// ============================================================================
//  jrSPAS12Fire.uc ::
// ============================================================================
class jrSPAS12Fire extends jrFireInstant;



DefaultProperties
{

    AmmoClass               = class'jrShotgunAmmo'
    AmmoPerFire             = 1
    DamageMin               = 20
    DamageMax               = 20
    FireSound               = Sound'JRSD_Weapons.GSPAS12_Fire'
    FireForce               = "NewSniperShot"
    TraceRange              = 17000

    Bullets         = 9
    FireRate        = 0.25

    PreFireTime             = 0.1
    TweenTime               = 0.1

    bWaitForRelease         = True

    //FireSoundVolume       = 8.0
    //FireSoundRadius       = 250

    PreFireAnim             = "threat"

    //FlashEmitterClass     = class'XEffects.AssaultMuzFlash1st'
    SmokeEmitterClass       = class'jrMK23SmokeEmitter'

    BotRefireRate           = 0.0
    AimError                = 850
    WarnTargetPct           = +0.5
}
