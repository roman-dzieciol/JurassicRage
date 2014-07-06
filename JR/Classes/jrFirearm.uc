// ============================================================================
//  jrFirearm.uc ::
// ============================================================================
class jrFirearm extends jrWeapon
    abstract
    HideDropDown
    CacheExempt;


var name ReadyAnim;
var name ThreatAnim;


// - Bones --------------------------------------------------------------------

var() name BoneGun;
var() name BoneLHand_IK;
var() name BoneRHand_IK;
var() name BoneLHand;
var() name BoneRHand;
var() name BoneLForearm;
var() name BoneRForearm;
var() name BoneLBicep;
var() name BoneRBicep;
var() name BoneHandsRoot;


// - Procedural Anims ---------------------------------------------------------

var() float DispLHand;
var() float DispLForearm;
var() float DispLBicep;

var() float DispRHand;
var() float DispRForearm;
var() float DispRBicep;

var() float RotLHand;
var() float RotLForearm;
var() float RotLBicep;

var() float RotRHand;
var() float RotRForearm;
var() float RotRBicep;


// - Reloading ----------------------------------------------------------------

enum EReloadState
{
    RS_None,
    RS_Pre,
    RS_Begin,
    RS_Reload,
    RS_Post,
    RS_End
};

var EReloadState ReloadState;

var() float ReloadBeginDuration;
var() float ReloadDuration;
var() float ReloadEndDuration;
var   float ReloadPreDuration;
var   float ReloadPostDuration;
var   float ReloadTime;
var   float ReloadCancelTime;

var() int   ClipSize[2];
var   int   ClipAmmo[2];

var() bool  bReloadOne;
var() bool  bReloadAuto;

var   bool  bReloading;
var   bool  bReloadCancel;
var   bool  bClipEmptyPlayed;

var() sound ReloadBeginSound;
var() sound ReloadSound;
var() sound ReloadEndSound;
var() sound ClipEmptySound;

var() name ReloadBeginAnim;
var() name ReloadAnim;
var() name ReloadEndAnim;

var() float ReloadBeginAnimRate;
var() float ReloadAnimRate;
var() float ReloadEndAnimRate;

var() float PlayClipEmptyDuration;
var() float PlayClipEmptyTime;
var() float PlayClipEmptyRand;


var() float ReloadBeginNoise;
var() float ReloadNoise;
var() float ReloadEndNoise;

var() float ClipEmptyNoise;


// - Sights -------------------------------------------------------------------

var   bool bSights;
var   float PoseTime;
var() float PoseTimeout;


// - Recoil -------------------------------------------------------------------

struct RecoilFrame
{
    var() float     Time;
    var() vector    GLoc;
    var() rotator   GRot;
    var   quat      GQuat;
    var() vector    NLocScale;
    var() rotator   NRotScale;
    var   vector    NLoc;
    var   rotator   NRot;
    var   quat      NQuat;
};

var() array<RecoilFrame> RecoilFrames;

var() bool      bUseRecoil;            // Enable recoil
var() float     RecoilLocScale;   //
var() float     RecoilRotScale;   //
var   float     RecoilTime;         // Last recoil time
var   int       RecoilIndex;        // Last recoil frame index
var   float     RecoilDuration;     //


// - Accuracy -----------------------------------------------------------------

var float AccuracySighted;
var float AccuracyUnsighted;
var float AccuracyBase;

var float FOVAim;
var float FOVThreat;
var float FOVReady;


var float ZoomAim;
var float ZoomThreat;
var float ZoomReady;



// ============================================================================
// Replication
// ============================================================================
replication
{
    // Things the server should send to the client
//    reliable if( bNetDirty && Role == ROLE_Authority )
//        bSights;

    reliable if( !bReloading && Role == ROLE_Authority )
        ClipAmmo;

    // Functions called by server on client
    reliable if( Role == ROLE_Authority )
        ReloadAbortClient
    ,   ReloadBeginClient
    ,   ReloadCancelClient
    ,   ReloadPreClient
    ,   ReloadPostClient
    ,   SightsEnableClient
    ,   SightsDisableClient
    ;

    // Functions called by client on server
    reliable if( Role < ROLE_Authority )
        ReloadServer
    ,   ReloadCancelServer
    ,   ReloadPreServer
    ,   ReloadPostServer
    ;

}


// ============================================================================
//  Lifespan
// ============================================================================

