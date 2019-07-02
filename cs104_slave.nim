##
##   cs104_slave.h
##
##   Copyright 2017, 2018 MZ Automation GmbH
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
  iec60870_types, iec60870_slave, iec60870_common

## *
##  \file cs104_slave.h
##  \brief CS 104 slave side definitions
##
## *
##  @addtogroup SLAVE Slave related functions
##
##  @{
##
## *
##  @defgroup CS104_SLAVE CS 104 slave (TCP/IP server) related functions
##
##  @{
##
    
type
  CS104_ServerMode* {.size: sizeof(cint).} = enum
    CS104_MODE_SINGLE_REDUNDANCY_GROUP,
    CS104_MODE_CONNECTION_IS_REDUNDANCY_GROUP,
    CS104_MODE_MULTIPLE_REDUNDANCY_GROUPS

  eCS104_IPAddressType* {.size: sizeof(cint).} = enum
    IP_ADDRESS_TYPE_IPV4, IP_ADDRESS_TYPE_IPV6

type    
  FrameBuffer* {.bycopy.} = object
    msg*: array[256, uint8_t]
    msgSize*: cint
      
type
    SentASDUSlave* {.bycopy.} = object
        entryTime*: uint64_t       ##  required to identify message in server (low-priority) queue
        queueIndex*: cint          ##  -1 if ASDU is not from low-priority queue
                        ##  required for T1 timeout
        sentTime*: uint64_t
        seqNo*: cint
      
type
  QueueEntryState* = enum
    QUEUE_ENTRY_STATE_NOT_USED, QUEUE_ENTRY_STATE_WAITING_FOR_TRANSMISSION,
    QUEUE_ENTRY_STATE_SENT_BUT_NOT_CONFIRMED    
    
type
  ASDUQueueEntry* = ptr sASDUQueueEntry
  sASDUQueueEntry* {.bycopy.} = object
    entryTimestamp*: uint64_t
    asdu*: FrameBuffer
    state*: QueueEntryState
 

## **************************************************
##  HighPriorityASDUQueue
## *************************************************

type
    HighPriorityASDUQueue* = ptr sHighPriorityASDUQueue
    sHighPriorityASDUQueue* {.bycopy.} = object
      size*: cint
      entryCounter*: cint
      lastMsgIndex*: cint
      firstMsgIndex*: cint       ## #if (CONFIG_CS104_SLAVE_POOL == 1)
      asdus*: array[CONFIG_CS104_MESSAGE_QUEUE_HIGH_PRIO_SIZE, FrameBuffer] ## #else
                                                                         ##     FrameBuffer* asdus;
                                                                         ## #endif
                                                                         ## #if (CONFIG_USE_SEMAPHORES == 1)
      queueLock*: Semaphore      ## #endif  

## **************************************************
##  MessageQueue
## *************************************************

type
    MessageQueue* = ptr sMessageQueue
    sMessageQueue* {.bycopy.} = object
      size*: cint
      entryCounter*: cint
      lastMsgIndex*: cint
      firstMsgIndex*: cint       ## #if (CONFIG_CS104_SLAVE_POOL == 1)
      asdus*: array[CONFIG_CS104_MESSAGE_QUEUE_SIZE, sASDUQueueEntry] ## #else
                                                                   ##     ASDUQueueEntry asdus;
                                                                   ## #endif
   ## #if (CONFIG_USE_SEMAPHORES == 1)
      queueLock*: Semaphore      ## #endif
      
    CS104_RedundancyGroup* = ptr sCS104_RedundancyGroup
    sCS104_RedundancyGroup* {.bycopy.} = object
        name*: cstring             ## *< name of the group to be shown in debug messages, or NULL
        asduQueue*: MessageQueue   ## *< low priority ASDU queue and buffer
        connectionAsduQueue*: HighPriorityASDUQueue ## *< high priority ASDU queue
        allowedClients*: LinkedList

## *
##  \brief Connection request handler is called when a client tries to connect to the server.
##
##  \param parameter user provided parameter
##  \param ipAddress string containing IP address and TCP port number (e.g. "192.168.1.1:34521")
##
##  \return true to accept the connection request, false to deny
##

