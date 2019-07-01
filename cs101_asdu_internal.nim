##
##   Copyright 2016, 2017 MZ Automation GmbH
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
  iec60870_types, iec60870_common #, information_objects_internal, apl_types_internal, lib_memory,
  #lib60870_internal

type
  sCS101_ASDU* {.bycopy.} = object
    parameters*: CS101_AppLayerParameters
    asdu*: ptr uint8_t
    asduHeaderLength*: cint
    payload*: ptr uint8_t
    payloadSize*: cint


## *
##  \brief create a new (read-only) instance
##
##  NOTE: Do not try to append information objects to the instance!
##

proc CS101_ASDU_createFromBuffer*(parameters: CS101_AppLayerParameters;
                                 msg: ptr uint8_t; msgLength: cint): CS101_ASDU