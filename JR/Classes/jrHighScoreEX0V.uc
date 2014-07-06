// ============================================================================
//  jrHighScoreV0EX.uc ::
// ============================================================================
//  Copyright 2006 Jurassic Rage team. All Rights Reserved.
//  http://www.jurassic-rage.com
// ============================================================================
class jrHighScoreEX0V extends jrHighScoreEX;

const MAX_DIFFICULTY = 7;
const MAX_SCORES = 10;
const PACKEDSCORE_MARGIN = 4;



struct SKeyValuePair
{
    var() string Key;
    var() string Value;
};


struct SPlayerScore
{
    // PRI
    var() float Score;
    var() float Deaths;
    var() string HasFlag;
    var() int NumLives;
    var() string PlayerName;
    var() string CharacterName;
    var() int Team;
    var() bool bOnlySpectator;
    var() bool bOutOfLives;
    var() bool bBot;
    var() float StartTime;
    var() int GoalsScored;
    var() int Kills;
    var() bool bFirstBlood;

    // EX
    var() int DinoKills;
    var() int BloodSamples;
    var() float DamageOut;
    var() float DamageIn;

    // Reserved
    var() array<SKeyValuePair> Data;
};


struct SGameScore
{
    // TeamInfo
    var() float TeamScore;
    var() int TeamSize;

    // GRI
    var() int MatchID;

    // EX
    var() int SpawnedDinos;
    var() int SpawnedSamples;
    var() int Cheats;

    // GameInfo
    var() float ElapsedTime;
    var() float RemainingTime;
    var() float GoalScore;
    var() int MaxLives;
    var() float TimeLimit;
    var() bool bWeaponStay;
    var() float GameDifficulty;
    var() float GameSpeed;
    var() int MaxSpectators;
    var() int NumSpectators;
    var() int MaxPlayers;
    var() int NumPlayers;
    var() int NumBots;
    var() int BotMode;
    var() int MinPlayers;
    var() float BotRatio;
    var() bool bPlayersVsBots;
    var() bool bForceRespawn;
    var() bool bAdjustSkill;
    var() bool bAllowTrans;
    var() int LateEntryLives;
    var() float AdjustedDifficulty;
    var() int PlayerKills;
    var() int PlayerDeaths;
    var() bool bBalanceTeams;
    var() bool bPlayersBalanceTeams;
    var() bool bScoreTeamKills;
    var() bool bSpawnInTeamArea;
    var() bool bScoreVictimsTarget;
    var() float FriendlyFireScale;
    var() bool bTeamScoreRounds;

    // Demo
    var() string DemoName;

    // Players
    var() array<SPlayerScore> Players;

    // Reserved
    var() array<SKeyValuePair> Data;
};






struct SHighScores
{
    var() array<SGameScore> Items;
    var() array<int> ByTimeScore;
    var() array<int> ByTime;
};

var() array<SHighScores> HighScore;

var() const float PointsPerDino;
var() const float PointsPerSample;
var() const float PointsLossTime;




function Initialize( GameInfo Game )
{

    HighScore.Length = MAX_DIFFICULTY;
//    for( i=0; i!=HighScore.Length; ++i )
//    {
//        HighScore[i].Items.Length = MAX_SCORES;
//        InitIndexTable( HighScore[i].ByScore );
//        InitIndexTable( HighScore[i].ByTime );
//        InitIndexTable( HighScore[i].ByTimeMinusScore );
//    }
}

