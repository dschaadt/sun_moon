import sun_moon, times

let
  latBE = Latitude(52.49)
  lonBE = Longitude(13.43)
  day = initDateTime(13, mMar, 2025, 14, 30, 0, 0, local())

# results assume that your local timezone is Europe/Berlin, i.e. UTC+2

# should be (azimuth: 218.54, altitude: 27.89)
echo sunPosition(day, latBE, lonBE)

# should be (solarNoon: (val: 2025-03-13T12:17:09+01:00, has: true), nadir: (val: 2025-03-13T00:17:09+01:00, has: true), 
# sunSet: (val: 2025-03-13T18:07:31+01:00, has: true), sunRise: (val: 2025-03-13T06:26:48+01:00, has: true),
# sunRiseEnd: (val: 2025-03-13T06:30:18+01:00, has: true), sunSetStart: (val: 2025-03-13T18:04:01+01:00, has: true), 
# civilDawn: (val: 2025-03-13T05:52:50+01:00, has: true), civilDusk: (val: 2025-03-13T18:41:29+01:00, has: true), 
# nauticalDawn: (val: 2025-03-13T05:13:05+01:00, has: true), nauticalDusk: (val: 2025-03-13T19:21:14+01:00, has: true),
# astroDawn: (val: 2025-03-13T04:32:11+01:00, has: true), astroDusk: (val: 2025-03-13T20:02:08+01:00, has: true))
echo sunDateTimes(day, latBE, lonBE)

# should be (azimuth: 43.43, altitude: -21.53, distance: 399761)
echo moonPosition(day, latBE, lonBE)

# should be (riseTime: (val: 2025-03-13T17:21:42+01:00, has: true), setTime: (val: 2025-03-13T06:22:51+01:00, has: true))
echo moonDateTimes(day, latBE, lonBE)
