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
  cs104_connection, cs104_frame, hal_thread, hal_socket, hal_time, lib_memory,
  apl_types_internal, information_objects_internal, lib60870_internal,
  cs101_asdu_internal

var defaultAPCIParameters*: sCS104_APCIParameters = [12, 8, 10, 15, 10, 20]

var defaultAppLayerParameters*: sCS101_AppLayerParameters = [1, 1, 2, 0, 2, 3, 249]

type                          ##  .k =
##  .sizeOfTypeId =
  SentASDU* {.bycopy.} = object
    sentTime*: uint64_t        ##  required for T1 timeout
    seqNo*: cint

  sCS104_Connection* {.bycopy.} = object
    hostname*: array[HOST_NAME_MAX + 1, char]
    tcpPort*: cint
    parameters*: sCS104_APCIParameters
    alParameters*: sCS101_AppLayerParameters
    connectTimeoutInMs*: cint
    sMessage*: array[6, uint8_t]
    sentASDUs*: ptr SentASDU    ##  the k-buffer
    maxSentASDUs*: cint        ##  maximum number of ASDU to be sent without confirmation - parameter k
    oldestSentASDU*: cint      ##  index of oldest entry in k-buffer
    newestSentASDU*: cint      ##  index of newest entry in k-buffer
                        ## #if (CONFIG_USE_SEMAPHORES == 1)
    sentASDUsLock*: Semaphore  ## #endif
                            ## #if (CONFIG_USE_THREADS == 1)
    connectionHandlingThread*: Thread ## #endif
    receiveCount*: cint
    sendCount*: cint
    unconfirmedReceivedIMessages*: cint ##  timeout T2 handling
    timeoutT2Trigger*: bool
    lastConfirmationTime*: uint64_t
    nextT3Timeout*: uint64_t
    outstandingTestFCConMessages*: cint
    uMessageTimeout*: uint64_t
    socket*: Socket
    running*: bool
    failure*: bool
    close*: bool               ## #if (CONFIG_CS104_SUPPORT_TLS == 1)
               ##     TLSConfiguration tlsConfig;
               ##     TLSSocket tlsSocket;
               ## #endif
    receivedHandler*: CS101_ASDUReceivedHandler
    receivedHandlerParameter*: pointer
    connectionHandler*: CS104_ConnectionHandler
    connectionHandlerParameter*: pointer
    rawMessageHandler*: IEC60870_RawMessageHandler
    rawMessageHandlerParameter*: pointer


var STARTDT_ACT_MSG*: ptr uint8_t = [0x00000000, 0x00000000, 0x00000000, 0x00000000,
                                0x00000000, 0x00000000]

const
  STARTDT_ACT_MSG_SIZE* = 6

var TESTFR_ACT_MSG*: ptr uint8_t = [0x00000000, 0x00000000, 0x00000000, 0x00000000,
                               0x00000000, 0x00000000]

const
  TESTFR_ACT_MSG_SIZE* = 6

var TESTFR_CON_MSG*: ptr uint8_t = [0x00000000, 0x00000000, 0x00000000, 0x00000000,
                               0x00000000, 0x00000000]

const
  TESTFR_CON_MSG_SIZE* = 6

var STOPDT_ACT_MSG*: ptr uint8_t = [0x00000000, 0x00000000, 0x00000000, 0x00000000,
                               0x00000000, 0x00000000]

const
  STOPDT_ACT_MSG_SIZE* = 6

var STARTDT_CON_MSG*: ptr uint8_t = [0x00000000, 0x00000000, 0x00000000, 0x00000000,
                                0x00000000, 0x00000000]

const
  STARTDT_CON_MSG_SIZE* = 6

proc writeToSocket*(self: CS104_Connection; buf: ptr uint8_t; size: cint): cint =
  if self.rawMessageHandler:
    self.rawMessageHandler(self.rawMessageHandlerParameter, buf, size, true)
  when (CONFIG_CS104_SUPPORT_TLS == 1):
    if self.tlsSocket:
      return TLSSocket_write(self.tlsSocket, buf, size)
    else:
      return Socket_write(self.socket, buf, size)
  else:
    return Socket_write(self.socket, buf, size)

proc prepareSMessage*(msg: ptr uint8_t) =
  msg[0] = 0x00000000
  msg[1] = 0x00000000
  msg[2] = 0x00000000
  msg[3] = 0x00000000

