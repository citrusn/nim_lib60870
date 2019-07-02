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
  cs104_slave, cs104_frame, frame, hal_socket, hal_thread, hal_time, lib_memory,
  linked_list, buffer_frame, lib60870_config, lib60870_internal, iec60870_slave,
  apl_types_internal, cs101_asdu_internal

when (CONFIG_CS104_SUPPORT_TLS == 1):
  import
    tls_socket

when ((CONFIG_CS104_SUPPORT_SERVER_MODE_CONNECTION_IS_REDUNDANCY_GROUP != 1) and
    (CONFIG_CS104_SUPPORT_SERVER_MODE_SINGLE_REDUNDANCY_GROUP != 1) and
    (CONFIG_CS104_SUPPORT_SERVER_MODE_MULTIPLE_REDUNDANCY_GROUPS != 1)):
type
  MasterConnection* = ptr sMasterConnection

proc MasterConnection_close*(self: MasterConnection)
proc MasterConnection_deactivate*(self: MasterConnection)
proc MasterConnection_activate*(self: MasterConnection)
const
  CS104_DEFAULT_PORT* = 2404

var defaultConnectionParameters*: sCS104_APCIParameters = [12, 8, 10, 15, 10, 20]

var defaultAppLayerParameters*: sCS101_AppLayerParameters = [1, 1, 2, 0, 2, 3, 249]

type                          ##  .k =
##  .sizeOfTypeId =
  FrameBuffer* {.bycopy.} = object
    msg*: array[256, uint8_t]
    msgSize*: cint

  QueueEntryState* = enum
    QUEUE_ENTRY_STATE_NOT_USED, QUEUE_ENTRY_STATE_WAITING_FOR_TRANSMISSION,
    QUEUE_ENTRY_STATE_SENT_BUT_NOT_CONFIRMED


type
  sASDUQueueEntry* {.bycopy.} = object
    entryTimestamp*: uint64_t
    asdu*: FrameBuffer
    state*: QueueEntryState

  ASDUQueueEntry* = ptr sASDUQueueEntry

## **************************************************
##  MessageQueue
## *************************************************

type
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

  MessageQueue* = ptr sMessageQueue

when (CONFIG_CS104_SLAVE_POOL == 1):
  type
    sMessageQueuePool* {.bycopy.} = object
      msgQueue*: sMessageQueue
      used*: bool

  var messageQueuePoolInitialized*: bool = false
  var msgQueuePool*: array[CONFIG_CS104_MESSAGE_QUEUE_POOL_SIZE, sMessageQueuePool]
  proc AllocateMessageQueueMemory*(): MessageQueue =
    var i: cint
    if not messageQueuePoolInitialized:
      i = 0
      while i < CONFIG_CS104_MESSAGE_QUEUE_POOL_SIZE:
        msgQueuePool[i].used = false
        inc(i)
      messageQueuePoolInitialized = true
    i = 0
    while i < CONFIG_CS104_MESSAGE_QUEUE_POOL_SIZE:
      if msgQueuePool[i].used == false:
        msgQueuePool[i].used = true
        return addr((msgQueuePool[i].msgQueue))
      inc(i)
    DEBUG_PRINT("AllocateMessageQueueMemory: failed\n")
    return nil

  proc ReleaseMessageQueueMemory*(queue: MessageQueue) =
    var i: cint
    i = 0
    while i < CONFIG_CS104_MESSAGE_QUEUE_POOL_SIZE:
      if msgQueuePool[i].used == true:
        if addr((msgQueuePool[i].msgQueue)) == queue:
          msgQueuePool[i].used = false
          return
      inc(i)
    DEBUG_PRINT("ReleaseMessageQueueMemory: failed\n")

proc MessageQueue_initialize*(self: MessageQueue; maxQueueSize: cint) =
  when (CONFIG_CS104_SLAVE_POOL == 1):
    memset(self.asdus, 0,
           sizeof(cast[sASDUQueueEntry](CONFIG_CS104_MESSAGE_QUEUE_SIZE[])))
  else:
    self.asdus = cast[ASDUQueueEntry](GLOBAL_CALLOC(maxQueueSize,
        sizeof(sASDUQueueEntry)))
  self.entryCounter = 0
  self.firstMsgIndex = 0
  self.lastMsgIndex = 0
  self.size = maxQueueSize
  when (CONFIG_CS104_SLAVE_POOL == 1):
    if maxQueueSize > CONFIG_CS104_MESSAGE_QUEUE_SIZE:
      self.size = CONFIG_CS104_MESSAGE_QUEUE_SIZE
  when (CONFIG_USE_SEMAPHORES == 1):
    self.queueLock = Semaphore_create(1)

proc MessageQueue_create*(maxQueueSize: cint): MessageQueue =
  when (CONFIG_CS104_SLAVE_POOL == 1):
    var self: MessageQueue = AllocateMessageQueueMemory()
  else:
    var self: MessageQueue = cast[MessageQueue](GLOBAL_MALLOC(sizeof(sMessageQueue)))
  if self != nil:
    MessageQueue_initialize(self, maxQueueSize)
  return self

proc MessageQueue_destroy*(self: MessageQueue) =
  if self != nil:
    when (CONFIG_CS104_SLAVE_POOL != 1):
      GLOBAL_FREEMEM(self.asdus)
    when (CONFIG_USE_SEMAPHORES == 1):
      Semaphore_destroy(self.queueLock)
    when (CONFIG_CS104_SLAVE_POOL == 1):
      ReleaseMessageQueueMemory(self)
    else:
      GLOBAL_FREEMEM(self)

proc MessageQueue_lock*(self: MessageQueue) =
  when (CONFIG_USE_SEMAPHORES == 1):
    Semaphore_wait(self.queueLock)

proc MessageQueue_unlock*(self: MessageQueue) =
  when (CONFIG_USE_SEMAPHORES == 1):
    Semaphore_post(self.queueLock)

## *
##  Add an ASDU to the queue. When queue is full, override oldest entry.
##

proc MessageQueue_enqueueASDU*(self: MessageQueue; asdu: CS101_ASDU) =
  when (CONFIG_USE_SEMAPHORES == 1):
    Semaphore_wait(self.queueLock)
  var nextIndex: cint
  var removeEntry: bool = false
  if self.entryCounter == 0:
    self.firstMsgIndex = 0
    nextIndex = 0
  else:
    nextIndex = self.lastMsgIndex + 1
  if nextIndex == self.size:
    nextIndex = 0
  if self.entryCounter == self.size:
    removeEntry = true
  if removeEntry == false:
    DEBUG_PRINT("add entry (nextIndex:%i)\n", nextIndex)
    self.lastMsgIndex = nextIndex
    inc(self.entryCounter)
  else:
    DEBUG_PRINT("add entry (nextIndex:%i) -> remove oldest\n", nextIndex)
    ##  remove oldest entry
    self.lastMsgIndex = nextIndex
    var firstIndex: cint = nextIndex + 1
    if firstIndex == self.size:
      firstIndex = 0
    self.firstMsgIndex = firstIndex
  var bufferFrame: sBufferFrame
  var frame: Frame = BufferFrame_initialize(addr(bufferFrame),
                                        self.asdus[nextIndex].asdu.msg,
                                        IEC60870_5_104_APCI_LENGTH)
  CS101_ASDU_encode(asdu, frame)
  self.asdus[nextIndex].asdu.msgSize = Frame_getMsgSize(frame)
  self.asdus[nextIndex].entryTimestamp = Hal_getTimeInMs()
  self.asdus[nextIndex].state = QUEUE_ENTRY_STATE_WAITING_FOR_TRANSMISSION
  DEBUG_PRINT("ASDUs in FIFO: %i (first: %i, last: %i)\n", self.entryCounter,
              self.firstMsgIndex, self.lastMsgIndex)
  when (CONFIG_USE_SEMAPHORES == 1):
    Semaphore_post(self.queueLock)

proc MessageQueue_isAsduAvailable*(self: MessageQueue): bool =
  when (CONFIG_USE_SEMAPHORES == 1):
    Semaphore_wait(self.queueLock)
  var retVal: bool
  if self.entryCounter > 0:
    retVal = true
  else:
    retVal = false
  when (CONFIG_USE_SEMAPHORES == 1):
    Semaphore_post(self.queueLock)
  return retVal

proc MessageQueue_getNextWaitingASDU*(self: MessageQueue; timestamp: ptr uint64_t;
                                     queueIndex: ptr cint): ptr FrameBuffer =
  var buffer: ptr FrameBuffer = nil
  if self.entryCounter != 0:
    var currentIndex: cint = self.firstMsgIndex
    while self.asdus[currentIndex].state !=
        QUEUE_ENTRY_STATE_WAITING_FOR_TRANSMISSION:
      if self.asdus[currentIndex].state == QUEUE_ENTRY_STATE_NOT_USED:
        break
      currentIndex = (currentIndex + 1) mod self.size
      ##  break when we reached the oldest entry again
      if currentIndex == self.firstMsgIndex:
        break
    if self.asdus[currentIndex].state ==
        QUEUE_ENTRY_STATE_WAITING_FOR_TRANSMISSION:
      self.asdus[currentIndex].state = QUEUE_ENTRY_STATE_SENT_BUT_NOT_CONFIRMED
      timestamp[] = self.asdus[currentIndex].entryTimestamp
      queueIndex[] = currentIndex
      buffer = addr((self.asdus[currentIndex].asdu))
  return buffer

when (CONFIG_CS104_SUPPORT_SERVER_MODE_SINGLE_REDUNDANCY_GROUP == 1):
  proc MessageQueue_releaseAllQueuedASDUs*(self: MessageQueue) =
    when (CONFIG_USE_SEMAPHORES == 1):
      Semaphore_wait(self.queueLock)
    self.firstMsgIndex = 0
    self.lastMsgIndex = 0
    self.entryCounter = 0
    when (CONFIG_USE_SEMAPHORES == 1):
      Semaphore_post(self.queueLock)

proc MessageQueue_markAsduAsConfirmed*(self: MessageQueue; queueIndex: cint;
                                      timestamp: uint64_t) =
  if (queueIndex < 0) or (queueIndex > self.size):
    return
  when (CONFIG_USE_SEMAPHORES == 1):
    Semaphore_wait(self.queueLock)
  if self.entryCounter > 0:
    if self.asdus[queueIndex].state == QUEUE_ENTRY_STATE_SENT_BUT_NOT_CONFIRMED:
      if self.asdus[queueIndex].entryTimestamp == timestamp:
        var currentIndex: cint = queueIndex
        while self.asdus[currentIndex].state ==
            QUEUE_ENTRY_STATE_SENT_BUT_NOT_CONFIRMED:
          DEBUG_PRINT("Remove from queue with index %i\n", currentIndex)
          self.asdus[currentIndex].state = QUEUE_ENTRY_STATE_NOT_USED
          self.asdus[currentIndex].entryTimestamp = 0
          dec(self.entryCounter)
          if self.entryCounter == 0:
            self.firstMsgIndex = -1
            self.lastMsgIndex = -1
            break
          if currentIndex == self.firstMsgIndex:
            self.firstMsgIndex = (queueIndex + 1) mod self.size
            if self.entryCounter == 1:
              self.lastMsgIndex = self.firstMsgIndex
            break
          dec(currentIndex)
          if currentIndex < 0:
            currentIndex = self.size - 1
          if currentIndex == queueIndex:
            break
          DEBUG_PRINT("queue state: noASDUs: %i oldest: %i latest: %i\n",
                      self.entryCounter, self.firstMsgIndex, self.lastMsgIndex)
  when (CONFIG_USE_SEMAPHORES == 1):
    Semaphore_post(self.queueLock)

