// ============================================================================
//  jr2K4Tab_GameTypeBase.uc ::
// ============================================================================
//  Copyright 2006 Jurassic Rage team. All Rights Reserved.
//  http://www.jurassic-rage.com
// ============================================================================
class jr2K4Tab_GameTypeBase extends UT2K4Tab_GameTypeBase;

var localized string jr2K4GameCaption;


function bool HasMaps( CacheManager.GameRecord TestRec )
{
    local array<CacheManager.MapRecord> Records;

    if( TestRec.MapPrefix != "" )
    {
        class'CacheManager'.static.GetMapList(Records, TestRec.MapPrefix);
        return Records.Length > 0;
    }

    return true;
}


function PopulateGameTypes()
{
    local int i;

    class'CacheManager'.static.GetGameTypeList(GameTypes);

    // show gametypes from packages starting with "jr" only
    for( i=0; i<GameTypes.Length; ++i )
    {
        if( Left(GameTypes[i].ClassName,2) ~= "JR" )
        {
            if( HasMaps(GameTypes[i]) )
            {
                AddEpicGameType( GameTypes[i].GameName, OverrideMaplist(GameTypes[i].MapListClassName) );
            }
        }
    }

    li_Games.Insert(0,jr2K4GameCaption,None,"",true,true);
    li_Games.SetIndex(0);
}

simulated static final function string OverrideMaplist(string S)
{
    return class'jrMapListManager'.static.OverrideMaplist(S);
}

DefaultProperties
{
    jr2K4GameCaption="Jurassic Rage"

}
