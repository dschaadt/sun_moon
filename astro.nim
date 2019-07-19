## This module provides functions for the calculation of the position of the sun,
## sunrise, sunset, civil, nautical and astronomical dawn and dusk, as well as
## the position of the moon, moonrise and moonset for a given time (including timezone) an
## location through latitude and longitude.
##
## For the sun calculations, the formulas are identical to those used in suncalc.js (https://github.com/mourner/suncalc),
## which are based on http://aa.quae.nl/en/reken/zonpositie.html.
## For the calculations regarding the moon, formulas given in Chapter 47 in the book "Astronomical Algorithms", 2nd edition
## by Jean Meeus are used. Moonrise and moonset are used by calculating a table of moon position for the requested day and
## by approximating the time when the moon reaches an altitude of 0°, therefore the exact time is only within about 5 min
## correct. For extreme cases, when the moon is only visible for around less than 10 min, the calculations might therefore be incorrect.
##
##
## Examples
## ========
##
## Calculating data for a location within the local timezone
## ---------------------------
##
## The following code calculates data for sun and moon in Berlin on March 13th, 2025 at 14:30 local time.
## Since no timezone is specified, the code assumes that you are in the timezone of Berlin.
## All location results are in degree, all time results are Option(DateTime) since there is sometimes no
## sunrise etc. for certain locations.
##
## .. code-block:: nim
##
##   import astro, times
##   
##   let
##   # Berlin
##     lat_BE = Latitude(52.49)
##     lon_BE = Longitude(13.43)
##     day = initDateTime(13, mMar, 2025, 14, 30, 0, 0, local())
##
##   # results assume that your local timezone is Europe/Berlin, i.e. UTC+2
##   echo sunPosition(day, lat_BE, lon_BE)
##   echo sunDateTimes(day, lat_BE, lon_BE)
##   echo moonPosition(day, lat_BE, lon_BE)  
##   echo moonDateTimes(day, lat_BE, lon_BE)
##
## output if you are in the timezone Europe/Berlin (UTC+2):
##
## .. code-block:: nim
##   
##   (azimuth: 218.54, altitude: 27.89)
##
##   (solarNoon: (val: 2025-03-13T12:17:09+01:00, has: true), nadir: (val: 2025-03-13T00:17:09+01:00, has: true), 
##   sunSet: (val: 2025-03-13T18:07:31+01:00, has: true), sunRise: (val: 2025-03-13T06:26:48+01:00, has: true),
##   sunRiseEnd: (val: 2025-03-13T06:30:18+01:00, has: true), sunSetStart: (val: 2025-03-13T18:04:01+01:00, has: true), 
##   civilDawn: (val: 2025-03-13T05:52:50+01:00, has: true), civilDusk: (val: 2025-03-13T18:41:29+01:00, has: true), 
##   nauticalDawn: (val: 2025-03-13T05:13:05+01:00, has: true), nauticalDusk: (val: 2025-03-13T19:21:14+01:00, has: true),
##   astroDawn: (val: 2025-03-13T04:32:11+01:00, has: true), astroDusk: (val: 2025-03-13T20:02:08+01:00, has: true))
## 
##   (azimuth: 43.43, altitude: -21.53, distance: 399761)
## 
##   (riseTime: (val: 2025-03-13T17:21:42+01:00, has: true), setTime: (val: 2025-03-13T06:22:51+01:00, has: true))
## 
## Calculating data for a location outside the local timezone
## ---------------------------
##
## .. code-block:: nim
##
##   import astro, times
##   
##   proc newTimezone(tzName: string, offset: int): Timezone {.raises: [].} =
##     proc zoneInfoFromAdjTime(adjTime: Time): ZonedTime {.locks: 0.} =
##       result.isDst = false
##       result.utcOffset = offset
##       result.time = adjTime + initDuration(seconds = offset)
##   
##     proc zoneInfoFromTime(time: Time): ZonedTime {.locks: 0.} =
##       result.isDst = false
##       result.utcOffset = offset
##       result.time = time
##   
##     result = newTimezone(tzName, zoneInfoFromTime, zoneInfoFromAdjTime)
##   
##   let
##   # San Diego
##     lat_SD = Latitude(52.49)
##     lon_SD = Longitude(13.43)
##     tzSD = newTimezone("SD", 7 * 3600)
##     day = initDateTime(13, mMar, 2025, 14, 30, 0, 0, tzSD)
##
##   echo sunPosition(day, lat_SD, lon_SD)
##   echo sunDateTimes(day, lat_SD, lon_SD, tzSD)
##   echo moonPosition(day, lat_SD, lon_SD)
##   echo moonDateTimes(day, lat_SD, lon_SD, tzSD)
##
## output (times given in San Diego local time):
##
## .. code-block:: nim
##   
##   (azimuth: 215.86, altitude: 48.35)
##
##   (solarNoon: (val: 2025-03-13T12:59:12-07:00, has: true), nadir: (val: 2025-03-13T00:59:12-07:00, has: true),
##   sunSet: (val: 2025-03-13T18:56:04-07:00, has: true), sunRise: (val: 2025-03-13T07:02:21-07:00, has: true),
##   sunRiseEnd: (val: 2025-03-13T07:04:53-07:00, has: true), sunSetStart: (val: 2025-03-13T18:53:31-07:00, has: true),
##   civilDawn: (val: 2025-03-13T06:37:45-07:00, has: true), civilDusk: (val: 2025-03-13T19:20:40-07:00, has: true),
##   nauticalDawn: (val: 2025-03-13T06:09:09-07:00, has: true), nauticalDusk: (val: 2025-03-13T19:49:15-07:00, has: true),
##   astroDawn: (val: 2025-03-13T05:40:24-07:00, has: true), astroDusk: (val: 2025-03-13T20:18:01-07:00, has: true))
## 
##   (azimuth: 38.37, altitude: -44.71, distance: 400587)
## 
##   (riseTime: (val: 2025-03-13T18:41:26-07:00, has: true), setTime: (val: 2025-03-13T06:50:02-07:00, has: true))
## 
## For some locations, the sun or moon might not rise or set. In such a case, the return time is of type none(DateTime), e.g.:
##
## .. code-block:: nim
##
##   let
##   # Hammerfest
##     lat_HF = Latitude(70.66)
##     lon_HF = Longitude(23.68)
##     tzHF = newTimezone("HF", -7200)
##     day = initDateTime(21, mJun, 2019, 9, 0, 0, 0, tzHF)
##
##   echo sunPosition(day, lat_HF, lon_HF)
##   echo sunDateTimes(day, lat_HF, lon_HF, tzHF)
##   echo moonPosition(day, lat_HF, lon_HF)
##   echo moonDateTimes(day, lat_HF, lon_HF, tzHF)
##
## output:
##
## .. code-block:: nim
##   
##   (azimuth: 119.18, altitude: 34.26)
##
##   (solarNoon: (val: 2019-06-21T12:28:14+02:00, has: true), nadir: (val: 2019-06-21T00:28:14+02:00, has: true),
##   sunSet: (val: 0001-00-00T00:00:00+00:00, has: false), sunRise: (val: 0001-00-00T00:00:00+00:00, has: false),
##   sunRiseEnd: (val: 0001-00-00T00:00:00+00:00, has: false), sunSetStart: (val: 0001-00-00T00:00:00+00:00, has: false),
##   civilDawn: (val: 0001-00-00T00:00:00+00:00, has: false), civilDusk: (val: 0001-00-00T00:00:00+00:00, has: false),
##   nauticalDawn: (val: 0001-00-00T00:00:00+00:00, has: false), nauticalDusk: (val: 0001-00-00T00:00:00+00:00, has: false),
##   astroDawn: (val: 0001-00-00T00:00:00+00:00, has: false), astroDusk: (val: 0001-00-00T00:00:00+00:00, has: false))
## 
##   (azimuth: 253.98, altitude: -14.27, distance: 402248)
## 
##   (riseTime: (val: 2019-06-21T03:23:04+02:00, has: true), setTime: (val: 2019-06-21T03:48:47+02:00, has: true))
## 

