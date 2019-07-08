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

## *
##  \file cs101_information_objects.h
##  \brief Functions for CS101/CS104 information objects
##  These are the implementation of the different data types and message types
##
## *
##  @defgroup COMMON Common API functions
##
##  @{
##
## *
##  \brief Message type IDs
##

import 
    iec60870_types

type
  IEC60870_5_TypeID* {.size: sizeof(cint).} = enum
    M_SP_NA_1 = 1,   M_SP_TA_1 = 2,   M_DP_NA_1 = 3,   M_DP_TA_1 = 4,   M_ST_NA_1 = 5, M_ST_TA_1 = 6,
    M_BO_NA_1 = 7,   M_BO_TA_1 = 8,   M_ME_NA_1 = 9,   M_ME_TA_1 = 10,  M_ME_NB_1 = 11,
    M_ME_TB_1 = 12,  M_ME_NC_1 = 13,  M_ME_TC_1 = 14,  M_IT_NA_1 = 15,  M_IT_TA_1 = 16,
    M_EP_TA_1 = 17,  M_EP_TB_1 = 18,  M_EP_TC_1 = 19,  M_PS_NA_1 = 20,  M_ME_ND_1 = 21,
    M_SP_TB_1 = 30,  M_DP_TB_1 = 31,  M_ST_TB_1 = 32,  M_BO_TB_1 = 33,  M_ME_TD_1 = 34,
    M_ME_TE_1 = 35,  M_ME_TF_1 = 36,  M_IT_TB_1 = 37,  M_EP_TD_1 = 38,  M_EP_TE_1 = 39,
    M_EP_TF_1 = 40,  C_SC_NA_1 = 45,  C_DC_NA_1 = 46,  C_RC_NA_1 = 47,  C_SE_NA_1 = 48,
    C_SE_NB_1 = 49,  C_SE_NC_1 = 50,  C_BO_NA_1 = 51,  C_SC_TA_1 = 58,  C_DC_TA_1 = 59,
    C_RC_TA_1 = 60,  C_SE_TA_1 = 61,  C_SE_TB_1 = 62,  C_SE_TC_1 = 63,  C_BO_TA_1 = 64,
    M_EI_NA_1 = 70,  C_IC_NA_1 = 100, C_CI_NA_1 = 101, C_RD_NA_1 = 102, C_CS_NA_1 = 103,
    C_TS_NA_1 = 104, C_RP_NA_1 = 105, C_CD_NA_1 = 106, C_TS_TA_1 = 107, P_ME_NA_1 = 110,
    P_ME_NB_1 = 111, P_ME_NC_1 = 112, P_AC_NA_1 = 113, F_FR_NA_1 = 120, F_SR_NA_1 = 121,
    F_SC_NA_1 = 122, F_LS_NA_1 = 123, F_AF_NA_1 = 124, F_SG_NA_1 = 125, F_DR_TA_1 = 126,
    F_SC_NB_1 = 127
  TypeID* = IEC60870_5_TypeID


proc TypeID_toString*(self: TypeID): cstring {.importc: "TypeID_toString",
     cdecl, cdecl .}


## *
##  \brief QDP - Quality descriptor for events of protection equipment according to IEC 60870-5-101:2003 7.2.6.4
##




#type
#  QualityDescriptor* = uint8_t  
#type
#  QualityDescriptorP* = uint8_t

type
    QualityDescriptor* = QualityDescriptorP
    QualityDescriptorP* {.size: sizeof(uint8_t).} = enum
        IEC60870_QUALITY_GOOD = 0
        IEC60870_QUALITY_OVERFLOW = 1
        IEC60870_QUALITY_RESERVED = 4
        IEC60870_QUALITY_ELAPSED_TIME_INVALID = 8
        IEC60870_QUALITY_BLOCKED = 0x10
        IEC60870_QUALITY_SUBSTITUTED = 0x20
        IEC60870_QUALITY_NON_TOPICAL = 0x40
        IEC60870_QUALITY_INVALID = 0x80

## *
##  \brief SPE - Start events of protection equipment according to IEC 60870-5-101:2003 7.2.6.11
##

type
  StartEvent* {.size: sizeof(uint8_t).} = enum
    IEC60870_START_EVENT_NONE = 0
    IEC60870_START_EVENT_GS = 0x00000001
    IEC60870_START_EVENT_SL1 = 0x00000002
    IEC60870_START_EVENT_SL2 = 0x00000004
    IEC60870_START_EVENT_SL3 = 0x00000008
    IEC60870_START_EVENT_SIE = 0x00000010
    IEC60870_START_EVENT_SRD = 0x00000020
    IEC60870_START_EVENT_RES1 = 0x00000040
    IEC60870_START_EVENT_RES2 = 0x00000080

## *
##  \brief Output circuit information (OCI) of protection equipment according to IEC 60870-5-101:2003 7.2.6.12
##

type
  OutputCircuitInfo* {.size: sizeof(uint8_t).} = enum
    IEC60870_OUTPUT_CI_GC = 0x00000001
    IEC60870_OUTPUT_CI_CL1 = 0x00000002
    IEC60870_OUTPUT_CI_CL2 = 0x00000004
    IEC60870_OUTPUT_CI_CL3 = 0x00000008

## *
##   \brief Qualifier of parameter of measured values (QPM) according to IEC 60870-5-101:2003 7.2.6.24
##
##   Possible values:
##   0 = not used
##   1 = threshold value
##   2 = smoothing factor (filter time constant)
##   3 = low limit for transmission of measured values
##   4 = high limit for transmission of measured values
##   5..31 = reserved for standard definitions of CS101 (compatible range)
##   32..63 = reserved for special use (private range)
##

type
  QualifierOfParameterMV* {.size: sizeof(uint8_t).} = enum
    IEC60870_QPM_NOT_USED = 0
    IEC60870_QPM_THRESHOLD_VALUE = 1
    IEC60870_QPM_SMOOTHING_FACTOR = 2
    IEC60870_QPM_LOW_LIMIT_FOR_TRANSMISSION = 3
    IEC60870_QPM_HIGH_LIMIT_FOR_TRANSMISSION = 4

## *
##  \brief Cause of Initialization (COI) according to IEC 60870-5-101:2003 7.2.6.21
##

type
  CauseOfInitialization* {.size: sizeof(uint8_t).} = enum
    IEC60870_COI_LOCAL_SWITCH_ON = 0
    IEC60870_COI_LOCAL_MANUAL_RESET = 1
    IEC60870_COI_REMOTE_RESET = 2

## *
##  \brief Qualifier Of Command (QOC) according to IEC 60870-5-101:2003 7.2.6.26
##

type
  QualifierOfCommand* {.size: sizeof(uint8_t).} = enum
    IEC60870_QOC_NO_ADDITIONAL_DEFINITION = 0
    IEC60870_QOC_SHORT_PULSE_DURATION = 1
    IEC60870_QOC_LONG_PULSE_DURATION = 2
    IEC60870_QOC_PERSISTANT_OUTPUT = 3

## *
##  \brief Select And Call Qualifier (SCQ) according to IEC 60870-5-101:2003 7.2.6.30
##

type
  SelectAndCallQualifier* {.size: sizeof(uint8_t).} = enum
    IEC60870_SCQ_DEFAULT = 0
    IEC60870_SCQ_SELECT_FILE = 1
    IEC60870_SCQ_REQUEST_FILE = 2
    IEC60870_SCQ_DEACTIVATE_FILE = 3
    IEC60870_SCQ_DELETE_FILE = 4
    IEC60870_SCQ_SELECT_SECTION = 5
    IEC60870_SCQ_REQUEST_SECTION = 6
    IEC60870_SCQ_DEACTIVATE_SECTION = 7

## *
##  \brief Qualifier of interrogation (QUI) according to IEC 60870-5-101:2003 7.2.6.22
##

type
  QualifierOfInterrogation* {.size: sizeof(uint8_t).} = enum
    IEC60870_QOI_STATION = 20
    IEC60870_QOI_GROUP_1 = 21
    IEC60870_QOI_GROUP_2 = 22
    IEC60870_QOI_GROUP_3 = 23
    IEC60870_QOI_GROUP_4 = 24
    IEC60870_QOI_GROUP_5 = 25
    IEC60870_QOI_GROUP_6 = 26
    IEC60870_QOI_GROUP_7 = 27
    IEC60870_QOI_GROUP_8 = 28
    IEC60870_QOI_GROUP_9 = 29
    IEC60870_QOI_GROUP_10 = 30
    IEC60870_QOI_GROUP_11 = 31
    IEC60870_QOI_GROUP_12 = 32
    IEC60870_QOI_GROUP_13 = 33
    IEC60870_QOI_GROUP_14 = 34
    IEC60870_QOI_GROUP_15 = 35
    IEC60870_QOI_GROUP_16 = 36

## *
##  \brief QCC (Qualifier of counter interrogation command) according to IEC 60870-5-101:2003 7.2.6.23
##
##  The QCC is composed by the RQT(request) and the FRZ(Freeze) part
##
##  QCC = RQT + FRZ
##
##  E.g.
##
##  to read the the values from counter group one use:
##
##    QCC = IEC60870_QCC_RQT_GROUP_1 + IEC60870_QCC_FRZ_READ
##
##  to reset all counters use:
##
##    QCC = IEC60870_QCC_RQT_GENERAL + IEC60870_QCC_FRZ_COUNTER_RESET
##
##

type
  QualifierOfCIC* {.size: sizeof(uint8_t).} = enum
    IEC60870_QCC_RQT_GROUP_1 = 1
    IEC60870_QCC_RQT_GROUP_2 = 2
    IEC60870_QCC_RQT_GROUP_3 = 3
    IEC60870_QCC_RQT_GROUP_4 = 4
    IEC60870_QCC_RQT_GENERAL = 5

const
    IEC60870_QCC_FRZ_READ* = 0x00
    IEC60870_QCC_FRZ_FREEZE_WITHOUT_RESET* = 0x40
    IEC60870_QCC_FRZ_FREEZE_WITH_RESET* = 0x80
    IEC60870_QCC_FRZ_COUNTER_RESET* = true #todo?

## *
##  \brief QRP (Qualifier of reset process command) according to IEC 60870-5-101:2003 7.2.6.27
##

type
  QualifierOfRPC* {.size: sizeof(cint).} = enum
    IEC60870_QRP_NOT_USED = 0
    IEC60870_QRP_GENERAL_RESET = 1
    IEC60870_QRP_RESET_PENDING_INFO_WITH_TIME_TAG = 2

## *
##  \brief Qualifier of parameter activation (QPA) according to IEC 60870-5-101:2003 7.2.6.25
##

type
  QualifierOfParameterActivation* {.size: sizeof(cint).} = enum
    IEC60870_QPA_NOT_USED = 0
    IEC60870_QPA_DE_ACT_PREV_LOADED_PARAMETER = 1
    IEC60870_QPA_DE_ACT_OBJECT_PARAMETER = 2
    IEC60870_QPA_DE_ACT_OBJECT_TRANSMISSION = 4

type
  SetpointCommandQualifier* = uint8_t

  DoublePointValue* {.size: sizeof(cint).} = enum
    IEC60870_DOUBLE_POINT_INTERMEDIATE = 0, IEC60870_DOUBLE_POINT_OFF = 1,
    IEC60870_DOUBLE_POINT_ON = 2, IEC60870_DOUBLE_POINT_INDETERMINATE = 3

  EventState* {.size: sizeof(cint).} = enum
    IEC60870_EVENTSTATE_INDETERMINATE_0 = 0, IEC60870_EVENTSTATE_OFF = 1,
    IEC60870_EVENTSTATE_ON = 2, IEC60870_EVENTSTATE_INDETERMINATE_3 = 3


## *
##  \brief Regulating step command state (RCS) according to IEC 60870-5-101:2003 7.2.6.17
##

type
  StepCommandValue* {.size: sizeof(cint).} = enum
    IEC60870_STEP_INVALID_0 = 0,
    IEC60870_STEP_LOWER = 1, 
    IEC60870_STEP_HIGHER = 2,
    IEC60870_STEP_INVALID_3 = 3
  
  tSingleEvent* = uint8_t
  SingleEvent* = ptr tSingleEvent


proc SingleEvent_setEventState*(self: SingleEvent; eventState: EventState) {.
    importc: "SingleEvent_setEventState",  cdecl.}
proc SingleEvent_getEventState*(self: SingleEvent): EventState {.
    importc: "SingleEvent_getEventState",  cdecl.}
proc SingleEvent_setQDP*(self: SingleEvent; qdp: QualityDescriptorP) {.
    importc: "SingleEvent_setQDP",  cdecl.}
proc SingleEvent_getQDP*(self: SingleEvent): QualityDescriptorP {.
    importc: "SingleEvent_getQDP",  cdecl.}
