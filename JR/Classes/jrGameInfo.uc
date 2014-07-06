// ============================================================================
//  jrGameInfo.uc ::
// ============================================================================
//  Copyright 2006 Jurassic Rage team. All Rights Reserved.
//  http://www.jurassic-rage.com
// ============================================================================
class jrGameInfo extends xTeamGame
    abstract
    HideDropDown
    CacheExempt;



function ReportCheat(PlayerController P,optional string cheat);

event InitGame( string Options, out string Error )
{
    if( Level.IsDemoBuild() )
    {
        MapListType = OverrideMaplist(MapListType);
        SaveConfig();
    }

    Super.InitGame(Options,Error);

    // Tags for gametype-less MS queries
    AddMutator("JR.jrTagJR");
}


function InitTeamSymbols()
{
    // override with dummies so team maps dont display them
    if( GameReplicationInfo.TeamSymbols[0] == None )
        GameReplicationInfo.TeamSymbols[0] =  GameReplicationInfo.default.TeamSymbols[0];
    if( GameReplicationInfo.TeamSymbols[1] == None )
        GameReplicationInfo.TeamSymbols[1] = GameReplicationInfo.default.TeamSymbols[1];
    GameReplicationInfo.TeamSymbolNotify();
}

simulated static final function string OverrideMaplist(string S)
{
    return class'jrMapListManager'.static.OverrideMaplist(S);
}

static function AddServerDetail( out ServerResponseLine ServerState, string RuleName, coerce string RuleValue )
{
    if( RuleName == "GameStats" )
        return;
    Super.AddServerDetail(ServerState,RuleName,RuleValue);
}


// ============================================================================
//  Debug
// ============================================================================
final simulated function xLog ( coerce string s )
{
    Log
    (   "[" $Left("00",2-Len(Level.Second)) $Level.Second $":"
            $Left("000",3-Len(Level.Millisecond)) $Level.Millisecond $"]"
    @   "[" $StrShort(GetStateName()) $"]"
    @   s
    ,   name );
}

final static function nLog ( coerce string s )
{
    Log( s, default.name );
}

final static function string StrShort( coerce string s )
{
    local string r,c;
    local int i,n;

    c = Caps(s);
    n = Len(s);

    for( i=0; i!=n; ++i )
        if( Mid(s,i,1) == Mid(c,i,1) )
            r $= Mid(s,i,1);

    return r;
}

final static operator(112) string # ( coerce string A, coerce string B )
{
    return A @"[" $B $"]";
}

final static function name GON( Object O )
{
    if( O != None ) return O.Name;
    else            return 'None';
}

final simulated function string GPT( string S )
{
    return GetPropertyText(S);
}


// ============================================================================
//  DefaultProperties
// ============================================================================
DefaultProperties
{
    MaplistHandlerType              = "JR.jrMapListManager"
    MapListType                     = "JR.jrMapList2K4EX"
    bForceNoPlayerLights            = True
    PlayerControllerClassName       = "JR.jrPlayer"
}
