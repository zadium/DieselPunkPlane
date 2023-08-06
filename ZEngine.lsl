/**
    @name: ZEngine
    @description: Plane Engine
    @note:

    @author: Zai Dium
    @license: MPL

    @version: 1.0
    @updated: "2023-08-06 18:58:51"
    @revision: 313
    @localfile: ?defaultpath\DieselPunkPlane\?@name.lsl
*/

float PowerFactor = 10; //* multiply with Velocity

float Tilting = 20; //DEG
float ForwardTilting = 10; //DEG
//integer DirectY = TRUE; //* Go forward to Y
float RotatingThrust = 10;
float ForwardThrust = 1;
float MaxForwardThrust = 5;
float UpThrust = 3;

vector textPos = < 0, 0, 0.1 >;
float Interval=0.5;
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
        CAMERA_ACTIVE, TRUE,
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

integer KEY_PageUp = CONTROL_UP;
integer KEY_PageDown = CONTROL_DOWN;
integer KEY_Up = CONTROL_FWD;
integer KEY_Down = CONTROL_BACK;
integer KEY_Left = CONTROL_ROT_LEFT;
integer KEY_Right = CONTROL_ROT_RIGHT;
integer KEY_ShiftLeft = CONTROL_LEFT;
integer KEY_ShiftRight = CONTROL_RIGHT;

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
        TRUE, FALSE
    );
    llOwnerSay("Control taken");
}

vector object_face = <1, 0, 0>; //* X direction, see Torpedo project

setupEngine()
{
    llSetStatus(STATUS_PHYSICS, TRUE);
    llSetStatus(STATUS_BLOCK_GRAB, TRUE);
    llSetStatus(STATUS_BLOCK_GRAB_OBJECT, TRUE);
    llSetVehicleType(VEHICLE_TYPE_AIRPLANE);

    rotation refRot = llEuler2Rot(<0, 0, 0>);
    //llSetVehicleRotationParam(VEHICLE_REFERENCE_FRAME, refRot);
    llSetVehicleRotationParam(VEHICLE_REFERENCE_FRAME, ZERO_ROTATION);
    llSetVehicleVectorParam(VEHICLE_LINEAR_MOTOR_OFFSET, <0, 0, 0>); //* engine in front
    llSetVehicleVectorParam( VEHICLE_LINEAR_FRICTION_TIMESCALE, <60, 20, 20> );

    llSetVehicleFloatParam( VEHICLE_LINEAR_MOTOR_TIMESCALE, 2 );
    llSetVehicleFloatParam( VEHICLE_LINEAR_MOTOR_DECAY_TIMESCALE, 10);
    llSetVehicleFloatParam( VEHICLE_LINEAR_DEFLECTION_EFFICIENCY, 0 );
    llSetVehicleFloatParam( VEHICLE_LINEAR_DEFLECTION_TIMESCALE, 5 );

    llSetVehicleFloatParam( VEHICLE_ANGULAR_MOTOR_TIMESCALE, 0 );
    llSetVehicleFloatParam( VEHICLE_ANGULAR_MOTOR_DECAY_TIMESCALE, 0.4);
    llSetVehicleFloatParam( VEHICLE_ANGULAR_DEFLECTION_EFFICIENCY, 0);
    llSetVehicleFloatParam( VEHICLE_ANGULAR_DEFLECTION_TIMESCALE, 2);

    llSetVehicleFloatParam( VEHICLE_VERTICAL_ATTRACTION_EFFICIENCY, 1 );
    llSetVehicleFloatParam( VEHICLE_VERTICAL_ATTRACTION_TIMESCALE, 5 );

    llSetVehicleFloatParam( VEHICLE_BANKING_EFFICIENCY, 0.3);
    llSetVehicleFloatParam( VEHICLE_BANKING_MIX, 0.9);
    llSetVehicleFloatParam( VEHICLE_BANKING_TIMESCALE, 0.2);

    llSetStatus(STATUS_ROTATE_X | STATUS_ROTATE_Z | STATUS_ROTATE_Y, TRUE);

    //llSetBuoyancy(0);
    llSetVehicleFloatParam( VEHICLE_BUOYANCY, 0);

    llRemoveVehicleFlags( VEHICLE_FLAG_NO_DEFLECTION_UP
                            | VEHICLE_FLAG_MOUSELOOK_STEER
                            | VEHICLE_FLAG_MOUSELOOK_BANK
                            | VEHICLE_FLAG_LIMIT_ROLL_ONLY
                            | VEHICLE_FLAG_HOVER_WATER_ONLY
                            | VEHICLE_FLAG_HOVER_TERRAIN_ONLY
                            | VEHICLE_FLAG_HOVER_GLOBAL_HEIGHT
                            | VEHICLE_FLAG_HOVER_UP_ONLY
                            | VEHICLE_FLAG_LIMIT_MOTOR_UP
                        );

    //llSetVehicleVectorParam(VEHICLE_ANGULAR_MOTOR_DIRECTION, <PI, PI, PI>);
    //llSetVehicleVectorParam(VEHICLE_LINEAR_MOTOR_DIRECTION, <0, 0, 1>);

    //llSetVehicleVectorParam(VEHICLE_LINEAR_FRICTION_TIMESCALE, <50, 50, 50>);
    //llSetVehicleFloatParam(VEHICLE_ANGULAR_FRICTION_TIMESCALE, 0.1);

}