type
  tStatusAndStatusChangeDetection* = sStatusAndStatusChangeDetection
  StatusAndStatusChangeDetection* = ptr tStatusAndStatusChangeDetection
  sStatusAndStatusChangeDetection* {.bycopy.} = object
    encodedValue*: array[4, uint8_t]


proc StatusAndStatusChangeDetection_getSTn*(self: StatusAndStatusChangeDetection): uint16_t {.
    importc: "StatusAndStatusChangeDetection_getSTn",  cdecl.}
proc StatusAndStatusChangeDetection_getCDn*(self: StatusAndStatusChangeDetection): uint16_t {.
    importc: "StatusAndStatusChangeDetection_getCDn",  cdecl.}
proc StatusAndStatusChangeDetection_setSTn*(self: StatusAndStatusChangeDetection;
    value: uint16_t) {.importc: "StatusAndStatusChangeDetection_setSTn",
                      cdecl.}
proc StatusAndStatusChangeDetection_getST*(self: StatusAndStatusChangeDetection;
    index: cint): bool {.importc: "StatusAndStatusChangeDetection_getST",
                       cdecl.}
proc StatusAndStatusChangeDetection_getCD*(self: StatusAndStatusChangeDetection;
    index: cint): bool {.importc: "StatusAndStatusChangeDetection_getCD",
                       cdecl.}
## ***********************************************
##  InformationObject
## **********************************************

include "cs101_information_objects_cpp.nim"

## *
##  \brief return the size in memory of a generic InformationObject instance
##
##  This function can be used to determine the required memory for malloc
##

proc InformationObject_getMaxSizeInMemory*(): cint {.
    importc: "InformationObject_getMaxSizeInMemory",  cdecl.}
proc InformationObject_getObjectAddress*(self: InformationObject): cint {.
    importc: "InformationObject_getObjectAddress",  cdecl.}
proc InformationObject_getType*(self: InformationObject): TypeID {.
    importc: "InformationObject_getType",  cdecl.}
## *
##  \brief Destroy object - free all related resources
##
##  This is a virtual function that calls the destructor from the implementation class
##
##  \self the InformationObject instance
##

proc InformationObject_destroy*(self: InformationObject) {.
    importc: "InformationObject_destroy", cdecl.}
## ***********************************************
##  SinglePointInformation (:InformationObject)
## **********************************************

include "information_objects_internal.nim"

type
  SinglePointInformation* = ptr sSinglePointInformation

proc SinglePointInformation_create*(self: SinglePointInformation; ioa: cint;
                                   value: bool; quality: QualityDescriptor): SinglePointInformation {.
    importc: "SinglePointInformation_create",  cdecl.}
proc SinglePointInformation_getValue*(self: SinglePointInformation): bool {.
    importc: "SinglePointInformation_getValue",  cdecl.}
proc SinglePointInformation_getQuality*(self: SinglePointInformation): QualityDescriptor {.
    importc: "SinglePointInformation_getQuality",  cdecl.}
proc SinglePointInformation_destroy*(self: SinglePointInformation) {.
    importc: "SinglePointInformation_destroy",  cdecl.}
## *******************************************************
##   SinglePointWithCP24Time2a (:SinglePointInformation)
## ******************************************************

type
  SinglePointWithCP24Time2a* = ptr sSinglePointWithCP24Time2a

proc SinglePointWithCP24Time2a_create*(self: SinglePointWithCP24Time2a; ioa: cint;
                                      value: bool; quality: QualityDescriptor;
                                      timestamp: CP24Time2a): SinglePointWithCP24Time2a {.
    importc: "SinglePointWithCP24Time2a_create",  cdecl.}
proc SinglePointWithCP24Time2a_destroy*(self: SinglePointWithCP24Time2a) {.
    importc: "SinglePointWithCP24Time2a_destroy",  cdecl.}
proc SinglePointWithCP24Time2a_getTimestamp*(self: SinglePointWithCP24Time2a): CP24Time2a {.
    importc: "SinglePointWithCP24Time2a_getTimestamp",  cdecl.}
## *******************************************************
##   SinglePointWithCP56Time2a (:SinglePointInformation)
## ******************************************************

type
  SinglePointWithCP56Time2a* = ptr sSinglePointWithCP56Time2a

proc SinglePointWithCP56Time2a_create*(self: SinglePointWithCP56Time2a; ioa: cint;
                                      value: bool; quality: QualityDescriptor;
                                      timestamp: CP56Time2a): SinglePointWithCP56Time2a {.
    importc: "SinglePointWithCP56Time2a_create",  cdecl.}
proc SinglePointWithCP56Time2a_destroy*(self: SinglePointWithCP56Time2a) {.
    importc: "SinglePointWithCP56Time2a_destroy",  cdecl.}
proc SinglePointWithCP56Time2a_getTimestamp*(self: SinglePointWithCP56Time2a): CP56Time2a {.
    importc: "SinglePointWithCP56Time2a_getTimestamp",  cdecl.}
## ***********************************************
##  DoublePointInformation (:InformationObject)
## **********************************************

type
  DoublePointInformation* = ptr sDoublePointInformation

proc DoublePointInformation_destroy*(self: DoublePointInformation) {.
    importc: "DoublePointInformation_destroy",  cdecl.}
proc DoublePointInformation_create*(self: DoublePointInformation; ioa: cint;
                                   value: DoublePointValue;
                                   quality: QualityDescriptor): DoublePointInformation {.
    importc: "DoublePointInformation_create",  cdecl.}
proc DoublePointInformation_getValue*(self: DoublePointInformation): DoublePointValue {.
    importc: "DoublePointInformation_getValue",  cdecl.}
proc DoublePointInformation_getQuality*(self: DoublePointInformation): QualityDescriptor {.
    importc: "DoublePointInformation_getQuality",  cdecl.}
## *******************************************************
##   DoublePointWithCP24Time2a (:DoublePointInformation)
## ******************************************************

type
  DoublePointWithCP24Time2a* = ptr sDoublePointWithCP24Time2a

proc DoublePointWithCP24Time2a_destroy*(self: DoublePointWithCP24Time2a) {.
    importc: "DoublePointWithCP24Time2a_destroy",  cdecl.}
proc DoublePointWithCP24Time2a_create*(self: DoublePointWithCP24Time2a; ioa: cint;
                                      value: DoublePointValue;
                                      quality: QualityDescriptor;
                                      timestamp: CP24Time2a): DoublePointWithCP24Time2a {.
    importc: "DoublePointWithCP24Time2a_create",  cdecl.}
proc DoublePointWithCP24Time2a_getTimestamp*(self: DoublePointWithCP24Time2a): CP24Time2a {.
    importc: "DoublePointWithCP24Time2a_getTimestamp",  cdecl.}
## *******************************************************
##   DoublePointWithCP56Time2a (:DoublePointInformation)
## ******************************************************

type
  DoublePointWithCP56Time2a* = ptr sDoublePointWithCP56Time2a

proc DoublePointWithCP56Time2a_create*(self: DoublePointWithCP56Time2a; ioa: cint;
                                      value: DoublePointValue;
                                      quality: QualityDescriptor;
                                      timestamp: CP56Time2a): DoublePointWithCP56Time2a {.
    importc: "DoublePointWithCP56Time2a_create",  cdecl.}
proc DoublePointWithCP56Time2a_destroy*(self: DoublePointWithCP56Time2a) {.
    importc: "DoublePointWithCP56Time2a_destroy",  cdecl.}
proc DoublePointWithCP56Time2a_getTimestamp*(self: DoublePointWithCP56Time2a): CP56Time2a {.
    importc: "DoublePointWithCP56Time2a_getTimestamp",  cdecl.}
## ***********************************************
##  StepPositionInformation (:InformationObject)
## **********************************************

type
  StepPositionInformation* = ptr sStepPositionInformation

## *
##  \brief Create a new instance of StepPositionInformation information object
##
##  \param self Reference to an existing instance to reuse, if NULL a new instance will we dynamically allocated
##  \param ioa Information object address
##  \param value Step position (range -64 ... +63)
##  \param isTransient true if position is transient, false otherwise
##  \param quality quality descriptor (according to IEC 60870-5-101:2003 7.2.6.3)
##
##  \return Reference to the new instance
##

proc StepPositionInformation_create*(self: StepPositionInformation; ioa: cint;
                                    value: cint; isTransient: bool;
                                    quality: QualityDescriptor): StepPositionInformation {.
    importc: "StepPositionInformation_create",  cdecl.}
proc StepPositionInformation_destroy*(self: StepPositionInformation) {.
    importc: "StepPositionInformation_destroy",  cdecl.}
proc StepPositionInformation_getObjectAddress*(self: StepPositionInformation): cint {.
    importc: "StepPositionInformation_getObjectAddress",  cdecl.}
## *
##  \brief Step position (range -64 ... +63)
##

proc StepPositionInformation_getValue*(self: StepPositionInformation): cint {.
    importc: "StepPositionInformation_getValue",  cdecl.}
proc StepPositionInformation_isTransient*(self: StepPositionInformation): bool {.
    importc: "StepPositionInformation_isTransient",  cdecl.}
proc StepPositionInformation_getQuality*(self: StepPositionInformation): QualityDescriptor {.
    importc: "StepPositionInformation_getQuality",  cdecl.}
## ********************************************************
##  StepPositionWithCP24Time2a (:StepPositionInformation)
## *******************************************************

type
  StepPositionWithCP24Time2a* = ptr sStepPositionWithCP24Time2a

proc StepPositionWithCP24Time2a_destroy*(self: StepPositionWithCP24Time2a) {.
    importc: "StepPositionWithCP24Time2a_destroy",  cdecl.}
proc StepPositionWithCP24Time2a_create*(self: StepPositionWithCP24Time2a;
                                       ioa: cint; value: cint; isTransient: bool;
                                       quality: QualityDescriptor;
                                       timestamp: CP24Time2a): StepPositionWithCP24Time2a {.
    importc: "StepPositionWithCP24Time2a_create",  cdecl.}
proc StepPositionWithCP24Time2a_getTimestamp*(self: StepPositionWithCP24Time2a): CP24Time2a {.
    importc: "StepPositionWithCP24Time2a_getTimestamp",  cdecl.}
## ********************************************************
##  StepPositionWithCP56Time2a (:StepPositionInformation)
## *******************************************************

type
  StepPositionWithCP56Time2a* = ptr sStepPositionWithCP56Time2a

proc StepPositionWithCP56Time2a_destroy*(self: StepPositionWithCP56Time2a) {.
    importc: "StepPositionWithCP56Time2a_destroy",  cdecl.}
proc StepPositionWithCP56Time2a_create*(self: StepPositionWithCP56Time2a;
                                       ioa: cint; value: cint; isTransient: bool;
                                       quality: QualityDescriptor;
                                       timestamp: CP56Time2a): StepPositionWithCP56Time2a {.
    importc: "StepPositionWithCP56Time2a_create",  cdecl.}
proc StepPositionWithCP56Time2a_getTimestamp*(self: StepPositionWithCP56Time2a): CP56Time2a {.
    importc: "StepPositionWithCP56Time2a_getTimestamp",  cdecl.}
## *********************************************
##  BitString32 (:InformationObject)
## ********************************************

type
  BitString32* = ptr sBitString32

proc BitString32_destroy*(self: BitString32) {.importc: "BitString32_destroy",
     cdecl.}
proc BitString32_create*(self: BitString32; ioa: cint; value: uint32_t): BitString32 {.
    importc: "BitString32_create",  cdecl.}
proc BitString32_getValue*(self: BitString32): uint32_t {.
    importc: "BitString32_getValue",  cdecl.}
proc BitString32_getQuality*(self: BitString32): QualityDescriptor {.
    importc: "BitString32_getQuality",  cdecl.}
## *********************************************
##  Bitstring32WithCP24Time2a (:BitString32)
## ********************************************

type
  Bitstring32WithCP24Time2a* = ptr sBitstring32WithCP24Time2a

proc Bitstring32WithCP24Time2a_destroy*(self: Bitstring32WithCP24Time2a) {.
    importc: "Bitstring32WithCP24Time2a_destroy",  cdecl.}
proc Bitstring32WithCP24Time2a_create*(self: Bitstring32WithCP24Time2a; ioa: cint;
                                      value: uint32_t; timestamp: CP24Time2a): Bitstring32WithCP24Time2a {.
    importc: "Bitstring32WithCP24Time2a_create",  cdecl.}
proc Bitstring32WithCP24Time2a_getTimestamp*(self: Bitstring32WithCP24Time2a): CP24Time2a {.
    importc: "Bitstring32WithCP24Time2a_getTimestamp",  cdecl.}
## *********************************************
##  Bitstring32WithCP56Time2a (:BitString32)
## ********************************************

type
  Bitstring32WithCP56Time2a* = ptr sBitstring32WithCP56Time2a

