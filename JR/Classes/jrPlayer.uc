// ============================================================================
//  jrPlayer.uc ::
// ============================================================================
//  Copyright 2006 Jurassic Rage team. All Rights Reserved.
//  http://www.jurassic-rage.com
// ============================================================================
class jrPlayer extends xPlayer;

struct SSongOverride
{
    var() string Map;
    var() string Song;
};

var globalconfig array<SSongOverride> SongOverride;

var float SightsSpeedOut;
var float SightsSpeedIn;
var float SightsFOV;

replication
{
    reliable if ( Role == ROLE_Authority)
        ClientSetZoom;
}


// ============================================================================
//  Lifespan
// ============================================================================

simulated event PostBeginPlay()
{
    Super.PostBeginPlay();
    OverrideSong();
}


// ============================================================================
//  FOV
// ============================================================================

function ClientSetZoom( float MaxZoomLevel )
{
    SetZoom(MaxZoomLevel);
}

function SetZoom( float MaxZoomLevel )
{
    DesiredZoomLevel = MaxZoomLevel;
    if( ZoomLevel == 0 )
        myHUD.FadeZoom();
    bZooming = true;
}


function CancelZoom()
{
    ZoomLevel = 0;
    if ( DesiredFOV != DefaultFOV )
        myHUD.FadeZoom();
    bZooming = false;
    DesiredFOV = DefaultFOV;
}

function SetWeaponFOV( float f )
{
    if( f > 0 )
        DesiredFOV = f;
    else
        DesiredFOV = DefaultFOV;
}



// ============================================================================
//
// ============================================================================
exec function etrace( int ax, int ay, int az, int bx, int by, int bz )
{
    local vector HL,HN,TE,TS;
    local Actor A;

    TE = ax*vect(1,0,0)+ay*vect(0,1,0)+az*vect(0,0,1);
    TS = bx*vect(1,0,0)+by*vect(0,1,0)+bz*vect(0,0,1);

    bIgnoreOutOfWorld  = True;
    A = Trace(HL,HN,TE,TS);

    //if( TraceThisActor(HL,HN,TE,TS) )
    if( A != None )
    {
        DrawStayingDebugLine(TS,HL,255,0,0);
        DrawStayingDebugLine(HL,HL+HN*64,0,125,255);
    }
    else
    {
        DrawStayingDebugLine(TS,TE,0,255,0);
        DrawStayingDebugLine(TE,TE+Normal(TE-TS)*64,255,125,0);
    }

    //native(309) final iterator function TraceActors   ( class<actor> BaseClass, out actor Actor, out vector HitLoc, out vector HitNorm, vector End, optional vector Start, optional vector Extent );

//    foreach TraceActors( class'Actor', A, HL, HN, TE, TS )
//    {
//        Log( A @HL @HN @TS @TE );
//    }
    Log( A @HL @HN @TS @TE );
}

simulated function OverrideSong()
{
    local int i;
    local string S;

//    S = Level.GetLocalURL();
//    i = InStr(S,"?");
//    if( i != -1 )
//        S = Left(S,i);

    S = string(Level);
    i = InStr(S,".");
    if( i != -1 )
        S = Left(S,i);

    Log( S @Level @Level.Song );

    for( i=0; i!=SongOverride.Length; ++i )
    {
        if( S ~= SongOverride[i].Map )
        {
            if( SongOverride[i].Song != "" )
            {
                Level.Song = SongOverride[i].Song;
                Level.default.Song = Level.Song;
                //StopAllMusic(0);
                //PlayMusic(Level.Song);
            }
            break;
        }
    }
}


function ServerUse()
{
    local Actor A;
    local Vehicle DrivenVehicle, EntryVehicle, V;

    if ( Role < ROLE_Authority )
        return;

    bSuccessfulUse = false;

    if ( Level.Pauser == PlayerReplicationInfo )
    {
        SetPause(false);
        return;
    }

    if (Pawn == None || !Pawn.bCanUse)
        return;

    DrivenVehicle = Vehicle(Pawn);
    if( DrivenVehicle != None )
    {
        DrivenVehicle.KDriverLeave(false);
        return;
    }

    // Check for nearby vehicles
    ForEach Pawn.VisibleCollidingActors(class'Vehicle', V, VehicleCheckRadius)
    {
        // Found a vehicle within radius
        EntryVehicle = V.FindEntryVehicle(Pawn);
        if (EntryVehicle != None && EntryVehicle.TryToDrive(Pawn))
            return;
    }

    // Send the 'DoUse' event to each actor player is touching.
    ForEach Pawn.TouchingActors(class'Actor', A)
        A.UsedBy(Pawn);

    if( Pawn.Base != None )
        Pawn.Base.UsedBy( Pawn );

    if( !bSuccessfulUse && Pawn.Weapon != None )
        Pawn.Weapon.UsedBy(Pawn);
}


state GameEnded
{
ignores SeePlayer, HearNoise, KilledBy, NotifyBump, HitWall, NotifyHeadVolumeChange, NotifyPhysicsVolumeChange, Falling, TakeDamage, Suicide;

Begin:
    if( MyHUD != None )
        MyHUD.bShowScoreBoard = True;
}

DefaultProperties
{
    PlayerReplicationInfoClass=class'jrPRIEX'
    CheatClass=class'jrCheatManager'

}
