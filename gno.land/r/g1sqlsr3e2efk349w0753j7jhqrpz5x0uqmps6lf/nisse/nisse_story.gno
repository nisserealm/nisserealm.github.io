package nisse

import "strconv"

type TileStoryBinding struct {
	StoryID   string
	StoryPath string
	Title     string
	Theme     string
}

type StoryEndingProfile struct {
	FinalDigit     string
	BaseChance     uint64
	LevelGain      uint64
	CompanionKind  string
	SuccessTitle   string
	SuccessBody    string
	FailureTitle   string
	FailureBody    string
}

type StoryRuleSet struct {
	BonusPattern string
	BonusPerStep uint64
	Endings      map[string]*StoryEndingProfile
}

type StoryResult struct {
	StoryID           string
	StoryTitle        string
	PathCode          string
	OutcomeTier       uint64
	LevelGain         uint64
	GrantedReindeer   bool
	GrantedCompanion  string
	Place             string
	Turn              uint64
	PatternMatches    uint64
	BonusPercent      uint64
	SuccessChance     uint64
	Roll              uint64
	Title             string
	Body              string
}

var tileStoryBindings map[string]*TileStoryBinding
var storyRuleSets map[string]*StoryRuleSet
var latestStoryResults map[string]*StoryResult

type RotatingStoryDefinition struct {
	StoryID   string
	StoryPath string
	Title     string
	Theme     string
}

var easternForestRotatingStories []*RotatingStoryDefinition
var easternFarmRotatingStories []*RotatingStoryDefinition
var westernFarmRotatingStories []*RotatingStoryDefinition

