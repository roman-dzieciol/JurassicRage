// ============================================================================
//  jr2K4StoryTab.uc ::
// ============================================================================
//  Copyright 2006 Jurassic Rage team. All Rights Reserved.
//  http://www.jurassic-rage.com
// ============================================================================
class jr2K4StoryTab extends jr2K4CommunityTabs;

var config array<string> Stories;

var automated GUIListBox        lb_Stories;

var localized string TextPackage;
var localized string Chapter;
var localized string ToBeContinued;



function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
    local int i;

    Super.InitComponent(MyController, MyOwner);

    lb_Stories.List.OnTrack = InternalOnTrack;
    lb_Stories.List.OnChange = InternalOnChange;
    lb_Stories.List.bHotTrack = true;

    //lb_Stories.List.Add("Stories",,,True);

    for( i=0; i!=Stories.Length; ++i )
    {
        AddStory(Stories[i]);
    }

    SetFocus(lb_Stories);
}


function AddStory( string StoryFile )
{
    local string S, StoryTitle, StoryAuthor;
    local int i, ChapterCount;

    if( StoryFile == "" )
        return;

    StoryTitle = Localize( "Story", "Title", StoryFile );
    if( StoryTitle == "" )
        StoryTitle = StoryFile;

    StoryAuthor = Localize( "Story", "Author", StoryFile );

    ChapterCount = int(Localize( "Story", "Chapters", StoryFile ));
    if( ChapterCount <= 0 )
        return;

    lb_Stories.List.Add(StoryTitle,,StoryFile,True);

    while( i++ != ChapterCount )
    {
        S = Localize( "Chapter"$i, "Title", StoryFile );
        lb_Stories.List.Add(S,,StoryFile$"."$i);
    }
}



function InternalOnCreateComponent(GUIComponent NewComp, GUIComponent Sender)
{
//    if( jr2K4StoryTextBox(NewComp) != None )
//    {
//        lb_TextDisplay = GUIScrollTextBox(NewComp);
//    }
//    else if( jr2K4StoryList(NewComp) != None )
//    {
//        lb_Stories = GUIListBox(NewComp);
//        lb_StoriesList = lb_Stories.List;
//        lb_StoriesList.OnTrack = InternalOnTrack;
//    }
}


function InternalOnTrack(GUIComponent Sender, int OldIndex)
{
    if (!lb_Stories.List.IsValid())
        return;

    if (lb_Stories.List.IsSection())
    {
        lb_Stories.List.Index = OldIndex;
        return;
    }

}


function InternalOnChange(GUIComponent Sender)
{
    if( Sender == lb_Stories.List )
    {
        if( lb_Stories.List.IsSection() || !lb_Stories.List.IsValid() )
            return;

        GoFullScreen();
    }
}


function GoFullScreen()
{
    Controller.OpenMenu("JR.jr2K4StoryPage",lb_Stories.List.GetExtra());
}

DefaultProperties
{
    Stories(0)="JrStory"
    Stories(1)="JrDinos"

    Chapter="Chapter %n: "
    ToBeContinued="||To be continued..."


    Begin Object Class=jr2K4StoryList Name=lbStories
        WinTop=0.020000
        WinLeft=0.020000
        WinWidth=0.960000
        WinHeight=0.960000
         bFocusOnWatch=True
    End Object
    lb_Stories=lbStories
}
