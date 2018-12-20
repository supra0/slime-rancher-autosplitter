state("SlimeRancher", "1.3.2b") {
  bool creditsFlag : "UnityPlayer.dll", 0x147CD50, 0x0, 0x28, 0x30, 0x78, 0x1E8, 0x28, 0x48, 0x49;
  //int gameState : "SlimeRancher.exe", 0x7FFADAE2CD50, 0x10;
  double worldTime : "mono.dll", 0x2685E0, 0xA0, 0x238, 0x0, 0x28, 0x58, 0x30, 0x50;
}

state("SlimeRancher", "1.3.0b") {
  bool creditsFlag : "SlimeRancher.exe", 0x14E4F38, 0x10, 0x0, 0x20, 0x8, 0x10, 0x28, 0x58, 0x49;
  //int gameState : "SlimeRancher.exe", 0x141D330;
  double worldTime : "SlimeRancher.exe", 0x14C9910, 0x8, 0xF8, 0x28, 0x48, 0xA8, 0x70;
}

init {
  //print("Module size: " + modules.First().ModuleMemorySize);
  switch(modules.First().ModuleMemorySize) {
    case 0x1718000:
      version = "1.3.0b";
      break;
    case 0xA4000:
      version = "1.3.2b";
      break;
    default:
      print("Game version either not detected or not supported");
      break;
  }
}

start {
  return current.worldTime >= 32403 //check if time has moved  (set to roughly .03 seconds after initial world time on new file)
  && old.worldTime < current.worldTime //make sure time is moving
  && current.worldTime < 32460; //prevent starting on non-new files

  //NOTE: initial time is 32400, increases by approx. 60 every second (in-game minute)
}

split {
  return old.creditsFlag && !current.creditsFlag; //credits flag turns off upon returning to ranch
}
