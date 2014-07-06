// ============================================================================
//  jr2K4StoryScrollText.uc ::
// ============================================================================
//  Copyright 2006 Jurassic Rage team. All Rights Reserved.
//  http://www.jurassic-rage.com
// ============================================================================
class jr2K4StoryScrollText extends GUIScrollText;

function NewContent()
{
    bNewContent = true;

    if(bNoTeletype)
        EndScrolling();
    else
        Restart();
}

DefaultProperties
{

}
