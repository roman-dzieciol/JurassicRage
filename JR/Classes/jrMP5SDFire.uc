// ============================================================================
//  jrMP5SDFire.uc ::
// ============================================================================
class jrMP5SDFire extends jrFireInstant;



DefaultProperties
{

    AmmoClass               = class'jrMP5Ammo'
    AmmoPerFire             = 1
    DamageMin               = 33
    DamageMax               = 33
    FireSound               = Sound'JRSD_Weapons.GMP5SD_Fire'
    FireForce               = "NewSniperShot"
    TraceRange              = 17000

    FireSoundVolume     = 8.0
    FireSoundRadius     = 250

    FireRate            = 0.076

    PreFireTime             = 0.1
    TweenTime               = 0.1


    //FireSoundVolume       = 8.0
    //FireSoundRadius       = 250

    PreFireAnim             = "threat"

    //FlashEmitterClass     = class'XEffects.AssaultMuzFlash1st'
    SmokeEmitterClass       = class'jrMK23SmokeEmitter'

    BotRefireRate           = 0.99
    AimError                = 850
    WarnTargetPct           = +0.5
}
