// ============================================================================
//  jrSecurity.uc ::
// ============================================================================
//  Copyright 2006 Jurassic Rage team. All Rights Reserved.
//  http://www.jurassic-rage.com
// ============================================================================
class jrSecurity extends jrHuman;



simulated function string GetDefaultCharacter()
{
    PlacedFemaleCharacterName = "SecurityGrunt";
    PlacedCharacterName = "SecurityGrunt";
    return PlacedCharacterName;
}

DefaultProperties
{
}