simulated event WeaponTick( float DT )
{
    Super.WeaponTick(DT);

    if( bSights )
    {
        // if player moves too fast goto point pose
        if( VSize(Instigator.Velocity) > Instigator.GroundSpeed * Instigator.WalkingPct * 1.1 )
        {
            SightsDisable();
        }
    }
    else
    {
        // if player moves too fast goto ready pose
        if( PoseTime > 0 )
        {
            if( VSize(Instigator.Velocity) > Instigator.GroundSpeed * Instigator.WalkingPct * 1.1 )
            {
                PoseTime -= DT;
            }

            if( PoseTime <= 0 )
            {
                PlayReady();
            }
        }
    }

    if( bReloading )
    {
        if( ReloadTime <= Level.TimeSeconds )
        {
            if( ReloadState == RS_Begin )
            {
                //xLog( "RS_Begin" #ReloadStatus() );

                // Begin reloading
                ReloadTime = ReloadDuration + Level.TimeSeconds;
                ReloadState = RS_Reload;
                PlayReload();
            }
            else if( ReloadState == RS_Reload )
            {
                //xLog( "RS_Reload" #ReloadStatus() #Eval(ReloadCancelTime == ReloadTime,"CANCEL","") );

                if( bReloadOne )
                {
                    // Load one shell at a time
                    ClipAmmo[0] += 1;

                    if( ClipAmmo[0] < AmmoCharge[0]
                    &&  ClipAmmo[0] < ClipSize[0]
                    &&  ReloadCancelTime != ReloadTime )
                    {
                        ReloadTime = ReloadDuration + Level.TimeSeconds;
                        ReloadState = RS_Reload;
                        PlayReload();

                        if( Instigator.IsLocallyControlled()
                        && (Instigator.Controller.bFire != 0 || Instigator.Controller.bAltFire != 0) )
                        {
                            ReloadCancelServer(0);
                        }
                    }
                    else
                    {
                        if( Level.NetMode == NM_Client )
                        {
                            ReloadTime = ReloadPostDuration + Level.TimeSeconds;
                            ReloadState = RS_Post;
                        }
                        else
                        {
                            ReloadTime = ReloadEndDuration + Level.TimeSeconds;
                            ReloadState = RS_End;
                            PlayReloadEnd();
                        }
                    }
                }
                else
                {
                    // Load clip
                    ClipAmmo[0] = FMin( ClipSize[0], AmmoCharge[0] );

                    if( Level.NetMode == NM_Client )
                    {
                        ReloadTime = ReloadPostDuration + Level.TimeSeconds;
                        ReloadState = RS_Post;
                    }
                    else
                    {
                        ReloadTime = ReloadEndDuration + Level.TimeSeconds;
                        ReloadState = RS_End;
                        PlayReloadEnd();
                    }
                }
            }
            else if( ReloadState == RS_Pre )
            {
                //xLog( "RS_Pre" #ReloadStatus() );

                // Reload request was not answered, try again
                ReloadTime = ReloadPreDuration + Level.TimeSeconds;
                ReloadPreServer();
            }
            else if( ReloadState == RS_Post )
            {
                //xLog( "RS_Post" #ReloadStatus() );

                // Reload state was not received, request it explicitly
                ReloadTime = ReloadPostDuration + Level.TimeSeconds;
                ReloadPostServer();
            }
            else if( ReloadState == RS_End )
            {
                //xLog( "RS_End" #ReloadStatus() );

                bReloading = False;
                NetUpdateTime = Level.TimeSeconds - 1;

                // Send reload state to client immediately
                if( Role == ROLE_Authority && !Instigator.IsLocallyControlled() )
                {
                    //xLog( "CALL ReloadPostClient" #ReloadStatus() );
                    ReloadPostClient( 0, ClipAmmo[0], AmmoCharge[0] );
                }
            }
        }
    }
    else
    {
        if( !Instigator.IsHumanControlled() )
        {
            if( Level.TimeSeconds - Instigator.Controller.LastSeenTime > ClipAmmo[0]
            && ClipAmmo[0] < AmmoCharge[0]
            && ClipAmmo[0] < ClipSize[0] )
            {
                Reload();
            }
        }
    }
}


// ============================================================================
//  Accuracy
// ============================================================================

simulated function float GetAccuracy()
{
    if( bSights )
        return AccuracySighted;
    else
        return AccuracyUnsighted;
}

simulated function float GetAccuracyBase()
{
    return AccuracyBase;
}