## **************************************************
##  HighPriorityASDUQueue
## *************************************************

type
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

  HighPriorityASDUQueue* = ptr sHighPriorityASDUQueue

when (CONFIG_CS104_SLAVE_POOL == 1):
  type
    sHighPrioQueuePool* {.bycopy.} = object
      msgQueue*: sHighPriorityASDUQueue
      used*: bool

  var highPrioQueuePoolInitialized*: bool = false
  var highPrioQueuePool*: array[CONFIG_CS104_MESSAGE_QUEUE_POOL_SIZE,
                              sHighPrioQueuePool]
  proc AllocateHighPrioQueueMemory*(): HighPriorityASDUQueue =
    var i: cint
    if not highPrioQueuePoolInitialized:
      i = 0
      while i < CONFIG_CS104_MESSAGE_QUEUE_POOL_SIZE:
        highPrioQueuePool[i].used = false
        inc(i)
      highPrioQueuePoolInitialized = true
    i = 0
    while i < CONFIG_CS104_MESSAGE_QUEUE_POOL_SIZE:
      if highPrioQueuePool[i].used == false:
        highPrioQueuePool[i].used = true
        return addr((highPrioQueuePool[i].msgQueue))
      inc(i)
    DEBUG_PRINT("AllocateHighPrioQueueMemory: failed\n")
    return nil

  proc ReleaseHighPrioQueueMemory*(queue: HighPriorityASDUQueue) =
    var i: cint
    i = 0
    while i < CONFIG_CS104_MESSAGE_QUEUE_POOL_SIZE:
      if highPrioQueuePool[i].used == true:
        if addr((highPrioQueuePool[i].msgQueue)) == queue:
          highPrioQueuePool[i].used = false
          return
      inc(i)
    DEBUG_PRINT("ReleaseHighPrioQueueMemory: failed\n")

proc HighPriorityASDUQueue_initialize*(self: HighPriorityASDUQueue;
                                      maxQueueSize: cint) =
  when (CONFIG_CS104_SLAVE_POOL != 1):
    self.asdus = cast[ptr FrameBuffer](GLOBAL_CALLOC(maxQueueSize,
        sizeof((FrameBuffer))))
  self.entryCounter = 0
  self.firstMsgIndex = 0
  self.lastMsgIndex = 0
  self.size = maxQueueSize
  when (CONFIG_CS104_SLAVE_POOL == 1):
    if maxQueueSize > CONFIG_CS104_MESSAGE_QUEUE_HIGH_PRIO_SIZE:
      self.size = CONFIG_CS104_MESSAGE_QUEUE_HIGH_PRIO_SIZE
  when (CONFIG_USE_SEMAPHORES == 1):
    self.queueLock = Semaphore_create(1)

proc HighPriorityASDUQueue_create*(maxQueueSize: cint): HighPriorityASDUQueue =
  when (CONFIG_CS104_SLAVE_POOL == 1):
    var self: HighPriorityASDUQueue = AllocateHighPrioQueueMemory()
  else:
    var self: HighPriorityASDUQueue = cast[HighPriorityASDUQueue](GLOBAL_MALLOC(
        sizeof(sHighPriorityASDUQueue)))
  if self != nil:
    HighPriorityASDUQueue_initialize(self, maxQueueSize)
  return self

proc HighPriorityASDUQueue_destroy*(self: HighPriorityASDUQueue) =
  when (CONFIG_CS104_SLAVE_POOL == 1):
  else:
    GLOBAL_FREEMEM(self.asdus)
  when (CONFIG_USE_SEMAPHORES == 1):
    Semaphore_destroy(self.queueLock)
  when (CONFIG_CS104_SLAVE_POOL == 1):
    ReleaseHighPrioQueueMemory(self)
  else:
    GLOBAL_FREEMEM(self)

proc HighPriorityASDUQueue_lock*(self: HighPriorityASDUQueue) =
  when (CONFIG_USE_SEMAPHORES == 1):
    Semaphore_wait(self.queueLock)

proc HighPriorityASDUQueue_unlock*(self: HighPriorityASDUQueue) =
  when (CONFIG_USE_SEMAPHORES == 1):
    Semaphore_post(self.queueLock)

proc HighPriorityASDUQueue_isAsduAvailable*(self: HighPriorityASDUQueue): bool =
  when (CONFIG_USE_SEMAPHORES == 1):
    Semaphore_wait(self.queueLock)
  var retVal: bool
  if self.entryCounter > 0:
    retVal = true
  else:
    retVal = false
  when (CONFIG_USE_SEMAPHORES == 1):
    Semaphore_post(self.queueLock)
  return retVal

proc HighPriorityASDUQueue_getNextASDU*(self: HighPriorityASDUQueue): ptr FrameBuffer =
  var buffer: ptr FrameBuffer = nil
  if self.entryCounter != 0:
    var currentIndex: cint = self.firstMsgIndex
    if self.entryCounter == 1:
      self.entryCounter = 0
      self.firstMsgIndex = -1
      self.lastMsgIndex = -1
    else:
      self.firstMsgIndex = (self.firstMsgIndex + 1) mod (self.size)
      dec(self.entryCounter)
    buffer = addr((self.asdus[currentIndex]))
  return buffer

proc HighPriorityASDUQueue_enqueue*(self: HighPriorityASDUQueue; asdu: CS101_ASDU): bool =
  when (CONFIG_USE_SEMAPHORES == 1):
    Semaphore_wait(self.queueLock)
  var frame: Frame
  var enqueued: bool = false
  if self.entryCounter == self.size:
    break exit_function
  var nextIndex: cint
  if self.entryCounter == 0:
    self.firstMsgIndex = 0
    nextIndex = 0
  else:
    nextIndex = self.lastMsgIndex + 1
  if nextIndex == self.size:
    nextIndex = 0
  DEBUG_PRINT("HighPrio AsduQueue: add entry (nextIndex:%i)\n", nextIndex)
  self.lastMsgIndex = nextIndex
  inc(self.entryCounter)
  var bufferFrame: sBufferFrame
  frame = BufferFrame_initialize(addr(bufferFrame), self.asdus[nextIndex].msg,
                               IEC60870_5_104_APCI_LENGTH)
  CS101_ASDU_encode(asdu, frame)
  self.asdus[nextIndex].msgSize = Frame_getMsgSize(frame)
  DEBUG_PRINT("ASDUs in HighPrio FIFO: %i (first: %i, last: %i)\n",
              self.entryCounter, self.firstMsgIndex, self.lastMsgIndex)
  enqueued = true
  when (CONFIG_USE_SEMAPHORES == 1):
    Semaphore_post(self.queueLock)
  return enqueued

proc HighPriorityASDUQueue_resetConnectionQueue*(self: HighPriorityASDUQueue) =
  when (CONFIG_USE_SEMAPHORES == 1):
    Semaphore_wait(self.queueLock)
  self.firstMsgIndex = 0
  self.lastMsgIndex = 0
  self.entryCounter = 0
  when (CONFIG_USE_SEMAPHORES == 1):
    Semaphore_post(self.queueLock)

## **************************************************
##  RedundancyGroup
## *************************************************

type
  CS104_IPAddress* = ptr sCS104_IPAddress
  sCS104_IPAddress* {.bycopy.} = object
    address*: array[16, uint8_t]
    `type`*: eCS104_IPAddressType


proc CS104_IPAddress_setFromString*(self: CS104_IPAddress; ipAddrStr: cstring) =
  if strchr(ipAddrStr, '.') != nil:
    ##  parse IPv4 string
    self.`type` = IP_ADDRESS_TYPE_IPV4
    var i: cint
    i = 0
    while i < 4:
      self.address[i] = strtoul(ipAddrStr, nil, 10)
      ipAddrStr = strchr(ipAddrStr, '.')
      if (ipAddrStr == nil) or (ipAddrStr[] == 0):
        break
      inc(ipAddrStr)
      inc(i)
  else:
    self.`type` = IP_ADDRESS_TYPE_IPV6
    var i: cint
    i = 0
    while i < 8:
      var val: uint32_t = strtoul(ipAddrStr, nil, 16)
      self.address[i * 2] = val div 0x00000000
      self.address[i * 2 + 1] = val mod 0x00000000
      ipAddrStr = strchr(ipAddrStr, ':')
      if (ipAddrStr == nil) or (ipAddrStr[] == 0):
        break
      inc(ipAddrStr)
      inc(i)

proc CS104_IPAddress_equals*(self: CS104_IPAddress; other: CS104_IPAddress): bool =
  if self.`type` != other.`type`:
    return false
  var size: cint
  if self.`type` == IP_ADDRESS_TYPE_IPV4:
    size = 4
  else:
    size = 16
  var i: cint
  i = 0
  while i < size:
    if self.address[i] != other.address[i]:
      return false
    inc(i)
  return true

type
  sCS104_RedundancyGroup* {.bycopy.} = object
    name*: cstring             ## *< name of the group to be shown in debug messages, or NULL
    asduQueue*: MessageQueue   ## *< low priority ASDU queue and buffer
    connectionAsduQueue*: HighPriorityASDUQueue ## *< high priority ASDU queue
    allowedClients*: LinkedList


when (CONFIG_CS104_SUPPORT_SERVER_MODE_MULTIPLE_REDUNDANCY_GROUPS == 1):
  proc CS104_RedundancyGroup_initializeMessageQueues*(
      self: CS104_RedundancyGroup; lowPrioMaxQueueSize: cint;
      highPrioMaxQueueSize: cint) =
    ##  initialized low priority queue
    when (CONFIG_CS104_SLAVE_POOL == 1):
      if lowPrioMaxQueueSize > CONFIG_CS104_MESSAGE_QUEUE_SIZE:
        lowPrioMaxQueueSize = CONFIG_CS104_MESSAGE_QUEUE_SIZE
    self.asduQueue = MessageQueue_create(lowPrioMaxQueueSize)
    ##  initialize high priority queue
    when (CONFIG_CS104_SLAVE_POOL == 1):
      if highPrioMaxQueueSize > CONFIG_CS104_MESSAGE_QUEUE_HIGH_PRIO_SIZE:
        highPrioMaxQueueSize = CONFIG_CS104_MESSAGE_QUEUE_HIGH_PRIO_SIZE
    self.connectionAsduQueue = HighPriorityASDUQueue_create(highPrioMaxQueueSize)

proc CS104_RedundancyGroup_create*(name: cstring): CS104_RedundancyGroup =
  var self: CS104_RedundancyGroup = cast[CS104_RedundancyGroup](GLOBAL_MALLOC(
      sizeof(sCS104_RedundancyGroup)))
  if self:
    if name:
      self.name = strdup(name)
    else:
      self.name = nil
    self.asduQueue = nil
    self.connectionAsduQueue = nil
    self.allowedClients = nil
  return self

proc CS104_RedundancyGroup_destroy*(self: CS104_RedundancyGroup) =
  if self:
    if self.name:
      GLOBAL_FREEMEM(self.name)
    MessageQueue_destroy(self.asduQueue)
    HighPriorityASDUQueue_destroy(self.connectionAsduQueue)
    if self.allowedClients:
      LinkedList_destroy(self.allowedClients)
    GLOBAL_FREEMEM(self)

proc CS104_RedundancyGroup_addAllowedClient*(self: CS104_RedundancyGroup;
    ipAddress: cstring) =
  var ipAddr: sCS104_IPAddress
  CS104_IPAddress_setFromString(addr(ipAddr), ipAddress)
  CS104_RedundancyGroup_addAllowedClientEx(self, ipAddr.address, ipAddr.`type`)

