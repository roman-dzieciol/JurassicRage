// ============================================================================
//  jrDamTypeFirearm.uc ::
// ============================================================================
class jrDamTypeFirearm extends jrDamTypeWeapon;



DefaultProperties
{

    DeathString="%k put a hole in %o"
    MaleSuicide="%o shot himself in the foot."
    FemaleSuicide="%o shot herself in the foot."

    WeaponClass=class'ClassicSniperRifle'
    bNeverSevers=true
    VehicleDamageScaling=0.65
    bBulletHit=True
}