function SaveScore( GameInfo Game )
{
    local jrGameEX G;
    local int skill;
    local SHighScores HS;
    local SGameScore GS;
    local TeamInfo TI;
    local jrGRIEX GRI;
    local int i,j;
    local jrPRIEX PRI;
    local SPlayerScore PS;
    local jrScoreReplicationInfo HSI;
    local int TimeScoreIndex;

    G = jrGameEX(Game);
    if( G == None )
        return;

    skill = GetSkill(G);
    HS = HighScore[skill];

    GRI = jrGRIEX(G.GameReplicationInfo);
    if( GRI == None )
        return;

    TI = TeamInfo(GRI.Winner);
    if( TI == None )
        return;


    // - Get score data -------------------------------------------------------

    GS.TeamScore                = TI.Score;
    GS.TeamSize                 = TI.Size;


    GS.MatchID                  = GRI.MatchID;

    GS.SpawnedDinos             = G.SpawnedDinos;
    GS.SpawnedSamples           = G.SpawnedSamples;
    GS.Cheats                   = int(G.bCheatsUsed);

    GS.ElapsedTime              = G.ElapsedTime;
    GS.RemainingTime            = G.RemainingTime;
    GS.GoalScore                = G.GoalScore;
    GS.MaxLives                 = G.MaxLives;
    GS.TimeLimit                = G.TimeLimit;
    GS.bWeaponStay              = G.bWeaponStay;
    GS.GameDifficulty           = G.GameDifficulty;
    GS.GameSpeed                = G.GameSpeed;
    GS.MaxSpectators            = G.MaxSpectators;
    GS.NumSpectators            = G.NumSpectators;
    GS.MaxPlayers               = G.MaxPlayers;
    GS.NumPlayers               = G.NumPlayers;
    GS.NumBots                  = G.NumBots;
    GS.BotMode                  = G.BotMode;
    GS.MinPlayers               = G.MinPlayers;
    GS.BotRatio                 = G.BotRatio;
    GS.bPlayersVsBots           = G.bPlayersVsBots;
    GS.bForceRespawn            = G.bForceRespawn;
    GS.bAdjustSkill             = G.bAdjustSkill;
    GS.bAllowTrans              = G.bAllowTrans;
    GS.LateEntryLives           = G.LateEntryLives;
    GS.AdjustedDifficulty       = G.AdjustedDifficulty;
    GS.PlayerKills              = G.PlayerKills;
    GS.PlayerDeaths             = G.PlayerDeaths;
    GS.bBalanceTeams            = G.bBalanceTeams;
    GS.bPlayersBalanceTeams     = G.bPlayersBalanceTeams;
    GS.bScoreTeamKills          = G.bScoreTeamKills;
    GS.bSpawnInTeamArea         = G.bSpawnInTeamArea;
    GS.bScoreVictimsTarget      = G.bScoreVictimsTarget;
    GS.FriendlyFireScale        = G.FriendlyFireScale;
    GS.bTeamScoreRounds         = G.bTeamScoreRounds;


    for( i=0; i!=GRI.PRIArray.Length; ++i )
    {
        PRI = jrPRIEX(GRI.PRIArray[i]);
        if( PRI != None )
        {
            PS.Score                = PRI.Score;
            PS.Deaths               = PRI.Deaths;
            PS.HasFlag              = string(PRI.HasFlag);
            PS.NumLives             = PRI.NumLives;
            PS.PlayerName           = PRI.PlayerName;
            PS.CharacterName        = PRI.CharacterName;
            PS.bOnlySpectator       = PRI.bOnlySpectator;
            PS.bOutOfLives          = PRI.bOutOfLives;
            PS.bBot                 = PRI.bBot;
            PS.StartTime            = PRI.StartTime;
            PS.GoalsScored          = PRI.GoalsScored;
            PS.Kills                = PRI.Kills;
            PS.bFirstBlood          = PRI.bFirstBlood;

            if( PRI.Team != None )
                    PS.Team = PRI.Team.TeamIndex;
            else    PS.Team = 255;

            PS.DinoKills            = PRI.DinoKills;
            PS.BloodSamples         = PRI.BloodSamples;
            PS.DamageOut            = PRI.DamageOut;
            PS.DamageIn             = PRI.DamageIn;

            // Add sorted by score
            for( j=0; j!=GS.Players.Length; ++j )
                if( GS.Players[j].Score < PS.Score )
                    break;
            GS.Players.Insert(j,1);
            GS.Players[j] = PS;
        }
    }




    // - Add new score --------------------------------------------------------

    // Add score
    HS.Items[HS.Items.Length] = GS;

    // TimeScore table
    for( i=0; i!=HS.ByTimeScore.Length; ++i )
        if( BetterTimeScore( GS, HS.Items[HS.ByTimeScore[i]] ) )
            break;
    TimeScoreIndex = i;
    HS.ByTimeScore.Insert(TimeScoreIndex,1);
    HS.ByTimeScore[TimeScoreIndex] = HS.Items.Length-1;



    // - Update packed score --------------------------------------------------

    HSI = GRI.Spawn(class'JR.jrScoreReplicationInfo');
    if( HSI != None )
    {
        HSI.HighScore = GetPackedScore(HS,TimeScoreIndex);
        GRI.HighScore = HSI;
    }


    // - Update structs -------------------------------------------------------

    HighScore[skill] = HS;
}


final function SPackedScore GetPackedScore( SHighScores HS, int index )
{
    local int i, j, begin, end;
    local SPackedScore PS;
    local SGameScore GS;

    end = Min( HS.ByTimeScore.Length, index + PACKEDSCORE_MARGIN + 1 );
    begin = Max( 0, end - PACKEDSCORE_MAX );

    PS.First = begin;
    PS.Index = index;

    for( i=begin; i!=end; ++i )
    {
        GS = HS.Items[HS.ByTimeScore[i]];
        PS.Items[j].Score = GetTimeScore(GS.ElapsedTime, GS.TeamScore);
        PS.Items[j].Player = GetBestPlayer(GS);
        //Log( "PACK:" @j @PS.Items[j].Score @PS.Items[j].Player, name );
        ++j;
    }

    return PS;
}

final function string GetBestPlayer( SGameScore GS )
{
    local int i;
    local float f, Best;
    local string S;

    for( i=0; i!=GS.Players.Length; ++i )
    {
        f = GS.Players[i].Score;
        if( S == "" || f > Best )
        {
            Best = f;
            S = GS.Players[i].PlayerName;
        }
    }
    return S;
}



final function int GetSkill( GameInfo G )
{
    return Clamp(G.GameDifficulty,0,MAX_DIFFICULTY);
}

static function int GetTimeScore( int Time, int Score )
{
    return Score - (Time/default.PointsLossTime);
}

static final function bool BetterTimeScore( SGameScore A, SGameScore B )
{
    local int sa,sb;

    sa = GetTimeScore(A.ElapsedTime,A.TeamScore);
    sb = GetTimeScore(B.ElapsedTime,B.TeamScore);

    if( sa > sb )
    {
        return True;
    }
    else if( sa == sb )
    {
        return A.ElapsedTime <= B.ElapsedTime;
    }

    return false;
}

final function InitIndexTable( int size, out array<int> table )
{
    local int i;
    table.Length = size;
    for( i=0; i!=size; ++i )
        table[i] = -1;
}

DefaultProperties
{
    PointsPerDino=3
    PointsPerSample=6
    PointsLossTime=6
}
