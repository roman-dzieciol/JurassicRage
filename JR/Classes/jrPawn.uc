// ============================================================================
//  jrPawn.uc ::
// ============================================================================
//  Copyright 2006 Jurassic Rage team. All Rights Reserved.
//  http://www.jurassic-rage.com
// ============================================================================
class jrPawn extends xPawn
    abstract;


function bool IsInLoadout(class<Inventory> InventoryClass)
{
    return true;
}




DefaultProperties
{
    bDramaticLighting           = False
    bDontPossess=True
}
