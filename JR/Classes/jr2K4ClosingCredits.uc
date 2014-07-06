// ============================================================================
//  jr2K4ClosingCredits.uc ::
// ============================================================================
//  Copyright 2006 Jurassic Rage team. All Rights Reserved.
//  http://www.jurassic-rage.com
// ============================================================================
class jr2K4ClosingCredits extends UT2K4GUIPage;


struct SCategory
{
    var string Title;
    var array<string> Names;
};

var string CreditsFile;

var string Intro;
var array<SCategory> Categories;
var float ElapsedTime;
var float EndTime;
var float ScrollSpeed;

var SCategory Outro;


function InitComponent(GUIController InController, GUIComponent InOwner)
{
    Super.InitComponent(InController, InOwner);
    OnDraw=MyOnDraw;
    OnMousePressed=MyOnMousePressed;
    OnKeyType=MyOnKeyType;
    LoadCredits();

}

function bool MyOnDraw(canvas C)
{
    local float XL,YL,X,Y;
    local int i,j;
    local array<string> Names;
    local string SL, SR;

    ElapsedTime += Controller.RenderDelta;

    C.Reset();
    C.SetPos(0,0);
    C.DrawTile( Material'Engine.BlackTexture', C.ClipX, C.ClipY, 0, 0, 128, 128 );


    C.Font = C.MedFont;
    C.StrLen(Intro,XL,YL);
    Y = C.ClipY - ElapsedTime*YL*ScrollSpeed;
    X = (C.ClipX - XL) * 0.20;
    C.SetPos(X,Y);
    C.DrawTextClipped(Intro);

    Y += YL*2;

    for( i=0; i!=Categories.Length; ++i )
    {
        C.Font = C.SmallFont;
        C.StrLen(Categories[i].Title,XL,YL);
        Y += YL*3;
        X = C.ClipX * 0.19 - XL;
        C.SetPos(X,Y);
        C.DrawTextClipped(Categories[i].Title);

        C.Font = C.MedFont;
        X = C.ClipX * 0.21;
        Names = Categories[i].Names;
        for( j=0; j!=Names.Length; ++j )
        {
            if( Divide(Names[j]," - ",SL,SR) )
            {
                C.StrLen(SL,XL,YL);
                C.SetPos(X,Y);
                C.DrawTextClipped(SL);
                Y += YL;

                C.Font = C.SmallFont;
                C.StrLen(SR,XL,YL);
                C.SetPos(X+YL,Y);
                C.DrawTextClipped(SR);
                Y += YL * 1.33;
                C.Font = C.MedFont;
            }
            else
            {
                C.StrLen(Names[j],XL,YL);
                C.SetPos(X,Y);
                C.DrawTextClipped(Names[j]);
                Y += YL * 1.33;
            }
        }

        if( Y > C.ClipY )
            return true;
    }

    Y += YL*6;

    C.Font = C.MedFont;
    C.StrLen(Outro.Title,XL,YL);
    X = (C.ClipX - XL) * 0.5;
    C.SetPos(X,Y);
    C.DrawTextClipped(Outro.Title);
    Y += YL*2;

    for( j=0; j!=Outro.Names.Length; ++j )
    {
        C.StrLen(Outro.Names[j],XL,YL);
        X = (C.ClipX - XL) * 0.5;
        C.SetPos(X,Y);
        C.DrawTextClipped(Outro.Names[j]);
        Y += YL * 2;
    }


    if( Y < 0 )
    {
        EndTime += Controller.RenderDelta;
        if( EndTime > 1 )
        {
            PlayerOwner().ConsoleCommand("exit");
        }
    }


    return true;
}


function MyOnMousePressed(GUIComponent Sender, bool bRepeat)
{
    PlayerOwner().ConsoleCommand("exit");
}

function bool MyOnKeyType(out byte Key, optional string Unicode)      // Key Strokes
{
    PlayerOwner().ConsoleCommand("exit");
    return true;
}


function LoadCredits()
{
    local int CategoryCount, ItemCount;
    local int i,j;
    local SCategory C;
    local array<string> Names;

    Categories.Length = 0;
    CategoryCount = int(Localize( "Credits", "Categories", CreditsFile ));
    if( CategoryCount <= 0 )
        return;

    Intro = Localize( "Credits", "Intro", CreditsFile );

    for( i=1; i<=CategoryCount; ++i )
    {
        C.Title = Localize( "Category"$i, "Name", CreditsFile );
        ItemCount = int(Localize( "Category"$i, "Items", CreditsFile ));
        Names.Length = ItemCount;
        for( j=1; j<=ItemCount; ++j )
        {
            Names[j-1] = Localize( "Category"$i, "Item"$j, CreditsFile );
        }
        C.Names = Names;

        Categories[Categories.Length] = C;
    }


    Outro.Title = Localize( "Outro", "Name", CreditsFile );
    Outro.Names.Length = int(Localize( "Outro", "Items", CreditsFile ));
    for( j=1; j<=Outro.Names.Length; ++j )
    {
        Outro.Names[j-1] = Localize( "Outro", "Item"$j, CreditsFile );
    }

}

DefaultProperties
{
    ScrollSpeed     = 2.5
    CreditsFile     = "JrCredits"
    Background      = None
    bPersistent     = False
    WinTop          = 0.000000
    WinHeight       = 1.000000
}
