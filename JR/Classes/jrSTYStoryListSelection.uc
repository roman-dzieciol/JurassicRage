// ============================================================================
//  jrSTYStoryListSelection.uc ::
// ============================================================================
//  Copyright 2006 Jurassic Rage team. All Rights Reserved.
//  http://www.jurassic-rage.com
// ============================================================================
class jrSTYStoryListSelection extends GUI2Styles;


event Initialize()
{
    local int i;

    super.Initialize();

    for (i=0;i<5;i++)
        Images[i]=Controller.DefaultPens[0];
}


DefaultProperties
{
    KeyName="StoryListSelection"

    Images(0)=None
    Images(1)=None
    Images(2)=None
    Images(3)=None
    Images(4)=None

    FontNames(5)="MediumFont"
    FontNames(6)="MediumFont"
    FontNames(7)="MediumFont"
    FontNames(8)="MediumFont"
    FontNames(9)="MediumFont"

    FontNames(10)="UT2SmallHeaderFont"
    FontNames(11)="UT2SmallHeaderFont"
    FontNames(12)="UT2SmallHeaderFont"
    FontNames(13)="UT2SmallHeaderFont"
    FontNames(14)="UT2SmallHeaderFont"

    FontColors(0)=(R=255,G=230,B=0,A=220)
    FontColors(1)=(R=255,G=230,B=0,A=255)
    FontColors(2)=(R=255,G=230,B=0,A=255)
    FontColors(3)=(R=255,G=230,B=0,A=255)
    FontColors(4)=(R=187,G=159,B=0,A=140)

    FontBKColors(0)=(R=37,G=59,B=127,A=220)
    FontBKColors(1)=(R=37,G=59,B=127,A=255)
    FontBKColors(2)=(R=37,G=59,B=127,A=255)
    FontBKColors(3)=(R=37,G=59,B=127,A=255)
    FontBKColors(4)=(R=10,G=30,B=94,A=140)

    ImgColors(0)=(R=37,G=59,B=127,A=220)
    ImgColors(1)=(R=37,G=59,B=127,A=255)
    ImgColors(2)=(R=28,G=35,B=128,A=255)
    ImgColors(3)=(R=28,G=35,B=128,A=255)
    ImgColors(4)=(R=10,G=30,B=94,A=140)

    BorderOffsets[0]=3
    BorderOffsets[1]=3
    BorderOffsets[2]=3
    BorderOffsets[3]=3
}
