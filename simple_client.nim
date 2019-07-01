import
  os, strformat, strutils, times, cs104_connection, iec60870_types, iec60870_common, winlean #, hal_time, hal_thread

##  Callback handler to log sent or received messages (optional)

proc Hal_getTimeInMs(): uint64_t =   
  return cast[uint64_t] (toUnix(getTime())*1000)
                               
proc rawMessageHandler(parameter: pointer; msg:var array[256, uint8_t]; 
                       msgSize: cint; sent: bool) {.cdecl.} =
  var s: string  
  if sent:
    s = "RAW SEND: "
  else:
    s = "RAW RCVD: "
  s = s & fmt"{msgSize} bytes"
  var i: cint = 0  
  var b : cint  
  while i < msgSize:     
    b = cast[cint](msg[i])
    s=s & fmt"{b:#X}" & " " 
    i = i+1
  echo(s)

##  Connection event handler

proc connectionHandler(parameter: pointer; connection: CS104_Connection;
                       event: CS104_ConnectionEvent) {.cdecl.} =  
  case event
  of CS104_CONNECTION_OPENED:
    echo("Connection established\n")
  of CS104_CONNECTION_CLOSED:
    echo("Connection closed\n")
  of CS104_CONNECTION_STARTDT_CON_RECEIVED:
    echo("Received STARTDT_CON\n")
  of CS104_CONNECTION_STOPDT_CON_RECEIVED:
    echo("Received STOPDT_CON\n")

##
##  CS101_ASDUReceivedHandler implementation
##
##  For CS104 the address parameter has to be ignored
##

proc asduReceivedHandler*(parameter: pointer; address: cint; asdu: CS101_ASDU): bool {.cdecl.} =
  echo(fmt"RECVD ASDU type: {TypeID_toString(CS101_ASDU_getTypeID(asdu))}({cast[int](CS101_ASDU_getTypeID(asdu))}) " &
       fmt"elements: {CS101_ASDU_getNumberOfElements(asdu)}" )
  if CS101_ASDU_getTypeID(asdu) == M_ME_TE_1:
    echo("  measured scaled values with CP56Time2a timestamp:")
    var i: cint
    i = 0
    while i < CS101_ASDU_getNumberOfElements(asdu):
      var io: MeasuredValueScaledWithCP56Time2a = 
           cast[MeasuredValueScaledWithCP56Time2a](CS101_ASDU_getElement(asdu, i))
      echo (fmt"    IOA: {InformationObject_getObjectAddress(cast[InformationObject](io))} " &
            fmt"value: {MeasuredValueScaled_getValue(cast[MeasuredValueScaled](io))}" )

      MeasuredValueScaledWithCP56Time2a_destroy(io)
      inc(i)
  elif CS101_ASDU_getTypeID(asdu) == M_SP_NA_1:
    echo("  single point information:")
    var i: cint
    i = 0
    while i < CS101_ASDU_getNumberOfElements(asdu):
      var io: SinglePointInformation = 
           cast[SinglePointInformation](CS101_ASDU_getElement(asdu, i))
      echo(fmt"    IOA: {InformationObject_getObjectAddress(cast[InformationObject](io))} " &
              fmt"value: {SinglePointInformation_getValue(cast[SinglePointInformation](io))}")
      SinglePointInformation_destroy(io)
      inc(i)
  return true

proc main*() =
  var ip: cstring = "10.220.7.138"
  var port: uint16_t = IEC_60870_5_104_DEFAULT_PORT
  if paramCount() > 1:
    ip = paramStr(1)
  if paramCount() > 2:
    port = cast[uint16_t](parseInt(paramStr(2)))
  echo("Connecting to ", ip, ":", port)
  var con = CS104_Connection_create(ip, port)
  CS104_Connection_setConnectionHandler(con, connectionHandler, nil)  
  CS104_Connection_setASDUReceivedHandler(con, asduReceivedHandler, nil)  
  ## uncomment to log messages
  CS104_Connection_setRawMessageHandler(con, rawMessageHandler, nil)

  if CS104_Connection_connect(con):
    #CS104_Connection_setConnectTimeout(con, 54321)    
    echo "running: " , con.running
    echo "oldestSentASDU: " , con.oldestSentASDU
    echo("StartDT")
    CS104_Connection_sendStartDT(con)    
    sleep(3000)
    discard CS104_Connection_sendInterrogationCommand(con, CS101_COT_ACTIVATION, 
      1, cast[QualifierOfInterrogation](IEC60870_QOI_STATION))
    sleep(3000)
    var sc: InformationObject = cast[InformationObject](SingleCommand_create(nil,
        5000, true, false, 0))
    echo("Send control command C_SC_NA_1")
    discard CS104_Connection_sendProcessCommandEx(con, CS101_COT_ACTIVATION, 1, sc)
    InformationObject_destroy(sc)
    ##  Send clock synchronization command
    var newTime: sCP56Time2a
    discard CP56Time2a_createFromMsTimestamp(addr newTime, Hal_getTimeInMs())
    echo("Send time sync command")    
    discard CS104_Connection_sendClockSyncCommand(con, 1, addr newTime)
    sleep(1000)
  else:
    echo("Connect failed!")
  sleep(1000)
  CS104_Connection_destroy(con)
  echo("exit")

main()

