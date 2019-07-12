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
  frame_cpp#, iec60870_common #, apl_types_internal, cs101_information_objects,
#  information_objects_internal, lib_memory, frame, platform_endian



type
  EncodeFunction* = proc (self: InformationObject; frame: Frame;
                       parameters: CS101_AppLayerParameters; isSequence: bool): bool
  DestroyFunction* = proc (self: InformationObject)
  
  InformationObjectVFT* = ptr sInformationObjectVFT
  sInformationObjectVFT* {.bycopy.} = object
    encode*: EncodeFunction
    destroy*: DestroyFunction  
    ## const char* (*toString)(InformationObject self);

  InformationObject* = ptr sInformationObject
  sInformationObject* {.bycopy.} = object
    objectAddress*: cint
    `type`*: TypeID
    virtualFunctionTable*: InformationObjectVFT
  
