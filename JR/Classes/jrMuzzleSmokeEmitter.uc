// ============================================================================
//  jrMuzzleSmokeEmitter.uc ::
// ============================================================================
class jrMuzzleSmokeEmitter extends jrTriggeredEmitter;



DefaultProperties
{
    TriggerMode=TM_Spawn
     bNoDelete=False

    Begin Object Class=SpriteEmitter Name=SpriteEmitter0
        UseColorScale=True
        UseSizeScale=True
        UseRegularSizeScale=False
        UniformSize=True
        UseRandomSubdivision=True
        AutomaticInitialSpawning=False
        RespawnDeadParticles=False
        UseVelocityScale=True
        ColorScale(1)=(RelativeTime=0.100000,Color=(B=255,G=255,R=255))
        ColorScale(2)=(RelativeTime=0.300000,Color=(B=64,G=64,R=64))
        ColorScale(3)=(RelativeTime=0.896429,Color=(B=32,G=32,R=32))
        ColorScale(4)=(RelativeTime=1.000000)
        Opacity=0.1
        UseRotationFrom=PTRS_Actor
        SizeScale(1)=(RelativeTime=0.310000,RelativeSize=0.100000)
        SizeScale(2)=(RelativeTime=0.640000,RelativeSize=0.330000)
        SizeScale(3)=(RelativeTime=1.000000,RelativeSize=1.000000)
        Texture=Texture'EmitterTextures.MultiFrame.smokepcl'
        TextureUSubdivisions=4
        TextureVSubdivisions=4
        LifetimeRange=(Min=0.500000,Max=0.500000)
        StartVelocityRange=(X=(Min=100.000000,Max=100.000000))
        VelocityScale(0)=(RelativeVelocity=(X=4.000000,Y=4.000000,Z=4.000000))
        VelocityScale(1)=(RelativeTime=0.660000,RelativeVelocity=(X=2.000000,Y=2.000000,Z=2.000000))
        VelocityScale(2)=(RelativeTime=1.000000,RelativeVelocity=(X=1.000000,Y=1.000000,Z=1.000000))
    End Object
    Emitters(0)=SpriteEmitter'SpriteEmitter0'
}