import times, math, options

type 
  Latitude* = range[-90.0..90.0] ## Represents the geographical latitude in degrees.
  Longitude* = range[-180.0..180.0] ## Represents the geographical longitude in degrees.
  EquatorialCoordinate = tuple ## Objects location in the equatorial coordinate system. Used for the sun.
    declination: float64
    rightAscension: float64
  EquatorialCoordinateDistance = tuple ## Objects location in the equatorial coordinate system including distance in km. Used for the moon.
    declination: float64
    rightAscension: float64
    distance: int64
  Azimuth* = range[-360.0..360.0] ## Represents the angular measurement in the horizontal coordinate system. 0° corresponds to north.
  Altitude* = range[-90.0..90.0] ## Represents the elevation in the horizontal coordinate system.
  HorizontalCoordinate* = tuple ## Represents the coordinate in the horizontal coordinate system.
    azimuth: Azimuth
    altitude: Altitude
  HorizontalCoordinateDistance* = tuple ## Represents the coordinate in the horizontal coordinate system including the distance in km.
    azimuth: Azimuth
    altitude: Altitude
    distance: int64

const
  EarthObliquity = float64(degToRad(23.4397))
  DaySecs = 86400
  J1970 = 2440588
  J2000 = 2451545
  J0 = 0.0009

