state("SlimeRancher", "1.3.2b") {
  bool creditsFlag : "UnityPlayer.dll", 0x147CD50, 0x0, 0x28, 0x30, 0x78, 0x1E8, 0x28, 0x48, 0x49;
  int gameState : "mono.dll", 0x281B78, 0x80, 0x130, 0x100, 0x8, 0x168, 0x10, 0xE4; //i don't know what this is but it's useful
  int keys : "UnityPlayer.dll", 0x14D4488, 0x50, 0x100, 0x68, 0x18, 0x60, 0x160, 0x70;
  double worldTime : "mono.dll", 0x2685E0, 0xA0, 0x238, 0x0, 0x28, 0x58, 0x30, 0x50;
}

state("SlimeRancher", "1.3.0b") {
  bool creditsFlag : "SlimeRancher.exe", 0x14E4F38, 0x10, 0x0, 0x20, 0x8, 0x10, 0x28, 0x58, 0x49;
  //int gameState : "SlimeRancher.exe", 0x141D330; unused as of now
  //int keys : ""; add support for this later
  double worldTime : "SlimeRancher.exe", 0x14C9910, 0x8, 0xF8, 0x28, 0x48, 0xA8, 0x70;
}

startup {
  // -- SETTINGS --
  settings.Add("key_get", false, "Split upon grabbing a key");
}

init {
  //--Determine game version--//
  switch(modules.First().ModuleMemorySize) {
    case 0x1718000:
      version = "1.3.0b";
      break;
    case 0xA4000:
      version = "1.3.2b";
      break;
    default:
      print("Game version not detected or not supported");
      break;
  }
}

start {
  return current.worldTime < 32460 //prevent starting on non-new files
  && current.gameState == old.gameState-2; //check if player has gained control

  //NOTE: initial time is 32400, increases by approx. 60 every second (in-game minute)
}

split {
  if(old.creditsFlag && !current.creditsFlag) {
    return true;
  }

  if(settings["key_get"] && version == "1.3.2b") {
    if(current.keys == old.keys+1) { //check if a key has been grabbed
      return true;
    }
  }

  return false;
}
