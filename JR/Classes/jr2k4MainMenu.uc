// ============================================================================
//  jr2k4MainMenu.uc ::
// ============================================================================
//  Copyright 2006 Jurassic Rage team. All Rights Reserved.
//  http://www.jurassic-rage.com
// ============================================================================
class jr2k4MainMenu extends UT2k4MainMenu;

var automated   GUIButton   b_Information;

function ReallyHideComponent( GUIComponent C )
{
    C.DisableMe();
    C.Hide();
    C.WinLeft = -10000;
}

function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
    b_SinglePlayer.bTabStop = False;
    b_ModsAndDemo.bTabStop = False;

    Super.InitComponent(MyController, MyOwner);

    ReallyHideComponent( b_SinglePlayer );
    ReallyHideComponent( b_ModsAndDemo );
}

event Opened(GUIComponent Sender)
{
    if ( bDebugging )
        log(Name$".Opened()   Sender:"$Sender,'Debug');

    if ( Sender != None && PlayerOwner().Level.IsPendingConnection() )
        PlayerOwner().ConsoleCommand("CANCEL");

    Super(UT2K4GUIPage).Opened(Sender);

    bNewNews = class'GUI2K4.UT2K4Community'.default.ModRevLevel != class'GUI2K4.UT2K4Community'.default.LastModRevLevel;
    FadeTime=0;
    FadeOut=true;

    Selected = none;

    // Reset the animations of all components
    i_TV.Animate(-0.000977, 1.668619, 0);
    i_UT2Logo.Animate(0.007226,-0.392579,0);
    i_UT2Shader.Animate(0.249023,-0.105470,0);
    b_Multiplayer.Animate(1.15,0.449282,0);
    b_Host.Animate(1.3,0.534027,0);
    b_InstantAction.Animate(1.45,0.618619,0);
    b_Information.Animate(1.6,0.705859,0);
    b_Settings.Animate(1.75,0.800327,0);
    b_Quit.Animate(1.9,0.887567,0);
}


function MenuIn_OnArrival(GUIComponent Sender, EAnimationType Type)
{
    Sender.OnArrival = none;
    if ( bAnimating )
        return;

    i_UT2Shader.OnDraw = MyOnDraw;
    DesiredCharFade=255;
    CharFadeTime = 0.75;

    if (!Controller.bQuietMenu)
        PlayerOwner().PlaySound(FadeInSound);

    b_Multiplayer.Animate(0.21,0.349282,0.40);
    b_Multiplayer.OnArrival = PlayPopSound;
    b_Host.Animate(0.22,0.434027,0.45);
    b_Host.OnArrival = PlayPopSound;
    b_InstantAction.Animate(0.23,0.518619,0.5);
    b_InstantAction.OnArrival = PlayPopSound;
    b_Information.Animate(0.24,0.605859,0.55);
    b_Information.OnArrival = PlayPopSound;
    b_Settings.Animate(0.25,0.700327,0.6);
    b_Settings.OnArrival = PlayPopSound;
    b_Quit.Animate(0.26,0.787567,0.65);
    b_Quit.OnArrival = MenuIn_Done;
}

function bool ButtonClick(GUIComponent Sender)
{
    if (GUIButton(Sender) != None)
        Selected = GUIButton(Sender);

    if (Selected==None)
        return false;

    InitAnimOut( i_TV, -0.000977, 1.668619, 0.35);
    InitAnimOut(i_UT2Logo, 0.007226,-0.392579,0.35);
    InitAnimOut(i_UT2Shader,0.249023,-0.105470,0.35);
    InitAnimOut(b_Multiplayer,1.15,0.449282,0.35);
    InitAnimOut(b_Host,1.3,0.534027,0.35);
    InitAnimOut(b_InstantAction,1.45,0.618619,0.35);
    InitAnimOut(b_Information,1.6,0.705859,0.35);
    InitAnimOut(b_Settings,1.75,0.800327,0.35);
    InitAnimOut(b_Quit,1.9,0.887567,0.35);

    DesiredCharFade=0;
    CharFadeTime = 0.35;
    return true;
}

function bool CommunityDraw(canvas c)
{
    return false;
}



function MoveOn()
{
    switch (Selected)
    {
        case b_MultiPlayer:
            if ( !Controller.AuthroizeFirewall() )
            {
                Controller.OpenMenu("GUI2K4.UT2K4GenericMessageBox",FireWallTitle,FireWallMsg);
                return;
            }
            Profile("ServerBrowser");
            Controller.OpenMenu(Controller.GetServerBrowserPage());
            Profile("ServerBrowser");
            return;

        case b_Host:
            if ( !Controller.AuthroizeFirewall() )
            {
                Controller.OpenMenu("GUI2K4.UT2K4GenericMessageBox",FireWallTitle,FireWallMsg);
                return;
            }
            Profile("MPHost");
            Controller.OpenMenu(Controller.GetMultiplayerPage());
            Profile("MPHost");
            return;

        case b_InstantAction:
            Profile("InstantAction");
            Controller.OpenMenu(Controller.GetInstantActionPage());
            Profile("InstantAction");
            return;

        case b_Information:
            if ( !Controller.AuthroizeFirewall() )
            {
                Controller.OpenMenu("GUI2K4.UT2K4GenericMessageBox",FireWallTitle,FireWallMsg);
                return;
            }
            Profile("ModsandDemos");
            Controller.OpenMenu(Controller.GetModPage());
            Profile("ModsandDemos");
            return;

        case b_Settings:
            Profile("Settings");
            Controller.OpenMenu(Controller.GetSettingsPage());
            Profile("Settings");
            return;

        case b_Quit:
            Profile("Quit");
            Controller.OpenMenu(Controller.GetQuitPage());
            Profile("Quit");
            return;

        default:
            StopWatch(True);
    }
}

DefaultProperties
{
     Begin Object Class=GUIButton Name=InformationButton
         CaptionAlign=TXTA_Left
         CaptionEffectStyleName="TextButtonEffect"
         Caption="Community"
         bUseCaptionHeight=True
         FontScale=FNS_Small
         StyleName="TextButton"
         Hint="Jurassic Rage stories and demos."
         WinTop=0.705859
         WinLeft=0.433406
         WinWidth=0.574135
         WinHeight=0.075000
         TabOrder=4
         bFocusOnWatch=True
         OnClick=ButtonClick
         OnKeyEvent=InformationButton.InternalOnKeyEvent
     End Object
     b_Information=GUIButton'InformationButton'
}