proc Bitstring32WithCP56Time2a_destroy*(self: Bitstring32WithCP56Time2a) {.
    importc: "Bitstring32WithCP56Time2a_destroy",  cdecl.}
proc Bitstring32WithCP56Time2a_create*(self: Bitstring32WithCP56Time2a; ioa: cint;
                                      value: uint32_t; timestamp: CP56Time2a): Bitstring32WithCP56Time2a {.
    importc: "Bitstring32WithCP56Time2a_create",  cdecl.}
proc Bitstring32WithCP56Time2a_getTimestamp*(self: Bitstring32WithCP56Time2a): CP56Time2a {.
    importc: "Bitstring32WithCP56Time2a_getTimestamp",  cdecl.}
## ************************************************************
##  MeasuredValueNormalizedWithoutQuality : InformationObject
## ***********************************************************

type
  MeasuredValueNormalizedWithoutQuality* = ptr sMeasuredValueNormalizedWithoutQuality

proc MeasuredValueNormalizedWithoutQuality_destroy*(
    self: MeasuredValueNormalizedWithoutQuality) {.
    importc: "MeasuredValueNormalizedWithoutQuality_destroy",  cdecl.}
proc MeasuredValueNormalizedWithoutQuality_create*(
    self: MeasuredValueNormalizedWithoutQuality; ioa: cint; value: cfloat): MeasuredValueNormalizedWithoutQuality {.
    importc: "MeasuredValueNormalizedWithoutQuality_create",  cdecl.}
proc MeasuredValueNormalizedWithoutQuality_getValue*(
    self: MeasuredValueNormalizedWithoutQuality): cfloat {.
    importc: "MeasuredValueNormalizedWithoutQuality_getValue",  cdecl.}
proc MeasuredValueNormalizedWithoutQuality_setValue*(
    self: MeasuredValueNormalizedWithoutQuality; value: cfloat) {.
    importc: "MeasuredValueNormalizedWithoutQuality_setValue",  cdecl.}
## *********************************************
##  MeasuredValueNormalized
## ********************************************

type
  MeasuredValueNormalized* = ptr sMeasuredValueNormalized

proc MeasuredValueNormalized_destroy*(self: MeasuredValueNormalized) {.
    importc: "MeasuredValueNormalized_destroy",  cdecl.}
proc MeasuredValueNormalized_create*(self: MeasuredValueNormalized; ioa: cint;
                                    value: cfloat; quality: QualityDescriptor): MeasuredValueNormalized {.
    importc: "MeasuredValueNormalized_create",  cdecl.}
proc MeasuredValueNormalized_getValue*(self: MeasuredValueNormalized): cfloat {.
    importc: "MeasuredValueNormalized_getValue",  cdecl.}
proc MeasuredValueNormalized_setValue*(self: MeasuredValueNormalized; value: cfloat) {.
    importc: "MeasuredValueNormalized_setValue",  cdecl.}
proc MeasuredValueNormalized_getQuality*(self: MeasuredValueNormalized): QualityDescriptor {.
    importc: "MeasuredValueNormalized_getQuality",  cdecl.}
## **********************************************************************
##  MeasuredValueNormalizedWithCP24Time2a : MeasuredValueNormalized
## *********************************************************************

type
  MeasuredValueNormalizedWithCP24Time2a* = ptr sMeasuredValueNormalizedWithCP24Time2a

proc MeasuredValueNormalizedWithCP24Time2a_destroy*(
    self: MeasuredValueNormalizedWithCP24Time2a) {.
    importc: "MeasuredValueNormalizedWithCP24Time2a_destroy",  cdecl.}
proc MeasuredValueNormalizedWithCP24Time2a_create*(
    self: MeasuredValueNormalizedWithCP24Time2a; ioa: cint; value: cfloat;
    quality: QualityDescriptor; timestamp: CP24Time2a): MeasuredValueNormalizedWithCP24Time2a {.
    importc: "MeasuredValueNormalizedWithCP24Time2a_create",  cdecl.}
proc MeasuredValueNormalizedWithCP24Time2a_getTimestamp*(
    self: MeasuredValueNormalizedWithCP24Time2a): CP24Time2a {.
    importc: "MeasuredValueNormalizedWithCP24Time2a_getTimestamp",
     cdecl.}
proc MeasuredValueNormalizedWithCP24Time2a_setTimestamp*(
    self: MeasuredValueNormalizedWithCP24Time2a; value: CP24Time2a) {.
    importc: "MeasuredValueNormalizedWithCP24Time2a_setTimestamp",
     cdecl.}
## **********************************************************************
##  MeasuredValueNormalizedWithCP56Time2a : MeasuredValueNormalized
## *********************************************************************

type
  MeasuredValueNormalizedWithCP56Time2a* = ptr sMeasuredValueNormalizedWithCP56Time2a

proc MeasuredValueNormalizedWithCP56Time2a_destroy*(
    self: MeasuredValueNormalizedWithCP56Time2a) {.
    importc: "MeasuredValueNormalizedWithCP56Time2a_destroy",  cdecl.}
proc MeasuredValueNormalizedWithCP56Time2a_create*(
    self: MeasuredValueNormalizedWithCP56Time2a; ioa: cint; value: cfloat;
    quality: QualityDescriptor; timestamp: CP56Time2a): MeasuredValueNormalizedWithCP56Time2a {.
    importc: "MeasuredValueNormalizedWithCP56Time2a_create",  cdecl.}
proc MeasuredValueNormalizedWithCP56Time2a_getTimestamp*(
    self: MeasuredValueNormalizedWithCP56Time2a): CP56Time2a {.
    importc: "MeasuredValueNormalizedWithCP56Time2a_getTimestamp",
     cdecl.}
proc MeasuredValueNormalizedWithCP56Time2a_setTimestamp*(
    self: MeasuredValueNormalizedWithCP56Time2a; value: CP56Time2a) {.
    importc: "MeasuredValueNormalizedWithCP56Time2a_setTimestamp",
     cdecl.}
## ******************************************
##  MeasuredValueScaled : InformationObject
## *****************************************

type
  MeasuredValueScaled* = ptr sMeasuredValueScaled

## *
##  \brief Create a new instance of MeasuredValueScaled information object
##
##  \param self Reference to an existing instance to reuse, if NULL a new instance will we dynamically allocated
##  \param ioa Information object address
##  \param value scaled value (range -32768 - 32767)
##  \param quality quality descriptor (according to IEC 60870-5-101:2003 7.2.6.3)
##
##  \return Reference to the new instance
##

proc MeasuredValueScaled_create*(self: MeasuredValueScaled; ioa: cint; value: cint;
                                quality: QualityDescriptor): MeasuredValueScaled {.
    importc: "MeasuredValueScaled_create",  cdecl.}
proc MeasuredValueScaled_destroy*(self: MeasuredValueScaled) {.
    importc: "MeasuredValueScaled_destroy",  cdecl.}
proc MeasuredValueScaled_getValue*(self: MeasuredValueScaled): cint {.
    importc: "MeasuredValueScaled_getValue",  cdecl.}
proc MeasuredValueScaled_setValue*(self: MeasuredValueScaled; value: cint) {.
    importc: "MeasuredValueScaled_setValue",  cdecl.}
proc MeasuredValueScaled_getQuality*(self: MeasuredValueScaled): QualityDescriptor {.
    importc: "MeasuredValueScaled_getQuality",  cdecl.}
proc MeasuredValueScaled_setQuality*(self: MeasuredValueScaled;
                                    quality: QualityDescriptor) {.
    importc: "MeasuredValueScaled_setQuality",  cdecl.}
## **********************************************************************
##  MeasuredValueScaledWithCP24Time2a : MeasuredValueScaled
## *********************************************************************

type
  MeasuredValueScaledWithCP24Time2a* = ptr sMeasuredValueScaledWithCP24Time2a

proc MeasuredValueScaledWithCP24Time2a_destroy*(
    self: MeasuredValueScaledWithCP24Time2a) {.
    importc: "MeasuredValueScaledWithCP24Time2a_destroy",  cdecl.}
proc MeasuredValueScaledWithCP24Time2a_create*(
    self: MeasuredValueScaledWithCP24Time2a; ioa: cint; value: cint;
    quality: QualityDescriptor; timestamp: CP24Time2a): MeasuredValueScaledWithCP24Time2a {.
    importc: "MeasuredValueScaledWithCP24Time2a_create",  cdecl.}
proc MeasuredValueScaledWithCP24Time2a_getTimestamp*(
    self: MeasuredValueScaledWithCP24Time2a): CP24Time2a {.
    importc: "MeasuredValueScaledWithCP24Time2a_getTimestamp",  cdecl.}
proc MeasuredValueScaledWithCP24Time2a_setTimestamp*(
    self: MeasuredValueScaledWithCP24Time2a; value: CP24Time2a) {.
    importc: "MeasuredValueScaledWithCP24Time2a_setTimestamp",  cdecl.}
## **********************************************************************
##  MeasuredValueScaledWithCP56Time2a : MeasuredValueScaled
## *********************************************************************

type
  MeasuredValueScaledWithCP56Time2a* = ptr sMeasuredValueScaledWithCP56Time2a

proc MeasuredValueScaledWithCP56Time2a_destroy*(
    self: MeasuredValueScaledWithCP56Time2a) {.
    importc: "MeasuredValueScaledWithCP56Time2a_destroy",  cdecl.}
proc MeasuredValueScaledWithCP56Time2a_create*(
    self: MeasuredValueScaledWithCP56Time2a; ioa: cint; value: cint;
    quality: QualityDescriptor; timestamp: CP56Time2a): MeasuredValueScaledWithCP56Time2a {.
    importc: "MeasuredValueScaledWithCP56Time2a_create",  cdecl.}
proc MeasuredValueScaledWithCP56Time2a_getTimestamp*(
    self: MeasuredValueScaledWithCP56Time2a): CP56Time2a {.
    importc: "MeasuredValueScaledWithCP56Time2a_getTimestamp",  cdecl.}
proc MeasuredValueScaledWithCP56Time2a_setTimestamp*(
    self: MeasuredValueScaledWithCP56Time2a; value: CP56Time2a) {.
    importc: "MeasuredValueScaledWithCP56Time2a_setTimestamp",  cdecl.}
## ******************************************
##  MeasuredValueShort : InformationObject
## *****************************************

type
  MeasuredValueShort* = ptr sMeasuredValueShort

proc MeasuredValueShort_destroy*(self: MeasuredValueShort) {.
    importc: "MeasuredValueShort_destroy",  cdecl.}
proc MeasuredValueShort_create*(self: MeasuredValueShort; ioa: cint; value: cfloat;
                               quality: QualityDescriptor): MeasuredValueShort {.
    importc: "MeasuredValueShort_create",  cdecl.}
proc MeasuredValueShort_getValue*(self: MeasuredValueShort): cfloat {.
    importc: "MeasuredValueShort_getValue",  cdecl.}
proc MeasuredValueShort_setValue*(self: MeasuredValueShort; value: cfloat) {.
    importc: "MeasuredValueShort_setValue",  cdecl.}
proc MeasuredValueShort_getQuality*(self: MeasuredValueShort): QualityDescriptor {.
    importc: "MeasuredValueShort_getQuality",  cdecl.}
## **********************************************************************
##  MeasuredValueShortWithCP24Time2a : MeasuredValueShort
## *********************************************************************

type
  MeasuredValueShortWithCP24Time2a* = ptr sMeasuredValueShortWithCP24Time2a

proc MeasuredValueShortWithCP24Time2a_destroy*(
    self: MeasuredValueShortWithCP24Time2a) {.
    importc: "MeasuredValueShortWithCP24Time2a_destroy",  cdecl.}
proc MeasuredValueShortWithCP24Time2a_create*(
    self: MeasuredValueShortWithCP24Time2a; ioa: cint; value: cfloat;
    quality: QualityDescriptor; timestamp: CP24Time2a): MeasuredValueShortWithCP24Time2a {.
    importc: "MeasuredValueShortWithCP24Time2a_create",  cdecl.}
proc MeasuredValueShortWithCP24Time2a_getTimestamp*(
    self: MeasuredValueShortWithCP24Time2a): CP24Time2a {.
    importc: "MeasuredValueShortWithCP24Time2a_getTimestamp",  cdecl.}
proc MeasuredValueShortWithCP24Time2a_setTimestamp*(
    self: MeasuredValueShortWithCP24Time2a; value: CP24Time2a) {.
    importc: "MeasuredValueShortWithCP24Time2a_setTimestamp",  cdecl.}
## **********************************************************************
##  MeasuredValueShortWithCP56Time2a : MeasuredValueShort
## *********************************************************************

type
  MeasuredValueShortWithCP56Time2a* = ptr sMeasuredValueShortWithCP56Time2a

