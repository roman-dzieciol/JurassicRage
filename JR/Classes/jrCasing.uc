// ============================================================================
//  jrCasing.uc ::
// ============================================================================
class jrCasing extends jrActor;


var() RangeVector       InitialVelocity;
var() float             DampenFactor;
var() float             DampenFactorParallel;

var() Sound             ImpactSound;
var() float             SoundTime;

var() float             ExtraGravity;
var() float             InitialSpin;

event PostBeginPlay()
{
    Velocity.X = RandRange(InitialVelocity.X.Min,InitialVelocity.X.Max);
    Velocity.Y = RandRange(InitialVelocity.Y.Min,InitialVelocity.Y.Max);
    Velocity.Z = RandRange(InitialVelocity.Z.Min,InitialVelocity.Z.Max);

    Velocity = Velocity >> Rotation;

    if( Owner != None )
    {
        Velocity += Owner.Velocity;
    }

    Acceleration = PhysicsVolume.default.Gravity * ExtraGravity;

    RandSpin(InitialSpin);
}

simulated final function RandSpin(float spinRate)
{
    DesiredRotation = RotRand();
    RotationRate.Yaw = spinRate * 2 *FRand() - spinRate;
    RotationRate.Pitch = spinRate * 2 *FRand() - spinRate;
    RotationRate.Roll = spinRate * 2 *FRand() - spinRate;
}

simulated function HitWall( vector HitNormal, Actor HitActor )
{
    local vector VN;
    local float speed;


    // Reflect off Wall w/damping
    VN = (Velocity dot HitNormal) * HitNormal;
    Velocity = -VN * DampenFactor + (Velocity - VN) * DampenFactorParallel;

    RandSpin(100000);
    DesiredRotation.Roll = 0;
    RotationRate.Roll = 0;
    Speed = VSize(Velocity);

    if( Speed < 50 )
    {
        bBounce = False;
        SetPhysics(PHYS_None);
        SetCollision(false,false);
        DesiredRotation = Rotation;
        DesiredRotation.Roll = 0;
        DesiredRotation.Pitch = 0;
        SetRotation(DesiredRotation);
        if( HitActor != None )
        {
            SetBase(HitActor);
        }
    }
    else
    {
        if( Level.NetMode != NM_DedicatedServer && Speed > 60 && SoundTime < Level.TimeSeconds )
        {
            PlaySound( ImpactSound, SLOT_Misc );
            SoundTime = Level.TimeSeconds + 0.25;
        }
        else
        {
            bFixedRotationDir = false;
            bRotateToDesired = true;
            DesiredRotation.Pitch = 0;
            RotationRate.Pitch = 50000;
        }
    }
}

DefaultProperties
{

    InitialSpin                     = 32768
    ExtraGravity                    = 1.0

    DampenFactor                    = 0.5
    DampenFactorParallel            = 0.8
    InitialVelocity                 = (X=(Min=240.000000,Max=320.000000),Y=(Min=350.000000,Max=80.000000))

    LifeSpan                        = 20
    ImpactSound                     = ProceduralSound'WeaponSounds.PShell1.P1Shell1'

    Physics                         = PHYS_Falling
    DrawType                        = DT_StaticMesh
    StaticMesh                      = StaticMesh'XEffects.ShellCasing'
    DrawScale                       = 0.33

    bAcceptsProjectors              = True
    bStatic                         = False
    bShadowCast                     = False
    bNoDelete                       = False
    RemoteRole                      = ROLE_None

    bBounce                         = True // No Landed() please
    bHardAttach                     = True

    bCollideActors                  = True
    bCollideWorld                   = True
    bProjTarget                     = False
    bBlockActors                    = False
    bBlockNonZeroExtentTraces       = False
    bBlockZeroExtentTraces          = False
    bWorldGeometry                  = False
    bBlockKarma                     = False
    bUseCollisionStaticMesh         = True


    bFixedRotationDir               = True
    DesiredRotation                 = (Pitch=12000,Yaw=5666,Roll=2334)

    CollisionHeight                 = 1
    CollisionRadius                 = 1
}
