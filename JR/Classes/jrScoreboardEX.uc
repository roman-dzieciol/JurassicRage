// ============================================================================
//  jrScoreboardEX.uc ::
// ============================================================================
//  Copyright 2006 Jurassic Rage team. All Rights Reserved.
//  http://www.jurassic-rage.com
// ============================================================================
class jrScoreboardEX extends ScoreBoardTeamDeathMatch
    dependson(jrHighScore);

var Texture TimeIcon;

var Material SeparatorMaterial;
var Material FrameMaterial;

var localized string HighScoreText;
var localized string CurrentScoreText;


simulated event UpdateScoreBoard(Canvas Canvas)
{
    local PlayerReplicationInfo PRI, OwnerPRI;
    local int i, PlayerCount, OwnerOffset;
    local float HeaderY, HeaderH, FooterY, FooterH;
    local float BodyM,BodyY,BodyW,BodyH,BodyR;

    OwnerPRI = PlayerController(Owner).PlayerReplicationInfo;
    for( i=0; i<GRI.PRIArray.Length; ++i )
    {
        PRI = GRI.PRIArray[i];
        if( !PRI.bOnlySpectator && (!PRI.bIsSpectator || PRI.bWaitingPlayer) )
        {
            if( PRI == OwnerPRI )
                OwnerOffset = i;
            PlayerCount++;
        }
    }
    PlayerCount = Min(PlayerCount,MAXPLAYERS);

    bDisplayMessages = true;
    DrawTitles(Canvas,HeaderY, HeaderH, FooterY, FooterH);

    if( GRI != None )
    {
        for( i=0; i<GRI.PRIArray.Length; ++i )
            PRIArray[i] = GRI.PRIArray[i];

        BodyR = 0.6;
        BodyM = Canvas.ClipX * 0.025;
        BodyY = HeaderY + HeaderH;
        BodyH = FooterY - BodyY;
        BodyW = Canvas.ClipX - 3*BodyM;

        DrawPlayerTeam(Canvas,PlayerCount,OwnerOffset,BodyM,BodyY,BodyW*BodyR,BodyH);

        if( jrGRIEX(GRI) != None && jrGRIEX(GRI).HighScore != None )
        {
            DrawHighScore(Canvas,BodyM*2+BodyW*BodyR,BodyY,BodyW*(1-BodyR),BodyH);
        }

    }
}

function DrawTitles(Canvas Canvas, out float HeaderY, out float HeaderH, out float FooterY, out float FooterH)
{
    local string titlestring,scoreinfostring,RestartString;
    local float XL,YL;
    local int LineH;
    local string S;

    if ( Canvas.ClipX < 512 )
        return;

    LineH = Canvas.ClipY * 0.1;

    HeaderY = 0;
    HeaderH = Canvas.ClipY * 0.075;
    FooterH = 1.5 *  HeaderH;
    FooterY = Canvas.ClipY - FooterH;

    TitleString     = GetTitleString();
    ScoreInfoString = GetDefaultScoreInfoString();

    Canvas.Style = ERenderStyle.STY_Normal;
    Canvas.DrawColor = HUDClass.default.GoldColor;

    SetFontFor(Canvas, TitleString, 0, HeaderH*0.66, XL, YL);
    Canvas.SetPos(0.5*(Canvas.ClipX-XL), (HeaderH-YL)*0.5);
    Canvas.DrawText(TitleString);



    if( UnrealPlayer(Owner).bDisplayLoser )
        ScoreInfoString = class'HUDBase'.default.YouveLostTheMatch;
    else if( UnrealPlayer(Owner).bDisplayWinner )
        ScoreInfoString = class'HUDBase'.default.YouveWonTheMatch;
    else if( PlayerController(Owner).IsDead() )
    {
        RestartString = GetRestartString();

//        if( Canvas.ClipY - HeaderOffsetY - PlayerAreaY >= 2.5 * YL )
//        {
            SetFontFor(Canvas, RestartString, 0, FooterH*0.5*0.75, XL, YL);
            Canvas.SetPos(0.5*(Canvas.ClipX-XL), FooterY + (FooterH*0.5-YL)*0.5);
            Canvas.DrawText(RestartString);
//        }
//        else
//            ScoreInfoString = RestartString;
    }

    SetFontFor(Canvas, ScoreInfoString, 0, FooterH*0.5*0.75, XL, YL);
    Canvas.SetPos(0.5*(Canvas.ClipX-XL), FooterY + FooterH*0.5 + (FooterH*0.5-YL)*0.5);
    Canvas.DrawText(ScoreInfoString);

    if( GRI.MatchID != 0 )
    {
        S = MatchIDText @GRI.MatchID;
        SetFontFor(Canvas, S, 0, HeaderH*0.15, XL, YL);
        Canvas.SetPos(Canvas.ClipX - XL - 4, 4);
        Canvas.DrawText(S);
    }
}




