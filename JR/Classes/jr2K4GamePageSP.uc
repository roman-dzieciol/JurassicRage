// ============================================================================
//  jr2K4GamePageSP.uc ::
// ============================================================================
//  Copyright 2006 Jurassic Rage team. All Rights Reserved.
//  http://www.jurassic-rage.com
// ============================================================================
class jr2K4GamePageSP extends UT2K4GamePageSP;


function InitComponent(GUIController InController, GUIComponent InOwner)
{
    bUseTabs = False;
    Super.InitComponent(InController, InOwner);
    mcRules = jr2K4Tab_OfflineRulesPanel(c_Tabs.ReplaceTab(mcRules.MyButton, PanelCaption[2], "JR.jr2K4Tab_OfflineRulesPanel",, PanelHint[2]));
}



DefaultProperties
{
    PanelClass(0)="JR.jr2K4Tab_GameTypeSP"
    PanelClass(1)="JR.jr2K4Tab_MainSP"
    PanelClass(2)="GUI2K4.UT2K4Tab_RulesBase"
    PanelClass(3)="GUI2K4.UT2K4Tab_MutatorSP"
    PanelClass(4)="GUI2K4.UT2K4Tab_BotConfigSP"
}
