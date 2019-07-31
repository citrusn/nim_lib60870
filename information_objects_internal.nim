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

#type
#  InformationObjectVFT* = ptr sInformationObjectVFT

#[proc InformationObject_encode*(self: InformationObject; frame: Frame;
                              parameters: CS101_AppLayerParameters;
                              isSequence: bool): bool
proc InformationObject_setObjectAddress*(self: InformationObject; ioa: cint)
proc InformationObject_ParseObjectAddress*(parameters: CS101_AppLayerParameters;
    msg: ptr uint8_t; startIndex: cint): cint
proc SinglePointInformation_getFromBuffer*(self: SinglePointInformation;
    parameters: CS101_AppLayerParameters; msg: ptr uint8_t; msgSize: cint;
    startIndex: cint; isSequence: bool): SinglePointInformation
proc MeasuredValueScaledWithCP56Time2a_getFromBuffer*(
    self: MeasuredValueScaledWithCP56Time2a; parameters: CS101_AppLayerParameters;
    msg: ptr uint8_t; msgSize: cint; startIndex: cint; isSequence: bool): MeasuredValueScaledWithCP56Time2a
proc StepPositionInformation_getFromBuffer*(self: StepPositionInformation;
    parameters: CS101_AppLayerParameters; msg: ptr uint8_t; msgSize: cint;
    startIndex: cint; isSequence: bool): StepPositionInformation
proc StepPositionWithCP56Time2a_getFromBuffer*(self: StepPositionWithCP56Time2a;
    parameters: CS101_AppLayerParameters; msg: ptr uint8_t; msgSize: cint;
    startIndex: cint; isSequence: bool): StepPositionWithCP56Time2a
proc StepPositionWithCP24Time2a_getFromBuffer*(self: StepPositionWithCP24Time2a;
    parameters: CS101_AppLayerParameters; msg: ptr uint8_t; msgSize: cint;
    startIndex: cint; isSequence: bool): StepPositionWithCP24Time2a
proc DoublePointInformation_getFromBuffer*(self: DoublePointInformation;
    parameters: CS101_AppLayerParameters; msg: ptr uint8_t; msgSize: cint;
    startIndex: cint; isSequence: bool): DoublePointInformation
proc DoublePointWithCP24Time2a_getFromBuffer*(self: DoublePointWithCP24Time2a;
    parameters: CS101_AppLayerParameters; msg: ptr uint8_t; msgSize: cint;
    startIndex: cint; isSequence: bool): DoublePointWithCP24Time2a
proc DoublePointWithCP56Time2a_getFromBuffer*(self: DoublePointWithCP56Time2a;
    parameters: CS101_AppLayerParameters; msg: ptr uint8_t; msgSize: cint;
    startIndex: cint; isSequence: bool): DoublePointWithCP56Time2a
proc SinglePointWithCP24Time2a_getFromBuffer*(self: SinglePointWithCP24Time2a;
    parameters: CS101_AppLayerParameters; msg: ptr uint8_t; msgSize: cint;
    startIndex: cint; isSequence: bool): SinglePointWithCP24Time2a
proc SinglePointWithCP56Time2a_getFromBuffer*(self: SinglePointWithCP56Time2a;
    parameters: CS101_AppLayerParameters; msg: ptr uint8_t; msgSize: cint;
    startIndex: cint; isSequence: bool): SinglePointWithCP56Time2a
proc BitString32_getFromBuffer*(self: BitString32;
                               parameters: CS101_AppLayerParameters;
                               msg: ptr uint8_t; msgSize: cint; startIndex: cint;
                               isSequence: bool): BitString32
proc Bitstring32WithCP24Time2a_getFromBuffer*(self: Bitstring32WithCP24Time2a;
    parameters: CS101_AppLayerParameters; msg: ptr uint8_t; msgSize: cint;
    startIndex: cint; isSequence: bool): Bitstring32WithCP24Time2a
proc Bitstring32WithCP56Time2a_getFromBuffer*(self: Bitstring32WithCP56Time2a;
    parameters: CS101_AppLayerParameters; msg: ptr uint8_t; msgSize: cint;
    startIndex: cint; isSequence: bool): Bitstring32WithCP56Time2a
proc MeasuredValueNormalized_getFromBuffer*(self: MeasuredValueNormalized;
    parameters: CS101_AppLayerParameters; msg: ptr uint8_t; msgSize: cint;
    startIndex: cint; isSequence: bool): MeasuredValueNormalized
proc MeasuredValueNormalizedWithCP24Time2a_getFromBuffer*(
    self: MeasuredValueNormalizedWithCP24Time2a;
    parameters: CS101_AppLayerParameters; msg: ptr uint8_t; msgSize: cint;
    startIndex: cint; isSequence: bool): MeasuredValueNormalizedWithCP24Time2a
proc MeasuredValueNormalizedWithCP56Time2a_getFromBuffer*(
    self: MeasuredValueNormalizedWithCP56Time2a;
    parameters: CS101_AppLayerParameters; msg: ptr uint8_t; msgSize: cint;
    startIndex: cint; isSequence: bool): MeasuredValueNormalizedWithCP56Time2a