type
  CS104_ConnectionRequestHandler* = proc (parameter: pointer; ipAddress: cstring): bool {.stdcall.}
  
  CS104_PeerConnectionEvent* {.size: sizeof(cint).} = enum
    CS104_CON_EVENT_CONNECTION_OPENED = 0, 
    CS104_CON_EVENT_CONNECTION_CLOSED = 1,
    CS104_CON_EVENT_ACTIVATED = 2,
    CS104_CON_EVENT_DEACTIVATED = 3


## *
##  \brief Handler that is called when a peer connection is established or closed, or START_DT/STOP_DT is issued
##
##  \param parameter user provided parameter
##  \param connection the connection object
##  \param event event type
##

type
  CS104_ConnectionEventHandler* = proc (parameter: pointer;
                                     connection: IMasterConnection;
                                     event: CS104_PeerConnectionEvent) {.stdcall.}

## *
##  \brief Callback handler for sent and received messages
##
##  This callback handler provides access to the raw message buffer of received or sent
##  messages. It can be used for debugging purposes. Usually it is not used nor required
##  for applications.
##
##  \param parameter user provided parameter
##  \param connection the connection that sent or received the message
##  \param msg the message buffer
##  \param msgSize size of the message
##  \param sent indicates if the message was sent or received
##

type
  CS104_SlaveRawMessageHandler* = proc (parameter: pointer;
                                     connection: IMasterConnection;
                                     msg: var array[256, uint8_t]; msgSize: cint; send: bool) {.stdcall.}

## **************************************************
##  Slave
## *************************************************

type
    CS104_Slave* = ptr sCS104_Slave
    sCS104_Slave* {.bycopy.} = object
      interrogationHandler*: CS101_InterrogationHandler
      interrogationHandlerParameter*: pointer
      counterInterrogationHandler*: CS101_CounterInterrogationHandler
      counterInterrogationHandlerParameter*: pointer
      readHandler*: CS101_ReadHandler
      readHandlerParameter*: pointer
      clockSyncHandler*: CS101_ClockSynchronizationHandler
      clockSyncHandlerParameter*: pointer
      resetProcessHandler*: CS101_ResetProcessHandler
      resetProcessHandlerParameter*: pointer
      delayAcquisitionHandler*: CS101_DelayAcquisitionHandler
      delayAcquisitionHandlerParameter*: pointer
      asduHandler*: CS101_ASDUHandler
      asduHandlerParameter*: pointer
      connectionRequestHandler*: CS104_ConnectionRequestHandler
      connectionRequestHandlerParameter*: pointer
      connectionEventHandler*: CS104_ConnectionEventHandler
      connectionEventHandlerParameter*: pointer
      rawMessageHandler*: CS104_SlaveRawMessageHandler
      rawMessageHandlerParameter*: pointer 
      ## #if (CONFIG_CS104_SUPPORT_TLS == 1)
      ##     TLSConfiguration tlsConfig;
      ## #endif
      ## #if (CONFIG_CS104_SUPPORT_SERVER_MODE_SINGLE_REDUNDANCY_GROUP)
      asduQueue*: MessageQueue   ## *< low priority ASDU queue and buffer
      connectionAsduQueue*: HighPriorityASDUQueue ## *< high priority ASDU queue
      ## #endif
      maxLowPrioQueueSize*: cint
      maxHighPrioQueueSize*: cint
      openConnections*: cint     ## *< number of connected clients
      masterConnections*: array[CONFIG_CS104_MAX_CLIENT_CONNECTIONS,
                               MasterConnection] ## *< references to all MasterConnection objects
      ## #if (CONFIG_USE_SEMAPHORES == 1)
      openConnectionsLock*: Semaphore ## #endif
      ## #if (CONFIG_USE_THREADS == 1)
      isThreadlessMode*: bool    
      ## #endif
      maxOpenConnections*: cint  ## *< maximum accepted open client connections
      conParameters*: sCS104_APCIParameters
      alParameters*: sCS101_AppLayerParameters
      isStarting*: bool
      isRunning*: bool
      stopRunning*: bool
      tcpPort*: cint
      ## when (CONFIG_CS104_SUPPORT_SERVER_MODE_MULTIPLE_REDUNDANCY_GROUPS):
      redundancyGroups*: LinkedList
      serverMode*: CS104_ServerMode
      ## when (CONFIG_CS104_SLAVE_POOL == 1):
      localAddress*: array[60, char]
      #localAddress*: cstring
      listeningThread*: Thread
      serverSocket*: ServerSocket

    MasterConnection* = ptr sMasterConnection 
    sMasterConnection* = object
        socket*: Socket
        ##when (CONFIG_CS104_SUPPORT_TLS == 1):
        ## var tlsSocket*: TLSSocket
        iMasterConnection*: sIMasterConnection
        slave*: CS104_Slave
        isActive*: bool
        isRunning*: bool
        sendCount*: cint           ##  sent messages - sequence counter
        receiveCount*: cint        ##  received messages - sequence counter
        unconfirmedReceivedIMessages*: cint ##  number of unconfirmed messages received
                                        ##  timeout T2 handling
        lastConfirmationTime*: uint64_t ##  timestamp when the last confirmation message (for I messages) was sent
        timeoutT2Triggered*: bool
        nextT3Timeout*: uint64_t
        outstandingTestFRConMessages*: cint
        maxSentASDUs*: cint
        oldestSentASDU*: cint
        newestSentASDU*: cint      
        ## #if (CONFIG_CS104_SLAVE_POOL == 1)
        sentASDUs*: array[CONFIG_CS104_MAX_K_BUFFER_SIZE, SentASDUSlave] 
        ## #else
        ##     SentASDUSlave* sentASDUs;
        ## #endif
        ## #if (CONFIG_USE_SEMAPHORES == 1)
        sentASDUsLock*: Semaphore
        ## #endif
        handleSet*: HandleSet
        buffer*: array[260, uint8_t]
        lowPrioQueue*: MessageQueue
        highPrioQueue*: HighPriorityASDUQueue 
        ## #if (CONFIG_CS104_SUPPORT_SERVER_MODE_MULTIPLE_REDUNDANCY_GROUPS == 1)
        redundancyGroup*: CS104_RedundancyGroup 
        ## #endif
    

