// ============================================================================
//  jrCheatManager.uc ::
// ============================================================================
//  Copyright 2006 Jurassic Rage team. All Rights Reserved.
//  http://www.jurassic-rage.com
// ============================================================================
class jrCheatManager extends CheatManager;


function ReportCheat(optional string cheat)
{
    if( jrGameInfo(Level.Game) != none ) {
        jrGameInfo(Level.Game).ReportCheat(outer, cheat);
    }
}


exec function AllWeapons()
{
    local array<CacheManager.WeaponRecord> L;
    local int i;

    if (!areCheatsEnabled()) return;
    if( (Level.Netmode!=NM_Standalone) || (Pawn == None) || (Vehicle(Pawn) != None) )
        return;

    class'CacheManager'.static.GetWeaponList(L);
    for( i=0; i!=L.Length; ++i )
    {
        if( Caps(Left(L[i].ClassName,2)) == "JR" )
            Pawn.GiveWeapon(L[i].ClassName);
    }

    ReportCheat("AllWeapons");
}



DefaultProperties
{

}