func round100(value: float64): float64 =
  return round(value * 100) / 100
  
func toJulian(unixTime: int64): float64 = 
  return float64(unixTime) / DaySecs - 0.5 + J1970

func fromJulian(j: float64, zone = local()): DateTime =
  {.noSideEffect.}:
    return inZone(fromUnix(int64(round((j + 0.5 - float64(J1970)) * DaySecs))), zone)

func toDays(unixTime: int64): float64 =
  return toJulian(unixTime) - J2000

func azimuth(H: float64, phi: float64, dec: float64): float64 =
  return radToDeg(arctan2(sin(H), cos(H) * sin(phi) - tan(dec) * cos(phi))) + 180

func altitude(H: float64, phi: float64, dec: float64): float64 =
  return radToDeg(arcsin(sin(phi) * sin(dec) + cos(phi) * cos(dec) * cos(H)))

func solarMeanAnomaly(d: float64): float64 = 
  return degToRad(357.5291 + 0.98560028 * d)

func eclipticLongitude(M: float64): float64 =
  let
    C = degToRad(1.9148 * sin(M) + 0.02 * sin(2 * M) + 0.0003 * sin(3 * M))
    P = degToRad(102.9372)

  return M + C + P + PI

func rightAscension(l: float64, b: float64): float64 =
  return arctan2(sin(l) * cos(EarthObliquity) - tan(b) * sin(EarthObliquity), cos(l))

func declination(l: float64 , b: float64): float64 =
  return arcsin(sin(b) * cos(EarthObliquity) + cos(b) * sin(EarthObliquity) * sin(l))
  
func sunCoords(d: float64): EquatorialCoordinate =
  let
    M = solarMeanAnomaly(d)
    L = eclipticLongitude(M)

  return (declination(L, 0), rightAscension(L, 0))

func siderealTime(d: float64, lw: float64): float64 =
  return degToRad(280.16 + 360.9856235 * d) - lw

func sunPosition(unixTime: int64, lat: Latitude, lon: Longitude): HorizontalCoordinate =
  let
    lw  = degToRad(-lon)
    phi = degToRad(lat)
    d   = toDays(unixTime)
    c  = sunCoords(d)
    H  = siderealTime(d, lw) - c.rightAscension

  return (Azimuth(round100(azimuth(H, phi, c.declination))), Altitude(round100(altitude(H, phi, c.declination))))

func sunPosition*(date: DateTime, lat: Latitude, lon: Longitude): HorizontalCoordinate =
  ## Calculates the position of the sun in horizontal coordinates for a given datetime and location.
  return sunPosition(date.toTime().toUnix(), lat, lon)

func julianCycle(d: float64, lw: float64): float64 =
  return round(d - J0 - lw / (2 * PI))

func approxTransit(Ht: float64, lw: float64, n: float64): float64 =
  return J0 + (Ht + lw) / (2 * PI) + n

func solarTransitJ(ds: float64, M: float64, L: float64): float64 =
  return J2000 + ds + 0.0053 * sin(M) - 0.0069 * sin(2 * L)

func hourAngle(h: float64, phi: float64, d: float64): float64 = 
  return arccos((sin(h) - sin(phi) * sin(d)) / (cos(phi) * cos(d)))

func getSetJ(h: float64, lw: float64, phi: float64, dec: float64, n: float64, M: float64, L: float64): float64 =
  let
    w = hourAngle(h, phi, dec)
    a = approxTransit(w, lw, n)

  return solarTransitJ(a, M, L)

