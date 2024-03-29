##
##   link_layer_parameters.h
##
##   Copyright 2017 MZ Automation GmbH
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

## *
##  \file link_layer_parameters.h
##
##  \brief Parameters for serial link layers
##
## * \brief Parameters for the IEC 60870-5 link layer

type
  LinkLayerParameters* = ptr sLinkLayerParameters
  sLinkLayerParameters* {.bycopy.} = object
    addressLength*: cint       ## * Length of link layer address (1 or 2 byte)
    timeoutForAck*: cint       ## * timeout for link layer ACK in ms
    timeoutRepeat*: cint       ## * timeout for repeated message transmission when no ACK received in ms
    useSingleCharACK*: bool    ## * use single char ACK for ACK (FC=0) or RESP_NO_USER_DATA (FC=9)

