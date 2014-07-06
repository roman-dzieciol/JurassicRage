// ============================================================================
//  jr2K4CommunityPage.uc ::
// ============================================================================
//  Copyright 2006 Jurassic Rage team. All Rights Reserved.
//  http://www.jurassic-rage.com
// ============================================================================
class jr2K4CommunityPage extends UT2k4MainPage;

#exec OBJ LOAD FILE=InterfaceContent.utx

var jr2K4StoryTab               tp_Story;
var jr2K4DemosTab               tp_Demos;

var UT2K4ModFooter              MyFooter;


function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
    local int i;

    MyFooter = UT2K4ModFooter(t_Footer);

    Super.InitComponent(MyController, MyOwner);

    tp_Story = jr2K4StoryTab( c_Tabs.AddTab(PanelCaption[i],"JR.jr2K4StoryTab",, PanelHint[i++]));
    tp_Demos = jr2K4DemosTab( c_Tabs.AddTab(PanelCaption[i],"JR.jr2K4DemosTab",, PanelHint[i++]));

    if( tp_Demos.lb_DemoList.List.ItemCount<=0 )
        tp_Demos.MyButton.DisableMe();
}

defaultproperties
{
     Begin Object Class=GUIHeader Name=JRHeader
         Caption="The Jurassic Rage Community"
         RenderWeight=0.300000
     End Object
     t_Header=GUIHeader'JRHeader'

     Begin Object Class=UT2K4ModFooter Name=ModFooter
         WinTop=0.957943
         RenderWeight=0.300000
         OnPreDraw=ModFooter.InternalOnPreDraw
     End Object
     t_Footer=UT2K4ModFooter'ModFooter'

     PanelCaption(0)="Stories"
     PanelCaption(1)="Demos"

     PanelHint(0)="Stories."
     PanelHint(1)="Replay a pre-recorded demo file..."

     bPersistent=False
}
