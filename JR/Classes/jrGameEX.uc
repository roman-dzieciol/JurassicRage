// ============================================================================
//  jrGameEX.uc ::
// ============================================================================
//  Copyright 2006 Jurassic Rage team. All Rights Reserved.
//  http://www.jurassic-rage.com
// ============================================================================
class jrGameEX extends JRGameInfo;

var() config bool bSurvival;

var   class<jrMonster> MonsterClass;
var   byte DinoCountMin;
var   byte DinoCountMax;

var   int SpawnedDinos;
var   int SpawnedSamples;
var   bool bCheatsUsed;


var   array<Actor> AllDinoSpots;
var   array<Actor> DinoSpots;
var   array<Actor> PlayerSpots;

var   class<jrMonster> LastKilledMonsterClass;


const EXPROPNUM = 2;
var localized string EXPropText[EXPROPNUM];
var localized string EXDescText[EXPROPNUM];

const HighScoreClass = class'jrHighScoreEX0V';

var(LoadingHints) private localized array<string> EXHints;
/* TODO

 - auto demo recording
 - high scores menu page

*/



// ============================================================================
//  Lifespan
// ============================================================================

event InitGame(string Options, out string Error)
{
    local NavigationPoint N;
    local int i,j;
    local vector v;
    local actor a;
    local string InOpt;

    Log( "InitGame" @Options );

    // Find interesting navpoints
    for( N=Level.NavigationPointList; N!=None; N=N.NextNavigationPoint )
    {
        if( PathNode(N) != None )
        {
            if( !N.bFlyingPreferred && !N.bNotBased )
                AllDinoSpots[AllDinoSpots.Length] = N;
        }
        else if( InventorySpot(N) != None )
        {
            AllDinoSpots[AllDinoSpots.Length] = N;
        }
        else if( PlayerStart(N) != None )
        {
            PlayerSpots[PlayerSpots.Length] = N;
        }
    }

    // Filter dino spawn points
    for( i=0; i!=AllDinoSpots.Length; ++i )
    {
        a = AllDinoSpots[i];
        v = a.Location;

        for( j=0; j!=PlayerSpots.Length; ++j )
        {
            // eliminate visible spots near playerstarts
            if( VSize(PlayerSpots[j].Location-v) < 3100
            &&  FastTrace(PlayerSpots[j].Location,v) )
            {
                a = None;
                break;
            }
        }

        if( a != None )
            DinoSpots[DinoSpots.Length] = a;
    }


    Super.InitGame(Options, Error);


    GoalScore = 0;
    SpawnProtectionTime = 3.0;
    bAllowTrans = False;

    InOpt = ParseOption( Options, "bSurvival");
    if( InOpt != "" )
    {
        bSurvival = bool(InOpt);
    }

    if( bSurvival )
    {
        MaxLives = 1;
        bForceRespawn = True;
    }
    else
    {
        MaxLives = 0;
        bForceRespawn = False;
    }

    TimeLimit = Max(TimeLimit,5);

}

event PreBeginPlay()
{
    SpawnMonsters();

    RemainingTime = 60 * Max( 1, Round((TimeLimit*SpawnedDinos)/60) );

    Super.PreBeginPlay();
}

function InitGameReplicationInfo()
{
    Super.InitGameReplicationInfo();
    GameReplicationInfo.bNoTeamSkins = true;
    GameReplicationInfo.bForceNoPlayerLights = true;
    GameReplicationInfo.bNoTeamChanges = true;
}

function StartMatch()
{
    Super.StartMatch();
}

function bool JustStarted( float T )
{
    return false;
}

function CheckReady()
{
}

// ============================================================================
//  Winning conditions
// ============================================================================

function CheckScore( PlayerReplicationInfo Scorer )
{
    if( CheckMaxLives(Scorer) )
        return;

    if( GameRulesModifiers != None && GameRulesModifiers.CheckScore(Scorer) )
        return;
}

function bool CheckMaxLives( PlayerReplicationInfo Scorer )
{
    local Controller C;

    if( MaxLives > 0 )
    {
        for( C=Level.ControllerList; C!=None; C=C.NextController )
        {
            if( C.bIsPlayer
            &&  C.PlayerReplicationInfo != None
            && !C.PlayerReplicationInfo.bOutOfLives
            && !C.PlayerReplicationInfo.bOnlySpectator )
                return false;
        }

        EndGame(Scorer,"LastMan");
        return true;
    }
    return false;
}

