// ============================================================================
//  jrMapVoteMapListConfigPage.uc ::
// ============================================================================
//  Copyright 2006 Jurassic Rage team. All Rights Reserved.
//  http://www.jurassic-rage.com
// ============================================================================
class jrMapVoteMapListConfigPage extends MapVoteMapListConfigPage;

function LoadMapLists()
{
    local int i;

    lb_MapList.List.Clear();
    for(i=0; i<GameTypes.Length; i++)
        lb_MapList.List.Add(GameTypes[i].GameName $ " MapList", none, OverrideMapList(GameTypes[i].MapListClassName));
}

simulated static final function string OverrideMaplist(string S)
{
    return class'jrMapListManager'.static.OverrideMaplist(S);
}

DefaultProperties
{

}
