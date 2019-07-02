##
##   Copyright 2016 MZ Automation GmbH
##
##   This file is part of lib60870-C
##
##   lib60870-C is free software: you can redistribute it and/or modify
##   it under the terms of the GNU General Public License as published by
##   the Free Software Foundation, either version 3 of the License, or
##   (at your option) any later version.
##
##   lib60870-C is distributed in the hope that it will be useful,
##   but WITHOUT ANY WARRANTY; without even the implied warranty of
##   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
##   GNU General Public License for more details.
##
##   You should have received a copy of the GNU General Public License
##   along with lib60870-C.  If not, see <http://www.gnu.org/licenses/>.
##
##   See COPYING file for the complete license text.
##

import 
  iec60870_types, winlean, times

proc Hal_getTimeInMs*(): uint64_t = 
  return cast[uint64_t] (toUnix(getTime())*1000)


#[proc Hal_getTimeInMs*(): uint64_t =
  var ft: FILETIME
  var now: uint64_t
  var DIFF_TO_UNIXTIME: uint64_t = 11644473600000'u64
  GetSystemTimeAsFileTime(addr(ft))
  now = cast[LONGLONG](ft.dwLowDateTime) + ((LONGLONG)(ft.dwHighDateTime) shl 32)
  return (now div 10000) - DIFF_TO_UNIXTIME]#