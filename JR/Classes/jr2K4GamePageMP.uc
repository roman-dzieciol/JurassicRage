// ============================================================================
//  jr2K4GamePageMP.uc ::
// ============================================================================
//  Copyright 2006 Jurassic Rage team. All Rights Reserved.
//  http://www.jurassic-rage.com
// ============================================================================
class jr2K4GamePageMP extends UT2K4GamePageMP;

function InitComponent(GUIController InController, GUIComponent InOwner)
{
    bUseTabs = False;
    Super.InitComponent(InController, InOwner);
    mcRules = jr2K4Tab_OfflineRulesPanel(c_Tabs.ReplaceTab(mcRules.MyButton, PanelCaption[2], "JR.jr2K4Tab_OfflineRulesPanel",, PanelHint[2]));
}

function StartGame(string GameURL, bool bAlt)
{
    local GUIController C;

    C = Controller;

    if (bAlt)
    {
        if ( mcServerRules != None )
            GameURL $= mcServerRules.Play();

        // Append optional server flags
        PlayerOwner().ConsoleCommand("relaunch"@GameURL@"-server -log=server.log -mod=JurassicRage");
    }
    else
        PlayerOwner().ClientTravel(GameURL $ "?Listen",TRAVEL_Absolute,False);

    C.CloseAll(false,True);
}

DefaultProperties
{
    PanelClass(0)="JR.jr2K4Tab_GameTypeMP"
    PanelClass(1)="JR.jr2K4Tab_MainSP"
    PanelClass(2)="GUI2K4.UT2K4Tab_RulesBase"
    PanelClass(3)="GUI2K4.UT2K4Tab_MutatorMP"
    PanelClass(4)="GUI2K4.UT2K4Tab_BotConfigMP"
    PanelClass(5)="GUI2K4.UT2K4Tab_ServerRulesPanel"
}