proc MeasuredValueScaled_getFromBuffer*(self: MeasuredValueScaled;
                                       parameters: CS101_AppLayerParameters;
                                       msg: ptr uint8_t; msgSize: cint;
                                       startIndex: cint; isSequence: bool): MeasuredValueScaled
proc MeasuredValueScaledWithCP24Time2a_getFromBuffer*(
    self: MeasuredValueScaledWithCP24Time2a; parameters: CS101_AppLayerParameters;
    msg: ptr uint8_t; msgSize: cint; startIndex: cint; isSequence: bool): MeasuredValueScaledWithCP24Time2a
proc MeasuredValueShort_getFromBuffer*(self: MeasuredValueShort;
                                      parameters: CS101_AppLayerParameters;
                                      msg: ptr uint8_t; msgSize: cint;
                                      startIndex: cint; isSequence: bool): MeasuredValueShort
proc MeasuredValueShortWithCP24Time2a_getFromBuffer*(
    self: MeasuredValueShortWithCP24Time2a; parameters: CS101_AppLayerParameters;
    msg: ptr uint8_t; msgSize: cint; startIndex: cint; isSequence: bool): MeasuredValueShortWithCP24Time2a
proc MeasuredValueShortWithCP56Time2a_getFromBuffer*(
    self: MeasuredValueShortWithCP56Time2a; parameters: CS101_AppLayerParameters;
    msg: ptr uint8_t; msgSize: cint; startIndex: cint; isSequence: bool): MeasuredValueShortWithCP56Time2a
proc IntegratedTotals_getFromBuffer*(self: IntegratedTotals;
                                    parameters: CS101_AppLayerParameters;
                                    msg: ptr uint8_t; msgSize: cint;
                                    startIndex: cint; isSequence: bool): IntegratedTotals
proc IntegratedTotalsWithCP24Time2a_getFromBuffer*(
    self: IntegratedTotalsWithCP24Time2a; parameters: CS101_AppLayerParameters;
    msg: ptr uint8_t; msgSize: cint; startIndex: cint; isSequence: bool): IntegratedTotalsWithCP24Time2a
proc IntegratedTotalsWithCP56Time2a_getFromBuffer*(
    self: IntegratedTotalsWithCP56Time2a; parameters: CS101_AppLayerParameters;
    msg: ptr uint8_t; msgSize: cint; startIndex: cint; isSequence: bool): IntegratedTotalsWithCP56Time2a
proc EventOfProtectionEquipment_getFromBuffer*(self: EventOfProtectionEquipment;
    parameters: CS101_AppLayerParameters; msg: ptr uint8_t; msgSize: cint;
    startIndex: cint; isSequence: bool): EventOfProtectionEquipment
proc PackedStartEventsOfProtectionEquipment_getFromBuffer*(
    self: PackedStartEventsOfProtectionEquipment;
    parameters: CS101_AppLayerParameters; msg: ptr uint8_t; msgSize: cint;
    startIndex: cint; isSequence: bool): PackedStartEventsOfProtectionEquipment
proc PackedOutputCircuitInfo_getFromBuffer*(self: PackedOutputCircuitInfo;
    parameters: CS101_AppLayerParameters; msg: ptr uint8_t; msgSize: cint;
    startIndex: cint; isSequence: bool): PackedOutputCircuitInfo
proc PackedSinglePointWithSCD_getFromBuffer*(self: PackedSinglePointWithSCD;
    parameters: CS101_AppLayerParameters; msg: ptr uint8_t; msgSize: cint;
    startIndex: cint; isSequence: bool): PackedSinglePointWithSCD
proc MeasuredValueNormalizedWithoutQuality_getFromBuffer*(
    self: MeasuredValueNormalizedWithoutQuality;
    parameters: CS101_AppLayerParameters; msg: ptr uint8_t; msgSize: cint;
    startIndex: cint; isSequence: bool): MeasuredValueNormalizedWithoutQuality
proc EventOfProtectionEquipmentWithCP56Time2a_getFromBuffer*(
    self: EventOfProtectionEquipmentWithCP56Time2a;
    parameters: CS101_AppLayerParameters; msg: ptr uint8_t; msgSize: cint;
    startIndex: cint; isSequence: bool): EventOfProtectionEquipmentWithCP56Time2a
proc PackedStartEventsOfProtectionEquipmentWithCP56Time2a_getFromBuffer*(
    self: PackedStartEventsOfProtectionEquipmentWithCP56Time2a;
    parameters: CS101_AppLayerParameters; msg: ptr uint8_t; msgSize: cint;
    startIndex: cint; isSequence: bool): PackedStartEventsOfProtectionEquipmentWithCP56Time2a