func init() {
	tileStoryBindings = make(map[string]*TileStoryBinding)
	storyRuleSets = make(map[string]*StoryRuleSet)
	latestStoryResults = make(map[string]*StoryResult)
	easternForestRotatingStories = []*RotatingStoryDefinition{
		{StoryID: "deepforest", StoryPath: "/stories/deepforest/story.json", Title: "Deep Forest", Theme: "forest"},
		{StoryID: "nightforest", StoryPath: "/stories/nightforest/story.json", Title: "Night Forest", Theme: "forest"},
		{StoryID: "hotforest", StoryPath: "/stories/hotforest/story.json", Title: "Hot Forest", Theme: "forest"},
	}
	easternFarmRotatingStories = []*RotatingStoryDefinition{
		{StoryID: "dayfarm", StoryPath: "/stories/dayfarm/story.json", Title: "Day Farm", Theme: "farm"},
		{StoryID: "nightfarm", StoryPath: "/stories/nightfarm/story.json", Title: "Night Farm", Theme: "farm"},
	}
	westernFarmRotatingStories = []*RotatingStoryDefinition{
		{StoryID: "warmdayfarm", StoryPath: "/stories/warmdayfarm/story.json", Title: "Warm Day Farm", Theme: "farm"},
	}

	bindTileStory(12, 3, "benevolentmonk", "", "Benevolent Monk", "monastery")
	bindTileStory(15, 4, "reindeer", "/stories/reindeer/story.json", "Reindeer", "hills")
	bindTileStory(9, 4, "goblinknot", "", "Goblin Knot", "mountain")
	bindTileStory(6, 5, "ashdrake", "", "Ash Drake", "mountain")
	bindTileStory(8, 5, "hilltroll", "", "Hill Troll", "mountain")

	storyRuleSets["reindeer"] = &StoryRuleSet{
		BonusPattern: "121",
		BonusPerStep: 6,
		Endings: map[string]*StoryEndingProfile{
			"1": {
				FinalDigit:     "1",
				BaseChance:     46,
				LevelGain:      1,
				CompanionKind:  "reindeer",
				SuccessTitle:   "Lumi chooses your road",
				SuccessBody:    "The old herder studies you for a long moment, then nods. Lumi lowers her head, steps close, and decides your road is one she is willing to share.",
				FailureTitle:   "A promise kept for another winter",
				FailureBody:    "The old herder smiles sadly and says Lumi is not ready to leave him yet. Even so, he shares a little of the old song and sends you away with warmer courage.",
			},
			"2": {
				FinalDigit:    "2",
				BaseChance:    52,
				LevelGain:     1,
				CompanionKind: "reindeer",
				SuccessTitle:  "Kindness circles back",
				SuccessBody:   "You share what small comfort and patience you can. The old herder presses a small silver charm into your hand in return and blesses your road.",
				FailureTitle:  "A quiet gift left in the snow",
				FailureBody:   "You leave what you can and ask for nothing back. The old herder thanks you with the kind of warmth that stays longer than trade.",
			},
			"3": {
				FinalDigit:     "3",
				BaseChance:     58,
				LevelGain:      1,
				CompanionKind:  "reindeer",
				SuccessTitle:   "A warm night under old songs",
				SuccessBody:    "You stay, mend the fire, and hear the old songs all the way through. By morning the snow feels lighter, and Lumi noses your mitten as if the choice has already been made.",
				FailureTitle:   "The snow keeps the song",
				FailureBody:    "You stay the night and help as best you can. Lumi does not leave with you, but the old herder gives you a blessing and a memory bright enough to outlast the cold.",
			},
		},
	}
	storyRuleSets["dayfarm"] = &StoryRuleSet{
		BonusPattern: "121",
		BonusPerStep: 6,
		Endings: map[string]*StoryEndingProfile{
			"1": {FinalDigit: "1", BaseChance: 52, LevelGain: 1, CompanionKind: "dog", SuccessTitle: "A dog chooses the road", SuccessBody: "", FailureTitle: "The road keeps its silence", FailureBody: ""},
			"2": {FinalDigit: "2", BaseChance: 44, LevelGain: 1, CompanionKind: "donkey", SuccessTitle: "A donkey chooses the road", SuccessBody: "", FailureTitle: "The road keeps its silence", FailureBody: ""},
			"3": {FinalDigit: "3", BaseChance: 58, LevelGain: 1, CompanionKind: "mule", SuccessTitle: "A mule chooses the road", SuccessBody: "", FailureTitle: "The road keeps its silence", FailureBody: ""},
		},
	}
	storyRuleSets["nightfarm"] = &StoryRuleSet{
		BonusPattern: "121",
		BonusPerStep: 6,
		Endings: map[string]*StoryEndingProfile{
			"1": {FinalDigit: "1", BaseChance: 52, LevelGain: 1, CompanionKind: "dog", SuccessTitle: "A dog chooses the road", SuccessBody: "", FailureTitle: "The road keeps its silence", FailureBody: ""},
			"2": {FinalDigit: "2", BaseChance: 44, LevelGain: 1, CompanionKind: "donkey", SuccessTitle: "A donkey chooses the road", SuccessBody: "", FailureTitle: "The road keeps its silence", FailureBody: ""},
			"3": {FinalDigit: "3", BaseChance: 58, LevelGain: 1, CompanionKind: "mule", SuccessTitle: "A mule chooses the road", SuccessBody: "", FailureTitle: "The road keeps its silence", FailureBody: ""},
		},
	}
	storyRuleSets["warmdayfarm"] = &StoryRuleSet{
		BonusPattern: "121",
		BonusPerStep: 6,
		Endings: map[string]*StoryEndingProfile{
			"1": {FinalDigit: "1", BaseChance: 52, LevelGain: 1, CompanionKind: "dog", SuccessTitle: "A dog chooses the road", SuccessBody: "", FailureTitle: "The road keeps its silence", FailureBody: ""},
			"2": {FinalDigit: "2", BaseChance: 44, LevelGain: 1, CompanionKind: "donkey", SuccessTitle: "A donkey chooses the road", SuccessBody: "", FailureTitle: "The road keeps its silence", FailureBody: ""},
			"3": {FinalDigit: "3", BaseChance: 58, LevelGain: 1, CompanionKind: "mule", SuccessTitle: "A mule chooses the road", SuccessBody: "", FailureTitle: "The road keeps its silence", FailureBody: ""},
		},
	}
	storyRuleSets["deepforest"] = &StoryRuleSet{
		BonusPattern: "121",
		BonusPerStep: 6,
		Endings: map[string]*StoryEndingProfile{
			"1": {FinalDigit: "1", BaseChance: 52, LevelGain: 1, CompanionKind: "fairy", SuccessTitle: "The deep forest answers", SuccessBody: "", FailureTitle: "The deep forest stays closed", FailureBody: "The deeper path does not open to you today."},
			"2": {FinalDigit: "2", BaseChance: 44, LevelGain: 1, CompanionKind: "deer", SuccessTitle: "The deep forest answers", SuccessBody: "", FailureTitle: "The deep forest stays closed", FailureBody: "The deeper path does not open to you today."},
			"3": {FinalDigit: "3", BaseChance: 58, LevelGain: 1, CompanionKind: "bear", SuccessTitle: "The deep forest answers", SuccessBody: "", FailureTitle: "The deep forest stays closed", FailureBody: "The deeper path does not open to you today."},
		},
	}
	storyRuleSets["nightforest"] = &StoryRuleSet{
		BonusPattern: "121",
		BonusPerStep: 6,
		Endings: map[string]*StoryEndingProfile{
			"1": {FinalDigit: "1", BaseChance: 52, LevelGain: 1, CompanionKind: "deer", SuccessTitle: "The night forest answers", SuccessBody: "", FailureTitle: "The night forest stays closed", FailureBody: "The darker path gives you nothing you can carry away."},
			"2": {FinalDigit: "2", BaseChance: 44, LevelGain: 1, CompanionKind: "owl", SuccessTitle: "The night forest answers", SuccessBody: "", FailureTitle: "The night forest stays closed", FailureBody: "The darker path gives you nothing you can carry away."},
			"3": {FinalDigit: "3", BaseChance: 58, LevelGain: 1, CompanionKind: "tomcat", SuccessTitle: "The night forest answers", SuccessBody: "", FailureTitle: "The night forest stays closed", FailureBody: "The darker path gives you nothing you can carry away."},
		},
	}
	storyRuleSets["hotforest"] = &StoryRuleSet{
		BonusPattern: "121",
		BonusPerStep: 6,
		Endings: map[string]*StoryEndingProfile{
			"1": {FinalDigit: "1", BaseChance: 52, LevelGain: 1, CompanionKind: "squirrel", SuccessTitle: "The hot forest answers", SuccessBody: "", FailureTitle: "The hot forest stays closed", FailureBody: "Heat and resin close over the path before it becomes yours."},
			"2": {FinalDigit: "2", BaseChance: 44, LevelGain: 1, CompanionKind: "porcupine", SuccessTitle: "The hot forest answers", SuccessBody: "", FailureTitle: "The hot forest stays closed", FailureBody: "Heat and resin close over the path before it becomes yours."},
			"3": {FinalDigit: "3", BaseChance: 58, LevelGain: 1, CompanionKind: "wolverine", SuccessTitle: "The hot forest answers", SuccessBody: "", FailureTitle: "The hot forest stays closed", FailureBody: "Heat and resin close over the path before it becomes yours."},
		},
	}
}

