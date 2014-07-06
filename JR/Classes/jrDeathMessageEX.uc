// ============================================================================
//  jrDeathMessageEX.uc ::
// ============================================================================
//  Copyright 2006 Jurassic Rage team. All Rights Reserved.
//  http://www.jurassic-rage.com
// ============================================================================
class jrDeathMessageEX extends xDeathMessage;



static function ClientReceive(
    PlayerController P,
    optional int Switch,
    optional PlayerReplicationInfo RelatedPRI_1,
    optional PlayerReplicationInfo RelatedPRI_2,
    optional Object OptionalObject
    )
{
    if( Switch == 2 )
    {
        if( RelatedPRI_1 == P.PlayerReplicationInfo
        || (P.PlayerReplicationInfo.bOnlySpectator && Pawn(P.ViewTarget) != None && Pawn(P.ViewTarget).PlayerReplicationInfo == RelatedPRI_1) )
        {
            // check multikills
            if( P.Role == ROLE_Authority )
            {
                // multikills checked already in LogMultiKills()
                if( UnrealPlayer(P).MultiKillLevel > 0 )
                    P.ReceiveLocalizedMessage( class'MultiKillMessage', UnrealPlayer(P).MultiKillLevel );
            }
            else
            {
                if( RelatedPRI_1 != None
                &&  RelatedPRI_1.Team != None
                &&  RelatedPRI_1.Team.TeamIndex == 0
                &&  RelatedPRI_2 == None )
                {
                    if( P.Level.TimeSeconds - UnrealPlayer(P).LastKillTime < 4 )
                    {
                        UnrealPlayer(P).MultiKillLevel++;
                        P.ReceiveLocalizedMessage( class'MultiKillMessage', xPlayer(P).MultiKillLevel );
                    }
                    else
                        UnrealPlayer(P).MultiKillLevel = 0;

                    UnrealPlayer(P).LastKillTime = P.Level.TimeSeconds;
                }
            }
        }
    }
    else
    {
        Super.ClientReceive(P,Switch,RelatedPRI_1,RelatedPRI_2,OptionalObject);
    }
}

DefaultProperties
{
    SomeoneString="a dino"

}
