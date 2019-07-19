import astro, times, options, unittest

abortOnError = false

func around(value, spread, measured: float64): bool =
  return (measured >= (value - spread)) and (measured <= (value + spread))

func around(value, spread, measured: int64): bool =
  return (measured >= (value - spread)) and (measured <= (value + spread))

func around2min(value, measured: DateTime): bool =
  return around(value.toTime.toUnix, 120, measured.toTime.toUnix)

proc verifySunTime(value: Option[DateTime], hasValue: bool, correctValue: DateTime): bool = 
  if value.isSome:
    return hasValue and around2min(correctValue, value.get)
  else:
    return not hasValue

proc verifyMoonTime(riseT: Option[DateTime], setT: Option[DateTime], value: DateTimeSet): bool = 
    result = false
    if riseT.isSome:
      if value.riseTime.isSome:
        result = around2min(riseT.get, value.riseTime.get)
      else:
        result = false
    else:
      result = not value.riseTime.isSome
    if setT.isSome:
      if value.setTime.isSome:
        result = result and around2min(setT.get, value.setTime.get)
      else:
        result = false
    else:
      result = not value.setTime.isSome

proc verifySunPosition(date: DateTime, lat: Latitude, lon: Longitude, azi: float64, alt: float64): bool = 
  let pos = sunPosition(date, lat, lon)
  result = around(azi, 1, pos.azimuth) and around(alt, 1, pos.altitude)
  if not result: echo "wrong position calculated: ", pos, "->", (azi, alt)
  return result

proc verifyMoonPosition(date: DateTime, lat: Latitude, lon: Longitude, azi: float64, alt: float64, dis: int64): bool = 
  let pos = moonPosition(date, lat, lon)
  result = around(azi, 1, pos.azimuth) and around(alt, 1, pos.altitude) and around(dis, 100, pos.distance)
  if not result: echo "wrong position calculated: ", pos, "->", (azi, alt, dis)
  return result

proc newTimezone(tzName: string, offset: int): Timezone {.raises: [].} =
  proc zoneInfoFromAdjTime(adjTime: Time): ZonedTime {.locks: 0.} =
    result.isDst = false
    result.utcOffset = offset
    result.time = adjTime + initDuration(seconds = offset)

  proc zoneInfoFromTime(time: Time): ZonedTime {.locks: 0.} =
    result.isDst = false
    result.utcOffset = offset
    result.time = time

  result = newTimezone(tzName, zoneInfoFromTime, zoneInfoFromAdjTime)

let
  latGS = Latitude(51.9)
  lonGS = Longitude(10.43)
  latSD = Latitude(32.82)
  lonSD = Longitude(-117.10)
  tzGSw = newTimezone("GS", -3600)
  tzSDw = newTimezone("SD", 8 * 3600)
  tzGSs = newTimezone("GS", -7200)
  tzSDs = newTimezone("SD", 7 * 3600)
  shortestDayMorningGS = initDateTime(21, mDec, 2018, 9, 0, 0, 0, tzGSw)
  shortestDayMorningSD = initDateTime(21, mDec, 2018, 9, 0, 0, 0, tzSDw)
  shortestDayEveningGS = initDateTime(21, mDec, 2018, 18, 0, 0, 0, tzGSw)
  shortestDayEveningSD = initDateTime(21, mDec, 2018, 18, 0, 0, 0, tzSDw)
  longestDayMorningGS = initDateTime(21, mJun, 2019, 9, 0, 0, 0, tzGSs)
  longestDayMorningSD = initDateTime(21, mJun, 2019, 9, 0, 0, 0, tzSDs)
  longestDayEveningGS = initDateTime(21, mJun, 2019, 18, 0, 0, 0, tzGSs)
  longestDayEveningSD = initDateTime(21, mJun, 2019, 18, 0, 0, 0, tzSDs)

suite "sun position":
  # shortest day
  test "sun position for Goslar @ 21 Dec 2018 9:00":
    check verifySunPosition(shortestDayMorningGS, latGS, lonGS, 136.0, 3.3)
  test "sun position for Goslar @ 21 Dec 2018 18:00":
    check verifySunPosition(shortestDayEveningGS, latGS, lonGS, 252.0, -15.8)
  test "sun position for San Diego @ 21 Dec 2018 9:00":
    check verifySunPosition(shortestDayMorningSD, latSD, lonSD, 139.2, 21.2)
  test "sun position for San Diego @ 21 Dec 2018 18:00":
    check verifySunPosition(shortestDayEveningSD, latSD, lonSD, 251.6, -15.1)
  
  # longest day
  test "sun position for Goslar @ 21 Jun 2019 9:00":
    check verifySunPosition(longestDayMorningGS, latGS, lonGS, 94.1, 33.6)
  test "sun position for Goslar @ 21 Jun 2019 18:00":
    check verifySunPosition(longestDayEveningGS, latGS, lonGS, 269.9, 30.5)
  test "sun position for San Diego @ 21 Jun 2019 9:00":
    check verifySunPosition(longestDayMorningSD, latSD, lonSD, 85.0, 39.0)
  test "sun position for San Diego @ 21 Jun 2019 18:00":
    check verifySunPosition(longestDayEveningSD, latSD, lonSD, 284.2, 22.6)