proc PackedOutputCircuitInfoWithCP56Time2a_getFromBuffer*(
    self: PackedOutputCircuitInfoWithCP56Time2a;
    parameters: CS101_AppLayerParameters; msg: ptr uint8_t; msgSize: cint;
    startIndex: cint; isSequence: bool): PackedOutputCircuitInfoWithCP56Time2a
proc SingleCommand_getFromBuffer*(self: SingleCommand;
                                 parameters: CS101_AppLayerParameters;
                                 msg: ptr uint8_t; msgSize: cint; startIndex: cint): SingleCommand
proc SingleCommandWithCP56Time2a_getFromBuffer*(
    self: SingleCommandWithCP56Time2a; parameters: CS101_AppLayerParameters;
    msg: ptr uint8_t; msgSize: cint; startIndex: cint): SingleCommandWithCP56Time2a
proc DoubleCommand_getFromBuffer*(self: DoubleCommand;
                                 parameters: CS101_AppLayerParameters;
                                 msg: ptr uint8_t; msgSize: cint; startIndex: cint): DoubleCommand
proc StepCommand_getFromBuffer*(self: StepCommand;
                               parameters: CS101_AppLayerParameters;
                               msg: ptr uint8_t; msgSize: cint; startIndex: cint): StepCommand
proc SetpointCommandNormalized_getFromBuffer*(self: SetpointCommandNormalized;
    parameters: CS101_AppLayerParameters; msg: ptr uint8_t; msgSize: cint;
    startIndex: cint): SetpointCommandNormalized
proc SetpointCommandScaled_getFromBuffer*(self: SetpointCommandScaled;
    parameters: CS101_AppLayerParameters; msg: ptr uint8_t; msgSize: cint;
    startIndex: cint): SetpointCommandScaled
proc SetpointCommandShort_getFromBuffer*(self: SetpointCommandShort;
                                        parameters: CS101_AppLayerParameters;
                                        msg: ptr uint8_t; msgSize: cint;
                                        startIndex: cint): SetpointCommandShort
proc Bitstring32Command_getFromBuffer*(self: Bitstring32Command;
                                      parameters: CS101_AppLayerParameters;
                                      msg: ptr uint8_t; msgSize: cint;
                                      startIndex: cint): Bitstring32Command
proc ReadCommand_getFromBuffer*(self: ReadCommand;
                               parameters: CS101_AppLayerParameters;
                               msg: ptr uint8_t; msgSize: cint; startIndex: cint): ReadCommand
proc ClockSynchronizationCommand_getFromBuffer*(
    self: ClockSynchronizationCommand; parameters: CS101_AppLayerParameters;
    msg: ptr uint8_t; msgSize: cint; startIndex: cint): ClockSynchronizationCommand
proc InterrogationCommand_getFromBuffer*(self: InterrogationCommand;
                                        parameters: CS101_AppLayerParameters;
                                        msg: ptr uint8_t; msgSize: cint;
                                        startIndex: cint): InterrogationCommand
proc ParameterNormalizedValue_getFromBuffer*(self: ParameterNormalizedValue;
    parameters: CS101_AppLayerParameters; msg: ptr uint8_t; msgSize: cint;
    startIndex: cint): ParameterNormalizedValue
proc ParameterScaledValue_getFromBuffer*(self: ParameterScaledValue;
                                        parameters: CS101_AppLayerParameters;
                                        msg: ptr uint8_t; msgSize: cint;
                                        startIndex: cint): ParameterScaledValue
proc ParameterFloatValue_getFromBuffer*(self: ParameterFloatValue;
                                       parameters: CS101_AppLayerParameters;
                                       msqg: ptr uint8_t; msgSize: cint;
                                       startIndex: cint): ParameterFloatValue
proc ParameterActivation_getFromBuffer*(self: ParameterActivation;
                                       parameters: CS101_AppLayerParameters;
                                       msg: ptr uint8_t; msgSize: cint;
                                       startIndex: cint): ParameterActivation
proc EndOfInitialization_getFromBuffer*(self: EndOfInitialization;
                                       parameters: CS101_AppLayerParameters;
                                       msg: ptr uint8_t; msgSize: cint;
                                       startIndex: cint): EndOfInitialization
proc DoubleCommandWithCP56Time2a_getFromBuffer*(
    self: DoubleCommandWithCP56Time2a; parameters: CS101_AppLayerParameters;
    msg: ptr uint8_t; msgSize: cint; startIndex: cint): DoubleCommandWithCP56Time2a
proc StepCommandWithCP56Time2a_getFromBuffer*(self: StepCommandWithCP56Time2a;
    parameters: CS101_AppLayerParameters; msg: ptr uint8_t; msgSize: cint;
    startIndex: cint): StepCommandWithCP56Time2a
proc SetpointCommandNormalizedWithCP56Time2a_getFromBuffer*(
    self: SetpointCommandNormalizedWithCP56Time2a;
    parameters: CS101_AppLayerParameters; msg: ptr uint8_t; msgSize: cint;
    startIndex: cint): SetpointCommandNormalizedWithCP56Time2a
