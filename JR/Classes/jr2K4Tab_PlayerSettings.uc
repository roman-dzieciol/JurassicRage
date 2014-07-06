// ============================================================================
//  jr2K4Tab_PlayerSettings.uc ::
// ============================================================================
//  Copyright 2006 Jurassic Rage team. All Rights Reserved.
//  http://www.jurassic-rage.com
// ============================================================================
class jr2K4Tab_PlayerSettings extends UT2K4Tab_PlayerSettings;

function ReallyHideComponent( GUIComponent C )
{
    C.DisableMe();
    C.Hide();
    C.WinLeft=-10000;
}

function InitComponent(GUIController MyController, GUIComponent MyOwner)
{

    co_SkinPreview.bTabStop = false;
    b_Pick.bTabStop = false;
    b_3DView.bTabStop = false;
    co_Team.bTabStop = false;

    Super.Initcomponent(MyController, MyOwner);

    ReallyHideComponent(co_SkinPreview);
    ReallyHideComponent(b_Pick);
    ReallyHideComponent(b_3DView);

    i_BG2.Unmanagecomponent(co_Team);
    ReallyHideComponent(co_Team);

    if( SpinnyDude != None )
        SpinnyDude.Destroy();

    SpinnyDude = PlayerOwner().spawn(class'JR.jrMenuDude');

    SpinnyDude.bPlayCrouches = true;
    SpinnyDude.bPlayRandomAnims = true;

    SpinnyDude.SetDrawType(DT_Mesh);
    SpinnyDude.SetDrawScale(0.9);
    SpinnyDude.SpinRate = 0;

}

function UpdateScroll()
{
    lb_Scroll.SetContent(LoadDecoText("",PlayerRec.TextName));
}


function string LoadDecoText(string PackageName, string DecoTextName)
{
    local string DecoText;

    if (InStr(DecoTextName, ".") != -1)
    {
        if (PackageName == "")
            Divide(DecoTextName, ".", PackageName, DecoTextName);
        else DecoTextName = Mid(DecoTextName, InStr(DecoTextName, ".") + 1);
    }

    DecoText = Localize( "DecoText", DecoTextName, PackageName );

    return DecoText;
}


DefaultProperties
{

}
