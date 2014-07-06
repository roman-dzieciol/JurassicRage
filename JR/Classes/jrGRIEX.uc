// ============================================================================
//  jrGRIEX.uc ::
// ============================================================================
//  Copyright 2006 Jurassic Rage team. All Rights Reserved.
//  http://www.jurassic-rage.com
// ============================================================================
class jrGRIEX extends jrGRI;


var byte PlayersCount;
var byte DinosCount;

var jrScoreReplicationInfo HighScore;


replication
{
    reliable if( bNetDirty && Role == ROLE_Authority )
        PlayersCount, DinosCount, HighScore;

}

DefaultProperties
{
    TeamSymbols(0)=Material'JRTX_Symbols.DefaultSymbol'
    TeamSymbols(1)=Material'JRTX_Symbols.DefaultSymbol'
}
