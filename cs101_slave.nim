##
##   cs101_slave.h
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
##  \file cs101_slave.h
##  \brief Functions for CS101_Slave ADT.
##  Can be used to implement a balanced or unbalanced CS 101 slave.
##

import
  hal_serial, iec60870_common, iec60870_slave, link_layer_parameters

## *
##  @defgroup SLAVE Slave related functions
##
##  @{
##
## *
##  @defgroup CS101_SLAVE CS 101 slave (serial link layer) related functions
##
##  @{
##
## *
##  \brief CS101_Slave type
##

type
  CS101_Slave* = ptr sCS101_Slave

## *
##  \brief Create a new balanced or unbalanced CS101 slave
##
##  The CS101_Slave instance has two separate data queues for class 1 and class 2 data.
##
##  \param serialPort the serial port to be used
##  \param llParameters the link layer parameters to be used
##  \param alParameters the CS101 application layer parameters
##  \param linkLayerMode the link layer mode (either BALANCED or UNBALANCED)
##
##  \return the new slave instance
##

proc CS101_Slave_create*(serialPort: SerialPort; llParameters: LinkLayerParameters;
                        alParameters: CS101_AppLayerParameters;
                        linkLayerMode: IEC60870_LinkLayerMode): CS101_Slave {.
    importc: "CS101_Slave_create",  cdecl.}
## *
##  \brief Destroy the slave instance and cleanup all resources
##
##  \param self CS101_Slave instance
##

proc CS101_Slave_destroy*(self: CS101_Slave) {.importc: "CS101_Slave_destroy",
     cdecl.}
## *
##  \brief Set the value of the DIR bit when sending messages (only balanced mode)
##
##  NOTE: Default value is false (controlled station). In the case of two equivalent stations
##  the value is defined by agreement.
##
##  \param dir the value of the DIR bit when sending messages
##

proc CS101_Slave_setDIR*(self: CS101_Slave; dir: bool) {.
    importc: "CS101_Slave_setDIR",  cdecl.}
## *
##  \brief Set the idle timeout
##
##  Time with no activity after which the connection is considered
##  in idle (LL_STATE_IDLE) state.
##
##  \param timeoutInMs the timeout value in milliseconds
##

proc CS101_Slave_setIdleTimeout*(self: CS101_Slave; timeoutInMs: cint) {.
    importc: "CS101_Slave_setIdleTimeout",  cdecl.}
## *
##  \brief Set a callback handler for link layer state changes
##

proc CS101_Slave_setLinkLayerStateChanged*(self: CS101_Slave;
    handler: IEC60870_LinkLayerStateChangedHandler; parameter: pointer) {.
    importc: "CS101_Slave_setLinkLayerStateChanged",  cdecl.}
## *
##  \brief Set the local link layer address
##
##  \param self CS101_Slave instance
##  \param address the link layer address (can be either 1 or 2 byte wide).
##

proc CS101_Slave_setLinkLayerAddress*(self: CS101_Slave; address: cint) {.
    importc: "CS101_Slave_setLinkLayerAddress",  cdecl.}
## *
##  \brief Set the link layer address of the remote station
##
##  \param self CS101_Slave instance
##  \param address the link layer address (can be either 1 or 2 byte wide).
##

proc CS101_Slave_setLinkLayerAddressOtherStation*(self: CS101_Slave; address: cint) {.
    importc: "CS101_Slave_setLinkLayerAddressOtherStation",  cdecl.}
## *
##  \brief Check if the class 1 ASDU is full
##
##  \param self CS101_Slave instance
##
##  \return true when the queue is full, false otherwise
##

proc CS101_Slave_isClass1QueueFull*(self: CS101_Slave): bool {.
    importc: "CS101_Slave_isClass1QueueFull",  cdecl.}
## *
##  \brief Enqueue an ASDU into the class 1 data queue
##
##  \param self CS101_Slave instance
##  \param asdu the ASDU instance to enqueue
##

proc CS101_Slave_enqueueUserDataClass1*(self: CS101_Slave; asdu: CS101_ASDU) {.
    importc: "CS101_Slave_enqueueUserDataClass1",  cdecl.}
## *
##  \brief Check if the class 2 ASDU is full
##
##  \param self CS101_Slave instance
##
##  \return true when the queue is full, false otherwise
##

proc CS101_Slave_isClass2QueueFull*(self: CS101_Slave): bool {.
    importc: "CS101_Slave_isClass2QueueFull",  cdecl.}
## *
##  \brief Enqueue an ASDU into the class 2 data queue
##
##  \param self CS101_Slave instance
##  \param asdu the ASDU instance to enqueue
##

proc CS101_Slave_enqueueUserDataClass2*(self: CS101_Slave; asdu: CS101_ASDU) {.
    importc: "CS101_Slave_enqueueUserDataClass2",  cdecl.}
## *
##  \brief Remove all ASDUs from the class 1/2 data queues
##
##  \param self CS101_Slave instance
##

proc CS101_Slave_flushQueues*(self: CS101_Slave) {.
    importc: "CS101_Slave_flushQueues",  cdecl.}
## *
##  \brief Receive a new message and run the link layer state machines
##
##  NOTE: Has to be called frequently, when the start/stop functions are
##  not used. Otherwise it will be called by the background thread.
##
##  \param self CS101_Slave instance
##