// ============================================================================
//  Selection
// ============================================================================

simulated function BringUp(optional Weapon PrevWeapon)
{
   local int Mode;

    if ( ClientState == WS_Hidden )
    {
        PlayOwnedSound(SelectSound, SLOT_Interact,,,,, false);
        ClientPlayForceFeedback(SelectForce);  // jdf

        if ( Instigator.IsLocallyControlled() )
        {
            PlayAnim(PutDownAnim, 1, 0.0);
            if ( (Mesh!=None) && HasAnim(SelectAnim) )
                PlayAnim(SelectAnim, SelectAnimRate, BringUpTime);
        }

        ClientState = WS_BringUp;
        SetTimer(BringUpTime, false);
    }
    for (Mode = 0; Mode < NUM_FIRE_MODES; Mode++)
    {
        FireMode[Mode].bIsFiring = false;
        FireMode[Mode].HoldTime = 0.0;
        FireMode[Mode].bServerDelayStartFire = false;
        FireMode[Mode].bServerDelayStopFire = false;
        FireMode[Mode].bInstantStop = false;
    }
       if ( (PrevWeapon != None) && PrevWeapon.HasAmmo() && !PrevWeapon.bNoVoluntarySwitch )
        OldWeapon = PrevWeapon;
    else
        OldWeapon = None;

}

simulated function bool PutDown()
{
    if( bSights )
    {
        SightsDisable();
    }

    if( bReloading )
        return false;

    return Super.PutDown();
}


// ============================================================================
//  Sights
// ============================================================================

simulated function PlayReady()
{
    //xLog("PlayReady");
    PreFireEnable(ThreatAnim);
    FOVDesired = FOVReady;
    SetPlayerFOV(ZoomReady);
    IdleAnim = ReadyAnim;
    PlayIdle();
}

simulated function PlayThreat()
{
    //xLog("PlayThreat");
    PreFireDisable();
    FOVDesired = FOVThreat;
    SetPlayerFOV(ZoomThreat);
    IdleAnim = ThreatAnim;
    PlayIdle();
}

simulated function PlayAim()
{
    //xLog("PlayAim");
    PreFireDisable();
    FOVDesired = FOVAim;
    SetPlayerFOV(ZoomAim);
    IdleAnim = AimAnim;
    PlayIdle();
}

simulated function SightsDisable()
{
    bSights = False;
    PreFireDisable();
    SightsDisableClient();
}

simulated function SightsDisableClient()
{
    bSights = False;
    Instigator.bSpecialCrosshair = False;
    PlayThreat();
}

simulated function SightsEnable()
{
    if( bReloading )
        return;

    bSights = True;
    PoseTime = 0;
    PreFireDisable();
    SightsEnableClient();
}

simulated function SightsEnableClient()
{
    bSights = True;
    Instigator.bSpecialCrosshair = True;
    PoseTime = 0;
    PlayAim();
}

simulated function SightsToggle()
{
    if( bSights )
    {
        SightsDisable();
    }
    else
    {
        SightsEnable();
    }
}



// ============================================================================
// Pawn
// ============================================================================

event UsedBy( Pawn P )
{
    Reload();
}


// ============================================================================
// Reload
// ============================================================================

exec simulated function Reload( optional int Mode )
{
    //xLog( "Reload" #Mode #ReloadStatus() );

    // Client immediately prepares for reload
    if( Level.NetMode == NM_Client )
    {
        // Check local variables
        if( bReloading
        ||  FireMode[0].IsFiring()
        ||  FireMode[1].IsFiring()
        ||  bEndOfRound
        )   return;

        if( bSights )
            SightsDisable();

        // Wait for server response
        bReloading = True;
        ReloadTime = ReloadPreDuration + Level.TimeSeconds;
        ReloadState = RS_Pre;

        ReloadServer(Mode,True);
    }
    else
    {
        ReloadServer(Mode);
    }

}

