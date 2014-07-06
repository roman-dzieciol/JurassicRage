// ============================================================================
//  jrMutatorID.uc :: helper object for gametype-less MS queries
// ============================================================================
//  Copyright 2006 Jurassic Rage team. All Rights Reserved.
//  http://www.jurassic-rage.com
// ============================================================================
class jrTag extends Mutator
    HideDropDown
    CacheExempt;


function bool MutatorIsAllowed()
{
    return true;
}

function GetServerDetails(out GameInfo.ServerResponseLine ServerState)
{
    // Do not add game-type default mutators to list
}

DefaultProperties
{

}
