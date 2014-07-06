// ============================================================================
//  jrMutatorEX.uc ::
// ============================================================================
//  Copyright 2006 Jurassic Rage team. All Rights Reserved.
//  http://www.jurassic-rage.com
// ============================================================================
class jrMutatorEX extends jrMutator
    HideDropDown
    CacheExempt;

var array<string> AmmoReplacement;
var array<string> RequiredEquipment;

function bool CheckReplacement( Actor Other, out byte bSuperRelevant )
{
    local int i;
    local WeaponLocker L;
    local array<CacheManager.WeaponRecord> CL;
    local class<Weapon> W;
    local WeaponLocker.WeaponEntry WE;

    // set bSuperRelevant to false if want the gameinfo's super.IsRelevant() function called
    // to check on relevancy of this actor.

    bSuperRelevant = 0;
    if ( Pawn(Other) != None )
    {
        if( jrHuman(Other) != None )
        {
            for( i=0; i!=RequiredEquipment.Length; ++i )
            {
                jrHuman(Other).RequiredEquipment[i] = RequiredEquipment[i];
            }
        }
        Pawn(Other).bAutoActivate = true;
    }
    else if ( GameObjective(Other) != None )
    {
        Other.bHidden = true;
        GameObjective(Other).bDisabled = true;
        GameObjective(Other).SetActive(false);
        Other.SetCollision(false,false,false);
    }
    else if ( GameObject(Other) != None )
    {
        return false;
    }
    else if ( Other.IsA('Pickup') )
    {
        if( Other.IsA('WeaponPickup') )
        {
            WeaponPickup(Other).bHidden = True;
            return false;
        }
        else if ( Ammo(Other) != None )
        {
            for( i=0; i!=AmmoReplacement.Length; ++i )
            {
                if( string(Other.Class) == AmmoReplacement[i] )
                    return true;
            }

            ReplaceWith( Other, AmmoReplacement[Rand(AmmoReplacement.Length)]);
            return False;
        }
        else if ( Other.IsA('WeaponLocker') )
        {
            L = WeaponLocker(Other);
            L.Weapons.Length = 0;

            class'CacheManager'.static.GetWeaponList(CL);
            for( i=0; i!=CL.Length; ++i )
            {
                if( Caps(Left(CL[i].ClassName,2)) == "JR" )
                {
                    W = class<Weapon>(DynamicLoadObject(CL[i].ClassName,class'Class'));
                    if( W != None )
                    {
                        WE.WeaponClass = W;
                        WE.ExtraAmmo = 0;
                        L.Weapons[L.Weapons.Length] = WE;
                    }
                }
            }

            return true;
        }
        else
        {
            return true;
        }
    }
    else if ( Other.IsA('xPickupBase') )
    {
        if( Other.IsA('xWeaponBase') )
        {
            xWeaponBase(Other).bHidden = True;
            return false;
        }
        else
        {
            return true;
        }
    }

    return true;
}
DefaultProperties
{
    AmmoReplacement(0)="JR.jrMK23AmmoPickup"
    AmmoReplacement(1)="JR.jrMP5AmmoPickup"
    AmmoReplacement(2)="JR.jrShotgunAmmoPickup"

    RequiredEquipment(0)        = "JR.jrMk23Gun"
    RequiredEquipment(1)        = "JR.jrMP5SDGun"
    RequiredEquipment(2)        = "JR.jrSPAS12Gun"
}