prepare()
{
    llRequestPermissions(pilot, PERMISSION_TAKE_CONTROLS | PERMISSION_TRIGGER_ANIMATION | PERMISSION_CONTROL_CAMERA);
}

start()
{
    started = TRUE;
    setupEngine();
    llSetTimerEvent(Interval);
    llSetStatus(STATUS_PHYSICS, TRUE);
    llOwnerSay("started");
}

unprepare()
{
    llReleaseControls();
    llClearCameraParams();
}

stop()
{
    started = FALSE;
    llSetVehicleVectorParam(VEHICLE_ANGULAR_MOTOR_DIRECTION, ZERO_VECTOR);
    llSetVehicleVectorParam(VEHICLE_LINEAR_MOTOR_DIRECTION, ZERO_VECTOR);
    llSetStatus(STATUS_PHYSICS, FALSE);
    llSetTimerEvent(0);
    llOwnerSay("stopped");
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

integer checkSeat()
{
    key agent = llAvatarOnLinkSitTarget(seatPilotLink);

    if((agent != NULL_KEY) && (pilot != agent))
    {
        pilot = agent;
        llMessageLinked(LINK_SET, 0, "sit", pilot);
        prepare();
        return TRUE;
    }
    else if((agent == NULL_KEY) && (pilot != NULL_KEY))
    {
        llMessageLinked(LINK_SET, 0, "unsit", pilot);
        unprepare();
        pilot = NULL_KEY;
        stop();
        return FALSE;
    }
    else
        return FALSE;
}

float factor=1;
vector linear;

vector oldPos; //* for testing only to return back to original pos
rotation oldRot;

respawn()
{
    factor = PowerFactor * Interval;
    linear = <0, 0, 0>;
    llSetSoundQueueing(FALSE);
    llStopSound();
    llMessageLinked(LINK_SET, 0, "stop", NULL_KEY);
    llSetTimerEvent(0);
    llSetVehicleRotationParam(VEHICLE_REFERENCE_FRAME, llGetRot());
    llSetStatus(STATUS_PHYSICS, FALSE);
    //llSetPhysicsMaterial(GRAVITY_MULTIPLIER, 1,0,0,0);
    llSetForce(ZERO_VECTOR, TRUE);
    llSensorRemove();
    llStopMoveToTarget();
    llStopLookAt();
    llParticleSystem([]);
    llSleep(1);
    llSetRegionPos(oldPos);
    llSetRot(oldRot);
}

init()
{
    llSetVehicleRotationParam( VEHICLE_REFERENCE_FRAME, ZERO_ROTATION / llGetRootRotation());
    llParticleSystem([]);
    llSetForce(ZERO_VECTOR, TRUE);
    llSitTarget(ZERO_VECTOR, ZERO_ROTATION); //* do not sit on hull/root
    factor = PowerFactor * Interval;
    linear = <0, 0, 0>;
}

default
{
    state_entry()
    {
        oldPos = llGetPos();
        oldRot = llGetRot();
        updateLinks();
        llSetSitText("Drive");
        llSetText("", ZERO_VECTOR, 1);
        init();
        checkSeat();
        setupEngine();
    }

    on_rez(integer number)
    {
        llSetStatus(STATUS_PHYSICS, TRUE);
        llSleep(2);
        llSetStatus(STATUS_PHYSICS, FALSE);
        llResetScript();
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
            setupCamera();
        }
        if (perm & (PERMISSION_CONTROL_CAMERA))
        {
            llClearCameraParams();
        }
    }

    control(key id, integer level, integer edge)
    {
        if (id==pilot)
        {
            if (!started)
                start();
            else
            {
                vector delta = <0, 0, 0>;

                if ((level & KEY_PageUp) || (level & KEY_PageDown))
                {
                    if ((edge & KEY_PageUp) && (edge & KEY_PageDown))
                    {
                        delta.x = -linear.x;
                    }
                    else if (edge & KEY_PageUp)
                    {
                        if (!started)
                        {
                            start();
                            return;
                        }
                        else
                            delta.x = ForwardThrust;
                    }
                    else if (edge & KEY_PageDown)
                        delta.x -= ForwardThrust;
                }
                else
                {
                    //llOwnerSay("---");
                    //linear_x = 0;
                }
                /*
                if ((level & KEY_Up) || (level & KEY_Down))
                {
                    if (level & KEY_Up)
                    {
                        delta.z = UpThrust;
                        //angular.y = -ForwardTilting * DEG_TO_RAD;
                    }
                    else if (level & KEY_Down)
                    {
                        delta.z = -UpThrust;
                        //angular.y = ForwardTilting * DEG_TO_RAD;
                    }
                }
                else
                {
                    delta.z = 0;
                }  */

                if ((delta.x > 0) || (delta.z>0))
                {
                    linear = linear + delta;
                    if (linear.x>MaxForwardThrust)
                        linear.x = MaxForwardThrust;
                    else if (linear.x<0)
                        linear.x = 0;
                    linear.z = linear.x;

                    llOwnerSay((string)linear);
                    llSetVehicleVectorParam(VEHICLE_LINEAR_MOTOR_DIRECTION, linear * factor);
                }


                vector angular = <0.0, 0.0, 0.0>;
        //        if (linear_x>0)
        //            angular.y = ForwardTilting * DEG_TO_RAD;

                if (level & KEY_Right) {
//                    angular.x = Tilting*DEG_TO_RAD;
                    angular.z = -linear.x * DEG_TO_RAD;
                }

                if (level & KEY_Left) {
//                    angular.x = -Tilting*DEG_TO_RAD;
                    angular.z = linear.x * DEG_TO_RAD;
                }

                if (level & KEY_ShiftRight) {
                    angular.x = Tilting*10*DEG_TO_RAD;
                    //angular.z = -RotatingThrust * DEG_TO_RAD;
                }

                if (level & KEY_ShiftLeft) {
                    angular.x = -Tilting*10*DEG_TO_RAD;
                    //angular.z = RotatingThrust * DEG_TO_RAD;
                }

                llSetVehicleVectorParam(VEHICLE_ANGULAR_MOTOR_DIRECTION, angular * factor);
            }
        }
    }

    timer()
    {

    }
}
