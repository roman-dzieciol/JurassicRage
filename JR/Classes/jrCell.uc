// ============================================================================
//  jrCell.uc ::
// ============================================================================
//  Copyright 2006 Jurassic Rage team. All Rights Reserved.
//  http://www.jurassic-rage.com
// ============================================================================
class jrCell extends jrHuman;



simulated function string GetDefaultCharacter()
{
    PlacedFemaleCharacterName = "CellGrunt";
    PlacedCharacterName = "CellGrunt";
    return PlacedCharacterName;
}

DefaultProperties
{

}
