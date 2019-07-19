import astro, times

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
  latSD = Latitude(32.825)
  lonSD = Longitude(-117.108)
  tzSD = newTimezone("SD", 7 * 3600)
  day = initDateTime(13, mMar, 2025, 14, 30, 0, 0, tzSD)

# should be (azimuth: 215.86, altitude: 48.35)
echo sunPosition(day, latSD, lonSD)

# should be (solarNoon: (val: 2025-03-13T12:59:12-07:00, has: true), nadir: (val: 2025-03-13T00:59:12-07:00, has: true),
# sunSet: (val: 2025-03-13T18:56:04-07:00, has: true), sunRise: (val: 2025-03-13T07:02:21-07:00, has: true),
# sunRiseEnd: (val: 2025-03-13T07:04:53-07:00, has: true), sunSetStart: (val: 2025-03-13T18:53:31-07:00, has: true),
# civilDawn: (val: 2025-03-13T06:37:45-07:00, has: true), civilDusk: (val: 2025-03-13T19:20:40-07:00, has: true),
# nauticalDawn: (val: 2025-03-13T06:09:09-07:00, has: true), nauticalDusk: (val: 2025-03-13T19:49:15-07:00, has: true),
# astroDawn: (val: 2025-03-13T05:40:24-07:00, has: true), astroDusk: (val: 2025-03-13T20:18:01-07:00, has: true))
echo sunDateTimes(day, latSD, lonSD, tzSD)

# should be (azimuth: 38.37, altitude: -44.71, distance: 400587)
echo moonPosition(day, latSD, lonSD)

# should be (riseTime: (val: 2025-03-13T18:41:26-07:00, has: true), setTime: (val: 2025-03-13T06:50:02-07:00, has: true))
echo moonDateTimes(day, latSD, lonSD, tzSD)
