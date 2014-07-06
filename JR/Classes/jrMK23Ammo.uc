// ============================================================================
//  jrMK23Ammo.uc ::
// ============================================================================
class jrMK23Ammo extends jrAmmo;



DefaultProperties
{

    ItemName=".45 ACP Bullets"
    IconMaterial=Material'HudContent.Generic.HUD'
    IconCoords=(X1=451,Y1=445,X2=510,Y2=500)

    bTryHeadShot=true
    PickupClass=class'jrMK23AmmoPickup'
    MaxAmmo=72
    InitialAmount=24
}