function ReloadServer( int Mode, optional bool bClientWaiting )
{
    //xLog( "ReloadServer" #Mode #ReloadStatus(Mode) );

    // Mode 1 unsupported
    Mode = 0;

    if( bReloading
    ||  ClipAmmo[Mode] == ClipSize[Mode]
    ||  ClipAmmo[Mode] == AmmoCharge[Mode]
    ||  FireMode[0].IsFiring()
    ||  FireMode[1].IsFiring()
    ||  bEndOfRound )
    {
        // Abort invalid reload
        if( bClientWaiting && Role == ROLE_Authority && !Instigator.IsLocallyControlled() )
            ReloadAbortClient( Mode, ClipAmmo[Mode], AmmoCharge[Mode] );
        return;
    }

    if( bSights )
        SightsDisable();

    if( Role == ROLE_Authority && !Instigator.IsLocallyControlled() )
    {
        if( bClientWaiting )
            ReloadPreClient( Mode, ClipAmmo[0], AmmoCharge[0] );
        else
            ReloadBeginClient( Mode, ClipAmmo[0], AmmoCharge[0] );
    }

    ReloadBegin(Mode);
}

simulated function ReloadAbortClient( int Mode, int NewClip, int NewAmmo )
{
    //xLog( "ReloadAbortClient" #Mode #ReloadStatus() #(NewClip $"/" $ClipAmmo[Mode]) #(NewAmmo $"/" $AmmoCharge[Mode])  );

    if( bReloading )
    {
        ClipAmmo[Mode] = NewClip;
        //AmmoCharge[Mode] = NewAmmo;

        bReloading = False;
        ReloadState = RS_None;
    }
}


simulated function ReloadBegin( int Mode )
{
    //xLog( "ReloadBegin" #Mode #ReloadStatus() #(FireMode[0].IsFiring() @FireMode[1].IsFiring()) );

    if( FireMode[0].IsFiring() )
    {
        StopFire(0);
    }
    if( FireMode[1].IsFiring() )
    {
        StopFire(1);
    }

    bReloading = True;
    ReloadState = RS_Begin;
    ReloadTime = ReloadBeginDuration + Level.TimeSeconds;
    PlayReloadBegin();
}


function ReloadPreServer()
{
    //xLog( "ReloadPreServer" #ReloadStatus() );

    ReloadServer(0,True);
}

simulated function ReloadBeginClient( int Mode, int NewClip, int NewAmmo )
{
    //xLog( "ReloadBeginClient" #Mode #ReloadStatus() #(NewClip $"/" $ClipAmmo[Mode]) #(NewAmmo $"/" $AmmoCharge[Mode])  );

    ClipAmmo[Mode] = NewClip;
    ReloadBegin(Mode);
}

simulated function ReloadPreClient( int Mode, int NewClip, int NewAmmo )
{
    //xLog( "ReloadPreClient" #Mode #ReloadStatus() #(NewClip $"/" $ClipAmmo[Mode]) #(NewAmmo $"/" $AmmoCharge[Mode])  );

    if( bReloading && ReloadState == RS_Pre )
    {
        ClipAmmo[Mode] = NewClip;
        ReloadBegin(Mode);
    }
}

function ReloadPostServer()
{
    //xLog( "ReloadPostServer" #ReloadStatus() );

    ReloadPostClient( 0, ClipAmmo[0], AmmoCharge[0] );
}

simulated function ReloadPostClient( int Mode, int NewClip, int NewAmmo )
{
    //xLog( "ReloadPostClient" #Mode #ReloadStatus() #(NewClip $"/" $ClipAmmo[Mode]) #(NewAmmo $"/" $AmmoCharge[Mode])  );

    if( bReloading )
    {
        ClipAmmo[Mode] = NewClip;
        ReloadState = RS_End;
        ReloadTime = ReloadEndDuration + Level.TimeSeconds;
        PlayReloadEnd();
    }
}

function ReloadCancelServer( int Mode )
{
    //xLog( "ReloadCancelServer" #Mode #ReloadStatus() );

    if( bReloading && ReloadState == RS_Reload )
    {
        ReloadCancelTime = ReloadTime;
        ReloadCancelClient( 0 );
    }
}

simulated function ReloadCancelClient( int Mode )
{
    //xLog( "ReloadCancelClient" #Mode #ReloadStatus() );

    ReloadCancelTime = ReloadTime;
}

simulated function bool ReloadAllowFire( int Mode )
{
    if( bReloading )
    {
        //xLog( "bReloading in ReloadAllowFire!" #Mode #ReloadStatus() );
        return False;
    }

    if( Mode == 1 )
        return true;

    // No ammo in clip
    if( ClipAmmo[0] == 0 )
    {
        //xLog( "ReloadAllowFire" #Mode #ReloadStatus() );

        if( PlayClipEmptyTime < Level.TimeSeconds )
            PlayClipEmpty();

        //if( Role != ROLE_Authority )
        //    return False;

        if( Bot(Instigator.Controller) != None && AmmoCharge[Mode] > 0 )
        {
            if( FireMode[0].IsFiring() )
            {
                StopFire(0);
            }
            if( FireMode[1].IsFiring() )
            {
                StopFire(1);
            }

            Reload(Mode);
        }

        return False;
    }


    return True;
}

