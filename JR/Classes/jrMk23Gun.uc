// ============================================================================
//  jrMk23Gun.uc ::
// ============================================================================
class jrMk23Gun extends jrFirearm;



DefaultProperties
{
    ItemName                = "H&K Mk.23 SOCOM"
    Description             = "H&K Mk.23 SOCOM"


    IdleAnim                = "ready"
    SelectAnim              = "ready"
    PutDownAnim             = "unselected"

    ClipSize(0)             = 12
    ClipAmmo(0)             = 12

    AccuracyBase                = 256

    RecoilFrames(0)             = (Time=0.00)
    RecoilFrames(1)             = (Time=0.05,GLoc=(X=-3,Y=0,Z=-0.25),GRot=(Pitch=4096,Yaw=0,Roll=0),NLocScale=(X=0.2,Y=0.2,Z=0.2),NRotScale=(Pitch=512,Yaw=256,Roll=256))
    RecoilFrames(2)             = (Time=0.10,GLoc=(X=-1.5,Y=0,Z=0.75),GRot=(Pitch=2048,Yaw=0,Roll=0),NLocScale=(X=0.2,Y=0.2,Z=0.2),NRotScale=(Pitch=512,Yaw=256,Roll=256))
    RecoilFrames(3)             = (Time=0.20,GLoc=(X=0,Y=0.0,Z=1.0),NLocScale=(X=0.25,Y=0.2,Z=0.5),NRotScale=(Pitch=512,Yaw=256,Roll=256))
    RecoilFrames(4)             = (Time=0.30,GLoc=(X=0,Y=0.0,Z=0.66),NLocScale=(X=0.2,Y=0.2,Z=0.4),NRotScale=(Pitch=512,Yaw=256,Roll=256))
    RecoilFrames(5)             = (Time=0.50,GLoc=(X=0,Y=0.0,Z=0.0),NLocScale=(X=0.1,Y=0.1,Z=0.2),NRotScale=(Pitch=64,Yaw=32,Roll=64))
    RecoilFrames(6)             = (Time=0.66,GLoc=(X=0,Y=0.0,Z=0.0),NLocScale=(X=0.05,Y=0.05,Z=0.05),NRotScale=(Pitch=32,Yaw=16,Roll=32))
    RecoilFrames(7)             = (Time=0.85,NLocScale=(X=0.025,Y=0.025,Z=0.025),NRotScale=(Pitch=16,Yaw=8,Roll=16))
    RecoilFrames(8)             = (Time=1.5)
    InventoryGroup          = 1

    Mesh                    = SkeletalMesh'JRAN_Firearms.Mk23'
    FireModeClass(0)        = Class'jrMK23Fire'
    FireModeClass(1)        = Class'jrFireContextual'
    //FireModeClass(1)        = Class'jrWeaponSightsToggle'
    //PickupClass             = Class'jrMK23Pickup'
    AttachmentClass         = Class'jrMK23Attachment'

    BoneGun                     = "Dummy01"
    BoneLHand_IK                = "Point01"
    BoneRHand_IK                = "Point02"
    BoneLHand                   = "bone_lhand"
    BoneRHand                   = "bone_rhand"
    BoneLForearm                = "bone_lforearm"
    BoneRForearm                = "bone_rforearm"
    BoneLBicep                  = "bone_lbicep"
    BoneRBicep                  = "bone_rbicep"
    BoneHandsRoot               = "root"

    DispLHand           = 0.45
    DispLForearm        = 0.225
    DispLBicep          = 0.225
    DispRHand           = 0.45
    DispRForearm        = 0.225
    DispRBicep          = 0.225

    RotLHand           = 1.0
    RotLForearm        = 0.0
    RotLBicep          = 0.0
    RotRHand           = 1.0
    RotRForearm        = 0.0
    RotRBicep          = 0.0

    AIRating=0.33
    CurrentRating=0.33
}
