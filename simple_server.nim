import os, strformat, iec60870_types, cs104_slave, iec60870_slave,
  iec60870_common, time # hal_thread, hal_time

var running*: bool = true

proc sigint_handler*() {.noconv.} =
  running = false
  echo "Ctrl-c"

proc printCP56Time2a*(time: CP56Time2a) =
  echo fmt"{CP56Time2a_getHour(time):02}:{CP56Time2a_getMinute(time):02}:{CP56Time2a_getSecond(time):02} " &
      fmt"{CP56Time2a_getDayOfMonth(time):02}/{CP56Time2a_getMonth(time):02}/{CP56Time2a_getYear(time) + 2000}"

##  Callback handler to log sent or received messages (optional)

proc rawMessageHandler*(parameter: pointer; conneciton: IMasterConnection;
                        msg: var array[256, uint8_t]; msgSize: cint;
                            sent: bool) =
  var s: string
  if sent:
    s = "RAW SEND: "
  else:
    s = "RAW RCVD: "
  s = s & fmt"{msgSize} bytes"
  var i: cint = 0
  var b: uint8_t
  while i < msgSize:
    b = msg[i]
    s = s & fmt"{b:#X}" & " "
    inc(i)
  echo(s)

proc clockSyncHandler*(parameter: pointer; connection: IMasterConnection;
                      asdu: CS101_ASDU; newTime: CP56Time2a): bool {.cdecl.} =
  echo("Process time sync command with time: ")
  printCP56Time2a(newTime)
  var newSystemTimeInMs: uint64_t = CP56Time2a_toMsTimestamp(newTime)
  ##  Set time for ACT_CON message
  CP56Time2a_setFromMsTimestamp(newTime, Hal_getTimeInMs())
  echo("")
  ##  update system time here
  return true

proc interrogationHandler*(parameter: pointer; connection: IMasterConnection;
                          asdu: CS101_ASDU; qoi: uint8_t): bool {.cdecl.} =
  echo("Received interrogation for group %i", qoi)
  if qoi == (uint8_t)20:
    ##  only handle station interrogation
    var alParams: CS101_AppLayerParameters = 
        IMasterConnection_getApplicationLayerParameters(connection)
    IMasterConnection_sendACT_CON(connection, asdu, false)
    ##  The CS101 specification only allows information objects without timestamp in GI responses
    var newAsdu: CS101_ASDU = CS101_ASDU_create(alParams, false,
        CS101_COT_INTERROGATED_BY_STATION, 0, 1, false, false)
    var io: InformationObject = cast[InformationObject](
        MeasuredValueScaled_create(nil, 100, -1, IEC60870_QUALITY_GOOD))
    discard CS101_ASDU_addInformationObject(newAsdu, io)
    discard CS101_ASDU_addInformationObject(newAsdu, cast[InformationObject](
        MeasuredValueScaled_create(cast[MeasuredValueScaled](io), 101, 23,
            IEC60870_QUALITY_GOOD)))
    discard CS101_ASDU_addInformationObject(newAsdu, cast[InformationObject](
        MeasuredValueScaled_create(cast[MeasuredValueScaled](io), 102, 2300,
            IEC60870_QUALITY_GOOD)))
    InformationObject_destroy(io)
    IMasterConnection_sendASDU(connection, newAsdu)
    CS101_ASDU_destroy(newAsdu)
    newAsdu = CS101_ASDU_create(alParams, false,
        CS101_COT_INTERROGATED_BY_STATION, 0, 1, false, false)
    io = cast[InformationObject](SinglePointInformation_create(nil, 104, true,
        IEC60870_QUALITY_GOOD))
    discard CS101_ASDU_addInformationObject(newAsdu, io)
    discard CS101_ASDU_addInformationObject(newAsdu, cast[InformationObject](
        SinglePointInformation_create(
        cast[SinglePointInformation](io), 105, false, IEC60870_QUALITY_GOOD)))
    InformationObject_destroy(io)
    IMasterConnection_sendASDU(connection, newAsdu)
    CS101_ASDU_destroy(newAsdu)
    newAsdu = CS101_ASDU_create(alParams, true, CS101_COT_INTERROGATED_BY_STATION,
                                0, 1, false, false)
    discard CS101_ASDU_addInformationObject(newAsdu, io = cast[
        InformationObject](SinglePointInformation_create(
        nil, 300, true, IEC60870_QUALITY_GOOD)))
    discard CS101_ASDU_addInformationObject(newAsdu, cast[InformationObject](
        SinglePointInformation_create(
        cast[SinglePointInformation](io), 301, false, IEC60870_QUALITY_GOOD)))
    discard CS101_ASDU_addInformationObject(newAsdu, cast[InformationObject](
        SinglePointInformation_create(
        cast[SinglePointInformation](io), 302, true, IEC60870_QUALITY_GOOD)))
    discard CS101_ASDU_addInformationObject(newAsdu, cast[InformationObject](
        SinglePointInformation_create(
        cast[SinglePointInformation](io), 303, false, IEC60870_QUALITY_GOOD)))
    discard CS101_ASDU_addInformationObject(newAsdu, cast[InformationObject](
        SinglePointInformation_create(
        cast[SinglePointInformation](io), 304, true, IEC60870_QUALITY_GOOD)))
    discard CS101_ASDU_addInformationObject(newAsdu, cast[InformationObject](
        SinglePointInformation_create(
        cast[SinglePointInformation](io), 305, false, IEC60870_QUALITY_GOOD)))
    discard CS101_ASDU_addInformationObject(newAsdu, cast[InformationObject](
        SinglePointInformation_create(
        cast[SinglePointInformation](io), 306, true, IEC60870_QUALITY_GOOD)))
    discard CS101_ASDU_addInformationObject(newAsdu, cast[InformationObject](
        SinglePointInformation_create(
        cast[SinglePointInformation](io), 307, false, IEC60870_QUALITY_GOOD)))
    InformationObject_destroy(io)
    IMasterConnection_sendASDU(connection, newAsdu)
    CS101_ASDU_destroy(newAsdu)
    IMasterConnection_sendACT_TERM(connection, asdu)
  else:
    IMasterConnection_sendACT_CON(connection, asdu, true)
  return true

