// ============================================================================
//  jrBot.uc ::
// ============================================================================
//  Copyright 2006 Jurassic Rage team. All Rights Reserved.
//  http://www.jurassic-rage.com
// ============================================================================
class jrBot extends xBot;

var bool bDamagedMessage;


/* YellAt()
Tell idiot to stop shooting me
*/
function YellAt(Pawn Moron)
{
    if ( (Enemy != None) || (FRand() < 0.7) )
        return;

    SendMessage(None, 'FRIENDLYFIRE', 0, 5, 'TEAM');
}

function bool AllowVoiceMessage(name MessageType)
{
    if ( Level.TimeSeconds - OldMessageTime < 3 )
        return false;
    else
        OldMessageTime = Level.TimeSeconds;

    return true;
}

event SeeMonster(Pawn Seen)
{
    if( !Seen.bAmbientCreature )
        SeePlayer(Seen);
}


function damageAttitudeTo(pawn Other, float Damage)
{
    if( jrMonster(Other) != None && Damage > 0 )
    {
        Squad.SetEnemy(self,Other);
    }
}

DefaultProperties
{
    PlayerReplicationInfoClass=class'jrPRIEX'
}
