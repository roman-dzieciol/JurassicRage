// ============================================================================
//  jr2K4FanFictionsTab.uc ::
// ============================================================================
//  Copyright 2006 Jurassic Rage team. All Rights Reserved.
//  http://www.jurassic-rage.com
// ============================================================================
class jr2K4FanFictionsTab extends jr2K4CommunityTabs;

var automated GUIScrollTextBox  TextBox;

function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
    Super.InitComponent(MyController, MyOwner);
}


DefaultProperties
{
     Begin Object Class=GUIScrollTextBox Name=lbText
         bNoTeletype=True
         bVisibleWhenEmpty=True
         OnCreateComponent=lbText.InternalOnCreateComponent
         WinTop=0.020000
         WinLeft=0.020000
         WinWidth=0.960000
         WinHeight=0.960000
         TabOrder=0
     End Object
     TextBox=GUIScrollTextBox'lbText'

}

