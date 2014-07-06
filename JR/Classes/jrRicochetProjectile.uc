// ============================================================================
//  jrRicochetProjectile.uc ::
// ============================================================================
class jrRicochetProjectile extends jrProjectile;


var xEmitter Trail;
var byte Bounces;
var float DamageAtten;
var sound ImpactSounds[6];
var() InterpCurve RicochetChance;
var bool bInit;
var class<xEmitter> HitEffectClass;

var float VelocityHit;

replication
{
    reliable if (bNetInitial && Role == ROLE_Authority)
        Bounces;
}

simulated function Destroyed()
{
    if (Trail !=None) Trail.mRegen=False;
    Super.Destroyed();
}

simulated function PostNetBeginPlay()
{
    local float r;
//    local PlayerController PC;
//    local vector Dir,LinePos,LineDir, OldLocation;

    if ( Level.NetMode != NM_DedicatedServer )
    {
        if ( !PhysicsVolume.bWaterVolume )
        {
            Trail = Spawn(class'FlakTrail',self);
            Trail.Lifespan = Lifespan;
        }
    }

    Velocity = Vector(Rotation) * (Speed);
    if (PhysicsVolume.bWaterVolume)
        Velocity *= 0.65;

    r = FRand();

    SetRotation(RotRand());

    Super.PostBeginPlay();


//    // see if local player controller near bullet, but missed
//    PC = Level.GetLocalPlayerController();
//    if ( (PC != None) && (PC.Pawn != None) )
//    {
//        Dir = Normal(Velocity);
//        LinePos = (Location + (Dir dot (PC.Pawn.Location - Location)) * Dir);
//        LineDir = PC.Pawn.Location - LinePos;
//        if ( VSize(LineDir) < 150 )
//        {
//            OldLocation = Location;
//            SetLocation(LinePos);
//            if ( FRand() < 0.5 )
//                PlaySound(sound'Impact3Snd',,,,80);
//            else
//                PlaySound(sound'Impact7Snd',,,,80);
//            SetLocation(OldLocation);
//        }
//    }

     bCollideWorld=True;
     SetCollision(True);
}

simulated function ProcessTouch (Actor Other, vector HitLocation)
{
    if ( (FlakChunk(Other) == None) && ((Physics == PHYS_Falling) || (Other != Instigator)) )
    {
        speed = VSize(Velocity);
        if ( speed > 200 )
        {
            if ( Role == ROLE_Authority )
            {
                if ( Instigator == None || Instigator.Controller == None )
                    Other.SetDelayedDamageInstigatorController( InstigatorController );

                Other.TakeDamage( Max(5, Damage - DamageAtten*FMax(0,(default.LifeSpan - LifeSpan - 1))), Instigator, HitLocation,
                    (MomentumTransfer * Velocity/speed), MyDamageType );
            }
        }
        Destroy();
    }
}

simulated function Landed( Vector HitNormal )
{
    SetPhysics(PHYS_None);
    LifeSpan = 1.0;
}

simulated function HitWall( vector HitNormal, actor Wall )
{
    local float f;
    local PlayerController PC;

    if ( !Wall.bStatic && !Wall.bWorldGeometry
        && ((Mover(Wall) == None) || Mover(Wall).bDamageTriggered) )
    {
        if ( Level.NetMode != NM_Client )
        {
            if ( Instigator == None || Instigator.Controller == None )
                Wall.SetDelayedDamageInstigatorController( InstigatorController );
            Wall.TakeDamage( Damage, instigator, Location, MomentumTransfer * Normal(Velocity), MyDamageType);
        }
        Destroy();
        return;
    }

    SetPhysics(PHYS_Falling);

    // Hit wall
    f = InterpCurveEval( RicochetChance, HitNormal dot Normal(Velocity) );
    if( f > FRand() && VSize(Velocity) > 2000 )
    {
        if ( !Level.bDropDetail && (FRand() < 0.4) )
            Playsound(ImpactSounds[Rand(6)]);

        Velocity = VelocityHit * (Velocity - 2.0*HitNormal*(Velocity dot HitNormal));

        //if ( (Level.NetMode != NM_DedicatedServer) && (Speed > 250) )
        //    PlaySound(ImpactSound, SLOT_Misc );

        if ( !Level.bDropDetail && (Level.DetailMode != DM_Low) && EffectIsRelevant(Location,false) )
        {
            PC = Level.GetLocalPlayerController();
            if ( (PC.ViewTarget != None) && VSize(PC.ViewTarget.Location - Location) < 6000 )
                Spawn(HitEffectClass,,, Location, Rotator(HitNormal));
        }

        return;
    }
    bBounce = false;
    if (Trail != None)
    {
        Trail.mRegen=False;
        Trail.SetPhysics(PHYS_None);
        //Trail.mRegenRange[0] = 0.0;//trail.mRegenRange[0] * 0.6;
        //Trail.mRegenRange[1] = 0.0;//trail.mRegenRange[1] * 0.6;
    }
}

simulated function PhysicsVolumeChange( PhysicsVolume Volume )
{
    if (Volume.bWaterVolume)
    {
        if ( Trail != None )
            Trail.mRegen=False;
        Velocity *= 0.65;
    }
}

DefaultProperties
{
     bCollideActors=False
     bCollideWorld=False
    VelocityHit=0.65
    Style=STY_Alpha
    ScaleGlow=1.0
    DrawType=DT_StaticMesh
    StaticMesh=StaticMesh'WeaponStaticMesh.FlakChunk'
    MyDamageType=class'DamTypeFlakChunk'
    FluidSurfaceShootStrengthMod=1.f
    speed=20000.000000
    MaxSpeed=20000.000000
    Damage=13
    DamageAtten=5.0 // damage reduced per second from when the chunk was fired
    MomentumTransfer=10000
    LifeSpan=2.7
    bBounce=true
    Bounces=3
    NetPriority=2.500000
    AmbientGlow=254
    DrawScale=14.0
    CullDistance=+3000.0
    HitEffectClass=class'XEffects.WallSparks'
    ImpactSounds(0)=sound'XEffects.Impact4Snd'
    ImpactSounds(1)=sound'XEffects.Impact6Snd'
    ImpactSounds(2)=sound'XEffects.Impact7Snd'
    ImpactSounds(3)=sound'XEffects.Impact3'
    ImpactSounds(4)=sound'XEffects.Impact1'
    ImpactSounds(5)=sound'XEffects.Impact2'
        RicochetChance=(Points=((InVal=-1.0,OutVal=0.033),(InVal=-0.71,OutVal=0.2),(InVal=0.0,OutVal=0.5)))

}
