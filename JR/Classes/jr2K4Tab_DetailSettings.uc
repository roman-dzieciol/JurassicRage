// ============================================================================
//  jr2K4Tab_DetailSettings.uc ::
// ============================================================================
class jr2K4Tab_DetailSettings extends UT2K4Tab_DetailSettings;

function bool RenderDeviceClick( byte Btn )
{
    switch ( Btn )
    {
    case QBTN_Yes:
        SaveSettings();
        Console(Controller.Master.Console).DelayedConsoleCommand("relaunch -mod=JurassicRage");
        break;

    case QBTN_Cancel:
        sRenDev = sRenDevD;
        co_RenderDevice.Find(sRenDev);
        co_RenderDevice.SetComponentValue(sRenDev,true);
        break;
    }

    return true;
}

DefaultProperties
{

}
