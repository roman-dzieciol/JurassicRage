// ============================================================================
//  jrMapListManager.uc ::
// ============================================================================
//  Copyright 2006 Jurassic Rage team. All Rights Reserved.
//  http://www.jurassic-rage.com
// ============================================================================
class jrMapListManager extends MaplistManager;

// returns whether Maplist class was loaded successfully
protected function CreateDefaultList(int i)
{
    local string ListName;
    local array<string> Arr;

    if ( !ValidCacheGameIndex(i) )
        return;

    ListName = DefaultListName @ CachedGames[i].GameAcronym;
    if ( GetDefaultMaps(OverrideMaplist(CachedGames[i].MaplistClassName), Arr)/* && Arr.Length > 0*/ )
        AddList(CachedGames[i].ClassName, ListName, Arr);
}

function bool ApplyMapList(int GameIndex, int RecordIndex)
{
    local class<MapList> ListClass;
    local int i;

    if (ValidRecordIndex(GameIndex, RecordIndex))
    {
        SetActiveList(GameIndex, RecordIndex);
        SaveGame(GameIndex);
        i = GetCacheGameIndex(Groups[GameIndex].GameType);
        if (i == -1)
        {
            Warn("Error applying maplist:"@Groups[GameIndex].GameType);
            return false;
        }

        ListClass = class<MapList>(DynamicLoadObject(OverrideMaplist(CachedGames[i].MapListClassName),Class'Class'));
        if ( ListClass == None )
        {
            log("Invalid maplist class:"@OverrideMaplist(CachedGames[i].MaplistClassName)@"for gametype"@Cachedgames[i].ClassName);
            return false;
        }

        ListClass.static.SetMaplist( GetActiveMap(GameIndex,RecordIndex), GetMaplist(GameIndex,RecordIndex) );
        return true;
    }
    else log("Invalid maplist index");

    return false;
}

simulated static final function string OverrideMaplist(string S)
{
    if( class'LevelInfo'.static.IsDemoBuild() && Right(S,4) != "Demo" )
        S $= "Demo";
    return S;
}

DefaultProperties
{

}
