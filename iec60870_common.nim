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

## *
##  \file iec60870_common.h
##  \brief Common definitions for IEC 60870-5-101/104
##  These types are used by CS101/CS104 master and slaves
##
## *
##  @addtogroup COMMON Common API functions
##
##  @{
##
import
  iec60870_types

const
  IEC_60870_5_104_DEFAULT_PORT* = 2404
  IEC_60870_5_104_DEFAULT_TLS_PORT* = 19998
  LIB60870_VERSION_MAJOR* = 2
  LIB60870_VERSION_MINOR* = 1
  LIB60870_VERSION_PATCH* = 0

## *
##  \brief lib60870 version information
##

type
  Lib60870VersionInfo*{.bycopy.} = object
    major*: cint
    minor*: cint
    patch*: cint


## *
##  \brief link layer mode for serial link layers
##

type
  IEC60870_LinkLayerMode*{.size: sizeof(cint).} = enum
    IEC60870_LINK_LAYER_BALANCED = 0, IEC60870_LINK_LAYER_UNBALANCED = 1


## * \brief State of the link layer

type ## * The link layer is idle, there is no communication
  LinkLayerState*{.size: sizeof(cint).} = enum
    LL_STATE_IDLE,  ## * An error has occurred at the link layer, the link may not be usable
    LL_STATE_ERROR,  ## * The link layer is busy and therefore no usable
    LL_STATE_BUSY,  ## * The link is available for user data transmission and reception
    LL_STATE_AVAILABLE


## *
##  \brief Callback handler for link layer state changes
##
##  \param parameter user provided parameter that is passed to the handler
##  \param address slave address used by the link layer state machine (only relevant for unbalanced master)
##  \param newState the new link layer state
##

type
  IEC60870_LinkLayerStateChangedHandler * = proc (parameter: pointer;
      address: cint;newState: LinkLayerState) {.cdecl.}

## *
##  \brief Callback handler for sent and received messages
##
##  This callback handler provides access to the raw message buffer of received or sent
##  messages. It can be used for debugging purposes. Usually it is not used nor required
##  for applications.
##
##  \param parameter user provided parameter
##  \param msg the message buffer
##  \param msgSize size of the message
##  \param sent indicates if the message was sent or received
##

type
  IEC60870_RawMessageHandler* = proc (parameter: pointer; msg: ptr array[256, byte];
                                   msgSize: cint; sent: bool) {.cdecl.}

## *
##  \brief Parameters for the CS101/CS104 application layer
##
type
  CS101_AppLayerParameters* = ptr sCS101_AppLayerParameters
  sCS101_AppLayerParameters*{.bycopy.} = object
    sizeOfTypeId*: cint ##  size of the type id (default = 1 - don't change)
    sizeOfVSQ*: cint         ##  don't change
    sizeOfCOT*: cint ##  size of COT (1/2 - default = 2 -> COT includes OA)
    originatorAddress*: cint ##  originator address (OA) to use (0-255)
    sizeOfCA*: cint ##  size of common address (CA) of ASDU (1/2 - default = 2)
    sizeOfIOA*: cint ##  size of information object address (IOA) (1/2/3 - default = 3)
    maxSizeOfASDU*: cint ##  maximum size of the ASDU that is generated - the maximum maximum value is 249 for IEC 104 and 254 for IEC 101


## *
##  \brief Application Service Data Unit (ASDU) for the CS101/CS104 application layer
##

type
  CS101_ASDU* = ptr sCS101_ASDU
  sCS101_ASDU*{.bycopy.} = object
    parameters*: CS101_AppLayerParameters
    asdu*: ptr uint8_t
    asduHeaderLength*: cint
    payload*: ptr uint8_t
    payloadSize*: cint

  CS101_StaticASDU* = ptr sCS101_StaticASDU
  sCS101_StaticASDU*{.bycopy.} = object
    parameters*: CS101_AppLayerParameters
    asdu*: ptr uint8_t
    asduHeaderLength*: cint
    payload*: ptr uint8_t
    payloadSize*: cint
    encodedData*: array[256, uint8_t]

  CP16Time2a* = ptr sCP16Time2a
  sCP16Time2a*{.bycopy.} = object
    encodedValue*: array[2, uint8_t]

  CP24Time2a* = ptr sCP24Time2a
  sCP24Time2a*{.bycopy.} = object
    encodedValue*: array[3, uint8_t]

