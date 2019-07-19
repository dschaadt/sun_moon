# Astro

This module provides functions for the calculation of the position of the sun, sunrise, sunset, civil, nautical and astronomical dawn and dusk, as well as the position of the moon, moonrise and moonset for a given time (including timezone) an location through latitude and longitude.

For the sun calculations, the formulas are identical to those used in suncalc.js (https://github.com/mourner/suncalc), which are based on http://aa.quae.nl/en/reken/zonpositie.html. For the calculations regarding the moon, formulas given in Chapter 47 in the book "Astronomical Algorithms", 2nd edition by Jean Meeus are used. Moonrise and moonset are used by calculating a table of moon position for the requested day and by approximating the time when the moon reaches an altitude of 0°, therefore the exact time is only within about 5 min correct. For extreme cases, when the moon is only visible for around less than 10 min, the calculations might therefore be incorrect.

## Installation

This module can be installed by `nimble install astro`. The documentation is astro.html, a unittest is located in tests (run with nimble test in that directory). Some examples are located the the examples folder.

## Usage

### Calculating data for a location within the local timezone

The following code calculates data for sun and moon in Berlin on March 13th, 2025 at 14:30 local time. Since no timezone is specified, the code assumes that you are in the timezone of Berlin. All location results are in degree, all time results are Option(DateTime) since there is sometimes no sunrise etc. for certain locations.

~~~~
import astro, times

let
# Berlin
    lat_BE = Latitude(52.49)
    lon_BE = Longitude(13.43)
    day = initDateTime(13, mMar, 2025, 14, 30, 0, 0, local())

# results assume that your local timezone is Europe/Berlin, i.e. UTC+2
echo sunPosition(day, lat_BE, lon_BE)
echo sunDateTimes(day, lat_BE, lon_BE)
echo moonPosition(day, lat_BE, lon_BE)
echo moonDateTimes(day, lat_BE, lon_BE)
~~~~
output if you are in the timezone Europe/Berlin (UTC+2):

~~~~
(azimuth: 218.54, altitude: 27.89)

(solarNoon: (val: 2025-03-13T12:17:09+01:00, has: true), nadir: (val: 2025-03-13T00:17:09+01:00, has: true),
sunSet: (val: 2025-03-13T18:07:31+01:00, has: true), sunRise: (val: 2025-03-13T06:26:48+01:00, has: true),
sunRiseEnd: (val: 2025-03-13T06:30:18+01:00, has: true), sunSetStart: (val: 2025-03-13T18:04:01+01:00, has: true),
civilDawn: (val: 2025-03-13T05:52:50+01:00, has: true), civilDusk: (val: 2025-03-13T18:41:29+01:00, has: true),
nauticalDawn: (val: 2025-03-13T05:13:05+01:00, has: true), nauticalDusk: (val: 2025-03-13T19:21:14+01:00, has: true),
astroDawn: (val: 2025-03-13T04:32:11+01:00, has: true), astroDusk: (val: 2025-03-13T20:02:08+01:00, has: true))

(azimuth: 43.43, altitude: -21.53, distance: 399761)

(riseTime: (val: 2025-03-13T17:21:42+01:00, has: true), setTime: (val: 2025-03-13T06:22:51+01:00, has: true))
~~~~

### Calculating data for a location outside the local timezone

~~~~
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
# San Diego
    lat_SD = Latitude(52.49)
    lon_SD = Longitude(13.43)
    tzSD = newTimezone("SD", 7 * 3600)
    day = initDateTime(13, mMar, 2025, 14, 30, 0, 0, tzSD)

echo sunPosition(day, lat_SD, lon_SD)
echo sunDateTimes(day, lat_SD, lon_SD, tzSD)
echo moonPosition(day, lat_SD, lon_SD)
echo moonDateTimes(day, lat_SD, lon_SD, tzSD)
~~~~

output (times given in San Diego local time):

~~~~
(azimuth: 215.86, altitude: 48.35)

(solarNoon: (val: 2025-03-13T12:59:12-07:00, has: true), nadir: (val: 2025-03-13T00:59:12-07:00, has: true),
sunSet: (val: 2025-03-13T18:56:04-07:00, has: true), sunRise: (val: 2025-03-13T07:02:21-07:00, has: true),
sunRiseEnd: (val: 2025-03-13T07:04:53-07:00, has: true), sunSetStart: (val: 2025-03-13T18:53:31-07:00, has: true),
civilDawn: (val: 2025-03-13T06:37:45-07:00, has: true), civilDusk: (val: 2025-03-13T19:20:40-07:00, has: true),
nauticalDawn: (val: 2025-03-13T06:09:09-07:00, has: true), nauticalDusk: (val: 2025-03-13T19:49:15-07:00, has: true),
astroDawn: (val: 2025-03-13T05:40:24-07:00, has: true), astroDusk: (val: 2025-03-13T20:18:01-07:00, has: true))

(azimuth: 38.37, altitude: -44.71, distance: 400587)

(riseTime: (val: 2025-03-13T18:41:26-07:00, has: true), setTime: (val: 2025-03-13T06:50:02-07:00, has: true))
~~~~

For some locations, the sun or moon might not rise or set. In such a case, the return time is of type none(DateTime), e.g.:

~~~~
let
# Hammerfest
    lat_HF = Latitude(70.66)
    lon_HF = Longitude(23.68)
    tzHF = newTimezone("HF", -7200)
    day = initDateTime(21, mJun, 2019, 9, 0, 0, 0, tzHF)

echo sunPosition(day, lat_HF, lon_HF)
echo sunDateTimes(day, lat_HF, lon_HF, tzHF)
echo moonPosition(day, lat_HF, lon_HF)
echo moonDateTimes(day, lat_HF, lon_HF, tzHF)

~~~~

output:

~~~~
(azimuth: 119.18, altitude: 34.26)

(solarNoon: (val: 2019-06-21T12:28:14+02:00, has: true), nadir: (val: 2019-06-21T00:28:14+02:00, has: true),
sunSet: (val: 0001-00-00T00:00:00+00:00, has: false), sunRise: (val: 0001-00-00T00:00:00+00:00, has: false),
sunRiseEnd: (val: 0001-00-00T00:00:00+00:00, has: false), sunSetStart: (val: 0001-00-00T00:00:00+00:00, has: false),
civilDawn: (val: 0001-00-00T00:00:00+00:00, has: false), civilDusk: (val: 0001-00-00T00:00:00+00:00, has: false),
nauticalDawn: (val: 0001-00-00T00:00:00+00:00, has: false), nauticalDusk: (val: 0001-00-00T00:00:00+00:00, has: false),
astroDawn: (val: 0001-00-00T00:00:00+00:00, has: false), astroDusk: (val: 0001-00-00T00:00:00+00:00, has: false))

(azimuth: 253.98, altitude: -14.27, distance: 402248)

(riseTime: (val: 2019-06-21T03:23:04+02:00, has: true), setTime: (val: 2019-06-21T03:48:47+02:00, has: true))
~~~~

## About
This module was initially written by Daniel M. Schaadt and is licensed under MIT license.