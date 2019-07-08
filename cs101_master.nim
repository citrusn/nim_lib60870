##
##   cs101_master.h
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
##  \file cs101_master.h
##  \brief Functions for CS101_Master ADT.
##  Can be used to implement a balanced or unbalanced CS 101 master.
##

import
  iec60870_master, link_layer_parameters

## *
##  @defgroup MASTER Master related functions
##
##  @{
##
## *
##  @defgroup CS101_MASTER CS 101 master related functions
##
##  @{
##
## *
##  \brief CS101_Master type
##

type
  CS101_Master* = ptr sCS101_Master

## *
##  \brief Create a new master instance
##
##  \param port the serial port to use
##  \param llParameters the link layer parameters to use
##  \param alParameters the application layer parameters to use
##  \param mode the link layer mode (either IEC60870_LINK_LAYER_BALANCED or IEC60870_LINK_LAYER_UNBALANCED)
##
##  \return the new CS101_Master instance
##

proc CS101_Master_create*(port: SerialPort; llParameters: LinkLayerParameters;
                         alParameters: CS101_AppLayerParameters;
                         mode: IEC60870_LinkLayerMode): CS101_Master {.
    importc: "CS101_Master_create", dynlib: "60870.dll", cdecl.}
## *
##  \brief Receive a new message and run the protocol state machine(s).
##
##  NOTE: This function has to be called frequently in order to send and
##  receive messages to and from slaves.
##

proc CS101_Master_run*(self: CS101_Master) {.importc: "CS101_Master_run",
    dynlib: "60870.dll", cdecl.}
## *
##  \brief Start a background thread that handles the link layer connections
##
##  NOTE: This requires threads. If you don't want to use a separate thread
##  for the master instance you have to call the \ref CS101_Master_run function
##  periodically.
##
##  \param self CS101_Master instance
##

proc CS101_Master_start*(self: CS101_Master) {.importc: "CS101_Master_start",
    dynlib: "60870.dll", cdecl.}
## *
##  \brief Stops the background thread that handles the link layer connections
##
##  \param self CS101_Master instance
##

proc CS101_Master_stop*(self: CS101_Master) {.importc: "CS101_Master_stop",
    dynlib: "60870.dll", cdecl.}
## *
##  \brief Add a new slave connection
##
##  This function creates and starts a new link layer state machine
##  to be used for communication with the slave. It has to be called
##  before any application data can be send/received to/from the slave.
##
##  \param address link layer address of the slave
##

proc CS101_Master_addSlave*(self: CS101_Master; address: cint) {.
    importc: "CS101_Master_addSlave", dynlib: "60870.dll", cdecl.}
## *
##  \brief Poll a slave (only unbalanced mode)
##
##  NOTE: This command will instruct the unbalanced link layer to send a
##  request for class 2 data. It is required to frequently call this
##  message for each slave in order to receive application layer data from
##  the slave
##
##  \param address the link layer address of the slave
##

proc CS101_Master_pollSingleSlave*(self: CS101_Master; address: cint) {.
    importc: "CS101_Master_pollSingleSlave", dynlib: "60870.dll", cdecl.}
## *
##  \brief Destroy the master instance and release all resources
##

proc CS101_Master_destroy*(self: CS101_Master) {.importc: "CS101_Master_destroy",
    dynlib: "60870.dll", cdecl.}
## *
##  \brief Set the value of the DIR bit when sending messages (only balanced mode)
##
##  NOTE: Default value is true (controlling station). In the case of two equivalent stations
##  the value is defined by agreement.
##
##  \param dir the value of the DIR bit when sending messages
##

proc CS101_Master_setDIR*(self: CS101_Master; dir: bool) {.
    importc: "CS101_Master_setDIR", dynlib: "60870.dll", cdecl.}
## *
##  \brief Set the own link layer address (only balanced mode)
##
##  \param address the link layer address to use
##

proc CS101_Master_setOwnAddress*(self: CS101_Master; address: cint) {.
    importc: "CS101_Master_setOwnAddress", dynlib: "60870.dll", cdecl.}
## *
##  \brief Set the slave address for the following send functions
##
##  NOTE: This is always required in unbalanced mode. Some balanced slaves
##  also check the link layer address. In this case the slave address
##  has also to be set in balanced mode.
##
##  \param address the link layer address of the slave to address
##

proc CS101_Master_useSlaveAddress*(self: CS101_Master; address: cint) {.
    importc: "CS101_Master_useSlaveAddress", dynlib: "60870.dll", cdecl.}
## *
##  \brief Returns the application layer parameters object of this master instance
##
##  \return the CS101_AppLayerParameters instance used by this master
##

proc CS101_Master_getAppLayerParameters*(self: CS101_Master): CS101_AppLayerParameters {.
    importc: "CS101_Master_getAppLayerParameters", dynlib: "60870.dll", cdecl.}
## *
##  \brief Returns the link layer parameters object of this master instance
##
##  \return the LinkLayerParameters instance used by this master
##

proc CS101_Master_getLinkLayerParameters*(self: CS101_Master): LinkLayerParameters {.
    importc: "CS101_Master_getLinkLayerParameters", dynlib: "60870.dll", cdecl.}
## *
##  \brief Is the channel ready to transmit an ASDU (only unbalanced mode)
##
##  The function will return true when the channel (slave) transmit buffer
##  is empty.
##
##  \param address slave address of the recipient
##
##  \return true, if channel ready to send a new ASDU, false otherwise
##

proc CS101_Master_isChannelReady*(self: CS101_Master; address: cint): bool {.
    importc: "CS101_Master_isChannelReady", dynlib: "60870.dll", cdecl.}
