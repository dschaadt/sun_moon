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
    lat_HF = Latitude(70.66)
    lon_HF = Longitude(23.68)
    tzHF = newTimezone("HF", -7200)
    day = initDateTime(21, mJun, 2019, 9, 0, 0, 0, tzHF)

# results assume that your local timezone is Europe/Berlin, i.e. UTC+2

# should be (azimuth: 119.18, altitude: 34.26)
echo sunPosition(day, lat_HF, lon_HF)

# should be (solarNoon: (val: 2019-06-21T12:28:14+02:00, has: true), nadir: (val: 2019-06-21T00:28:14+02:00, has: true),
# sunSet: (val: 0001-00-00T00:00:00+00:00, has: false), sunRise: (val: 0001-00-00T00:00:00+00:00, has: false),
# sunRiseEnd: (val: 0001-00-00T00:00:00+00:00, has: false), sunSetStart: (val: 0001-00-00T00:00:00+00:00, has: false),
# civilDawn: (val: 0001-00-00T00:00:00+00:00, has: false), civilDusk: (val: 0001-00-00T00:00:00+00:00, has: false),
# nauticalDawn: (val: 0001-00-00T00:00:00+00:00, has: false), nauticalDusk: (val: 0001-00-00T00:00:00+00:00, has: false),
# astroDawn: (val: 0001-00-00T00:00:00+00:00, has: false), astroDusk: (val: 0001-00-00T00:00:00+00:00, has: false))
echo sunDateTimes(day, lat_HF, lon_HF)

# should be (azimuth: 253.98, altitude: -14.27, distance: 402248)
echo moonPosition(day, lat_HF, lon_HF)

# should be (riseTime: (val: 2019-06-21T03:23:04+02:00, has: true), setTime: (val: 2019-06-21T03:48:47+02:00, has: true))
echo moonDateTimes(day, lat_HF, lon_HF)