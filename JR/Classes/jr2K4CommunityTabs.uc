// ============================================================================
//  jr2K4CommunityTabs.uc ::
// ============================================================================
//  Copyright 2006 Jurassic Rage team. All Rights Reserved.
//  http://www.jurassic-rage.com
// ============================================================================
class jr2K4CommunityTabs extends UT2K4TabPanel;

var jr2K4CommunityPage MyPage;


function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
    super.InitComponent(MyController,MyOwner);
    MyPage = jr2K4CommunityPage(MyOwner.MenuOwner);
}

function ShowPanel(bool bShow)
{
    if (bShow)
        MyPage.MyFooter.TabChange(Tag);

    super.ShowPanel(bShow);
}

DefaultProperties
{

}
