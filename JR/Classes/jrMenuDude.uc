// ============================================================================
//  jrMenuDude.uc ::
// ============================================================================
//  Copyright 2006 Jurassic Rage team. All Rights Reserved.
//  http://www.jurassic-rage.com
// ============================================================================
class jrMenuDude extends SpinnyWeap;

var name IdleAnim;


event AnimEnd( int Channel )
{
    PlayAnim(IdleAnim, 1.0/Level.TimeDilation, 0.25/Level.TimeDilation);
}

function PlayNextAnim()
{
    local int i;

    if( Mesh == None || default.AnimNames.Length == 0 )
        return;

    if( AnimNames.Length == 0 )
        AnimNames = default.AnimNames;

    i = Rand(AnimNames.Length);
    PlayAnim(AnimNames[i], 1.0/Level.TimeDilation, 0.25/Level.TimeDilation);
    AnimNames.Remove(i,1);

    NextAnimTime = CurrentTime + AnimChangeInterval;
}

DefaultProperties
{
    AnimChangeInterval      = 3.0
    LODBias                 = 1000000
    bPlayCrouches           = true
    bPlayRandomAnims        = true

    IdleAnim                = "Idle_Rest"

    AnimNames(0)            = "Idle_Rest"
    AnimNames(1)            = "Crouch"
    AnimNames(2)            = "asssmack"
    AnimNames(3)            = "pthrust"
    AnimNames(4)            = "throatcut"
    AnimNames(5)            = "gesture_halt"
    AnimNames(6)            = "gesture_point"
    AnimNames(7)            = "gesture_beckon"
    AnimNames(8)            = "gesture_cheer"
    AnimNames(9)            = "Specific_1"
    AnimNames(10)           = "Idle_Character02"
    AnimNames(11)           = "Idle_Character03"
    AnimNames(12)           = "Gesture_Taunt01"
    AnimNames(13)           = "Gesture_Taunt02"
    AnimNames(14)           = "Gesture_Taunt03"
    AnimNames(15)           = "Idle_Chat"
}
