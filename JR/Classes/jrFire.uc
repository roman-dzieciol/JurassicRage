// ============================================================================
//  jrFire.uc ::
// ============================================================================
class jrFire extends WeaponFire;



// - Sounds -------------------------------------------------------------------

var() float FireSoundVolume;
var() float FireSoundRadius;


// - Accuracy -------------------------------------------------------------------

var() float AccuracyWeapon;
var() float AccuracyRecoil;
var() float AccuracyShooter;
var() float AccuracyBase;


// - Bones --------------------------------------------------------------------

var() name BoneEject;
var() name BoneFlash;
var() name BoneSights;
var() name BoneMuzzleSmoke;


// - Effects ------------------------------------------------------------------

var() class<Emitter>    SmokeEffectClass;
var() rotator           SmokeBoneRotator;
var() name              SmokeBone;

var() class<Emitter>    FlashEffectClass;
var() rotator           FlashBoneRotator;
var() name              FlashBone;

var() class<Actor>      ShellActorClass;
var() class<Emitter>    ShellEffectClass;
var() rotator           ShellBoneRotator;
var() name              ShellBone;

var   Emitter           SmokeEffect;
var   Emitter           FlashEffect;
var   Emitter           ShellEffect;




function PlayFiring()
{
    if ( Weapon.Mesh != None )
    {
        if ( FireCount > 0 )
        {
            if ( Weapon.HasAnim(FireLoopAnim) )
            {
                Weapon.PlayAnim(FireLoopAnim, FireLoopAnimRate, 0.0);
            }
            else if ( Weapon.HasAnim(FireAnim) )
            {
                Weapon.PlayAnim(FireAnim, FireAnimRate, TweenTime);
            }
        }
        else if ( Weapon.HasAnim(FireAnim) )
        {
            Weapon.PlayAnim(FireAnim, FireAnimRate, TweenTime);
        }
    }
    Weapon.PlayOwnedSound(FireSound,SLOT_Interact,FireSoundVolume,,FireSoundRadius,Default.FireAnimRate/FireAnimRate,false);
    ClientPlayForceFeedback(FireForce);  // jdf

    FireCount++;
}

simulated function bool AllowFire()
{
    if( jrFirearm(Weapon) != None && !jrFirearm(Weapon).ReloadAllowFire( ThisModeNum ) )
        return false;

    return Weapon.AmmoAmount(ThisModeNum) >= AmmoPerFire;
}




// ============================================================================
// Effects
// ============================================================================

simulated function DestroyEffects()
{
    if( SmokeEffect != None )
        SmokeEffect.Destroy();

    if( FlashEffect != None )
        FlashEffect.Destroy();

    if( ShellEffect != None )
        ShellEffect.Destroy();
}

simulated function InitEffects()
{
    // don't even spawn on server
    if( Level.NetMode == NM_DedicatedServer )
        return;

    if( SmokeEffectClass != None && (SmokeEffect == None || SmokeEffect.bDeleteMe) )
    {
        SmokeEffect = Spawn(SmokeEffectClass);
        if( SmokeEffect != None && SmokeBone != '' )
        {
            Weapon.AttachToBone(SmokeEffect, SmokeBone);
            if( SmokeBoneRotator != rot(0,0,0) )
                Weapon.SetBoneRotation( SmokeBone, SmokeBoneRotator, 0, 1 );
        }
    }

    if( FlashEffectClass != None && (FlashEffect == None || FlashEffect.bDeleteMe) )
    {
        FlashEffect = Spawn(FlashEffectClass);
        if( FlashEffect != None && FlashBone != '' )
        {
            Weapon.AttachToBone(FlashEffect, FlashBone);
            if( FlashBoneRotator != rot(0,0,0) )
                Weapon.SetBoneRotation( FlashBone, FlashBoneRotator, 0, 1 );
        }
    }

    if( ShellEffectClass != None && (ShellEffect == None || ShellEffect.bDeleteMe) )
    {
        ShellEffect = Spawn(ShellEffectClass);
        if( ShellEffect != None && ShellBone != '' )
        {
            if( ShellBoneRotator != rot(0,0,0) )
                Weapon.SetBoneRotation( ShellBone, ShellBoneRotator, 0, 1 );
        }
    }
}