## *
##  \brief Create a new instance of a CS104 slave (server)
##
##  \param maxLowPrioQueueSize the maximum size of the event queue
##  \param maxHighPrioQueueSize the maximum size of the high-priority queue
##
##  \return the new slave instance
##

proc CS104_Slave_create*(maxLowPrioQueueSize: cint; maxHighPrioQueueSize: cint): CS104_Slave {.
    importc: "CS104_Slave_create", dynlib: "60870.dll".}
## *
##  \brief Create a new instance of a CS104 slave (server) with TLS enabled
##
##  \param maxLowPrioQueueSize the maximum size of the event queue
##  \param maxHighPrioQueueSize the maximum size of the high-priority queue
##  \param tlsConfig the TLS configuration object (containing configuration parameters, keys, and certificates)
##
##  \return the new slave instance
##

## proc CS104_Slave_createSecure*(maxLowPrioQueueSize: cint;
##                              maxHighPrioQueueSize: cint;
##                              tlsConfig: TLSConfiguration): CS104_Slave {.
##    importc: "CS104_Slave_createSecure", dynlib: "60870.dll".}

## *
##  \brief Set the local IP address to bind the server
##  use "0.0.0.0" to bind to all interfaces
##
##  \param self the slave instance
##  \param ipAddress the IP address string or hostname
##

proc CS104_Slave_setLocalAddress*(self: CS104_Slave; ipAddress: cstring) {.
    importc: "CS104_Slave_setLocalAddress", dynlib: "60870.dll".}
## *
##  \brief Set the local TCP port to bind the server
##
##  \param self the slave instance
##  \param tcpPort the TCP port to use (default is 2404)
##

proc CS104_Slave_setLocalPort*(self: CS104_Slave; tcpPort: cint) {.
    importc: "CS104_Slave_setLocalPort", dynlib: "60870.dll".}
## *
##  \brief Get the number of connected clients
##
##  \param self the slave instance
##

proc CS104_Slave_getOpenConnections*(self: CS104_Slave): cint {.
    importc: "CS104_Slave_getOpenConnections", dynlib: "60870.dll".}
## *
##  \brief set the maximum number of open client connections allowed
##
##  NOTE: the number cannot be larger than the static maximum defined in
##
##  \param self the slave instance
##  \param maxOpenConnections the maximum number of open client connections allowed
##

proc CS104_Slave_setMaxOpenConnections*(self: CS104_Slave; maxOpenConnections: cint) {.
    importc: "CS104_Slave_setMaxOpenConnections", dynlib: "60870.dll".}
## *
##  \brief Set one of the server modes
##
##  \param self the slave instance
##  \param serverMode the server mode (see \ref CS104_ServerMode) to use
##

