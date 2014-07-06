// ============================================================================
//  jrTriggeredEmitter.uc ::
// ============================================================================
class jrTriggeredEmitter extends jrEmitter;

enum ETriggerMode
{
    TM_Default
,   TM_Reset
,   TM_Spawn
};

var() ETriggerMode TriggerMode;
var() int SpawnAmount;

simulated event PostBeginPlay()
{
    local int i;

    //Log( "PostBeginPlay" );
    Super.PostBeginPlay();

    switch( TriggerMode )
    {
        case TM_Reset:
            for( i=0; i!=Emitters.Length; ++i )
            {
                if( Emitters[i] != None )
                {
                    Emitters[i].Disabled = True;
                    Emitters[i].AllParticlesDead = True;
                }
            }
            break;

        case TM_Spawn:
            for( i=0; i!=Emitters.Length; ++i )
            {
                if( Emitters[i] != None )
                {
                    //Emitters[i].AllParticlesDead = True;
                   // Emitters[i].RespawnDeadParticles = True;
                }
            }
            break;

    }
}

simulated event Trigger( Actor Other, Pawn EventInstigator )
{
    local int i;


    switch( TriggerMode )
    {
        case TM_Reset:
            for( i=0; i!=Emitters.Length; ++i )
            {
                if( Emitters[i] != None && !Emitters[i].Backup_Disabled )
                {
                    Emitters[i].AllParticlesDead = False;
                    Emitters[i].Disabled = False;
                    Emitters[i].Reset();
                }
            }
            break;

        case TM_Spawn:
            for( i=0; i!=Emitters.Length; ++i )
            {
                if( Emitters[i] != None && !Emitters[i].Backup_Disabled )
                {
                    //Emitters[i].AllParticlesDead = False;
                    Emitters[i].SpawnParticle(SpawnAmount);
                }
            }
            break;

        default:
            Super.Trigger( Other, EventInstigator );
            break;
    }
}

DefaultProperties
{
    TriggerMode=TM_Reset
    AutoDestroy = False
    SpawnAmount=1
}