type
  TimeSet = tuple
    riseTime: Option[Time]
    setTime: Option[Time]
  DateTimeSet* = tuple ## Represents rise and set times as a set of Option[DateTime].
    riseTime: Option[DateTime]
    setTime: Option[DateTime]
  SunDateTimes* = tuple ## Represents time form sun calculation as set of Option[DateTime].
    solarNoon: Option[DateTime]
    nadir: Option[DateTime]
    sunSet: Option[DateTime]
    sunRise: Option[DateTime]
    sunRiseEnd: Option[DateTime]
    sunSetStart: Option[DateTime]
    civilDawn: Option[DateTime]
    civilDusk: Option[DateTime]
    nauticalDawn: Option[DateTime]
    nauticalDusk: Option[DateTime]
    astroDawn: Option[DateTime]
    astroDusk: Option[DateTime]
#[
func sunTimeSet(unixTime: int64, angle: float64, lat: Latitude, lon: Longitude): TimeSet =
  let
    lw  = degToRad(-lon)
    phi = degToRad(lat)
    d   = toDays(unixTime)
    c = julianCycle(d, lw)
    ds = approxTransit(0, lw, c)
    M = solarMeanAnomaly(ds)
    L = eclipticLongitude(M)
    dec = declination(L, 0)

    n = solarTransitJ(ds, M, L)
    s = getSetJ(degToRad(angle), lw, phi, dec, c, M, L)
    r = n - (s - n);

  result.riseTime = if r.classify != fcNaN: some(fromJulian(r)) else: none(Time)
  result.setTime = if s.classify != fcNaN: some(fromJulian(s)) else: none(Time)

func sunTimeSet*(date: DateTime, angle: float64, lat: Latitude, lon: Longitude): TimeSet =
  return sunTimeSet(date.toTime().toUnix(), angle, lat, lon)
]#
func sunDateTimes*(date: DateTime, lat: Latitude, lon: Longitude, zone = local()): SunDateTimes =
  ## Calculates solar noon, nadir, sunrise, sunset, sunrise end, sunset start, civil, nautical and astronomical dawn and dusk
  ## for a given datetime, latitude and longitude. If no timezone is specified, the local timezone is used. If you want the
  ## correct time for a random location, specify that locations timezone.
  ## If no value can be calculated, for instance the is no sunrise, none(DateTime) will be the result for that value.
  var s, r: float64
  let
    unixTime = date.toTime.toUnix
    lw  = degToRad(-lon)
    phi = degToRad(lat)
    d   = toDays(unixTime)
    c = julianCycle(d, lw)
    ds = approxTransit(0, lw, c)
    M = solarMeanAnomaly(ds)
    L = eclipticLongitude(M)
    dec = declination(L, 0)
    n = solarTransitJ(ds, M, L)
  
  result.solarNoon =  if n.classify != fcNaN: some(fromJulian(n, zone)) else: none(DateTime)
  result.nadir = if n.classify != fcNaN: some(fromJulian((n - 0.5), zone)) else: none(DateTime)

  s = getSetJ(degToRad(-0.833), lw, phi, dec, c, M, L)
  r = n - (s - n)
  result.sunSet = if s.classify != fcNaN: some(fromJulian(s, zone)) else: none(DateTime)
  result.sunRise = if r.classify != fcNaN: some(fromJulian(r, zone)) else: none(DateTime)

  s = getSetJ(degToRad(-0.3), lw, phi, dec, c, M, L)
  r = n - (s - n)
  result.sunSetStart = if s.classify != fcNaN: some(fromJulian(s, zone)) else: none(DateTime)
  result.sunRiseEnd = if r.classify != fcNaN: some(fromJulian(r, zone)) else: none(DateTime)

  s = getSetJ(degToRad(-6.0), lw, phi, dec, c, M, L)
  r = n - (s - n)
  result.civilDusk = if s.classify != fcNaN: some(fromJulian(s, zone)) else: none(DateTime)
  result.civilDawn = if r.classify != fcNaN: some(fromJulian(r, zone)) else: none(DateTime)

  s = getSetJ(degToRad(-12.0), lw, phi, dec, c, M, L)
  r = n - (s - n)
  result.nauticalDusk = if s.classify != fcNaN: some(fromJulian(s, zone)) else: none(DateTime)
  result.nauticalDawn = if r.classify != fcNaN: some(fromJulian(r, zone)) else: none(DateTime)

  s = getSetJ(degToRad(-18.0), lw, phi, dec, c, M, L)
  r = n - (s - n)
  result.astroDusk = if s.classify != fcNaN: some(fromJulian(s, zone)) else: none(DateTime)
  result.astroDawn = if r.classify != fcNaN: some(fromJulian(r, zone)) else: none(DateTime)

