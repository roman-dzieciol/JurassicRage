// ============================================================================
//  jrShotgunAmmo.uc ::
// ============================================================================
class jrShotgunAmmo extends jrAmmo;



DefaultProperties
{

    ItemName="Buckshot"
    IconMaterial=Material'HudContent.Generic.HUD'
    IconCoords=(X1=336,Y1=82,X2=382,Y2=125)

    PickupClass=class'jrShotgunAmmoPickup'
    MaxAmmo=80
    InitialAmount=16
}
