// ============================================================================
//  jrHUDEX.uc ::
// ============================================================================
//  Copyright 2006 Jurassic Rage team. All Rights Reserved.
//  http://www.jurassic-rage.com
// ============================================================================
class jrHUDEX extends jrHUD;

var SpriteWidget AccuracyWidget;

simulated function UpdateTeamHud()
{
    local jrGRIEX GRI;

    GRI = jrGRIEX(PlayerOwner.GameReplicationInfo);
    if( GRI == None )
        return;

    ScoreTeam[0].Value = Min(GRI.PlayersCount, 999);
    ScoreTeam[1].Value = Min(GRI.DinosCount, 999);

    TeamSymbols[0].WidgetTexture = default.TeamSymbols[0].WidgetTexture;
    TeamSymbols[1].WidgetTexture = default.TeamSymbols[1].WidgetTexture;

//    for( i=0; i<2; ++i )
//    {
//        if( GRI.Teams[i] == None )
//            continue;
//
//        TeamSymbols[i].Tints[i] = HudColorTeam[i];
//
//        if( GRI.TeamSymbols[i] != None )
//            TeamSymbols[i].WidgetTexture = GRI.TeamSymbols[i];
//    }
}



simulated function Message( PlayerReplicationInfo PRI, coerce string Msg, name MsgType )
{
    local Class<LocalMessage> LocalMessageClass;

    switch( MsgType )
    {
        case 'Say':
            if ( PRI == None )
                return;
            Msg = PRI.PlayerName$": "$Msg;
            LocalMessageClass = class'SayMessagePlus';
            break;
        case 'TeamSay':
            if ( PRI == None )
                return;
            Msg = PRI.PlayerName$"("$PRI.GetLocationName()$"): "$Msg;
            LocalMessageClass = class'TeamSayMessagePlus';
            break;
        case 'CriticalEvent':
            LocalMessageClass = class'CriticalEventPlus';
            LocalizedMessage( LocalMessageClass, 0, None, None, None, Msg );
            return;
        case 'DeathMessage':
            LocalMessageClass = class'jrDeathMessageEX';
            break;
        default:
            LocalMessageClass = class'StringMessagePlus';
            break;
    }

    AddTextMessage(Msg,LocalMessageClass,PRI);
}


