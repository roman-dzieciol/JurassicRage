// ============================================================================
//  jrMutatorEX2K4.uc ::
// ============================================================================
//  Copyright 2006 Jurassic Rage team. All Rights Reserved.
//  http://www.jurassic-rage.com
// ============================================================================
class jrMutator2K4EX extends jrMutator
    HideDropDown
    CacheExempt;



function bool CheckReplacement( Actor Other, out byte bSuperRelevant )
{
    // set bSuperRelevant to false if want the gameinfo's super.IsRelevant() function called
    // to check on relevancy of this actor.

    bSuperRelevant = 0;
    if ( Pawn(Other) != None )
    {
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
        return false;
    return true;
}



DefaultProperties
{

}
