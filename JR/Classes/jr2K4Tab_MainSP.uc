// ============================================================================
//  jr2K4Tab_MainSP.uc ::
// ============================================================================
//  Copyright 2006 Jurassic Rage team. All Rights Reserved.
//  http://www.jurassic-rage.com
// ============================================================================
class jr2K4Tab_MainSP extends UT2K4Tab_MainSP;

var globalconfig bool bOnlyShowRecommended;

var automated moCheckBox ch_RecommendedMapsOnly;
var globalconfig string DefaultMapName;


function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
    Super.InitComponent(MyController, MyOwner);

    if( PlayerOwner().Level.IsDemoBuild() )
    {
        bOnlyShowRecommended = False;
        SaveConfig();
    }

    ch_RecommendedMapsOnly.Checked(bOnlyShowRecommended);

    // Insert recommended maps control in the middle
    sb_Options.UnmanageComponent(ch_OfficialMapsOnly);
    sb_Options.UnmanageComponent(b_Maplist);
    sb_Options.UnmanageComponent(b_Tutorial);
    sb_Options.ManageComponent(ch_OfficialMapsOnly);
    sb_Options.ManageComponent(ch_RecommendedMapsOnly);
    sb_Options.ManageComponent(b_Maplist);
    sb_Options.ManageComponent(b_Tutorial);
}

function ChangeRecommendedFilter(GUIComponent Sender)
{
    if( Sender != ch_RecommendedMapsOnly )
        return;

    bOnlyShowRecommended = ch_RecommendedMapsOnly.IsChecked();
    InitMaps();
}


function MaplistConfigClick( GUIComponent Sender )
{
    local MaplistEditor MaplistPage;

    // open maplist config page
    if ( Controller.OpenMenu(MaplistEditorMenu) )
    {
        MaplistPage = MaplistEditor(Controller.ActivePage);
        if ( MaplistPage != None )
        {
            MaplistPage.MainPanel = self;
            MaplistPage.bOnlyShowOfficial = bOnlyShowOfficial;
            MaplistPage.bOnlyShowCustom = bOnlyShowCustom;
            jr2K4MaplistEditor(MaplistPage).bOnlyShowRecommended = bOnlyShowRecommended;
            MaplistPage.Initialize(MapHandler);
        }
    }
}



// Query the CacheManager for the maps that correspond to this gametype, then fill the main list
function InitMaps( optional string MapPrefix )
{
    local int i, j;
    local bool bTemp;
    local string Package, Item, Desc;
    local GUITreeNode StoredItem;
    local DecoText DT;

    // Make sure we have a map prefix
    if ( MapPrefix == "" )
        MapPrefix = GetMapPrefix();

    // Temporarily disable notification in all components
    bTemp = Controller.bCurMenuInitialized;
    Controller.bCurMenuInitialized = False;

    if ( li_Maps.IsValid() )
        li_Maps.GetElementAtIndex(li_Maps.Index, StoredItem);

    // Get the list of maps for the current gametype
    class'CacheManager'.static.GetMapList( CacheMaps, MapPrefix );
    if ( MapHandler.GetAvailableMaps(MapHandler.GetGameIndex(CurrentGameType.ClassName), Maps) )
    {
        li_Maps.bNotify = False;
        li_Maps.Clear();

        for ( i = 0; i < Maps.Length; i++ )
        {

            DT = None;
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

            j = FindCacheRecordIndex(Maps[i].MapName);
            if ( class'CacheManager'.static.Is2003Content(Maps[i].MapName) )
            {
                if ( CacheMaps[j].TextName != "" )
                {
                    if ( !Divide(CacheMaps[j].TextName, ".", Package, Item) )
                    {
                        Package = "XMaps";
                        Item = CacheMaps[j].TextName;
                    }
                }

                DT = class'xUtil'.static.LoadDecoText(Package, Item);
            }

            Desc = Localize( "LevelSummary", "Description", Maps[i].MapName );
            if( Desc == "" )
            {
                if ( DT != None )
                    Desc = JoinArray(DT.Rows, "|");
                else
                    Desc = CacheMaps[j].Description;
            }

            li_Maps.AddItem( Maps[i].MapName, Maps[i].MapName, ,,Desc);

//            // for now, limit this to power link setups only
//            if ( CurrentGameType.MapPrefix ~= "ONS" )
//            {
//
//                // Big Hack Time for the bonus pack
//
//                CurrentItem = Maps[i].MapName;
//                for (BV=0;BV<2;BV++)
//                {
//                    if ( Maps[i].Options.Length > 0 )
//                    {
//                        Package = CacheMaps[j].Description;
//
//                        // Add the "auto link setup" item
//                        li_Maps.AddItem( AutoSelectText @ LinkText, Maps[i].MapName $ "?LinkSetup=Random", CurrentItem,,Package );
//
//                        // Now add all official link setups
//                        for ( k = 0; k < Maps[i].Options.Length; k++ )
//                        {
//                            li_Maps.AddItem(Maps[i].Options[k].Value @ LinkText, Maps[i].MapName $ "?LinkSetup=" $ Maps[i].Options[k].Value, CurrentItem,,Package );
//                        }
//                    }
//
//                    // Now to add the custom setups
//                    CustomLinkSetups = GetPerObjectNames(Maps[i].MapName, "ONSPowerLinkCustomSetup");
//                    for ( k = 0; k < CustomLinkSetups.Length; k++ )
//                    {
//                        li_Maps.AddItem(CustomLinkSetups[k] @ LinkText, Maps[i].MapName $ "?" $ "LinkSetup=" $ CustomLinkSetups[k], CurrentItem,,Package);
//                    }
//
//                    if ( !OrigONSMap(Maps[i].MapName) )
//                        break;
//
//                    else if (BV<1 && Controller.bECEEdition)
//                    {
//                        li_Maps.AddItem( Maps[i].MapName$BonusVehicles, Maps[i].MapName, ,,BonusVehiclesMsg$Package);
//                        CurrentItem=CurrentItem$BonusVehicles;
//                    }
//
//                    if ( !Controller.bECEEdition )  // Don't do the second loop if not the ECE
//                        break;
//
//                }
//
//            }
        }
    }

    if ( li_Maps.bSorted )
        li_Maps.SortList();

//    if ( StoredItem.Caption != "" )
//    {
//        i = li_Maps.FindFullIndex(StoredItem.Caption, StoredItem.Value, StoredItem.ParentCaption);
//        if ( i != -1 )
//            li_Maps.SilentSetIndex(i);
//    }

    li_Maps.bNotify = True;

    Controller.bCurMenuInitialized = bTemp;

    i = li_Maps.FindIndex( DefaultMapName );
    if ( i != -1 )
        li_Maps.SetIndex(i);
}