## *
##  \brief 4 byte binary time
##

type
  CP32Time2a* = ptr sCP32Time2a
  sCP32Time2a*{.bycopy.} = object
    encodedValue*: array[4, uint8_t]

## *
##  \brief 7 byte binary time
##

type
  CP56Time2a* = ptr sCP56Time2a
  sCP56Time2a*{.bycopy.} = object
    encodedValue*: array[7, uint8_t]


## *
##  \brief Base type for counter readings
##

type
  BinaryCounterReading* = ptr sBinaryCounterReading
  sBinaryCounterReading*{.bycopy.} = object
    encodedValue*: array[5, uint8_t]

## *
##  \brief Parameters for CS104 connections - APCI (application protocol control information)
##

type
  CS104_APCIParameters* = ptr sCS104_APCIParameters
  sCS104_APCIParameters*{.bycopy.} = object
    k*: cint
    w*: cint
    t0*: cint
    t1*: cint
    t2*: cint
    t3*: cint

include "cs101_information_objects.nim"

type
  CS101_CauseOfTransmission*{.size: sizeof(cint).} = enum
    CS101_COT_PERIODIC = 1, CS101_COT_BACKGROUND_SCAN = 2,CS101_COT_SPONTANEOUS = 3,
    CS101_COT_INITIALIZED = 4, CS101_COT_REQUEST = 5, CS101_COT_ACTIVATION = 6,
    CS101_COT_ACTIVATION_CON = 7, CS101_COT_DEACTIVATION = 8,
    CS101_COT_DEACTIVATION_CON = 9, CS101_COT_ACTIVATION_TERMINATION = 10,
    CS101_COT_RETURN_INFO_REMOTE = 11, CS101_COT_RETURN_INFO_LOCAL = 12,
    CS101_COT_FILE_TRANSFER = 13, CS101_COT_AUTHENTICATION = 14,
    CS101_COT_MAINTENANCE_OF_AUTH_SESSION_KEY = 15, 
    CS101_COT_MAINTENANCE_OF_USER_ROLE_AND_UPDATE_KEY = 16,
    CS101_COT_INTERROGATED_BY_STATION = 20, CS101_COT_INTERROGATED_BY_GROUP_1 = 21,
    CS101_COT_INTERROGATED_BY_GROUP_2 = 22, CS101_COT_INTERROGATED_BY_GROUP_3 = 23,
    CS101_COT_INTERROGATED_BY_GROUP_4 = 24, CS101_COT_INTERROGATED_BY_GROUP_5 = 25,
    CS101_COT_INTERROGATED_BY_GROUP_6 = 26, CS101_COT_INTERROGATED_BY_GROUP_7 = 27,
    CS101_COT_INTERROGATED_BY_GROUP_8 = 28, CS101_COT_INTERROGATED_BY_GROUP_9 = 29,
    CS101_COT_INTERROGATED_BY_GROUP_10 = 30, CS101_COT_INTERROGATED_BY_GROUP_11 = 31,
    CS101_COT_INTERROGATED_BY_GROUP_12 = 32, CS101_COT_INTERROGATED_BY_GROUP_13 = 33,
    CS101_COT_INTERROGATED_BY_GROUP_14 = 34, CS101_COT_INTERROGATED_BY_GROUP_15 = 35,
    CS101_COT_INTERROGATED_BY_GROUP_16 = 36, CS101_COT_REQUESTED_BY_GENERAL_COUNTER = 37,
    CS101_COT_REQUESTED_BY_GROUP_1_COUNTER = 38, 
    CS101_COT_REQUESTED_BY_GROUP_2_COUNTER = 39,
    CS101_COT_REQUESTED_BY_GROUP_3_COUNTER = 40,
    CS101_COT_REQUESTED_BY_GROUP_4_COUNTER = 41, 
    CS101_COT_UNKNOWN_TYPE_ID = 44, CS101_COT_UNKNOWN_COT = 45,
    CS101_COT_UNKNOWN_CA = 46, CS101_COT_UNKNOWN_IOA = 47