proc sendSMessage*(self: CS104_Connection) =
  var msg: ptr uint8_t = self.sMessage
  msg[4] = (uint8_t)((self.receiveCount mod 128) * 2)
  msg[5] = (uint8_t)(self.receiveCount div 128)
  writeToSocket(self, msg, 6)

proc sendIMessage*(self: CS104_Connection; frame: Frame): cint =
  T104Frame_prepareToSend(cast[T104Frame](frame), self.sendCount,
                          self.receiveCount)
  writeToSocket(self, T104Frame_getBuffer(frame), T104Frame_getMsgSize(frame))
  self.sendCount = (self.sendCount + 1) mod 32768
  self.unconfirmedReceivedIMessages = false
  self.timeoutT2Trigger = false
  return self.sendCount

proc createConnection*(hostname: cstring; tcpPort: cint): CS104_Connection =
  var self: CS104_Connection = cast[CS104_Connection](GLOBAL_MALLOC(
      sizeof(sCS104_Connection)))
  if self != nil:
    strncpy(self.hostname, hostname, HOST_NAME_MAX)
    self.tcpPort = tcpPort
    self.parameters = defaultAPCIParameters
    self.alParameters = defaultAppLayerParameters
    self.receivedHandler = nil
    self.receivedHandlerParameter = nil
    self.connectionHandler = nil
    self.connectionHandlerParameter = nil
    self.rawMessageHandler = nil
    self.rawMessageHandlerParameter = nil
    when (CONFIG_USE_SEMAPHORES == 1):
      self.sentASDUsLock = Semaphore_create(1)
    when (CONFIG_USE_THREADS == 1):
      self.connectionHandlingThread = nil
    when (CONFIG_CS104_SUPPORT_TLS == 1):
      self.tlsConfig = nil
      self.tlsSocket = nil
    self.sentASDUs = nil
    prepareSMessage(self.sMessage)
  return self

proc CS104_Connection_create*(hostname: cstring; tcpPort: cint): CS104_Connection =
  if tcpPort == -1:
    tcpPort = IEC_60870_5_104_DEFAULT_PORT
  return createConnection(hostname, tcpPort)

when (CONFIG_CS104_SUPPORT_TLS == 1):
  proc CS104_Connection_createSecure*(hostname: cstring; tcpPort: cint;
                                     tlsConfig: TLSConfiguration): CS104_Connection =
    if tcpPort == -1:
      tcpPort = IEC_60870_5_104_DEFAULT_TLS_PORT
    var self: CS104_Connection = createConnection(hostname, tcpPort)
    if self != nil:
      self.tlsConfig = tlsConfig
      TLSConfiguration_setClientMode(tlsConfig)
    return self

proc resetT3Timeout*(self: CS104_Connection) =
  self.nextT3Timeout = Hal_getTimeInMs() + (self.parameters.t3 * 1000)

proc resetConnection*(self: CS104_Connection) =
  self.connectTimeoutInMs = self.parameters.t0 * 1000
  self.running = false
  self.failure = false
  self.close = false
  self.receiveCount = 0
  self.sendCount = 0
  self.unconfirmedReceivedIMessages = 0
  self.lastConfirmationTime = 0x0000000000000000'i64
  self.timeoutT2Trigger = false
  self.oldestSentASDU = -1
  self.newestSentASDU = -1
  if self.sentASDUs == nil:
    self.maxSentASDUs = self.parameters.k
    self.sentASDUs = cast[ptr SentASDU](GLOBAL_MALLOC(
        sizeof((SentASDU) * self.maxSentASDUs)))
  self.outstandingTestFCConMessages = 0
  self.uMessageTimeout = 0
  resetT3Timeout(self)

