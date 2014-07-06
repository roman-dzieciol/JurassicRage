// ============================================================================
//  jr2K4Tab_GameSettings.uc ::
// ============================================================================
//  Copyright 2006 Jurassic Rage team. All Rights Reserved.
//  http://www.jurassic-rage.com
// ============================================================================
class jr2K4Tab_GameSettings extends UT2K4Tab_GameSettings;


function ReallyHideComponent( GUIComponent C )
{
    C.DisableMe();
    C.Hide();
    C.WinLeft = -10000;
    C.TabOrder = -1;
}

function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
    ch_ClassicTrans.bTabStop = false;
    Super.Initcomponent(MyController, MyOwner);

    i_BG1.Unmanagecomponent(ch_ClassicTrans);
    ReallyHideComponent(ch_ClassicTrans);
}


function ShowPanel(bool bShow)
{
    Super.ShowPanel(bShow);
    i_BG1.Unmanagecomponent(ch_ClassicTrans);
    ReallyHideComponent(ch_ClassicTrans);
}

DefaultProperties
{

}