proc CS101_CauseOfTransmission_toString*(self: CS101_CauseOfTransmission): cstring {.
    importc: "CS101_CauseOfTransmission_toString", cdecl.}
proc Lib60870_enableDebugOutput*(value: bool) {.
    importc: "Lib60870_enableDebugOutput", cdecl.}
proc Lib60870_getLibraryVersionInfo*(): Lib60870VersionInfo {.
    importc: "Lib60870_getLibraryVersionInfo", cdecl.}

## *
##  \brief Check if the test flag of the ASDU is set
##
proc CS101_ASDU_isTest*(self: CS101_ASDU): bool {.importc: "CS101_ASDU_isTest",
     cdecl.}

## *
##  \brief Set the test flag of the ASDU
##
proc CS101_ASDU_setTest*(self: CS101_ASDU; value: bool) {.
    importc: "CS101_ASDU_setTest", cdecl.}
## *
##  \brief Check if the negative flag of the ASDU is set
##

proc CS101_ASDU_isNegative*(self: CS101_ASDU): bool {.
    importc: "CS101_ASDU_isNegative", cdecl.}
## *
##  \brief Set the negative flag of the ASDU
##

proc CS101_ASDU_setNegative*(self: CS101_ASDU; value: bool) {.
    importc: "CS101_ASDU_setNegative", cdecl.}
## *
##  \brief get the OA (originator address) of the ASDU.
##

proc CS101_ASDU_getOA*(self: CS101_ASDU): cint {.importc: "CS101_ASDU_getOA",
     cdecl.}
## *
##  \brief Get the cause of transmission (COT) of the ASDU
##

proc CS101_ASDU_getCOT*(self: CS101_ASDU): CS101_CauseOfTransmission {.
    importc: "CS101_ASDU_getCOT", cdecl.}
## *
##  \brief Set the cause of transmission (COT) of the ASDU
##

proc CS101_ASDU_setCOT*(self: CS101_ASDU; value: CS101_CauseOfTransmission) {.
    importc: "CS101_ASDU_setCOT", cdecl.}
## *
##  \brief Get the common address (CA) of the ASDU
##

proc CS101_ASDU_getCA*(self: CS101_ASDU): cint {.importc: "CS101_ASDU_getCA",
     cdecl.}
## *
##  \brief Set the common address (CA) of the ASDU
##
##  \param ca the ca in unstructured form
##

proc CS101_ASDU_setCA*(self: CS101_ASDU; ca: cint) {.importc: "CS101_ASDU_setCA",
     cdecl.}
## *
##  \brief Get the type ID of the ASDU
##

proc CS101_ASDU_getTypeID*(self: CS101_ASDU): IEC60870_5_TypeID {.
    importc: "CS101_ASDU_getTypeID", cdecl.}
## *
##  \brief Check if the ASDU contains a sequence of consecutive information objects
##
##  NOTE: in a sequence of consecutive information objects only the first information object address
##  is encoded. The following information objects ahve consecutive information object addresses.
##

proc CS101_ASDU_isSequence*(self: CS101_ASDU): bool {.
    importc: "CS101_ASDU_isSequence", cdecl.}
## *
##  \brief Get the number of information objects (elements) in the ASDU
##

proc CS101_ASDU_getNumberOfElements*(self: CS101_ASDU): cint {.
    importc: "CS101_ASDU_getNumberOfElements", cdecl.}
## *
##  \brief Get the information object with the given index
##
##  \param index the index of the information object (starting with 0)
##
##  \return the information object, or NULL if there is no information object with the given index
##