function bool CheckDinoCount( PlayerReplicationInfo Scorer )
{
    local Controller C;

    if( SpawnedDinos <= 0 )
        return false;

    for( C=Level.ControllerList; C!=None; C=C.NextController )
        if( jrMonsterController(C) != None
        &&  C.Pawn != None
        &&  C.Pawn.Health > 0 )
            return false;

    EndGame(Scorer,"LastDino");
    return true;
}

function EndGame( PlayerReplicationInfo Winner, string Reason )
{
    if( Reason ~= "LastDino"
    ||  Reason ~= "LastMan"
    ||  Reason ~= "TimeLimit"
    ||  Reason ~= "triggered" )
    {
        Super(GameInfo).EndGame(Winner,Reason);
        if( bGameEnded )
        {
            if( Reason == "LastDino" )
                ScoreSave();

            GotoState('MatchOver');
        }
    }
}

function bool CheckEndGame( PlayerReplicationInfo Winner, string Reason )
{
    local Controller C;

    if( GameRulesModifiers != None && !GameRulesModifiers.CheckEndGame(Winner, Reason) )
        return false;

    if( Reason ~= "LastDino" || DinosDead() )
    {
        // if all dinos are dead, victory
        GameReplicationInfo.Winner = Teams[0];
    }
    else if( Reason ~= "LastMan" )
    {
        // If all players are dead, play again
        bAlreadyChanged = True;
    }
    else if( Reason ~= "TimeLimit" )
    {
        // If some dinos escaped, play again
        bAlreadyChanged = True;
    }

    if( Winner == None )
    {
        for( C=Level.ControllerList; C!=None; C=C.NextController )
            if( C.PlayerReplicationInfo != None
            &&  C.PlayerReplicationInfo.Team == GameReplicationInfo.Winner
            && (Winner == None || C.PlayerReplicationInfo.Score > Winner.Score) )
            {
                Winner = C.PlayerReplicationInfo;
            }
    }

    EndTime = Level.TimeSeconds + EndTimeDelay;
    SetEndGameFocus(Winner);
    return true;
}

function SetEndGameFocus( PlayerReplicationInfo Winner )
{
    local Controller C, NextController;
    local PlayerController PC;

    if( Winner != None )
        EndGameFocus = Controller(Winner.Owner).Pawn;

    if( EndGameFocus != None )
        EndGameFocus.bAlwaysRelevant = true;

    for( C=Level.ControllerList; C!=None; C=NextController )
    {
        NextController = C.NextController;
        PC = PlayerController(C);
        if( PC != None )
        {
            if(!PC.PlayerReplicationInfo.bOnlySpectator )
                PlayWinMessage(PC, (PC.PlayerReplicationInfo.Team == GameReplicationInfo.Winner));

            PC.ClientSetBehindView(true);
            if( EndGameFocus != None )
            {
                PC.ClientSetViewTarget(EndGameFocus);
                PC.SetViewTarget(EndGameFocus);
            }
            PC.ClientGameEnded();
            if( CurrentGameProfile != None )
                CurrentGameProfile.bWonMatch = (PC.PlayerReplicationInfo.Team == GameReplicationInfo.Winner);
        }
        C.GameHasEnded();
    }
}

// ============================================================================
//  Players
// ============================================================================

function class<Pawn> GetDefaultPlayerClass(Controller C)
{
    if( C.GetTeamNum() == 0 )
        return class'JR.jrSecurity';
    else if( C.GetTeamNum() == 1 )
        return class'JR.jrCell';
    else
        return None;
}

