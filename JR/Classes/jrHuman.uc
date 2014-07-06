// ============================================================================
//  jrHuman.uc ::
// ============================================================================
//  Copyright 2006 Jurassic Rage team. All Rights Reserved.
//  http://www.jurassic-rage.com
// ============================================================================
class jrHuman extends jrPawn;



// - Accuracy -------------------------------------------------------------------

const   MT_None         = 0;
const   MT_Fall         = 1;
const   MT_Stand        = 2;
const   MT_Crouch       = 3;
const   MT_Swim         = 4;
const   MT_Ladder       = 5;
const   MT_Vehicle      = 6;
const   MT_Last         = 6;
const   MT_Max          = 7;

const   MS_Idle         = 0;
const   MS_Slow         = 1;
const   MS_Fast         = 2;
const   MS_Top          = 3;
const   MS_Last         = 3;
const   MS_Max          = 4;

var() array<InterpCurve> AccuracyAim;
var() array<InterpCurve> AccuracyPoint;
var() InterpCurve AccuracyHealth;


simulated event PostBeginPlay()
{
    Super.PostBeginPlay();
    InitAccuracy();

}

// ============================================================================
//  Accuracy
// ============================================================================

simulated function InitAccuracy()
{
    SetupAccuracy(AccuracyAim);
    SetupAccuracy(AccuracyPoint);
}

simulated function SetupAccuracy( out array<InterpCurve> data )
{
    data[MT_None].Points[MS_Slow].InVal = GroundSpeed * WalkingPct;
    data[MT_None].Points[MS_Fast].InVal = GroundSpeed;
    data[MT_None].Points[MS_Top].InVal = GroundSpeed * 2;

    data[MT_Fall].Points[MS_Slow].InVal = AirSpeed * WalkingPct;
    data[MT_Fall].Points[MS_Fast].InVal = AirSpeed;
    data[MT_Fall].Points[MS_Top].InVal = AirSpeed * 2;

    data[MT_Stand].Points[MS_Slow].InVal = GroundSpeed * WalkingPct;
    data[MT_Stand].Points[MS_Fast].InVal = GroundSpeed;
    data[MT_Stand].Points[MS_Top].InVal = GroundSpeed * 2;

    // TODO: speeds
    data[MT_Crouch].Points[MS_Slow].InVal = GroundSpeed * WalkingPct;
    data[MT_Crouch].Points[MS_Fast].InVal = GroundSpeed;
    data[MT_Crouch].Points[MS_Top].InVal = GroundSpeed * 2;

    data[MT_Swim].Points[MS_Slow].InVal = WaterSpeed * WalkingPct;
    data[MT_Swim].Points[MS_Fast].InVal = WaterSpeed;
    data[MT_Swim].Points[MS_Top].InVal = WaterSpeed * 2;
}

simulated function float GetAccuracy()
{
    local float f,speed,h;
    local int type;

    // Get movement type
    if( Physics == PHYS_Walking )
    {
        if( bIsCrouched )   type = MT_Crouch;
        else                type = MT_Stand;
    }
    else if( Physics == PHYS_Falling )
    {
        type = MT_Fall;
    }
    else if( Physics == PHYS_Swimming )
    {
        type = MT_Swim;
    }

    // Sights
    if( jrFirearm(Weapon) == None /*|| jrFirearm(Weapon).bUseZoom*/ || jrFirearm(Weapon).bSights )
    {
        // Get movement speed
        InterpCurveGetInputDomain( AccuracyAim[type], f, speed );
        speed = FMin( speed, VSize(Velocity) );

        // Calc shooter's accuracy
        f = InterpCurveEval( AccuracyAim[type], speed );
    }
    else
    {
        // Get movement speed
        InterpCurveGetInputDomain( AccuracyPoint[type], f, speed );
        speed = FMin( speed, VSize(Velocity) );

        // Calc shooter's accuracy
        f = InterpCurveEval( AccuracyPoint[type], speed );
    }

    // Apply health accuracy
    h = FClamp(Health,0,default.Health) / default.Health;
    f += InterpCurveEval( AccuracyHealth, h );

    return F;
}

simulated function bool ForceDefaultCharacter()
{
    return true;
}

