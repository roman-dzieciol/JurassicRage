// ============================================================================
//  jr2K4StoryPage.uc ::
// ============================================================================
//  Copyright 2006 Jurassic Rage team. All Rights Reserved.
//  http://www.jurassic-rage.com
// ============================================================================
class jr2K4StoryPage extends UT2K4GUIPage;


var automated GUIScrollTextBox  lb_TextDisplay;
var automated GUIHeader         t_Header;
var automated ButtonFooter      t_Footer;
var automated BackgroundImage   i_Background;

var automated   GUIImage        i_bkChar, i_bkScan;



function InitComponent(GUIController MyC, GUIComponent MyO)
{
    Super.InitComponent(MyC, MyO);

    SetFocus(lb_TextDisplay);
}

function HandleParameters(string Param1, string Param2)
{
    if( Param1 != "" )
    {
        LoadStory(Param1);
    }
}


function LoadStory( string Extra )
{
    local int i, ChunkCount;
    local string StoryFile, Section, ChapterNum;

    if( !Divide( Extra, ".", StoryFile, ChapterNum )
    ||  StoryFile == ""
    ||  ChapterNum == "" )
        return;

    Section = "Chapter" $ChapterNum;

    t_Header.SetCaption( Localize( "Story", "Title", StoryFile ) );

    ChunkCount = int(Localize( Section, "Chunks", StoryFile ));
    if( ChunkCount <= 0 )
        return;

    lb_TextDisplay.SetContent("");

    lb_TextDisplay.AddText( Localize( Section, "Prefix", StoryFile ) $Localize( Section, "Title", StoryFile ) $"||");

    while( i++ != ChunkCount )
    {
        lb_TextDisplay.AddText(Localize( Section, "Chunk"$i, StoryFile ));
    }

    if( bool(Localize( "Story", "ToBeContinued", StoryFile ))
    &&  Localize( "Story", "Chapters", StoryFile ) == ChapterNum )
    {
        lb_TextDisplay.AddText(class'jr2K4StoryTab'.default.ToBeContinued);
    }
}

DefaultProperties
{

     Begin Object Class=jr2K4StoryTextBox Name=lbTextDisplay
         WinTop=0.04
         WinLeft=0.010000
         WinWidth=0.980000
         WinHeight=0.917943
         RenderWeight=0.490000
         bFocusOnWatch=True
         TabOrder=0
     End Object
     lb_TextDisplay=lbTextDisplay

     Begin Object Class=GUIHeader Name=JRHeader
         RenderWeight=0.300000
     End Object
     t_Header=GUIHeader'JRHeader'

     Begin Object Class=jr2K4StoryFooter Name=JRFooter
         WinTop=0.957943
         RenderWeight=0.300000
         TabOrder=1
     End Object
     t_Footer=jr2K4StoryFooter'JRFooter'

     Begin Object Class=BackgroundImage Name=PageBackground
         Image=Texture'2K4Menus.BkRenders.Bgndtile'
         ImageStyle=ISTY_PartialScaled
         X1=0
         Y1=0
         X2=4
         Y2=768
         RenderWeight=0.010000
     End Object
     i_Background=BackgroundImage'PageBackground'

     Begin Object Class=GUIImage Name=BkChar
         Image=Texture'2K4Menus.BkRenders.Char01'
         ImageStyle=ISTY_Scaled
         X1=0
         Y1=0
         X2=1024
         Y2=768
         WinHeight=1.000000
         RenderWeight=0.020000
     End Object
     i_bkChar=GUIImage'BkChar'

     Begin Object Class=BackgroundImage Name=PageScanLine
         Image=Texture'2K4Menus.BkRenders.Scanlines'
         ImageColor=(A=32)
         ImageStyle=ISTY_Tiled
         ImageRenderStyle=MSTY_Alpha
         X1=0
         Y1=0
         X2=32
         Y2=32
         RenderWeight=0.030000
     End Object
     i_bkScan=BackgroundImage'PageScanLine'


     bPersistent=False
     WinTop=0.000000
     WinHeight=1.000000

}
