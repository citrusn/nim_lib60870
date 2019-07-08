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
  iec60870_master, iec60870_types, iec60870_common

## *
##  \file cs104_connection.h
##  \brief CS 104 master side definitions
##
## *
##  @addtogroup MASTER Master related functions
##
##  @{
##
## *
##  @defgroup CS104_MASTER CS 104 master related functions
##
##  @{
##
const 
    HOST_NAME_MAX = 64

type
  ##  .k =#  .sizeOfTypeId = 
  SentASDU* = object
    sentTime*: uint64_t ##  required for T1 timeout  
    seqNo*: cint

  sCS104_Connection* = object
    hostname*: array[HOST_NAME_MAX + 1, char]
    tcpPort*: cint
    parameters*: sCS104_APCIParameters
    alParameters*: sCS101_AppLayerParameters
    connectTimeoutInMs*: cint
    sMessage*: array[6, uint8_t]
    sentASDUs*: ptr SentASDU   ##  the k-buffer
    maxSentASDUs*: cint        ##  maximum number of ASDU to be sent without confirmation - parameter k
    oldestSentASDU*: cint      ##  index of oldest entry in k-buffer
    newestSentASDU*: cint      ##  index of newest entry in k-buffer
    ## #if (CONFIG_USE_SEMAPHORES == 1)
    sentASDUsLock*: Semaphore  
    ## #endif
    ## #if (CONFIG_USE_THREADS == 1)
    connectionHandlingThread*: Thread 
    ## #endif
    receiveCount*: cint
    sendCount*: cint
    unconfirmedReceivedIMessages*: cint 
    timeoutT2Trigger*: bool ##  timeout T2 handling
    lastConfirmationTime*: uint64_t
    nextT3Timeout*: uint64_t
    outstandingTestFCConMessages*: cint
    uMessageTimeout*: uint64_t
    socket*: Socket
    running*: bool
    failure*: bool
    close*: bool               
    ## #if (CONFIG_CS104_SUPPORT_TLS == 1)
    ##     TLSConfiguration tlsConfig;
    ##     TLSSocket tlsSocket;
    ## #endif
    receivedHandler*: CS101_ASDUReceivedHandler
    receivedHandlerParameter*: pointer
    connectionHandler*: CS104_ConnectionHandler
    connectionHandlerParameter*: pointer
    rawMessageHandler*: IEC60870_RawMessageHandler
    rawMessageHandlerParameter*: pointer

  CS104_Connection* = ptr sCS104_Connection
  
  CS104_ConnectionEvent* {.size: sizeof(cint).} = enum
    CS104_CONNECTION_OPENED = 0, CS104_CONNECTION_CLOSED = 1,
    CS104_CONNECTION_STARTDT_CON_RECEIVED = 2,
    CS104_CONNECTION_STOPDT_CON_RECEIVED = 3

  CS104_ConnectionHandler* = proc (parameter: pointer; connection: CS104_Connection;
                                  event: CS104_ConnectionEvent) {.cdecl.}
    ## *
    ##  \brief Handler that is called when the connection is established or closed
    ##
    ##  \param parameter user provided parameter
    ##  \param connection the connection object
    ##  \param event event type
    ##

## *
##  \brief Create a new connection object
##
##  \param hostname host name of IP address of the server to connect
##  \param tcpPort tcp port of the server to connect. If set to -1 use default port (2404)
##
##  \return the new connection object
##

proc CS104_Connection_create*(hostname: cstring; tcpPort: uint16_t): CS104_Connection {.
    importc: "CS104_Connection_create", cdecl.} #
## *
##  \brief Create a new secure connection object (uses TLS)
##
##  \param hostname host name of IP address of the server to connect
##  \param tcpPort tcp port of the server to connect. If set to -1 use default port (19998)
##  \param tlcConfig the TLS configuration (certificates, keys, and parameters)
##
##  \return the new connection object
##

#proc CS104_Connection_createSecure*(hostname: cstring; tcpPort: cint;
#                                   tlsConfig: TLSConfiguration): CS104_Connection {.
#    importc: "CS104_Connection_createSecure",  cdecl.}
## *
##  \brief Set the CS104 specific APCI parameters.
##
##  If not set the default parameters are used. This function must be called before the
##  CS104_Connection_connect function is called! If the function is called after the connect
##  the behavior is undefined.
##
##  \param self CS104_Connection instance
##

proc CS104_Connection_setAPCIParameters*(self: CS104_Connection;
                                        parameters: CS104_APCIParameters) {.
    importc: "CS104_Connection_setAPCIParameters",  cdecl.}