func bindTileStory(x uint64, y uint64, storyID string, storyPath string, title string, theme string) {
	tileStoryBindings[tileStoryKey(Position{X: x, Y: y})] = &TileStoryBinding{
		StoryID:   normalizeKey(storyID),
		StoryPath: storyPath,
		Title:     title,
		Theme:     normalizeKey(theme),
	}
}

func tileStoryKey(pos Position) string {
	return strconv.Itoa(int(pos.X)) + "," + strconv.Itoa(int(pos.Y))
}

func storyAttitudeStat(player *Player, attitude string) uint64 {
	switch normalizeArrivalAttitude(attitude) {
	case "bold":
		return player.Boldness
	case "kind":
		return player.Kindness
	default:
		return player.Caution
	}
}

func storyAttitudeStatMod(player *Player, attitude string) int64 {
	return int64(storyAttitudeStat(player, attitude)) - 10
}

func storyImbalancePenalty(player *Player) int64 {
	high := player.Boldness
	low := player.Boldness
	if player.Caution > high {
		high = player.Caution
	}
	if player.Kindness > high {
		high = player.Kindness
	}
	if player.Caution < low {
		low = player.Caution
	}
	if player.Kindness < low {
		low = player.Kindness
	}
	if high <= low {
		return 0
	}
	diff := high - low
	if diff <= 6 {
		return 0
	}
	return int64((diff - 6) / 2)
}

