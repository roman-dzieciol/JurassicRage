// ============================================================================
//  jrRecommendedMaps.uc ::
// ============================================================================
//  Copyright 2006 Jurassic Rage team. All Rights Reserved.
//  http://www.jurassic-rage.com
// ============================================================================
class jrRecommendedMaps extends jrObject
    config;

var globalconfig array<string> Maps;

static function bool IsRecommended( string MapName )
{
    local int i;

    for( i=0; i!=default.Maps.Length; ++i )
    {
        if( InStr(Caps(MapName),Caps(default.Maps[i])) != -1 )
            return true;
    }

    return false;
}

DefaultProperties
{

}
