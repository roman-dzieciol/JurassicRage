// ============================================================================
//  jrMapFilter.uc ::
// ============================================================================
//  Copyright 2006 Jurassic Rage team. All Rights Reserved.
//  http://www.jurassic-rage.com
// ============================================================================
class jrMapFilter extends jrObject
    config;

var globalconfig array<string> Maps;
var globalconfig array<string> Prefix;


static function bool IsIncompatible( string MapName )
{
    local int i;

    for( i=0; i!=default.Maps.Length; ++i )
    {
        if( InStr(Caps(MapName),Caps(default.Maps[i])) != -1 )
            return true;
    }

    for( i=0; i!=default.Prefix.Length; ++i )
    {
        if( Left(Caps(MapName),Len(default.Prefix[i])) == Caps(default.Prefix[i]) )
            break;
    }

    if( i == default.Prefix.Length && i != 0 )
        return true;

    return false;
}

DefaultProperties
{

}