func easternForestStoryTiles() []Position {
	tiles := []Position{}
	for y := uint64(0); y < mapHeight(); y++ {
		for x := uint64(10); x < mapWidth(); x++ {
			if GetTile(x, y) == 3 {
				tiles = append(tiles, Position{X: x, Y: y})
			}
		}
	}
	return tiles
}

func easternFarmStoryTiles() []Position {
	return []Position{
		{X: 13, Y: 5},
		{X: 14, Y: 5},
		{X: 13, Y: 6},
	}
}

func westernFarmStoryTiles() []Position {
	return []Position{
		{X: 5, Y: 4},
		{X: 6, Y: 4},
		{X: 2, Y: 5},
	}
}

func rotatingStoryBindingForPool(pos Position, turn uint64, pool []Position, stories []*RotatingStoryDefinition) *TileStoryBinding {
	if len(pool) == 0 || len(stories) == 0 {
		return nil
	}

	n := uint64(len(pool))
	phase := turn / 2
	for storyIndex, story := range stories {
		slot := (phase + uint64(storyIndex)) % n
		index := (slot*7 + 3) % n
		tile := pool[index]
		if sameTile(tile, pos) {
			return &TileStoryBinding{
				StoryID:   story.StoryID,
				StoryPath: story.StoryPath,
				Title:     story.Title,
				Theme:     story.Theme,
			}
		}
	}

	return nil
}

func rotatingForestStoryBindingAt(pos Position, turn uint64) *TileStoryBinding {
	return rotatingStoryBindingForPool(pos, turn, easternForestStoryTiles(), easternForestRotatingStories)
}

func rotatingFarmStoryBindingAt(pos Position, turn uint64) *TileStoryBinding {
	binding := rotatingStoryBindingForPool(pos, turn, easternFarmStoryTiles(), easternFarmRotatingStories)
	if binding != nil {
		return binding
	}
	return rotatingStoryBindingForPool(pos, turn, westernFarmStoryTiles(), westernFarmRotatingStories)
}

func storyBindingAt(pos Position, turn uint64) *TileStoryBinding {
	binding := tileStoryBindings[tileStoryKey(pos)]
	if binding != nil {
		return binding
	}
	binding = rotatingForestStoryBindingAt(pos, turn)
	if binding != nil {
		return binding
	}
	return rotatingFarmStoryBindingAt(pos, turn)
}

func darkElfBindingForPlayer(playerKey string, pos Position) *TileStoryBinding {
	if !playerHasDarkElfWarning(playerKey) {
		return nil
	}
	if (pos.X == 7 && pos.Y == 6) || (pos.X == 8 && pos.Y == 4) {
		return &TileStoryBinding{
			StoryID:   "darkelves",
			StoryPath: "",
			Title:     "Dark Elves",
			Theme:     "forest",
		}
	}
	return nil
}

func darkElfHomeBinding(pos Position) *TileStoryBinding {
	if (pos.X == 7 && pos.Y == 6) || (pos.X == 8 && pos.Y == 4) {
		return &TileStoryBinding{
			StoryID:   "darkelves",
			StoryPath: "",
			Title:     "Dark Elves",
			Theme:     "forest",
		}
	}
	return nil
}

func storyBindingAtForPlayer(playerKey string, pos Position, turn uint64) *TileStoryBinding {
	if binding := darkElfBindingForPlayer(playerKey, pos); binding != nil {
		return binding
	}
	return storyBindingAt(pos, turn)
}

