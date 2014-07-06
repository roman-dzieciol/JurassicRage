// ============================================================================
//  jrHighScoreEX.uc ::
// ============================================================================
//  Copyright 2006 Jurassic Rage team. All Rights Reserved.
//  http://www.jurassic-rage.com
// ============================================================================
class jrHighScoreEX extends jrHighScore
    abstract;

static function int GetTimeScore( int Time, int Score )
{
    return class'jrHighScoreEX0V'.static.GetTimeScore(Time,Score);
}

DefaultProperties
{

}
