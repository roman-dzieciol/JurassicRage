// ============================================================================
//  jrWeapon.uc ::
// ============================================================================
class jrWeapon extends Weapon
    abstract
    HideDropDown
    CacheExempt;


var() vector MeshOffset;
var() rotator MeshPivot;


var float FOVSpeedIn;
var float FOVSpeedOut;

var float FOVAngle;
var float FOVDesired;
var float FOVCamera;



// - Animation ----------------------------------------------------------------

var float IdleAnimTween;

var float BobAim;
var float BobThreat;
var float BobReady;

// ============================================================================
//  Lifespan
// ============================================================================

simulated function PostBeginPlay()
{
    Super.PostBeginPlay();
}


// ============================================================================
//  Firing
// ============================================================================

simulated function ContextFire()
{
}

simulated function float GetAccuracy()
{
    return 0;
}

simulated function float GetAccuracyBase()
{
    return 0;
}


// ============================================================================
//  Animation
// ============================================================================

simulated function PlayIdle()
{
    LoopAnim(IdleAnim, IdleAnimRate, IdleAnimTween);
}


simulated function AnimEnd(int channel)
{
    if( ClientState == WS_ReadyToFire )
    {
        if((FireMode[0] == None || !FireMode[0].bIsFiring)
        && (FireMode[1] == None || !FireMode[1].bIsFiring))
        {
            PlayIdle();
        }
    }
}


simulated event WeaponTick( float DT )
{
    if( Level.NetMode == NM_DedicatedServer )
        return;

    if( FOVAngle != FOVDesired )
    {
        if( FOVAngle > FOVDesired )
        {
            FOVAngle = FMax( FOVAngle - FOVSpeedIn * DT, FOVDesired);
        }
        else if( FOVAngle < FOVDesired )
        {
            FOVAngle = FMin( FOVAngle + FOVSpeedOut * DT, FOVDesired);
        }
    }
}


// ============================================================================
//  Draw
// ============================================================================

simulated event RenderOverlays( Canvas Canvas )
{
    local int i;

    if( Instigator == None )
        return;

    for( i=0; i!=NUM_FIRE_MODES; ++i )
    {
        if( FireMode[i] != None )
        {
            FireMode[i].DrawMuzzleFlash(Canvas);
        }
    }

    PlayerViewPivot = MeshPivot;
    PlayerViewOffset = MeshOffset;

    SetLocation( Instigator.Location + CalcWeaponOffset() );
    SetRotation( Instigator.GetViewRotation() );

    PreDrawFPWeapon();

    bDrawingFirstPerson = true;
    Canvas.DrawActor(self, false, false, FOVAngle);
    bDrawingFirstPerson = false;
}

simulated function vector CalcWeaponOffset()
{
    return Instigator.EyePosition() + Instigator.WeaponBob(BobDamping);
}

simulated function SetPlayerFOV( float f )
{
    if( jrPlayer(Instigator.Controller) != None )
    {
        if( f > 0 )
        {
            jrPlayer(Instigator.Controller).ClientSetZoom(f);
        }
        else
        {
            jrPlayer(Instigator.Controller).CancelZoom();
        }
    }
}

simulated function float GetCrosshairScale()
{
    return 1.0;
}


// ============================================================================
//  Debug Weapon
// ============================================================================

exec function EditGun()
{
    ConsoleCommand( "editobj" @name );
}

exec function EditGunD()
{
    ConsoleCommand( "editdefault class=" $class.name );
}

exec function Edit3rd()
{
    if( ThirdPersonActor != None )
        ConsoleCommand( "editobj" @ThirdPersonActor.name );
}

exec function Edit3rdD()
{
    if( AttachmentClass != None )
        ConsoleCommand( "editdefault class=" $AttachmentClass.name );
}

exec function EditFire( byte Mode )
{
    ConsoleCommand( "editobj" @FireMode[Mode].name );
}

exec function EditFireD( byte Mode )
{
    ConsoleCommand( "editdefault class=" $FireMode[Mode].class.name );
}

exec function AttRot( int  Pitch, int Yaw, int Roll )
{
    local rotator NewRot;

    NewRot.Pitch = pitch;
    NewRot.Yaw = yaw;
    NewRot.Roll = roll;
    ThirdPersonActor.SetRelativeRotation(NewRot);
}

exec function AttLoc( int x, int y, int z )
{
    local vector  NewLoc;
    NewLoc.x = x;
    NewLoc.y = y;
    NewLoc.z = z;
    ThirdPersonActor.SetRelativeLocation(NewLoc);
}


// ============================================================================
//  Debug
// ============================================================================
final simulated function xLog ( coerce string s )
{
    Log
    (   "[" $Left("00",2-Len(Level.Second)) $Level.Second $":"
            $Left("000",3-Len(Level.Millisecond)) $Level.Millisecond $"]"
    @   "[" $StrShort(GetStateName()) $"]"
    @   s
    ,   name );
}

final simulated static function nLog ( coerce string s )
{
    Log( s, default.name );
}

final simulated static function string StrShort( coerce string s )
{
    local string r,c;
    local int i,n;

    c = Caps(s);
    n = Len(s);

    for( i=0; i!=n; ++i )
        if( Mid(s,i,1) == Mid(c,i,1) )
            r $= Mid(s,i,1);

    return r;
}

final simulated static operator(112) string # ( coerce string A, coerce string B )
{
    return A @"[" $B $"]";
}

final simulated static function name GON( Object O )
{
    if( O != None ) return O.Name;
    else            return 'None';
}

final simulated function string GPT( string S )
{
    return GetPropertyText(S);
}

final simulated function string GetNetInfo( optional Actor A )
{
    if( A == None )
        A = self;
    return class 'jrDbg'.static.GetNetInfo(A);
}

// ============================================================================
//  Debug Draw
// ============================================================================
simulated final function DrawAxesRot( vector Loc, rotator Rot, float Length, optional bool bStaying )
{
    local vector X,Y,Z;
    GetAxes( Rot, X, Y, Z );
    DrawAxesXYZ(Loc,X,Y,Z,Length,bStaying);
}

simulated final function DrawAxesCoords( Coords C, float Length, optional bool bStaying )
{
    DrawAxesXYZ(C.Origin,C.XAxis,C.YAxis,C.ZAxis,Length,bStaying);
}

simulated final function DrawAxesXYZ( vector Loc, vector X, vector Y, vector Z, float Length, optional bool bStaying )
{
    if( bStaying )
    {
        Level.DrawStayingDebugLine(Loc,Loc+X*Length,255,0,0);
        Level.DrawStayingDebugLine(Loc,Loc+Y*Length,0,255,0);
        Level.DrawStayingDebugLine(Loc,Loc+Z*Length,0,0,255);
    }
    else
    {
        Level.DrawDebugLine(Loc,Loc+X*Length,255,0,0);
        Level.DrawDebugLine(Loc,Loc+Y*Length,0,255,0);
        Level.DrawDebugLine(Loc,Loc+Z*Length,0,0,255);
    }
}


// ============================================================================
//  DefaultProperties
// ============================================================================
DefaultProperties
{
    IdleAnimTween           = 0.1

    BobAim = 0.9
    BobThreat = 0.33
    BobReady = 0.0

    DrawType            = DT_Mesh


    DisplayFOV          = 90
    CenteredOffsetY     = 0
    CenteredRoll        = 0

    LightType               = LT_None

    FOVSpeedIn = 90
    FOVSpeedOut = 720

    FOVAngle = 90
    FOVDesired = 90

}
