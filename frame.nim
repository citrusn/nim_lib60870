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
  iec60870_types

type  
  FrameVFT* = ptr sFrameVFT
  
  sFrameVFT* {.bycopy.} = object
    destroy*: proc (self: Frame)
    resetFrame*: proc (self: Frame)
    setNextByte*: proc (self: Frame; byte: uint8_t)
    appendBytes*: proc (self: Frame; bytes: ptr uint8_t; numberOfBytes: cint)
    getMsgSize*: proc (self: Frame): cint
    getBuffer*: proc (self: Frame): ptr uint8_t
    getSpaceLeft*: proc (self: Frame): cint
  
  Frame* = ptr sFrame

  sFrame* {.bycopy.} = object
    virtualFunctionTable*: FrameVFT 

  
