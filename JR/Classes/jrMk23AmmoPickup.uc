// ============================================================================
//  jrMk23Ammo.uc ::
// ============================================================================
class jrMk23AmmoPickup extends jrAmmoPickup;



DefaultProperties
{

    InventoryType=class'ClassicSniperAmmo'

    PickupMessage="You picked up a MK23 clip."
    PickupSound=Sound'PickupSounds.SniperAmmoPickup'
    PickupForce="SniperAmmoPickup"  // jdf

    AmmoAmount=12
    CollisionHeight=16.000000
    PrePivot=(Z=16.0)

    StaticMesh=StaticMesh'NewWeaponStatic.ClassicSniperAmmoM'
    DrawType=DT_StaticMesh
}