proc CS101_ASDU_getElement*(self: CS101_ASDU; index: cint): InformationObject {.
    importc: "CS101_ASDU_getElement", cdecl.}
## *
##  \brief Get the information object with the given index and store it in the provided information object instance
##
##  \param io if not NULL use the provided information object instance to store the information, has to be of correct type.
##  \param index the index of the information object (starting with 0)
##
##  \return the information object, or NULL if there is no information object with the given index
##

proc CS101_ASDU_getElementEx*(self: CS101_ASDU; io: InformationObject;
    index: cint): InformationObject {.
    importc: "CS101_ASDU_getElementEx", cdecl.}

## *
##  \brief Create a new ASDU. The type ID will be derived from the first InformationObject that will be added
##
##  \param parameters the application layer parameters used to encode the ASDU
##  \param isSequence if the information objects will be encoded as a compact sequence of information objects with subsequent IOA values
##  \param cot cause of transmission (COT)
##  \param oa originator address (OA) to be used
##  \param ca the common address (CA) of the ASDU
##  \param isTest if the test flag will be set or not
##  \param isNegative if the negative falg will be set or not
##
##  \return the new CS101_ASDU instance
##
proc CS101_ASDU_create*(parameters: CS101_AppLayerParameters; isSequence: bool;
                       cot: CS101_CauseOfTransmission; oa: cint; ca: cint;
                       isTest: bool; isNegative: bool): CS101_ASDU {.
    importc: "CS101_ASDU_create", cdecl.}

## *
##  \brief Create a new ASDU and store it in the provided static ASDU structure.
##
##  NOTE: The type ID will be derived from the first InformationObject that will be added.
##
##  \param self pointer to the statically allocated data structure
##  \param parameters the application layer parameters used to encode the ASDU
##  \param isSequence if the information objects will be encoded as a compact sequence of information objects with subsequent IOA values
##  \param cot cause of transmission (COT)
##  \param oa originator address (OA) to be used
##  \param ca the common address (CA) of the ASDU
##  \param isTest if the test flag will be set or not
##  \param isNegative if the negative falg will be set or not
##
##  \return the new CS101_ASDU instance
##

proc CS101_ASDU_initializeStatic*(self: CS101_StaticASDU;
                                 parameters: CS101_AppLayerParameters;
                                 isSequence: bool;
                                     cot: CS101_CauseOfTransmission;
                                 oa: cint; ca: cint; isTest: bool;
                                     isNegative: bool): CS101_ASDU {.
    importc: "CS101_ASDU_initializeStatic", cdecl.}
## *
##  \brief Destroy the ASDU object (release all resources)
##

proc CS101_ASDU_destroy*(self: CS101_ASDU) {.importc: "CS101_ASDU_destroy",
     cdecl.}
## *
##  \brief add an information object to the ASDU
##
##  \param self ASDU object instance
##  \param io information object to be added
##
##  \return true when added, false when there not enough space left in the ASDU or IO cannot be added to the sequence because of wrong IOA.
##

proc CS101_ASDU_addInformationObject*(self: CS101_ASDU;
    io: InformationObject): bool {.importc: "CS101_ASDU_addInformationObject", cdecl.}
## *
##  \brief remove all information elements from the ASDU object
##
##  \param self ASDU object instance
##

proc CS101_ASDU_removeAllElements*(self: CS101_ASDU) {.
    importc: "CS101_ASDU_removeAllElements", cdecl.}
## *
##  \brief Get the elapsed time in ms
##

proc CP16Time2a_getEplapsedTimeInMs*(self: CP16Time2a): cint {.
    importc: "CP16Time2a_getEplapsedTimeInMs", cdecl.}
## *
##  \brief set the elapsed time in ms
##

proc CP16Time2a_setEplapsedTimeInMs*(self: CP16Time2a; value: cint) {.
    importc: "CP16Time2a_setEplapsedTimeInMs", cdecl.}
## *
##  \brief Get the millisecond part of the time value
##

