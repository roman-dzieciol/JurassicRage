// ============================================================================
//  jrHighScoreInfo.uc ::
// ============================================================================
//  Copyright 2006 Jurassic Rage team. All Rights Reserved.
//  http://www.jurassic-rage.com
// ============================================================================
class jrScoreReplicationInfo extends jrInfo
    dependson(jrHighScore);


var jrHighScore.SPackedScore HighScore;


replication
{
    reliable if( bNetInitial && Role == ROLE_Authority )
        HighScore;
}

DefaultProperties
{
    bAlwaysRelevant     = True
    RemoteRole          = ROLE_SimulatedProxy

}
