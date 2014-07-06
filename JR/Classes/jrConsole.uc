// ============================================================================
//  jrConsole.uc ::
// ============================================================================
class jrConsole extends ExtendedConsole;

event ViewportInitialized()
{
    Super.ViewportInitialized();

    // Adjust near clipping plane
    DelayedConsoleCommand("NEARCLIP 1");
}

DefaultProperties
{

}