proc CS104_RedundancyGroup_addAllowedClientEx*(self: CS104_RedundancyGroup;
    ipAddress: ptr uint8_t; addressType: eCS104_IPAddressType) =
  if self.allowedClients == nil:
    self.allowedClients = LinkedList_create()
  var ipAddr: CS104_IPAddress = cast[CS104_IPAddress](GLOBAL_MALLOC(
      sizeof(sCS104_IPAddress)))
  ipAddr.`type` = addressType
  var size: cint
  if addressType == IP_ADDRESS_TYPE_IPV4:
    size = 4
  else:
    size = 16
  var i: cint
  i = 0
  while i < size:
    ipAddr.address[i] = ipAddress[i]
    inc(i)
  LinkedList_add(self.allowedClients, ipAddr)

proc CS104_RedundancyGroup_matches*(self: CS104_RedundancyGroup;
                                   ipAddress: CS104_IPAddress): bool =
  if self.allowedClients == nil:
    return false
  var element: LinkedList = LinkedList_getNext(self.allowedClients)
  while element:
    var allowedAddress: CS104_IPAddress = cast[CS104_IPAddress](LinkedList_getData(
        element))
    if CS104_IPAddress_equals(ipAddress, allowedAddress):
      return true
    element = LinkedList_getNext(element)
  return false

proc CS104_RedundancyGroup_isCatchAll*(self: CS104_RedundancyGroup): bool =
  if self.allowedClients:
    return false
  else:
    return true


type
  sMasterConnection* {.bycopy.} = object
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
    sentASDUs*: array[CONFIG_CS104_MAX_K_BUFFER_SIZE, SentASDUSlave] ## #else
                                                                  ##     SentASDUSlave* sentASDUs;
                                                                  ## #endif
                                                                  ## #if (CONFIG_USE_SEMAPHORES == 1)
    sentASDUsLock*: Semaphore  ## #endif
    handleSet*: HandleSet
    buffer*: array[260, uint8_t]
    lowPrioQueue*: MessageQueue
    highPrioQueue*: HighPriorityASDUQueue 
    ## #if (CONFIG_CS104_SUPPORT_SERVER_MODE_MULTIPLE_REDUNDANCY_GROUPS == 1)
    redundancyGroup*: CS104_RedundancyGroup 
    ## #endif


when (CONFIG_CS104_SLAVE_POOL == 1):
  type
    sCS104_Slave_PoolEntry* {.bycopy.} = object
      slave*: sCS104_Slave
      used*: bool

  var slavePool*: array[CONFIG_CS104_SLAVE_POOL_SIZE, sCS104_Slave_PoolEntry]
  var slavePoolInitialized*: bool = false
  proc AllocateSlave*(): CS104_Slave =
    var i: cint
    if not slavePoolInitialized:
      i = 0
      while i < CONFIG_CS104_SLAVE_POOL_SIZE:
        slavePool[i].used = false
        inc(i)
      slavePoolInitialized = true
    i = 0
    while i < CONFIG_CS104_SLAVE_POOL_SIZE:
      if slavePool[i].used == false:
        slavePool[i].used = true
        return addr((slavePool[i].slave))
      inc(i)
    DEBUG_PRINT("AllocateSlave: failed\n")
    return nil

  proc ReleaseSlave*(slave: CS104_Slave) =
    var i: cint
    i = 0
    while i < CONFIG_CS104_SLAVE_POOL_SIZE:
      if slavePool[i].used == true:
        if addr((slavePool[i].slave)) == slave:
          slavePool[i].used = false
          return
      inc(i)
    DEBUG_PRINT("ReleaseSlave: failed\n")

var STARTDT_CON_MSG*: ptr uint8_t = [0x00000000, 0x00000000, 0x00000000, 0x00000000,
                                0x00000000, 0x00000000]

const
  STARTDT_CON_MSG_SIZE* = 6

var STOPDT_CON_MSG*: ptr uint8_t = [0x00000000, 0x00000000, 0x00000000, 0x00000000,
                               0x00000000, 0x00000000]

const
  STOPDT_CON_MSG_SIZE* = 6

var TESTFR_CON_MSG*: ptr uint8_t = [0x00000000, 0x00000000, 0x00000000, 0x00000000,
                               0x00000000, 0x00000000]

const
  TESTFR_CON_MSG_SIZE* = 6

var TESTFR_ACT_MSG*: ptr uint8_t = [0x00000000, 0x00000000, 0x00000000, 0x00000000,
                               0x00000000, 0x00000000]

const
  TESTFR_ACT_MSG_SIZE* = 6

when (CONFIG_CS104_SUPPORT_SERVER_MODE_SINGLE_REDUNDANCY_GROUP == 1):
  proc initializeMessageQueues*(self: CS104_Slave; lowPrioMaxQueueSize: cint;
                               highPrioMaxQueueSize: cint) =
    ##  initialized low priority queue
    when (CONFIG_CS104_SLAVE_POOL == 1):
      if lowPrioMaxQueueSize > CONFIG_CS104_MESSAGE_QUEUE_SIZE:
        lowPrioMaxQueueSize = CONFIG_CS104_MESSAGE_QUEUE_SIZE
    self.asduQueue = MessageQueue_create(lowPrioMaxQueueSize)
    ##  initialize high priority queue
    when (CONFIG_CS104_SLAVE_POOL == 1):
      if highPrioMaxQueueSize > CONFIG_CS104_MESSAGE_QUEUE_HIGH_PRIO_SIZE:
        highPrioMaxQueueSize = CONFIG_CS104_MESSAGE_QUEUE_HIGH_PRIO_SIZE
    self.connectionAsduQueue = HighPriorityASDUQueue_create(highPrioMaxQueueSize)

proc createSlave*(maxLowPrioQueueSize: cint; maxHighPrioQueueSize: cint): CS104_Slave =
  when (CONFIG_CS104_SLAVE_POOL == 1):
    var self: CS104_Slave = AllocateSlave()
  else:
    var self: CS104_Slave = cast[CS104_Slave](GLOBAL_MALLOC(sizeof(sCS104_Slave)))
  if self != nil:
    self.conParameters = defaultConnectionParameters
    self.alParameters = defaultAppLayerParameters
    self.asduHandler = nil
    self.interrogationHandler = nil
    self.counterInterrogationHandler = nil
    self.readHandler = nil
    self.clockSyncHandler = nil
    self.resetProcessHandler = nil
    self.delayAcquisitionHandler = nil
    self.connectionRequestHandler = nil
    self.connectionEventHandler = nil
    self.rawMessageHandler = nil
    self.maxLowPrioQueueSize = maxLowPrioQueueSize
    self.maxHighPrioQueueSize = maxHighPrioQueueSize
    var i: cint
    i = 0
    while i < CONFIG_CS104_MAX_CLIENT_CONNECTIONS:
      self.masterConnections[i] = nil
      inc(i)
    self.maxOpenConnections = CONFIG_CS104_MAX_CLIENT_CONNECTIONS
    when (CONFIG_USE_SEMAPHORES == 1):
      self.openConnectionsLock = Semaphore_create(1)
    when (CONFIG_USE_THREADS == 1):
      self.isThreadlessMode = false
    self.isRunning = false
    self.stopRunning = false
    self.localAddress = nil
    self.tcpPort = CS104_DEFAULT_PORT
    self.openConnections = 0
    self.listeningThread = nil
    self.serverSocket = nil
    when (CONFIG_CS104_SUPPORT_TLS == 1):
      self.tlsConfig = nil
    when (CONFIG_CS104_SUPPORT_SERVER_MODE_MULTIPLE_REDUNDANCY_GROUPS == 1):
      self.redundancyGroups = nil
    when (CONFIG_CS104_SUPPORT_SERVER_MODE_SINGLE_REDUNDANCY_GROUP == 1):
      self.serverMode = CS104_MODE_SINGLE_REDUNDANCY_GROUP
    else:
      when (CONFIG_CS104_SUPPORT_SERVER_MODE_CONNECTION_IS_REDUNDANCY_GROUP == 1):
        self.serverMode = CS104_MODE_CONNECTION_IS_REDUNDANCY_GROUP
  return self

proc CS104_Slave_create*(maxLowPrioQueueSize: cint; maxHighPrioQueueSize: cint): CS104_Slave =
  return createSlave(maxLowPrioQueueSize, maxHighPrioQueueSize)

when (CONFIG_CS104_SUPPORT_TLS == 1):
  proc CS104_Slave_createSecure*(maxLowPrioQueueSize: cint;
                                maxHighPrioQueueSize: cint;
                                tlsConfig: TLSConfiguration): CS104_Slave =
    var self: CS104_Slave = createSlave(maxLowPrioQueueSize, maxHighPrioQueueSize)
    if self != nil:
      self.tcpPort = 19998
      self.tlsConfig = tlsConfig
    return self

proc CS104_Slave_setServerMode*(self: CS104_Slave; serverMode: CS104_ServerMode) =
  self.serverMode = serverMode

proc CS104_Slave_setLocalAddress*(self: CS104_Slave; ipAddress: cstring) =
  when (CONFIG_CS104_SLAVE_POOL == 1):
    if ipAddress:
      self.localAddress = self._localAddress
      strncpy(self._localAddress, ipAddress, sizeof((self._localAddress)))
    else:
      self.localAddress = nil
  else:
    if self.localAddress:
      GLOBAL_FREEMEM(self.localAddress)
    self.localAddress = cast[cstring](GLOBAL_MALLOC(strlen(ipAddress) + 1))
    if self.localAddress:
      strcpy(self.localAddress, ipAddress)

proc CS104_Slave_setLocalPort*(self: CS104_Slave; tcpPort: cint) =
  self.tcpPort = tcpPort

proc CS104_Slave_getOpenConnections*(self: CS104_Slave): cint =
  var openConnections: cint
  when (CONFIG_USE_SEMAPHORES == 1):
    Semaphore_wait(self.openConnectionsLock)
  openConnections = self.openConnections
  when (CONFIG_USE_SEMAPHORES == 1):
    Semaphore_post(self.openConnectionsLock)
  return openConnections

proc addOpenConnection*(self: CS104_Slave; connection: MasterConnection) =
  when (CONFIG_USE_SEMAPHORES):
    Semaphore_wait(self.openConnectionsLock)
  var i: cint
  i = 0
  while i < CONFIG_CS104_MAX_CLIENT_CONNECTIONS:
    if self.masterConnections[i] == nil:
      self.masterConnections[i] = connection
      inc(self.openConnections)
      break
    inc(i)
  when (CONFIG_USE_SEMAPHORES):
    Semaphore_post(self.openConnectionsLock)

proc CS104_Slave_setMaxOpenConnections*(self: CS104_Slave; maxOpenConnections: cint) =
  if CONFIG_CS104_MAX_CLIENT_CONNECTIONS > 0:
    if maxOpenConnections > CONFIG_CS104_MAX_CLIENT_CONNECTIONS:
      maxOpenConnections = CONFIG_CS104_MAX_CLIENT_CONNECTIONS
  self.maxOpenConnections = maxOpenConnections

proc CS104_Slave_setConnectionRequestHandler*(self: CS104_Slave;
    handler: CS104_ConnectionRequestHandler; parameter: pointer) =
  self.connectionRequestHandler = handler
  self.connectionRequestHandlerParameter = parameter

