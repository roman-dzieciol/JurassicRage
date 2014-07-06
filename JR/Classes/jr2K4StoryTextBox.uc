// ============================================================================
//  jr2K4StoryTextBox.uc ::
// ============================================================================
//  Copyright 2006 Jurassic Rage team. All Rights Reserved.
//  http://www.jurassic-rage.com
// ============================================================================
class jr2K4StoryTextBox extends GUIScrollTextBox;

function AddText(string NewText)
{
    local string StrippedText;

    if(NewText == "")
        return;

    if(bStripColors)
        StrippedText = StripColors(NewText);
    else
        StrippedText = NewText;

    MyScrollText.NewText $= StrippedText;

    //jr2K4StoryScrollText(MyScrollText).NewContent();
}

DefaultProperties
{
    bVisibleWhenEmpty       = True
    bNoTeletype             = True
    DefaultListClass        = "JR.jr2K4StoryScrollText"
}
