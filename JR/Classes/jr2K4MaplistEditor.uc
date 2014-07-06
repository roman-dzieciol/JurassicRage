// ============================================================================
//  jr2K4MaplistEditor.uc ::
// ============================================================================
//  Copyright 2006 Jurassic Rage team. All Rights Reserved.
//  http://www.jurassic-rage.com
// ============================================================================
class jr2K4MaplistEditor extends MaplistEditor;

var bool bOnlyShowRecommended;


// Query the CacheManager for the maps that correspond to this gametype, then fill the 'available' list
function ReloadAvailable()
{
    local int i;

    if ( MapHandler.GetAvailableMaps(GameIndex, Maps) )
    {
        li_Avail.bNotify = False;
        li_Avail.Clear();

        for ( i = 0; i < Maps.Length; i++ )
        {
            if ( class'CacheManager'.static.IsDefaultContent(Maps[i].MapName) )
            {
                if ( bOnlyShowCustom )
                    continue;
            }
            else if ( bOnlyShowOfficial )
                continue;

            if( bOnlyShowRecommended && !class'jrRecommendedMaps'.static.IsRecommended(Maps[i].MapName) )
                continue;

            if( class'jrMapFilter'.static.IsIncompatible(Maps[i].MapName) )
                continue;

//            if ( Maps[i].Options.Length > 0 )
//            {
//                // Add the "auto link setup" item
//                li_Avail.AddItem( AutoSelectText @ LinkText, Maps[i].MapName $ "?LinkSetup=Random", Maps[i].MapName );
//
//                // Now add all custom link setups
//                for ( j = 0; j < Maps[i].Options.Length; j++ )
//                    li_Avail.AddItem(Maps[i].Options[j].Value @ LinkText, Maps[i].MapName $ "?LinkSetup=" $ Maps[i].Options[j].Value, Maps[i].MapName );
//            }
//            else
                li_Avail.AddItem( Maps[i].MapName, Maps[i].MapName );

//            if ( CurrentGameType.MapPrefix == "ONS" )
//            {
//                CustomLinkSetups = GetPerObjectNames( Maps[i].MapName, "ONSPowerLinkCustomSetup" );
//                for ( j = 0; j < CustomLinkSetups.Length; j++ )
//                    li_Avail.AddItem( CustomLinkSetups[j] @ LinkText, Maps[i].MapName $ "?LinkSetup=" $ CustomLinkSetups[j], Maps[i].MapName );
//
//                if ( OrigONSMap(Maps[i].MapName) && Controller.bECEEdition )
//                {
//                    li_Avail.AddItem( Maps[i].MapName$BonusVehicles, Maps[i].MapName$"?BonusVehicles=true" );
//
//                    // Now add all custom link setups
//                    for ( j = 0; j < Maps[i].Options.Length; j++ )
//                        li_Avail.AddItem(Maps[i].Options[j].Value @ LinkText, Maps[i].MapName $ "?LinkSetup=" $ Maps[i].Options[j].Value$"?BonusVehicles=true" , Maps[i].MapName$BonusVehicles );
//
//                    CustomLinkSetups = GetPerObjectNames( Maps[i].MapName, "ONSPowerLinkCustomSetup" );
//                    for ( j = 0; j < CustomLinkSetups.Length; j++ )
//                        li_Avail.AddItem( CustomLinkSetups[j] @ LinkText, Maps[i].MapName $ "?LinkSetup=" $ CustomLinkSetups[j]$"?BonusVehicles=true", Maps[i].MapName$BonusVehicles );
//                }
//            }
        }
    }

    if ( li_Avail.bSorted )
        li_Avail.Sort();

    li_Avail.bNotify = True;
}

function CreateNewMaplist( optional bool bCancelled )
{
    local string str, warning;
    local array<string> Ar;

    str = Controller.ActivePage.GetDataString();

    if ( !bCancelled && str != "" )
    {
        // Build an array of strings containing the active maps
        if ( MapHandler.GetDefaultMaps(OverrideMaplist(CurrentGameType.MapListClassName), Ar) && Ar.Length > 0 )
        {
            // Since we are creating a new list, instead of changing this one, reset the old one
            RecordIndex = MapHandler.AddList(CurrentGameType.ClassName, str, Ar);

            // Reload maplist names, set the editbox's text to the new maplist's title
            RefreshMaplistNames(Str);
        }
        else
        {
            warning = Repl(InvalidMaplistClassText, "%name%", str);
            warning = Repl(warning, "%game%", CurrentGameType.ClassName);
            warning = Repl(warning, "%mapclass%", OverrideMaplist(CurrentGameType.MaplistClassName));
            warn( warning );
        }
    }
}


function string GetMapListClass()
{
    return OverrideMaplist(CurrentGameType.MapListClassName);
}

simulated static final function string OverrideMaplist(string S)
{
    return class'jrMapListManager'.static.OverrideMaplist(S);
}

DefaultProperties
{

}