proc checkSequenceNumber*(self: CS104_Connection; seqNo: cint): bool =
  when (CONFIG_USE_SEMAPHORES == 1):
    Semaphore_wait(self.sentASDUsLock)
  ##  check if received sequence number is valid
  var seqNoIsValid: bool = false
  var counterOverflowDetected: bool = false
  var oldestValidSeqNo: cint = -1
  if self.oldestSentASDU == -1:
    ##  if k-Buffer is empty
    if seqNo == self.sendCount:
      seqNoIsValid = true
  else:
    ##  Two cases are required to reflect sequence number overflow
    if self.sentASDUs[self.oldestSentASDU].seqNo <=
        self.sentASDUs[self.newestSentASDU].seqNo:
      if (seqNo >= self.sentASDUs[self.oldestSentASDU].seqNo) and
          (seqNo <= self.sentASDUs[self.newestSentASDU].seqNo):
        seqNoIsValid = true
    else:
      if (seqNo >= self.sentASDUs[self.oldestSentASDU].seqNo) or
          (seqNo <= self.sentASDUs[self.newestSentASDU].seqNo):
        seqNoIsValid = true
      counterOverflowDetected = true
    ##  check if confirmed message was already removed from list
    if self.sentASDUs[self.oldestSentASDU].seqNo == 0:
      oldestValidSeqNo = 32767
    else:
      oldestValidSeqNo = (self.sentASDUs[self.oldestSentASDU].seqNo - 1) mod 32768
    if oldestValidSeqNo == seqNo:
      seqNoIsValid = true
  if seqNoIsValid:
    if self.oldestSentASDU != -1:
      while true:
        if counterOverflowDetected == false:
          if seqNo < self.sentASDUs[self.oldestSentASDU].seqNo:
            break
        if seqNo == oldestValidSeqNo:
          break
        if self.sentASDUs[self.oldestSentASDU].seqNo == seqNo:
          ##  we arrived at the seq# that has been confirmed
          if self.oldestSentASDU == self.newestSentASDU:
            self.oldestSentASDU = -1
          else:
            self.oldestSentASDU = (self.oldestSentASDU + 1) mod self.maxSentASDUs
          break
        self.oldestSentASDU = (self.oldestSentASDU + 1) mod self.maxSentASDUs
        var checkIndex: cint = (self.newestSentASDU + 1) mod self.maxSentASDUs
        if self.oldestSentASDU == checkIndex:
          self.oldestSentASDU = -1
          break
        if not true:
          break
  when (CONFIG_USE_SEMAPHORES == 1):
    Semaphore_post(self.sentASDUsLock)
  return seqNoIsValid

proc isSentBufferFull*(self: CS104_Connection): bool =
  if self.oldestSentASDU == -1:
    return false
  var newIndex: cint = (self.newestSentASDU + 1) mod self.maxSentASDUs
  if newIndex == self.oldestSentASDU:
    return true
  else:
    return false

proc CS104_Connection_close*(self: CS104_Connection) =
  self.close = true
  when (CONFIG_USE_THREADS == 1):
    if self.connectionHandlingThread:
      Thread_destroy(self.connectionHandlingThread)
      self.connectionHandlingThread = nil

proc CS104_Connection_destroy*(self: CS104_Connection) =
  CS104_Connection_close(self)
  if self.sentASDUs != nil:
    GLOBAL_FREEMEM(self.sentASDUs)
  when (CONFIG_USE_SEMAPHORES == 1):
    Semaphore_destroy(self.sentASDUsLock)
  GLOBAL_FREEMEM(self)

proc CS104_Connection_setAPCIParameters*(self: CS104_Connection;
                                        parameters: CS104_APCIParameters) =
  self.parameters = parameters[]
  self.connectTimeoutInMs = self.parameters.t0 * 1000

proc CS104_Connection_setAppLayerParameters*(self: CS104_Connection;
    parameters: CS101_AppLayerParameters) =
  self.alParameters = parameters[]

proc CS104_Connection_getAppLayerParameters*(self: CS104_Connection): CS101_AppLayerParameters =
  return addr((self.alParameters))

proc CS104_Connection_setConnectTimeout*(self: CS104_Connection; millies: cint) =
  self.connectTimeoutInMs = millies

proc CS104_Connection_getAPCIParameters*(self: CS104_Connection): CS104_APCIParameters =
  return addr((self.parameters))

when (CONFIG_CS104_SUPPORT_TLS == 1):
  proc receiveMessageTlsSocket*(socket: TLSSocket; buffer: ptr uint8_t): cint =
    var readFirst: cint = TLSSocket_read(socket, buffer, 1)
    if readFirst < 1:
      return readFirst
    if buffer[0] != 0x00000000:
      return -1
    if TLSSocket_read(socket, buffer + 1, 1) != 1:
      return -1
    var length: cint = buffer[1]
    ##  read remaining frame
    if TLSSocket_read(socket, buffer + 2, length) != length:
      return -1
    return length + 2

