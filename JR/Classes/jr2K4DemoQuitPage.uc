// ============================================================================
//  jr2K4DemoQuitPage.uc ::
// ============================================================================
//  Copyright 2006 Jurassic Rage team. All Rights Reserved.
//  http://www.jurassic-rage.com
// ============================================================================
class jr2K4DemoQuitPage extends UT2DemoQuitPage;

function bool OnQuitClicked(GUIComponent Sender)
{
    Controller.ReplaceMenu("JR.jr2K4ClosingCredits");
    return true;
}

DefaultProperties
{

}