## *
##  \brief Get the currently used CS104 specific APCI parameters
##

proc CS104_Connection_getAPCIParameters*(self: CS104_Connection): CS104_APCIParameters {.
    importc: "CS104_Connection_getAPCIParameters",  cdecl.}
## *
##  \brief Set the CS101 application layer parameters
##
##  If not set the default parameters are used. This function must be called before the
##  CS104_Connection_connect function is called! If the function is called after the connect
##  the behavior is undefined.
##
##  \param self CS104_Connection instance
##  \param parameters the application layer parameters
##

proc CS104_Connection_setAppLayerParameters*(self: CS104_Connection;
    parameters: CS101_AppLayerParameters) {.
    importc: "CS104_Connection_setAppLayerParameters",  cdecl.}
## *
##  \brief Return the currently used application layer parameter
##
##  NOTE: The application layer parameters are required to create CS101_ASDU objects.
##
##  \param self CS104_Connection instance
##
##  \return the currently used CS101_AppLayerParameters object
##

proc CS104_Connection_getAppLayerParameters*(self: CS104_Connection): CS101_AppLayerParameters {.
    importc: "CS104_Connection_getAppLayerParameters",  cdecl.}
## *
##  \brief Sets the timeout for connecting to the server (in ms)
##
##  \param self
##  \param millies timeout value in ms
##

proc CS104_Connection_setConnectTimeout*(self: CS104_Connection; millies: cint) {.
    importc: "CS104_Connection_setConnectTimeout",  cdecl.}
## *
##  \brief non-blocking connect.
##
##  Invokes a connection establishment to the server and returns immediately.
##
##  \param self CS104_Connection instance
##

proc CS104_Connection_connectAsync*(self: CS104_Connection) {.
    importc: "CS104_Connection_connectAsync",  cdecl.}
## *
##  \brief blocking connect
##
##  Establishes a connection to a server. This function is blocking and will return
##  after the connection is established or the connect timeout elapsed.
##
##  \param self CS104_Connection instance
##  \return true when connected, false otherwise
##

proc CS104_Connection_connect*(self: CS104_Connection): bool {.
    importc: "CS104_Connection_connect", cdecl.} #, dynlib: "60870.dll"
## *
##  \brief start data transmission on this connection
##
##  After issuing this command the client (master) will receive spontaneous
##  (unsolicited) messages from the server (slave).
##

proc CS104_Connection_sendStartDT*(self: CS104_Connection) {.
    importc: "CS104_Connection_sendStartDT", cdecl.}
## *
##  \brief stop data transmission on this connection
##

proc CS104_Connection_sendStopDT*(self: CS104_Connection) {.
    importc: "CS104_Connection_sendStopDT", cdecl.} 
## *
##  \brief Check if the transmit (send) buffer is full. If true the next send command will fail.
##
##  The transmit buffer is full when the slave/server didn't confirm the last k sent messages.
##  In this case the next message can only be sent after the next confirmation (by I or S messages)
##  that frees part of the sent messages buffer.
##

proc CS104_Connection_isTransmitBufferFull*(self: CS104_Connection): bool {.
    importc: "CS104_Connection_isTransmitBufferFull",  cdecl.}
## *
##  \brief send an interrogation command
##
##  \param cot cause of transmission
##  \param ca Common address of the slave/server
##  \param qoi qualifier of interrogation (20 for station interrogation)
##
##  \return true if message was sent, false otherwise
##

proc CS104_Connection_sendInterrogationCommand*(self: CS104_Connection;
    cot: CS101_CauseOfTransmission; ca: cint; qoi: QualifierOfInterrogation): bool {.
    importc: "CS104_Connection_sendInterrogationCommand",  cdecl.}
## *
##  \brief send a counter interrogation command
##
##  \param cot cause of transmission
##  \param ca Common address of the slave/server
##  \param qcc
##
##  \return true if message was sent, false otherwise
##

proc CS104_Connection_sendCounterInterrogationCommand*(self: CS104_Connection;
    cot: CS101_CauseOfTransmission; ca: cint; qcc: uint8_t): bool {.
    importc: "CS104_Connection_sendCounterInterrogationCommand",  cdecl.}
## *
##  \brief  Sends a read command (C_RD_NA_1 typeID: 102)
##
##  This will send a read command C_RC_NA_1 (102) to the slave/outstation. The COT is always REQUEST (5).
##  It is used to implement the cyclical polling of data application function.
##
##  \param ca Common address of the slave/server
##  \param ioa Information object address of the data point to read
##
##  \return true if message was sent, false otherwise
##

