// ============================================================================
//  jrMP5SDGun.uc ::
// ============================================================================
class jrMP5SDGun extends jrFirearm;


DefaultProperties
{
    ItemName                = "H&K MP5SD3"
    Description             = "H&K MP5SD3"


    IdleAnim                = "ready"
    SelectAnim              = "ready"
    PutDownAnim             = "unselected"

    ClipSize(0)             = 30
    ClipAmmo(0)             = 30

    AccuracyBase                = 256
    AccuracySighted             = 0
    AccuracyUnsighted           = 768

    RecoilFrames(0)         = (Time=0.00)
    RecoilFrames(1)         = (Time=0.06,GLoc=(X=-1,Y=0,Z=0),GRot=(Pitch=192,Yaw=192,Roll=0),NLocScale=(X=0.5,Y=0.1,Z=0),NRotScale=(Pitch=192,Yaw=48,Roll=64))
    RecoilFrames(2)         = (Time=0.20,GLoc=(X=-0.5,Y=0,Z=0),GRot=(Pitch=128,Yaw=64,Roll=0),NLocScale=(X=0.25,Y=0.1,Z=0.1),NRotScale=(Pitch=128,Yaw=24,Roll=64))
    RecoilFrames(3)         = (Time=0.30,NLocScale=(X=0.2,Y=0.1,Z=0.1),NRotScale=(Pitch=64,Yaw=16,Roll=64))
    RecoilFrames(4)         = (Time=0.66,NLocScale=(X=0.05,Y=0.05,Z=0.05),NRotScale=(Pitch=32,Yaw=16,Roll=32))
    RecoilFrames(5)         = (Time=0.85,NLocScale=(X=0.025,Y=0.025,Z=0.025),NRotScale=(Pitch=16,Yaw=8,Roll=16))
    RecoilFrames(6)         = (Time=1.5)

    InventoryGroup          = 2

    Mesh                    = SkeletalMesh'JRAN_Firearms.MP5SD'
    FireModeClass(0)        = Class'jrMP5SDFire'
    FireModeClass(1)        = Class'jrFireContextual'
    //FireModeClass(1)        = Class'jrWeaponSightsToggle'
    //PickupClass             = Class'jrMK23Pickup'
    AttachmentClass         = Class'jrMP5SDAttachment'


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

    AIRating=0.66
    CurrentRating=0.66
}