## *
##  \brief Manually send link layer test function.
##
##  Together with the IEC60870_LinkLayerStateChangedHandler this function can
##  be used to ensure that the link is working correctly
##

proc CS101_Master_sendLinkLayerTestFunction*(self: CS101_Master) {.
    importc: "CS101_Master_sendLinkLayerTestFunction", dynlib: "60870.dll", cdecl.}
## *
##  \brief send an interrogation command
##
##  \param cot cause of transmission
##  \param ca Common address of the slave/server
##  \param qoi qualifier of interrogation (20 for station interrogation)
##

proc CS101_Master_sendInterrogationCommand*(self: CS101_Master;
    cot: CS101_CauseOfTransmission; ca: cint; qoi: QualifierOfInterrogation) {.
    importc: "CS101_Master_sendInterrogationCommand", dynlib: "60870.dll", cdecl.}
## *
##  \brief send a counter interrogation command
##
##  \param cot cause of transmission
##  \param ca Common address of the slave/server
##  \param qcc
##

proc CS101_Master_sendCounterInterrogationCommand*(self: CS101_Master;
    cot: CS101_CauseOfTransmission; ca: cint; qcc: uint8_t) {.
    importc: "CS101_Master_sendCounterInterrogationCommand", dynlib: "60870.dll", cdecl.}
## *
##  \brief  Sends a read command (C_RD_NA_1 typeID: 102)
##
##  This will send a read command C_RC_NA_1 (102) to the slave/outstation. The COT is always REQUEST (5).
##  It is used to implement the cyclical polling of data application function.
##
##  \param ca Common address of the slave/server
##  \param ioa Information object address of the data point to read
##

proc CS101_Master_sendReadCommand*(self: CS101_Master; ca: cint; ioa: cint) {.
    importc: "CS101_Master_sendReadCommand", dynlib: "60870.dll", cdecl.}
## *
##  \brief Sends a clock synchronization command (C_CS_NA_1 typeID: 103)
##
##  \param ca Common address of the slave/server
##  \param time new system time for the slave/server
##

proc CS101_Master_sendClockSyncCommand*(self: CS101_Master; ca: cint;
                                       time: CP56Time2a) {.
    importc: "CS101_Master_sendClockSyncCommand", dynlib: "60870.dll", cdecl.}
## *
##  \brief Send a test command (C_TS_NA_1 typeID: 104)
##
##  Note: This command is not supported by IEC 60870-5-104
##
##  \param ca Common address of the slave/server
##

proc CS101_Master_sendTestCommand*(self: CS101_Master; ca: cint) {.
    importc: "CS101_Master_sendTestCommand", dynlib: "60870.dll", cdecl.}
## *
##  \brief Send a process command to the controlled (or other) station
##
##  \param cot the cause of transmission (should be ACTIVATION to select/execute or ACT_TERM to cancel the command)
##  \param ca the common address of the information object
##  \param command the command information object (e.g. SingleCommand or DoubleCommand)
##
##

proc CS101_Master_sendProcessCommand*(self: CS101_Master;
                                     cot: CS101_CauseOfTransmission; ca: cint;
                                     command: InformationObject) {.
    importc: "CS101_Master_sendProcessCommand", dynlib: "60870.dll", cdecl.}
## *
##  \brief Send a user specified ASDU
##
##  This function can be used for any kind of ASDU types. It can
##  also be used for monitoring messages in reverse direction.
##
##  NOTE: The ASDU is put into a message queue and will be sent whenever
##  the link layer state machine is able to transmit the ASDU. The ASDUs will
##  be sent in the order they are put into the queue.
##
##  \param asdu the ASDU to send
##

proc CS101_Master_sendASDU*(self: CS101_Master; asdu: CS101_ASDU) {.
    importc: "CS101_Master_sendASDU", dynlib: "60870.dll", cdecl.}
## *
##  \brief Register a callback handler for received ASDUs
##
##  \param handler user provided callback handler function
##  \param parameter user provided parameter that is passed to the callback handler
##

proc CS101_Master_setASDUReceivedHandler*(self: CS101_Master;
    handler: CS101_ASDUReceivedHandler; parameter: pointer) {.
    importc: "CS101_Master_setASDUReceivedHandler", dynlib: "60870.dll", cdecl.}
## *
##  \brief Set a callback handler for link layer state changes
##

proc CS101_Master_setLinkLayerStateChanged*(self: CS101_Master;
    handler: IEC60870_LinkLayerStateChangedHandler; parameter: pointer) {.
    importc: "CS101_Master_setLinkLayerStateChanged", dynlib: "60870.dll", cdecl.}
## *
##  \brief Set the raw message callback (called when a message is sent or received)
##
##  \param handler user provided callback handler function
##  \param parameter user provided parameter that is passed to the callback handler
##

proc CS101_Master_setRawMessageHandler*(self: CS101_Master;
                                       handler: IEC60870_RawMessageHandler;
                                       parameter: pointer) {.
    importc: "CS101_Master_setRawMessageHandler", dynlib: "60870.dll", cdecl.}
## *
##  \brief Set the idle timeout (only for balanced mode)
##
##  Time with no activity after which the connection is considered
##  in idle (LL_STATE_IDLE) state.
##
##  \param timeoutInMs the timeout value in milliseconds
##

proc CS101_Master_setIdleTimeout*(self: CS101_Master; timeoutInMs: cint) {.
    importc: "CS101_Master_setIdleTimeout", dynlib: "60870.dll", cdecl.}
## *
##  @}
##
## *
##  @}
##
