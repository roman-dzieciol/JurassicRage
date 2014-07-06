// ============================================================================
//  jrHighScore.uc :: DO NOT MODIFY SERIALIZABLES! Add new classes instead.
// ============================================================================
//  Copyright 2006 Jurassic Rage team. All Rights Reserved.
//  http://www.jurassic-rage.com
// ============================================================================
class jrHighScore extends jrObject
    abstract;




// - Replicated Score ---------------------------------------------------------

const PACKEDSCORE_MAX = 10;

struct SPackedScoreItem
{
    var() int Score;
    var() string Player;
};

struct SPackedScore
{
    var() byte First;
    var() byte Index;
    var() SPackedScoreItem Items[PACKEDSCORE_MAX];
};


// - jrHighScore Interface ----------------------------------------------------

function Initialize( GameInfo Game );
function SaveScore( GameInfo Game );


DefaultProperties
{

}