function DrawPlayerTeam(Canvas Canvas, int PlayerCount, int OwnerOffset, int BodyX, int BodyY, int BodyW, int BodyH )
{
    local int i;
    local float ListX, ListY, ListW, ListH;
    local float ItemX, ItemY, ItemW, ItemH;
    local float FieldX, FieldY, FieldW, FieldH;
    local float CaptionX, CaptionY, CaptionW, CaptionH;
    local float SeparatorH, SeparatorY;
    local float X,Y, XL,YL, ScoreFontH, PlayerFontH, LocFontH;
    local Font ScoreFont, PlayerFont, LocFont;
    local int Score, VirtualCount;
    local string S;
    local Color BaseColor;


    // caption
    CaptionX = BodyX;
    CaptionY = BodyY;
    CaptionW = BodyW;
    CaptionH = Canvas.ClipY * 0.075;

    PlayerCount = Min(16,PlayerCount);
    VirtualCount = Max(8,PlayerCount);


    // score list
    ListX = CaptionX;
    ListY = CaptionY + CaptionH;
    ListW = CaptionW;
    ListH = BodyH - CaptionH;

    // score item
    ItemX = ListX;
    ItemY = ListY;
    ItemW = ListW;
    ItemH = ListH / VirtualCount;

    if( VirtualCount == 8 )
    {
        ListH = ItemH * PlayerCount;
    }

    // score item field
    FieldW = ItemW * 0.95;
    FieldH = ItemH * 0.80;
    FieldX = ItemX + (ItemW-FieldW)*0.5;
    FieldY = ItemY + (ItemH-FieldH)*0.5;


    // draw header box
    Canvas.Style = ERenderStyle.STY_Alpha;
    Canvas.DrawColor = HUDClass.default.WhiteColor * 0.75;
    Canvas.SetPos(CaptionX, CaptionY);
    Canvas.DrawTileStretched( Material'InterfaceContent.ScoreBoxA', CaptionW, CaptionH+ListH);

    // draw header text
    Score = class'jrHighScoreEX'.Static.GetTimeScore(GRI.ElapsedTime, GRI.Teams[0].Score);
    S = CurrentScoreText @Score;
    SetFontFor( Canvas, S, 0, CaptionH*0.9, XL, YL );
    Canvas.DrawColor = HUDClass.default.WhiteColor;
    Canvas.SetPos( CaptionX + (CaptionW-XL)*0.5, CaptionY + (CaptionH-YL)*0.5);
    Canvas.DrawText( S );

    if( PlayerCount == 0 )
        return;


    // draw frame
    Canvas.Style = ERenderStyle.STY_Alpha;
    Canvas.DrawColor = HUDClass.default.WhiteColor * 0.75;
    Canvas.SetPos(ListX, ListY);
    Canvas.DrawTileStretched( FrameMaterial, ListW, ListH );

    // draw frame background
    Canvas.DrawColor = HUDClass.default.WhiteColor;
    Canvas.SetPos(ListX, ListY);
    Canvas.DrawTileStretched( TeamBoxMaterial[0], ListW, ListH );

    // draw separators
    SeparatorH = 2 * Canvas.ClipY / 480;
    SeparatorY = ItemY - SeparatorH*0.5;
    Canvas.Style = ERenderStyle.STY_Translucent;
    Canvas.DrawColor = HUDClass.default.RedColor;
    for( i=0; i<PlayerCount-1; ++i )
    {
        Canvas.SetPos( FieldX, SeparatorY + ItemH*(i+1) );
        Canvas.DrawTileStretched( SeparatorMaterial, FieldW, SeparatorH );
    }

    // Fonts
    ScoreFont = SetFontFor( Canvas, "1234", 0, FieldH*0.8, XL, ScoreFontH );
    PlayerFont = SetFontFor( Canvas, "ABCDefghIJKLmnop", 0, FieldH*0.7, XL, PlayerFontH );
    LocFont = SetFontFor( Canvas, "ABCDefghIJKLmnop", 0, FieldH*0.3, XL, LocFontH );


    // draw player info
    Canvas.Style = ERenderStyle.STY_Alpha;
    Canvas.DrawColor = HUDClass.default.WhiteColor;
    for( i=0; i<PlayerCount; ++i )
    {
        if( i != OwnerOffset )
            BaseColor = HUDClass.default.WhiteColor;
        else
            BaseColor = HUDClass.default.GoldColor;

        // player name
        Canvas.Font = PlayerFont;
        X = FieldX + 0.00*FieldW;
        S = PRIArray[i].PlayerName;
        Canvas.SetPos( X, FieldY + ItemH*i );
        Canvas.DrawColor = BaseColor;
        Canvas.DrawText( S );
        Canvas.StrLen(S,XL,YL);
        X += XL;
        if( PRIArray[i].bBot )
        {
            Canvas.SetPos( X, FieldY + ItemH*i );
            S = " ["$PRIArray[i].GetCallSign() $"]";
            Canvas.DrawColor = BaseColor * 0.33;
            Canvas.Style = ERenderStyle.STY_Translucent;
            Canvas.DrawText( S );
            Canvas.Style = ERenderStyle.STY_Alpha;
            Canvas.StrLen(S,XL,YL);
            X += XL;
        }

        // score
        S = string(int(PRIArray[i].Score));
        Canvas.DrawColor = BaseColor;
        Canvas.Font = ScoreFont;
        Canvas.StrLen( "9999", XL, YL );
        Canvas.SetPos( FieldX + FieldW - XL - FieldW*0.15, FieldY + ItemH*i + (FieldH-ScoreFontH)*0.5 );
        Canvas.DrawText( S );
/*

     WhiteColor=(B=255,G=255,R=255,A=255)
     RedColor=(R=255,A=255)
     GreenColor=(G=255,A=255)
     CyanColor=(B=255,G=255,A=255)
     BlueColor=(B=255,A=255)
     GoldColor=(G=255,R=255,A=255)
     PurpleColor=(B=255,R=255,A=255)
     TurqColor=(B=255,G=128,A=255)
     GrayColor=(B=200,G=200,R=200,A=255)
*/

        // player details
        Canvas.Font = LocFont;
        X = FieldX + 0.00*FieldW;
        Y = FieldY + ItemH*i + PlayerFontH;

        // readiness
        if( !GRI.bMatchHasBegun )
        {
            if( PRIArray[i].bReadyToPlay )
            {
                S = ReadyText;
                Canvas.DrawColor = HUDClass.default.GreenColor;
            }
            else
            {
                S = NotReadyText;
                Canvas.DrawColor = HUDClass.default.WhiteColor;
            }
            S = " "$S;
            Canvas.SetPos( X, Y );
            Canvas.DrawText( S );
            Canvas.StrLen(S,XL,YL);
            X += XL;
        }

        // admin
        if( PRIArray[i].bAdmin )
        {
            S = AdminText;
            S = " "$S;
            Canvas.DrawColor = HUDClass.default.GoldColor;
            Canvas.SetPos( X, Y );
            Canvas.DrawText( S );
            Canvas.StrLen(S,XL,YL);
            X += XL;
        }

        // location
        if( GRI.bMatchHasBegun )
        {
            Canvas.SetPos( X, Y );
            Canvas.DrawColor = HUDClass.default.CyanColor;
            S = PRIArray[i].GetLocationName();
            S = " "$S;
            Canvas.DrawText( S );
            Canvas.StrLen(S,XL,YL);
            X += XL;
        }

        // bot info
        if( PRIArray[i].bBot )
        {
            S = TeamPlayerReplicationInfo(PRIArray[i]).Squad.GetShortOrderStringFor(TeamPlayerReplicationInfo(PRIArray[i]));
            S = " "$S;
            Canvas.DrawColor = HUDClass.default.GrayColor;
            Canvas.SetPos( X, Y );
            Canvas.DrawText( S );
            Canvas.StrLen(S,XL,YL);
            X += XL;
        }

        Canvas.DrawColor = HUDClass.default.CyanColor;
        X = FieldX + FieldW - FieldW*0.15;
        Y = FieldY + ItemH*i;

        S = PingText @Min(999,4*PRIArray[i].Ping);
        Canvas.StrLen(S,XL,YL);
        Canvas.SetPos( X, Y );
        Canvas.DrawText( S );
        Y += YL;

        S = PLText @PRIArray[i].PacketLoss;
        Canvas.StrLen(S,XL,YL);
        Canvas.SetPos( X, Y );
        Canvas.DrawText( S );
        Y += YL;

        S = FPH @Clamp(3600*PRIArray[i].Score/FMax(1,GRI.ElapsedTime - PRIArray[i].StartTime),-999,9999);
        Canvas.StrLen(S,XL,YL);
        Canvas.SetPos( X, Y );
        Canvas.DrawText( S );
        Y += YL;

        //Canvas.DrawText(FormatTime(Max(0,FPHTime - PRIArray[OwnerOffset].StartTime)),true);
    }
}



