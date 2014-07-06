// ============================================================================
//  jrMessageEX.uc ::
// ============================================================================
//  Copyright 2006 Jurassic Rage team. All Rights Reserved.
//  http://www.jurassic-rage.com
// ============================================================================
class jrMessageEX extends CriticalEventPlus;

var(Message) localized string OutMessage;

//
// Messages common to GameInfo derivatives.
//
static function string GetString(
    optional int Switch,
    optional PlayerReplicationInfo RelatedPRI_1,
    optional PlayerReplicationInfo RelatedPRI_2,
    optional Object OptionalObject
    )
{
    switch (Switch)
    {
        case 1:
            return RelatedPRI_1.PlayerName@Default.OutMessage;
            break;
    }
    return "";
}

DefaultProperties
{

    OutMessage="is OUT!"

    bIsUnique=True

    FontSize=1

    StackMode=SM_Down
    PosY=0.65
}