simulated function bool ReloadReadyToFire( int Mode )
{
    //xLog( "ReloadReadyToFire" #Mode #ReloadStatus() );

    if( bReloading )
    {
        //xLog( "bReloading in ReloadReadyToFire!" #Mode #ReloadStatus() #FireMode[0].IsFiring() #FireMode[1].IsFiring() );
        return False;
    }

    if( Mode == 1 )
        return true;

    // No ammo in clip
    if( ClipAmmo[0] == 0 )
    {
        //if( Role != ROLE_Authority )
        //    return False;

        // Have ammo, reload
        if( AmmoCharge[Mode] > 0 )
        {
            //xLog( "ReloadReadyToFire CALL Reload" #Mode #ReloadStatus() );
            Reload(Mode);
        }
        else
        {
        }

        return False;
    }

    return True;
}


// ============================================================================
// Reload Effects
// ============================================================================

simulated function PlayReloadBegin()
{
    if( ReloadBeginNoise != 0 )
        MakeNoise(ReloadBeginNoise);

    if( ReloadBeginSound != None )
        Instigator.PlayOwnedSound(ReloadBeginSound,,2);

    if( HasAnim(ReloadBeginAnim) )
        PlayAnim(ReloadBeginAnim, ReloadBeginAnimRate, 0.0);

    PlayReady();
    PlayAnim(PutDownAnim, 1.0, 0.2);
}

simulated function PlayReload()
{
    if( ReloadNoise != 0 )
        MakeNoise(ReloadNoise);

    if( ReloadSound != None )
        Instigator.PlayOwnedSound(ReloadSound,,2);

    if( HasAnim(ReloadAnim) )
        PlayAnim(ReloadAnim, ReloadAnimRate, 0.0);
}

simulated function PlayReloadEnd()
{
    if( ReloadEndNoise != 0 )
        MakeNoise(ReloadEndNoise);

    if( ReloadEndSound != None )
        Instigator.PlayOwnedSound(ReloadEndSound,,2);

    if( HasAnim(ReloadEndAnim) )
        PlayAnim(ReloadEndAnim, ReloadEndAnimRate, 0.0);

    PlayThreat();
    PlayAnim(IdleAnim, 1.0, 0.2);
}

simulated function PlayClipEmpty()
{
    PlayClipEmptyTime = PlayClipEmptyDuration + PlayClipEmptyRand*FRand() + Level.TimeSeconds;

    if( ClipEmptyNoise != 0 )
        MakeNoise(ClipEmptyNoise);

    if( ClipEmptySound != None )
        Instigator.PlaySound(ClipEmptySound,,2);
}



// ============================================================================
//  Firing
// ============================================================================

event ServerStartFire(byte Mode)
{
    //xLog( "ServerStartFire" #Mode #ReloadStatus()
    //    #FireMode[Mode].bServerDelayStartFire
    //    #FireMode[Mode].bServerDelayStopFire );

    if( bReloading )
        return;

    Super.ServerStartFire(Mode);
    return;
}


simulated function bool ReadyToFire( int Mode )
{
    if( bReloading || !ReloadReadyToFire(Mode) )
    {
        return False;
    }

    //xLog( "ReadyToFire" #Mode #ReloadStatus() );
    return Super.ReadyToFire(Mode);
}


simulated function ContextFire()
{
    SightsToggle();
}

simulated function bool StartFire(int Mode)
{
    //Log("StartFire");
    if( Super.StartFire(Mode) )
    {
        PoseTime = 0;

        if( mode == 0 )
        {
            if( !bSights )
            {
                PlayThreat();
            }
        }

        return true;
    }

    return false;
}

simulated event StopFire(int Mode)
{
    Super.StopFire(Mode);

    if( mode == 0 )
    {
        if( !bSights )
        {
            PoseTime = PoseTimeout;
        }
    }
}


// ============================================================================
//  Ammo
// ============================================================================