proc receiveMessageSocket*(socket: Socket; buffer: ptr uint8_t): cint =
  var readFirst: cint = Socket_read(socket, buffer, 1)
  if readFirst < 1:
    return readFirst
  if buffer[0] != 0x00000000:
    return -1
  if Socket_read(socket, buffer + 1, 1) != 1:
    return -1
  var length: cint = buffer[1]
  ##  read remaining frame
  if Socket_read(socket, buffer + 2, length) != length:
    return -1
  return length + 2

proc receiveMessage*(self: CS104_Connection; buffer: ptr uint8_t): cint =
  when (CONFIG_CS104_SUPPORT_TLS == 1):
    if self.tlsSocket != nil:
      return receiveMessageTlsSocket(self.tlsSocket, buffer)
    else:
      return receiveMessageSocket(self.socket, buffer)
  else:
    return receiveMessageSocket(self.socket, buffer)

proc checkConfirmTimeout*(self: CS104_Connection; currentTime: clong): bool =
  if (currentTime - self.lastConfirmationTime) >=
      (uint32_t)(self.parameters.t2 * 1000):
    return true
  else:
    return false

proc checkMessage*(self: CS104_Connection; buffer: ptr uint8_t; msgSize: cint): bool =
  if (buffer[2] and 1) == 0:
    ##  I format frame
    if self.timeoutT2Trigger == false:
      self.timeoutT2Trigger = true
      self.lastConfirmationTime = Hal_getTimeInMs()
      ##  start timeout T2
    if msgSize < 7:
      DEBUG_PRINT("I msg too small!\n")
      return false
    var frameSendSequenceNumber: cint = ((buffer[3] * 0x00000000) +
        (buffer[2] and 0x00000000)) div 2
    var frameRecvSequenceNumber: cint = ((buffer[5] * 0x00000000) +
        (buffer[4] and 0x00000000)) div 2
    DEBUG_PRINT("Received I frame: N(S) = %i N(R) = %i\n",
                frameSendSequenceNumber, frameRecvSequenceNumber)
    ##  check the receive sequence number N(R) - connection will be closed on an unexpected value
    if frameSendSequenceNumber != self.receiveCount:
      DEBUG_PRINT("Sequence error: Close connection!")
      return false
    if checkSequenceNumber(self, frameRecvSequenceNumber) == false:
      return false
    self.receiveCount = (self.receiveCount + 1) mod 32768
    inc(self.unconfirmedReceivedIMessages)
    var asdu: CS101_ASDU = CS101_ASDU_createFromBuffer(
        (CS101_AppLayerParameters) and (self.alParameters), buffer + 6, msgSize - 6)
    if asdu != nil:
      if self.receivedHandler != nil:
        self.receivedHandler(self.receivedHandlerParameter, -1, asdu)
      CS101_ASDU_destroy(asdu)
    else:
      return false
  elif (buffer[2] and 0x00000000) == 0x00000000:
    ##  U format frame
    DEBUG_PRINT("Received U frame\n")
    self.uMessageTimeout = 0
    if buffer[2] == 0x00000000:
      ##  Check for TESTFR_ACT message
      DEBUG_PRINT("Send TESTFR_CON\n")
      writeToSocket(self, TESTFR_CON_MSG, TESTFR_CON_MSG_SIZE)
    elif buffer[2] == 0x00000000:
      ##  TESTFR_CON
      DEBUG_PRINT("Rcvd TESTFR_CON\n")
      self.outstandingTestFCConMessages = 0
    elif buffer[2] == 0x00000000:
      ##  STARTDT_ACT
      DEBUG_PRINT("Send STARTDT_CON\n")
      writeToSocket(self, STARTDT_CON_MSG, STARTDT_CON_MSG_SIZE)
    elif buffer[2] == 0x00000000:
      ##  STARTDT_CON
      DEBUG_PRINT("Received STARTDT_CON\n")
      if self.connectionHandler != nil:
        self.connectionHandler(self.connectionHandlerParameter, self,
                               CS104_CONNECTION_STARTDT_CON_RECEIVED)
    elif buffer[2] == 0x00000000:
      ##  STOPDT_CON
      DEBUG_PRINT("Received STOPDT_CON\n")
      if self.connectionHandler != nil:
        self.connectionHandler(self.connectionHandlerParameter, self,
                               CS104_CONNECTION_STOPDT_CON_RECEIVED)
  elif buffer[2] == 0x00000000:
    ##  S-message
    var seqNo: cint = (buffer[4] + buffer[5] * 0x00000000) div 2
    DEBUG_PRINT("Rcvd S(%i) (own sendcounter = %i)\n", seqNo, self.sendCount)
    if checkSequenceNumber(self, seqNo) == false:
      return false
  resetT3Timeout(self)
  return true

