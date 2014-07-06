// ============================================================================
//  jr2k4ServerBrowser.uc ::
// ============================================================================
//  Copyright 2006 Jurassic Rage team. All Rights Reserved.
//  http://www.jurassic-rage.com
// ============================================================================
class jr2k4ServerBrowser extends UT2k4ServerBrowser;


function PopulateGameTypes()
{
    local array<CacheManager.GameRecord> Games;
    local int i, j;

    if (Records.Length > 0)
        Records.Remove(0, Records.Length);

    class'CacheManager'.static.GetGameTypeList(Games);
    for (i = 0; i < Games.Length; i++)
    {
        if( Left(Games[i].ClassName,2) ~= "JR" )
        {
            Records.Insert(j, 1);
            Records[j] = Games[i];
        }
    }
}


DefaultProperties
{
    CurrentGameType="JR.jrGame2K4EX"
    PanelClass(5)="JR.jr2K4Browser_ServerListPageInternet"

    Begin Object Class=jr2K4Browser_Footer Name=FooterPanel
        WinWidth=1.000000
        WinLeft=0.000000
        WinTop=0.917943
        TabOrder=4
    End Object
    t_Footer=FooterPanel

}
