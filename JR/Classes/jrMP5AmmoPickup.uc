// ============================================================================
//  jrMP5SDAmmo.uc ::
// ============================================================================
class jrMP5AmmoPickup extends jrAmmoPickup;



DefaultProperties
{
     AmmoAmount=30
     InventoryType=Class'jrMP5Ammo'
     PickupMessage="You picked up a MP5 clip."
     PickupSound=Sound'PickupSounds.MinigunAmmoPickup'
     PickupForce="MinigunAmmoPickup"
     DrawType=DT_StaticMesh
     StaticMesh=StaticMesh'WeaponStaticMesh.MinigunAmmoPickup'
     CollisionHeight=12.750000
}
