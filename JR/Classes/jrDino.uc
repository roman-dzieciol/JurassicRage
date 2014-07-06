// ============================================================================
//  jrDino.uc ::
// ============================================================================
//  Copyright 2006 Jurassic Rage team. All Rights Reserved.
//  http://www.jurassic-rage.com
// ============================================================================
class jrDino extends jrMonster;


var Mesh RMesh;
var Mesh CollisionMesh;

var float MeleeDamage;
var bool bLeapAttack;

var name AttackAnim;


var     vector              LeapShakeRotMag;
var     vector              LeapShakeRotRate;
var     float               LeapShakeRotTime;
var     vector              LeapShakeOffsetMag;
var     vector              LeapShakeOffsetRate;
var     float               LeapShakeOffsetTime;

var  float WaterAttackTime;

var bool bContaminated;

var array<Sound> ExplodeSounds;
var array<Sound> ConvulseSounds;
var Sound DiseaseSound;

var range ConvulseSpacing;

function Landed(vector HitNormal)
{
    bLeapAttack = False;
    Super.Landed(HitNormal);
}

function bool PreferMelee()
{
    return true;
}

simulated event PostBeginPlay()
{
    Super.PostBeginPlay();

    InitCollision();
}

simulated function InitCollision()
{
    // Hack to instance correctly the skeletal collision boxes
    GetBoneCoords('');
    SetCollision(false, false);
    SetCollision(true, true);
}

function SetMovementPhysics()
{
    SetPhysics(PHYS_Falling);
}

simulated function PlayDirectionalHit(Vector HitLoc)
{
//    TweenAnim('TakeHit', 0.05);
}


singular function Bump(actor Other)
{
    if( bLeapAttack && Other == Controller.Target )
    {
        LeapBite(Other);
        bLeapAttack = False;
    }
    Super.Bump(Other);
}

function float RangedAttackTime()
{
    return 0.33+FRand()*0.33;
}

function RangedAttack(Actor A)
{
    local float Dist;

    if( bLeapAttack )
        return;

    if( Physics == PHYS_Walking )
    {

        Dist = VSize(A.Location - Location);
        if( Dist > MeleeRange + CollisionRadius + A.CollisionRadius )
            return;

        PlaySound(FireSound,SLOT_Talk);
        bLeapAttack = true;
        Acceleration = vect(0,0,0);
        //Controller.bPreparingMove = true;

        Enable('Bump');


        Velocity = A.Location - Location;
        Velocity += A.Velocity * Abs( vector(Rotation) dot Normal(A.Velocity)  );
        Velocity.Z = 0;
        Velocity = AirSpeed * Normal(Velocity);
        Velocity.Z = 320;

        SetPhysics(PHYS_Falling);

        if( bLeapAttack && Dist < 48 + CollisionRadius + A.CollisionRadius )
        {
            bLeapAttack = False;
            LeapBite(A);
        }
    }
    else if ( Physics == PHYS_Swimming )
    {
        Dist = VSize(A.Location - Location);
        if( WaterAttackTime < Level.TimeSeconds && Dist < 48 + CollisionRadius + A.CollisionRadius )
        {
            WaterAttackTime = Level.TimeSeconds + 0.33 + RangedAttackTime();
            LeapBite(A);
        }
    }


}


function bool LeapBite( Actor A )
{
    local vector HitLocation, HitNormal;
    local Actor HitActor;
    Local Pawn P;

    if( A == None )
        return false;

    HitActor = Trace(HitLocation, HitNormal, A.Location, Location, false);
    if( HitActor != None )
        return False;

    A.TakeDamage(MeleeDamage, self, HitLocation, 20000.0 * Normal(A.Location - Location), class'jrMeleeDamage');

    P = Pawn(A);
    if( P != None )
    {
        P.AddVelocity( Normal(Velocity) * 128 );
        //PlaySound(AttackSound, SLOT_None,2*TransientSoundVolume,,400);
        //PlayAnim(AttackAnim,,0.2);
        if( P.Controller != None )
        {
            if( FRand() > 0.5 ) LeapShakeRotRate.X *= -1;
            if( FRand() > 0.5 ) LeapShakeRotRate.Y *= -1;
            if( FRand() > 0.5 ) LeapShakeRotRate.Z *= -1;

            if( FRand() > 0.5 ) LeapShakeOffsetRate.X *= -1;
            if( FRand() > 0.5 ) LeapShakeOffsetRate.Y *= -1;
            if( FRand() > 0.5 ) LeapShakeOffsetRate.Z *= -1;

            P.Controller.ShakeView(LeapShakeRotMag*1, LeapShakeRotRate, LeapShakeRotTime, LeapShakeOffsetMag*1, LeapShakeOffsetRate, LeapShakeOffsetTime);
         }
    }
    return True;
}