function ScoreKill(Controller Killer, Controller Other)
{
    local jrPRIEX OtherPRI, KillerPRI;
    local float KillScore;

    OtherPRI = jrPRIEX(Other.PlayerReplicationInfo);
    KillerPRI = jrPRIEX(Killer.PlayerReplicationInfo);

    // Player died
    if( OtherPRI != None )
    {
        OtherPRI.Score -= 5;
        OtherPRI.NetUpdateTime = Level.TimeSeconds - 1;
        //OtherPRI.Team.Score -= 5;
        //OtherPRI.Team.NetUpdateTime = Level.TimeSeconds - 1;
        OtherPRI.NumLives++;

        if( MaxLives > 0 && OtherPRI.NumLives >= MaxLives )
        {
            OtherPRI.bOutOfLives = true;
            BroadcastLocalizedMessage(class'jrMessageEX', 1, OtherPRI);
        }
        CheckScore(None);
    }

    if( GameRulesModifiers != None )
        GameRulesModifiers.ScoreKill(Killer, Other);

    if( jrMonsterController(Killer) != None )
        return;

    if( Killer == Other || Killer == None )
    {
        if( OtherPRI != None )
        {
            OtherPRI.Score -= 1;
            OtherPRI.NetUpdateTime = Level.TimeSeconds - 1;
            //Killer.PlayerReplicationInfo.Team.Score -= 1;
            //Killer.PlayerReplicationInfo.Team.NetUpdateTime = Level.TimeSeconds - 1;
            ScoreEvent(OtherPRI,-1,"self_frag");
        }
    }

    if( Killer == None || !Killer.bIsPlayer || Killer == Other )
        return;

    if( Other.bIsPlayer )
    {
        KillerPRI.Score -= 10;
        KillerPRI.NetUpdateTime = Level.TimeSeconds - 1;
        //KillerPRI.Team.Score -= 10;
        //KillerPRI.Team.NetUpdateTime = Level.TimeSeconds - 1;
        ScoreEvent(KillerPRI, -10, "team_frag");
        return;
    }

    if( LastKilledMonsterClass == None )
    {
        KillScore = 1;
    }
    else
    {
        KillScore = HighScoreClass.default.PointsPerDino;
        KillerPRI.DinoKills++;
    }

    KillerPRI.Kills++;
    KillerPRI.Score += KillScore;
    KillerPRI.Team.Score += KillScore;
    KillerPRI.Team.NetUpdateTime = Level.TimeSeconds - 1;
    Killer.AwardAdrenaline(KillScore);
    KillerPRI.NetUpdateTime = Level.TimeSeconds - 1;
    TeamScoreEvent(KillerPRI.Team.TeamIndex, KillScore, "tdm_frag");

    UpdateAliveCount(KillerPRI,false,true);
}

function Killed( Controller Killer, Controller Killed, Pawn KilledPawn, class<DamageType> damageType )
{
    local jrPRIEX PRI;

    if( jrMonsterController(Killed) != None && Killer != None && Killer.bIsPlayer )
    {
        PRI = jrPRIEX(Killer.PlayerReplicationInfo);
        if( PRI != None )
        {
            PRI.AddWeaponKill(DamageType);
            PRI.DinoKills++;
        }

        if( UnrealPlayer(Killer) != None )
            UnrealPlayer(Killer).LogMultiKills(ADR_MajorKill, True);

        BroadcastLocalized(self, DeathMessageClass, 2, Killer.PlayerReplicationInfo, None, None);

        DamageType.static.ScoreKill(Killer, Killed);

        if( !bFirstBlood )
        {
            bFirstBlood = True;
            Killer.AwardAdrenaline(ADR_MajorKill);
            if( TeamPlayerReplicationInfo(Killer.PlayerReplicationInfo) != None )
                TeamPlayerReplicationInfo(Killer.PlayerReplicationInfo).bFirstBlood = true;
            BroadcastLocalizedMessage( class'FirstBloodMessage', 0, Killer.PlayerReplicationInfo );
            SpecialEvent(Killer.PlayerReplicationInfo,"first_blood");
        }

        Killer.AwardAdrenaline(ADR_Kill);
        if( Killer.Pawn != None )
        {
            Killer.Pawn.IncrementSpree();
            if( Killer.Pawn.GetSpree() > 4 )
                NotifySpree(Killer, Killer.Pawn.GetSpree());
        }
    }

    LastKilledMonsterClass = class<jrMonster>(KilledPawn.class);

    Super.Killed(Killer,Killed,KilledPawn,DamageType);
}



function NotifyKilled(Controller Killer, Controller Killed, Pawn KilledPawn)
{
    local Controller C;

    for ( C=Level.ControllerList; C!=None; C=C.nextController )
        if ( jrMonsterController(C) != None )
            C.NotifyKilled(Killer, Killed, KilledPawn);

    Super.NotifyKilled(Killer,Killed,KilledPawn);
}