suite "sun times":
  # longest day
  test "sun times for Goslar @ 21 Jun 2019":
    let st = sunDateTimes(longestDayEveningGS, latGS, lonGS, tzGSs)
    check verifySunTime(st.solarNoon, true, initDateTime(21, mJun, 2019, 13, 21, 5, 0, tzGSs))
    check verifySunTime(st.nadir, true, initDateTime(21, mJun, 2019, 01, 21, 5, 0, tzGSs))
    check verifySunTime(st.sunRise, true, initDateTime(21, mJun, 2019, 04, 59, 32, 0, tzGSs))
    check verifySunTime(st.sunSet, true, initDateTime(21, mJun, 2019, 21, 42, 37, 0, tzGSs))
    check verifySunTime(st.civilDawn, true, initDateTime(21, mJun, 2019, 04, 10, 48, 0, tzGSs))
    check verifySunTime(st.civilDusk, true, initDateTime(21, mJun, 2019, 22, 31, 22, 0, tzGSs))
    check verifySunTime(st.nauticalDawn, true, initDateTime(21, mJun, 2019, 02, 52, 53, 0, tzGSs))
    check verifySunTime(st.nauticalDusk, true, initDateTime(21, mJun, 2019, 23, 49, 16, 0, tzGSs))
    check verifySunTime(st.astroDawn, false, initDateTime(21, mJun, 1970, 01, 0, 0, 0, tzGSs))
    check verifySunTime(st.astroDusk, false, initDateTime(21, mJun, 1970, 01, 0, 0, 0, tzGSs))
  test "sun times for San Diego @ 21 Jun 2019":
    let st = sunDateTimes(longestDayEveningSD, latSD, lonSD, tzSDs)
    check verifySunTime(st.solarNoon, true, initDateTime(21, mJun, 2019, 12, 51, 27, 0, tzSDs))
    check verifySunTime(st.nadir, true, initDateTime(21, mJun, 2019, 00, 51, 27, 0, tzSDs))
    check verifySunTime(st.sunRise, true, initDateTime(21, mJun, 2019, 05, 41, 59, 0, tzSDs))
    check verifySunTime(st.sunSet, true, initDateTime(21, mJun, 2019, 20, 00, 56, 0, tzSDs))
    check verifySunTime(st.civilDawn, true, initDateTime(21, mJun, 2019, 05, 13, 19, 0, tzSDs))
    check verifySunTime(st.civilDusk, true, initDateTime(21, mJun, 2019, 20, 29, 36, 0, tzSDs))
    check verifySunTime(st.nauticalDawn, true, initDateTime(21, mJun, 2019, 04, 38, 10, 0, tzSDs))
    check verifySunTime(st.nauticalDusk, true, initDateTime(21, mJun, 2019, 21, 04, 45, 0, tzSDs))
    check verifySunTime(st.astroDawn, true, initDateTime(21, mJun, 2019, 03, 59, 56, 0, tzSDs))
    check verifySunTime(st.astroDusk, true, initDateTime(21, mJun, 2019, 21, 42, 59, 0, tzSDs))

suite "moon position":
  # shortest day
  test "moon position for Goslar @ 21 Dec 2018 9:00":
    check verifyMoonPosition(shortestDayMorningGS, latGS, lonGS, 331.0, -15.3, 368681)
  test "moon position for Goslar @ 21 Dec 2018 18:00":
    check verifyMoonPosition(shortestDayEveningGS, latGS, lonGS, 85.7, 20.7, 367007)
  test "moon position for San Diego @ 21 Dec 2018 9:00":
    check verifyMoonPosition(shortestDayMorningSD, latSD, lonSD, 329.5, -31.8, 367007)
  test "moon position for San Diego @ 21 Dec 2018 18:00":
    check verifyMoonPosition(shortestDayEveningSD, latSD, lonSD, 79.0, 20.9, 365512)

  # longest day
  test "moon position for Goslar @ 21 Jun 2019 9:00":
    check verifyMoonPosition(longestDayMorningGS, latGS, lonGS, 240.2, -1.1, 402248)
  test "moon position for Goslar @ 21 Jun 2019 18:00":
    check verifyMoonPosition(longestDayEveningGS, latGS, lonGS, 28.0, -53.2, 402989)
  test "moon position for San Diego @ 21 Jun 2019 9:00":
    check verifyMoonPosition(longestDayMorningSD, latSD, lonSD, 244.0, 6.6, 402989)
  test "moon position for San Diego @ 21 Jun 2019 18:00":
    check verifyMoonPosition(longestDayEveningSD, latSD, lonSD, 53.55, -65.4, 403598)

suite "moon times":
  # longest day
  test "moon times for Goslar and San Diego @ 21 Dec 2018":
    check verifyMoonTime(some(initDateTime(21, mDec, 2018, 15, 27, 00, tzGSw)),
               some(initDateTime(21, mDec, 2018, 06, 30, 00, tzGSw)),
               moonDateTimes(shortestDayMorningGS, latGS, lonGS, tzGSw))
    check verifyMoonTime(some(initDateTime(21, mDec, 2018, 16, 11, 00, tzSDw)),
               some(initDateTime(21, mDec, 2018, 05, 32, 00, tzSDw)),
               moonDateTimes(shortestDayMorningSD, latSD, lonSD, tzSDw))
  test "moon times for Goslar and San Diego @ 21 Jun 2019":
    check verifyMoonTime(some(initDateTime(21, mJun, 2019, 00, 06, 00, tzGSs)),
               some(initDateTime(21, mJun, 2019, 08, 51, 00, tzGSs)),
               moonDateTimes(longestDayMorningGS, latGS, lonGS, tzGSs))
    check verifyMoonTime(some(initDateTime(21, mJun, 2019, 23, 28, 43, tzSDs)),
               some(initDateTime(21, mJun, 2019, 09, 33, 24, tzSDs)),
               moonDateTimes(longestDayMorningSD, latSD, lonSD, tzSDs))
            