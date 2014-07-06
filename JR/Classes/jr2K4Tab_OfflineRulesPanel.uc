// ============================================================================
//  jr2K4Tab_OfflineRulesPanel.uc ::
// ============================================================================
//  Copyright 2006 Jurassic Rage team. All Rights Reserved.
//  http://www.jurassic-rage.com
// ============================================================================
class jr2K4Tab_OfflineRulesPanel extends IAMultiColumnRulesPanel;

function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
    Super.InitComponent(MyController, MyOwner);

    RemoveComponent(b_Symbols);
}

DefaultProperties
{

}