proc MeasuredValueShortWithCP56Time2a_destroy*(
    self: MeasuredValueShortWithCP56Time2a) {.
    importc: "MeasuredValueShortWithCP56Time2a_destroy",  cdecl.}
proc MeasuredValueShortWithCP56Time2a_create*(
    self: MeasuredValueShortWithCP56Time2a; ioa: cint; value: cfloat;
    quality: QualityDescriptor; timestamp: CP56Time2a): MeasuredValueShortWithCP56Time2a {.
    importc: "MeasuredValueShortWithCP56Time2a_create",  cdecl.}
proc MeasuredValueShortWithCP56Time2a_getTimestamp*(
    self: MeasuredValueShortWithCP56Time2a): CP56Time2a {.
    importc: "MeasuredValueShortWithCP56Time2a_getTimestamp",  cdecl.}
proc MeasuredValueShortWithCP56Time2a_setTimestamp*(
    self: MeasuredValueShortWithCP56Time2a; value: CP56Time2a) {.
    importc: "MeasuredValueShortWithCP56Time2a_setTimestamp",  cdecl.}
## ******************************************
##  IntegratedTotals : InformationObject
## *****************************************

type
  IntegratedTotals* = ptr sIntegratedTotals

proc IntegratedTotals_destroy*(self: IntegratedTotals) {.
    importc: "IntegratedTotals_destroy",  cdecl.}
## *
##  \brief Create a new instance of IntegratedTotals information object
##
##  For message type: M_IT_NA_1 (15)
##
##  \param self Reference to an existing instance to reuse, if NULL a new instance will we dynamically allocated
##  \param ioa Information object address
##  \param value binary counter reading value and state
##
##  \return Reference to the new instance
##

proc IntegratedTotals_create*(self: IntegratedTotals; ioa: cint;
                             value: BinaryCounterReading): IntegratedTotals {.
    importc: "IntegratedTotals_create",  cdecl.}
proc IntegratedTotals_getBCR*(self: IntegratedTotals): BinaryCounterReading {.
    importc: "IntegratedTotals_getBCR",  cdecl.}
proc IntegratedTotals_setBCR*(self: IntegratedTotals; value: BinaryCounterReading) {.
    importc: "IntegratedTotals_setBCR",  cdecl.}
## **********************************************************************
##  IntegratedTotalsWithCP24Time2a : IntegratedTotals
## *********************************************************************

type
  IntegratedTotalsWithCP24Time2a* = ptr sIntegratedTotalsWithCP24Time2a

## *
##  \brief Create a new instance of IntegratedTotalsWithCP24Time2a information object
##
##  For message type: M_IT_TA_1 (16)
##
##  \param self Reference to an existing instance to reuse, if NULL a new instance will we dynamically allocated
##  \param ioa Information object address
##  \param value binary counter reading value and state
##  \param timestamp timestamp of the reading
##
##  \return Reference to the new instance
##

proc IntegratedTotalsWithCP24Time2a_create*(self: IntegratedTotalsWithCP24Time2a;
    ioa: cint; value: BinaryCounterReading; timestamp: CP24Time2a): IntegratedTotalsWithCP24Time2a {.
    importc: "IntegratedTotalsWithCP24Time2a_create",  cdecl.}
proc IntegratedTotalsWithCP24Time2a_destroy*(self: IntegratedTotalsWithCP24Time2a) {.
    importc: "IntegratedTotalsWithCP24Time2a_destroy",  cdecl.}
proc IntegratedTotalsWithCP24Time2a_getTimestamp*(
    self: IntegratedTotalsWithCP24Time2a): CP24Time2a {.
    importc: "IntegratedTotalsWithCP24Time2a_getTimestamp",  cdecl.}
proc IntegratedTotalsWithCP24Time2a_setTimestamp*(
    self: IntegratedTotalsWithCP24Time2a; value: CP24Time2a) {.
    importc: "IntegratedTotalsWithCP24Time2a_setTimestamp",  cdecl.}
## **********************************************************************
##  IntegratedTotalsWithCP56Time2a : IntegratedTotals
## *********************************************************************

type
  IntegratedTotalsWithCP56Time2a* = ptr sIntegratedTotalsWithCP56Time2a

## *
##  \brief Create a new instance of IntegratedTotalsWithCP56Time2a information object
##
##  For message type: M_IT_TB_1 (37)
##
##  \param self Reference to an existing instance to reuse, if NULL a new instance will we dynamically allocated
##  \param ioa Information object address
##  \param value binary counter reading value and state
##  \param timestamp timestamp of the reading
##
##  \return Reference to the new instance
##

proc IntegratedTotalsWithCP56Time2a_create*(self: IntegratedTotalsWithCP56Time2a;
    ioa: cint; value: BinaryCounterReading; timestamp: CP56Time2a): IntegratedTotalsWithCP56Time2a {.
    importc: "IntegratedTotalsWithCP56Time2a_create",  cdecl.}
proc IntegratedTotalsWithCP56Time2a_destroy*(self: IntegratedTotalsWithCP56Time2a) {.
    importc: "IntegratedTotalsWithCP56Time2a_destroy",  cdecl.}
proc IntegratedTotalsWithCP56Time2a_getTimestamp*(
    self: IntegratedTotalsWithCP56Time2a): CP56Time2a {.
    importc: "IntegratedTotalsWithCP56Time2a_getTimestamp",  cdecl.}
proc IntegratedTotalsWithCP56Time2a_setTimestamp*(
    self: IntegratedTotalsWithCP56Time2a; value: CP56Time2a) {.
    importc: "IntegratedTotalsWithCP56Time2a_setTimestamp",  cdecl.}
## **********************************************************************
##  EventOfProtectionEquipment : InformationObject
## *********************************************************************

type
  EventOfProtectionEquipment* = ptr sEventOfProtectionEquipment

proc EventOfProtectionEquipment_destroy*(self: EventOfProtectionEquipment) {.
    importc: "EventOfProtectionEquipment_destroy",  cdecl.}
proc EventOfProtectionEquipment_create*(self: EventOfProtectionEquipment;
                                       ioa: cint; event: SingleEvent;
                                       elapsedTime: CP16Time2a;
                                       timestamp: CP24Time2a): EventOfProtectionEquipment {.
    importc: "EventOfProtectionEquipment_create",  cdecl.}
proc EventOfProtectionEquipment_getEvent*(self: EventOfProtectionEquipment): SingleEvent {.
    importc: "EventOfProtectionEquipment_getEvent",  cdecl.}
proc EventOfProtectionEquipment_getElapsedTime*(self: EventOfProtectionEquipment): CP16Time2a {.
    importc: "EventOfProtectionEquipment_getElapsedTime",  cdecl.}
proc EventOfProtectionEquipment_getTimestamp*(self: EventOfProtectionEquipment): CP24Time2a {.
    importc: "EventOfProtectionEquipment_getTimestamp",  cdecl.}
## **********************************************************************
##  PackedStartEventsOfProtectionEquipment : InformationObject
## *********************************************************************

type
  PackedStartEventsOfProtectionEquipment* = ptr sPackedStartEventsOfProtectionEquipment

proc PackedStartEventsOfProtectionEquipment_create*(
    self: PackedStartEventsOfProtectionEquipment; ioa: cint; event: StartEvent;
    qdp: QualityDescriptorP; elapsedTime: CP16Time2a; timestamp: CP24Time2a): PackedStartEventsOfProtectionEquipment {.
    importc: "PackedStartEventsOfProtectionEquipment_create",  cdecl.}
proc PackedStartEventsOfProtectionEquipment_destroy*(
    self: PackedStartEventsOfProtectionEquipment) {.
    importc: "PackedStartEventsOfProtectionEquipment_destroy",  cdecl.}
proc PackedStartEventsOfProtectionEquipment_getEvent*(
    self: PackedStartEventsOfProtectionEquipment): StartEvent {.
    importc: "PackedStartEventsOfProtectionEquipment_getEvent",  cdecl.}
proc PackedStartEventsOfProtectionEquipment_getQuality*(
    self: PackedStartEventsOfProtectionEquipment): QualityDescriptorP {.
    importc: "PackedStartEventsOfProtectionEquipment_getQuality",
     cdecl.}
proc PackedStartEventsOfProtectionEquipment_getElapsedTime*(
    self: PackedStartEventsOfProtectionEquipment): CP16Time2a {.
    importc: "PackedStartEventsOfProtectionEquipment_getElapsedTime",
     cdecl.}
proc PackedStartEventsOfProtectionEquipment_getTimestamp*(
    self: PackedStartEventsOfProtectionEquipment): CP24Time2a {.
    importc: "PackedStartEventsOfProtectionEquipment_getTimestamp",
     cdecl.}
## **********************************************************************
##  PacketOutputCircuitInfo : InformationObject
## *********************************************************************

type
  PackedOutputCircuitInfo* = ptr sPackedOutputCircuitInfo

proc PackedOutputCircuitInfo_destroy*(self: PackedOutputCircuitInfo) {.
    importc: "PackedOutputCircuitInfo_destroy",  cdecl.}
proc PackedOutputCircuitInfo_create*(self: PackedOutputCircuitInfo; ioa: cint;
                                    oci: OutputCircuitInfo;
                                    qdp: QualityDescriptorP;
                                    operatingTime: CP16Time2a;
                                    timestamp: CP24Time2a): PackedOutputCircuitInfo {.
    importc: "PackedOutputCircuitInfo_create",  cdecl.}
proc PackedOutputCircuitInfo_getOCI*(self: PackedOutputCircuitInfo): OutputCircuitInfo {.
    importc: "PackedOutputCircuitInfo_getOCI",  cdecl.}
proc PackedOutputCircuitInfo_getQuality*(self: PackedOutputCircuitInfo): QualityDescriptorP {.
    importc: "PackedOutputCircuitInfo_getQuality",  cdecl.}
proc PackedOutputCircuitInfo_getOperatingTime*(self: PackedOutputCircuitInfo): CP16Time2a {.
    importc: "PackedOutputCircuitInfo_getOperatingTime",  cdecl.}
proc PackedOutputCircuitInfo_getTimestamp*(self: PackedOutputCircuitInfo): CP24Time2a {.
    importc: "PackedOutputCircuitInfo_getTimestamp",  cdecl.}
## **********************************************************************
##  PackedSinglePointWithSCD : InformationObject
## *********************************************************************

type
  PackedSinglePointWithSCD* = ptr sPackedSinglePointWithSCD

proc PackedSinglePointWithSCD_destroy*(self: PackedSinglePointWithSCD) {.
    importc: "PackedSinglePointWithSCD_destroy",  cdecl.}
proc PackedSinglePointWithSCD_create*(self: PackedSinglePointWithSCD; ioa: cint;
                                     scd: StatusAndStatusChangeDetection;
                                     qds: QualityDescriptor): PackedSinglePointWithSCD {.
    importc: "PackedSinglePointWithSCD_create",  cdecl.}
proc PackedSinglePointWithSCD_getQuality*(self: PackedSinglePointWithSCD): QualityDescriptor {.
    importc: "PackedSinglePointWithSCD_getQuality",  cdecl.}
proc PackedSinglePointWithSCD_getSCD*(self: PackedSinglePointWithSCD): StatusAndStatusChangeDetection {.
    importc: "PackedSinglePointWithSCD_getSCD",  cdecl.}
## ******************************************
##  SingleCommand
## *****************************************

type
  SingleCommand* = ptr sSingleCommand

## *
##  \brief Create a single point command information object
##
##  \param[in] self existing instance to reuse or NULL to create a new instance
##  \param[in] ioa information object address
##  \param[in] command the command value
##  \param[in] selectCommand (S/E bit) if true send "select", otherwise "execute"
##  \param[in] qu qualifier of command QU parameter(0 = no additional definition, 1 = short pulse, 2 = long pulse, 3 = persistent output)
##
##  \return the initialized instance
##

proc SingleCommand_create*(self: SingleCommand; ioa: cint; command: bool;
                          selectCommand: bool; qu: cint): SingleCommand {.
    importc: "SingleCommand_create",  cdecl.}
proc SingleCommand_destroy*(self: SingleCommand) {.
    importc: "SingleCommand_destroy",  cdecl.}
## *
##  \brief Get the qualifier of command QU value
##
##  \return the QU value (0 = no additional definition, 1 = short pulse, 2 = long pulse, 3 = persistent output, > 3 = reserved)
##

proc SingleCommand_getQU*(self: SingleCommand): cint {.
    importc: "SingleCommand_getQU",  cdecl.}
## *
##  \brief Get the state (command) value
##

proc SingleCommand_getState*(self: SingleCommand): bool {.
    importc: "SingleCommand_getState",  cdecl.}
## *
##  \brief Return the value of the S/E bit of the qualifier of command
##
##  \return S/E bit, true = select, false = execute
##

