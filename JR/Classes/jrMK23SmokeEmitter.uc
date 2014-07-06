// ============================================================================
//  jrMK23SmokeEmitter.uc ::
// ============================================================================
class jrMK23SmokeEmitter extends jrxEmitter;

var int mNumPerFlash;

simulated function Trigger(Actor Other, Pawn EventInstigator)
{
    mStartParticles += mNumPerFlash;
}

DefaultProperties
{
     //mRegen=False
     mNumPerFlash=1
     mMaxParticles=16
     mDelayRange(1)=0.0
     mLifeRange(0)=0.500000
     mLifeRange(1)=1.500000
     mRegenRange(0)=0.000000
     mRegenRange(1)=0.000000
     mDirDev=(X=0.150000,Y=0.150000,Z=0.150000)
     mPosDev=(X=1.000000,Y=1.000000,Z=1.000000)
     mSpeedRange(0)=50.000000
     mSpeedRange(1)=100.000000
     mRandOrient=True
     mSpinRange(0)=-10.000000
     mSpinRange(1)=10.000000
     mSizeRange(1)=25.000000
     mColorRange(0)=(B=20,G=20,R=20)
     mColorRange(1)=(B=40,G=40,R=40)
     mRandTextures=True
     mNumTileColumns=4
     mNumTileRows=4
     CullDistance=7000.000000
     Skins(0)=Texture'XEffects.EmitSmoke_t'
     ScaleGlow=2.000000
     Style=STY_Translucent

}