proc CP24Time2a_getMillisecond*(self: CP24Time2a): cint {.
    importc: "CP24Time2a_getMillisecond", cdecl.}
## *
##  \brief Set the millisecond part of the time value
##

proc CP24Time2a_setMillisecond*(self: CP24Time2a; value: cint) {.
    importc: "CP24Time2a_setMillisecond", cdecl.}
## *
##  \brief Get the second part of the time value
##

proc CP24Time2a_getSecond*(self: CP24Time2a): cint {.
    importc: "CP24Time2a_getSecond", cdecl.}
## *
##  \brief Set the second part of the time value
##

proc CP24Time2a_setSecond*(self: CP24Time2a; value: cint) {.
    importc: "CP24Time2a_setSecond", cdecl.}
## *
##  \brief Get the minute part of the time value
##

proc CP24Time2a_getMinute*(self: CP24Time2a): cint {.
    importc: "CP24Time2a_getMinute", cdecl.}
## *
##  \brief Set the minute part of the time value
##

proc CP24Time2a_setMinute*(self: CP24Time2a; value: cint) {.
    importc: "CP24Time2a_setMinute", cdecl.}
## *
##  \brief Check if the invalid flag of the time value is set
##

proc CP24Time2a_isInvalid*(self: CP24Time2a): bool {.
    importc: "CP24Time2a_isInvalid", cdecl.}
## *
##  \brief Set the invalid flag of the time value
##

proc CP24Time2a_setInvalid*(self: CP24Time2a; value: bool) {.
    importc: "CP24Time2a_setInvalid", cdecl.}
## *
##  \brief Check if the substituted flag of the time value is set
##

proc CP24Time2a_isSubstituted*(self: CP24Time2a): bool {.
    importc: "CP24Time2a_isSubstituted", cdecl.}
## *
##  \brief Set the substituted flag of the time value
##

proc CP24Time2a_setSubstituted*(self: CP24Time2a; value: bool) {.
    importc: "CP24Time2a_setSubstituted", cdecl.}
## *
##  \brief Create a 7 byte time from a UTC ms timestamp
##

proc CP56Time2a_createFromMsTimestamp*(self: CP56Time2a;
    timestamp: uint64_t): CP56Time2a {.
    importc: "CP56Time2a_createFromMsTimestamp"cdecl.} #,
proc CP32Time2a_create*(self: CP32Time2a): CP32Time2a {.
    importc: "CP32Time2a_create", cdecl.}
proc CP32Time2a_setFromMsTimestamp*(self: CP32Time2a; timestamp: uint64_t) {.
    importc: "CP32Time2a_setFromMsTimestamp", cdecl.}
proc CP32Time2a_getMillisecond*(self: CP32Time2a): cint {.
    importc: "CP32Time2a_getMillisecond", cdecl.}
proc CP32Time2a_setMillisecond*(self: CP32Time2a; value: cint) {.
    importc: "CP32Time2a_setMillisecond", cdecl.}
proc CP32Time2a_getSecond*(self: CP32Time2a): cint {.
    importc: "CP32Time2a_getSecond", cdecl.}
proc CP32Time2a_setSecond*(self: CP32Time2a; value: cint) {.
    importc: "CP32Time2a_setSecond", cdecl.}
proc CP32Time2a_getMinute*(self: CP32Time2a): cint {.
    importc: "CP32Time2a_getMinute", cdecl.}
proc CP32Time2a_setMinute*(self: CP32Time2a; value: cint) {.
    importc: "CP32Time2a_setMinute", cdecl.}
proc CP32Time2a_isInvalid*(self: CP32Time2a): bool {.
    importc: "CP32Time2a_isInvalid", cdecl.}
proc CP32Time2a_setInvalid*(self: CP32Time2a; value: bool) {.
    importc: "CP32Time2a_setInvalid", cdecl.}
proc CP32Time2a_isSubstituted*(self: CP32Time2a): bool {.
    importc: "CP32Time2a_isSubstituted", cdecl.}
proc CP32Time2a_setSubstituted*(self: CP32Time2a; value: bool) {.
    importc: "CP32Time2a_setSubstituted", cdecl.}
