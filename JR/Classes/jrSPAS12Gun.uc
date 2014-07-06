// ============================================================================
//  jrSPAS12Gun.uc ::
// ============================================================================
class jrSPAS12Gun extends jrFirearm;



DefaultProperties
{
    ItemName                = "Franchi SPAS-12"
    Description             = "Franchi SPAS-12"


    IdleAnim                = "ready"
    SelectAnim              = "ready"
    PutDownAnim             = "unselected"

    DisplayFOV              = 45

    RecoilFrames(0)         = (Time=0.00)
    RecoilFrames(1)         = (Time=0.06,GLoc=(X=-4,Y=0.3,Z=0),GRot=(Pitch=768,Yaw=128,Roll=0),NLocScale=(X=0.5,Y=0.2,Z=0),NRotScale=(Pitch=384,Yaw=64,Roll=128))
    RecoilFrames(2)         = (Time=0.20,GLoc=(X=-1.0,Y=0.2,Z=0),GRot=(Pitch=384,Yaw=64,Roll=0),NLocScale=(X=0.25,Y=0.1,Z=0.1),NRotScale=(Pitch=192,Yaw=32,Roll=128))
    RecoilFrames(3)         = (Time=0.30,NLocScale=(X=0.3,Y=0.1,Z=0.1),NRotScale=(Pitch=0,Yaw=32,Roll=128))
    RecoilFrames(4)         = (Time=0.50,NLocScale=(X=0.1,Y=0.1,Z=0.1),NRotScale=(Pitch=64,Yaw=32,Roll=64))
    RecoilFrames(5)         = (Time=0.66,NLocScale=(X=0.05,Y=0.05,Z=0.05),NRotScale=(Pitch=32,Yaw=16,Roll=32))
    RecoilFrames(6)         = (Time=0.85,NLocScale=(X=0.025,Y=0.025,Z=0.025),NRotScale=(Pitch=16,Yaw=8,Roll=16))
    RecoilFrames(7)         = (Time=1.5)

    ReloadDuration          = 0.400000
    ClipSize(0)             = 8
    ClipAmmo(0)             = 8
    bReloadOne              = True
    ReloadBeginSound        = None
    ReloadSound             = Sound'WeaponSounds.BaseGunTech.BReload6'
    ReloadEndSound          = Sound'WeaponSounds.BaseGunTech.BReload11'


    InventoryGroup          = 3

    Mesh                    = SkeletalMesh'JRAN_Firearms.SPAS12'
    FireModeClass(0)        = Class'jrSPAS12Fire'
    FireModeClass(1)        = Class'jrFireContextual'
    //FireModeClass(1)        = Class'jrWeaponSightsToggle'
    //PickupClass             = Class'jrMK23Pickup'
    AttachmentClass         = Class'jrSPAS12Attachment'

    DispLHand           = 0.2
    DispLForearm        = 0.36
    DispLBicep          = 0.34
    DispRHand           = 0.2
    DispRForearm        = 0.36
    DispRBicep          = 0.34

    RotLHand           = 0.2
    RotLForearm        = 0.55
    RotLBicep          = 0.25
    RotRHand           = 0.2
    RotRForearm        = 0.55
    RotRBicep          = 0.25

    FOVAim = 45
    FOVThreat = 45
    FOVReady = 90

    AIRating=1.0
    CurrentRating=1.0

    AccuracyBase                = 1024
}
