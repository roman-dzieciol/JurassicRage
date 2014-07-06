// ============================================================================
//  jrFireContextual.uc ::
// ============================================================================
class jrFireContextual extends jrFireUtil;


function DoFireEffect()
{
    jrWeapon(Weapon).ContextFire();
}


DefaultProperties
{
    FireRate            = 0.1
    bModeExclusive      = false
    bWaitForRelease     = true
    FireAnim            = ""
    FireEndAnim            = ""
    PreFireAnim            = ""
     BotRefireRate=0
}