proc SingleCommand_isSelect*(self: SingleCommand): bool {.
    importc: "SingleCommand_isSelect",  cdecl.}
## **********************************************************************
##  SingleCommandWithCP56Time2a : SingleCommand
## *********************************************************************

type
  SingleCommandWithCP56Time2a* = ptr sSingleCommandWithCP56Time2a

proc SingleCommandWithCP56Time2a_destroy*(self: SingleCommandWithCP56Time2a) {.
    importc: "SingleCommandWithCP56Time2a_destroy",  cdecl.}
## *
##  \brief Create a single command with CP56Time2a time stamp information object
##
##  \param[in] self existing instance to reuse or NULL to create a new instance
##  \param[in] ioa information object address
##  \param[in] command the command value
##  \param[in] selectCommand (S/E bit) if true send "select", otherwise "execute"
##  \param[in] qu qualifier of command QU parameter(0 = no additional definition, 1 = short pulse, 2 = long pulse, 3 = persistent output)
##  \param[in] timestamp the time stamp value
##
##  \return the initialized instance
##

proc SingleCommandWithCP56Time2a_create*(self: SingleCommandWithCP56Time2a;
                                        ioa: cint; command: bool;
                                        selectCommand: bool; qu: cint;
                                        timestamp: CP56Time2a): SingleCommandWithCP56Time2a {.
    importc: "SingleCommandWithCP56Time2a_create",  cdecl.}
## *
##  \brief Get the time stamp of the command.
##
##  NOTE: according to the specification the command shall not be accepted when the time stamp differs too much
##  from the time of the receiving system. In this case the command has to be discarded silently.
##
##  \return the time stamp of the command
##

proc SingleCommandWithCP56Time2a_getTimestamp*(self: SingleCommandWithCP56Time2a): CP56Time2a {.
    importc: "SingleCommandWithCP56Time2a_getTimestamp",  cdecl.}
## ******************************************
##  DoubleCommand : InformationObject
## *****************************************

type
  DoubleCommand* = ptr sDoubleCommand

proc DoubleCommand_destroy*(self: DoubleCommand) {.
    importc: "DoubleCommand_destroy",  cdecl.}
## *
##  \brief Create a double command information object
##
##  \param[in] self existing instance to reuse or NULL to create a new instance
##  \param[in] ioa information object address
##  \param[in] command the double command state (0 = not permitted, 1 = off, 2 = on, 3 = not permitted)
##  \param[in] selectCommand (S/E bit) if true send "select", otherwise "execute"
##  \param[in] qu qualifier of command QU parameter(0 = no additional definition, 1 = short pulse, 2 = long pulse, 3 = persistent output)
##
##  \return the initialized instance
##

proc DoubleCommand_create*(self: DoubleCommand; ioa: cint; command: cint;
                          selectCommand: bool; qu: cint): DoubleCommand {.
    importc: "DoubleCommand_create",  cdecl.}
## *
##  \brief Get the qualifier of command QU value
##
##  \return the QU value (0 = no additional definition, 1 = short pulse, 2 = long pulse, 3 = persistent output, > 3 = reserved)
##

proc DoubleCommand_getQU*(self: DoubleCommand): cint {.
    importc: "DoubleCommand_getQU",  cdecl.}
## *
##  \brief Get the state (command) value
##
##  \return 0 = not permitted, 1 = off, 2 = on, 3 = not permitted
##

proc DoubleCommand_getState*(self: DoubleCommand): cint {.
    importc: "DoubleCommand_getState",  cdecl.}
## *
##  \brief Return the value of the S/E bit of the qualifier of command
##
##  \return S/E bit, true = select, false = execute
##

proc DoubleCommand_isSelect*(self: DoubleCommand): bool {.
    importc: "DoubleCommand_isSelect",  cdecl.}
## ******************************************
##  StepCommand : InformationObject
## *****************************************

type
  StepCommand* = ptr sStepCommand

proc StepCommand_destroy*(self: StepCommand) {.importc: "StepCommand_destroy",
     cdecl.}
proc StepCommand_create*(self: StepCommand; ioa: cint; command: StepCommandValue;
                        selectCommand: bool; qu: cint): StepCommand {.
    importc: "StepCommand_create",  cdecl.}
## *
##  \brief Get the qualifier of command QU value
##
##  \return the QU value (0 = no additional definition, 1 = short pulse, 2 = long pulse, 3 = persistent output, > 3 = reserved)
##

proc StepCommand_getQU*(self: StepCommand): cint {.importc: "StepCommand_getQU",
     cdecl.}
proc StepCommand_getState*(self: StepCommand): StepCommandValue {.
    importc: "StepCommand_getState",  cdecl.}
## *
##  \brief Return the value of the S/E bit of the qualifier of command
##
##  \return S/E bit, true = select, false = execute
##

proc StepCommand_isSelect*(self: StepCommand): bool {.
    importc: "StepCommand_isSelect",  cdecl.}
## ************************************************
##  SetpointCommandNormalized : InformationObject
## **********************************************

type
  SetpointCommandNormalized* = ptr sSetpointCommandNormalized

proc SetpointCommandNormalized_destroy*(self: SetpointCommandNormalized) {.
    importc: "SetpointCommandNormalized_destroy",  cdecl.}
## *
##  \brief Create a normalized set point command information object
##
##  \param[in] self existing instance to reuse or NULL to create a new instance
##  \param[in] ioa information object address
##  \param[in] value normalized value between -1 and 1
##  \param[in] selectCommand (S/E bit) if true send "select", otherwise "execute"
##  \param[in] ql qualifier of set point command (0 = standard, 1..127 = reserved)
##
##  \return the initialized instance
##

proc SetpointCommandNormalized_create*(self: SetpointCommandNormalized; ioa: cint;
                                      value: cfloat; selectCommand: bool; ql: cint): SetpointCommandNormalized {.
    importc: "SetpointCommandNormalized_create",  cdecl.}
proc SetpointCommandNormalized_getValue*(self: SetpointCommandNormalized): cfloat {.
    importc: "SetpointCommandNormalized_getValue",  cdecl.}
proc SetpointCommandNormalized_getQL*(self: SetpointCommandNormalized): cint {.
    importc: "SetpointCommandNormalized_getQL",  cdecl.}
## *
##  \brief Return the value of the S/E bit of the qualifier of command
##
##  \return S/E bit, true = select, false = execute
##

proc SetpointCommandNormalized_isSelect*(self: SetpointCommandNormalized): bool {.
    importc: "SetpointCommandNormalized_isSelect",  cdecl.}
## ************************************************
##  SetpointCommandScaled : InformationObject
## **********************************************

type
  SetpointCommandScaled* = ptr sSetpointCommandScaled

proc SetpointCommandScaled_destroy*(self: SetpointCommandScaled) {.
    importc: "SetpointCommandScaled_destroy",  cdecl.}
## *
##  \brief Create a scaled set point command information object
##
##  \param[in] self existing instance to reuse or NULL to create a new instance
##  \param[in] ioa information object address
##  \param[in] value the scaled value (–32.768 .. 32.767)
##  \param[in] selectCommand (S/E bit) if true send "select", otherwise "execute"
##  \param[in] ql qualifier of set point command (0 = standard, 1..127 = reserved)
##
##  \return the initialized instance
##

proc SetpointCommandScaled_create*(self: SetpointCommandScaled; ioa: cint;
                                  value: cint; selectCommand: bool; ql: cint): SetpointCommandScaled {.
    importc: "SetpointCommandScaled_create",  cdecl.}
proc SetpointCommandScaled_getValue*(self: SetpointCommandScaled): cint {.
    importc: "SetpointCommandScaled_getValue",  cdecl.}
proc SetpointCommandScaled_getQL*(self: SetpointCommandScaled): cint {.
    importc: "SetpointCommandScaled_getQL",  cdecl.}
## *
##  \brief Return the value of the S/E bit of the qualifier of command
##
##  \return S/E bit, true = select, false = execute
##

proc SetpointCommandScaled_isSelect*(self: SetpointCommandScaled): bool {.
    importc: "SetpointCommandScaled_isSelect",  cdecl.}
## ************************************************
##  SetpointCommandShort: InformationObject
## **********************************************

type
  SetpointCommandShort* = ptr sSetpointCommandShort

proc SetpointCommandShort_destroy*(self: SetpointCommandShort) {.
    importc: "SetpointCommandShort_destroy",  cdecl.}
## *
##  \brief Create a short floating point set point command information object
##
##  \param[in] self existing instance to reuse or NULL to create a new instance
##  \param[in] ioa information object address
##  \param[in] value short floating point number
##  \param[in] selectCommand (S/E bit) if true send "select", otherwise "execute"
##  \param[in] ql qualifier of set point command (0 = standard, 1..127 = reserved)
##
##  \return the initialized instance
##

proc SetpointCommandShort_create*(self: SetpointCommandShort; ioa: cint;
                                 value: cfloat; selectCommand: bool; ql: cint): SetpointCommandShort {.
    importc: "SetpointCommandShort_create",  cdecl.}
proc SetpointCommandShort_getValue*(self: SetpointCommandShort): cfloat {.
    importc: "SetpointCommandShort_getValue",  cdecl.}
proc SetpointCommandShort_getQL*(self: SetpointCommandShort): cint {.
    importc: "SetpointCommandShort_getQL",  cdecl.}
## *
##  \brief Return the value of the S/E bit of the qualifier of command
##
##  \return S/E bit, true = select, false = execute
##

proc SetpointCommandShort_isSelect*(self: SetpointCommandShort): bool {.
    importc: "SetpointCommandShort_isSelect",  cdecl.}
## ************************************************
##  Bitstring32Command : InformationObject
## **********************************************

type
  Bitstring32Command* = ptr sBitstring32Command

proc Bitstring32Command_create*(self: Bitstring32Command; ioa: cint; value: uint32_t): Bitstring32Command {.
    importc: "Bitstring32Command_create",  cdecl.}
proc Bitstring32Command_destroy*(self: Bitstring32Command) {.
    importc: "Bitstring32Command_destroy",  cdecl.}
proc Bitstring32Command_getValue*(self: Bitstring32Command): uint32_t {.
    importc: "Bitstring32Command_getValue",  cdecl.}
## ************************************************
##  InterrogationCommand : InformationObject
## **********************************************

type
  InterrogationCommand* = ptr sInterrogationCommand

proc InterrogationCommand_create*(self: InterrogationCommand; ioa: cint; qoi: uint8_t): InterrogationCommand {.
    importc: "InterrogationCommand_create",  cdecl.}
proc InterrogationCommand_destroy*(self: InterrogationCommand) {.
    importc: "InterrogationCommand_destroy",  cdecl.}
proc InterrogationCommand_getQOI*(self: InterrogationCommand): uint8_t {.
    importc: "InterrogationCommand_getQOI",  cdecl.}
## ************************************************
##  ReadCommand : InformationObject
## **********************************************

type
  ReadCommand* = ptr sReadCommand

proc ReadCommand_create*(self: ReadCommand; ioa: cint): ReadCommand {.
    importc: "ReadCommand_create",  cdecl.}
proc ReadCommand_destroy*(self: ReadCommand) {.importc: "ReadCommand_destroy",
     cdecl.}
## **************************************************
##  ClockSynchronizationCommand : InformationObject
## ************************************************

type
  ClockSynchronizationCommand* = ptr sClockSynchronizationCommand

proc ClockSynchronizationCommand_create*(self: ClockSynchronizationCommand;
                                        ioa: cint; timestamp: CP56Time2a): ClockSynchronizationCommand {.
    importc: "ClockSynchronizationCommand_create",  cdecl.}
proc ClockSynchronizationCommand_destroy*(self: ClockSynchronizationCommand) {.
    importc: "ClockSynchronizationCommand_destroy",  cdecl.}
proc ClockSynchronizationCommand_getTime*(self: ClockSynchronizationCommand): CP56Time2a {.
    importc: "ClockSynchronizationCommand_getTime",  cdecl.}
## *****************************************************
##  ParameterNormalizedValue : MeasuredValueNormalized
## ***************************************************

type
  ParameterNormalizedValue* = ptr sMeasuredValueNormalized

proc ParameterNormalizedValue_destroy*(self: ParameterNormalizedValue) {.
    importc: "ParameterNormalizedValue_destroy",  cdecl.}
## *
##  \brief Create a parameter measured values, normalized (P_ME_NA_1) information object
##
##  NOTE: Can only be used in control direction (with COT=ACTIVATION) or in monitoring
##  direction as a response of an interrogation request (with COT=INTERROGATED_BY...).
##
##  Possible values of qpm:
##  0 = not used
##  1 = threshold value
##  2 = smoothing factor (filter time constant)
##  3 = low limit for transmission of measured values
##  4 = high limit for transmission of measured values
##  5..31 = reserved for standard definitions of CS101 (compatible range)
##  32..63 = reserved for special use (private range)
##
##  \param[in] self existing instance to reuse or NULL to create a new instance
##  \param[in] ioa information object address
##  \param[in] value the normalized value (-1 .. 1)
##  \param[in] qpm qualifier of measured values (\ref QualifierOfParameterMV)
##
##  \return the initialized instance
##

