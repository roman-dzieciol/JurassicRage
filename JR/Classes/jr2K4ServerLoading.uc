// ============================================================================
//  jr2K4ServerLoading.uc ::
// ============================================================================
//  Copyright 2006 Jurassic Rage team. All Rights Reserved.
//  http://www.jurassic-rage.com
// ============================================================================
class jr2K4ServerLoading extends UT2K4ServerLoading;



simulated function SetText()
{
    local DrawOpText HintOp;
    local string Hint;

    DrawOpText(Operations[3]).Text = StripMap(MapName);

    if (Level.IsSoftwareRendering())
        return;

    HintOp = DrawOpText(Operations[4]);
    if ( HintOp == None )
        return;

    if ( GameClass == None )
    {
        Warn("Invalid game class, so cannot draw loading hint!");
        return;
    }

    Hint = GameClass.static.GetLoadingHint(Level.GetLocalPlayerController(), MapName, HintOp.DrawColor);
    if ( Hint == "" )
    {
        log("No loading hint configured for "@GameClass.Name);
        return;
    }

    HintOp.Text = Hint;
}

DefaultProperties
{


    Begin Object Class=DrawOpImage Name=OpBG
        Top=0
        Lft=0
        Width=1.0
        Height=1.0
        DrawColor=(R=255,B=255,G=255,A=255)
        SubXL=512
        SubYL=384
    End Object
    Operations(0)=OpBG

    Begin Object Class=DrawOpImage Name=OpTextBG
        Top=0.825
        Lft=0
        Width=1.0
        Height=0.175
        RenderStyle=4
        DrawColor=(R=64,B=64,G=64,A=255)
        Image=Material'Engine.WhiteTexture'
    End Object
    Operations(1)=OpTextBG

    Begin Object Class=DrawOpText Name=OpLoading
        Top=0.58
        Lft=0.5
        Height=0.05
        Width=0.49
        Justification=2
        Text=". . . LOADING"
        FontName="XInterface.UT2LargeFont"
        bWrapText=False
    End Object
    Operations(2)=OpLoading

    Begin Object Class=DrawOpText Name=OpMapname
        Top=0.7
        Lft=0.5
        Height=0.05
        Width=0.49
        Justification=2
        FontName="XInterface.UT2LargeFont"
        bWrapText=False
    End Object
    Operations(3)=OpMapname

    Begin Object Class=DrawOpText Name=OpHint
        Top=0.85
        Height=0.15
        Lft=0.05
        Width=0.93
        Justification=2
        FontName="GUI2K4.fntUT2k4SmallHeader"
    End Object
    Operations(4)=OpHint
}