proc CP32Time2a_getHour*(self: CP32Time2a): cint {.importc: "CP32Time2a_getHour",
     cdecl.}
proc CP32Time2a_setHour*(self: CP32Time2a; value: cint) {.
    importc: "CP32Time2a_setHour", cdecl.}
proc CP32Time2a_isSummerTime*(self: CP32Time2a): bool {.
    importc: "CP32Time2a_isSummerTime", cdecl.}
proc CP32Time2a_setSummerTime*(self: CP32Time2a; value: bool) {.
    importc: "CP32Time2a_setSummerTime", cdecl.}
## *
##  \brief Set the time value of a 7 byte time from a UTC ms timestamp
##

proc CP56Time2a_setFromMsTimestamp*(self: CP56Time2a; timestamp: uint64_t) {.
    importc: "CP56Time2a_setFromMsTimestamp", cdecl.}
## *
##  \brief Convert a 7 byte time to a ms timestamp
##

proc CP56Time2a_toMsTimestamp*(self: CP56Time2a): uint64_t {.
    importc: "CP56Time2a_toMsTimestamp", cdecl.}
## *
##  \brief Get the ms part of a time value
##

proc CP56Time2a_getMillisecond*(self: CP56Time2a): cint {.
    importc: "CP56Time2a_getMillisecond", cdecl.}
## *
##  \brief Set the ms part of a time value
##

proc CP56Time2a_setMillisecond*(self: CP56Time2a; value: cint) {.
    importc: "CP56Time2a_setMillisecond", cdecl.}
proc CP56Time2a_getSecond*(self: CP56Time2a): cint {.
    importc: "CP56Time2a_getSecond", cdecl.}
proc CP56Time2a_setSecond*(self: CP56Time2a; value: cint) {.
    importc: "CP56Time2a_setSecond", cdecl.}
proc CP56Time2a_getMinute*(self: CP56Time2a): cint {.
    importc: "CP56Time2a_getMinute", cdecl.}
proc CP56Time2a_setMinute*(self: CP56Time2a; value: cint) {.
    importc: "CP56Time2a_setMinute", cdecl.}
proc CP56Time2a_getHour*(self: CP56Time2a): cint {.importc: "CP56Time2a_getHour",
     cdecl.}
proc CP56Time2a_setHour*(self: CP56Time2a; value: cint) {.
    importc: "CP56Time2a_setHour", cdecl.}
proc CP56Time2a_getDayOfWeek*(self: CP56Time2a): cint {.
    importc: "CP56Time2a_getDayOfWeek", cdecl.}
proc CP56Time2a_setDayOfWeek*(self: CP56Time2a; value: cint) {.
    importc: "CP56Time2a_setDayOfWeek", cdecl.}
proc CP56Time2a_getDayOfMonth*(self: CP56Time2a): cint {.
    importc: "CP56Time2a_getDayOfMonth", cdecl.}
proc CP56Time2a_setDayOfMonth*(self: CP56Time2a; value: cint) {.
    importc: "CP56Time2a_setDayOfMonth", cdecl.}
## *
##  \brief Get the month field of the time
##
##  \return value the month (1..12)
##

proc CP56Time2a_getMonth*(self: CP56Time2a): cint {.importc: "CP56Time2a_getMonth",
     cdecl.}
## *
##  \brief Set the month field of the time
##
##  \param value the month (1..12)
##

proc CP56Time2a_setMonth*(self: CP56Time2a; value: cint) {.
    importc: "CP56Time2a_setMonth", cdecl.}
## *
##  \brief Get the year (range 0..99)
##
##  \param value the year (0.99)
##

proc CP56Time2a_getYear*(self: CP56Time2a): cint {.importc: "CP56Time2a_getYear",
     cdecl.}
## *
##  \brief Set the year
##
##  \param value the year
##

proc CP56Time2a_setYear*(self: CP56Time2a; value: cint) {.
    importc: "CP56Time2a_setYear", cdecl.}