function RestartPlayer( Controller C )
{
    if( C.PlayerReplicationInfo.bOutOfLives )
        return;

    C.PawnClass = GetDefaultPlayerClass(C);

    Super(GameInfo).RestartPlayer(C);
}

function bool CanSpectate( PlayerController Viewer, bool bOnlySpectator, actor ViewTarget )
{
    if( ViewTarget == None )
        return false;

    if( Controller(ViewTarget) != None )
    {
        if( Controller(ViewTarget).Pawn == None )
            return false;

        return( ViewTarget != Viewer
            &&  Controller(ViewTarget).PlayerReplicationInfo != None
            &&  Controller(ViewTarget).PlayerReplicationInfo.Team == Viewer.PlayerReplicationInfo.Team );
    }

    return( Pawn(ViewTarget) != None
        &&  Pawn(ViewTarget).IsPlayerPawn()
        &&  Pawn(ViewTarget).PlayerReplicationInfo.Team == Viewer.PlayerReplicationInfo.Team );
}

event PlayerController Login
(
    string Portal,
    string Options,
    out string Error
)
{
    local PlayerController NewPlayer;
    local Controller C;

    NewPlayer = Super.Login(Portal,Options,Error);

    if( MaxLives > 0 )
    {
        for( C=Level.ControllerList; C!=None; C=C.NextController )
            if( C.PlayerReplicationInfo != None
            &&  C.PlayerReplicationInfo.bOutOfLives
            && !C.PlayerReplicationInfo.bOnlySpectator )
            {
                NewPlayer.PlayerReplicationInfo.bOutOfLives = true;
                NewPlayer.PlayerReplicationInfo.NumLives = MaxLives;
                NewPlayer.GotoState('Spectating');
            }
    }

    return NewPlayer;
}



// ============================================================================
//  Dinos
// ============================================================================

function float GetDinoRatio()
{
    if( SpawnedDinos > 0 )
        return float(jrGRIEX(GameReplicationInfo).DinosCount) / SpawnedDinos;
    return 1;
}

function bool DinosDead()
{
    local Controller C;

    for( C=Level.ControllerList; C!=None; C=C.NextController )
        if( jrMonsterController(C) != None
        &&  C.Pawn != None
        &&  C.Pawn.Health > 0 )
            return false;

    return true;
}

function int GetDinosCount()
{
    local Controller C;
    local int i;

    for( C=Level.ControllerList; C!=None; C=C.NextController )
        if( jrMonsterController(C) != None
        &&  C.Pawn != None
        &&  C.Pawn.Health > 0 )
            ++i;

    return i;
}

function jrMonster SpawnMonster( Actor StartSpot )
{
    local vector loc;
    local jrMonster M;

    loc = StartSpot.Location;
    //loc += (MonsterClass.Default.CollisionHeight - StartSpot.CollisionHeight) * vect(0,0,1);
    M = Spawn(MonsterClass,,,loc,StartSpot.Rotation);

    // if there's no LOS to spawn loc, it was prolly spawned in world geometry, destroy!
    if( M != None && !FastTrace(M.Location,loc) )
    {
        Warn( "Suspicious StartSpot:" @StartSpot @loc @M.Location );
        M.Destroy();
        M = None;
    }

    return M;
}

function SpawnMonsters()
{
    local jrMonster M;
    local int i,j, limit;
    local array<Actor> Spots;

    limit += DinoCountMin;
    limit += Level.IdealPlayerCountMin;
    limit += Level.IdealPlayerCountMax;
    limit += PlayerSpots.Length;
    limit = Min( limit, DinoCountMax );

    Spots = DinoSpots;

    for( i=0; i!=limit; ++i )
    {
        j = Rand(Spots.Length);
        M = SpawnMonster(Spots[j]);

        // if spawn failed, remove spot and try again
        if( M == None )
        {
            Spots.Remove(j,1);
            if( Spots.Length > 0 )
            {
                --i;
                continue;
            }
            break;
        }
        else
        {
            ++SpawnedDinos;
        }
    }

}


// ============================================================================
//  Bots
// ============================================================================