proc ParameterNormalizedValue_create*(self: ParameterNormalizedValue; ioa: cint;
                                     value: cfloat; qpm: QualifierOfParameterMV): ParameterNormalizedValue {.
    importc: "ParameterNormalizedValue_create",  cdecl.}
proc ParameterNormalizedValue_getValue*(self: ParameterNormalizedValue): cfloat {.
    importc: "ParameterNormalizedValue_getValue",  cdecl.}
proc ParameterNormalizedValue_setValue*(self: ParameterNormalizedValue;
                                       value: cfloat) {.
    importc: "ParameterNormalizedValue_setValue",  cdecl.}
## *
##  \brief Returns the qualifier of measured values (QPM)
##
##  \return the QPM value (\ref QualifierOfParameterMV)
##

proc ParameterNormalizedValue_getQPM*(self: ParameterNormalizedValue): QualifierOfParameterMV {.
    importc: "ParameterNormalizedValue_getQPM",  cdecl.}
## *****************************************************
##  ParameterScaledValue : MeasuredValueScaled
## ***************************************************

type
  ParameterScaledValue* = ptr sMeasuredValueScaled

proc ParameterScaledValue_destroy*(self: ParameterScaledValue) {.
    importc: "ParameterScaledValue_destroy",  cdecl.}
## *
##  \brief Create a parameter measured values, scaled (P_ME_NB_1) information object
##
##  NOTE: Can only be used in control direction (with COT=ACTIVATION) or in monitoring
##  direction as a response of an interrogation request (with COT=INTERROGATED_BY...).
##
##  Possible values of qpm:
##  0 = not used
##  1 = threshold value
##  2 = smoothing factor (filter time constant)
##  3 = low limit for transmission of measured values
##  4 = high limit for transmission of measured values
##  5..31 = reserved for standard definitions of CS101 (compatible range)
##  32..63 = reserved for special use (private range)
##
##  \param[in] self existing instance to reuse or NULL to create a new instance
##  \param[in] ioa information object address
##  \param[in] value the scaled value (–32.768 .. 32.767)
##  \param[in] qpm qualifier of measured values (\ref QualifierOfParameterMV)
##
##  \return the initialized instance
##

proc ParameterScaledValue_create*(self: ParameterScaledValue; ioa: cint; value: cint;
                                 qpm: QualifierOfParameterMV): ParameterScaledValue {.
    importc: "ParameterScaledValue_create",  cdecl.}
proc ParameterScaledValue_getValue*(self: ParameterScaledValue): cint {.
    importc: "ParameterScaledValue_getValue",  cdecl.}
proc ParameterScaledValue_setValue*(self: ParameterScaledValue; value: cint) {.
    importc: "ParameterScaledValue_setValue",  cdecl.}
## *
##  \brief Returns the qualifier of measured values (QPM)
##
##  \return the QPM value (\ref QualifierOfParameterMV)
##

proc ParameterScaledValue_getQPM*(self: ParameterScaledValue): QualifierOfParameterMV {.
    importc: "ParameterScaledValue_getQPM",  cdecl.}
## *****************************************************
##  ParameterFloatValue : MeasuredValueShort
## ***************************************************

type
  ParameterFloatValue* = ptr sMeasuredValueShort

proc ParameterFloatValue_destroy*(self: ParameterFloatValue) {.
    importc: "ParameterFloatValue_destroy",  cdecl.}
## *
##  \brief Create a parameter measured values, short floating point (P_ME_NC_1) information object
##
##  NOTE: Can only be used in control direction (with COT=ACTIVATION) or in monitoring
##  direction as a response of an interrogation request (with COT=INTERROGATED_BY...).
##
##  Possible values of qpm:
##  0 = not used
##  1 = threshold value
##  2 = smoothing factor (filter time constant)
##  3 = low limit for transmission of measured values
##  4 = high limit for transmission of measured values
##  5..31 = reserved for standard definitions of CS101 (compatible range)
##  32..63 = reserved for special use (private range)
##
##  \param[in] self existing instance to reuse or NULL to create a new instance
##  \param[in] ioa information object address
##  \param[in] value short floating point number
##  \param[in] qpm qualifier of measured values (QPM - \ref QualifierOfParameterMV)
##
##  \return the initialized instance
##

proc ParameterFloatValue_create*(self: ParameterFloatValue; ioa: cint; value: cfloat;
                                qpm: QualifierOfParameterMV): ParameterFloatValue {.
    importc: "ParameterFloatValue_create",  cdecl.}
proc ParameterFloatValue_getValue*(self: ParameterFloatValue): cfloat {.
    importc: "ParameterFloatValue_getValue",  cdecl.}
proc ParameterFloatValue_setValue*(self: ParameterFloatValue; value: cfloat) {.
    importc: "ParameterFloatValue_setValue",  cdecl.}
## *
##  \brief Returns the qualifier of measured values (QPM)
##
##  \return the QPM value (\ref QualifierOfParameterMV)
##

proc ParameterFloatValue_getQPM*(self: ParameterFloatValue): QualifierOfParameterMV {.
    importc: "ParameterFloatValue_getQPM",  cdecl.}
## ******************************************
##  ParameterActivation : InformationObject
## *****************************************

type
  ParameterActivation* = ptr sParameterActivation

proc ParameterActivation_destroy*(self: ParameterActivation) {.
    importc: "ParameterActivation_destroy",  cdecl.}
## *
##  \brief Create a parameter activation (P_AC_NA_1) information object
##
##  \param[in] self existing instance to reuse or NULL to create a new instance
##  \param[in] ioa information object address
##  \param[in] qpa qualifier of parameter activation (3 = act/deact of persistent cyclic or periodic transmission)
##
##  \return the initialized instance
##

proc ParameterActivation_create*(self: ParameterActivation; ioa: cint;
                                qpa: QualifierOfParameterActivation): ParameterActivation {.
    importc: "ParameterActivation_create",  cdecl.}
## *
##  \brief Get the qualifier of parameter activation (QPA) value
##
##  \return 3 = act/deact of persistent cyclic or periodic transmission
##

proc ParameterActivation_getQuality*(self: ParameterActivation): QualifierOfParameterActivation {.
    importc: "ParameterActivation_getQuality",  cdecl.}
## **********************************************************************
##  EventOfProtectionEquipmentWithCP56Time2a : InformationObject
## *********************************************************************

type
  EventOfProtectionEquipmentWithCP56Time2a* = ptr sEventOfProtectionEquipmentWithCP56Time2a

proc EventOfProtectionEquipmentWithCP56Time2a_destroy*(
    self: EventOfProtectionEquipmentWithCP56Time2a) {.
    importc: "EventOfProtectionEquipmentWithCP56Time2a_destroy",  cdecl.}
proc EventOfProtectionEquipmentWithCP56Time2a_create*(
    self: EventOfProtectionEquipmentWithCP56Time2a; ioa: cint; event: SingleEvent;
    elapsedTime: CP16Time2a; timestamp: CP56Time2a): EventOfProtectionEquipmentWithCP56Time2a {.
    importc: "EventOfProtectionEquipmentWithCP56Time2a_create",  cdecl.}
proc EventOfProtectionEquipmentWithCP56Time2a_getEvent*(
    self: EventOfProtectionEquipmentWithCP56Time2a): SingleEvent {.
    importc: "EventOfProtectionEquipmentWithCP56Time2a_getEvent",
     cdecl.}
proc EventOfProtectionEquipmentWithCP56Time2a_getElapsedTime*(
    self: EventOfProtectionEquipmentWithCP56Time2a): CP16Time2a {.
    importc: "EventOfProtectionEquipmentWithCP56Time2a_getElapsedTime",
     cdecl.}
proc EventOfProtectionEquipmentWithCP56Time2a_getTimestamp*(
    self: EventOfProtectionEquipmentWithCP56Time2a): CP56Time2a {.
    importc: "EventOfProtectionEquipmentWithCP56Time2a_getTimestamp",
     cdecl.}
## **************************************************************************
##  PackedStartEventsOfProtectionEquipmentWithCP56Time2a : InformationObject
## *************************************************************************

type
  PackedStartEventsOfProtectionEquipmentWithCP56Time2a* = ptr sPackedStartEventsOfProtectionEquipmentWithCP56Time2a

proc PackedStartEventsOfProtectionEquipmentWithCP56Time2a_destroy*(
    self: PackedStartEventsOfProtectionEquipmentWithCP56Time2a) {.
    importc: "PackedStartEventsOfProtectionEquipmentWithCP56Time2a_destroy",
     cdecl.}
proc PackedStartEventsOfProtectionEquipmentWithCP56Time2a_create*(
    self: PackedStartEventsOfProtectionEquipmentWithCP56Time2a; ioa: cint;
    event: StartEvent; qdp: QualityDescriptorP; elapsedTime: CP16Time2a;
    timestamp: CP56Time2a): PackedStartEventsOfProtectionEquipmentWithCP56Time2a {.
    importc: "PackedStartEventsOfProtectionEquipmentWithCP56Time2a_create",
     cdecl.}
proc PackedStartEventsOfProtectionEquipmentWithCP56Time2a_getEvent*(
    self: PackedStartEventsOfProtectionEquipmentWithCP56Time2a): StartEvent {.
    importc: "PackedStartEventsOfProtectionEquipmentWithCP56Time2a_getEvent",
     cdecl.}
proc PackedStartEventsOfProtectionEquipmentWithCP56Time2a_getQuality*(
    self: PackedStartEventsOfProtectionEquipmentWithCP56Time2a): QualityDescriptorP {.
    importc: "PackedStartEventsOfProtectionEquipmentWithCP56Time2a_getQuality",
     cdecl.}
proc PackedStartEventsOfProtectionEquipmentWithCP56Time2a_getElapsedTime*(
    self: PackedStartEventsOfProtectionEquipmentWithCP56Time2a): CP16Time2a {.importc: "PackedStartEventsOfProtectionEquipmentWithCP56Time2a_getElapsedTime",
     cdecl.}
proc PackedStartEventsOfProtectionEquipmentWithCP56Time2a_getTimestamp*(
    self: PackedStartEventsOfProtectionEquipmentWithCP56Time2a): CP56Time2a {.importc: "PackedStartEventsOfProtectionEquipmentWithCP56Time2a_getTimestamp",
     cdecl.}
## **********************************************************************
##  PackedOutputCircuitInfoWithCP56Time2a : InformationObject
## *********************************************************************

type
  PackedOutputCircuitInfoWithCP56Time2a* = ptr sPackedOutputCircuitInfoWithCP56Time2a

proc PackedOutputCircuitInfoWithCP56Time2a_destroy*(
    self: PackedOutputCircuitInfoWithCP56Time2a) {.
    importc: "PackedOutputCircuitInfoWithCP56Time2a_destroy",  cdecl.}
proc PackedOutputCircuitInfoWithCP56Time2a_create*(
    self: PackedOutputCircuitInfoWithCP56Time2a; ioa: cint; oci: OutputCircuitInfo;
    qdp: QualityDescriptorP; operatingTime: CP16Time2a; timestamp: CP56Time2a): PackedOutputCircuitInfoWithCP56Time2a {.
    importc: "PackedOutputCircuitInfoWithCP56Time2a_create",  cdecl.}
proc PackedOutputCircuitInfoWithCP56Time2a_getOCI*(
    self: PackedOutputCircuitInfoWithCP56Time2a): OutputCircuitInfo {.
    importc: "PackedOutputCircuitInfoWithCP56Time2a_getOCI",  cdecl.}
proc PackedOutputCircuitInfoWithCP56Time2a_getQuality*(
    self: PackedOutputCircuitInfoWithCP56Time2a): QualityDescriptorP {.
    importc: "PackedOutputCircuitInfoWithCP56Time2a_getQuality",  cdecl.}
proc PackedOutputCircuitInfoWithCP56Time2a_getOperatingTime*(
    self: PackedOutputCircuitInfoWithCP56Time2a): CP16Time2a {.
    importc: "PackedOutputCircuitInfoWithCP56Time2a_getOperatingTime",
     cdecl.}
proc PackedOutputCircuitInfoWithCP56Time2a_getTimestamp*(
    self: PackedOutputCircuitInfoWithCP56Time2a): CP56Time2a {.
    importc: "PackedOutputCircuitInfoWithCP56Time2a_getTimestamp",
     cdecl.}
## *********************************************
##  DoubleCommandWithCP56Time2a : DoubleCommand
## ********************************************