simulated function bool ConsumeAmmo(int Mode, float load, optional bool bAmountNeededIsMax)
{
    local int AmountNeeded;

    if( bNoAmmoInstances )
    {
        if ( AmmoClass[0] == AmmoClass[mode] )
            mode = 0;
        AmountNeeded = int(load);
        if (bAmountNeededIsMax && AmmoCharge[mode] < AmountNeeded)
            AmountNeeded = AmmoCharge[mode];

        if (AmmoCharge[mode] < AmountNeeded )
        {
            CheckOutOfAmmo();
            return false;   // Can't do it
        }


        AmmoCharge[mode] -= AmountNeeded;
        ClipAmmo[0] -= AmountNeeded;
        NetUpdateTime = Level.TimeSeconds - 1;

        if (Level.NetMode == NM_StandAlone || Level.NetMode == NM_ListenServer)
            CheckOutOfAmmo();

        return true;
    }

    if( Ammo[Mode] != None )
    {
        return Ammo[Mode].UseAmmo(int(load), bAmountNeededIsMax);
    }

    return true;
}



// ============================================================================
//  Firing
// ============================================================================


simulated function PreFireDisable( optional int mode )
{
    FireMode[Mode].PreFireTime = 0;
    FireMode[Mode].PreFireAnim = '';
}

simulated function PreFireEnable( name AnimName, optional int mode )
{
    FireMode[Mode].PreFireTime = FireMode[Mode].default.PreFireTime;
    FireMode[Mode].PreFireAnim = AnimName;
}


// ============================================================================
//  Attachment
// ============================================================================

simulated function IncrementFlashCount( int Mode )
{
    if( Mode == 1 )
        return;

    Super.IncrementFlashCount(Mode);
}


// ============================================================================
//  Drawing
// ============================================================================

simulated function float GetCrosshairScale()
{
    local float f;

    f += GetAccuracy();
    f += GetAccuracyBase();

    if( jrHuman(Instigator) != None )
        f += jrHuman(Instigator).GetAccuracy();

    return f / 1536;
}

simulated function vector CalcWeaponOffset()
{
    if( bSights )
        return Instigator.EyePosition() + Instigator.WeaponBob(BobAim);
    else if( IdleAnim == ThreatAnim )
        return Instigator.EyePosition() + Instigator.WeaponBob(BobThreat);
    else
        return Instigator.EyePosition() + Instigator.WeaponBob(BobReady);
}

simulated function PreDrawFPWeapon()
{
    local vector VW,VL,VR,VLP,VRP;
    local coords CW,CLP,CRP,CD;
    local rotator RecoilRot;
    local vector RecoilVect;


    if( bUseRecoil )
    {
        // TODO: IK?
        // TODO: SBR() instead of SBD() ?

        // Precache
        CW = GetBoneCoords(BoneGun);
        CLP = GetBoneCoords(BoneLHand_IK);
        CRP = GetBoneCoords(BoneRHand_IK);

        CD = CW;
        CD.Origin = CLP.Origin;
        //DrawAxesCoords(CD,64);

        VW = CW.Origin;
        VLP = CLP.Origin;
        VRP = CRP.Origin;

        VW = VW << Rotation;
        VLP = VLP << Rotation;
        VRP = VRP << Rotation;

        // Calc recoil
        CalcRecoil(RecoilVect,RecoilRot);

        // eh?
        RecoilRot.Pitch *= -1;

        // Apply recoil on gun
        SetBoneDirection(BoneGun,RecoilRot,,1,0);
        //SetBoneRotation(BoneGun,RecoilRot,0,1);
        SetBoneLocation(BoneGun,RecoilVect,1);

        // Adjust hands
        VL = (((VLP - VW) << RecoilRot) - (VLP - VW) >> Rotation);
        VR = (((VRP - VW) << RecoilRot) - (VRP - VW) >> Rotation);

        //SetBoneDirection(BoneLHand,RecoilRot, RotLHand*VL + DispLHand*(RecoilVect >> Rotation), 1,0);
        //SetBoneDirection(BoneRHand,RecoilRot, RotRHand*VR + DispRHand*(RecoilVect >> Rotation), 1,0);

        SetBoneDirection(BoneLHand,RecoilRot,,1,0);
        SetBoneDirection(BoneRHand,RecoilRot,,1,0);

        SetBoneLocation(BoneLHand, RotLHand*(VL << GetBoneRotation(BoneLForearm,0)) + DispLHand*((RecoilVect >> Rotation) << GetBoneRotation(BoneLForearm,0)), 1);
        SetBoneLocation(BoneRHand, RotRHand*(VR << GetBoneRotation(BoneRForearm,0)) + DispRHand*((RecoilVect >> Rotation) << GetBoneRotation(BoneRForearm,0)), 1);

        SetBoneLocation(BoneLForearm, RotLForearm*(VL << GetBoneRotation(BoneLBicep,0)) + DispLForearm*((RecoilVect >> Rotation) << GetBoneRotation(BoneLBicep,0)), 1);
        SetBoneLocation(BoneRForearm, RotRForearm*(VR << GetBoneRotation(BoneRBicep,0)) + DispRForearm*((RecoilVect >> Rotation) << GetBoneRotation(BoneRBicep,0)), 1);

        SetBoneLocation(BoneLBicep, RotLBicep*(VL << GetBoneRotation(BoneHandsRoot,0)) + DispLBicep*((RecoilVect >> Rotation) << GetBoneRotation(BoneHandsRoot,0)), 1);
        SetBoneLocation(BoneRBicep, RotRBicep*(VR << GetBoneRotation(BoneHandsRoot,0)) + DispRBicep*((RecoilVect >> Rotation) << GetBoneRotation(BoneHandsRoot,0)), 1);
     }
}



