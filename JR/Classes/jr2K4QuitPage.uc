// ============================================================================
//  jr2K4QuitPage.uc ::
// ============================================================================
//  Copyright 2006 Jurassic Rage team. All Rights Reserved.
//  http://www.jurassic-rage.com
// ============================================================================
class jr2K4QuitPage extends UT2K4QuitPage;

function bool InternalOnClick(GUIComponent Sender)
{
    if (Sender==YesButton)
    {
        if(PlayerOwner().Level.IsDemoBuild())
            Controller.ReplaceMenu("JR.jr2K4DemoQuitPage");
        else
            Controller.ReplaceMenu("JR.jr2K4ClosingCredits");
    }
    else
        Controller.CloseMenu(false);

    return true;
}

DefaultProperties
{

}
