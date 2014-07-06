// ============================================================================
//  jrBloodSamplePickup.uc ::
// ============================================================================
//  Copyright 2006 Jurassic Rage team. All Rights Reserved.
//  http://www.jurassic-rage.com
// ============================================================================
class jrBloodSamplePickup extends JRPickup;

function PostBeginPlay()
{
    Super.PostBeginPlay();
    if( jrGameEX(Level.Game) != None )
        jrGameEX(Level.Game).SpawnedSamples++;
}


function float BotDesireability( Pawn Bot )
{
    return MaxDesireability;
}

auto state Pickup
{
    function Touch( actor Other )
    {
        if( ValidTouch(Other) )
        {
            AnnouncePickup(Pawn(Other));
            SetRespawn();
        }
    }
}

function inventory SpawnCopy( pawn Other )
{
    return None;
}

function InitDroppedPickupFor(Inventory Inv)
{
    Super.InitDroppedPickupFor(Inv);
    SetPhysics(default.Physics);
}


DefaultProperties
{
    bDropped                    = True
    //bOnlyAffectPawns          = True
    bAmbientGlow                = true
    bFixedRotationDir           = True
    bTrailerAllowRotation       = True
    MessageClass                = class'PickupMessagePlus'
    PickupMessage               = "Blood Sample "
    RespawnTime                 = 0.0
    MaxDesireability            = 1000000.0
    RemoteRole                  = ROLE_DumbProxy
    AmbientGlow                 = 128
    CollisionRadius             = 32.0
    CollisionHeight             = 23.0
    Mass                        = 10.0
    Physics                     = PHYS_Falling
    DrawScale                   = 0.06
    PickupSound                 = sound'PickupSounds.HealthPack'
    PickupForce                 = "HealthPack"
    DrawType                    = DT_StaticMesh
    StaticMesh                  = StaticMesh'XPickups_rc.MiniHealthPack'
    RotationRate                = (Yaw=24000)
    Style                       = STY_AlphaZ
    ScaleGlow                   = 0.6
    CullDistance                = 5500.0
    Skins(0)                    = Material'XGameTextures.SuperPickups.MHPickup'
    Skins(1)                    = Material'JRTX_Pickup.MHInnerS'

}