proc CS104_Slave_setConnectionEventHandler*(self: CS104_Slave;
    handler: CS104_ConnectionEventHandler; parameter: pointer) =
  self.connectionEventHandler = handler
  self.connectionEventHandlerParameter = parameter

## *
##  Activate connection and deactivate existing active connections if required
##

proc CS104_Slave_activate*(self: CS104_Slave;
                          connectionToActivate: MasterConnection) =
  when (CONFIG_CS104_SUPPORT_SERVER_MODE_SINGLE_REDUNDANCY_GROUP == 1):
    if self.serverMode == CS104_MODE_SINGLE_REDUNDANCY_GROUP:
      ##  Deactivate all other connections
      when (CONFIG_USE_SEMAPHORES == 1):
        Semaphore_wait(self.openConnectionsLock)
      var i: cint
      i = 0
      while i < CONFIG_CS104_MAX_CLIENT_CONNECTIONS:
        var con: MasterConnection = self.masterConnections[i]
        if con:
          if con != connectionToActivate:
            MasterConnection_deactivate(con)
        inc(i)
      when (CONFIG_USE_SEMAPHORES == 1):
        Semaphore_post(self.openConnectionsLock)
  when (CONFIG_CS104_SUPPORT_SERVER_MODE_MULTIPLE_REDUNDANCY_GROUPS == 1):
    if self.serverMode == CS104_MODE_MULTIPLE_REDUNDANCY_GROUPS:
      ##  Deactivate all other connections of the same redundancy group
      when (CONFIG_USE_SEMAPHORES == 1):
        Semaphore_wait(self.openConnectionsLock)
      var i: cint
      i = 0
      while i < CONFIG_CS104_MAX_CLIENT_CONNECTIONS:
        var con: MasterConnection = self.masterConnections[i]
        if con:
          if con.redundancyGroup == connectionToActivate.redundancyGroup:
            if con != connectionToActivate:
              MasterConnection_deactivate(con)
        inc(i)
      when (CONFIG_USE_SEMAPHORES == 1):
        Semaphore_post(self.openConnectionsLock)
  MasterConnection_activate(connectionToActivate)

proc CS104_Slave_setInterrogationHandler*(self: CS104_Slave;
    handler: CS101_InterrogationHandler; parameter: pointer) =
  self.interrogationHandler = handler
  self.interrogationHandlerParameter = parameter

proc CS104_Slave_setCounterInterrogationHandler*(self: CS104_Slave;
    handler: CS101_CounterInterrogationHandler; parameter: pointer) =
  self.counterInterrogationHandler = handler
  self.counterInterrogationHandlerParameter = parameter

proc CS104_Slave_setReadHandler*(self: CS104_Slave; handler: CS101_ReadHandler;
                                parameter: pointer) =
  self.readHandler = handler
  self.readHandlerParameter = parameter

proc CS104_Slave_setASDUHandler*(self: CS104_Slave; handler: CS101_ASDUHandler;
                                parameter: pointer) =
  self.asduHandler = handler
  self.asduHandlerParameter = parameter

proc CS104_Slave_setClockSyncHandler*(self: CS104_Slave; handler: CS101_ClockSynchronizationHandler;
                                     parameter: pointer) =
  self.clockSyncHandler = handler
  self.clockSyncHandlerParameter = parameter

proc CS104_Slave_setRawMessageHandler*(self: CS104_Slave;
                                      handler: CS104_SlaveRawMessageHandler;
                                      parameter: pointer) =
  self.rawMessageHandler = handler
  self.rawMessageHandlerParameter = parameter

proc CS104_Slave_getConnectionParameters*(self: CS104_Slave): CS104_APCIParameters =
  return addr((self.conParameters))

proc CS104_Slave_getAppLayerParameters*(self: CS104_Slave): CS101_AppLayerParameters =
  return addr((self.alParameters))

## *******************************************************
##  MasterConnection
## *******************************************************

when (CONFIG_CS104_SLAVE_POOL == 1):
  type
    sMasterConnectionPool* {.bycopy.} = object
      con*: sMasterConnection
      used*: bool

  var conPoolInitialized*: bool = false
  var conPool*: array[CONFIG_CS104_MAX_CLIENT_CONNECTIONS *
      CONFIG_CS104_SLAVE_POOL_SIZE, sMasterConnectionPool]
  proc AllocateConnectionMemory*(): MasterConnection =
    var i: cint
    if not conPoolInitialized:
      i = 0
      while i <
          CONFIG_CS104_MAX_CLIENT_CONNECTIONS * CONFIG_CS104_SLAVE_POOL_SIZE:
        conPool[i].used = false
        inc(i)
      conPoolInitialized = true
    i = 0
    while i < CONFIG_CS104_MAX_CLIENT_CONNECTIONS * CONFIG_CS104_SLAVE_POOL_SIZE:
      if conPool[i].used == false:
        conPool[i].used = true
        return addr((conPool[i].con))
      inc(i)
    DEBUG_PRINT("AllocateConnectionMemory: failed\n")
    return nil

  proc ReleaseConnectionMemory*(con: MasterConnection) =
    var i: cint
    i = 0
    while i < CONFIG_CS104_MAX_CLIENT_CONNECTIONS * CONFIG_CS104_SLAVE_POOL_SIZE:
      if conPool[i].used == true:
        if addr((conPool[i].con)) == con:
          conPool[i].used = false
          return
      inc(i)
    DEBUG_PRINT("ReleaseConnectionMemory: failed\n")

proc printSendBuffer*(self: MasterConnection) =
  if self.oldestSentASDU != -1:
    var currentIndex: cint = self.oldestSentASDU
    var nextIndex: cint = 0
    DEBUG_PRINT("------k-buffer------\n")
    while true:
      DEBUG_PRINT("%02i : SeqNo=%i time=%llu : queueIdx=%i\n", currentIndex,
                  self.sentASDUs[currentIndex].seqNo,
                  self.sentASDUs[currentIndex].sentTime,
                  self.sentASDUs[currentIndex].queueIndex)
      if currentIndex == self.newestSentASDU:
        nextIndex = -1
      else:
        currentIndex = (currentIndex + 1) mod self.maxSentASDUs
      if not (nextIndex != -1):
        break
    DEBUG_PRINT("--------------------\n")
  else:
    DEBUG_PRINT("k-buffer is empty\n")

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

proc receiveMessage*(self: MasterConnection; buffer: ptr uint8_t): cint =
  when (CONFIG_CS104_SUPPORT_TLS == 1):
    if self.tlsSocket != nil:
      return receiveMessageTlsSocket(self.tlsSocket, buffer)
    else:
      return receiveMessageSocket(self.socket, buffer)
  else:
    return receiveMessageSocket(self.socket, buffer)

proc writeToSocket*(self: MasterConnection; buf: ptr uint8_t; size: cint): cint =
  if self.slave.rawMessageHandler:
    self.slave.rawMessageHandler(self.slave.rawMessageHandlerParameter,
                                 addr((self.iMasterConnection)), buf, size, true)
  when (CONFIG_CS104_SUPPORT_TLS == 1):
    if self.tlsSocket:
      return TLSSocket_write(self.tlsSocket, buf, size)
    else:
      return Socket_write(self.socket, buf, size)
  else:
    return Socket_write(self.socket, buf, size)

proc sendIMessage*(self: MasterConnection; buffer: ptr uint8_t; msgSize: cint): cint =
  buffer[0] = cast[uint8_t](0x00000000)
  buffer[1] = (uint8_t)(msgSize - 2)
  buffer[2] = (uint8_t)((self.sendCount mod 128) * 2)
  buffer[3] = (uint8_t)(self.sendCount div 128)
  buffer[4] = (uint8_t)((self.receiveCount mod 128) * 2)
  buffer[5] = (uint8_t)(self.receiveCount div 128)
  if writeToSocket(self, buffer, msgSize) > 0:
    DEBUG_PRINT("SEND I (size = %i) N(S) = %i N(R) = %i\n", msgSize,
                self.sendCount, self.receiveCount)
    self.sendCount = (self.sendCount + 1) mod 32768
    self.unconfirmedReceivedIMessages = 0
    self.timeoutT2Triggered = false
  else:
    self.isRunning = false
  self.unconfirmedReceivedIMessages = 0
  return self.sendCount

proc isSentBufferFull*(self: MasterConnection): bool =
  ##  locking of k-buffer has to be done by caller!
  if self.oldestSentASDU == -1:
    return false
  var newIndex: cint = (self.newestSentASDU + 1) mod (self.maxSentASDUs)
  if newIndex == self.oldestSentASDU:
    return true
  else:
    return false

proc sendASDU*(self: MasterConnection; asdu: ptr FrameBuffer; timestamp: uint64_t;
              index: cint) =
  var currentIndex: cint = 0
  if self.oldestSentASDU == -1:
    self.oldestSentASDU = 0
    self.newestSentASDU = 0
  else:
    currentIndex = (self.newestSentASDU + 1) mod self.maxSentASDUs
  self.sentASDUs[currentIndex].entryTime = timestamp
  self.sentASDUs[currentIndex].queueIndex = index
  self.sentASDUs[currentIndex].seqNo = sendIMessage(self, asdu.msg, asdu.msgSize)
  self.sentASDUs[currentIndex].sentTime = Hal_getTimeInMs()
  self.newestSentASDU = currentIndex
  printSendBuffer(self)

proc sendASDUInternal*(self: MasterConnection; asdu: CS101_ASDU): bool =
  var asduSent: bool
  if self.isActive:
    when (CONFIG_USE_SEMAPHORES == 1):
      Semaphore_wait(self.sentASDUsLock)
    if isSentBufferFull(self) == false:
      var frameBuffer: FrameBuffer
      var bufferFrame: sBufferFrame
      var frame: Frame = BufferFrame_initialize(addr(bufferFrame), frameBuffer.msg,
          IEC60870_5_104_APCI_LENGTH)
      CS101_ASDU_encode(asdu, frame)
      frameBuffer.msgSize = Frame_getMsgSize(frame)
      sendASDU(self, addr(frameBuffer), 0, -1)
      when (CONFIG_USE_SEMAPHORES == 1):
        Semaphore_post(self.sentASDUsLock)
      asduSent = true
    else:
      when (CONFIG_USE_SEMAPHORES == 1):
        Semaphore_post(self.sentASDUsLock)
      asduSent = HighPriorityASDUQueue_enqueue(self.highPrioQueue, asdu)
  else:
    asduSent = false
  if asduSent == false:
    DEBUG_PRINT("unable to send response (isActive=%i)\n", self.isActive)
  return asduSent

proc responseCOTUnknown*(asdu: CS101_ASDU; self: MasterConnection) =
  DEBUG_PRINT("  with unknown COT\n")
  CS101_ASDU_setCOT(asdu, CS101_COT_UNKNOWN_COT)
  CS101_ASDU_setNegative(asdu, true)
  sendASDUInternal(self, asdu)

##
##  Handle received ASDUs
##
##  Call the appropriate callbacks according to ASDU type and CoT
##