function OverrideInitialBots()
{
    if( bAutoNumBots )
    {
        InitialBots = Max(GetMinPlayers()-1,0);
    }
    else
    {
        InitialBots = InitialBots;
    }
}

function Bot SpawnBot(optional string botName)
{
    local Bot NewBot;
    local RosterEntry Chosen;
    local UnrealTeamInfo BotTeam;

    BotTeam = GetBotTeam();
    Chosen = BotTeam.ChooseBotClass(botName);

    if( Chosen.PawnClass == None )
        Chosen.Init();

    NewBot = Spawn(class'jrBot');
    if( NewBot != None )
    {
        //AdjustedDifficulty = AdjustedDifficulty + 2;
        InitializeBot(NewBot,BotTeam,Chosen);
        //AdjustedDifficulty = AdjustedDifficulty - 2;
        NewBot.bInitLifeMessage = true;
    }
    return NewBot;
}

static function AdjustPlayerCount( out int pmin, out int pmax )
{
    pmin = Clamp(pmin*0.5,1,8);
    pmax = Clamp(pmax*0.5,1,16);
}


function int GetMinPlayers()
{
    local int pmin, pmax;

    if( CurrentGameProfile == None )
    {
        pmin = Level.IdealPlayerCountMin;
        pmax = Level.IdealPlayerCountMax;
        AdjustPlayerCount(pmin,pmax);
        return Min(8,(pmax + pmin)/2);
    }

    return Level.SinglePlayerTeamSize*2;
}

// ============================================================================
//  Inventory
// ============================================================================

function bool PickupQuery( Pawn Other, Pickup item )
{
    local float p;
    local JRPRIEX PRI;

    if( !Super.PickupQuery(Other,item) )
        return false;

    // points for getting a virus sample
    if( jrBloodSamplePickup(item) != None && Other != None )
    {
        PRI = JRPRIEX(Other.PlayerReplicationInfo);

        p = HighScoreClass.default.PointsPerSample;
        PRI.Score += p;
        PRI.NetUpdateTime = Level.TimeSeconds - 1;
        PRI.Team.Score += p;
        PRI.Team.NetUpdateTime = Level.TimeSeconds - 1;
        ScoreEvent(PRI,p,"bloodsample");
        PRI.BloodSamples++;
        return true;
    }

    return true;
}


// ============================================================================
//  Teams
// ============================================================================

function byte PickTeam( byte num, Controller C )
{
    return 0;
}

function UnrealTeamInfo GetBotTeam( optional int TeamBots )
{
    return Teams[0];
}


// ============================================================================
//  Config
// ============================================================================

static event bool AcceptPlayInfoProperty( string PropertyName )
{
    if( PropertyName == "bBalanceTeams"
    ||  PropertyName == "bPlayersBalanceTeams"
    ||  PropertyName == "MaxLives"
    ||  PropertyName == "GoalScore"
    ||  PropertyName == "bAllowTrans"
    ||  PropertyName == "bForceRespawn"
    ||  PropertyName == "SpawnProtectionTime" )
        return false;

    return Super.AcceptPlayInfoProperty(PropertyName);
}


function GetServerDetails( out ServerResponseLine ServerState )
{
    Super(UnrealMPGameInfo).GetServerDetails(ServerState);

    AddServerDetail( ServerState, "Evolution", class'jrBuild'.default.Build );
    AddServerDetail( ServerState, "TimeLimit", TimeLimit );
    AddServerDetail( ServerState, "FriendlyFireScale", int(FriendlyFireScale*100) $ "%" );
    if( bSurvival )
        AddServerDetail( ServerState, "Survival", bSurvival );
}

static function FillPlayInfo(PlayInfo PI)
{
    Super.FillPlayInfo(PI);

    PI.AddSetting(default.GameGroup,   "bSurvival",         GetDisplayText("bSurvival"),          1, 0, "Check",             ,            ,    ,False);
}

static event string GetDisplayText( string PropName )
{
    switch( PropName )
    {
        case "bSurvival":     return default.EXPropText[0];
    }

    return Super.GetDisplayText( PropName );
}

static event string GetDescriptionText(string PropName)
{
    switch( PropName )
    {
        case "bSurvival":     return default.EXDescText[0];
    }

    return Super.GetDescriptionText(PropName);
}