proc handleTimeouts*(self: CS104_Connection): bool =
  var retVal: bool = true
  var currentTime: uint64_t = Hal_getTimeInMs()
  if currentTime > self.nextT3Timeout:
    if self.outstandingTestFCConMessages > 2:
      DEBUG_PRINT("Timeout for TESTFR_CON message\n")
      ##  close connection
      retVal = false
      break exit_function
    else:
      DEBUG_PRINT("U message T3 timeout\n")
      writeToSocket(self, TESTFR_ACT_MSG, TESTFR_ACT_MSG_SIZE)
      self.uMessageTimeout = currentTime + (self.parameters.t1 * 1000)
      inc(self.outstandingTestFCConMessages)
      resetT3Timeout(self)
  if self.unconfirmedReceivedIMessages > 0:
    if checkConfirmTimeout(self, currentTime):
      self.lastConfirmationTime = currentTime
      self.unconfirmedReceivedIMessages = 0
      self.timeoutT2Trigger = false
      sendSMessage(self)
      ##  send confirmation message
  if self.uMessageTimeout != 0:
    if currentTime > self.uMessageTimeout:
      DEBUG_PRINT("U message T1 timeout\n")
      retVal = false
      break exit_function
  when (CONFIG_USE_SEMAPHORES == 1):
    Semaphore_wait(self.sentASDUsLock)
  if self.oldestSentASDU != -1:
    if (currentTime - self.sentASDUs[self.oldestSentASDU].sentTime) >=
        (uint64_t)(self.parameters.t1 * 1000):
      DEBUG_PRINT("I message timeout\n")
      retVal = false
  when (CONFIG_USE_SEMAPHORES == 1):
    Semaphore_post(self.sentASDUsLock)
  return retVal

when (CONFIG_USE_THREADS == 1):
  proc handleConnection*(parameter: pointer): pointer =
    var self: CS104_Connection = cast[CS104_Connection](parameter)
    resetConnection(self)
    self.socket = TcpSocket_create()
    Socket_setConnectTimeout(self.socket, self.connectTimeoutInMs)
    if Socket_connect(self.socket, self.hostname, self.tcpPort):
      when (CONFIG_CS104_SUPPORT_TLS == 1):
        if self.tlsConfig != nil:
          self.tlsSocket = TLSSocket_create(self.socket, self.tlsConfig, false)
          if self.tlsSocket:
            self.running = true
          else:
            self.failure = true
        else:
          self.running = true
      else:
        self.running = true
      if self.running:
        ##  Call connection handler
        if self.connectionHandler != nil:
          self.connectionHandler(self.connectionHandlerParameter, self,
                                 CS104_CONNECTION_OPENED)
        var handleSet: HandleSet = Handleset_new()
        var loopRunning: bool = true
        while loopRunning:
          var buffer: array[300, uint8_t]
          Handleset_reset(handleSet)
          Handleset_addSocket(handleSet, self.socket)
          if Handleset_waitReady(handleSet, 100):
            var bytesRec: cint = receiveMessage(self, buffer)
            if bytesRec == -1:
              loopRunning = false
              self.failure = true
            if bytesRec > 0:
              if self.rawMessageHandler:
                self.rawMessageHandler(self.rawMessageHandlerParameter, buffer,
                                       bytesRec, false)
              if checkMessage(self, buffer, bytesRec) == false:
                ##  close connection on error
                loopRunning = false
                self.failure = true
            if self.unconfirmedReceivedIMessages >= self.parameters.w:
              self.lastConfirmationTime = Hal_getTimeInMs()
              self.unconfirmedReceivedIMessages = 0
              self.timeoutT2Trigger = false
              sendSMessage(self)
          if handleTimeouts(self) == false:
            loopRunning = false
          if self.close:
            loopRunning = false
        Handleset_destroy(handleSet)
        ##  Call connection handler
        if self.connectionHandler != nil:
          self.connectionHandler(self.connectionHandlerParameter, self,
                                 CS104_CONNECTION_CLOSED)
    else:
      self.failure = true
    when (CONFIG_CS104_SUPPORT_TLS == 1):
      if self.tlsSocket:
        TLSSocket_close(self.tlsSocket)
    Socket_destroy(self.socket)
    DEBUG_PRINT("EXIT CONNECTION HANDLING THREAD\n")
    self.running = false
    return nil