proc handleASDU*(self: MasterConnection; asdu: CS101_ASDU) =
  var messageHandled: bool = false
  var slave: CS104_Slave = self.slave
  var cot: uint8_t = CS101_ASDU_getCOT(asdu)
  case CS101_ASDU_getTypeID(asdu)
  of C_IC_NA_1:                ##  100 - interrogation command
    DEBUG_PRINT("Rcvd interrogation command C_IC_NA_1\n")
    if (cot == CS101_COT_ACTIVATION) or (cot == CS101_COT_DEACTIVATION):
      if slave.interrogationHandler != nil:
        var _io: uInformationObject
        var irc: InterrogationCommand = cast[InterrogationCommand](CS101_ASDU_getElementEx(
            asdu, (InformationObject) and _io, 0))
        if slave.interrogationHandler(slave.interrogationHandlerParameter,
                                     addr((self.iMasterConnection)), asdu,
                                     InterrogationCommand_getQOI(irc)):
          messageHandled = true
    else:
      responseCOTUnknown(asdu, self)
  of C_CI_NA_1:                ##  101 - counter interrogation command
    DEBUG_PRINT("Rcvd counter interrogation command C_CI_NA_1\n")
    if (cot == CS101_COT_ACTIVATION) or (cot == CS101_COT_DEACTIVATION):
      if slave.counterInterrogationHandler != nil:
        var _io: uInformationObject
        var cic: CounterInterrogationCommand = cast[CounterInterrogationCommand](CS101_ASDU_getElementEx(
            asdu, (InformationObject) and _io, 0))
        if slave.counterInterrogationHandler(
            slave.counterInterrogationHandlerParameter,
            addr((self.iMasterConnection)), asdu,
            CounterInterrogationCommand_getQCC(cic)):
          messageHandled = true
    else:
      responseCOTUnknown(asdu, self)
  of C_RD_NA_1:                ##  102 - read command
    DEBUG_PRINT("Rcvd read command C_RD_NA_1\n")
    if cot == CS101_COT_REQUEST:
      if slave.readHandler != nil:
        var _io: uInformationObject
        var rc: ReadCommand = cast[ReadCommand](CS101_ASDU_getElementEx(asdu,
            (InformationObject) and _io, 0))
        if slave.readHandler(slave.readHandlerParameter,
                            addr((self.iMasterConnection)), asdu, InformationObject_getObjectAddress(
            cast[InformationObject](rc))):
          messageHandled = true
    else:
      responseCOTUnknown(asdu, self)
  of C_CS_NA_1:                ##  103 - Clock synchronization command
    DEBUG_PRINT("Rcvd clock sync command C_CS_NA_1\n")
    if cot == CS101_COT_ACTIVATION:
      if slave.clockSyncHandler != nil:
        var _io: uInformationObject
        var csc: ClockSynchronizationCommand = cast[ClockSynchronizationCommand](CS101_ASDU_getElementEx(
            asdu, (InformationObject) and _io, 0))
        var newTime: CP56Time2a = ClockSynchronizationCommand_getTime(csc)
        if slave.clockSyncHandler(slave.clockSyncHandlerParameter,
                                 addr((self.iMasterConnection)), asdu, newTime):
          CS101_ASDU_removeAllElements(asdu)
          ClockSynchronizationCommand_create(csc, 0, newTime)
          CS101_ASDU_addInformationObject(asdu, cast[InformationObject](csc))
          CS101_ASDU_setCOT(asdu, CS101_COT_ACTIVATION_CON)
          CS104_Slave_enqueueASDU(slave, asdu)
        else:
          CS101_ASDU_setCOT(asdu, CS101_COT_ACTIVATION_CON)
          CS101_ASDU_setNegative(asdu, true)
          sendASDUInternal(self, asdu)
        messageHandled = true
    else:
      responseCOTUnknown(asdu, self)
  of C_TS_NA_1:                ##  104 - test command
    DEBUG_PRINT("Rcvd test command C_TS_NA_1\n")
    if cot != CS101_COT_ACTIVATION:
      CS101_ASDU_setCOT(asdu, CS101_COT_UNKNOWN_COT)
      CS101_ASDU_setNegative(asdu, true)
    else:
      CS101_ASDU_setCOT(asdu, CS101_COT_ACTIVATION_CON)
    sendASDUInternal(self, asdu)
    messageHandled = true
  of C_RP_NA_1:                ##  105 - Reset process command
    DEBUG_PRINT("Rcvd reset process command C_RP_NA_1\n")
    if cot == CS101_COT_ACTIVATION:
      if slave.resetProcessHandler != nil:
        var _io: uInformationObject
        var rpc: ResetProcessCommand = cast[ResetProcessCommand](CS101_ASDU_getElementEx(
            asdu, (InformationObject) and _io, 0))
        if slave.resetProcessHandler(slave.resetProcessHandlerParameter,
                                    addr((self.iMasterConnection)), asdu,
                                    ResetProcessCommand_getQRP(rpc)):
          messageHandled = true
    else:
      responseCOTUnknown(asdu, self)
  of C_CD_NA_1:                ##  106 - Delay acquisition command
    DEBUG_PRINT("Rcvd delay acquisition command C_CD_NA_1\n")
    if (cot == CS101_COT_ACTIVATION) or (cot == CS101_COT_SPONTANEOUS):
      if slave.delayAcquisitionHandler != nil:
        var _io: uInformationObject
        var dac: DelayAcquisitionCommand = cast[DelayAcquisitionCommand](CS101_ASDU_getElementEx(
            asdu, (InformationObject) and _io, 0))
        if slave.delayAcquisitionHandler(slave.delayAcquisitionHandlerParameter,
                                        addr((self.iMasterConnection)), asdu,
                                        DelayAcquisitionCommand_getDelay(dac)):
          messageHandled = true
    else:
      responseCOTUnknown(asdu, self)
  else:                       ##  no special handler available -> use default handler
    nil
  if (messageHandled == false) and (slave.asduHandler != nil):
    if slave.asduHandler(slave.asduHandlerParameter,
                        addr((self.iMasterConnection)), asdu):
      messageHandled = true
  if messageHandled == false:
    ##  send error response
    CS101_ASDU_setCOT(asdu, CS101_COT_UNKNOWN_TYPE_ID)
    CS101_ASDU_setNegative(asdu, true)
    sendASDUInternal(self, asdu)

proc checkSequenceNumber*(self: MasterConnection; seqNo: cint): bool =
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
    ##  two cases are required to reflect sequence number overflow
    var oldestAsduSeqNo: cint = self.sentASDUs[self.oldestSentASDU].seqNo
    var newestAsduSeqNo: cint = self.sentASDUs[self.newestSentASDU].seqNo
    if oldestAsduSeqNo <= newestAsduSeqNo:
      if (seqNo >= oldestAsduSeqNo) and (seqNo <= newestAsduSeqNo):
        seqNoIsValid = true
    else:
      if (seqNo >= oldestAsduSeqNo) or (seqNo <= newestAsduSeqNo):
        seqNoIsValid = true
      counterOverflowDetected = true
    ##  check if confirmed message was already removed from list
    if oldestAsduSeqNo == 0:
      oldestValidSeqNo = 32767
    else:
      oldestValidSeqNo = (oldestAsduSeqNo - 1) mod 32768
    if oldestValidSeqNo == seqNo:
      seqNoIsValid = true
  if seqNoIsValid:
    if self.oldestSentASDU != -1:
      while true:
        var oldestAsduSeqNo: cint = self.sentASDUs[self.oldestSentASDU].seqNo
        if counterOverflowDetected == false:
          if seqNo < oldestAsduSeqNo:
            break
        if seqNo == oldestValidSeqNo:
          break
        if self.sentASDUs[self.oldestSentASDU].queueIndex != -1:
          MessageQueue_markAsduAsConfirmed(self.lowPrioQueue,
              self.sentASDUs[self.oldestSentASDU].queueIndex,
              self.sentASDUs[self.oldestSentASDU].entryTime)
        if oldestAsduSeqNo == seqNo:
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
  else:
    DEBUG_PRINT("Received sequence number out of range")
  when (CONFIG_USE_SEMAPHORES == 1):
    Semaphore_post(self.sentASDUsLock)
  return seqNoIsValid

proc resetT3Timeout*(self: MasterConnection) =
  self.nextT3Timeout = Hal_getTimeInMs() +
      (uint64_t)(self.slave.conParameters.t3 * 1000)

proc handleMessage*(self: MasterConnection; buffer: ptr uint8_t; msgSize: cint): bool =
  var currentTime: uint64_t = Hal_getTimeInMs()
  if (buffer[2] and 1) == 0:
    if msgSize < 7:
      DEBUG_PRINT("Received I msg too small!\n")
      return false
    if self.timeoutT2Triggered == false:
      self.timeoutT2Triggered = true
      self.lastConfirmationTime = currentTime
      ##  start timeout T2
    var frameSendSequenceNumber: cint = ((buffer[3] * 0x00000000) +
        (buffer[2] and 0x00000000)) div 2
    var frameRecvSequenceNumber: cint = ((buffer[5] * 0x00000000) +
        (buffer[4] and 0x00000000)) div 2
    DEBUG_PRINT("Received I frame: N(S) = %i N(R) = %i\n",
                frameSendSequenceNumber, frameRecvSequenceNumber)
    if frameSendSequenceNumber != self.receiveCount:
      DEBUG_PRINT("Sequence error: Close connection!")
      return false
    if checkSequenceNumber(self, frameRecvSequenceNumber) == false:
      DEBUG_PRINT("Sequence number check failed")
      return false
    self.receiveCount = (self.receiveCount + 1) mod 32768
    inc(self.unconfirmedReceivedIMessages)
    if self.isActive:
      var asdu: CS101_ASDU = CS101_ASDU_createFromBuffer(
          addr((self.slave.alParameters)), buffer + 6, msgSize - 6)
      handleASDU(self, asdu)
      CS101_ASDU_destroy(asdu)
    else:
      DEBUG_PRINT("Connection not activated. Skip I message")
  elif (buffer[2] and 0x00000000) == 0x00000000: ##  Check for STARTDT_ACT message
    DEBUG_PRINT("Send TESTFR_CON\n")
    if writeToSocket(self, TESTFR_CON_MSG, TESTFR_CON_MSG_SIZE) < 0:
      return false
  elif (buffer[2] and 0x00000000) == 0x00000000: ##  Check for STOPDT_ACT message
    CS104_Slave_activate(self.slave, self)
    HighPriorityASDUQueue_resetConnectionQueue(self.highPrioQueue)
    DEBUG_PRINT("Send STARTDT_CON\n")
    if writeToSocket(self, STARTDT_CON_MSG, STARTDT_CON_MSG_SIZE) < 0:
      return false
  elif (buffer[2] and 0x00000000) == 0x00000000: ##  Check for TESTFR_CON message
    MasterConnection_deactivate(self)
    DEBUG_PRINT("Send STOPDT_CON\n")
    if writeToSocket(self, STOPDT_CON_MSG, STOPDT_CON_MSG_SIZE) < 0:
      return false
  elif (buffer[2] and 0x00000000) == 0x00000000:
    DEBUG_PRINT("Recv TESTFR_CON\n")
    self.outstandingTestFRConMessages = 0
  elif buffer[2] == 0x00000000:
    ##  S-message
    var seqNo: cint = (buffer[4] + buffer[5] * 0x00000000) div 2
    DEBUG_PRINT("Rcvd S(%i) (own sendcounter = %i)\n", seqNo, self.sendCount)
    if checkSequenceNumber(self, seqNo) == false:
      return false
  else:
    DEBUG_PRINT("unknown message - IGNORE\n")
    return true
  resetT3Timeout(self)
  return true

proc sendSMessage*(self: MasterConnection) =
  var msg: array[6, uint8_t]
  msg[0] = 0x00000000
  msg[1] = 0x00000000
  msg[2] = 0x00000000
  msg[3] = 0
  msg[4] = (uint8_t)((self.receiveCount mod 128) * 2)
  msg[5] = (uint8_t)(self.receiveCount div 128)
  if writeToSocket(self, msg, 6) < 0:
    self.isRunning = false

