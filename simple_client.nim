#If the symbol begins with a _ but has no @, then it's __cdecl.
#If it begins with _ and has a @ it's __cdecl.
#If it begins with @ and has another @, it's __fastcall.
#{.link: "Ws2_32.lib".}
{.passL: "lib60870.a -lws2_32".}

import
  os, strformat, strutils, asyncdispatch, time, cs104_connection,
      iec60870_types, iec60870_common

var running*: bool = true
proc sigint_handler*() {.cdecl.} =
  running = false
  echo "Ctrl-c"

##  Callback handler to log sent or received messages (optional)

proc rawMessageHandler(parameter: pointer; msg: ptr array[256, byte];
                       msgSize: cint; sent: bool) {.cdecl.} =
  setupForeignThreadGc()
  var s: string
  if sent:
    s = "RAW SEND->"
  else:
    s = "RAW RCVD<-"
  s = s & ( $ msgSize) & " bytes=" #& (repr msg)
  #region
  #debugEcho(s)
  #return
  #var i:cint = 0
  #var b:byte
  #s = ""
  #while i < msgSize:
  #  b = msg[i]
  #  s = s & $b & " "
  #echo "i=", i, " b= ", b
  #  inc(i)
  #endregion
  debugEcho(s & " " & repr msg[0..(msgSize-1)])

##  Connection event handler

proc connectionHandler(parameter: pointer; connection: CS104_Connection;
                       event: CS104_ConnectionEvent) {.cdecl.} =
  #debugEcho(event)
  setupForeignThreadGc()
  case event
  of CS104_CONNECTION_OPENED:
    debugEcho("Connection established")
  of CS104_CONNECTION_CLOSED:
    debugEcho("Connection closed")
    running = false
  of CS104_CONNECTION_STARTDT_CON_RECEIVED:
    debugEcho("Received STARTDT_CON")
  of CS104_CONNECTION_STOPDT_CON_RECEIVED:
    debugEcho("Received STOPDT_CON")

##
##  CS101_ASDUReceivedHandler implementation
##
##  For CS104 the address parameter has to be ignored
##

proc asduReceivedHandler*(parameter: pointer; address: cint;
    asdu: CS101_ASDU): bool {.cdecl.} =
  var 
    i, cnt: cint = 0
    asdu_id = CS101_ASDU_getTypeID(asdu)
  cnt = CS101_ASDU_getNumberOfElements(asdu)
  echo(fmt"RECVD ASDU type: {TypeID_toString(asdu_id)}({cast[int](asdu_id)}) elements: {cnt}")

  if CS101_ASDU_getTypeID(asdu) == M_ME_TE_1:  #36
    echo("  measured short floated values with CP56Time2a timestamp:")
    while i < cnt:
      var io = cast[MeasuredValueShortWithCP56Time2a](CS101_ASDU_getElement(asdu, i))
      echo (fmt"    IOA: {InformationObject_getObjectAddress(cast[InformationObject](io))} " &
            fmt"value: {MeasuredValueShort_getValue(cast[MeasuredValueShort](io))}")
      MeasuredValueShortWithCP56Time2a_destroy(io)
      inc(i)

  elif CS101_ASDU_getTypeID(asdu) == M_ME_NC_1:  #13
    echo("  measured short floated values:")
    while i < cnt:
      var io = cast[MeasuredValueShort](CS101_ASDU_getElement(asdu, i))
      echo (fmt"    IOA: {InformationObject_getObjectAddress(cast[InformationObject](io))} " &          
            fmt"value: {MeasuredValueShort_getValue(io)}")
      MeasuredValueShort_destroy(io)
      inc(i)

  elif CS101_ASDU_getTypeID(asdu) == M_ME_NB_1:  #11
    echo("  measured scaled values:")
    while i < cnt:
      var io = cast[MeasuredValueScaled](CS101_ASDU_getElement(asdu, i))
      echo (fmt"    IOA: {InformationObject_getObjectAddress(cast[InformationObject](io))} " &          
            fmt"value: {MeasuredValueScaled_getValue(io)}")
      MeasuredValueScaled_destroy(io)
      inc(i)

  elif CS101_ASDU_getTypeID(asdu) == M_ME_TE_1:  #35
    echo("  measured scaled values with CP56Time2a timestamp:")
    while i < cnt:
      var io = cast[MeasuredValueScaledWithCP56Time2a](CS101_ASDU_getElement(asdu, i))
      echo (fmt"    IOA: {InformationObject_getObjectAddress(cast[InformationObject](io))} " &          
            fmt"value: {MeasuredValueScaled_getValue(cast[MeasuredValueScaled](io))}")
      MeasuredValueScaledWithCP56Time2a_destroy(io)
      inc(i)

  elif CS101_ASDU_getTypeID(asdu) == M_SP_NA_1:  #1
    echo("  single point information:")    
    while i < cnt:
      var io = cast[SinglePointInformation](CS101_ASDU_getElement(asdu, i))
      echo(fmt"    IOA: {InformationObject_getObjectAddress(cast[InformationObject](io))} " &          
            fmt"value: {SinglePointInformation_getValue(io)}")
      SinglePointInformation_destroy(io)
      inc(i)

  elif CS101_ASDU_getTypeID(asdu) == M_SP_TA_1:  #2
    echo("  single point information with CP56Time2a timestamp:")    
    while i < cnt:
      var io = cast[SinglePointWithCP56Time2a](CS101_ASDU_getElement(asdu, i))
      echo(fmt"    IOA: {InformationObject_getObjectAddress(cast[InformationObject](io))} " &          
           fmt"value: {SinglePointInformation_getValue(cast[SinglePointInformation](io))}")
      SinglePointWithCP56Time2a_destroy(io)
      inc(i)
  else:
    echo fmt"asdu unknown: {asdu_id}({cast[int](asdu_id)})"
  return true