#[ formulas from suncalc.js, does not work very well
func moonCoords(d: float64): EquatorialCoordinate =
  let
    M = degToRad(134.963 + 13.064993 * d)
    L = degToRad(218.316 + 13.176396 * d)
    F = degToRad(93.272 + 13.229350 * d)
    l  = L + degToRad(6.289 * sin(M))
    b  = degToRad(5.128 * sin(F))

  return (declination(l, b), rightAscension(l, b))
]#

func fnred(x: float64): float64 =
  let r = x - float64(360 * int64(x / 360))
  return if r < 0: r + 360 else: r

func moonCoords(d: float64): EquatorialCoordinateDistance =
  const
    ta = [[0, 0, 1, 0, 6288774, -20905355], [2, 0, -1, 0, 1274027, -3699111], [2, 0, 0, 0, 658314, -2955968],
          [0, 0, 2, 0, 213618, -569925], [0, 1, 0, 0, -185116, 48888],[0, 0, 0, 2, -114332, -3149],
          [2, 0, -2, 0, 58793, 246158], [2, -1, -1, 0, 57066, -152138], [2, 0, 1, 0, 53322, -170733],
          [2, -1, 0, 0, 45758, -204586], [0, 1, -1, 0, -40923, -129620], [1, 0, 0, 0, -34720, 108743],
          [0, 1, 1, 0, -30383, 104755], [2, 0, 0, -2, 15327, 10321], [0, 0, 1, 2, -12528, 0],
          [0, 0, 1, -2, 10980, 79661], [4, 0, -1, 0, 10675, -34782], [0, 0, 3, 0, 10034, -23210],
          [4, 0, -2, 0, 8548, -21636], [2, 1, -1, 0, -7888, 24208], [2, 1, 0, 0, -6766, 30824],
          [1, 0, -1, 0, -5163, -8379], [1, 1, 0, 0, 4987, -16675], [2, -1, 1, 0, 4036, -12831],
          [2, 0, 2, 0, 3994, -10445], [4, 0, 0, 0, 3861, -11650], [2, 0, -3, 0, 3665, 14403],
          [0, 1, -2, 0, -2689, -7003], [2, 0, -1, 2, -2602, 0], [2, -1, -2, 0, 2390, 10056],
          [1, 0, 1, 0, -2348, 6322], [2, -2, 0, 0, 2236, -9884], [0, 1, 2, 0, -2120, 5751],
          [0, 2, 0, 0, -2069, 0], [2, -2, -1, 0, 2048, -4950], [2, 0, 1, -2, -1773, 4130],
          [2, 0, 0, 2, -1595, 0], [4, -1, -1, 0, 1215, -3958], [0, 0, 2, 2, -1110, 0],
          [3, 0, -1, 0, -892, 3258], [2, 1, 1, 0, -810, 2616], [4, -1, -2, 0, 759, -1897],
          [0, 2, -1, 0, -713, -2117], [2, 2, -1, 0, -700, 2354], [2, 1, -2, 0, 691, 0],
          [2, -1, 0, -2, 596, 0], [4, 0, 1, 0, 549, -1423], [0, 0, 4, 0, 537, -1117],
          [4, -1, 0, 0, 520, -1571], [1, 0, -2, 0, -487, -1739], [2, 1, 0, -2, -399, 0],
          [0, 0, 2, -2, -381, -4421], [1, 1, 1, 0, 351, 0], [3, 0, -2, 0, -340, 0],
          [4, 0, -3, 0, 330, 0], [2, -1, 2, 0, 327, 0], [0, 2, 1, 0, -323, 1165],
          [1, 1, -1, 0, 299, 0], [2, 0, 3, 0, 294, 0], [2, 0, -1, -2, 0, 8752]]
    tb = [[0, 0, 0, 1, 5128122], [0, 0, 1, 1, 280602], [0, 0, 1, -1, 277693],
          [2, 0, 0, -1, 173237], [2, 0, -1, 1, 55413], [2, 0, -1, -1, 46271],
          [2, 0, 0, 1, 32573], [0, 0, 2, 1, 17198], [2, 0, 1, -1, 9266],
          [0, 0, 2, -1, 8822], [2, -1, 0, -1, 8216], [2, 0, -2, -1, 4324],
          [2, 0, 1, 1, 4200], [2, 1, 0, -1, -3359], [2, -1, -1, 1, 2463],
          [2, -1, 0, 1, 2211], [2, -1, -1, -1, 2065], [0, 1, -1, -1, -1870],
          [4, 0, -1, -1, 1828], [0, 1, 0, 1, -1794], [0, 0, 0, 3, -1749],
          [0, 1, -1, 1, -1565], [1, 0, 0, 1, -1491], [0, 1, 1, 1, -1475],
          [0, 1, 1, -1, -1410], [0, 1, 0, -1, -1344], [1, 0, 0, -1, -1335],
          [0, 0, 3, 1, 1107], [4, 0, 0, -1, 1021], [4, 0, -1, 1, 833],
          [0, 0, 1, -3, 777], [4, 0, -2, 1, 671], [2, 0, 0, -3, 607],
          [2, 0, 2, -1, 596], [2, -1, 1, -1, 491], [2, 0, -2, 1, -451],
          [0, 0, 3, -1, 439], [2, 0, 2, 1, 422], [2, 0, -3, -1, 421],
          [2, 1, -1, 1, -366], [2, 1, 0, 1, -351], [4, 0, 0, 1, 331],
          [2, -1, 1, 1, 315], [2, -2, 0, -1, 302], [0, 0, 1, 3, -283],
          [2, 1, 1, -1, -229], [1, 1, 0, -1, 223], [1, 1, 0, 1, 223],
          [0, 1, -2, -1, -220], [2, 1, -1, -1, -220], [1, 0, 1, 1, -185],
          [2, -1, -2, -1, 181], [0, 1, 2, 1, -177], [4, 0, -2, -1, 176],
          [4, -1, -1, -1, 166], [1, 0, 1, -1, -164], [4, 0, 1, -1, 132],
          [1, 0, -1, -1, -119], [4, -1, 0, -1, 115], [2, -2, 0, 1, 107]]
  let
    T = d / 36525
    Lp = fnred(218.3164477 + 481267.88123421 * T - 0.0015786 * T^2 + T^3 / 538841 - T^4 / 65194000)
    D = fnred(297.8501921 + 445267.1114034 * T - 0.0018819 * T^2 + T^3 / 545868 - T^4 / 1130650000)
    M = fnred(357.5291092 + 35999.0502909 * T - 0.0001536 * T^2 + T^3 / 24490000)
    Mp = fnred(134.9633964 + 477198.8675055 * T + 0.0087414 * T^2 + T^3 / 69699 - T^4 / 14712000)
    F = fnred(93.2720950 + 483202.0175233 * T - 0.0036539 * T^2 - T^3 / 3526000 + T^4 / 863310000)
    A1 = fnred(119.75 + 131.849 * T)
    A2 = fnred(53.09 + 479264.29 * T)
    A3 = fnred(313.45 + 481266.484 * T)
    E = fnred(1 - 0.002516 * T - 0.0000074 * T^2)
  var
    suml = 3958 * sin(degToRad(A1)) + 1962 * sin(degToRad(Lp - F)) + 318 * sin(degToRad(A2))
    sumr = 0.0
    sumb = -2235 * sin(degToRad(Lp)) + 382 * sin(degToRad(A3)) + 175 * sin(degToRad(A1 - F)) + 175 * sin(degToRad(A1 + F)) + 127 * sin(degToRad(Lp - Mp)) - 115 * sin(degToRad(Lp + Mp))
    l = 0.0
    b = 0.0

  for i in 0..<len(ta):
    var a = D * float64(ta[i][0]) + M * float64(ta[i][1]) + Mp * float64(ta[i][2]) + F * float64(ta[i][3])
    var sa = sin(degToRad(a))
    var ca = cos(degToRad(a))
    case ta[i][1]:
      of 0:
        suml = suml + float64(ta[i][4]) * sa
        sumr = sumr + float64(ta[i][5]) * ca
      of 1 or -1:
        suml = suml + float64(ta[i][4]) * sa * E
        sumr = sumr + float64(ta[i][5]) * ca * E
      else: #of 2 or -2:
        suml = suml + float64(ta[i][4]) * sa * E^2
        sumr = sumr + float64(ta[i][5]) * ca * E^2

  l = Lp + suml / 1000000

  for i in 0..<len(tb):
    var b = D * float64(tb[i][0]) + M * float64(tb[i][1]) + Mp * float64(tb[i][2]) + F * float64(tb[i][3])
    var sb = sin(degToRad(b))
    case tb[i][1]:
      of 0:
        sumb = sumb + float64(tb[i][4]) * sb
      of 1 or -1:
        sumb = sumb + float64(tb[i][4]) * sb * E
      else: #of 2 or -2:
        sumb = sumb + float64(tb[i][4]) * sb * E^2

  b = sumb / 1000000

  return (declination(degToRad(l), degToRad(b)), rightAscension(degToRad(l), degToRad(b)), int64(385000.56 + sumr / 1000))
  
