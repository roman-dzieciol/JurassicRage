// ============================================================================
//  jrSquadTEX.uc ::
// ============================================================================
//  Copyright 2006 Jurassic Rage team. All Rights Reserved.
//  http://www.jurassic-rage.com
// ============================================================================
class jrSquadEX extends jrSquadAI;


// ----------------------------------------------------------------------------

function float AssessThreat( Bot B, Pawn NewThreat, bool bThreatVisible )
{
    if( jrMonster(NewThreat) != None && VSize(NewThreat.Location-B.Pawn.Location) < 1024 )
        return 10000000;
    return super.AssessThreat(B,NewThreat,bThreatVisible);
}

function float ModifyThreat(float current, Pawn NewThreat, bool bThreatVisible, Bot B)
{
    if( jrMonster(NewThreat) == None )
    {
        if( VSize(NewThreat.Location-B.Pawn.Location) < 2048 )
            return current;
        else
            return FMin(current,4);
    }
    else
        return 10000000 - VSize(NewThreat.Location-B.Pawn.Location);
}

function NotifyKilled(Controller Killer, Controller Killed, pawn KilledPawn)
{
    local Bot B;
    local int i;
    local jrMonster P;

    if ( Killed == None )
        return;

    // if teammate killed, no need to update enemy list
    if ( (Team != None) && (Killed.PlayerReplicationInfo != None)
        && (Killed.PlayerReplicationInfo.Team == Team) )
    {
        if ( IsOnSquad(Killed) )
        {
            for ( B=SquadMembers; B!=None; B=B.NextSquadMember )
                if ( (B != Killed) && (B.Pawn != None) )
                {
                    B.SendMessage(None, 'OTHER', B.GetMessageIndex('MANDOWN'), 4, 'TEAM');
                    break;
                }
        }
        return;
    }
    RemoveEnemy(KilledPawn);

    B = Bot(Killer);
    if ( (B != None) && (B.Squad == self) && (B.Enemy == None) && (B.Pawn != None) )
    {
        // if no enemies left, area secure
        for ( i=0; i<8; i++ )
            if ( Enemies[i] != None )
                return;

        ForEach DynamicActors(class'jrMonster',P)
            if ( (P.Health > 0) && VSize(B.Pawn.Location - P.Location) < 3000 )
                return;
        B.SendMessage(None, 'OTHER', 11, 12, 'TEAM');
    }
}

DefaultProperties
{
     CurrentOrders="Freelance"
     GatherThreshold=0.000000
     MaxSquadSize=3
}