proc asduHandler*(parameter: pointer; connection: IMasterConnection;
    asdu: CS101_ASDU): bool {.cdecl.} =
  if CS101_ASDU_getTypeID(asdu) == C_SC_NA_1:
    echo("received single command")
    if CS101_ASDU_getCOT(asdu) == CS101_COT_ACTIVATION:
      var io: InformationObject = CS101_ASDU_getElement(asdu, 0)
      if InformationObject_getObjectAddress(io) == 5000:
        var sc: SingleCommand = cast[SingleCommand](io)
        echo("IOA:", InformationObject_getObjectAddress(io),
            " switch to ", SingleCommand_getState(sc))
        CS101_ASDU_setCOT(asdu, CS101_COT_ACTIVATION_CON)
      else:
        CS101_ASDU_setCOT(asdu, CS101_COT_UNKNOWN_IOA)
      InformationObject_destroy(io)
    else:
      CS101_ASDU_setCOT(asdu, CS101_COT_UNKNOWN_COT)
    IMasterConnection_sendASDU(connection, asdu)
    return true
  return false

proc connectionRequestHandler*(parameter: pointer; ipAddress: cstring): bool {.
  cdecl.} =
  echo fmt("New connection request from {ipAddress}")
  #[when false:
    if strcmp(ipAddress, "127.0.0.1") == 0:
      echo("Accept connection")
      return true
    else:
      echo("Deny connection")
      return false
  else:
    return true]#

proc connectionEventHandler*(parameter: pointer; con: IMasterConnection;
                            event: CS104_PeerConnectionEvent) {.cdecl.} =
  if event == CS104_CON_EVENT_CONNECTION_OPENED:
    echo("Connection opened ", repr con)
  elif event == CS104_CON_EVENT_CONNECTION_CLOSED:
    echo("Connection closed ", repr con)
  elif event == CS104_CON_EVENT_ACTIVATED:
    echo("Connection activated ", repr con)
  elif event == CS104_CON_EVENT_DEACTIVATED:
    echo("Connection deactivated", repr con)

proc main*() =
  ##  Add Ctrl-C handler
  setControlCHook(sigint_handler)
  ##  create a new slave/server instance with default connection parameters and
  ##  default message queue size
  var slave: CS104_Slave = CS104_Slave_create(100, 100)
  CS104_Slave_setLocalAddress(slave, "0.0.0.0")
  ##  Set mode to a single redundancy group
  ##  NOTE: library has to be compiled with CONFIG_CS104_SUPPORT_SERVER_MODE_SINGLE_REDUNDANCY_GROUP enabled (=1)
  ##
  CS104_Slave_setServerMode(slave, CS104_MODE_SINGLE_REDUNDANCY_GROUP)
  ##  get the connection parameters - we need them to create correct ASDUs
  var alParams: CS101_AppLayerParameters = CS104_Slave_getAppLayerParameters(
      slave)
  ##  set the callback handler for the clock synchronization command
  CS104_Slave_setClockSyncHandler(slave, clockSyncHandler, nil)
  ##  set the callback handler for the interrogation command
  CS104_Slave_setInterrogationHandler(slave, interrogationHandler, nil)
  ##  set handler for other message types
  CS104_Slave_setASDUHandler(slave, asduHandler, nil)
  ##  set handler to handle connection requests (optional)
  CS104_Slave_setConnectionRequestHandler(slave, connectionRequestHandler, nil)
  ##  set handler to track connection events (optional)
  CS104_Slave_setConnectionEventHandler(slave, connectionEventHandler, nil)
  ##  uncomment to log messages
  ## CS104_Slave_setRawMessageHandler(slave, rawMessageHandler, NULL);
  CS104_Slave_start(slave)
  if CS104_Slave_isRunning(slave) == false:
    echo("Starting server failed!")
    return #break exit_program
  var scaledValue: int16_t = 0
  while running:
    sleep(1000)
    var newAsdu: CS101_ASDU = CS101_ASDU_create(alParams, false,
        CS101_COT_PERIODIC, 0,
        1, false, false)
    var io: InformationObject = cast[InformationObject](
        MeasuredValueScaled_create(
        nil, 110, scaledValue, IEC60870_QUALITY_GOOD))
    inc(scaledValue)
    discard CS101_ASDU_addInformationObject(newAsdu, io)
    InformationObject_destroy(io)
    ##  Add ASDU to slave event queue - don't release the ASDU afterwards!
    ##  The ASDU will be released by the Slave instance when the ASDU
    ##  has been sent.
    ##
    CS104_Slave_enqueueASDU(slave, newAsdu)
    CS101_ASDU_destroy(newAsdu)
  CS104_Slave_stop(slave)
  CS104_Slave_destroy(slave)
  sleep(500)
  echo("Wait for exit...")

main()