func astroRefraction(h: float64): float64 =
  if h < 0:
    return 0.0002967 / tan(0.00312536 / 0.08901179)
  else:
    return 0.0002967 / tan(h + 0.00312536 / (h + 0.08901179))

func moonPosition(unixTime: int64, lat: Latitude, lon: Longitude): HorizontalCoordinateDistance =
  let
    lw  = degToRad(-lon)
    phi = degToRad(lat)
    d   = toDays(unixTime)
    c  = moonCoords(d)
    H  = siderealTime(d, lw) - c.rightAscension
    h = altitude(H, phi, c.declination)

  return (Azimuth(round100(azimuth(H, phi, c.declination))), Altitude(round100(h + astroRefraction(h))), c.distance)
  
func moonPosition*(date: DateTime, lat: Latitude, lon: Longitude): HorizontalCoordinateDistance =
  ## Calculates the position of the moon in horizontal coordinates including the distance in km for a given datetime
  ## and location.
  return moonPosition(date.toTime.toUnix, lat, lon)
  
func later(unixTime: int64, h: int64, diff: int64): int64 =
  return int64(unixTime + h * diff)

func zeroTransit(startTime: int64, diff: int64, hStart: float64, hEnd: float64): int64 =
  return startTime + int64(abs(hStart/(hStart - hEnd)) * float64(diff))