// ============================================================================
// Recoil
// ============================================================================

simulated function PlayRecoil()
{
    local int i;
    local rotator R, RS;

    RecoilTime = Level.TimeSeconds;
    RecoilIndex = 0;

    for( i=1; i<RecoilFrames.Length-1; ++i )
    {
        RS = RecoilFrames[i].NRotScale;
        R = Normalize(RotRand(true));
        R.Pitch = R.Pitch % RS.Pitch;
        R.Yaw = R.Yaw % RS.Yaw;
        R.Roll = R.Roll % RS.Roll;
        RecoilFrames[i].NLoc = VRand() * RecoilFrames[i].NLocScale * RecoilLocScale;
        RecoilFrames[i].NRot = R * RecoilRotScale;
    }

    for( i=0; i<RecoilFrames.Length; ++i )
    {
        RecoilFrames[i].GQuat = QuatFromRotator(RecoilFrames[i].GRot);
        RecoilFrames[i].NQuat = QuatFromRotator(RecoilFrames[i].NRot);
    }

    RecoilDuration = RecoilFrames[RecoilFrames.Length-1].Time;
}


simulated function CalcRecoil( out vector L, out rotator R )
{
    local int i;
    local float DT,Alpha;
    local RecoilFrame Prev,This;

    DT = Level.TimeSeconds - RecoilTime;
    if( DT <= RecoilDuration )
    {
        for( i=RecoilIndex; i<RecoilFrames.Length; ++i )
        {
            // Time in current item must be equal or greater than DT
            if( RecoilFrames[i].Time >= DT )
            {
                if( i > 0 )
                {
                    RecoilIndex = i;
                    Prev = RecoilFrames[i-1];
                    This = RecoilFrames[i];
                    Alpha = (DT - Prev.Time) / (This.Time - Prev.Time);

                    // TODO: check how PlayerView stuff is applied
                    // RecoilFrames assumes pivot at 0,0,0, gun centered on end sights
                    L += Prev.GLoc + (This.GLoc-Prev.GLoc) * Alpha;
                    R += QuatToRotator(QuatSlerp(Prev.GQuat, This.GQuat, Alpha));

                    // Noise
                    L += Prev.NLoc + (This.NLoc-Prev.NLoc) * Alpha;
                    R += QuatToRotator(QuatSlerp(Prev.NQuat, This.NQuat, Alpha));
                }
                else
                {
                    // with first item containing zero's there's no use for this case
                }
                break;
            }
        }
    }
}


simulated function RecoilInit()
{
}


// ============================================================================
//  Animation
// ============================================================================

simulated function PlayIdle()
{
    if( bReloading )
    {
        return;
    }
    LoopAnim(IdleAnim, IdleAnimRate, IdleAnimTween);
}


// ============================================================================
//  AI
// ============================================================================

function byte BestMode()
{
    return 0;
}


function float SuggestAttackStyle()
{
    local float EnemyDist;

    if( Owner == None
    ||  Instigator == None
    ||  Instigator.Controller == None
    ||  Instigator.Controller.Enemy == None )
        return 0;

    // recommend backing off if target is too close
    EnemyDist = VSize(Instigator.Controller.Enemy.Location - Owner.Location);
    if( EnemyDist < 768 )
    {
        return -1.0;
    }
    else if( EnemyDist > 2048 )
        return 1.0;
    else
        return 0.2;
}