proc CS104_Slave_setServerMode*(self: CS104_Slave; serverMode: CS104_ServerMode) {.
    importc: "CS104_Slave_setServerMode", dynlib: "60870.dll".}
## *
##  \brief Set the connection request handler
##
##  The connection request handler is called whenever a client/master is trying to connect.
##  This handler can be used to implement access control mechanisms as it allows the user to decide
##  if the new connection is accepted or not.
##
##  \param self the slave instance
##  \param handler the callback function to be used
##  \param parameter user provided context parameter that will be passed to the callback function (or NULL if not required).
##

proc CS104_Slave_setConnectionRequestHandler*(self: CS104_Slave;
    handler: CS104_ConnectionRequestHandler; parameter: pointer) {.
    importc: "CS104_Slave_setConnectionRequestHandler", dynlib: "60870.dll".}
## *
##  \brief Set the connection event handler
##
##  The connection request handler is called whenever a connection event happens. A connection event
##  can be when a client connects or disconnects, or when a START_DT or STOP_DT message is received.
##
##  \param self the slave instance
##  \param handler the callback function to be used
##  \param parameter user provided context parameter that will be passed to the callback function (or NULL if not required).
##

proc CS104_Slave_setConnectionEventHandler*(self: CS104_Slave;
    handler: CS104_ConnectionEventHandler; parameter: pointer) {.
    importc: "CS104_Slave_setConnectionEventHandler", dynlib: "60870.dll".}
proc CS104_Slave_setInterrogationHandler*(self: CS104_Slave;
    handler: CS101_InterrogationHandler; parameter: pointer) {.
    importc: "CS104_Slave_setInterrogationHandler", dynlib: "60870.dll".}
proc CS104_Slave_setCounterInterrogationHandler*(self: CS104_Slave;
    handler: CS101_CounterInterrogationHandler; parameter: pointer) {.
    importc: "CS104_Slave_setCounterInterrogationHandler", dynlib: "60870.dll".}
## *
##  \brief set handler for read request (C_RD_NA_1 - 102)
##

proc CS104_Slave_setReadHandler*(self: CS104_Slave; handler: CS101_ReadHandler;
                                parameter: pointer) {.
    importc: "CS104_Slave_setReadHandler", dynlib: "60870.dll".}
proc CS104_Slave_setASDUHandler*(self: CS104_Slave; handler: CS101_ASDUHandler;
                                parameter: pointer) {.
    importc: "CS104_Slave_setASDUHandler", dynlib: "60870.dll".}
proc CS104_Slave_setClockSyncHandler*(self: CS104_Slave; handler: CS101_ClockSynchronizationHandler;
                                     parameter: pointer) {.
    importc: "CS104_Slave_setClockSyncHandler", dynlib: "60870.dll".}
## *
##  \brief Set the raw message callback (called when a message is sent or received)
##
##  \param handler user provided callback handler function
##  \param parameter user provided parameter that is passed to the callback handler
##

proc CS104_Slave_setRawMessageHandler*(self: CS104_Slave;
                                      handler: CS104_SlaveRawMessageHandler;
                                      parameter: pointer) {.
    importc: "CS104_Slave_setRawMessageHandler", dynlib: "60870.dll".}
## *
##  \brief Get the APCI parameters instance. APCI parameters are CS 104 specific parameters.
##

proc CS104_Slave_getConnectionParameters*(self: CS104_Slave): CS104_APCIParameters {.
    importc: "CS104_Slave_getConnectionParameters", dynlib: "60870.dll".}
## *
##  \brief Get the application layer parameters instance..
##

proc CS104_Slave_getAppLayerParameters*(self: CS104_Slave): CS101_AppLayerParameters {.
    importc: "CS104_Slave_getAppLayerParameters", dynlib: "60870.dll".}
## *
##  \brief State the CS 104 slave. The slave (server) will listen on the configured TCP/IP port
##
##  \param self CS104_Slave instance
##

proc CS104_Slave_start*(self: CS104_Slave) {.importc: "CS104_Slave_start",
    dynlib: "60870.dll".}
proc CS104_Slave_isRunning*(self: CS104_Slave): bool {.
    importc: "CS104_Slave_isRunning", dynlib: "60870.dll".}
