// ============================================================================
//  jrMapListLoader.uc ::
// ============================================================================
//  Copyright 2006 Jurassic Rage team. All Rights Reserved.
//  http://www.jurassic-rage.com
// ============================================================================
class jrMapListLoader extends DefaultMapListLoader;


function LoadFromPreFix(string Prefix, xVotingHandler VotingHandler)
{
    local string FirstMap,NextMap,MapName,TestMap;
    local int z;

    FirstMap = Level.GetMapName(PreFix, "", 0);
    NextMap = FirstMap;
    while(!(FirstMap ~= TestMap))
    {
        MapName = NextMap;
        z = InStr(Caps(MapName), ".UT2");
        if(z != -1)
         MapName = Left(MapName, z);  // remove ".UT2"

        if( !class'jrMapFilter'.static.IsIncompatible(MapName) )
            VotingHandler.AddMap(MapName, "", "");

        NextMap = Level.GetMapName(PreFix, NextMap, 1);
        TestMap = NextMap;
    }
}


//------------------------------------------------------------------------------------------------
function LoadFromMapList(string MapListType, xVotingHandler VotingHandler)
{
   local string Mutators,GameOptions;
   local class<MapList> MapListClass;
   local string MapName;
   local array<string> Parts;
   local array<string> Maps;
   local int z,x,p,i;

   MapListClass = class<MapList>(DynamicLoadObject(MapListType, class'Class'));
   if(MapListClass == none)
   {
      Log("___Couldn't load maplist type:"$MaplistType,'MapVote');
      return;
   }

   Maps = MapListClass.static.StaticGetMaps();
   for(i=0;i<Maps.Length;i++)
   {
      Mutators = "";
      GameOptions = "";

      MapName = Maps[i];

      // Parse map string incase there are mutator and game options in it
      // DOM-Aztec?Game=XGame.xDoubleDom?mutator=XGame.MutVampire,UTSecure.MutUTSecure?WeaponStay=True?Translocator=True?TimeLimit=15
      // p0       | p1                  | p2                                          | p3            | p4              | p5
      Parts.Length = 0;
      p = Split(MapName, "?", Parts);
      if(p > 1)
      {
         MapName = Parts[0];
         for(x=1;x<Parts.Length;x++)
         {
            if(left(Parts[x],8) ~= "mutator=")
            {
               Mutators = Mid(Parts[x],8);
            }
            else
            {
               // ignore the "game" option but add all others to GameOptions
               if(!(left(Parts[x],5) ~= "Game="))
               {
                  if(GameOptions == "")
                     GameOptions = Parts[x];
                  else
                     GameOptions = GameOptions $ "?" $ Parts[x];
               }
            }
         }
      }

      z = InStr(Caps(MapName), ".UT2");
      if(z != -1)
         MapName = Left(MapName, z);  // remove ".UT2"

    if( !class'jrMapFilter'.static.IsIncompatible(MapName) )
        VotingHandler.AddMap(MapName, Mutators, GameOptions);
    }
}

DefaultProperties
{

}