func DescribeTileStoryBinding(playerName string) string {
	key := normalizeKey(playerName)
	player, ok := players[key]
	if !ok {
		return "StoryID: none"
	}

	return describeTileStoryBindingBlock(key, player)
}

func DescribeTileStoryBindingAt(playerName string, x uint64, y uint64) string {
	key := normalizeKey(playerName)
	player, ok := players[key]
	if !ok {
		return "StoryID: none"
	}
	if !inBounds(x, y) {
		return "StoryID: none"
	}

	binding := storyBindingAtForPlayer(key, Position{X: x, Y: y}, player.Turns)
	if binding == nil {
		return "StoryID: none"
	}

	out := "StoryID: " + binding.StoryID + "\n"
	out += "StoryTitle: " + binding.Title + "\n"
	out += "StoryTheme: " + binding.Theme + "\n"
	out += "StoryPath: " + binding.StoryPath + "\n"
	return out
}

func ListActiveStoryTiles(playerName string) string {
	key := normalizeKey(playerName)
	player, ok := players[key]
	if !ok {
		panic("player not found")
	}

	out := ""
	for y := uint64(0); y < mapHeight(); y++ {
		for x := uint64(0); x < mapWidth(); x++ {
			binding := storyBindingAtForPlayer(key, Position{X: x, Y: y}, player.Turns)
			if binding == nil {
				continue
			}
			out += "- (" + strconv.Itoa(int(x)) + ", " + strconv.Itoa(int(y)) + ") " + binding.StoryID + " | " + binding.Title + "\n"
		}
	}
	if out == "" {
		return "No active story tiles."
	}
	return out
}

func describeTileStoryBindingBlock(playerKey string, player *Player) string {
	binding := storyBindingAtForPlayer(playerKey, player.Pos, player.Turns)
	if binding == nil {
		return ""
	}

	out := "StoryID: " + binding.StoryID + "\n"
	out += "StoryTitle: " + binding.Title + "\n"
	out += "StoryTheme: " + binding.Theme + "\n"
	out += "StoryPath: " + binding.StoryPath + "\n"
	return out
}