// ============================================================================
//  Messages
// ============================================================================

function PlayEndOfMatchMessage()
{
    local Controller C;

    if( GameReplicationInfo.Winner == Teams[0] )
    {
        for( C=Level.ControllerList; C!=None; C=C.NextController )
            if( C.IsA('PlayerController') )
                PlayerController(C).PlayStatusAnnouncement(AltEndGameSoundName[0],1,true);
    }
    else
    {
        for( C=Level.ControllerList; C!=None; C=C.NextController )
            if( C.IsA('PlayerController') )
                PlayerController(C).PlayStatusAnnouncement(AltEndGameSoundName[1],1,true);
    }
}

function UpdateAliveCount( PlayerReplicationInfo Killer, bool bCheckPlayers, bool bCheckDinos )
{
    local Controller C;
    local int d,p;

    for( C=Level.ControllerList; C!=None; C=C.NextController )
    {
        if( jrMonsterController(C) != None
        &&  C.Pawn != None
        &&  C.Pawn.Health > 0 )
        {
            ++d;
        }
        else if( C.bIsPlayer
             &&  C.PlayerReplicationInfo != None
             && !C.PlayerReplicationInfo.bOutOfLives
             && !C.PlayerReplicationInfo.bOnlySpectator )
        {
            ++p;
        }
    }

    jrGRIEX(GameReplicationInfo).DinosCount = d;
    jrGRIEX(GameReplicationInfo).PlayersCount = p;
    jrGRIEX(GameReplicationInfo).NetUpdateTime = Level.TimeSeconds - 1;

    if( bCheckPlayers && p == 0 )
        EndGame(Killer,"LastMan");

    if( bCheckDinos && d == 0 )
        EndGame(Killer,"LastDino");
}



// ============================================================================
//  Precaching
// ============================================================================

static function PrecacheGameTextures(LevelInfo myLevel)
{
    class'xTeamGame'.static.PrecacheGameTextures(myLevel);

//    myLevel.AddPrecacheMaterial(Material'SkaarjPackSkins.jBrute2');
//    myLevel.AddPrecacheMaterial(Material'SkaarjPackSkins.jBrute1');
}

static function PrecacheGameAnnouncements(AnnouncerVoice V, bool bRewardSounds)
{
    Super.PrecacheGameAnnouncements(V,bRewardSounds);
//    if ( bRewardSounds )
//    {
//        V.PrecacheSound('SKAARJtermination');
//        V.PrecacheSound('SKAARJslaughter');
//        V.PrecacheSound('SKAARJextermination');
//    }
//    else
//        V.PrecacheSound('Next_wave_in');
}


// ============================================================================
//  High Score
// ============================================================================

function ScoreSave()
{
    local string PackageName, ObjectName;
    local jrHighScore HS;

    PackageName = "JRHS_" $class.name;
    ObjectName = GetURLMap(False);

    HS = LoadDataObject(HighScoreClass,ObjectName,PackageName);
    if( HS == None )
    {
        Log("Creating HighScore:" @PackageName $"." $ObjectName , name);
        HS = CreateDataObject(HighScoreClass, ObjectName, PackageName);
        if( HS != None )
        {
            HS.Initialize(self);
        }
        else
        {
            Log("Missing HighScore:" @PackageName $"." $ObjectName , name);
            return;
        }
    }

    HS.SaveScore(self);

    SavePackage(PackageName);
}


function ReportCheat( PlayerController P, optional string cheat )
{
    bCheatsUsed = True;
}