type
  DoubleCommandWithCP56Time2a* = ptr sDoubleCommandWithCP56Time2a

proc DoubleCommandWithCP56Time2a_destroy*(self: DoubleCommandWithCP56Time2a) {.
    importc: "DoubleCommandWithCP56Time2a_destroy",  cdecl.}
proc DoubleCommandWithCP56Time2a_create*(self: DoubleCommandWithCP56Time2a;
                                        ioa: cint; command: cint;
                                        selectCommand: bool; qu: cint;
                                        timestamp: CP56Time2a): DoubleCommandWithCP56Time2a {.
    importc: "DoubleCommandWithCP56Time2a_create",  cdecl.}
proc DoubleCommandWithCP56Time2a_getQU*(self: DoubleCommandWithCP56Time2a): cint {.
    importc: "DoubleCommandWithCP56Time2a_getQU",  cdecl.}
proc DoubleCommandWithCP56Time2a_getState*(self: DoubleCommandWithCP56Time2a): cint {.
    importc: "DoubleCommandWithCP56Time2a_getState",  cdecl.}
proc DoubleCommandWithCP56Time2a_isSelect*(self: DoubleCommandWithCP56Time2a): bool {.
    importc: "DoubleCommandWithCP56Time2a_isSelect",  cdecl.}
proc DoubleCommandWithCP56Time2a_getTimestamp*(self: DoubleCommandWithCP56Time2a): CP56Time2a {.
    importc: "DoubleCommandWithCP56Time2a_getTimestamp",  cdecl.}
## ************************************************
##  StepCommandWithCP56Time2a : InformationObject
## ***********************************************

type
  StepCommandWithCP56Time2a* = ptr sStepCommandWithCP56Time2a

proc StepCommandWithCP56Time2a_destroy*(self: StepCommand) {.
    importc: "StepCommandWithCP56Time2a_destroy",  cdecl.}
proc StepCommandWithCP56Time2a_create*(self: StepCommandWithCP56Time2a; ioa: cint;
                                      command: StepCommandValue;
                                      selectCommand: bool; qu: cint;
                                      timestamp: CP56Time2a): StepCommandWithCP56Time2a {.
    importc: "StepCommandWithCP56Time2a_create",  cdecl.}
proc StepCommandWithCP56Time2a_getQU*(self: StepCommandWithCP56Time2a): cint {.
    importc: "StepCommandWithCP56Time2a_getQU",  cdecl.}
proc StepCommandWithCP56Time2a_getState*(self: StepCommandWithCP56Time2a): StepCommandValue {.
    importc: "StepCommandWithCP56Time2a_getState",  cdecl.}
proc StepCommandWithCP56Time2a_isSelect*(self: StepCommandWithCP56Time2a): bool {.
    importc: "StepCommandWithCP56Time2a_isSelect",  cdecl.}
proc StepCommandWithCP56Time2a_getTimestamp*(self: StepCommandWithCP56Time2a): CP56Time2a {.
    importc: "StepCommandWithCP56Time2a_getTimestamp",  cdecl.}
## *********************************************************************
##  SetpointCommandNormalizedWithCP56Time2a : SetpointCommandNormalized
## ********************************************************************

type
  SetpointCommandNormalizedWithCP56Time2a* = ptr sSetpointCommandNormalizedWithCP56Time2a

proc SetpointCommandNormalizedWithCP56Time2a_destroy*(
    self: SetpointCommandNormalizedWithCP56Time2a) {.
    importc: "SetpointCommandNormalizedWithCP56Time2a_destroy",  cdecl.}
proc SetpointCommandNormalizedWithCP56Time2a_create*(
    self: SetpointCommandNormalizedWithCP56Time2a; ioa: cint; value: cfloat;
    selectCommand: bool; ql: cint; timestamp: CP56Time2a): SetpointCommandNormalizedWithCP56Time2a {.
    importc: "SetpointCommandNormalizedWithCP56Time2a_create",  cdecl.}
proc SetpointCommandNormalizedWithCP56Time2a_getValue*(
    self: SetpointCommandNormalizedWithCP56Time2a): cfloat {.
    importc: "SetpointCommandNormalizedWithCP56Time2a_getValue",  cdecl.}
proc SetpointCommandNormalizedWithCP56Time2a_getQL*(
    self: SetpointCommandNormalizedWithCP56Time2a): cint {.
    importc: "SetpointCommandNormalizedWithCP56Time2a_getQL",  cdecl.}
proc SetpointCommandNormalizedWithCP56Time2a_isSelect*(
    self: SetpointCommandNormalizedWithCP56Time2a): bool {.
    importc: "SetpointCommandNormalizedWithCP56Time2a_isSelect",  cdecl.}
proc SetpointCommandNormalizedWithCP56Time2a_getTimestamp*(
    self: SetpointCommandNormalizedWithCP56Time2a): CP56Time2a {.
    importc: "SetpointCommandNormalizedWithCP56Time2a_getTimestamp",
     cdecl.}
## *********************************************************************
##  SetpointCommandScaledWithCP56Time2a : SetpointCommandScaled
## ********************************************************************

type
  SetpointCommandScaledWithCP56Time2a* = ptr sSetpointCommandScaledWithCP56Time2a

proc SetpointCommandScaledWithCP56Time2a_destroy*(
    self: SetpointCommandScaledWithCP56Time2a) {.
    importc: "SetpointCommandScaledWithCP56Time2a_destroy",  cdecl.}
proc SetpointCommandScaledWithCP56Time2a_create*(
    self: SetpointCommandScaledWithCP56Time2a; ioa: cint; value: cint;
    selectCommand: bool; ql: cint; timestamp: CP56Time2a): SetpointCommandScaledWithCP56Time2a {.
    importc: "SetpointCommandScaledWithCP56Time2a_create",  cdecl.}
proc SetpointCommandScaledWithCP56Time2a_getValue*(
    self: SetpointCommandScaledWithCP56Time2a): cint {.
    importc: "SetpointCommandScaledWithCP56Time2a_getValue",  cdecl.}
proc SetpointCommandScaledWithCP56Time2a_getQL*(
    self: SetpointCommandScaledWithCP56Time2a): cint {.
    importc: "SetpointCommandScaledWithCP56Time2a_getQL",  cdecl.}
proc SetpointCommandScaledWithCP56Time2a_isSelect*(
    self: SetpointCommandScaledWithCP56Time2a): bool {.
    importc: "SetpointCommandScaledWithCP56Time2a_isSelect",  cdecl.}
proc SetpointCommandScaledWithCP56Time2a_getTimestamp*(
    self: SetpointCommandScaledWithCP56Time2a): CP56Time2a {.
    importc: "SetpointCommandScaledWithCP56Time2a_getTimestamp",  cdecl.}
## *********************************************************************
##  SetpointCommandShortWithCP56Time2a : SetpointCommandShort
## ********************************************************************

type
  SetpointCommandShortWithCP56Time2a* = ptr sSetpointCommandShortWithCP56Time2a

proc SetpointCommandShortWithCP56Time2a_destroy*(
    self: SetpointCommandShortWithCP56Time2a) {.
    importc: "SetpointCommandShortWithCP56Time2a_destroy",  cdecl.}
proc SetpointCommandShortWithCP56Time2a_create*(
    self: SetpointCommandShortWithCP56Time2a; ioa: cint; value: cfloat;
    selectCommand: bool; ql: cint; timestamp: CP56Time2a): SetpointCommandShortWithCP56Time2a {.
    importc: "SetpointCommandShortWithCP56Time2a_create",  cdecl.}
proc SetpointCommandShortWithCP56Time2a_getValue*(
    self: SetpointCommandShortWithCP56Time2a): cfloat {.
    importc: "SetpointCommandShortWithCP56Time2a_getValue",  cdecl.}
proc SetpointCommandShortWithCP56Time2a_getQL*(
    self: SetpointCommandShortWithCP56Time2a): cint {.
    importc: "SetpointCommandShortWithCP56Time2a_getQL",  cdecl.}
proc SetpointCommandShortWithCP56Time2a_isSelect*(
    self: SetpointCommandShortWithCP56Time2a): bool {.
    importc: "SetpointCommandShortWithCP56Time2a_isSelect",  cdecl.}
proc SetpointCommandShortWithCP56Time2a_getTimestamp*(
    self: SetpointCommandShortWithCP56Time2a): CP56Time2a {.
    importc: "SetpointCommandShortWithCP56Time2a_getTimestamp",  cdecl.}
## ******************************************************
##  Bitstring32CommandWithCP56Time2a: Bitstring32Command
## *****************************************************

type
  Bitstring32CommandWithCP56Time2a* = ptr sBitstring32CommandWithCP56Time2a

proc Bitstring32CommandWithCP56Time2a_create*(
    self: Bitstring32CommandWithCP56Time2a; ioa: cint; value: uint32_t;
    timestamp: CP56Time2a): Bitstring32CommandWithCP56Time2a {.
    importc: "Bitstring32CommandWithCP56Time2a_create",  cdecl.}
proc Bitstring32CommandWithCP56Time2a_destroy*(
    self: Bitstring32CommandWithCP56Time2a) {.
    importc: "Bitstring32CommandWithCP56Time2a_destroy",  cdecl.}
proc Bitstring32CommandWithCP56Time2a_getValue*(
    self: Bitstring32CommandWithCP56Time2a): uint32_t {.
    importc: "Bitstring32CommandWithCP56Time2a_getValue",  cdecl.}
proc Bitstring32CommandWithCP56Time2a_getTimestamp*(
    self: Bitstring32CommandWithCP56Time2a): CP56Time2a {.
    importc: "Bitstring32CommandWithCP56Time2a_getTimestamp",  cdecl.}
## *************************************************
##  CounterInterrogationCommand : InformationObject
## ************************************************

type
  CounterInterrogationCommand* = ptr sCounterInterrogationCommand

proc CounterInterrogationCommand_create*(self: CounterInterrogationCommand;
                                        ioa: cint; qcc: QualifierOfCIC): CounterInterrogationCommand {.
    importc: "CounterInterrogationCommand_create",  cdecl.}
proc CounterInterrogationCommand_destroy*(self: CounterInterrogationCommand) {.
    importc: "CounterInterrogationCommand_destroy",  cdecl.}
proc CounterInterrogationCommand_getQCC*(self: CounterInterrogationCommand): QualifierOfCIC {.
    importc: "CounterInterrogationCommand_getQCC",  cdecl.}
## ************************************************
##  TestCommand : InformationObject
## **********************************************

type
  TestCommand* = ptr sTestCommand

proc TestCommand_create*(self: TestCommand): TestCommand {.
    importc: "TestCommand_create",  cdecl.}
proc TestCommand_destroy*(self: TestCommand) {.importc: "TestCommand_destroy",
     cdecl.}
proc TestCommand_isValid*(self: TestCommand): bool {.importc: "TestCommand_isValid",
     cdecl.}
## ************************************************
##  ResetProcessCommand : InformationObject
## **********************************************

type
  ResetProcessCommand* = ptr sResetProcessCommand

proc ResetProcessCommand_create*(self: ResetProcessCommand; ioa: cint;
                                qrp: QualifierOfRPC): ResetProcessCommand {.
    importc: "ResetProcessCommand_create",  cdecl.}
proc ResetProcessCommand_destroy*(self: ResetProcessCommand) {.
    importc: "ResetProcessCommand_destroy",  cdecl.}
proc ResetProcessCommand_getQRP*(self: ResetProcessCommand): QualifierOfRPC {.
    importc: "ResetProcessCommand_getQRP",  cdecl.}
## ************************************************
##  DelayAcquisitionCommand : InformationObject
## **********************************************

type
  DelayAcquisitionCommand* = ptr sDelayAcquisitionCommand

proc DelayAcquisitionCommand_create*(self: DelayAcquisitionCommand; ioa: cint;
                                    delay: CP16Time2a): DelayAcquisitionCommand {.
    importc: "DelayAcquisitionCommand_create",  cdecl.}
proc DelayAcquisitionCommand_destroy*(self: DelayAcquisitionCommand) {.
    importc: "DelayAcquisitionCommand_destroy",  cdecl.}
proc DelayAcquisitionCommand_getDelay*(self: DelayAcquisitionCommand): CP16Time2a {.
    importc: "DelayAcquisitionCommand_getDelay",  cdecl.}
## ******************************************
##  EndOfInitialization : InformationObject
## *****************************************

type
  EndOfInitialization* = ptr sEndOfInitialization

proc EndOfInitialization_create*(self: EndOfInitialization; coi: uint8_t): EndOfInitialization {.
    importc: "EndOfInitialization_create",  cdecl.}
proc EndOfInitialization_destroy*(self: EndOfInitialization) {.
    importc: "EndOfInitialization_destroy",  cdecl.}