proc MasterConnection_destroy*(self: MasterConnection) =
  if self:
    when (CONFIG_CS104_SUPPORT_TLS == 1):
      if self.tlsSocket != nil:
        TLSSocket_close(self.tlsSocket)
    Socket_destroy(self.socket)
    when (CONFIG_CS104_SLAVE_POOL != 1):
      GLOBAL_FREEMEM(self.sentASDUs)
    when (CONFIG_USE_SEMAPHORES == 1):
      Semaphore_destroy(self.sentASDUsLock)
    Handleset_destroy(self.handleSet)
    when (CONFIG_CS104_SLAVE_POOL == 1):
      ReleaseConnectionMemory(self)
    else:
      GLOBAL_FREEMEM(self)

proc sendNextLowPriorityASDU*(self: MasterConnection) =
  when (CONFIG_USE_SEMAPHORES == 1):
    Semaphore_wait(self.sentASDUsLock)
  var asdu: ptr FrameBuffer
  if isSentBufferFull(self):
    break exit_function
  MessageQueue_lock(self.lowPrioQueue)
  var timestamp: uint64_t
  var queueIndex: cint
  asdu = MessageQueue_getNextWaitingASDU(self.lowPrioQueue, addr(timestamp),
                                       addr(queueIndex))
  if asdu != nil:
    sendASDU(self, asdu, timestamp, queueIndex)
  MessageQueue_unlock(self.lowPrioQueue)
  when (CONFIG_USE_SEMAPHORES == 1):
    Semaphore_post(self.sentASDUsLock)
  return

proc sendNextHighPriorityASDU*(self: MasterConnection): bool =
  var retVal: bool = false
  var msg: ptr FrameBuffer
  when (CONFIG_USE_SEMAPHORES == 1):
    Semaphore_wait(self.sentASDUsLock)
  if isSentBufferFull(self):
    break exit_function
  HighPriorityASDUQueue_lock(self.highPrioQueue)
  msg = HighPriorityASDUQueue_getNextASDU(self.highPrioQueue)
  if msg != nil:
    sendASDU(self, msg, 0, -1)
    retVal = true
  HighPriorityASDUQueue_unlock(self.highPrioQueue)
  when (CONFIG_USE_SEMAPHORES == 1):
    Semaphore_post(self.sentASDUsLock)
  return retVal

## *
##  Send all high-priority ASDUs and the last waiting ASDU from the low-priority queue.
##  Returns true if ASDUs are still waiting. This can happen when there are more ASDUs
##  in the event (low-priority) buffer, or the connection is unavailable to send the high-priority
##  ASDUs (congestion or connection lost).
##

proc sendWaitingASDUs*(self: MasterConnection): bool =
  ##  send all available high priority ASDUs first
  while HighPriorityASDUQueue_isAsduAvailable(self.highPrioQueue):
    if sendNextHighPriorityASDU(self) == false:
      return true
    if self.isRunning == false:
      return true
  ##  send messages from low-priority queue
  sendNextLowPriorityASDU(self)
  if MessageQueue_isAsduAvailable(self.lowPrioQueue):
    return true
  else:
    return false

proc handleTimeouts*(self: MasterConnection): bool =
  var currentTime: uint64_t = Hal_getTimeInMs()
  var timeoutsOk: bool = true
  ##  check T3 timeout
  if currentTime > self.nextT3Timeout:
    if self.outstandingTestFRConMessages > 2:
      DEBUG_PRINT("Timeout for TESTFR CON message\n")
      ##  close connection
      timeoutsOk = false
    else:
      if writeToSocket(self, TESTFR_ACT_MSG, TESTFR_ACT_MSG_SIZE) < 0:
        DEBUG_PRINT("Failed to write TESTFR ACT message\n")
        self.isRunning = false
      inc(self.outstandingTestFRConMessages)
      resetT3Timeout(self)
  if self.unconfirmedReceivedIMessages > 0:
    if (currentTime - self.lastConfirmationTime) >=
        (uint64_t)(self.slave.conParameters.t2 * 1000):
      self.lastConfirmationTime = currentTime
      self.unconfirmedReceivedIMessages = 0
      self.timeoutT2Triggered = false
      sendSMessage(self)
  when (CONFIG_USE_SEMAPHORES == 1):
    Semaphore_wait(self.sentASDUsLock)
  ##  check if counterpart confirmed I message
  if self.oldestSentASDU != -1:
    if currentTime > self.sentASDUs[self.oldestSentASDU].sentTime:
      if (currentTime - self.sentASDUs[self.oldestSentASDU].sentTime) >=
          (uint64_t)(self.slave.conParameters.t1 * 1000):
        timeoutsOk = false
        printSendBuffer(self)
        DEBUG_PRINT("I message timeout for %i seqNo: %i\n", self.oldestSentASDU,
                    self.sentASDUs[self.oldestSentASDU].seqNo)
  when (CONFIG_USE_SEMAPHORES == 1):
    Semaphore_post(self.sentASDUsLock)
  return timeoutsOk

proc CS104_Slave_removeConnection*(self: CS104_Slave; connection: MasterConnection) =
  when (CONFIG_USE_SEMAPHORES):
    Semaphore_wait(self.openConnectionsLock)
  dec(self.openConnections)
  var i: cint
  i = 0
  while i < CONFIG_CS104_MAX_CLIENT_CONNECTIONS:
    if self.masterConnections[i] == connection:
      self.masterConnections[i] = nil
      break
    inc(i)
  MasterConnection_destroy(connection)
  when (CONFIG_USE_SEMAPHORES):
    Semaphore_post(self.openConnectionsLock)

proc connectionHandlingThread*(parameter: pointer): pointer =
  var self: MasterConnection = cast[MasterConnection](parameter)
  self.isRunning = true
  resetT3Timeout(self)
  var isAsduWaiting: bool = false
  if self.slave.connectionEventHandler:
    self.slave.connectionEventHandler(self.slave.connectionEventHandlerParameter,
                                      addr((self.iMasterConnection)),
                                      CS104_CON_EVENT_CONNECTION_OPENED)
  while self.isRunning:
    Handleset_reset(self.handleSet)
    Handleset_addSocket(self.handleSet, self.socket)
    var socketTimeout: cint
    ##
    ##  When an ASDU is waiting only have a short look to see if a client request
    ##  was received. Otherwise wait to save CPU time.
    ##
    if isAsduWaiting:
      socketTimeout = 1
    else:
      socketTimeout = 100
    if Handleset_waitReady(self.handleSet, socketTimeout):
      var bytesRec: cint = receiveMessage(self, self.buffer)
      if self.slave.rawMessageHandler:
        self.slave.rawMessageHandler(self.slave.rawMessageHandlerParameter,
                                     addr((self.iMasterConnection)), self.buffer,
                                     bytesRec, false)
      if bytesRec == -1:
        DEBUG_PRINT("Error reading from socket\n")
        break
      if bytesRec > 0:
        DEBUG_PRINT("Connection: rcvd msg(%i bytes)\n", bytesRec)
        if self.slave.rawMessageHandler:
          self.slave.rawMessageHandler(self.slave.rawMessageHandlerParameter,
                                       addr((self.iMasterConnection)),
                                       self.buffer, bytesRec, false)
        if handleMessage(self, self.buffer, bytesRec) == false:
          self.isRunning = false
        if self.unconfirmedReceivedIMessages >= self.slave.conParameters.w:
          self.lastConfirmationTime = Hal_getTimeInMs()
          self.unconfirmedReceivedIMessages = 0
          self.timeoutT2Triggered = false
          sendSMessage(self)
    if handleTimeouts(self) == false:
      self.isRunning = false
    if self.isRunning:
      if self.isActive:
        isAsduWaiting = sendWaitingASDUs(self)
  if self.slave.connectionEventHandler:
    self.slave.connectionEventHandler(self.slave.connectionEventHandlerParameter,
                                      addr((self.iMasterConnection)),
                                      CS104_CON_EVENT_CONNECTION_CLOSED)
  DEBUG_PRINT("Connection closed\n")
  self.isRunning = false
  when (CONFIG_CS104_SUPPORT_SERVER_MODE_CONNECTION_IS_REDUNDANCY_GROUP == 1):
    if self.slave.serverMode == CS104_MODE_CONNECTION_IS_REDUNDANCY_GROUP:
      MessageQueue_destroy(self.lowPrioQueue)
      HighPriorityASDUQueue_destroy(self.highPrioQueue)
  CS104_Slave_removeConnection(self.slave, self)
  return nil

## *******************************************
##  IMasterConnection
## *****************************************

proc _IMasterConnection_sendASDU*(self: IMasterConnection; asdu: CS101_ASDU) =
  var con: MasterConnection = cast[MasterConnection](self.`object`)
  sendASDUInternal(con, asdu)

proc _IMasterConnection_sendACT_CON*(self: IMasterConnection; asdu: CS101_ASDU;
                                    negative: bool) =
  CS101_ASDU_setCOT(asdu, CS101_COT_ACTIVATION_CON)
  CS101_ASDU_setNegative(asdu, negative)
  _IMasterConnection_sendASDU(self, asdu)

proc _IMasterConnection_sendACT_TERM*(self: IMasterConnection; asdu: CS101_ASDU) =
  CS101_ASDU_setCOT(asdu, CS101_COT_ACTIVATION_TERMINATION)
  CS101_ASDU_setNegative(asdu, false)
  _IMasterConnection_sendASDU(self, asdu)

proc _IMasterConnection_close*(self: IMasterConnection) =
  var con: MasterConnection = cast[MasterConnection](self.`object`)
  MasterConnection_close(con)

proc _IMasterConnection_getPeerAddress*(self: IMasterConnection; addrBuf: cstring;
                                       addrBufSize: cint): cint =
  var con: MasterConnection = cast[MasterConnection](self.`object`)
  var buf: array[50, char]
  var addrStr: cstring = Socket_getPeerAddressStatic(con.socket, buf)
  if addrStr == nil:
    return 0
  var len: cint = strlen(buf)
  if len < addrBufSize:
    strcpy(addrBuf, buf)
    return len
  else:
    return 0

proc _IMasterConnection_getApplicationLayerParameters*(self: IMasterConnection): CS101_AppLayerParameters =
  var con: MasterConnection = cast[MasterConnection](self.`object`)
  return addr((con.slave.alParameters))

## *******************************************
##  END IMasterConnection
## *****************************************