function float RatePlayerStart(NavigationPoint N, byte Team, Controller Player)
{
    local PlayerStart P;
    local float Score, NextDist;
    local Controller OtherPlayer;
    local int PlayersChecked;
    local jrMonster M;

    P = PlayerStart(N);
    if( P == None )
        return -10000000;

    if ( bSpawnInTeamArea && (Team != P.TeamNumber) )
        return -9000000;

    P = PlayerStart(N);

    if ( (P == None) || !P.bEnabled || P.PhysicsVolume.bWaterVolume )
        return -10000000;

    //assess candidate
    if ( P.bPrimaryStart )
        Score = 10000000;
    else
        Score = 5000000;

    //if ( (N == LastStartSpot) || (N == LastPlayerStartSpot) )
    //    Score -= 10000.0;
    //else
        Score += 3000 * FRand(); //randomize

    for( OtherPlayer=Level.ControllerList; OtherPlayer!=None; OtherPlayer=OtherPlayer.NextController)
        if ( OtherPlayer.bIsPlayer && (OtherPlayer.Pawn != None) )
        {
            if ( OtherPlayer.Pawn.Region.Zone == N.Region.Zone )
                Score += 1500;
            NextDist = VSize(OtherPlayer.Pawn.Location - N.Location);
            if ( NextDist < OtherPlayer.Pawn.CollisionRadius + OtherPlayer.Pawn.CollisionHeight )
                Score -= 1000000.0;
            else if ( (NextDist < 3000) && FastTrace(N.Location, OtherPlayer.Pawn.Location) )
                Score += (10000.0 - NextDist);
            else if ( NumPlayers + NumBots == 2 )
            {
                Score -= 2 * VSize(OtherPlayer.Pawn.Location - N.Location);
                if ( FastTrace(N.Location, OtherPlayer.Pawn.Location) )
                    Score += 10000;
            }
            ++PlayersChecked;
        }

    if( PlayersChecked == 0 )
    {
        foreach VisibleCollidingActors( class'jrMonster', M, class'jrMonster'.default.SightRadius*1.2, P.Location, True )
        {
            Score -= 3000 + VSize(M.Location - P.Location);
        }
    }

    return FMax(Score, 5);
}



static function array<string> GetAllLoadHints(optional bool bThisClassOnly)
{
    local int i;
    local array<string> Hints;

    if ( !bThisClassOnly || default.EXHints.Length == 0 )
        Hints = Super.GetAllLoadHints();

    for ( i = 0; i < default.EXHints.Length; i++ )
        Hints[Hints.Length] = default.EXHints[i];

    return Hints;
}

// ============================================================================
//  STATES
// ============================================================================

state MatchInProgress
{
    function Timer()
    {
        Super.Timer();

        UpdateAliveCount(None,false,true);
    }
}


State MatchOver
{
    function BeginState()
    {
        Super.BeginState();
    }
}


// ============================================================================
//  DefaultProperties
// ============================================================================
DefaultProperties
{
    EXPropText(0)="Survival Mode"
    EXDescText(0)="Players have only one life."


    MaxLives                        = 0
    InitialBots                     = 0
    GoalScore                       = 0
    DinoCountMin                    = 8
    DinoCountMax                    = 64
    TimeLimit                       = 15

    bSpawnInTeamArea                = False
    bPlayersMustBeReady             = True
    bForceRespawn                   = False
    MonsterClass                    = class'jrDinoEX'

    TeamAIType(0)                   = class'JR.jrTeamEX'
    TeamAIType(1)                   = class'JR.jrTeamEX'
    DeathMessageClass               = class'JR.jrDeathMessageEX'
    GameReplicationInfoClass        = class'JR.jrGRIEX'
    MutatorClass                    = "JR.jrMutatorEX"
    HUDType                         = "JR.jrHUDEX"
    ScoreboardType                  = "JR.jrScoreboardEX"
    ScreenShotName                  = "JRTX_Thumbs.Extermination"
    DefaultPlayerClassName          = "JR.jrSecurity"

    GameName                        = "Extermination"
    Acronym                         = "EX"
    BeaconName                      = "EX"
    MapPrefix                       = ""
    Description                     = "An unknown disease is spreading quickly among dinos. Infected dinos are decimating other species and DinoTech personnel.||The orders are to find and destroy all suspected dinos before it's too late. Whenever possible, blood samples should be collected from dino carcasses.||Observed changes include reckless agresiveness towards other species, improved mental abilities, better agility, greatly reduced pain perception, partial hearing loss, skin discolorations and deformations. Shortly after death massive convulsions, swelling and bursting of skin can be observed."

    SPBotDesc                       = "Specify the number of bots that should join."

    EXHints(0)                      = "If you can't find dinosaurs, listen for the noises they make."
    EXHints(1)                      = "If you find the game too hard, disable survival mode, reduce AI difficulty, increase timelimit and play with teammates."
    EXHints(2)                      = "Intimidate velociraptors by using their own tactics against them."

}