proc SetpointCommandScaledWithCP56Time2a_getFromBuffer*(
    self: SetpointCommandScaledWithCP56Time2a;
    parameters: CS101_AppLayerParameters; msg: ptr uint8_t; msgSize: cint;
    startIndex: cint): SetpointCommandScaledWithCP56Time2a
proc SetpointCommandShortWithCP56Time2a_getFromBuffer*(
    self: SetpointCommandShortWithCP56Time2a;
    parameters: CS101_AppLayerParameters; msg: ptr uint8_t; msgSize: cint;
    startIndex: cint): SetpointCommandShortWithCP56Time2a
proc Bitstring32CommandWithCP56Time2a_getFromBuffer*(
    self: Bitstring32CommandWithCP56Time2a; parameters: CS101_AppLayerParameters;
    msg: ptr uint8_t; msgSize: cint; startIndex: cint): Bitstring32CommandWithCP56Time2a
proc CounterInterrogationCommand_getFromBuffer*(
    self: CounterInterrogationCommand; parameters: CS101_AppLayerParameters;
    msg: ptr uint8_t; msgSize: cint; startIndex: cint): CounterInterrogationCommand
proc TestCommand_getFromBuffer*(self: TestCommand;
                               parameters: CS101_AppLayerParameters;
                               msg: ptr uint8_t; msgSize: cint; startIndex: cint): TestCommand
proc ResetProcessCommand_getFromBuffer*(self: ResetProcessCommand;
                                       parameters: CS101_AppLayerParameters;
                                       msg: ptr uint8_t; msgSize: cint;
                                       startIndex: cint): ResetProcessCommand
proc DelayAcquisitionCommand_getFromBuffer*(self: DelayAcquisitionCommand;
    parameters: CS101_AppLayerParameters; msg: ptr uint8_t; msgSize: cint;
    startIndex: cint): DelayAcquisitionCommand
proc FileReady_getFromBuffer*(self: FileReady;
                             parameters: CS101_AppLayerParameters;
                             msg: ptr uint8_t; msgSize: cint; startIndex: cint): FileReady
proc SectionReady_getFromBuffer*(self: SectionReady;
                                parameters: CS101_AppLayerParameters;
                                msg: ptr uint8_t; msgSize: cint; startIndex: cint): SectionReady
proc FileCallOrSelect_getFromBuffer*(self: FileCallOrSelect;
                                    parameters: CS101_AppLayerParameters;
                                    msg: ptr uint8_t; msgSize: cint; startIndex: cint): FileCallOrSelect
proc FileLastSegmentOrSection_getFromBuffer*(self: FileLastSegmentOrSection;
    parameters: CS101_AppLayerParameters; msg: ptr uint8_t; msgSize: cint;
    startIndex: cint): FileLastSegmentOrSection
proc FileACK_getFromBuffer*(self: FileACK; parameters: CS101_AppLayerParameters;
                           msg: ptr uint8_t; msgSize: cint; startIndex: cint): FileACK
proc FileSegment_getFromBuffer*(self: FileSegment;
                               parameters: CS101_AppLayerParameters;
                               msg: ptr uint8_t; msgSize: cint; startIndex: cint): FileSegment
proc FileDirectory_getFromBuffer*(self: FileDirectory;
                                 parameters: CS101_AppLayerParameters;
                                 msg: ptr uint8_t; msgSize: cint; startIndex: cint;
                                 isSequence: bool): FileDirectory
]#                                
## *******************************************
##  static InformationObject type definitions
## ******************************************

