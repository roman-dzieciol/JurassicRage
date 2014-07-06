// ============================================================================
//  jr2K4StoryList.uc ::
// ============================================================================
//  Copyright 2006 Jurassic Rage team. All Rights Reserved.
//  http://www.jurassic-rage.com
// ============================================================================
class jr2K4StoryList extends GUIListBox;

function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
    Super.Initcomponent(MyController, MyOwner);

}

DefaultProperties
{
    //SectionStyleName="ListSection"
    //SelectedStyleName="ListSelection"
    //StyleName="NoBackground"
    SectionStyleName        = "StoryListSection"
    StyleName               = "StoryList"
    SelectedStyleName       = "StoryListSelection"
    FontScale               = FNS_Large
}