function PlayDyingAnimation(class<DamageType> DamageType, vector HitLoc)
{
    local KarmaParamsSkel KP;

    Super.PlayDyingAnimation(DamageType,HitLoc);

    KP = KarmaParamsSkel(KParams);
    if( KP != None )
    {
        KP.bKDoConvulsions = True;
    }

    if( Lifespan > 0 )
        Lifespan += FRand()*5;
}


function Died(Controller Killer, class<DamageType> damageType, vector HitLocation)
{
    local Pickup P;

    Super.Died(Killer,DamageType,HitLocation);

    if( Health <= 0 )
    {
        if( !bContaminated )
        {
            bContaminated = True;
            P = Spawn(class'jrBloodSamplePickup',None,,Location+vect(0,0,16));
            if( P != None )
            {
                P.InitDroppedPickupFor(None);
                //P.SetBase(self);
            }
        }
    }
}


state Dying
{
    simulated event Destroyed()
    {
        if( !bGibbed )
        {
            SpawnGibs(rotator(vect(0,0,1)),4*(0.5-FRand()));
            PlaySound(ExplodeSounds[Rand(ExplodeSounds.Length)],,5.0*TransientSoundVolume,true,500);
            AmbientSound = None;
            SoundVolume = 0;
        }

        Super.Destroyed();
    }

    simulated function TakeDamage( int Damage, Pawn InstigatedBy, Vector Hitlocation, Vector Momentum, class<DamageType> damageType)
    {
        local Vector SelfToHit, SelfToInstigator, CrossPlaneNormal;
        local float W;
        local float YawDir;

        local Vector HitNormal;
        local Vector PushLinVel;
        local Name HitBone;
        local float HitBoneDist;
        local int MaxCorpseYawRate;

        if ( bFrozenBody || bRubbery )
            return;

        if( Physics == PHYS_KarmaRagdoll )
        {
            // Can't shoot corpses during de-res
            if( bDeRes || bRubbery )
                return;

            if ( Momentum == vect(0,0,0) )
                Momentum = HitLocation - InstigatedBy.Location;

            PushLinVel = RagShootStrength*Normal(Momentum);
            KAddImpulse(PushLinVel, HitLocation);

            if ( (DamageType.Default.DamageOverlayMaterial != None) && (Level.DetailMode != DM_Low) && !Level.bDropDetail )
                SetOverlayMaterial(DamageType.Default.DamageOverlayMaterial, DamageType.default.DamageOverlayTime, true);


            //if( LifeSpan > 0 && LifeSpan < RagdollLifeSpan )
            //    LifeSpan += 0.5;

            return;
        }

        if ( DamageType.default.bFastInstantHit && GetAnimSequence() == 'Death_Spasm' && RepeaterDeathCount < 6)
        {
            PlayAnim('Death_Spasm',, 0.2);
            RepeaterDeathCount++;
        }
        else if (Damage > 0)
        {
            if ( InstigatedBy != None )
            {
                if ( InstigatedBy.IsA('xPawn') && xPawn(InstigatedBy).bBerserk )
                    Damage *= 2;

                // Figure out which direction to spin:

                if( InstigatedBy.Location != Location )
                {
                    SelfToInstigator = InstigatedBy.Location - Location;
                    SelfToHit = HitLocation - Location;

                    CrossPlaneNormal = Normal( SelfToInstigator cross Vect(0,0,1) );
                    W = CrossPlaneNormal dot Location;

                    if( HitLocation dot CrossPlaneNormal < W )
                        YawDir = -1.0;
                    else
                        YawDir = 1.0;
                }
            }
            if( VSize(Momentum) < 10 )
            {
                Momentum = - Normal(SelfToInstigator) * Damage * 1000.0;
                Momentum.Z = Abs( Momentum.Z );
            }

            SetPhysics(PHYS_Falling);
            Momentum = Momentum / Mass;
            AddVelocity( Momentum );
            bBounce = true;

            RotationRate.Pitch = 0;
            RotationRate.Yaw += VSize(Momentum) * YawDir;

            MaxCorpseYawRate = 150000;
            RotationRate.Yaw = Clamp( RotationRate.Yaw, -MaxCorpseYawRate, MaxCorpseYawRate );
            RotationRate.Roll = 0;

            bFixedRotationDir = true;
            bRotateToDesired = false;

            Health -= Damage;
            CalcHitLoc( HitLocation, vect(0,0,0), HitBone, HitBoneDist );

            if( InstigatedBy != None )
                HitNormal = Normal( Normal(InstigatedBy.Location-HitLocation) + VRand() * 0.2 + vect(0,0,2.8) );
            else
                HitNormal = Normal( Vect(0,0,1) + VRand() * 0.2 + vect(0,0,2.8) );

            DoDamageFX( HitBone, Damage, DamageType, Rotator(HitNormal) );
        }
    }

    simulated function BeginState()
    {
        Super.BeginState();
        SetTimer(1,false);
        //SoundVolume = 0;
    }

    simulated function Timer()
    {
//        local KarmaParamsSkel KP;
//        local float f;
//
//        f = FClamp(LifeSpan / RagdollLifeSpan,0,1);
//
//        KP = KarmaParamsSkel(KParams);
//        if( KP != None )
//        {
//            KP.KConvulseSpacing.Min = Smerp(f,ConvulseSpacing.Min,ConvulseSpacing.Max);
//            KP.KConvulseSpacing.Max = KP.KConvulseSpacing.Min + 0.3;
//            KP.bKDoConvulsions = True;
//        }

        //log( "Timer" @SoundVolume );
        //AmbientSound = DiseaseSound;
        //f = 1-(LifeSpan / RagdollLifeSpan);
        //SoundVolume = min(255,SoundVolume+64);
        //SoundRadius = 2 * SoundVolume;
        //SoundVolume = 255;
        //SoundRadius = 512;
        SetTimer(1,false);
    }

    // We shorten the lifetime when the guys comes to rest.
    event KVelDropBelow()
    {
    }

    event KSkelConvulse()
    {
        if( !bGibbed )
        {
            PlaySound(ConvulseSounds[Rand(ConvulseSounds.Length)],,3.5*TransientSoundVolume,false,500);
            MakeNoise(1.0);
        }
    }
}

