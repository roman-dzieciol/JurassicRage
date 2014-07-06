// ============================================================================
//  jrWeaponAttachment.uc ::
// ============================================================================
class jrWeaponAttachment extends xWeaponAttachment;


simulated function Vector GetTipLocation()
{
    return GetBoneCoords('Muzzle').Origin;
}

DefaultProperties
{
    DrawScale               = 1.0
    RelativeRotation        = (Pitch=32768,Yaw=0,Roll=0)
}