#[
  Requires about 30µs per call and yields approximate values, most of the time within 10 min of correct values.
  t must be a date only (i.e. the time needs to be 00:00:00 in the lat/lon-corresponding timezone!)
]#
func moonTimes(t: int64, lat: Latitude, lon: Longitude): TimeSet =
  var h1: float64
  const hc = degToRad(0.133)

  var h0 = moonPosition(t, lat, lon).altitude - hc
  var visible0: bool = (h0 > 0)
  var visible1: bool

  var foundRise = false
  var foundSet = false
  let diff = 900 # resolution in seconds
  for i in countup(1, int(24 * 3600 / diff)):
    h1 = moonPosition(later(t, i, diff), lat, lon).altitude - hc
    visible1 = (h1 > 0)
    if visible0 != visible1:
      if visible0:
        foundSet = true
        result.setTime = some(fromUnix(zeroTransit(later(t, i - 1, diff), diff, h0, h1)))
      else:
        foundRise = true
        result.riseTime = some(fromUnix(zeroTransit(later(t, i - 1, diff), diff, h0, h1)))
      visible0 = visible1
    h0 = h1

func moonDateTimes*(date: DateTime, lat: Latitude, lon: Longitude, zone = local()): DateTimeSet =
  ## Calculates moonrise and moonset for a given datetime, latitude and longitude.
  ## If no timezone is specified, the local timezone is used. If you want the
  ## correct time for a random location, specify that locations timezone.
  ## If no value can be calculated, for instance the is no moonrise, none(DateTime) will be the result for that value.
  {.noSideEffect.}:
    result = (none(DateTime), none(DateTime))
    let t = moonTimes(initDateTime(date.monthday, date.month, date.year, 0, 0, 0, zone).toTime.toUnix, lat, lon)
    result.riseTime = if t.riseTime.isSome: some(inZone(t.riseTime.get, zone)) else: none(DateTime)
    result.setTime = if t.setTime.isSome: some(inZone(t.setTime.get, zone)) else: none(DateTime)
  