function float SuggestDefenseStyle()
{
    local float EnemyDist;

    if( Owner == None
    ||  Instigator == None
    ||  Instigator.Controller == None
    ||  Instigator.Controller.Enemy == None )
        return 0;

    // recommend backing off if target is too close
    EnemyDist = VSize(Instigator.Controller.Enemy.Location - Owner.Location);
    if( EnemyDist < 1024 )
    {
        return -1.0;
    }
    else if( EnemyDist > 3072 )
        return 1.0;
    else
        return 0.2;
}

// ============================================================================
//  Debug Weapon
// ============================================================================

final simulated function string GetAmmoString( optional int mode )
{
    return ClipAmmo[mode] $"/" $ClipSize[mode] $"/" $AmmoCharge[mode];
}

final simulated function string ReloadStatus( optional int mode )
{
    return Eval(bReloading,"R"," ") $ReloadState @GetAmmoString() @GetNetInfo(Instigator);
}

simulated function DisplayDebug( Canvas C, out float YL, out float YPos )
{
    local string T;
    Super.DisplayDebug( C, YL, YPos );

    C.SetDrawColor(0,255,0);

    T = "RELOAD"
    @"State" @ReloadState
    @"Time" @ReloadTime
    @"Clip" @GetAmmoString()
    @Eval( bReloading, "bReloading", "" )
    @Eval( bReloadCancel, "bReloadCancel", "" );

    YPos += YL;
    C.SetPos(4,YPos);
    C.DrawText(T, false);
}

DefaultProperties
{
    bUseRecoil                  = True
    RecoilLocScale              = 1.0
    RecoilRotScale              = 1.0

    PoseTimeout               = 3

    AccuracyBase                = 256
    AccuracySighted             = 0
    AccuracyUnsighted           = 384


    ThreatAnim                  = "threat"
    ReadyAnim                   = "ready"
    AimAnim                     = "aim"

    FireModeClass(0)            = class'AssaultFire'
    FireModeClass(1)            = class'AssaultFire'


    ReloadBeginDuration         = 0.300000
    ReloadDuration              = 0.600000
    ReloadEndDuration           = 0.400000
    ReloadPreDuration           = 0.750000
    ReloadPostDuration          = 0.750000

    ClipSize(0)                 = 30
    ClipAmmo(0)                 = 30

    ReloadBeginSound            = Sound'WeaponSounds.BaseGunTech.BReload9'
    ReloadEndSound              = Sound'WeaponSounds.BaseGunTech.BReload6'
    ClipEmptySound              = Sound'NewWeaponSounds.Newclickgrenade'

    ReloadBeginAnim             = "PutDown"
    ReloadEndAnim               = ""

    ReloadBeginAnimRate         = 1.000000
    ReloadAnimRate              = 1.000000
    ReloadEndAnimRate           = 1.000000

    PlayClipEmptyDuration       = 0.200000
    PlayClipEmptyRand           = 0.100000

    ReloadNoise                 = 0.100000
    ReloadEndNoise              = 0.100000
    ClipEmptyNoise              = 0.050000

    BoneGun                     = "Bone Gun"
    BoneLHand_IK                = "Bone LHand IK"
    BoneRHand_IK                = "Bone RHand IK"
    BoneLHand                   = "bone_lhand"
    BoneRHand                   = "bone_rhand"
    BoneLForearm                = "bone_lforearm"
    BoneRForearm                = "bone_rforearm"
    BoneLBicep                  = "bone_lbicep"
    BoneRBicep                  = "bone_rbicep"
    BoneHandsRoot               = "root"

    FOVAim = 45
    FOVThreat = 90
    FOVReady = 90

    ZoomAim = 0.5
    ZoomThreat = 0
    ZoomReady = 0


    DispLHand           = 0.5
    DispLForearm        = 0.25
    DispLBicep          = 0.25
    DispRHand           = 0.5
    DispRForearm        = 0.25
    DispRBicep          = 0.25

    RotLHand           = 0.33
    RotLForearm        = 0.33
    RotLBicep          = 0.34
    RotRHand           = 0.33
    RotRForearm        = 0.33
    RotRBicep          = 0.34
}
