// ============================================================================
//  jrFireInstant.uc ::
// ============================================================================
class jrFireInstant extends jrFire;


var   class<DamageType> DamageType;
var   int DamageMin, DamageMax;
var   float TraceRange;
var   float Momentum;
var() vector FireOffset;

var() float HeadShotDamageMult;
var() class<DamageType> DamageTypeHeadShot;
var() int Bullets;

var() InterpCurve RicochetChance;
var() int RicochetLimit;

var() Sound BodyHitSound;

function float MaxRange()
{
    if (Instigator.Region.Zone.bDistanceFog)
        TraceRange = FClamp(Instigator.Region.Zone.DistanceFogEnd, 8000, default.TraceRange);
    else
        TraceRange = default.TraceRange;

    return TraceRange;
}

function DoFireEffect()
{
    local vector X,Y,Z, StartTrace, RecLoc;
    local rotator AimRot, RecRot, PR;
    local float Cone;
    local int i;

    Instigator.MakeNoise(1.0);

    // The to-hit trace always starts right in front of the eye
    Weapon.GetViewAxes(X,Y,Z);
    StartTrace = GetFireStart(X,Y,Z);
    StartTrace = StartTrace + X*FireOffset.X + Y*FireOffset.Y + Z*FireOffset.Z;
    AimRot = AdjustAim(StartTrace, AimError);

    // Apply recoil
    if( jrFirearm(Weapon) != None && jrFirearm(Weapon).bUseRecoil )
    {
        jrFirearm(Weapon).CalcRecoil( RecLoc, RecRot);
        RecRot *= AccuracyRecoil;
        RecLoc *= AccuracyRecoil;

        GetAxes(RecRot,X,Y,Z);
        StartTrace = StartTrace + X*RecLoc.X + Y*RecLoc.Y + Z*RecLoc.Z;
        AimRot = OrthoRotation( X>>AimRot, Y>>AimRot, Z>>AimRot );
    }

    // Shooter firing cone
    if( AccuracyShooter > 0 && jrHuman(Instigator) != None )
    {
        Cone = jrHuman(Instigator).GetAccuracy() * AccuracyShooter * FRand();
        GetDistAxes( Cone, X,Y,Z );
        AimRot = OrthoRotation( X>>AimRot, Y>>AimRot, Z>>AimRot );
    }

    // Weapon aim cone
    if( AccuracyWeapon > 0 && jrWeapon(Weapon) != None )
    {
        Cone = jrWeapon(Weapon).GetAccuracy() * AccuracyWeapon * FRand();
        GetDistAxes( Cone, X,Y,Z );
        AimRot = OrthoRotation( X>>AimRot, Y>>AimRot, Z>>AimRot );
    }

    for( i=0; i!=Bullets; ++i )
    {
        // Base firing cone
        Cone = jrWeapon(Weapon).GetAccuracyBase() * AccuracyBase * FRand() * FRand();
        GetDistAxes( Cone, X,Y,Z );
        PR = OrthoRotation( X>>AimRot, Y>>AimRot, Z>>AimRot );

        // Trace
        DoTrace(StartTrace, PR);
    }
}

function DoTrace(Vector Start, Rotator Dir)
{
    local Vector X, End, HitLocation, HitNormal;
    local Actor Other;
    local int RicochetCount;
    local SniperWallHitEffect S;
    local Pawn HeadShotPawn;
    local float f;

    MaxRange();

    X = Vector(Dir);
    End = Start + TraceRange * X;

    Other = Weapon.Trace(HitLocation, HitNormal, End, Start, true);

    if( Other != None && (Other != Instigator || RicochetCount > 0) )
    {
        if( !Other.bWorldGeometry )
        {
            // Hit target

            if (Vehicle(Other) != None)
                HeadShotPawn = Vehicle(Other).CheckForHeadShot(HitLocation, X, 1.0);

            if (HeadShotPawn != None)
                HeadShotPawn.TakeDamage(DamageMax * HeadShotDamageMult, Instigator, HitLocation, Momentum*X, DamageTypeHeadShot);
            else if ( (Pawn(Other) != None) && Pawn(Other).IsHeadShot(HitLocation, X, 1.0))
                Other.TakeDamage(DamageMax * HeadShotDamageMult, Instigator, HitLocation, Momentum*X, DamageTypeHeadShot);
            else
                Other.TakeDamage(DamageMax, Instigator, HitLocation, Momentum*X, DamageType);

            if( jrPawn(Other) != None )
                Other.PlaySound(BodyHitSound,SLOT_Interface,4,,256);
        }
        else
        {
            // Hit wall
            f = InterpCurveEval( RicochetChance, HitNormal dot X );
            if( f > FRand() )
            {
                Start = HitLocation + 2.0 * HitNormal;
                Dir = /*Rotator(HitNormal);*/ Rotator( X - 2.0*HitNormal*(X dot HitNormal) );
                Weapon.Spawn(class'jrRicochetProjectile',Instigator.Controller,,Start,Dir);
            }
        }
    }
    else
    {
        // Hit None
        HitLocation = End;
        HitNormal = Normal(Start - End);
    }

    if ( (HitNormal != Vect(0,0,0)) && (HitScanBlockingVolume(Other) == None) )
    {
        S = Weapon.Spawn(class'SniperWallHitEffect',,, HitLocation, rotator(-1 * HitNormal));
        if ( S != None )
            S.FireStart = Start;
    }
}