proc MasterConnection_create*(slave: CS104_Slave; socket: Socket;
                             lowPrioQueue: MessageQueue;
                             highPrioQueue: HighPriorityASDUQueue): MasterConnection =
  when (CONFIG_CS104_SLAVE_POOL == 1):
    var self: MasterConnection = AllocateConnectionMemory()
    ## #else
    ##     MasterConnection self = (MasterConnection) GLOBAL_MALLOC(sizeof(struct sMasterConnection));
  if self != nil:
    self.slave = slave
    self.socket = socket
    self.isActive = false
    self.isRunning = false
    self.receiveCount = 0
    self.sendCount = 0
    self.unconfirmedReceivedIMessages = 0
    self.lastConfirmationTime = UINT64_MAX
    self.timeoutT2Triggered = false
    self.maxSentASDUs = slave.conParameters.k
    self.oldestSentASDU = -1
    self.newestSentASDU = -1
    when (CONFIG_CS104_SLAVE_POOL == 1):
      if slave.conParameters.k > CONFIG_CS104_MAX_K_BUFFER_SIZE:
        DEBUG_PRINT("Parameter k is to large!\n")
        self.maxSentASDUs = CONFIG_CS104_MAX_K_BUFFER_SIZE
    self.iMasterConnection.`object` = self
    self.iMasterConnection.getApplicationLayerParameters = _IMasterConnection_getApplicationLayerParameters
    self.iMasterConnection.sendASDU = _IMasterConnection_sendASDU
    self.iMasterConnection.sendACT_CON = _IMasterConnection_sendACT_CON
    self.iMasterConnection.sendACT_TERM = _IMasterConnection_sendACT_TERM
    self.iMasterConnection.close = _IMasterConnection_close
    self.iMasterConnection.getPeerAddress = _IMasterConnection_getPeerAddress
    resetT3Timeout(self)
    when (CONFIG_USE_SEMAPHORES == 1):
      self.sentASDUsLock = Semaphore_create(1)
    when (CONFIG_CS104_SUPPORT_TLS == 1):
      if slave.tlsConfig != nil:
        self.tlsSocket = TLSSocket_create(socket, slave.tlsConfig, false)
        if self.tlsSocket == nil:
          DEBUG_PRINT("Close connection\n")
          MasterConnection_destroy(self)
          return nil
      else:
        self.tlsSocket = nil
    self.lowPrioQueue = lowPrioQueue
    self.highPrioQueue = highPrioQueue
    self.outstandingTestFRConMessages = 0
    self.handleSet = Handleset_new()
  return self

when (CONFIG_CS104_SUPPORT_SERVER_MODE_MULTIPLE_REDUNDANCY_GROUPS == 1):
  proc MasterConnection_createEx*(slave: CS104_Slave; socket: Socket;
                                 redGroup: CS104_RedundancyGroup): MasterConnection =
    var self: MasterConnection = MasterConnection_create(slave, socket,
        redGroup.asduQueue, redGroup.connectionAsduQueue)
    if self:
      self.redundancyGroup = redGroup
    return self

proc MasterConnection_start*(self: MasterConnection) =
  var newThread: Thread = Thread_create(cast[ThreadExecutionFunction](connectionHandlingThread),
                                    cast[pointer](self), true)
  Thread_start(newThread)

proc MasterConnection_close*(self: MasterConnection) =
  self.isRunning = false

proc MasterConnection_deactivate*(self: MasterConnection) =
  if self.isActive == true:
    if self.slave.connectionEventHandler:
      self.slave.connectionEventHandler(self.slave.connectionEventHandlerParameter,
                                        addr((self.iMasterConnection)),
                                        CS104_CON_EVENT_DEACTIVATED)
  self.isActive = false

proc MasterConnection_activate*(self: MasterConnection) =
  if self.isActive == false:
    if self.slave.connectionEventHandler:
      self.slave.connectionEventHandler(self.slave.connectionEventHandlerParameter,
                                        addr((self.iMasterConnection)),
                                        CS104_CON_EVENT_ACTIVATED)
  self.isActive = true

proc MasterConnection_handleTcpConnection*(self: MasterConnection) =
  var bytesRec: cint = receiveMessage(self, self.buffer)
  if bytesRec < 0:
    DEBUG_PRINT("Error reading from socket\n")
    self.isRunning = false
  if (bytesRec > 0) and (self.isRunning):
    if self.slave.rawMessageHandler:
      self.slave.rawMessageHandler(self.slave.rawMessageHandlerParameter,
                                   addr((self.iMasterConnection)), self.buffer,
                                   bytesRec, false)
    if handleMessage(self, self.buffer, bytesRec) == false:
      self.isRunning = false
    if self.unconfirmedReceivedIMessages >= self.slave.conParameters.w:
      self.lastConfirmationTime = Hal_getTimeInMs()
      self.unconfirmedReceivedIMessages = 0
      self.timeoutT2Triggered = false
      sendSMessage(self)

proc MasterConnection_executePeriodicTasks*(self: MasterConnection) =
  if self.isActive:
    sendWaitingASDUs(self)
  if handleTimeouts(self) == false:
    self.isRunning = false

proc handleClientConnections*(self: CS104_Slave) =
  var handleset: HandleSet = nil
  if self.openConnections > 0:
    var i: cint
    var first: bool = true
    i = 0
    while i < CONFIG_CS104_MAX_CLIENT_CONNECTIONS:
      var con: MasterConnection = self.masterConnections[i]
      if con != nil:
        if con.isRunning:
          if first:
            handleset = con.handleSet
            Handleset_reset(handleset)
            first = false
          Handleset_addSocket(handleset, con.socket)
        else:
          if self.connectionEventHandler:
            self.connectionEventHandler(self.connectionEventHandlerParameter,
                                        addr((con.iMasterConnection)),
                                        CS104_CON_EVENT_CONNECTION_CLOSED)
          DEBUG_PRINT("Connection closed\n")
          self.masterConnections[i] = nil
          dec(self.openConnections)
          MasterConnection_destroy(con)
      inc(i)
    ##  handle incoming messages when available
    if handleset != nil:
      if Handleset_waitReady(handleset, 1):
        i = 0
        while i < CONFIG_CS104_MAX_CLIENT_CONNECTIONS:
          var con: MasterConnection = self.masterConnections[i]
          if con != nil:
            MasterConnection_handleTcpConnection(con)
          inc(i)
    i = 0
    while i < CONFIG_CS104_MAX_CLIENT_CONNECTIONS:
      var con: MasterConnection = self.masterConnections[i]
      if con != nil:
        if con.isRunning:
          MasterConnection_executePeriodicTasks(con)
      inc(i)

proc getPeerAddress*(socket: Socket; ipAddress: cstring): cstring =
  var ipAddrStr: cstring
  Socket_getPeerAddressStatic(socket, ipAddress)
  ##  remove TCP port part
  if ipAddress[0] == '[':
    ##  IPV6 address
    ipAddrStr = ipAddress + 1
    var separator: cstring = strchr(ipAddrStr, ']')
    if separator != nil:
      separator[] = 0
  else:
    ##  IPV4 address
    ipAddrStr = ipAddress
    var separator: cstring = strchr(ipAddrStr, ':')
    if separator != nil:
      separator[] = 0
  return ipAddrStr

proc callConnectionRequestHandler*(self: CS104_Slave; newSocket: Socket): bool =
  if self.connectionRequestHandler != nil:
    var ipAddress: array[60, char]
    var ipAddrStr: cstring = getPeerAddress(newSocket, ipAddress)
    return self.connectionRequestHandler(self.connectionRequestHandlerParameter,
                                        ipAddrStr)
  else:
    return true

proc getMatchingRedundancyGroup*(self: CS104_Slave; ipAddrStr: cstring): CS104_RedundancyGroup =
  var ipAddress: sCS104_IPAddress
  CS104_IPAddress_setFromString(addr(ipAddress), ipAddrStr)
  var catchAllGroup: CS104_RedundancyGroup = nil
  var matchingGroup: CS104_RedundancyGroup = nil
  var element: LinkedList = LinkedList_getNext(self.redundancyGroups)
  while element:
    var redGroup: CS104_RedundancyGroup = cast[CS104_RedundancyGroup](LinkedList_getData(
        element))
    if CS104_RedundancyGroup_matches(redGroup, addr(ipAddress)):
      matchingGroup = redGroup
      break
    if CS104_RedundancyGroup_isCatchAll(redGroup):
      catchAllGroup = redGroup
    element = LinkedList_getNext(element)
  if matchingGroup == nil:
    matchingGroup = catchAllGroup
  return matchingGroup

##  handle TCP connections in non-threaded mode

proc handleConnectionsThreadless*(self: CS104_Slave) =
  if (self.maxOpenConnections < 1) or
      (self.openConnections < self.maxOpenConnections):
    var newSocket: Socket = ServerSocket_accept(self.serverSocket)
    if newSocket != nil:
      var acceptConnection: bool = true
      if acceptConnection:
        acceptConnection = callConnectionRequestHandler(self, newSocket)
      if acceptConnection:
        var lowPrioQueue: MessageQueue = nil
        var highPrioQueue: HighPriorityASDUQueue = nil
        when (CONFIG_CS104_SUPPORT_SERVER_MODE_SINGLE_REDUNDANCY_GROUP == 1):
          if self.serverMode == CS104_MODE_SINGLE_REDUNDANCY_GROUP:
            lowPrioQueue = self.asduQueue
            highPrioQueue = self.connectionAsduQueue
        when (CONFIG_CS104_SUPPORT_SERVER_MODE_CONNECTION_IS_REDUNDANCY_GROUP ==
            1):
          if self.serverMode == CS104_MODE_CONNECTION_IS_REDUNDANCY_GROUP:
            lowPrioQueue = MessageQueue_create(self.maxLowPrioQueueSize)
            highPrioQueue = HighPriorityASDUQueue_create(self.maxHighPrioQueueSize)
        var connection: MasterConnection = nil
        when (CONFIG_CS104_SUPPORT_SERVER_MODE_MULTIPLE_REDUNDANCY_GROUPS == 1):
          if self.serverMode == CS104_MODE_MULTIPLE_REDUNDANCY_GROUPS:
            var ipAddress: array[60, char]
            var ipAddrStr: cstring = getPeerAddress(newSocket, ipAddress)
            var matchingGroup: CS104_RedundancyGroup = getMatchingRedundancyGroup(
                self, ipAddrStr)
            if matchingGroup != nil:
              connection = MasterConnection_createEx(self, newSocket, matchingGroup)
              if matchingGroup.name:
                DEBUG_PRINT("Add connection to group: %s\n", matchingGroup.name)
            else:
              DEBUG_PRINT("Found no matching redundancy group -> close connection\n")
          else:
            connection = MasterConnection_create(self, newSocket, lowPrioQueue,
                highPrioQueue)
        else:
          connection = MasterConnection_create(self, newSocket, lowPrioQueue,
              highPrioQueue)
        if connection:
          addOpenConnection(self, connection)
          connection.isRunning = true
          if self.connectionEventHandler:
            self.connectionEventHandler(self.connectionEventHandlerParameter,
                                        addr((connection.iMasterConnection)),
                                        CS104_CON_EVENT_CONNECTION_OPENED)
        else:
          Socket_destroy(newSocket)
          DEBUG_PRINT("Connection attempt failed!\n")
      else:
        Socket_destroy(newSocket)
  handleClientConnections(self)