proc EndOfInitialization_getCOI*(self: EndOfInitialization): uint8_t {.
    importc: "EndOfInitialization_getCOI",  cdecl.}
## ******************************************
##  FileReady : InformationObject
## *****************************************
## *
##  \name CS101_NOF
##
##  \brief NOF (Name of file) values
##
##  @{
##

const
  CS101_NOF_TRANSPARENT_FILE* = 1
  CS101_NOF_DISTURBANCE_DATA* = 2
  CS101_NOF_SEQUENCES_OF_EVENTS* = 3
  CS101_NOF_SEQUENCES_OF_ANALOGUE_VALUES* = 4

## * @}
## *
##  \name CS101_SCQ
##
##  \brief SCQ (select and call qualifier) values
##
##  @{
##

const
  CS101_SCQ_DEFAULT* = 0
  CS101_SCQ_SELECT_FILE* = 1
  CS101_SCQ_REQUEST_FILE* = 2
  CS101_SCQ_DEACTIVATE_FILE* = 3
  CS101_SCQ_DELETE_FILE* = 4
  CS101_SCQ_SELECT_SECTION* = 5
  CS101_SCQ_REQUEST_SECTION* = 6
  CS101_SCQ_DEACTIVATE_SECTION* = 7

## * @}
## *
##  \name CS101_LSQ
##
##  \brief LSQ (last section or segment qualifier) values
##
##  @{
##

const
  CS101_LSQ_NOT_USED* = 0
  CS101_LSQ_FILE_TRANSFER_WITHOUT_DEACT* = 1
  CS101_LSQ_FILE_TRANSFER_WITH_DEACT* = 2
  CS101_LSQ_SECTION_TRANSFER_WITHOUT_DEACT* = 3
  CS101_LSQ_SECTION_TRANSFER_WITH_DEACT* = 4

## * @}
## *
##  \name CS101_AFQ
##
##  \brief AFQ (Acknowledge file or section qualifier) values
##
##  @{
##
## * \brief AFQ not used

const
  CS101_AFQ_NOT_USED* = 0

## * \brief acknowledge file positively

const
  CS101_AFQ_POS_ACK_FILE* = 1

## * \brief acknowledge file negatively

const
  CS101_AFQ_NEG_ACK_FILE* = 2

## * \brief acknowledge section positively

const
  CS101_AFQ_POS_ACK_SECTION* = 3

## * \brief acknowledge section negatively

const
  CS101_AFQ_NEG_ACK_SECTION* = 4

## * @}
## *
##  \name CS101_FILE_ERROR
##
##  \brief Error code values used by FileACK
##
##  @{
##
## * \brief no error

const
  CS101_FILE_ERROR_DEFAULT* = 0

## * \brief requested memory not available (not enough memory)

const
  CS101_FILE_ERROR_REQ_MEMORY_NOT_AVAILABLE* = 1

## * \brief checksum test failed

const
  CS101_FILE_ERROR_CHECKSUM_FAILED* = 2

## * \brief unexpected communication service

const
  CS101_FILE_ERROR_UNEXPECTED_COMM_SERVICE* = 3

## * \brief unexpected name of file

const
  CS101_FILE_ERROR_UNEXPECTED_NAME_OF_FILE* = 4

## * \brief unexpected name of section

const
  CS101_FILE_ERROR_UNEXPECTED_NAME_OF_SECTION* = 5

## * @}
## *
##  \name CS101_SOF
##
##  \brief Status of file (SOF) definitions - IEC 60870-5-101:2003 7.2.6.38
##
##  @{
##
## * \brief bit mask value for STATUS part of SOF

const
  CS101_SOF_STATUS* = 0x00000000

## * \brief bit mask value for LFD (last file of the directory) flag

const
  CS101_SOF_LFD* = 0x00000000

## * \brief bit mask value for FOR (name defines subdirectory) flag

const
  CS101_SOF_FOR* = 0x00000000

## * \brief bit mask value for FA (file transfer of this file is active) flag

const
  CS101_SOF_FA* = 0x00000000

## * @}

type
  FileReady* = ptr sFileReady

## *
##  \brief Create a new instance of FileReady information object
##
##  For message type: F_FR_NA_1 (120)
##
##  \param self
##  \param ioa
##  \param nof name of file (1 for transparent file)
##  \param lengthOfFile
##  \param positive when true file is ready to transmit
##

proc FileReady_create*(self: FileReady; ioa: cint; nof: uint16_t;
                      lengthOfFile: uint32_t; positive: bool): FileReady {.
    importc: "FileReady_create",  cdecl.}
proc FileReady_destroy*(self: FileReady) {.importc: "FileReady_destroy",
                                         cdecl.}
proc FileReady_getFRQ*(self: FileReady): uint8_t {.importc: "FileReady_getFRQ",
     cdecl.}
proc FileReady_setFRQ*(self: FileReady; frq: uint8_t) {.importc: "FileReady_setFRQ",
     cdecl.}
proc FileReady_isPositive*(self: FileReady): bool {.importc: "FileReady_isPositive",
     cdecl.}
proc FileReady_getNOF*(self: FileReady): uint16_t {.importc: "FileReady_getNOF",
     cdecl.}
proc FileReady_getLengthOfFile*(self: FileReady): uint32_t {.
    importc: "FileReady_getLengthOfFile",  cdecl.}
#proc FileReady_destroy*(self: FileReady) {.importc: "FileReady_destroy",
#                                         cdecl.}
## ******************************************
##  SectionReady : InformationObject
## *****************************************

type
  SectionReady* = ptr sSectionReady

proc SectionReady_create*(self: SectionReady; ioa: cint; nof: uint16_t; nos: uint8_t;
                         lengthOfSection: uint32_t; notReady: bool): SectionReady {.
    importc: "SectionReady_create",  cdecl.}
proc SectionReady_isNotReady*(self: SectionReady): bool {.
    importc: "SectionReady_isNotReady",  cdecl.}
proc SectionReady_getSRQ*(self: SectionReady): uint8_t {.
    importc: "SectionReady_getSRQ",  cdecl.}
proc SectionReady_setSRQ*(self: SectionReady; srq: uint8_t) {.
    importc: "SectionReady_setSRQ",  cdecl.}
proc SectionReady_getNOF*(self: SectionReady): uint16_t {.
    importc: "SectionReady_getNOF",  cdecl.}
proc SectionReady_getNameOfSection*(self: SectionReady): uint8_t {.
    importc: "SectionReady_getNameOfSection",  cdecl.}
proc SectionReady_getLengthOfSection*(self: SectionReady): uint32_t {.
    importc: "SectionReady_getLengthOfSection",  cdecl.}
proc SectionReady_destroy*(self: SectionReady) {.importc: "SectionReady_destroy",
     cdecl.}
## ******************************************
##  FileCallOrSelect : InformationObject
## *****************************************

type
  FileCallOrSelect* = ptr sFileCallOrSelect

proc FileCallOrSelect_create*(self: FileCallOrSelect; ioa: cint; nof: uint16_t;
                             nos: uint8_t; scq: uint8_t): FileCallOrSelect {.
    importc: "FileCallOrSelect_create",  cdecl.}
proc FileCallOrSelect_getNOF*(self: FileCallOrSelect): uint16_t {.
    importc: "FileCallOrSelect_getNOF",  cdecl.}
proc FileCallOrSelect_getNameOfSection*(self: FileCallOrSelect): uint8_t {.
    importc: "FileCallOrSelect_getNameOfSection",  cdecl.}
proc FileCallOrSelect_getSCQ*(self: FileCallOrSelect): uint8_t {.
    importc: "FileCallOrSelect_getSCQ",  cdecl.}
proc FileCallOrSelect_destroy*(self: FileCallOrSelect) {.
    importc: "FileCallOrSelect_destroy",  cdecl.}
## ************************************************
##  FileLastSegmentOrSection : InformationObject
## ***********************************************

type
  FileLastSegmentOrSection* = ptr sFileLastSegmentOrSection

proc FileLastSegmentOrSection_create*(self: FileLastSegmentOrSection; ioa: cint;
                                     nof: uint16_t; nos: uint8_t; lsq: uint8_t;
                                     chs: uint8_t): FileLastSegmentOrSection {.
    importc: "FileLastSegmentOrSection_create",  cdecl.}
proc FileLastSegmentOrSection_getNOF*(self: FileLastSegmentOrSection): uint16_t {.
    importc: "FileLastSegmentOrSection_getNOF",  cdecl.}
proc FileLastSegmentOrSection_getNameOfSection*(self: FileLastSegmentOrSection): uint8_t {.
    importc: "FileLastSegmentOrSection_getNameOfSection",  cdecl.}
proc FileLastSegmentOrSection_getLSQ*(self: FileLastSegmentOrSection): uint8_t {.
    importc: "FileLastSegmentOrSection_getLSQ",  cdecl.}
proc FileLastSegmentOrSection_getCHS*(self: FileLastSegmentOrSection): uint8_t {.
    importc: "FileLastSegmentOrSection_getCHS",  cdecl.}
proc FileLastSegmentOrSection_destroy*(self: FileLastSegmentOrSection) {.
    importc: "FileLastSegmentOrSection_destroy",  cdecl.}
## ************************************************
##  FileACK : InformationObject
## ***********************************************

type
  FileACK* = ptr sFileACK

proc FileACK_create*(self: FileACK; ioa: cint; nof: uint16_t; nos: uint8_t; afq: uint8_t): FileACK {.
    importc: "FileACK_create",  cdecl.}
proc FileACK_getNOF*(self: FileACK): uint16_t {.importc: "FileACK_getNOF",
     cdecl.}
proc FileACK_getNameOfSection*(self: FileACK): uint8_t {.
    importc: "FileACK_getNameOfSection",  cdecl.}
proc FileACK_getAFQ*(self: FileACK): uint8_t {.importc: "FileACK_getAFQ",
     cdecl.}
proc FileACK_destroy*(self: FileACK) {.importc: "FileACK_destroy",  cdecl.}
## ************************************************
##  FileSegment : InformationObject
## ***********************************************

type
  FileSegment* = ptr sFileSegment

proc FileSegment_create*(self: FileSegment; ioa: cint; nof: uint16_t; nos: uint8_t;
                        data: ptr uint8_t; los: uint8_t): FileSegment {.
    importc: "FileSegment_create",  cdecl.}
proc FileSegment_getNOF*(self: FileSegment): uint16_t {.
    importc: "FileSegment_getNOF",  cdecl.}
proc FileSegment_getNameOfSection*(self: FileSegment): uint8_t {.
    importc: "FileSegment_getNameOfSection",  cdecl.}
proc FileSegment_getLengthOfSegment*(self: FileSegment): uint8_t {.
    importc: "FileSegment_getLengthOfSegment",  cdecl.}
proc FileSegment_getSegmentData*(self: FileSegment): ptr uint8_t {.
    importc: "FileSegment_getSegmentData",  cdecl.}
proc FileSegment_GetMaxDataSize*(parameters: CS101_AppLayerParameters): cint {.
    importc: "FileSegment_GetMaxDataSize",  cdecl.}
proc FileSegment_destroy*(self: FileSegment) {.importc: "FileSegment_destroy",
     cdecl.}
## ************************************************
##  FileDirectory: InformationObject
## ***********************************************

type
  FileDirectory* = ptr sFileDirectory

proc FileDirectory_create*(self: FileDirectory; ioa: cint; nof: uint16_t;
                          lengthOfFile: cint; sof: uint8_t; creationTime: CP56Time2a): FileDirectory {.
    importc: "FileDirectory_create",  cdecl.}
proc FileDirectory_getNOF*(self: FileDirectory): uint16_t {.
    importc: "FileDirectory_getNOF",  cdecl.}
proc FileDirectory_getSOF*(self: FileDirectory): uint8_t {.
    importc: "FileDirectory_getSOF",  cdecl.}
proc FileDirectory_getSTATUS*(self: FileDirectory): cint {.
    importc: "FileDirectory_getSTATUS",  cdecl.}
proc FileDirectory_getLFD*(self: FileDirectory): bool {.
    importc: "FileDirectory_getLFD",  cdecl.}
proc FileDirectory_getFOR*(self: FileDirectory): bool {.
    importc: "FileDirectory_getFOR",  cdecl.}
proc FileDirectory_getFA*(self: FileDirectory): bool {.
    importc: "FileDirectory_getFA",  cdecl.}
proc FileDirectory_getLengthOfFile*(self: FileDirectory): uint8_t {.
    importc: "FileDirectory_getLengthOfFile",  cdecl.}
proc FileDirectory_getCreationTime*(self: FileDirectory): CP56Time2a {.
    importc: "FileDirectory_getCreationTime",  cdecl.}
proc FileDirectory_destroy*(self: FileDirectory) {.
    importc: "FileDirectory_destroy",  cdecl.}
## *
##  @}
##