## *
##  \brief Stop the server.
##
##  Stop listening to incoming TCP/IP connections and close all open connections.
##  Event buffers will be deactivated.
##

proc CS104_Slave_stop*(self: CS104_Slave) {.importc: "CS104_Slave_stop",
    dynlib: "60870.dll".}
## *
##  \brief Start the slave (server) in non-threaded mode.
##
##  Start listening to incoming TCP/IP connections.
##
##  NOTE: Server should only be started after all configuration is done.
##

proc CS104_Slave_startThreadless*(self: CS104_Slave) {.
    importc: "CS104_Slave_startThreadless", dynlib: "60870.dll".}
## *
##  \brief Stop the server in non-threaded mode
##
##  Stop listening to incoming TCP/IP connections and close all open connections.
##  Event buffers will be deactivated.
##

proc CS104_Slave_stopThreadless*(self: CS104_Slave) {.
    importc: "CS104_Slave_stopThreadless", dynlib: "60870.dll".}
## *
##  \brief Protocol stack tick function for non-threaded mode.
##
##  Handle incoming connection requests and messages, send buffered events, and
##  handle periodic tasks.
##
##  NOTE: This function has to be called periodically by the application.
##

proc CS104_Slave_tick*(self: CS104_Slave) {.importc: "CS104_Slave_tick",
    dynlib: "60870.dll".}
## *
##  \brief Add an ASDU to the low-priority queue of the slave (use for periodic and spontaneous messages)
##
##  \param asdu the ASDU to add
##

proc CS104_Slave_enqueueASDU*(self: CS104_Slave; asdu: CS101_ASDU) {.
    importc: "CS104_Slave_enqueueASDU", dynlib: "60870.dll".}
## *
##  \brief Add a new redundancy group to the server.
##
##  A redundancy group is a group of clients that share the same event queue. This function can
##  only be used with server mode CS104_MODE_MULTIPLE_REDUNDANCY_GROUPS.
##
##  NOTE: Has to be called before the server is started!
##
##  \param redundancyGroup the new redundancy group
##

proc CS104_Slave_addRedundancyGroup*(self: CS104_Slave;
                                    redundancyGroup: CS104_RedundancyGroup) {.
    importc: "CS104_Slave_addRedundancyGroup", dynlib: "60870.dll".}
## *
##  \brief Delete the slave instance. Release all resources.
##

proc CS104_Slave_destroy*(self: CS104_Slave) {.importc: "CS104_Slave_destroy",
    dynlib: "60870.dll".}
## *
##  \brief Create a new redundancy group.
##
##  A redundancy group is a group of clients that share the same event queue. Redundancy groups can
##  only be used with server mode CS104_MODE_MULTIPLE_REDUNDANCY_GROUPS.
##

proc CS104_RedundancyGroup_create*(name: cstring): CS104_RedundancyGroup {.
    importc: "CS104_RedundancyGroup_create", dynlib: "60870.dll".}
## *
##  \brief Add an allowed client to the redundancy group
##
##  \param ipAddress the IP address of the client as C string (can be IPv4 or IPv6 address).
##

proc CS104_RedundancyGroup_addAllowedClient*(self: CS104_RedundancyGroup;
    ipAddress: cstring) {.importc: "CS104_RedundancyGroup_addAllowedClient",
                        dynlib: "60870.dll".}
## *
##  \brief Add an allowed client to the redundancy group
##
##  \param ipAddress the IP address as byte buffer (4 byte for IPv4, 16 byte for IPv6)
##  \param addressType type of the IP address (either IP_ADDRESS_TYPE_IPV4 or IP_ADDRESS_TYPE_IPV6)
##

proc CS104_RedundancyGroup_addAllowedClientEx*(self: CS104_RedundancyGroup;
    ipAddress: ptr uint8_t; addressType: eCS104_IPAddressType) {.
    importc: "CS104_RedundancyGroup_addAllowedClientEx", dynlib: "60870.dll".}
## *
##  \brief Destroy the instance and release all resources.
##
##  NOTE: This function will be called by \ref CS104_Slave_destroy. After using
##  the \ref CS104_Slave_addRedundancyGroup function the redundancy group object must
##  not be destroyed manually.
##

proc CS104_RedundancyGroup_destroy*(self: CS104_RedundancyGroup) {.
    importc: "CS104_RedundancyGroup_destroy", dynlib: "60870.dll".}
## *
##  @}
##
## *
##  @}
##