proc CS104_Connection_sendReadCommand*(self: CS104_Connection; ca: cint; ioa: cint): bool {.
    importc: "CS104_Connection_sendReadCommand",  cdecl.}
## *
##  \brief Sends a clock synchronization command (C_CS_NA_1 typeID: 103)
##
##  \param ca Common address of the slave/server
##  \param newTime new system time for the slave/server
##
##  \return true if message was sent, false otherwise
##

proc CS104_Connection_sendClockSyncCommand*(self: CS104_Connection; ca: cint;
    newTime: CP56Time2a): bool {.importc: "CS104_Connection_sendClockSyncCommand",
                               cdecl.} #
## *
##  \brief Send a test command (C_TS_NA_1 typeID: 104)
##
##  Note: This command is not supported by IEC 60870-5-104
##
##  \param ca Common address of the slave/server
##
##  \return true if message was sent, false otherwise
##

proc CS104_Connection_sendTestCommand*(self: CS104_Connection; ca: cint): bool {.
    importc: "CS104_Connection_sendTestCommand", cdecl.}
## *
##  \brief Send a process command to the controlled (or other) station
##
##  \deprecated Use \ref CS104_Connection_sendProcessCommandEx instead
##
##  \param typeId the type ID of the command message to send or 0 to use the type ID of the information object
##  \param cot the cause of transmission (should be ACTIVATION to select/execute or ACT_TERM to cancel the command)
##  \param ca the common address of the information object
##  \param command the command information object (e.g. SingleCommand or DoubleCommand)
##
##  \return true if message was sent, false otherwise
##

proc CS104_Connection_sendProcessCommand*(self: CS104_Connection; typeId: TypeID;
    cot: CS101_CauseOfTransmission; ca: cint; command: InformationObject): bool {.
    importc: "CS104_Connection_sendProcessCommand", cdecl.} #
## *
##  \brief Send a process command to the controlled (or other) station
##
##  \param cot the cause of transmission (should be ACTIVATION to select/execute or ACT_TERM to cancel the command)
##  \param ca the common address of the information object
##  \param command the command information object (e.g. SingleCommand or DoubleCommand)
##
##  \return true if message was sent, false otherwise
##

proc CS104_Connection_sendProcessCommandEx*(self: CS104_Connection;
    cot: CS101_CauseOfTransmission; ca: cint; sc: InformationObject): bool {.
    importc: "CS104_Connection_sendProcessCommandEx",  cdecl.} #
## *
##  \brief Send a user specified ASDU
##
##  \param asdu the ASDU to send
##
##  \return true if message was sent, false otherwise
##

proc CS104_Connection_sendASDU*(self: CS104_Connection; asdu: CS101_ASDU): bool {.
    importc: "CS104_Connection_sendASDU",  cdecl.} 
## *
##  \brief Register a callback handler for received ASDUs
##
##  \param handler user provided callback handler function
##  \param parameter user provided parameter that is passed to the callback handler
##

proc CS104_Connection_setASDUReceivedHandler*(self: CS104_Connection;
    handler: CS101_ASDUReceivedHandler; parameter: pointer) {.
    importc: "CS104_Connection_setASDUReceivedHandler", cdecl.} #, dynlib: "60870.dll"


## *
##  \brief Set the connection event handler
##
##  \param handler user provided callback handler function
##  \param parameter user provided parameter that is passed to the callback handler
##

proc CS104_Connection_setConnectionHandler*(self: CS104_Connection;
    handler: CS104_ConnectionHandler; parameter: pointer) {.
    importc: "CS104_Connection_setConnectionHandler", cdecl.} #, dynlib: "60870.dll"
## *
##  \brief Set the raw message callback (called when a message is sent or received)
##
##  \param handler user provided callback handler function
##  \param parameter user provided parameter that is passed to the callback handler
##

proc CS104_Connection_setRawMessageHandler*(self: CS104_Connection;
    handler: IEC60870_RawMessageHandler; parameter: pointer) {.
    importc: "CS104_Connection_setRawMessageHandler", cdecl.} # 
## *
##  \brief Close the connection
##

proc CS104_Connection_close*(self: CS104_Connection) {.
    importc: "CS104_Connection_close", cdecl.} #, dynlib: "60870.dll"
## *
##  \brief Close the connection and free all related resources
##

proc CS104_Connection_destroy*(self: CS104_Connection) {.
    importc: "CS104_Connection_destroy", cdecl.} #, dynlib: "60870.dll"
## ! @}
## ! @}