function DrawHighScore(Canvas Canvas, int BodyX, int BodyY, int BodyW, int BodyH)
{
    local int i;
    local jrHighScore.SPackedScore HighScore;
    local float ListX, ListY, ListW, ListH;
    local float ItemX, ItemY, ItemW, ItemH;
    local float FieldX, FieldY, FieldW, FieldH;
    local float CaptionX, CaptionY, CaptionW, CaptionH;
    local float SeparatorH, RankTextY, ScoreTextY, SeparatorY;
    local float XL, YL;

    if( jrGRIEX(GRI) != None && jrGRIEX(GRI).HighScore != None )
        HighScore = jrGRIEX(GRI).HighScore.HighScore;

    // caption
    CaptionX = BodyX;
    CaptionY = BodyY;
    CaptionW = BodyW;
    CaptionH = Canvas.ClipY * 0.075;

    // score list
    ListX = CaptionX;
    ListY = CaptionY + CaptionH;
    ListW = CaptionW;
    ListH = BodyH - CaptionH;

    // score item
    ItemX = ListX;
    ItemY = ListY;
    ItemW = ListW;
    ItemH = ListH / ArrayCount(HighScore.Items);

    // score item field
    FieldW = ItemW * 0.95;
    FieldH = ItemH * 0.80;
    FieldX = ItemX + (ItemW-FieldW)*0.5;
    FieldY = ItemY + (ItemH-FieldH)*0.5;

    // draw frame
    Canvas.Style = ERenderStyle.STY_Alpha;
    Canvas.DrawColor = HUDClass.default.WhiteColor * 0.75;
    Canvas.SetPos(ListX, BodyY);
    Canvas.DrawTileStretched( FrameMaterial, ListW, BodyH );

    // draw caption box
    Canvas.Style = ERenderStyle.STY_Alpha;
    Canvas.DrawColor = HUDClass.default.WhiteColor * 0.75;
    Canvas.SetPos(CaptionX, CaptionY);
    Canvas.DrawTileStretched( FrameMaterial, CaptionW, CaptionH );

    // draw caption text
    SetFontFor( Canvas, HighScoreText, 0, CaptionH*0.9, XL, YL );
    Canvas.DrawColor = HUDClass.default.WhiteColor;
    Canvas.SetPos( CaptionX + (CaptionW-XL)*0.5, CaptionY + (CaptionH-YL)*0.5);
    Canvas.DrawText(HighScoreText);

    // draw separators
    Canvas.Style = ERenderStyle.STY_Translucent;
    Canvas.DrawColor = HUDClass.default.WhiteColor;
    SeparatorH = 2 * Canvas.ClipY / 480;
    SeparatorY = ItemY - SeparatorH*0.5;
    for( i=1; i<ArrayCount(HighScore.Items); ++i )
    {
        Canvas.SetPos( FieldX, SeparatorY + ItemH*i );
        Canvas.DrawTileStretched( SeparatorMaterial, FieldW, SeparatorH );
    }

    // draw rank
    Canvas.Font = SetFontFor( Canvas, "#123", 0, FieldH*0.75, XL, YL );
    Canvas.Style = ERenderStyle.STY_Translucent;
    Canvas.DrawColor = HUDClass.default.WhiteColor * 0.33;
    RankTextY = ItemY + (ItemH-YL)*0.5;
    for( i=0; i<ArrayCount(HighScore.Items); ++i )
    {
        Canvas.SetPos( FieldX + 0.0*FieldW, RankTextY + ItemH*i );
        Canvas.DrawText( "#" $(HighScore.First+i+1) );
    }

    // draw scores
    Canvas.Font = SetFontFor( Canvas, "1234", 0, FieldH, XL, YL );
    Canvas.Style = ERenderStyle.STY_Alpha;
    Canvas.DrawColor = HUDClass.default.WhiteColor;
    ScoreTextY = ItemY + (ItemH-YL)*0.5;
    for( i=0; i<ArrayCount(HighScore.Items); ++i )
    {
        if( i + HighScore.First != HighScore.Index )
        {
            // score text
            Canvas.SetPos( FieldX + 0.2*FieldW, FieldY + ItemH*i );
            Canvas.DrawText( HighScore.Items[i].Score );

            // player name
            Canvas.SetPos( FieldX + 0.5*FieldW, FieldY + ItemH*i );
            Canvas.DrawText( HighScore.Items[i].Player );
        }
        else
        {
            Canvas.DrawColor = HUDClass.default.GoldColor;

            // score text
            Canvas.SetPos( FieldX + 0.2*FieldW, FieldY + ItemH*i );
            Canvas.DrawText( HighScore.Items[i].Score );

            // player name
            Canvas.SetPos( FieldX + 0.5*FieldW, FieldY + ItemH*i );
            Canvas.DrawText( HighScore.Items[i].Player );

            Canvas.DrawColor = HUDClass.default.WhiteColor;
        }
    }
}


final function Font SetFontFor( Canvas C, string Text, float Width, float Height, out float XL, out float YL )
{
    local int i;

    for( i=0; i!=9; ++i )
    {
        C.Font = HUDClass.static.LoadFontStatic(i);
        C.StrLen(Text, XL, YL);
        if((Height == 0 || YL <= Height) && (Width == 0 || XL <= Width))
            break;
    }

    return C.Font;
}

DefaultProperties
{
    TimeIcon = Texture'HUDContent.Generic.HUD';
    HighScoreText="HIGH SCORE"
    CurrentScoreText="SCORE:"
    HUDClass=class'JR.jrHUDEX'
    SeparatorMaterial=Material'InterfaceContent.ButtonBob'
    FrameMaterial=Material'InterfaceContent.ScoreBoxA'
}
