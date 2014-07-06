// ============================================================================
//  jrDbg.uc ::
// ============================================================================
class jrDbg extends jrObject;


final static function string GetNetInfo( Actor A )
{
    local string S;

    switch( A.Level.NetMode )
    {
        case NM_Standalone:         S $= "S";   break;
        case NM_DedicatedServer:    S $= "D";   break;
        case NM_ListenServer:       S $= "L";   break;
        case NM_Client:             S $= "C";   break;
    }

    switch( A.Role )
    {
        case ROLE_None:             S $= "N";   break;
        case ROLE_DumbProxy:        S $= "D";   break;
        case ROLE_SimulatedProxy:   S $= "S";   break;
        case ROLE_AutonomousProxy:  S $= "P";   break;
        case ROLE_Authority:        S $= "A";   break;
    }

    switch( A.RemoteRole )
    {
        case ROLE_None:             S $= "N";   break;
        case ROLE_DumbProxy:        S $= "D";   break;
        case ROLE_SimulatedProxy:   S $= "S";   break;
        case ROLE_AutonomousProxy:  S $= "P";   break;
        case ROLE_Authority:        S $= "A";   break;
    }

    return S;
}

DefaultProperties
{

}
