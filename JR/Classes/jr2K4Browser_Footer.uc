// ============================================================================
//  jr2K4Browser_Footer.uc ::
// ============================================================================
//  Copyright 2006 Jurassic Rage team. All Rights Reserved.
//  http://www.jurassic-rage.com
// ============================================================================
class jr2K4Browser_Footer extends UT2k4Browser_Footer;


function ReallyHideComponent( GUIComponent C )
{
    C.DisableMe();
    C.Hide();
    C.WinLeft = -10000;
}


function InitComponent(GUIController InController, GUIComponent InOwner)
{
    ch_Standard.bTabStop = false;
    b_Filter.bTabStop = false;

    Super.InitComponent(InController, InOwner);
    ReallyHideComponent(ch_Standard);
    ReallyHideComponent(b_Filter);

}

DefaultProperties
{

}