func resolveStoryDecisionForPath(key string, player *Player, binding *TileStoryBinding, storyKey string, normalizedPathCode string, preface string, attitude string) string {
	rules := storyRuleSets[storyKey]
	if rules == nil {
		panic("story rules not found")
	}
	if normalizedPathCode == "" {
		panic("story path code required")
	}

	finalDigit := normalizedPathCode[len(normalizedPathCode)-1 : len(normalizedPathCode)]
	ending := rules.Endings[finalDigit]
	if ending == nil {
		panic("unknown story ending")
	}

	advanceEventPlayer(player)
	attitude = normalizeArrivalAttitude(attitude)

	place := placeName(player.Pos)
	matchCount := storyPatternMatches(normalizedPathCode, rules.BonusPattern)
	bonus := matchCount * rules.BonusPerStep
	statMod := storyAttitudeStatMod(player, attitude)
	imbalancePenalty := storyImbalancePenalty(player)
	successChance := uint64(100)

	title := ""
	body := ""
	if preface != "" {
		body += preface
		if preface[len(preface)-1:] != "\n" {
			body += "\n"
		}
	}
	body += "At " + place + ", you commit to the " + binding.Title + " story.\n"
	body += "Path taken: " + normalizedPathCode + "\n"
	body += "Attitude: " + attitude + "\n"
	body += "Pattern matches: " + strconv.Itoa(int(matchCount)) + " against " + rules.BonusPattern + ".\n"
	body += "Resolve bonus: +" + strconv.Itoa(int(bonus)) + "%.\n"
	if statMod != 0 {
		if statMod > 0 {
			body += "Attitude stat shape: +" + strconv.Itoa(int(statMod)) + ".\n"
		} else {
			body += "Attitude stat drag: " + strconv.Itoa(int(statMod)) + ".\n"
		}
	}
	if imbalancePenalty > 0 {
		body += "Imbalance strain: -" + strconv.Itoa(int(imbalancePenalty)) + ".\n"
	}
	grantText := ""
	grantedCompanion := false
	grantedCompanionName := ""
	result := StoryResult{
		StoryID:        binding.StoryID,
		StoryTitle:     binding.Title,
		PathCode:       normalizedPathCode,
		Place:          place,
		Turn:           player.Turns,
		PatternMatches: matchCount,
		BonusPercent:   bonus,
		SuccessChance:  successChance,
		Roll:           0,
	}
	levelGain := ending.LevelGain
	if ending.LevelGain > 0 {
		player.Level += ending.LevelGain
	}
	switch ending.CompanionKind {
	case "reindeer":
		grantText, grantedCompanion, grantedCompanionName = grantSnowReindeerCompanion(key, player)
	case "dog":
		grantText, grantedCompanion, grantedCompanionName = grantSacredDogCompanion(key, player)
	case "donkey":
		grantText, grantedCompanion, grantedCompanionName = grantSacredDonkeyCompanion(key, player)
	case "mule":
		grantText, grantedCompanion, grantedCompanionName = grantSacredMuleCompanion(key, player)
	case "bear":
		grantText, grantedCompanion, grantedCompanionName = grantSacredBearCompanion(key, player)
	case "deer":
		grantText, grantedCompanion, grantedCompanionName = grantSacredDeerCompanion(key, player)
	case "fairy":
		grantText, grantedCompanion, grantedCompanionName = grantSacredFairyCompanion(key, player)
	case "owl":
		grantText, grantedCompanion, grantedCompanionName = grantSacredOwlCompanion(key, player)
	case "tomcat":
		grantText, grantedCompanion, grantedCompanionName = grantSacredTomcatCompanion(key, player)
	case "wolverine":
		grantText, grantedCompanion, grantedCompanionName = grantSacredWolverineCompanion(key, player)
	case "porcupine":
		grantText, grantedCompanion, grantedCompanionName = grantSacredPorcupineCompanion(key, player)
	case "squirrel":
		grantText, grantedCompanion, grantedCompanionName = grantSacredSquirrelCompanion(key, player)
	}
	body += ending.SuccessBody
	if grantText != "" {
		body += "\n" + grantText
	}
	title = ending.SuccessTitle
	outcomeTier := uint64(1)
	if grantedCompanion && len(rules.BonusPattern) > 0 && matchCount >= uint64(len(rules.BonusPattern)) {
		outcomeTier = 3
	}
	createDiaryEntry(key, "story", place, "day", title, body)
	result.OutcomeTier = outcomeTier
	result.LevelGain = levelGain
	result.GrantedReindeer = grantedCompanion
	if grantedCompanion {
		result.GrantedCompanion = grantedCompanionName
	}
	result.Title = title
	result.Body = body
	latestStoryResults[key] = &result
	return title
}

func normalizeArrivalAttitude(value string) string {
	switch normalizeKey(value) {
	case "", "cautious":
		return "cautious"
	case "kind":
		return "kind"
	case "bold":
		return "bold"
	default:
		panic("unknown attitude")
	}
}

func isCompanionStoryID(storyID string) bool {
	switch normalizeKey(storyID) {
	case "reindeer", "dayfarm", "nightfarm", "warmdayfarm", "deepforest", "nightforest", "hotforest":
		return true
	default:
		return false
	}
}

func companionKindForStoryAttitude(storyID string, attitude string) string {
	attitude = normalizeArrivalAttitude(attitude)
	switch normalizeKey(storyID) {
	case "reindeer":
		return "reindeer"
	case "dayfarm", "nightfarm", "warmdayfarm":
		switch attitude {
		case "kind":
			return "dog"
		case "bold":
			return "mule"
		default:
			return "donkey"
		}
	case "deepforest":
		switch attitude {
		case "kind":
			return "fairy"
		case "bold":
			return "bear"
		default:
			return "deer"
		}
	case "nightforest":
		switch attitude {
		case "kind":
			return "deer"
		case "bold":
			return "tomcat"
		default:
			return "owl"
		}
	case "hotforest":
		switch attitude {
		case "kind":
			return "squirrel"
		case "bold":
			return "wolverine"
		default:
			return "porcupine"
		}
	default:
		return ""
	}
}

