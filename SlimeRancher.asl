state("SlimeRancher", "1.4.1c") {
	int gameMode         : "UnityPlayer.dll", 0x163AF50, 0x8, 0x170, 0x28, 0x40, 0x88, 0x124;
	int keys             : "UnityPlayer.dll", 0x163AF50, 0x8, 0x210, 0x28, 0x48, 0x30, 0x38, 0x90;
	bool readyForCredits : "UnityPlayer.dll", 0x163AF50, 0x8, 0x210, 0x28, 0x48, 0x49;
	double worldTime     : "UnityPlayer.dll", 0x163AF50, 0x8, 0x210, 0x28, 0x60, 0x50;
}

state("SlimeRancher", "1.4.2") {
	int gameMode         : "UnityPlayer.dll", 0x168EEA0, 0x8, 0x170, 0x28, 0x40, 0x88, 0x124;
	int keys             : "UnityPlayer.dll", 0x168EEA0, 0x8, 0x210, 0x28, 0x48, 0x30, 0x38, 0x90;
	bool readyForCredits : "UnityPlayer.dll", 0x168EEA0, 0x8, 0x210, 0x28, 0x48, 0x49;
	double worldTime     : "UnityPlayer.dll", 0x168EEA0, 0x8, 0x210, 0x28, 0x60, 0x50;
}

state("SlimeRancher", "1.4.3b") {
	int gameMode         : "UnityPlayer.dll", 0x17C5508, 0x8, 0x170, 0x28, 0x40, 0x88, 0x124;
	int keys             : "UnityPlayer.dll", 0x17C5508, 0x8, 0x210, 0x28, 0x48, 0x30, 0x38, 0x90;
	bool readyForCredits : "UnityPlayer.dll", 0x17C5508, 0x8, 0x210, 0x28, 0x48, 0x49;
	double worldTime     : "UnityPlayer.dll", 0x17C5508, 0x8, 0x210, 0x28, 0x60, 0x50;
}

state("SlimeRancher", "1.4.4") {
	int gameMode         : "UnityPlayer.dll", 0x17E1BD8, 0x8, 0x170, 0x28, 0x40, 0x88, 0x124;
	int keys             : "UnityPlayer.dll", 0x17E1BD8, 0x8, 0x210, 0x28, 0x48, 0x30, 0x38, 0x90;
	bool readyForCredits : "UnityPlayer.dll", 0x17E1BD8, 0x8, 0x210, 0x28, 0x48, 0x49;
	double worldTime     : "UnityPlayer.dll", 0x17E1BD8, 0x8, 0x210, 0x28, 0x60, 0x50;
}

startup {
	vars.thisGordo = new Dictionary<int, string> {
		{0x5, "Pink Gordo (Main)"},
		{0x8, "Pink Gordo (Ring Island)"},
		{0xB, "Phosphor Gordo"},
		{0x6, "Tabby Gordo (Reef)"},
		{0x2, "Tabby Gordo (Beach)"},
		{0xA, "Honey Gordo"},
		{0x4, "Hunter Gordo"},
		{0x1, "Rock Gordo (Cave)"},
		{0x7, "Rock Gordo (Ash Isle)"},
		{0xC, "Rad Gordo"},
		{0x9, "Crystal Gordo"},
		{0x3, "Quantum Gordo"},
		{0xE, "Boom Gordo"},
		{0x0, "Mosaic Gordo"},
		{0xD, "Tangle Gordo"},
		{0xF, "Dervish Gordo"}
	};

	settings.Add("gordoSplits", true, "Split when popping a Gordo:");
	settings.Add("gateSplits", false, "Split when using a key on a gate");

	foreach (var g in vars.thisGordo)
		settings.Add(g.Value, true, g.Value, "gordoSplits");
}

init {
	// MD5 code by CptBrian.
	string MD5Hash;
	using (var md5 = System.Security.Cryptography.MD5.Create())
		using (var s = File.Open(modules.First().FileName, FileMode.Open, FileAccess.Read, FileShare.ReadWrite))
			MD5Hash = md5.ComputeHash(s).Select(x => x.ToString("X")).Aggregate((a, b) => a + b);
	print("MD5Hash: " + MD5Hash);

	int gordoOffset = 0;
	switch(MD5Hash) {
		case "D7C5A3D642348A1C4661C69B51971D"  : version = "1.4.1c"; gordoOffset = 0x163AF50; break;
		case "A82CBDAD4AA16341D436FF8F24788DC7": version = "1.4.2"; gordoOffset = 0x168EEA0; break;
		case "2A7939BF3AB02090C36BD8BDA037E9E2": version = "1.4.3b"; gordoOffset = 0x17C5508; break;
		case "2E1E312AF04AC4E661319536E01BE05F": version = "1.4.4"; gordoOffset = 0x17E1BD8; break;
		default: version = "Undetected!"; break;
	}

	vars.gordoWatchers = new MemoryWatcherList();
	for (int i = 0; i <= 0xF; ++i) {
		var ptr = new DeepPointer("UnityPlayer.dll", gordoOffset, 0x8, 0x170, 0x28, 0x40, 0x88, 0x30, 0x18, 0x30 + i * 0x18, 0x20);
		vars.gordoWatchers.Add(new MemoryWatcher<int>(ptr) {Name = vars.thisGordo[i]});
	}
}

start {
	return
		old.worldTime < current.worldTime &&
		current.worldTime >= 32402 &&
		current.worldTime < 32410;
}

split {
	if (current.gameMode != 3) {
		print("gameMode: " + current.gameMode);
		vars.gordoWatchers.UpdateAll(game);

		for (int i = 0; i <= 0xF; ++i) {
			string name = vars.thisGordo[i];
			if (vars.gordoWatchers[name].Changed) {
				int eatOld = vars.gordoWatchers[name].Old;
				int eatCurr = vars.gordoWatchers[name].Current;
				return eatOld > 0 && eatCurr == -1 && settings[name];
			}
		}
	}
	
	print("gameMode: " + current.gameMode);

	return current.worldTime > 32400 && (
		old.keys > current.keys && settings["gateSplits"] ||
		old.readyForCredits && !current.readyForCredits
	);
}

reset {
	return current.worldTime == 32400;
}