function DrawMuzzleFlash( Canvas C )
{
    // Draw smoke first
    if( SmokeEffect != None && SmokeEffect.Base != Weapon )
    {
        SmokeEffect.SetLocation( Weapon.GetEffectStart() );
        C.DrawActor( SmokeEffect, false, false, Weapon.DisplayFOV );
    }

    if( FlashEffect != None && FlashEffect.Base != Weapon )
    {
        FlashEffect.SetLocation( Weapon.GetEffectStart() );
        C.DrawActor( FlashEffect, false, false, Weapon.DisplayFOV );
    }
}

function FlashMuzzleFlash()
{
    if( Instigator == None || !Instigator.IsFirstPerson() )
        return;

    if( FlashEffect != None )
        FlashEffect.Trigger(Weapon, Instigator);

    if( ShellActorClass != None && Level.DetailMode != DM_Low )
    {
        Spawn(ShellActorClass,Instigator,,Weapon.GetBoneCoords(ShellBone).Origin,Weapon.GetBoneRotation(ShellBone,0));
    }

    if( ShellEffect != None )
    {
        ShellEffect.SetLocation( Weapon.GetBoneCoords(ShellBone).Origin );
        ShellEffect.SetRotation( Weapon.GetBoneRotation(ShellBone,0) );
        ShellEffect.Trigger(Weapon, Instigator);
    }
}

function StartMuzzleSmoke()
{
    if( SmokeEffect != None && Level.DetailMode != DM_Low )
        SmokeEffect.Trigger(Weapon, Instigator);
}

function ShakeView()
{
    //Super.ShakeView();

    if( jrFirearm(Weapon) != None )
        jrFirearm(Weapon).PlayRecoil();
}

simulated final static function GetDistAxes( float Dist, out vector RX, out vector RY, out vector RZ )
{
    local rotator R;
    local vector X,Y,Z;

    GetAxes( rot(1,0,0) * Dist, X,Y,Z );
    R = rot(0,0,1) * 65535 * FRand();
    RX = X>>R;
    RY = Y>>R;
    RZ = Z>>R;
}

// ============================================================================
//  Debug
// ============================================================================
final simulated function xLog ( coerce string s )
{
    Log
    (   "[" $Left("00",2-Len(Level.Second)) $Level.Second $":"
            $Left("000",3-Len(Level.Millisecond)) $Level.Millisecond $"]"
    @   "[" $StrShort(GetStateName()) $"]"
    @   s
    ,   name );
}

final static function nLog ( coerce string s )
{
    Log( s, default.name );
}

final static function string StrShort( coerce string s )
{
    local string r,c;
    local int i,n;

    c = Caps(s);
    n = Len(s);

    for( i=0; i!=n; ++i )
        if( Mid(s,i,1) == Mid(c,i,1) )
            r $= Mid(s,i,1);

    return r;
}

final static operator(112) string # ( coerce string A, coerce string B )
{
    return A @"[" $B $"]";
}

final static function name GON( Object O )
{
    if( O != None ) return O.Name;
    else            return 'None';
}

final simulated function string GPT( string S )
{
    return GetPropertyText(S);
}


function PlayPreFire()
{
    if ( Weapon.Mesh != None && Weapon.HasAnim(PreFireAnim) )
    {
        Weapon.PlayAnim(PreFireAnim, PreFireAnimRate, TweenTime);
    }
}


DefaultProperties
{
    FireSoundVolume             = 4.0
    FireSoundRadius             = 400

    TransientSoundVolume        = 1.000000
    TransientSoundRadius        = 512.000000


    AccuracyWeapon              = 1.0
    AccuracyRecoil              = 1.0
    AccuracyShooter             = 1.0
    AccuracyBase                = 1.0

}
