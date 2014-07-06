// ============================================================================
//  jr2k4Browser_ServerListPageInternet.uc ::
// ============================================================================
//  Copyright 2006 Jurassic Rage team. All Rights Reserved.
//  http://www.jurassic-rage.com
// ============================================================================
class jr2k4Browser_ServerListPageInternet extends UT2k4Browser_ServerListPageInternet;


function Refresh()
{
//    local int i, j;
//    local string TmpString;
//    local array<CustomFilter.AFilterRule> Rules;
//    local MasterServerClient.QueryData QueryItem;

    GameTypeChanged(UT2K4Browser_ServersList(Browser.co_GameType.GetObject()));

    Super(UT2K4Browser_ServerListPageMS).Refresh();

//    if (PlayCount==ShowAt)
//    {
//        Controller.OpenMenu("gui2k4.UT2K4TryAMod",""$PlayCount);
//        PlayCount=ShowAt+1;
//    }
    SaveConfig();

    if( Caps(Browser.CurrentGameType) != "ANY" )
        AddQueryTerm("gametype", GetItemName(Browser.CurrentGameType), QT_Equals);


//    if ( Browser.bStandardServersOnly )
//        AddQueryTerm( "standard", "true", QT_Equals );
//
//    // Add any extra filtering to the query
//    for (i = 0; i < FilterMaster.AllFilters.Length; i++)
//    {
//        if ( FilterMaster.IsActiveAt(i) )
//        {
//            Rules = FilterMaster.GetFilterRules( i );
//            for (j = 0; j < Rules.Length; j++)
//            {
//                QueryItem = Rules[j].FilterItem;
//                if (ValidateQueryItem(Rules[j].FilterType, QueryItem ))
//                {
//                    TmpString = QueryItem.Value;
//                    if (QueryItem.QueryType < 2)
//                        class'CustomFilter'.static.ChopClass(TmpString);
//
//                    AddQueryTerm( QueryItem.Key, TmpString, QueryItem.QueryType );
//                }
//            }
//        }
//    }

    // Only JR servers
    AddQueryTerm( "mutator", "jrTagJR", QT_Equals );

//  log("AddQueryTerm Key:"$Key@"Value:"$Value@"QueryType:"$GetEnum(enum'EQueryType',QueryType));
//    for ( i = 0; i < Browser.Uplink().Query.Length; i++ )
//    {
//        QueryItem = Browser.Uplink().Query[i];
//        Log( "Q: "@QueryItem.Key @QueryItem.Value @QueryItem.QueryType );
//    }

    // Run query
    Browser.Uplink().StartQuery(CTM_Query);
    SetFooterCaption(StartQueryString);
}

DefaultProperties
{

}