function ReadMapInfo(string MapName)
{
    local string mDesc;
    local int Index;
    local int pmin, pmax;

    if(MapName == "")
        return;

    if (!Controller.bCurMenuInitialized)
        return;

    Index = FindCacheRecordIndex(MapName);

    if (CacheMaps[Index].FriendlyName != "")
        asb_Scroll.Caption = CacheMaps[Index].FriendlyName;
    else
        asb_Scroll.Caption = MapName;

    UpdateScreenshot(Index);

    pmin = CacheMaps[Index].PlayerCountMin;
    pmax = CacheMaps[Index].PlayerCountMax;

    class'jrGameEX'.static.AdjustPlayerCount(pmin,pmax);

    // Only show 1 number if min & max are the same
    if ( pmin == pmax )
        l_MapPlayers.Caption = pmin @ PlayerText;
    else l_MapPlayers.Caption = pmin@"-"@pmax@PlayerText;

    mDesc = li_Maps.GetExtra();

    if (mDesc == "")
        mDesc = MessageNoInfo;

    lb_MapDesc.SetContent( mDesc );
    if (CacheMaps[Index].Author != "" && !class'CacheManager'.static.IsDefaultContent(CacheMaps[Index].MapName))
        l_MapAuthor.Caption = AuthorText$":"@CacheMaps[Index].Author;
    else l_MapAuthor.Caption = "";
}

function string GetMapListClass()
{
    return OverrideMaplist(CurrentGameType.MapListClassName);
}

function InitMapHandler()
{
    local PlayerController PC;

    PC = PlayerOwner();

    if ( PC.Level.Game != None && MaplistManager(PC.Level.Game.MaplistHandler) != None )
        MapHandler = MaplistManager(PC.Level.Game.MaplistHandler);

    if ( MapHandler == None )
        foreach PC.DynamicActors(class'MaplistManager', MapHandler)
            break;

    MapHandler = jrMaplistManager(MapHandler);

    if( MapHandler == None )
        MapHandler = PC.Spawn(class'jrMaplistManager');
}


simulated static final function string OverrideMaplist(string S)
{
    return class'jrMapListManager'.static.OverrideMaplist(S);
}

DefaultProperties
{
    CurrentGameType=(MapPrefix="INVALID")
    DefaultMapName="DM-DesertIsle"

    Begin Object Class=moCheckbox Name=RecommendedCheck
        OnChange=ChangeRecommendedFilter
        WinHeight=0.030035
        WinWidth=0.341797
        WinLeft=0.039258
        WinTop=0.949531
        Caption="Only Recommended Maps"
        Hint="Show only maps recommended by the Jurassic Rage creators."
        TabOrder=1
        bAutoSizeCaption=True
        ComponentWidth=0.9
        CaptionWidth=0.1
        bSquare=True
    End Object
    ch_RecommendedMapsOnly=RecommendedCheck
}
