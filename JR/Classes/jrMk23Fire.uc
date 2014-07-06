// ============================================================================
//  jrMk23Fire.uc ::
// ============================================================================
class jrMk23Fire extends jrFireInstant;



function PlayFiring()
{
    if( Weapon.Mesh != None )
    {
        //Weapon.AnimBlendToAlpha(1,1.0,0.1);
        Weapon.AnimBlendParams( 1, 1, 0, 0, 'Bone Mark23' );
        Weapon.AnimBlendParams( 2, 1, 0, 0, 'bone_Rindex1' );
        Weapon.PlayAnim( FireAnim, FireAnimRate, 0, 1 );
        Weapon.PlayAnim( FireAnim, FireAnimRate, 0, 2 );
    }

    Weapon.PlayOwnedSound(FireSound,SLOT_Interact,TransientSoundVolume,,TransientSoundRadius,Default.FireAnimRate/FireAnimRate,false);
    ClientPlayForceFeedback(FireForce);  // jdf

    FireCount++;
}


DefaultProperties
{
    AmmoClass               = class'jrMk23Ammo'
    AmmoPerFire             = 1
    DamageMin               = 50
    DamageMax               = 50
    FireSound               = Sound'JRSD_Weapons.GMK23_Suppressed'
    FireForce               = "NewSniperShot"
    TraceRange              = 17000
    FireRate                = 0.15


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



    SmokeBone = "bone silencer"
}