proc CS104_Connection_connectAsync*(self: CS104_Connection) =
  self.running = false
  self.failure = false
  self.close = false
  when (CONFIG_USE_THREADS == 1):
    self.connectionHandlingThread = Thread_create(handleConnection,
        cast[pointer](self), false)
    if self.connectionHandlingThread:
      Thread_start(self.connectionHandlingThread)

proc CS104_Connection_connect*(self: CS104_Connection): bool =
  self.running = false
  self.failure = false
  self.close = false
  CS104_Connection_connectAsync(self)
  while (self.running == false) and (self.failure == false):
    Thread_sleep(1)
  return self.running

proc CS104_Connection_setASDUReceivedHandler*(self: CS104_Connection;
    handler: CS101_ASDUReceivedHandler; parameter: pointer) =
  self.receivedHandler = handler
  self.receivedHandlerParameter = parameter

proc CS104_Connection_setConnectionHandler*(self: CS104_Connection;
    handler: CS104_ConnectionHandler; parameter: pointer) =
  self.connectionHandler = handler
  self.connectionHandlerParameter = parameter

proc CS104_Connection_setRawMessageHandler*(self: CS104_Connection;
    handler: IEC60870_RawMessageHandler; parameter: pointer) =
  self.rawMessageHandler = handler
  self.rawMessageHandlerParameter = parameter

proc encodeIdentificationField*(self: CS104_Connection; frame: Frame; typeId: TypeID;
                               vsq: cint; cot: CS101_CauseOfTransmission; ca: cint) =
  T104Frame_setNextByte(frame, typeId)
  T104Frame_setNextByte(frame, cast[uint8_t](vsq))
  ##  encode COT
  T104Frame_setNextByte(frame, cast[uint8_t](cot))
  if self.alParameters.sizeOfCOT == 2:
    T104Frame_setNextByte(frame,
                          cast[uint8_t](self.alParameters.originatorAddress))
  T104Frame_setNextByte(frame, (uint8_t)(ca and 0x00000000))
  if self.alParameters.sizeOfCA == 2:
    T104Frame_setNextByte(frame, (uint8_t)((ca and 0x00000000) shr 8))

proc encodeIOA*(self: CS104_Connection; frame: Frame; ioa: cint) =
  T104Frame_setNextByte(frame, (uint8_t)(ioa and 0x00000000))
  if self.alParameters.sizeOfIOA > 1:
    T104Frame_setNextByte(frame, (uint8_t)((ioa div 0x00000000) and 0x00000000))
  if self.alParameters.sizeOfIOA > 2:
    T104Frame_setNextByte(frame, (uint8_t)((ioa div 0x00000000) and 0x00000000))

proc CS104_Connection_sendStartDT*(self: CS104_Connection) =
  writeToSocket(self, STARTDT_ACT_MSG, STARTDT_ACT_MSG_SIZE)

proc CS104_Connection_sendStopDT*(self: CS104_Connection) =
  writeToSocket(self, STOPDT_ACT_MSG, STOPDT_ACT_MSG_SIZE)

proc sendIMessageAndUpdateSentASDUs*(self: CS104_Connection; frame: Frame) =
  when (CONFIG_USE_SEMAPHORES == 1):
    Semaphore_wait(self.sentASDUsLock)
  var currentIndex: cint = 0
  if self.oldestSentASDU == -1:
    self.oldestSentASDU = 0
    self.newestSentASDU = 0
  else:
    currentIndex = (self.newestSentASDU + 1) mod self.maxSentASDUs
  self.sentASDUs[currentIndex].seqNo = sendIMessage(self, frame)
  self.sentASDUs[currentIndex].sentTime = Hal_getTimeInMs()
  self.newestSentASDU = currentIndex
  when (CONFIG_USE_SEMAPHORES == 1):
    Semaphore_post(self.sentASDUsLock)