func playerAlreadyOwnsCompanionStoryKind(playerName string, storyID string, attitude string) bool {
	switch companionKindForStoryAttitude(storyID, attitude) {
	case "reindeer":
		return playerOwnsSnowReindeer(playerName)
	case "dog":
		return playerOwnsSacredDog(playerName)
	case "donkey":
		return playerOwnsSacredDonkey(playerName)
	case "mule":
		return playerOwnsSacredMule(playerName)
	case "bear":
		return playerOwnsSacredBear(playerName)
	case "deer":
		return playerOwnsSacredDeer(playerName)
	case "fairy":
		return playerOwnsSacredFairy(playerName)
	case "owl":
		return playerOwnsSacredOwl(playerName)
	case "tomcat":
		return playerOwnsSacredTomcat(playerName)
	case "wolverine":
		return playerOwnsSacredWolverine(playerName)
	case "porcupine":
		return playerOwnsSacredPorcupine(playerName)
	case "squirrel":
		return playerOwnsSacredSquirrel(playerName)
	default:
		return false
	}
}

func oldHerderPathForAttitude(attitude string) string {
	switch attitude {
	case "kind":
		return "121"
	case "bold":
		return "13"
	default:
		return "12"
	}
}

func resolveArrivalStoryOnEntry(key string, player *Player, attitude string, travelBody string) (bool, string) {
	if binding := darkElfHomeBinding(player.Pos); binding != nil {
		preface := travelBody + "\nAttitude on arrival: " + normalizeArrivalAttitude(attitude) + "."
		title := resolveDarkElvesEncounter(key, player, binding, preface, attitude)
		return true, title
	}
	binding := storyBindingAtForPlayer(key, player.Pos, player.Turns)
	if binding == nil {
		return false, ""
	}
	if binding.StoryID == "hilltroll" {
		preface := travelBody + "\nAttitude on arrival: " + normalizeArrivalAttitude(attitude) + "."
		title := resolveHillTrollEncounter(key, player, binding, preface, attitude)
		return true, title
	}
	if binding.StoryID == "benevolentmonk" {
		preface := travelBody + "\nAttitude on arrival: " + normalizeArrivalAttitude(attitude) + "."
		title := resolveBenevolentMonkEncounter(key, player, binding, preface, attitude)
		return true, title
	}
	if binding.StoryID == "goblinknot" {
		preface := travelBody + "\nAttitude on arrival: " + normalizeArrivalAttitude(attitude) + "."
		title := resolveGoblinEncounter(key, player, binding, preface, attitude)
		return true, title
	}
	if binding.StoryID == "ashdrake" {
		preface := travelBody + "\nAttitude on arrival: " + normalizeArrivalAttitude(attitude) + "."
		title := resolveAshDrakeEncounter(key, player, binding, preface, attitude)
		return true, title
	}
	if binding.StoryID == "darkelves" {
		preface := travelBody + "\nAttitude on arrival: " + normalizeArrivalAttitude(attitude) + "."
		title := resolveDarkElvesEncounter(key, player, binding, preface, attitude)
		return true, title
	}
	if storyRuleSets[binding.StoryID] == nil {
		return false, ""
	}
	attitude = normalizeArrivalAttitude(attitude)
	if isCompanionStoryID(binding.StoryID) && totalCompanions(key) >= 3 {
		return false, ""
	}
	if isCompanionStoryID(binding.StoryID) && playerAlreadyOwnsCompanionStoryKind(player.Name, binding.StoryID, attitude) {
		return false, ""
	}

	preface := travelBody + "\nAttitude on arrival: " + attitude + "."
	pathCode := oldHerderPathForAttitude(attitude)
	title := resolveStoryDecisionForPath(key, player, binding, binding.StoryID, pathCode, preface, attitude)
	return true, title
}

func normalizeStoryPathCode(value string) string {
	out := ""
	for i := 0; i < len(value); i++ {
		ch := value[i]
		if ch >= '0' && ch <= '9' {
			out += string(ch)
		}
	}
	return out
}

