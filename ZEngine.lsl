/**
    @name: ZEngine
    @description: Plane Engine
    @note:

    @author: Zai Dium

    @version: 1.0
    @updated: "2023-07-19 14:30:25"
    @revision: 60
    @localfile: ?defaultpath\\DieselPunkPlane\?@name.lsl
*/

vector textPos = < 0, 0, 0.1 >;
integer Interval=1;
integer textLink = 1; //* a prim to show text on it, if not exist, no text will show
key pilot = NULL_KEY; //* Pilot who sit
integer seatPilotLink = 1; //* can be 0 if it root
list seatPilotLinks;

integer started = FALSE;

sendMsg(string message)
{
    if (pilot != NULL_KEY)
        llRegionSayTo(pilot, 0, message);
    else
        llWhisper(0, message);
}

updateLinks()
{
    seatPilotLinks = [];
    seatPilotLink = 1;
    textLink = 1;
    integer c = llGetNumberOfPrims();
    integer i = 1;
    string name;
    while (i<=c)
    {
        name = llToLower(llGetLinkName(i));
        if (name == "pilotseat")
            seatPilotLink = i;
        else if (name == "text")
            textLink = i;
        else if (name == "seat")
            seatPilotLinks += [i];
        i++;
    }
}

setupCamera()
{
    llSetCameraParams([
        CAMERA_ACTIVE, 1,
        CAMERA_DISTANCE, 10.0,
        CAMERA_BEHINDNESS_ANGLE, 30.0,
        CAMERA_BEHINDNESS_LAG, 0.0,

        CAMERA_PITCH, 10.0,

        //CAMERA_FOCUS, <0,0,5>,
        CAMERA_FOCUS_OFFSET, <2.0, 0.0, 0.0>,
        CAMERA_FOCUS_LAG, 0.05 ,
        CAMERA_FOCUS_THRESHOLD, 0.0,
        CAMERA_FOCUS_LOCKED, FALSE,

        //CAMERA_POSITION, <0,0,0>,
        CAMERA_POSITION_LOCKED, FALSE,
        CAMERA_POSITION_THRESHOLD, 0.0,
        CAMERA_POSITION_LAG, 0.0
    ]);
}

takeControls()
{
    llTakeControls(
        CONTROL_UP |
        CONTROL_DOWN |
        CONTROL_FWD |
        CONTROL_BACK |
        CONTROL_RIGHT |
        CONTROL_LEFT |
        CONTROL_ROT_RIGHT |
        CONTROL_ROT_LEFT,
        TRUE, TRUE
    );
}

vector object_face = <1, 0, 0>; //* X direction, see Torpedo project

setupEngine()
{
    llSetStatus(STATUS_BLOCK_GRAB, TRUE);
    llSetStatus(STATUS_BLOCK_GRAB_OBJECT, TRUE);
    llSetVehicleType(VEHICLE_TYPE_AIRPLANE);

    rotation refRot = llEuler2Rot(<0, 0, 0>);
    llSetVehicleRotationParam(VEHICLE_REFERENCE_FRAME, refRot);
    llSetVehicleVectorParam(VEHICLE_LINEAR_MOTOR_OFFSET, -object_face);
    llSetVehicleVectorParam(VEHICLE_LINEAR_FRICTION_TIMESCALE, <1000, 1000, 20000>);

    llSetStatus(STATUS_ROTATE_Z | STATUS_ROTATE_Y, FALSE);
    //llSetStatus(STATUS_ROTATE_X | STATUS_ROTATE_Z | STATUS_ROTATE_Y, FALSE);
    //llSetBuoyancy(0);
    llSetVehicleFloatParam( VEHICLE_BUOYANCY, 0);


    //llSetVehicleVectorParam(VEHICLE_ANGULAR_MOTOR_DIRECTION, <PI, PI, PI>);
    //llSetVehicleVectorParam(VEHICLE_LINEAR_MOTOR_DIRECTION, <0, 0, 1>);

    //llSetVehicleVectorParam(VEHICLE_LINEAR_FRICTION_TIMESCALE, <50, 50, 50>);
    //llSetVehicleFloatParam(VEHICLE_ANGULAR_FRICTION_TIMESCALE, 0.1);

    llSetStatus(STATUS_PHYSICS, TRUE);
}

prepare()
{
    llRequestPermissions(pilot, PERMISSION_TAKE_CONTROLS | PERMISSION_TRIGGER_ANIMATION | PERMISSION_CONTROL_CAMERA);
}

start()
{
    started = TRUE;
    llSetTimerEvent(Interval);
}

unprepare()
{
    llReleaseControls();
    llClearCameraParams();
}

stop()
{
    started = FALSE;
    llSetTimerEvent(0);
}

//* enject all sitters that not pilot
eject()
{
    integer c = llGetListLength(seatPilotLinks);
    integer i = 0;
    key avatar;
    while (i<c)
    {
        avatar = llAvatarOnLinkSitTarget(llList2Integer(seatPilotLinks, i));
        if (avatar != NULL_KEY)
            llUnSit(avatar);
        i++;
    }
}

setText(string text)
{
    if (textLink>0)
        llSetLinkPrimitiveParams(textLink, [PRIM_TEXT, text, textPos, 1]);
}

doCommand(string cmd)
{
    if (cmd == "prepare")
        prepare();
    else if (cmd == "unprepare")
        unprepare();
    else if (cmd == "start")
        start();
    else if (cmd == "stop")
        stop();
    else if (cmd == "eject")
        eject();
}

checkSeat()
{
    key agent = llAvatarOnLinkSitTarget(seatPilotLink);

    if((agent != NULL_KEY) && (pilot != agent))
    {
        pilot = agent;
        llMessageLinked(LINK_SET, 0, "sit", pilot);
        doCommand("engine:prepare");
    }
    else if((agent == NULL_KEY) && (pilot != NULL_KEY))
    {
        llMessageLinked(LINK_SET, 0, "unsit", pilot);

        doCommand("engine:unprepare");
        pilot = NULL_KEY;
        doCommand("engine:stop");
    }
}

default
{
    state_entry()
    {
        llSetSitText("Drive");
        llSetText("", ZERO_VECTOR, 1);
        updateLinks();
        checkSeat();
    }

    changed(integer change)
    {
        if(change & CHANGED_LINK)
        {
            checkSeat();
        }
    }

    run_time_permissions(integer perm)
    {
        if (perm & (PERMISSION_TAKE_CONTROLS))
        {
            takeControls();
        }
        if (perm & (PERMISSION_CONTROL_CAMERA))
        {
            llClearCameraParams();
        }
    }

    timer()
    {
        //power();
    }
}