simulated function vector CalcDrawOffset(inventory Inv)
{
    local vector DrawOffset;

    if( jrWeapon(Inv) == None )
        return Super.CalcDrawOffset(Inv);

    //if ( Controller == None )
    //    return (Inv.PlayerViewOffset >> Rotation) + BaseEyeHeight * vect(0,0,1);

    //DrawOffset = ((0.9/Weapon.DisplayFOV * 100 * ModifiedPlayerViewOffset(Inv)) >> GetViewRotation() );

    if ( !IsLocallyControlled() )
        DrawOffset.Z += BaseEyeHeight;
    else
    {
        DrawOffset.Z += EyeHeight;
        //if( bWeaponBob )
        //    DrawOffset += WeaponBob(Inv.BobDamping);
        // DrawOffset += CameraShake();
    }

    return DrawOffset;
}

State Dying
{
    simulated function BeginState()
    {
        Super.BeginState();
        bSpecialCalcView = True;
    }

    simulated function Timer()
    {
        if( LifeSpan <= DeResTime && bDeRes == False )
        {
            StartDeRes();
        }
        else
        {
            SetTimer(1.0, False);
        }
    }

    simulated function bool SpectatorSpecialCalcView( PlayerController Viewer, out Actor ViewActor, out vector CameraLocation, out rotator CameraRotation )
    {
        local coords C;
        local vector X,Y,Z;
        local KarmaParamsSkel SkelParams;

        C = GetBoneCoords('head');
        if( C.Origin == vect(0,0,0) )
        {
            return False;
        }

        // UT2004 bipeds head rotation hack
        X = -C.YAxis;
        Y = -C.ZAxis;
        Z = C.XAxis;

        CameraLocation = C.Origin;
        CameraRotation = OrthoRotation(X,Y,Z);

        SkelParams = KarmaParamsSkel(KParams);
        SkelParams.bKImportantRagdoll = True;

        if( Viewer.bBehindView )
            Viewer.bBehindView = false;

        if( Viewport(Viewer.Player) != None )
        {
            if( LifeSpan <= DeResTime )
            {
                //Log("F"@(LifeSpan/DeResTime));
                Viewer.ClientFlash(LifeSpan/DeResTime,vect(0,0,0));
            }
        }

        return true;
    }

    simulated function HideBone( name BoneName )
    {
        if( BoneName == 'head' || BoneName == 'spine' )
        {
            bSpecialCalcView = False;
        }

        Super.HideBone(BoneName);
    }

    simulated event KVelDropBelow()
    {
    }
}

DefaultProperties
{

    // Speed : Idle, Slow, Fast, Top
    AccuracyAim(0)=(Points=((OutVal=32),(OutVal=1024),(OutVal=2048),(OutVal=4096))) // MT_None
    AccuracyAim(1)=(Points=((OutVal=32),(OutVal=1024),(OutVal=2048),(OutVal=4096))) // MT_Fall
    AccuracyAim(2)=(Points=((OutVal=32),(OutVal=512),(OutVal=1536),(OutVal=4096))) // MT_Stand
    AccuracyAim(3)=(Points=((OutVal=0),(OutVal=256),(OutVal=768),(OutVal=4096))) // MT_Crouch
    AccuracyAim(4)=(Points=((OutVal=32),(OutVal=1024),(OutVal=2048),(OutVal=4096))) // MT_Swim
    AccuracyAim(5)=(Points=((OutVal=32),(OutVal=1024),(OutVal=2048),(OutVal=4096))) // MT_Ladder
    AccuracyAim(6)=(Points=((OutVal=32),(OutVal=1024),(OutVal=2048),(OutVal=4096))) // MT_Vehicle

    // Speed : Idle, Slow, Fast, Top
    AccuracyPoint(0)=(Points=((OutVal=384),(OutVal=1024),(OutVal=3072),(OutVal=4096))) // MT_None
    AccuracyPoint(1)=(Points=((OutVal=384),(OutVal=1024),(OutVal=3072),(OutVal=4096))) // MT_Fall
    AccuracyPoint(2)=(Points=((OutVal=256),(OutVal=768),(OutVal=2048),(OutVal=4096))) // MT_Stand
    AccuracyPoint(3)=(Points=((OutVal=192),(OutVal=512),(OutVal=1024),(OutVal=4096))) // MT_Crouch
    AccuracyPoint(4)=(Points=((OutVal=384),(OutVal=1024),(OutVal=3072),(OutVal=4096))) // MT_Swim
    AccuracyPoint(5)=(Points=((OutVal=384),(OutVal=1024),(OutVal=3072),(OutVal=4096))) // MT_Ladder
    AccuracyPoint(6)=(Points=((OutVal=384),(OutVal=1024),(OutVal=3072),(OutVal=4096))) // MT_Vehicle

    AccuracyHealth=(Points=((InVal=0,OutVal=2048),(InVal=0.2,OutVal=512),(InVal=0.5,OutVal=128),(InVal=1,OutVal=0)))

}