func storyPatternMatches(path string, pattern string) uint64 {
	limit := len(path)
	if len(pattern) < limit {
		limit = len(pattern)
	}

	matches := uint64(0)
	for i := 0; i < limit; i++ {
		if path[i] == pattern[i] {
			matches++
		}
	}
	return matches
}

func clampStoryChance(value int64) uint64 {
	if value < 0 {
		return 0
	}
	if value > 99 {
		return 99
	}
	return uint64(value)
}

func grantSnowReindeerCompanion(playerKey string, player *Player) (string, bool, string) {
	if playerOwnsSnowReindeer(player.Name) {
		return "A snow reindeer already knows your step and remains part of your road.", false, ""
	}

	reindeer := nextSacredReindeer()
	if reindeer == nil {
		return "The high herd has already thinned into other roads. No sacred reindeer remains here to choose a new companion.", false, ""
	}

	collection := ensureCompanionCollection(playerKey)
	id := nextCompanionID
	nextCompanionID++
	asset := createAsset("companion", "Snow Reindeer", reindeer.Name, player.Name, player.LineageOwner, player.Turns, player.Pos)
	reindeer.MintedAssetID = asset.ID
	companion := &Companion{
		ID:          id,
		AssetID:     asset.ID,
		OwnerPlayer: player.Name,
		Species: CompanionSpecies{
			Kind:        "land",
			Name:        "Snow Reindeer",
			SpawnWeight: 0,
			Ability:     reindeer.Ability,
			Description: reindeer.Description,
		},
		FoundAt:    player.Pos,
		FoundTurn:  player.Turns,
		Strength:   reindeer.Strength,
		Wisdom:     reindeer.Wisdom,
		Dexterity:  reindeer.Dexterity,
		Skill:      reindeer.Skill,
		Trait:      reindeer.Trait,
		Encounters: 0,
	}
	deriveCompanionAttitudes(companion)
	if playerBagHasRoom(player) {
		collection[id] = companion
		if player.ActiveCompanionID == 0 {
			player.ActiveCompanionID = id
		}
		return reindeer.Name + " the Snow Reindeer bows her head and chooses your road as a companion.", true, asset.DisplayName
	}
	hiddenCompanions[asset.ID] = companion
	storeAssetOnTile(player.Pos, asset.ID, player.Name, player.LineageOwner, player.Turns)
	return reindeer.Name + " the Snow Reindeer bows her head, but your bag is full, so she is hidden here under your mark until you return.", true, asset.DisplayName
}

func DescribeLatestStoryResult(playerName string) string {
	key := normalizeKey(playerName)
	_, ok := players[key]
	if !ok {
		panic("player not found")
	}

	result := latestStoryResults[key]
	if result == nil {
		panic("player has no story results")
	}

	out := "StoryID: " + result.StoryID + "\n"
	out += "StoryTitle: " + result.StoryTitle + "\n"
	out += "PathCode: " + result.PathCode + "\n"
	out += "OutcomeTier: " + strconv.Itoa(int(result.OutcomeTier)) + "\n"
	out += "LevelGain: " + strconv.Itoa(int(result.LevelGain)) + "\n"
	if result.GrantedReindeer {
		out += "GrantedReindeer: yes\n"
	} else {
		out += "GrantedReindeer: no\n"
	}
	out += "GrantedCompanion: " + result.GrantedCompanion + "\n"
	out += "Place: " + result.Place + "\n"
	out += "Turn: " + strconv.Itoa(int(result.Turn)) + "\n"
	out += "PatternMatches: " + strconv.Itoa(int(result.PatternMatches)) + "\n"
	out += "BonusPercent: " + strconv.Itoa(int(result.BonusPercent)) + "\n"
	out += "SuccessChance: " + strconv.Itoa(int(result.SuccessChance)) + "\n"
	out += "Roll: " + strconv.Itoa(int(result.Roll)) + "\n"
	out += "Title: " + result.Title + "\n"
	out += "Body: " + result.Body
	return out
}
