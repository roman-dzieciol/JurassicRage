// ============================================================================
//  jr2K4StoryFooter.uc ::
// ============================================================================
//  Copyright 2006 Jurassic Rage team. All Rights Reserved.
//  http://www.jurassic-rage.com
// ============================================================================
class jr2K4StoryFooter extends ButtonFooter;


var automated GUIButton b_Back;


function bool InternalOnClick(GUIComponent Sender)
{
    if (Sender==b_Back)
        Controller.CloseMenu(false);

    return true;
}



defaultproperties
{
    Begin Object Class=GUIButton Name=BackB
        Caption="BACK"
        Hint="Return to the previous menu"
         WinTop=0.085678
         WinWidth=0.120000
         WinHeight=0.036482
         RenderWeight=2.000200
        TabOrder=0
        bBoundToParent=True
        StyleName="FooterButton"
        OnClick=InternalOnClick
    End Object
    b_Back=BackB

     Padding=0.300000
     Margin=0.010000
     Spacer=0.010000
}
