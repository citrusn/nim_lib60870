##
##   Copyright 2016-2018 MZ Automation GmbH
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
  iec60870_types, iec60870_common #, tls_config

## *
##  \file iec60870_slave.h
##  \brief Common slave side definitions for IEC 60870-5-101/104
##  These types are used by CS101/CS104 slaves
##
## *
##  @addtogroup SLAVE Slave related functions
##
##  @{
##
## *
##  @defgroup COMMON_SLAVE Common slave related functions and interfaces
##
##  These definitions are used by both the CS 101 and CS 104 slave implementations.
##
##  @{
##
## *
##  @defgroup IMASTER_CONNECTION IMasterConnection interface
##
##  @{
##
## *
##  \brief Interface to send messages to the master (used by slave)
##

type
  IMasterConnection* = ptr sIMasterConnection
  sIMasterConnection*{.bycopy.} = object
    sendASDU*: proc (self: IMasterConnection; asdu: CS101_ASDU)
    sendACT_CON*: proc (self: IMasterConnection; asdu: CS101_ASDU; negative: bool)
    sendACT_TERM*: proc (self: IMasterConnection; asdu: CS101_ASDU)
    close*: proc (self: IMasterConnection)
    getPeerAddress*: proc (self: IMasterConnection; addrBuf: cstring;
                         addrBufSize: cint): cint
    getApplicationLayerParameters*: proc (self: IMasterConnection): CS101_AppLayerParameters
    `object`*: pointer


## *
##  \brief Send an ASDU to the client/master
##
##  The ASDU will be released by this function after the message is sent.
##  You should not call the ASDU_destroy function for the given ASDU after
##  calling this function!
##
##  \param self the connection object (this is usually received as a parameter of a callback function)
##  \param asdu the ASDU to send to the client/master
##

proc IMasterConnection_sendASDU*(self: IMasterConnection; asdu: CS101_ASDU) {.
    importc: "IMasterConnection_sendASDU", dynlib: "60870.dll", cdecl.}
## *
##  \brief Send an ACT_CON ASDU to the client/master
##
##  ACT_CON is used for a command confirmation (positive or negative)
##
##  \param asdu the ASDU to send to the client/master
##  \param negative value of the negative flag
##

proc IMasterConnection_sendACT_CON*(self: IMasterConnection; asdu: CS101_ASDU;
                                   negative: bool) {.
    importc: "IMasterConnection_sendACT_CON", dynlib: "60870.dll", cdecl.}
## *
##  \brief Send an ACT_TERM ASDU to the client/master
##
##  ACT_TERM is used to indicate that the command execution is complete.
##
##  \param asdu the ASDU to send to the client/master
##

proc IMasterConnection_sendACT_TERM*(self: IMasterConnection; asdu: CS101_ASDU) {.
    importc: "IMasterConnection_sendACT_TERM", dynlib: "60870.dll", cdecl.}
## *
##  \brief Get the peer address of the master (only for CS 104)
##
##  \param addrBuf buffer where to store the IP address as string
##  \param addrBufSize the size of the buffer where to store the IP address
##
##  \return the number of bytes written to the buffer, 0 if function not supported
##

proc IMasterConnection_getPeerAddress*(self: IMasterConnection; addrBuf: cstring;
                                      addrBufSize: cint): cint {.
    importc: "IMasterConnection_getPeerAddress", dynlib: "60870.dll", cdecl.}
## *
##  \brief Close the master connection (only for CS 104)
##
##  Allows the slave to actively close a master connection (e.g. when some exception occurs)
##

proc IMasterConnection_close*(self: IMasterConnection) {.
    importc: "IMasterConnection_close", dynlib: "60870.dll", cdecl.}
## *
##  \brief Get the application layer parameters used by this connection
##

proc IMasterConnection_getApplicationLayerParameters*(self: IMasterConnection): CS101_AppLayerParameters {.
    importc: "IMasterConnection_getApplicationLayerParameters", dynlib: "60870.dll", cdecl.}
## *
##  @}
##
## *
##  @defgroup CALLBACK_HANDLERS Slave callback handlers
##
##  Callback handlers to handle events in the slave
##
## *
##  \brief Handler will be called when a link layer reset CU (communication unit) message is received
##
##  NOTE: Can be used to empty the ASDU queues
##
##  \param parameter a user provided parameter
##

type
  CS101_ResetCUHandler* = proc (parameter: pointer) {.cdecl.}

## *
##  \brief Handler for interrogation command (C_IC_NA_1 - 100).
##

type
  CS101_InterrogationHandler* = proc (parameter: pointer;
                                   connection: IMasterConnection;
                                   asdu: CS101_ASDU; qoi: uint8_t): bool  {.cdecl.}

## *
##  \brief Handler for counter interrogation command (C_CI_NA_1 - 101).
##

type
  CS101_CounterInterrogationHandler* = proc (parameter: pointer;
      connection: IMasterConnection; asdu: CS101_ASDU; qcc: QualifierOfCIC): bool  {.cdecl.}

## *
##  \brief Handler for read command (C_RD_NA_1 - 102)
##

type
  CS101_ReadHandler* = proc (parameter: pointer; connection: IMasterConnection;
                          asdu: CS101_ASDU; ioa: cint): bool  {.cdecl.}

## *
##  \brief Handler for clock synchronization command (C_CS_NA_1 - 103)
##
##  This handler will be called whenever a time synchronization command is received.
##  NOTE: The \ref CS104_Slave instance will automatically send an ACT-CON message for the received time sync command.
##
##  \param[in] parameter user provided parameter
##  \param[in] connection represents the (TCP) connection that received the time sync command
##  \param[in] asdu the received ASDU
##  \param[in,out] the time received with the time sync message. The user can update this time for the ACT-CON message
##
##  \return true when time synchronization has been successful, false otherwise
##

type
  CS101_ClockSynchronizationHandler* = proc (parameter: pointer;
      connection: IMasterConnection; asdu: CS101_ASDU; newTime: CP56Time2a): bool  {.cdecl.}

## *
##  \brief Handler for reset process command (C_RP_NA_1 - 105)
##

type
  CS101_ResetProcessHandler* = proc (parameter: pointer;
                                  connection: IMasterConnection; asdu: CS101_ASDU;
                                  qrp: uint8_t): bool  {.cdecl.}

## *
##  \brief Handler for delay acquisition command (C_CD_NA:1 - 106)
##

type
  CS101_DelayAcquisitionHandler* = proc (parameter: pointer;
                                      connection: IMasterConnection;
                                      asdu: CS101_ASDU; delayTime: CP16Time2a): bool  {.cdecl.}

## *
##  \brief Handler for ASDUs that are not handled by other handlers (default handler)
##

type
  CS101_ASDUHandler* = proc (parameter: pointer; connection: IMasterConnection;
                          asdu: CS101_ASDU): bool  {.cdecl.}

## *
##  @}
##
## *
##  @}
##
## *
##  @}
##