proc CS101_Slave_run*(self: CS101_Slave) {.importc: "CS101_Slave_run",
                                         cdecl.}
## *
##  \brief Start a background thread that handles the link layer connections
##
##  NOTE: This requires threads. If you don't want to use a separate thread
##  for the slave instance you have to call the \ref CS101_Slave_run function
##  periodically.
##
##  \param self CS101_Slave instance
##

proc CS101_Slave_start*(self: CS101_Slave) {.importc: "CS101_Slave_start",
     cdecl.}
## *
##  \brief Stops the background thread that handles the link layer connections
##
##  \param self CS101_Slave instance
##

proc CS101_Slave_stop*(self: CS101_Slave) {.importc: "CS101_Slave_stop",
     cdecl.}
## *
##  \brief Returns the application layer parameters object of this slave instance
##
##  \param self CS101_Slave instance
##
##  \return the CS101_AppLayerParameters instance used by this slave
##

proc CS101_Slave_getAppLayerParameters*(self: CS101_Slave): CS101_AppLayerParameters {.
    importc: "CS101_Slave_getAppLayerParameters",  cdecl.}
## *
##  \brief Returns the link layer parameters object of this slave instance
##
##  \param self CS101_Slave instance
##
##  \return the LinkLayerParameters instance used by this slave
##

proc CS101_Slave_getLinkLayerParameters*(self: CS101_Slave): LinkLayerParameters {.
    importc: "CS101_Slave_getLinkLayerParameters",  cdecl.}
## *
##  \brief Set the handler for the reset CU (communication unit) message
##
##  \param handler the callback handler function
##  \param parameter user provided parameter to be passed to the callback handler
##

proc CS101_Slave_setResetCUHandler*(self: CS101_Slave;
                                   handler: CS101_ResetCUHandler;
                                   parameter: pointer) {.
    importc: "CS101_Slave_setResetCUHandler",  cdecl.}
## *
##  \brief Set the handler for the general interrogation message
##
##  \param handler the callback handler function
##  \param parameter user provided parameter to be passed to the callback handler
##

proc CS101_Slave_setInterrogationHandler*(self: CS101_Slave;
    handler: CS101_InterrogationHandler; parameter: pointer) {.
    importc: "CS101_Slave_setInterrogationHandler",  cdecl.}
## *
##  \brief Set the handler for the counter interrogation message
##
##  \param handler the callback handler function
##  \param parameter user provided parameter to be passed to the callback handler
##

proc CS101_Slave_setCounterInterrogationHandler*(self: CS101_Slave;
    handler: CS101_CounterInterrogationHandler; parameter: pointer) {.
    importc: "CS101_Slave_setCounterInterrogationHandler",  cdecl.}
## *
##  \brief Set the handler for the read message
##
##  \param handler the callback handler function
##  \param parameter user provided parameter to be passed to the callback handler
##

proc CS101_Slave_setReadHandler*(self: CS101_Slave; handler: CS101_ReadHandler;
                                parameter: pointer) {.
    importc: "CS101_Slave_setReadHandler",  cdecl.}
## *
##  \brief Set the handler for the clock synchronization message
##
##  \param handler the callback handler function
##  \param parameter user provided parameter to be passed to the callback handler
##

proc CS101_Slave_setClockSyncHandler*(self: CS101_Slave; handler: CS101_ClockSynchronizationHandler;
                                     parameter: pointer) {.
    importc: "CS101_Slave_setClockSyncHandler",  cdecl.}
## *
##  \brief Set the handler for the reset process message
##
##  \param handler the callback handler function
##  \param parameter user provided parameter to be passed to the callback handler
##

proc CS101_Slave_setResetProcessHandler*(self: CS101_Slave;
                                        handler: CS101_ResetProcessHandler;
                                        parameter: pointer) {.
    importc: "CS101_Slave_setResetProcessHandler",  cdecl.}
## *
##  \brief Set the handler for the delay acquisition message
##
##  \param handler the callback handler function
##  \param parameter user provided parameter to be passed to the callback handler
##

proc CS101_Slave_setDelayAcquisitionHandler*(self: CS101_Slave;
    handler: CS101_DelayAcquisitionHandler; parameter: pointer) {.
    importc: "CS101_Slave_setDelayAcquisitionHandler",  cdecl.}
## *
##  \brief Set the handler for a received ASDU
##
##  NOTE: This a generic handler that will only be called when the ASDU has not been handled by
##  one of the other callback handlers.
##
##  \param handler the callback handler function
##  \param parameter user provided parameter to be passed to the callback handler
##

proc CS101_Slave_setASDUHandler*(self: CS101_Slave; handler: CS101_ASDUHandler;
                                parameter: pointer) {.
    importc: "CS101_Slave_setASDUHandler",  cdecl.}
## *
##  \brief Set the raw message callback (called when a message is sent or received)
##
##  \param handler user provided callback handler function
##  \param parameter user provided parameter that is passed to the callback handler
##

proc CS101_Slave_setRawMessageHandler*(self: CS101_Slave;
                                      handler: IEC60870_RawMessageHandler;
                                      parameter: pointer) {.
    importc: "CS101_Slave_setRawMessageHandler",  cdecl.}
## *
##  @}
##
## *
##  @}
##