proc sendASDUInternal*(self: CS104_Connection; frame: Frame): bool =
  var retVal: bool = false
  if self.running:
    if isSentBufferFull(self) == false:
      sendIMessageAndUpdateSentASDUs(self, frame)
      retVal = true
  T104Frame_destroy(frame)
  return retVal

proc CS104_Connection_sendInterrogationCommand*(self: CS104_Connection;
    cot: CS101_CauseOfTransmission; ca: cint; qoi: QualifierOfInterrogation): bool =
  var frame: Frame = cast[Frame](T104Frame_create())
  encodeIdentificationField(self, frame, C_IC_NA_1, 1, cot, ca)
  encodeIOA(self, frame, 0)
  ##  encode QOI (7.2.6.22)
  T104Frame_setNextByte(frame, qoi)
  ##  20 = station interrogation
  return sendASDUInternal(self, frame)

proc CS104_Connection_sendCounterInterrogationCommand*(self: CS104_Connection;
    cot: CS101_CauseOfTransmission; ca: cint; qcc: uint8_t): bool =
  var frame: Frame = cast[Frame](T104Frame_create())
  encodeIdentificationField(self, frame, C_CI_NA_1, 1, cot, ca)
  encodeIOA(self, frame, 0)
  ##  encode QCC
  T104Frame_setNextByte(frame, qcc)
  return sendASDUInternal(self, frame)

proc CS104_Connection_sendReadCommand*(self: CS104_Connection; ca: cint; ioa: cint): bool =
  var frame: Frame = cast[Frame](T104Frame_create())
  encodeIdentificationField(self, frame, C_RD_NA_1, 1, CS101_COT_REQUEST, ca)
  encodeIOA(self, frame, ioa)
  return sendASDUInternal(self, frame)

proc CS104_Connection_sendClockSyncCommand*(self: CS104_Connection; ca: cint;
    newTime: CP56Time2a): bool =
  var frame: Frame = cast[Frame](T104Frame_create())
  encodeIdentificationField(self, frame, C_CS_NA_1, 1, CS101_COT_ACTIVATION, ca)
  encodeIOA(self, frame, 0)
  T104Frame_appendBytes(frame, CP56Time2a_getEncodedValue(newTime), 7)
  return sendASDUInternal(self, frame)

proc CS104_Connection_sendTestCommand*(self: CS104_Connection; ca: cint): bool =
  var frame: Frame = cast[Frame](T104Frame_create())
  encodeIdentificationField(self, frame, C_TS_NA_1, 1, CS101_COT_ACTIVATION, ca)
  encodeIOA(self, frame, 0)
  T104Frame_setNextByte(frame, 0x00000000)
  T104Frame_setNextByte(frame, 0x00000000)
  return sendASDUInternal(self, frame)

proc CS104_Connection_sendProcessCommand*(self: CS104_Connection; typeId: TypeID;
    cot: CS101_CauseOfTransmission; ca: cint; sc: InformationObject): bool =
  var frame: Frame = cast[Frame](T104Frame_create())
  if typeId == 0:
    typeId = InformationObject_getType(sc)
  encodeIdentificationField(self, frame, typeId, 1, cot, ca)
  InformationObject_encode(sc, frame,
                           (CS101_AppLayerParameters) and (self.alParameters),
                           false)
  return sendASDUInternal(self, frame)

proc CS104_Connection_sendProcessCommandEx*(self: CS104_Connection;
    cot: CS101_CauseOfTransmission; ca: cint; sc: InformationObject): bool =
  var frame: Frame = cast[Frame](T104Frame_create())
  var typeId: TypeID = InformationObject_getType(sc)
  encodeIdentificationField(self, frame, typeId, 1, cot, ca)
  InformationObject_encode(sc, frame,
                           (CS101_AppLayerParameters) and (self.alParameters),
                           false)
  return sendASDUInternal(self, frame)

proc CS104_Connection_sendASDU*(self: CS104_Connection; asdu: CS101_ASDU): bool =
  var frame: Frame = cast[Frame](T104Frame_create())
  CS101_ASDU_encode(asdu, frame)
  return sendASDUInternal(self, frame)

proc CS104_Connection_isTransmitBufferFull*(self: CS104_Connection): bool =
  return isSentBufferFull(self)