proc CP56Time2a_isSummerTime*(self: CP56Time2a): bool {.
    importc: "CP56Time2a_isSummerTime", cdecl.}
proc CP56Time2a_setSummerTime*(self: CP56Time2a; value: bool) {.
    importc: "CP56Time2a_setSummerTime", cdecl.}
proc CP56Time2a_isInvalid*(self: CP56Time2a): bool {.
    importc: "CP56Time2a_isInvalid", cdecl.}
proc CP56Time2a_setInvalid*(self: CP56Time2a; value: bool) {.
    importc: "CP56Time2a_setInvalid", cdecl.}
proc CP56Time2a_isSubstituted*(self: CP56Time2a): bool {.
    importc: "CP56Time2a_isSubstituted", cdecl.}
proc CP56Time2a_setSubstituted*(self: CP56Time2a; value: bool) {.
    importc: "CP56Time2a_setSubstituted", cdecl.}
proc BinaryCounterReading_create*(self: BinaryCounterReading; value: int32_t;
                                 seqNumber: cint; hasCarry: bool;
                                     isAdjusted: bool;
                                 isInvalid: bool): BinaryCounterReading {.
    importc: "BinaryCounterReading_create", cdecl.}
proc BinaryCounterReading_destroy*(self: BinaryCounterReading) {.
    importc: "BinaryCounterReading_destroy", cdecl.}
proc BinaryCounterReading_getValue*(self: BinaryCounterReading): int32_t {.
    importc: "BinaryCounterReading_getValue", cdecl.}
proc BinaryCounterReading_setValue*(self: BinaryCounterReading;
    value: int32_t) {.importc: "BinaryCounterReading_setValue", cdecl.}
proc BinaryCounterReading_getSequenceNumber*(self: BinaryCounterReading): cint {.
    importc: "BinaryCounterReading_getSequenceNumber", cdecl.}
proc BinaryCounterReading_hasCarry*(self: BinaryCounterReading): bool {.
    importc: "BinaryCounterReading_hasCarry", cdecl.}
proc BinaryCounterReading_isAdjusted*(self: BinaryCounterReading): bool {.
    importc: "BinaryCounterReading_isAdjusted", cdecl.}
proc BinaryCounterReading_isInvalid*(self: BinaryCounterReading): bool {.
    importc: "BinaryCounterReading_isInvalid", cdecl.}
proc BinaryCounterReading_setSequenceNumber*(self: BinaryCounterReading;
    value: cint) {.importc: "BinaryCounterReading_setSequenceNumber", cdecl.}
proc BinaryCounterReading_setCarry*(self: BinaryCounterReading; value: bool) {.
    importc: "BinaryCounterReading_setCarry", cdecl.}
proc BinaryCounterReading_setAdjusted*(self: BinaryCounterReading;
    value: bool) {.importc: "BinaryCounterReading_setAdjusted", cdecl.}
proc BinaryCounterReading_setInvalid*(self: BinaryCounterReading;
    value: bool) {.importc: "BinaryCounterReading_setInvalid", cdecl.}
## *
##  @}
##
include "frame_cpp.nim"

proc Frame_destroy*(self: Frame) {.importc: "Frame_destroy", cdecl.}
proc Frame_resetFrame*(self: Frame) {.importc: "Frame_resetFrame", cdecl.}
proc Frame_setNextByte*(self: Frame; byte: uint8_t) {.importc: "Frame_setNextByte",
     cdecl.}
proc Frame_appendBytes*(self: Frame; bytes: ptr uint8_t; numberOfBytes: cint) {.
    importc: "Frame_appendBytes", cdecl.}
proc Frame_getMsgSize*(self: Frame): cint {.importc: "Frame_getMsgSize", cdecl.}
proc Frame_getBuffer*(self: Frame): ptr uint8_t {.importc: "Frame_getBuffer",
     cdecl.}
proc Frame_getSpaceLeft*(self: Frame): cint {.importc: "Frame_getSpaceLeft",
     cdecl.}
