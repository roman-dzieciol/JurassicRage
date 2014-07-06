// ============================================================================
//  jrShotgunAmmo.uc ::
// ============================================================================
class jrShotgunAmmoPickup extends jrAmmoPickup;



DefaultProperties
{

    InventoryType=class'jrShotgunAmmo'

    PickupMessage="You got 8 shotgun shells."
    PickupSound=Sound'PickupSounds.AssaultAmmoPickup'
    PickupForce="AssaultAmmoPickup"  // jdf

    AmmoAmount=8

    CollisionHeight=12.500000
    MaxDesireability=0.20000

    StaticMesh=StaticMesh'WeaponStaticMesh.AssaultAmmoPickup'
    DrawType=DT_StaticMesh
    TransientSoundVolume=0.4
}