simulated function DrawCrosshair (Canvas C)
{
    local float NormalScale;
    local int i, CurrentCrosshair;
    local float OldScale,OldW, CurrentCrosshairScale, WeaponCrosshairScale;;
    local color CurrentCrosshairColor;
    local SpriteWidget CHtexture, ACtexture;

    if ( PawnOwner.bSpecialCrosshair )
    {
        PawnOwner.SpecialDrawCrosshair( C );
        return;
    }

    if (!bCrosshairShow)
        return;

    if ( bUseCustomWeaponCrosshairs && (PawnOwner != None) && (PawnOwner.Weapon != None) )
    {
        CurrentCrosshair = PawnOwner.Weapon.CustomCrosshair;
        if (CurrentCrosshair == -1 || CurrentCrosshair == Crosshairs.Length)
        {
            CurrentCrosshair = CrosshairStyle;
            CurrentCrosshairColor = CrosshairColor;
            CurrentCrosshairScale = CrosshairScale;
        }
        else
        {
            CurrentCrosshairColor = PawnOwner.Weapon.CustomCrosshairColor;
            CurrentCrosshairScale = PawnOwner.Weapon.CustomCrosshairScale;
            if ( PawnOwner.Weapon.CustomCrosshairTextureName != "" )
            {
                if ( PawnOwner.Weapon.CustomCrosshairTexture == None )
                {
                    PawnOwner.Weapon.CustomCrosshairTexture = Texture(DynamicLoadObject(PawnOwner.Weapon.CustomCrosshairTextureName,class'Texture'));
                    if ( PawnOwner.Weapon.CustomCrosshairTexture == None )
                    {
                        log(PawnOwner.Weapon$" custom crosshair texture not found!");
                        PawnOwner.Weapon.CustomCrosshairTextureName = "";
                    }
                }
                CHTexture = Crosshairs[0];
                CHTexture.WidgetTexture = PawnOwner.Weapon.CustomCrosshairTexture;
            }
        }
    }
    else
    {
        CurrentCrosshair = CrosshairStyle;
        CurrentCrosshairColor = CrosshairColor;
        CurrentCrosshairScale = CrosshairScale;
    }



    OldScale = HudScale;
    HudScale=1;
    OldW = C.ColorModulate.W;

    if( jrWeapon(PawnOwner.Weapon) != None )
    {
        WeaponCrosshairScale = jrWeapon(PawnOwner.Weapon).GetCrosshairScale();
        //CurrentCrosshairScale *= WeaponCrosshairScale;

        ACtexture = AccuracyWidget;
        ACtexture.TextureScale *= CurrentCrosshairScale * WeaponCrosshairScale;

        C.ColorModulate.W = 0.3-0.2*((FClamp(WeaponCrosshairScale,0.5,2.5)-0.5)/2);

        DrawSpriteWidget (C, ACtexture);
    }



    CurrentCrosshair = Clamp(CurrentCrosshair, 0, Crosshairs.Length - 1);

    NormalScale = Crosshairs[CurrentCrosshair].TextureScale;
    if ( CHTexture.WidgetTexture == None )
        CHTexture = Crosshairs[CurrentCrosshair];
    CHTexture.TextureScale *= 0.5 * CurrentCrosshairScale;

    for( i = 0; i < ArrayCount(CHTexture.Tints); i++ )
        CHTexture.Tints[i] = CurrentCrossHairColor;



    if ( LastPickupTime > Level.TimeSeconds - 0.4 )
    {
        if ( LastPickupTime > Level.TimeSeconds - 0.2 )
            CHTexture.TextureScale *= (1 + 5 * (Level.TimeSeconds - LastPickupTime));
        else
            CHTexture.TextureScale *= (1 + 5 * (LastPickupTime + 0.4 - Level.TimeSeconds));
    }


    C.ColorModulate.W = 1;

    DrawSpriteWidget (C, CHTexture);


    C.ColorModulate.W = OldW;
    HudScale=OldScale;
    CHTexture.TextureScale = NormalScale;

    DrawEnemyName(C);
}

DefaultProperties
{
    YouveLostTheMatch="Diseased dinosaurs have escaped!"
    TeamSymbols(0)=(WidgetTexture=Texture'JRTX_Symbols.SecuritySymbol',RenderStyle=STY_Alpha,TextureCoords=(X2=256,Y2=256),TextureScale=0.100000,DrawPivot=DP_UpperRight,PosX=0.500000,OffsetX=-200,OffsetY=45,Tints[0]=(B=100,G=100,R=255,A=200),Tints[1]=(B=32,G=32,R=255,A=200))
    TeamSymbols(1)=(WidgetTexture=Texture'JRTX_Symbols.RaptorSymbol',RenderStyle=STY_Alpha,TextureCoords=(X2=256,Y2=256),TextureScale=0.100000,PosX=0.500000,OffsetX=200,OffsetY=45,Tints[0]=(B=255,G=128,A=200),Tints[1]=(B=255,G=210,R=32,A=200))

    AccuracyWidget=(WidgetTexture=Texture'JRTX_HUD.Crosshair_Accuracy',RenderStyle=STY_Alpha,TextureCoords=(X1=0,X2=64,Y1=0,Y2=64),TextureScale=0.750000,DrawPivot=DP_MiddleMiddle,PosX=0.5,PosY=0.5,OffsetX=0,OffsetY=0,ScaleMode=SM_None,Scale=1.000000,Tints[0]=(B=255,G=255,R=255,A=255),Tints[1]=(B=255,G=255,R=255,A=255))
}