type
  sSinglePointInformation* {.bycopy.} = object
    objectAddress*: cint
    `type`*: TypeID
    virtualFunctionTable*: InformationObjectVFT
    value*: bool
    quality*: QualityDescriptor

  sStepPositionInformation* {.bycopy.} = object
    objectAddress*: cint
    `type`*: TypeID
    virtualFunctionTable*: InformationObjectVFT
    vti*: uint8_t
    quality*: QualityDescriptor

  sStepPositionWithCP56Time2a* {.bycopy.} = object
    objectAddress*: cint
    `type`*: TypeID
    virtualFunctionTable*: InformationObjectVFT
    vti*: uint8_t
    quality*: QualityDescriptor
    timestamp*: sCP56Time2a

  sStepPositionWithCP24Time2a* {.bycopy.} = object
    objectAddress*: cint
    `type`*: TypeID
    virtualFunctionTable*: InformationObjectVFT
    vti*: uint8_t
    quality*: QualityDescriptor
    timestamp*: sCP24Time2a

  sDoublePointInformation* {.bycopy.} = object
    objectAddress*: cint
    `type`*: TypeID
    virtualFunctionTable*: InformationObjectVFT
    value*: DoublePointValue
    quality*: QualityDescriptor

  sDoublePointWithCP24Time2a* {.bycopy.} = object
    objectAddress*: cint
    `type`*: TypeID
    virtualFunctionTable*: InformationObjectVFT
    value*: DoublePointValue
    quality*: QualityDescriptor
    timestamp*: sCP24Time2a

  sDoublePointWithCP56Time2a* {.bycopy.} = object
    objectAddress*: cint
    `type`*: TypeID
    virtualFunctionTable*: InformationObjectVFT
    value*: DoublePointValue
    quality*: QualityDescriptor
    timestamp*: sCP56Time2a

  sSinglePointWithCP24Time2a* {.bycopy.} = object
    objectAddress*: cint
    `type`*: TypeID
    virtualFunctionTable*: InformationObjectVFT
    value*: bool
    quality*: QualityDescriptor
    timestamp*: sCP24Time2a

  sSinglePointWithCP56Time2a* {.bycopy.} = object
    objectAddress*: cint
    `type`*: TypeID
    virtualFunctionTable*: InformationObjectVFT
    value*: bool
    quality*: QualityDescriptor
    timestamp*: sCP56Time2a

  sBitString32* {.bycopy.} = object
    objectAddress*: cint
    `type`*: TypeID
    virtualFunctionTable*: InformationObjectVFT
    value*: uint32_t
    quality*: QualityDescriptor

  sBitstring32WithCP24Time2a* {.bycopy.} = object
    objectAddress*: cint
    `type`*: TypeID
    virtualFunctionTable*: InformationObjectVFT
    value*: uint32_t
    quality*: QualityDescriptor
    timestamp*: sCP24Time2a

  sBitstring32WithCP56Time2a* {.bycopy.} = object
    objectAddress*: cint
    `type`*: TypeID
    virtualFunctionTable*: InformationObjectVFT
    value*: uint32_t
    quality*: QualityDescriptor
    timestamp*: sCP56Time2a

  sMeasuredValueNormalized* {.bycopy.} = object
    objectAddress*: cint
    `type`*: TypeID
    virtualFunctionTable*: InformationObjectVFT
    encodedValue*: array[2, uint8_t]
    quality*: QualityDescriptor

  sMeasuredValueNormalizedWithoutQuality* {.bycopy.} = object
    objectAddress*: cint
    `type`*: TypeID
    virtualFunctionTable*: InformationObjectVFT
    encodedValue*: array[2, uint8_t]

  sMeasuredValueNormalizedWithCP24Time2a* {.bycopy.} = object
    objectAddress*: cint
    `type`*: TypeID
    virtualFunctionTable*: InformationObjectVFT
    encodedValue*: array[2, uint8_t]
    quality*: QualityDescriptor
    timestamp*: sCP24Time2a

  sMeasuredValueNormalizedWithCP56Time2a* {.bycopy.} = object
    objectAddress*: cint
    `type`*: TypeID
    virtualFunctionTable*: InformationObjectVFT
    encodedValue*: array[2, uint8_t]
    quality*: QualityDescriptor
    timestamp*: sCP56Time2a

  sMeasuredValueScaled* {.bycopy.} = object
    objectAddress*: cint
    `type`*: TypeID
    virtualFunctionTable*: InformationObjectVFT
    encodedValue*: array[2, uint8_t]
    quality*: QualityDescriptor

  sMeasuredValueScaledWithCP24Time2a* {.bycopy.} = object
    objectAddress*: cint
    `type`*: TypeID
    virtualFunctionTable*: InformationObjectVFT
    encodedValue*: array[2, uint8_t]
    quality*: QualityDescriptor
    timestamp*: sCP24Time2a

  sMeasuredValueScaledWithCP56Time2a* {.bycopy.} = object
    objectAddress*: cint
    `type`*: TypeID
    virtualFunctionTable*: InformationObjectVFT
    encodedValue*: array[2, uint8_t]
    quality*: QualityDescriptor
    timestamp*: sCP56Time2a

  sMeasuredValueShort* {.bycopy.} = object
    objectAddress*: cint
    `type`*: TypeID
    virtualFunctionTable*: InformationObjectVFT
    value*: cfloat
    quality*: QualityDescriptor

  sMeasuredValueShortWithCP24Time2a* {.bycopy.} = object
    objectAddress*: cint
    `type`*: TypeID
    virtualFunctionTable*: InformationObjectVFT
    value*: cfloat
    quality*: QualityDescriptor
    timestamp*: sCP24Time2a

  sMeasuredValueShortWithCP56Time2a* {.bycopy.} = object
    objectAddress*: cint
    `type`*: TypeID
    virtualFunctionTable*: InformationObjectVFT
    value*: cfloat
    quality*: QualityDescriptor
    timestamp*: sCP56Time2a

  sIntegratedTotals* {.bycopy.} = object
    objectAddress*: cint
    `type`*: TypeID
    virtualFunctionTable*: InformationObjectVFT
    totals*: sBinaryCounterReading

  sIntegratedTotalsWithCP24Time2a* {.bycopy.} = object
    objectAddress*: cint
    `type`*: TypeID
    virtualFunctionTable*: InformationObjectVFT
    totals*: sBinaryCounterReading
    timestamp*: sCP24Time2a

  sIntegratedTotalsWithCP56Time2a* {.bycopy.} = object
    objectAddress*: cint
    `type`*: TypeID
    virtualFunctionTable*: InformationObjectVFT
    totals*: sBinaryCounterReading
    timestamp*: sCP56Time2a

  sEventOfProtectionEquipment* {.bycopy.} = object
    objectAddress*: cint
    `type`*: TypeID
    virtualFunctionTable*: InformationObjectVFT
    event*: tSingleEvent
    elapsedTime*: sCP16Time2a
    timestamp*: sCP24Time2a

  sEventOfProtectionEquipmentWithCP56Time2a* {.bycopy.} = object
    objectAddress*: cint
    `type`*: TypeID
    virtualFunctionTable*: InformationObjectVFT
    event*: tSingleEvent
    elapsedTime*: sCP16Time2a
    timestamp*: sCP56Time2a

  sPackedStartEventsOfProtectionEquipment* {.bycopy.} = object
    objectAddress*: cint
    `type`*: TypeID
    virtualFunctionTable*: InformationObjectVFT
    event*: StartEvent
    qdp*: QualityDescriptorP
    elapsedTime*: sCP16Time2a
    timestamp*: sCP24Time2a

  sPackedStartEventsOfProtectionEquipmentWithCP56Time2a* {.bycopy.} = object
    objectAddress*: cint
    `type`*: TypeID
    virtualFunctionTable*: InformationObjectVFT
    event*: StartEvent
    qdp*: QualityDescriptorP
    elapsedTime*: sCP16Time2a
    timestamp*: sCP56Time2a

  sPackedOutputCircuitInfo* {.bycopy.} = object
    objectAddress*: cint
    `type`*: TypeID
    virtualFunctionTable*: InformationObjectVFT
    oci*: OutputCircuitInfo
    qdp*: QualityDescriptorP
    operatingTime*: sCP16Time2a
    timestamp*: sCP24Time2a

  sPackedOutputCircuitInfoWithCP56Time2a* {.bycopy.} = object
    objectAddress*: cint
    `type`*: TypeID
    virtualFunctionTable*: InformationObjectVFT
    oci*: OutputCircuitInfo
    qdp*: QualityDescriptorP
    operatingTime*: sCP16Time2a
    timestamp*: sCP56Time2a

  sPackedSinglePointWithSCD* {.bycopy.} = object
    objectAddress*: cint
    `type`*: TypeID
    virtualFunctionTable*: InformationObjectVFT
    scd*: tStatusAndStatusChangeDetection
    qds*: QualityDescriptor

  sSingleCommand* {.bycopy.} = object
    objectAddress*: cint
    `type`*: TypeID
    virtualFunctionTable*: InformationObjectVFT
    sco*: uint8_t

  sSingleCommandWithCP56Time2a* {.bycopy.} = object
    objectAddress*: cint
    `type`*: TypeID
    virtualFunctionTable*: InformationObjectVFT
    sco*: uint8_t
    timestamp*: sCP56Time2a

  sDoubleCommand* {.bycopy.} = object
    objectAddress*: cint
    `type`*: TypeID
    virtualFunctionTable*: InformationObjectVFT
    dcq*: uint8_t

  sDoubleCommandWithCP56Time2a* {.bycopy.} = object
    objectAddress*: cint
    `type`*: TypeID
    virtualFunctionTable*: InformationObjectVFT
    dcq*: uint8_t
    timestamp*: sCP56Time2a

  sStepCommand* {.bycopy.} = object
    objectAddress*: cint
    `type`*: TypeID
    virtualFunctionTable*: InformationObjectVFT
    dcq*: uint8_t

  sStepCommandWithCP56Time2a* {.bycopy.} = object
    objectAddress*: cint
    `type`*: TypeID
    virtualFunctionTable*: InformationObjectVFT
    dcq*: uint8_t
    timestamp*: sCP56Time2a

  sSetpointCommandNormalized* {.bycopy.} = object
    objectAddress*: cint
    `type`*: TypeID
    virtualFunctionTable*: InformationObjectVFT
    encodedValue*: array[2, uint8_t]
    qos*: uint8_t  ##  Qualifier of setpoint command

  sSetpointCommandNormalizedWithCP56Time2a* {.bycopy.} = object
    objectAddress*: cint
    `type`*: TypeID
    virtualFunctionTable*: InformationObjectVFT
    encodedValue*: array[2, uint8_t]
    qos*: uint8_t              ##  Qualifier of setpoint command
    timestamp*: sCP56Time2a

  sSetpointCommandScaled* {.bycopy.} = object
    objectAddress*: cint
    `type`*: TypeID
    virtualFunctionTable*: InformationObjectVFT
    encodedValue*: array[2, uint8_t]
    qos*: uint8_t         ##  Qualifier of setpoint command

  sSetpointCommandScaledWithCP56Time2a* {.bycopy.} = object
    objectAddress*: cint
    `type`*: TypeID
    virtualFunctionTable*: InformationObjectVFT
    encodedValue*: array[2, uint8_t]
    qos*: uint8_t              ##  Qualifier of setpoint command
    timestamp*: sCP56Time2a

  sSetpointCommandShort* {.bycopy.} = object
    objectAddress*: cint
    `type`*: TypeID
    virtualFunctionTable*: InformationObjectVFT
    value*: cfloat
    qos*: uint8_t      ##  Qualifier of setpoint command

  sSetpointCommandShortWithCP56Time2a* {.bycopy.} = object
    objectAddress*: cint
    `type`*: TypeID
    virtualFunctionTable*: InformationObjectVFT
    value*: cfloat
    qos*: uint8_t              ##  Qualifier of setpoint command
    timestamp*: sCP56Time2a

  sBitstring32Command* {.bycopy.} = object
    objectAddress*: cint
    `type`*: TypeID
    virtualFunctionTable*: InformationObjectVFT
    value*: uint32_t

  sBitstring32CommandWithCP56Time2a* {.bycopy.} = object
    objectAddress*: cint
    `type`*: TypeID
    virtualFunctionTable*: InformationObjectVFT
    value*: uint32_t
    timestamp*: sCP56Time2a

  sReadCommand* {.bycopy.} = object
    objectAddress*: cint
    `type`*: TypeID
    virtualFunctionTable*: InformationObjectVFT

  sClockSynchronizationCommand* {.bycopy.} = object
    objectAddress*: cint
    `type`*: TypeID
    virtualFunctionTable*: InformationObjectVFT
    timestamp*: sCP56Time2a

  sInterrogationCommand* {.bycopy.} = object
    objectAddress*: cint
    `type`*: TypeID
    virtualFunctionTable*: InformationObjectVFT
    qoi*: uint8_t

  sCounterInterrogationCommand* {.bycopy.} = object
    objectAddress*: cint
    `type`*: TypeID
    virtualFunctionTable*: InformationObjectVFT
    qcc*: uint8_t

  sTestCommand* {.bycopy.} = object
    objectAddress*: cint
    `type`*: TypeID
    virtualFunctionTable*: InformationObjectVFT
    byte1*: uint8_t
    byte2*: uint8_t

  sResetProcessCommand* {.bycopy.} = object
    objectAddress*: cint
    `type`*: TypeID
    virtualFunctionTable*: InformationObjectVFT
    qrp*: QualifierOfRPC

  sDelayAcquisitionCommand* {.bycopy.} = object
    objectAddress*: cint
    `type`*: TypeID
    virtualFunctionTable*: InformationObjectVFT
    delay*: sCP16Time2a

  sParameterActivation* {.bycopy.} = object
    objectAddress*: cint
    `type`*: TypeID
    virtualFunctionTable*: InformationObjectVFT
    qpa*: QualifierOfParameterActivation

  sEndOfInitialization* {.bycopy.} = object
    objectAddress*: cint
    `type`*: TypeID
    virtualFunctionTable*: InformationObjectVFT
    coi*: uint8_t

  sFileReady* {.bycopy.} = object
    objectAddress*: cint
    `type`*: TypeID
    virtualFunctionTable*: InformationObjectVFT
    nof*: uint16_t             ##  name of file
    lengthOfFile*: uint32_t
    frq*: uint8_t              ##  file ready qualifier

  sSectionReady* {.bycopy.} = object
    objectAddress*: cint
    `type`*: TypeID
    virtualFunctionTable*: InformationObjectVFT
    nof*: uint16_t             ##  name of file
    nameOfSection*: uint8_t
    lengthOfSection*: uint32_t
    srq*: uint8_t              ##  section ready qualifier

  sFileCallOrSelect* {.bycopy.} = object
    objectAddress*: cint
    `type`*: TypeID
    virtualFunctionTable*: InformationObjectVFT
    nof*: uint16_t             ##  name of file
    nameOfSection*: uint8_t
    scq*: uint8_t              ##  select and call qualifier

  sFileLastSegmentOrSection* {.bycopy.} = object
    objectAddress*: cint
    `type`*: TypeID
    virtualFunctionTable*: InformationObjectVFT
    nof*: uint16_t             ##  name of file
    nameOfSection*: uint8_t
    lsq*: uint8_t              ##  last section or segment qualifier
    chs*: uint8_t              ##  checksum of section or segment

  sFileACK* {.bycopy.} = object
    objectAddress*: cint
    `type`*: TypeID
    virtualFunctionTable*: InformationObjectVFT
    nof*: uint16_t             ##  name of file
    nameOfSection*: uint8_t
    afq*: uint8_t              ##  AFQ (acknowledge file or section qualifier)

  sFileSegment* {.bycopy.} = object
    objectAddress*: cint
    `type`*: TypeID
    virtualFunctionTable*: InformationObjectVFT
    nof*: uint16_t             ##  name of file
    nameOfSection*: uint8_t
    los*: uint8_t              ##  length of segment
    data*: ptr uint8_t          ##  user data buffer - file payload

  sFileDirectory* {.bycopy.} = object
    objectAddress*: cint
    `type`*: TypeID
    virtualFunctionTable*: InformationObjectVFT
    nof*: uint16_t             ##  name of file
    lengthOfFile*: cint        ##  LOF
    sof*: uint8_t              ##  state of file
    creationTime*: sCP56Time2a

  uInformationObject* {.bycopy, union.} = object 
    m1*: sSinglePointInformation      # M_SP_NA_1 1 0x01 Single-point information
    m8*: sSinglePointWithCP24Time2a   # M_SP_TA_1 2 0x02 Single-point information with time tag
    m5*: sDoublePointInformation      # M_DP_NA_1 3 0x03 Double-point information
    m6*: sDoublePointWithCP24Time2a   # M_DP_TA_1 4 0x04 Double-point information with time tag
    m2*: sStepPositionInformation     # M_ST_NA_1 5 0x05 Step position information
    m3*: sStepPositionWithCP24Time2a  # M_ST_TA_1 6 0x06 Step position information with time tag
    m10*: sBitString32                # M_BO_NA_1 7 0x07 Bitstring of 32 bit
    m11*: sBitstring32WithCP24Time2a  # M_BO_TA_1 8 0x08 Bitstring of 32 bit with time tag
    m13*: sMeasuredValueNormalized    # M_ME_NA_1 9 0x09 Measured value, normalised value
    m9*: sSinglePointWithCP56Time2a   # M_SP_TB_1 30 0x1E Single-point information with time tag CP56Time2a 
    m7*: sDoublePointWithCP56Time2a   # M_DP_TB_1 31 0x1F Double-point information with time tag CP56Time2a
    m4*: sStepPositionWithCP56Time2a  # M_ST_TB_1 32 0x20 Step position information with time tag CP56Time2a
    m12*: sBitstring32WithCP56Time2a  # M_BO_TB_1 33 0x21 Bitstring of 32 bit with time tag CP56Time2a    
    m14*: sMeasuredValueNormalizedWithCP24Time2a  # M_ME_TA_1 10 0x0A Measured value, normalized value with time tag
    m15*: sMeasuredValueNormalizedWithCP56Time2a  # M_ME_TD_1 34 0x22 Measured value, normalised value with time tag CP56Time2a
    m16*: sMeasuredValueScaled                    # M_ME_NB_1 11 0x0B Measured value, scaled value
    m17*: sMeasuredValueScaledWithCP24Time2a      # M_ME_TB_1 12 0x0C Measured value, scaled value wit time tag
    m18*: sMeasuredValueScaledWithCP56Time2a      # M_ME_TE_1 35 0x23 Measured value, scaled value with time tag CP56Time2a
    m19*: sMeasuredValueShort                     # M_ME_NC_1 13 0x0D Measured value, short floating point number
    m20*: sMeasuredValueShortWithCP24Time2a       # M_ME_TC_1 14 0x0E Measured value, short floating point number with time tag
    m21*: sMeasuredValueShortWithCP56Time2a       # M_ME_TF_1 36 0x24 Measured value, short floating point number with time tag CP56Time2a
    m22*: sIntegratedTotals                       # M_IT_NA_1 15 0x0F Integrated totals
    m23*: sIntegratedTotalsWithCP24Time2a         # M_IT_TA_1 16 0x10 Integrated totals with time tag
    m24*: sIntegratedTotalsWithCP56Time2a         # M_IT_TB_1 37 0x25 Integrated totals with time tag CP56Time2a
    m25*: sSingleCommand                # C_SC_NA_1 45 0x2D Single command
    m26*: sSingleCommandWithCP56Time2a  # C_SC_TA_1 58 0x3A Single command with time tag CP56Time2a
    m27*: sDoubleCommand                # C_DC_NA_1 46 0x2E Double command
    m28*: sStepCommand                  # C_RC_NA_1 47 0x2F Regulating step command
    m29*: sSetpointCommandNormalized    # C_SE_NA_1 48 0x30 Set-point Command, normalised value
    m30*: sSetpointCommandScaled        # C_SE_NB_1 49 0x31 Set-point Command, scaled value
    m31*: sSetpointCommandShort         # C_SE_NC_1 50 0x32 Set-point Command, short floating point number
    m32*: sBitstring32Command           # C_BO_NA_1 51 0x33 Bitstring 32 bit command
    m33*: sReadCommand                  # C_RD_NA_1 102 0x66 Read command
    m34*: sClockSynchronizationCommand  # C_CS_NA_1 103 0x67 Clock synchronisation command
    m35*: sInterrogationCommand         # C_IC_NA_1 100 0x64 Interrogation command
    m36*: sParameterActivation          # P_AC_NA_1 113 0x71 Parameter activation
    m37*: sEventOfProtectionEquipmentWithCP56Time2a # M_EP_TD_1 38 0x26 Event of protection equipment with time tag CP56Time2a
    m38*: sStepCommandWithCP56Time2a    # C_RC_TA_1 60 0x3C Regulating step command with time tag CP56Time2a
