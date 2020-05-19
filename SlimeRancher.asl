state("SlimeRancher", "1.4.0b") {
    bool creditsFlag: "UnityPlayer.dll", 0x14D4228, 0x8, 0x8, 0x218, 0x28, 0x48, 0x48;
    int keys        : "UnityPlayer.dll", 0x14D4228, 0x8, 0x8, 0x228, 0x28, 0x30, 0x90;
    double worldTime: "UnityPlayer.dll", 0x14D4228, 0x8, 0x8, 0x218, 0x28, 0x60, 0x50;
}

state("SlimeRancher", "1.3.0b") {
    bool creditsFlag: 0x14C9910, 0x0, 0xB8, 0x28, 0x198, 0x150, 0x48;
    //int gameState : 0x141D330;
    //int keys      : ""; requires sig scan
    double worldTime: 0x14C9910, 0x8, 0xF8, 0x28, 0x48, 0xA8, 0x70;
}

startup {
    settings.Add("keysplits", false, "1.4.0b ONLY: Split when collecting a new key in a run (non-specific)");
        settings.Add("key1", false, "Key N° 1", "keysplits");
        settings.Add("key2", false, "Key N° 2", "keysplits");
        settings.Add("key3", false, "Key N° 3", "keysplits");
        settings.Add("key4", false, "Key N° 4", "keysplits");
        settings.Add("key5", false, "Key N° 5", "keysplits");
        settings.Add("key6", false, "Key N° 6", "keysplits");
        settings.Add("key7", false, "Key N° 7", "keysplits");
        settings.Add("key8", false, "Key N° 8", "keysplits");
        settings.Add("key9", false, "Key N° 9", "keysplits");
        settings.Add("key10", false, "Key N° 10", "keysplits");
        settings.Add("key11", false, "Key N° 11", "keysplits");

    settings.Add("gatesplits", false, "1.4.0b ONLY: Split when using a key on a gate");
}

init {
    switch(modules.First().ModuleMemorySize) {
        case 0x1718000:
            version = "1.3.0b";
            break;
        case 0xA4000:
            version = "1.4.0b";
            break;
        default:
            print(">>>>> Game version not detected or not supported.");
            break;
    }

    vars.keysInRun = 0;
}

update {
    if (old.keys < current.keys && version == "1.4.0b") {
        vars.keysInRun++;
        print(">>>> keysInRun has increased to " + vars.keysInRun);
    }
}

start {
    if (old.worldTime < current.worldTime && current.worldTime >= 32401 && current.worldTime < 32410) {
        vars.keysInRun = 0;
        return true;
    }

    //NOTE: initial time is 32400, increases by approx. 60 every second (in-game minute)
}

split {
    if (version == "1.4.0b" && current.worldTime > 32400) {
        return
            old.keys < current.keys && settings["key" + vars.keysInRun.ToString()] ||
            old.keys > current.keys && settings["gatesplits"];
    }

    return current.worldTime > 32400 && old.creditsFlag && !current.creditsFlag;
}