proc serverThread*(parameter: pointer): pointer =
  var self: CS104_Slave = cast[CS104_Slave](parameter)
  if self.localAddress:
    self.serverSocket = TcpServerSocket_create(self.localAddress, self.tcpPort)
  else:
    self.serverSocket = TcpServerSocket_create("0.0.0.0", self.tcpPort)
  if self.serverSocket == nil:
    DEBUG_PRINT("Cannot create server socket\n")
    self.isStarting = false
    break exit_function
  ServerSocket_listen(self.serverSocket)
  self.isRunning = true
  self.isStarting = false
  while self.stopRunning == false:
    var newSocket: Socket = ServerSocket_accept(self.serverSocket)
    if newSocket != nil:
      var acceptConnection: bool = true
      ##  check if maximum number of open connections is reached
      if self.maxOpenConnections > 0:
        if self.openConnections >= self.maxOpenConnections:
          acceptConnection = false
      if acceptConnection:
        acceptConnection = callConnectionRequestHandler(self, newSocket)
      if acceptConnection:
        var lowPrioQueue: MessageQueue = nil
        var highPrioQueue: HighPriorityASDUQueue = nil
        when (CONFIG_CS104_SUPPORT_SERVER_MODE_SINGLE_REDUNDANCY_GROUP == 1):
          if self.serverMode == CS104_MODE_SINGLE_REDUNDANCY_GROUP:
            lowPrioQueue = self.asduQueue
            highPrioQueue = self.connectionAsduQueue
        when (CONFIG_CS104_SUPPORT_SERVER_MODE_CONNECTION_IS_REDUNDANCY_GROUP ==
            1):
          if self.serverMode == CS104_MODE_CONNECTION_IS_REDUNDANCY_GROUP:
            lowPrioQueue = MessageQueue_create(self.maxLowPrioQueueSize)
            highPrioQueue = HighPriorityASDUQueue_create(self.maxHighPrioQueueSize)
        var connection: MasterConnection = nil
        when (CONFIG_CS104_SUPPORT_SERVER_MODE_MULTIPLE_REDUNDANCY_GROUPS == 1):
          if self.serverMode == CS104_MODE_MULTIPLE_REDUNDANCY_GROUPS:
            var ipAddress: array[60, char]
            var ipAddrStr: cstring = getPeerAddress(newSocket, ipAddress)
            var matchingGroup: CS104_RedundancyGroup = getMatchingRedundancyGroup(
                self, ipAddrStr)
            if matchingGroup != nil:
              connection = MasterConnection_createEx(self, newSocket, matchingGroup)
              if matchingGroup.name:
                DEBUG_PRINT("Add connection to group: %s\n", matchingGroup.name)
            else:
              DEBUG_PRINT("Found no matching redundancy group -> close connection\n")
          else:
            connection = MasterConnection_create(self, newSocket, lowPrioQueue,
                highPrioQueue)
        else:
          connection = MasterConnection_create(self, newSocket, lowPrioQueue,
              highPrioQueue)
        if connection:
          addOpenConnection(self, connection)
          ##  now start the connection handling (thread)
          MasterConnection_start(connection)
        else:
          DEBUG_PRINT("Connection attempt failed!")
      else:
        Socket_destroy(newSocket)
    else:
      Thread_sleep(10)
  if self.serverSocket:
    Socket_destroy(cast[Socket](self.serverSocket))
  self.isRunning = false
  self.stopRunning = false
  return nil

proc CS104_Slave_enqueueASDU*(self: CS104_Slave; asdu: CS101_ASDU) =
  when (CONFIG_CS104_SUPPORT_SERVER_MODE_SINGLE_REDUNDANCY_GROUP == 1):
    if self.serverMode == CS104_MODE_SINGLE_REDUNDANCY_GROUP:
      MessageQueue_enqueueASDU(self.asduQueue, asdu)
  when (CONFIG_CS104_SUPPORT_SERVER_MODE_MULTIPLE_REDUNDANCY_GROUPS == 1):
    if self.serverMode == CS104_MODE_MULTIPLE_REDUNDANCY_GROUPS:
      ## ***********************************************
      ##  Dispatch event to all redundancy groups
      ## **********************************************
      var element: LinkedList = LinkedList_getNext(self.redundancyGroups)
      while element:
        var group: CS104_RedundancyGroup = cast[CS104_RedundancyGroup](LinkedList_getData(
            element))
        MessageQueue_enqueueASDU(group.asduQueue, asdu)
        element = LinkedList_getNext(element)
  when (CONFIG_CS104_SUPPORT_SERVER_MODE_CONNECTION_IS_REDUNDANCY_GROUP == 1):
    if self.serverMode == CS104_MODE_CONNECTION_IS_REDUNDANCY_GROUP:
      when (CONFIG_USE_SEMAPHORES == 1):
        Semaphore_wait(self.openConnectionsLock)
      ## ***********************************************
      ##  Dispatch event to all open client connections
      ## **********************************************
      var i: cint
      i = 0
      while i < CONFIG_CS104_MAX_CLIENT_CONNECTIONS:
        var con: MasterConnection = self.masterConnections[i]
        if con:
          MessageQueue_enqueueASDU(con.lowPrioQueue, asdu)
        inc(i)
      when (CONFIG_USE_SEMAPHORES == 1):
        Semaphore_post(self.openConnectionsLock)

proc CS104_Slave_addRedundancyGroup*(self: CS104_Slave;
                                    redundancyGroup: CS104_RedundancyGroup) =
  when (CONFIG_CS104_SUPPORT_SERVER_MODE_MULTIPLE_REDUNDANCY_GROUPS == 1):
    if self.serverMode == CS104_MODE_MULTIPLE_REDUNDANCY_GROUPS:
      if self.redundancyGroups == nil:
        self.redundancyGroups = LinkedList_create()
      LinkedList_add(self.redundancyGroups, redundancyGroup)

when (CONFIG_CS104_SUPPORT_SERVER_MODE_MULTIPLE_REDUNDANCY_GROUPS == 1):
  proc initializeRedundancyGroups*(self: CS104_Slave; lowPrioMaxQueueSize: cint;
                                  highPrioMaxQueueSize: cint) =
    if self.redundancyGroups == nil:
      var redGroup: CS104_RedundancyGroup = CS104_RedundancyGroup_create(nil)
      CS104_Slave_addRedundancyGroup(self, redGroup)
    var element: LinkedList = LinkedList_getNext(self.redundancyGroups)
    while element:
      var redGroup: CS104_RedundancyGroup = cast[CS104_RedundancyGroup](LinkedList_getData(
          element))
      if redGroup.asduQueue == nil:
        CS104_RedundancyGroup_initializeMessageQueues(redGroup,
            lowPrioMaxQueueSize, highPrioMaxQueueSize)
      element = LinkedList_getNext(element)

proc CS104_Slave_start*(self: CS104_Slave) =
  if self.isRunning == false:
    self.isStarting = true
    self.stopRunning = false
    when (CONFIG_CS104_SUPPORT_SERVER_MODE_SINGLE_REDUNDANCY_GROUP == 1):
      if self.serverMode == CS104_MODE_SINGLE_REDUNDANCY_GROUP:
        initializeMessageQueues(self, self.maxLowPrioQueueSize,
                                self.maxHighPrioQueueSize)
    when (CONFIG_CS104_SUPPORT_SERVER_MODE_MULTIPLE_REDUNDANCY_GROUPS == 1):
      if self.serverMode == CS104_MODE_MULTIPLE_REDUNDANCY_GROUPS:
        initializeRedundancyGroups(self, self.maxLowPrioQueueSize,
                                   self.maxHighPrioQueueSize)
    self.listeningThread = Thread_create(serverThread, cast[pointer](self), false)
    Thread_start(self.listeningThread)
    while self.isStarting:
      Thread_sleep(1)

proc CS104_Slave_startThreadless*(self: CS104_Slave) =
  if self.isRunning == false:
    when (CONFIG_USE_THREADS == 1):
      self.isThreadlessMode = true
    when (CONFIG_CS104_SUPPORT_SERVER_MODE_SINGLE_REDUNDANCY_GROUP == 1):
      if self.serverMode == CS104_MODE_SINGLE_REDUNDANCY_GROUP:
        initializeMessageQueues(self, self.maxLowPrioQueueSize,
                                self.maxHighPrioQueueSize)
    when (CONFIG_CS104_SUPPORT_SERVER_MODE_MULTIPLE_REDUNDANCY_GROUPS == 1):
      if self.serverMode == CS104_MODE_MULTIPLE_REDUNDANCY_GROUPS:
        initializeRedundancyGroups(self, self.maxLowPrioQueueSize,
                                   self.maxHighPrioQueueSize)
    if self.localAddress:
      self.serverSocket = TcpServerSocket_create(self.localAddress, self.tcpPort)
    else:
      self.serverSocket = TcpServerSocket_create("0.0.0.0", self.tcpPort)
    if self.serverSocket == nil:
      DEBUG_PRINT("Cannot create server socket\n")
      self.isStarting = false
      break exit_function
    ServerSocket_listen(self.serverSocket)
    self.isRunning = true
  return

proc CS104_Slave_stopThreadless*(self: CS104_Slave) =
  self.isRunning = false
  if self.serverSocket:
    Socket_destroy(cast[Socket](self.serverSocket))
    self.serverSocket = nil

proc CS104_Slave_tick*(self: CS104_Slave) =
  handleConnectionsThreadless(self)

proc CS104_Slave_isRunning*(self: CS104_Slave): bool =
  return self.isRunning

proc CS104_Slave_stop*(self: CS104_Slave) =
  ## #if (CONFIG_USE_THREADS == 1)
  if self.isThreadlessMode:
    ## #endif
    CS104_Slave_stopThreadless(self)
    ## #if (CONFIG_USE_THREADS == 1)
  else:
    if self.isRunning:
      self.stopRunning = true
      while self.isRunning:
        Thread_sleep(1)
    if self.listeningThread:
      Thread_destroy(self.listeningThread)
    self.listeningThread = nil

proc CS104_Slave_destroy*(self: CS104_Slave) =
  when (CONFIG_USE_THREADS == 1):
    if self.isRunning:
      CS104_Slave_stop(self)
  when (CONFIG_CS104_SUPPORT_SERVER_MODE_SINGLE_REDUNDANCY_GROUP == 1):
    if self.serverMode == CS104_MODE_SINGLE_REDUNDANCY_GROUP:
      MessageQueue_releaseAllQueuedASDUs(self.asduQueue)
  when (CONFIG_CS104_SLAVE_POOL != 1):
    if self.localAddress != nil:
      GLOBAL_FREEMEM(self.localAddress)
  ##
  ##  Stop all connections
  ##
  when (CONFIG_USE_SEMAPHORES == 1):
    Semaphore_wait(self.openConnectionsLock)
  var i: cint
  i = 0
  while i < CONFIG_CS104_MAX_CLIENT_CONNECTIONS:
    if self.masterConnections[i] != nil:
      MasterConnection_close(self.masterConnections[i])
    inc(i)
  when (CONFIG_USE_SEMAPHORES == 1):
    Semaphore_post(self.openConnectionsLock)
  ## #if (CONFIG_USE_THREADS == 1)
  if self.isThreadlessMode:
    ## #endif
    var i: cint
    i = 0
    while i < CONFIG_CS104_MAX_CLIENT_CONNECTIONS:
      if self.masterConnections[i] != nil:
        MasterConnection_destroy(self.masterConnections[i])
        self.masterConnections[i] = nil
      inc(i)
    ## #if (CONFIG_USE_THREADS == 1)
  else:
    ##  Wait until all connections are closed
    while CS104_Slave_getOpenConnections(self) > 0:
      Thread_sleep(10)
  ## #endif
  ## #if (CONFIG_USE_SEMAPHORES == 1)
  Semaphore_destroy(self.openConnectionsLock)
  ## #endif
  when (CONFIG_CS104_SUPPORT_SERVER_MODE_SINGLE_REDUNDANCY_GROUP == 1):
    if self.serverMode == CS104_MODE_SINGLE_REDUNDANCY_GROUP:
      MessageQueue_destroy(self.asduQueue)
      HighPriorityASDUQueue_destroy(self.connectionAsduQueue)
  when (CONFIG_CS104_SUPPORT_SERVER_MODE_MULTIPLE_REDUNDANCY_GROUPS == 1):
    if self.serverMode == CS104_MODE_MULTIPLE_REDUNDANCY_GROUPS:
      if self.redundancyGroups:
        LinkedList_destroyDeep(self.redundancyGroups, cast[LinkedListValueDeleteFunction](CS104_RedundancyGroup_destroy))
  when (CONFIG_CS104_SLAVE_POOL == 1):
    ReleaseSlave(self)
  else:
    GLOBAL_FREEMEM(self)