//function DoTrace( Vector Start, Rotator Dir )
//{
//    local Vector X,Y,Z, End, HitLocation, HitNormal, ArcEnd;
//    local Actor Other;
//    local SniperWallHitEffect S;
//    local Pawn HeadShotPawn;
//
//    f += InterpCurveEval( AccuracyHealth, h );
//    Weapon.GetViewAxes(X, Y, Z);
//
//    while()
//
//    X = Vector(Dir);
//    End = Start + TraceRange * X;
//    Other = Weapon.Trace(HitLocation, HitNormal, End, Start, true);
//
//    //if( Level.NetMode != NM_Standalone || PlayerController(Instigator.Controller) == None )
//    //    Weapon.Spawn(class'jrTracerProjectile',Instigator.Controller,,Start,Dir);
//
//    if( Other != None && Other != Instigator )
//    {
//        if ( !Other.bWorldGeometry )
//        {
//            if (Vehicle(Other) != None)
//                HeadShotPawn = Vehicle(Other).CheckForHeadShot(HitLocation, X, 1.0);
//
//            if (HeadShotPawn != None)
//                HeadShotPawn.TakeDamage(DamageMax * HeadShotDamageMult, Instigator, HitLocation, Momentum*X, DamageTypeHeadShot);
//            else if ( (Pawn(Other) != None) && Pawn(Other).IsHeadShot(HitLocation, X, 1.0))
//                Other.TakeDamage(DamageMax * HeadShotDamageMult, Instigator, HitLocation, Momentum*X, DamageTypeHeadShot);
//            else
//                Other.TakeDamage(DamageMax, Instigator, HitLocation, Momentum*X, DamageType);
//        }
//        else
//                HitLocation = HitLocation + 2.0 * HitNormal;
//    }
//    else
//    {
//        HitLocation = End;
//        HitNormal = Normal(Start - End);
//    }
//
//    if ( (HitNormal != Vect(0,0,0)) && (HitScanBlockingVolume(Other) == None) )
//    {
//        S = Weapon.Spawn(class'SniperWallHitEffect',,, HitLocation, rotator(-1 * HitNormal));
//        if ( S != None )
//            S.FireStart = Start;
//    }
//}

function SpawnBeamEffect(Vector Start, Rotator Dir, Vector HitLocation, Vector HitNormal, int ReflectNum)
{
}

DefaultProperties
{
    DamageTypeHeadShot      = class'jrDamTypeHeadshot'
    DamageType              = class'jrDamTypeFirearm'


    HeadShotDamageMult      = 2.0
    Bullets                 = 1
    TraceRange              = 10000.000000
    Momentum                = 1.000000
    NoAmmoSound             = ProceduralSound'WeaponSounds.PReload5.P1Reload5'

    SmokeEffectClass        = class'jrMuzzleSmokeEmitter'
    RicochetLimit           = 8

    RicochetChance          = (Points=((InVal=-1.0,OutVal=0.033),(InVal=-0.71,OutVal=0.2),(InVal=0.0,OutVal=0.5)))

    BodyHitSound            = Sound'JRSD_Hit.BulletBodyHit'

    ShellActorClass         = class'jrCasing'
    SmokeBone               = "bone muzzle"
    ShellBone               = "Bone Eject"
}