var con {.threadvar.}: CS104_Connection

proc main() =
  setControlCHook(sigint_handler)
  var ip: cstring = "127.0.0.1"
  var port: uint16_t = IEC_60870_5_104_DEFAULT_PORT
  if paramCount() > 1:
    ip = paramStr(1)
  if paramCount() > 2:
    port = cast[uint16_t](parseInt(paramStr(2)))
  echo("Connecting to ", ip, ":", port)
  con = CS104_Connection_create(ip, port)
  #var conHandler = protect(connectionHandler)
  CS104_Connection_setConnectionHandler(con, connectionHandler, nil)
  CS104_Connection_setASDUReceivedHandler(con, asduReceivedHandler, nil)
  ## uncomment to log messages
  CS104_Connection_setRawMessageHandler(con, rawMessageHandler, nil)

  if CS104_Connection_connect(con):
    #CS104_Connection_setConnectTimeout(con, 54321)
    #echo "running: " , con.running
    #echo "timeOut: " , con.connectTimeoutInMs
    #echo "oldestSentASDU: " , con.oldestSentASDU
    #echo("StartDT")
    CS104_Connection_sendStartDT(con)
    sleep(1000)
    while running:
      discard CS104_Connection_sendInterrogationCommand(con, CS101_COT_ACTIVATION,
                                                        1, IEC60870_QOI_STATION)
      sleep(2000)

      var sc: InformationObject = cast[InformationObject]
        (SingleCommand_create(nil, 257, true, false, 0))
      echo("Send control command C_SC_NA_1")
      #discard CS104_Connection_sendProcessCommandEx(con, CS101_COT_ACTIVATION, 1, sc)
      InformationObject_destroy(sc)
      sleep(3000)
      ##  Send clock synchronization command
      var newTime: sCP56Time2a
      discard CP56Time2a_createFromMsTimestamp(addr newTime, Hal_getTimeInMs())
      echo("Send time sync command")
      discard CS104_Connection_sendClockSyncCommand(con, 1, addr newTime)
    sleep(1000)
  else:
    echo("Connect failed!")
  sleep(1000)
  CS104_Connection_sendStopDT(con)
  CS104_Connection_close(con)
  CS104_Connection_destroy(con)
  #dispose(conHandler)
  #echo("exit")

main()
echo("Exit program")