DefaultProperties
{
    ControllerClass         = class'JR.jrDinoController'

    //FireRootBone              = "bip01 Spine"

    HitSound                    = Sound'U2SnipeA.GHit'
    DeathSound                  = Sound'U2SnipeA.GDie'
    ChallengeSound              = Sound'U2SnipeA.GTaunt'
    FireSound                   = Sound'U2SnipeA.GMelee'
    IdleSound                   = Sound'U2SnipeA.GIdle'

    RootBone                    = "Base"
    HeadBone                    = "Bone04"
    SpineBone1                  = "Bone05"
    SpineBone2                  = "Bone07"

    ConvulseSpacing             = (Min=0.1,Max=2.0)

    DiseaseSound                = Sound'U2SporeA.SporeAmbient_07'

    ExplodeSounds(0)            = Sound'U2A.Gibbed1'
    ExplodeSounds(1)            = Sound'U2A.Gibbed2'
    ExplodeSounds(2)            = Sound'U2A.Gibbed3'

    ConvulseSounds(0)           = Sound'U2A.GibBounce01'
    ConvulseSounds(1)           = Sound'U2A.GibBounce02'
    ConvulseSounds(2)           = Sound'U2A.GibBounce03'
    ConvulseSounds(3)           = Sound'U2A.GibBounce04'

    SoundGroupClass             = Class'JR.jrSoundGroupRaptor'

    RagdollOverride             = "velociraptor"
    MeleeDamage                 = 20

    LeapShakeRotMag             = (X=-1024.000000,Y=1024.000000,Z=1024.000000)
    LeapShakeRotRate            = (X=9000.000000,Y=9000.000000,Z=9000.000000)
    LeapShakeRotTime            = 3.000000
    LeapShakeOffsetMag          = (X=5.000000,Y=6.000000,Z=4.000000)
    LeapShakeOffsetRate         = (X=40.000000,Y=60.000000,Z=50.000000)
    LeapShakeOffsetTime         = 4.000000

    RagdollLifeSpan             = 10.0
    RagDeathVel                 = 25.0

    MeleeRange                  = 96.0

    JumpZ                       = 450
    Health                      = 150
    HealthMax                   = 150
    AirSpeed                    = 640
    GroundSpeed                 = 640
    WaterSpeed                  = 440
    Mass                        = 100
    Buoyancy                    = 150
    RotationRate                = (Pitch=3072,Yaw=60000,Roll=2048)

    CollisionRadius             = 40.0
    CollisionHeight             = 28.0
    bUseCylinderCollision       = True

    DrawScale                   = 1.0
    Mesh                        = SkeletalMesh'JRAN_Raptor.Velociraptor'
    Skins(0)                    = Texture'JRTX_Raptor.velociraptor'

    HearingThreshold            = 1500
    SightRadius                 = 3000

    MovementAnims(0)            = "Run"
    MovementAnims(1)            = "Run"
    MovementAnims(2)            = "Run"
    MovementAnims(3)            = "Run"
    TurnLeftAnim                = "Idle"
    TurnRightAnim               = "Idle"
    SwimAnims(0)                = "Walk"
    SwimAnims(1)                = "Walk"
    SwimAnims(2)                = "Walk"
    SwimAnims(3)                = "Walk"
    CrouchAnims(0)              = "Idle"
    CrouchAnims(1)              = "Idle"
    CrouchAnims(2)              = "Idle"
    CrouchAnims(3)              = "Idle"
    WalkAnims(0)                = "Walk"
    WalkAnims(1)                = "Walk"
    WalkAnims(2)                = "Walk"
    WalkAnims(3)                = "Walk"
    AirAnims(0)                 = "Idle"
    AirAnims(1)                 = "Idle"
    AirAnims(2)                 = "Idle"
    AirAnims(3)                 = "Idle"
    TakeoffAnims(0)             = "Idle"
    TakeoffAnims(1)             = "Idle"
    TakeoffAnims(2)             = "Idle"
    TakeoffAnims(3)             = "Idle"
    LandAnims(0)                = "Null"
    LandAnims(1)                = "Null"
    LandAnims(2)                = "Null"
    LandAnims(3)                = "Null"
    DoubleJumpAnims(0)          = "Idle"
    DoubleJumpAnims(1)          = "Idle"
    DoubleJumpAnims(2)          = "Idle"
    DoubleJumpAnims(3)          = "Idle"
    DodgeAnims(0)               = "Idle"
    DodgeAnims(1)               = "Idle"
    DodgeAnims(2)               = "Idle"
    DodgeAnims(3)               = "Idle"
    AirStillAnim                = "Idle"
    TakeoffStillAnim            = "Idle"
    CrouchTurnRightAnim         = "Idle"
    CrouchTurnLeftAnim          = "Idle"
    IdleCrouchAnim              = "Idle"
    IdleSwimAnim                = "Idle"
    IdleWeaponAnim              = "Idle"
    IdleRestAnim                = "Idle"
    IdleHeavyAnim               = "Idle"
    IdleRifleAnim               = "Idle"

    Begin Object Class=KarmaParamsSkel Name=PawnKParams
        KConvulseSpacing=(Min=0.2,Max=1.0)
        bKDoConvulsions=True
        KLinearDamping=0.2
        KAngularDamping=0.1
        KBuoyancy=1.0
        KStartEnabled=True
        KVelDropBelowThreshold=50.0
        bHighDetailOnly=False
        KFriction=0.6
        KRestitution=0.3
        KImpactThreshold=0.0
    End Object
}
