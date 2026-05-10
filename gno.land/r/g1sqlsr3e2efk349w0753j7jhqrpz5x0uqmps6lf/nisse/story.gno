package nisse

import "strconv"

type TileStoryBinding struct {
	StoryID   string
	StoryPath string
	Title     string
	Theme     string
}

type StoryEndingProfile struct {
	FinalDigit    string
	LevelGain     uint64
	CompanionKind string
	SuccessTitle  string
}

type StoryRuleSet struct {
	Endings map[string]*StoryEndingProfile
}

type StoryResult struct {
	StoryID          string
	StoryTitle       string
	PathCode         string
	OutcomeTier      uint64
	LevelGain        uint64
	EarnedClaimID    string
	EarnedCompanion  string
	GrantedReindeer  bool
	GrantedCompanion string
	Place            string
	Turn             uint64
	PatternMatches   uint64
	BonusPercent     uint64
	Roll             uint64
	Title            string
	Body             string
}

var tileStoryBindings map[string]*TileStoryBinding
var storyRuleSets map[string]*StoryRuleSet
var latestStoryResults map[string]*StoryResult
var storyKinds map[string]string

func mkStorySet(aType string, bType string, cType string, title string) *StoryRuleSet {
	return &StoryRuleSet{
		Endings: map[string]*StoryEndingProfile{
			"1": {FinalDigit: "1", LevelGain: 1, CompanionKind: aType, SuccessTitle: title},
			"2": {FinalDigit: "2", LevelGain: 1, CompanionKind: bType, SuccessTitle: title},
			"3": {FinalDigit: "3", LevelGain: 1, CompanionKind: cType, SuccessTitle: title},
		},
	}
}

func init() {
	tileStoryBindings = make(map[string]*TileStoryBinding)
	storyRuleSets = make(map[string]*StoryRuleSet)
	latestStoryResults = make(map[string]*StoryResult)
	storyKinds = make(map[string]string)

	bindTileStory(12, 3, "benevolentmonk", "", "Benevolent Monk", "monastery")
	bindTileStory(15, 4, "reindeer", "/stories/reindeer/story.json", "Reindeer", "hills")
	bindTileStory(9, 4, "goblinknot", "", "Goblin Knot", "mountain")
	bindTileStory(6, 5, "ashdrake", "", "Ash Drake", "mountain")
	bindTileStory(8, 5, "hilltroll", "", "Hill Troll", "mountain")
	bindStoryAlias(11, 2, "eleventwo1", "deepforest", "/stories/deepforest/story.json", "Deep Forest", "forest")
	bindStoryAlias(12, 2, "twelvetwo1", "nightforest", "/stories/nightforest/story.json", "Night Forest", "forest")
	bindStoryAlias(13, 4, "thirteenfour1", "hotforest", "/stories/hotforest/story.json", "Hot Forest", "forest")
	bindStoryAlias(13, 5, "thirteenfive1", "dayfarm", "/stories/dayfarm/story.json", "Day Farm", "farm")
	bindStoryAlias(14, 5, "fourteenfive1", "nightfarm", "/stories/nightfarm/story.json", "Night Farm", "farm")
	bindStoryAlias(5, 4, "fivefour1", "warmdayfarm", "/stories/warmdayfarm/story.json", "Warm Day Farm", "farm")

	storyRuleSets["reindeer"] = &StoryRuleSet{
		Endings: map[string]*StoryEndingProfile{
			"1": {
				FinalDigit:    "1",
				LevelGain:     1,
				CompanionKind: "reindeer",
				SuccessTitle:  "Lumi chooses your road",
			},
			"2": {
				FinalDigit:    "2",
				LevelGain:     1,
				CompanionKind: "reindeer",
				SuccessTitle:  "Kindness circles back",
			},
			"3": {
				FinalDigit:    "3",
				LevelGain:     1,
				CompanionKind: "reindeer",
				SuccessTitle:  "A warm night under old songs",
			},
		},
	}
	storyRuleSets["dayfarm"] = mkStorySet("dog", "donkey", "mule", "farm_companion")
	storyRuleSets["nightfarm"] = mkStorySet("dog", "donkey", "mule", "farm_companion")
	storyRuleSets["warmdayfarm"] = mkStorySet("dog", "donkey", "mule", "farm_companion")
	storyRuleSets["deepforest"] = mkStorySet("fairy", "deer", "bear", "The deep forest answers")
	storyRuleSets["nightforest"] = mkStorySet("deer", "owl", "tomcat", "The night forest answers")
	storyRuleSets["hotforest"] = mkStorySet("squirrel", "porcupine", "wolverine", "The hot forest answers")
}

func bindTileStory(x uint64, y uint64, storyID string, storyPath string, title string, theme string) {
	tileStoryBindings[tileStoryKey(Position{X: x, Y: y})] = &TileStoryBinding{
		StoryID:   normalizeKey(storyID),
		StoryPath: storyPath,
		Title:     title,
		Theme:     normalizeKey(theme),
	}
}

func bindStoryAlias(x uint64, y uint64, storyID string, kind string, storyPath string, title string, theme string) {
	bindTileStory(x, y, storyID, storyPath, title, theme)
	storyKinds[normalizeKey(storyID)] = normalizeKey(kind)
}

func tileStoryKey(pos Position) string {
	return strconv.Itoa(int(pos.X)) + "," + strconv.Itoa(int(pos.Y))
}

func storyBindingAt(pos Position, _ uint64) *TileStoryBinding {
	return tileStoryBindings[tileStoryKey(pos)]
}

func storyRuleKey(storyID string) string {
	key := normalizeKey(storyID)
	if kind := storyKinds[key]; kind != "" {
		return kind
	}
	return key
}

func darkElfBindingForPlayer(playerKey string, pos Position) *TileStoryBinding {
	if !playerHasDarkElfWarning(playerKey) {
		return nil
	}
	return darkElfHomeBinding(pos)
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
	storyKey = storyRuleKey(storyKey)
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
	roll := d20(player, "story-"+storyKey)
	statKey := resolvePrimaryStatForStory(attitude)
	totals := resolveTotals(player, key, attitude)
	statTotal := resolveStatTotal(totals, statKey)
	target := resolveStoryTarget(storyKey)
	band := encounterBand(int64(roll)+int64(statTotal), int64(target))
	title := ""
	body := ""
	if preface != "" {
		body += preface
		if preface[len(preface)-1:] != "\n" {
			body += "\n"
		}
	}
	body += "Story:" + binding.StoryID + "\n"
	body += "Path:" + normalizedPathCode + "\n"
	body += "Mode:" + attitude + "\n"
	result := StoryResult{
		StoryID:        binding.StoryID,
		StoryTitle:     binding.Title,
		PathCode:       normalizedPathCode,
		Place:          place,
		Turn:           player.Turns,
		PatternMatches: 0,
		BonusPercent:   0,
		Roll:           roll,
	}
	levelGain := ending.LevelGain
	if (band == "triumph" || band == "success") && ending.LevelGain > 0 {
		player.Level += ending.LevelGain
	}
	if band == "triumph" || band == "success" {
		bonusText := grantAttitudeSuccessBonus(player, attitude)
		if ending.CompanionKind != "" {
			result.EarnedClaimID = grantCompanionClaim(key, ending.CompanionKind)
			body += "ClaimType:" + ending.CompanionKind
			body += "\nClaimID:" + result.EarnedClaimID
			result.EarnedCompanion = ending.CompanionKind
		}
		if bonusText != "" {
			body += "\n" + bonusText
		}
		title = ending.SuccessTitle
	} else {
		title = binding.Title + " stays closed"
		if band == "setback" {
			body += "Outcome:setback"
		} else {
			body += "Outcome:ruin"
		}
	}
	body += "\n\nDice:"
	body += "\nD20: " + strconv.Itoa(int(roll))
	body += "\nResolved stat: " + statKey
	body += "\nStat total: +" + strconv.Itoa(int(statTotal))
	body += "\nTarget: " + strconv.Itoa(int(target))
	body += "\nResult: " + band
	outcomeTier := uint64(0)
	if band == "success" {
		outcomeTier = 1
	}
	if band == "triumph" {
		outcomeTier = 3
	}
	createDiaryEntry(key, "story", place, "day", title, body)
	result.OutcomeTier = outcomeTier
	result.LevelGain = levelGain
	result.GrantedReindeer = result.EarnedCompanion == "reindeer"
	result.GrantedCompanion = result.EarnedCompanion
	result.Title = title
	result.Body = body
	latestStoryResults[key] = &result
	return title
}

func resolvePrimaryStatForStory(attitude string) string {
	switch normalizeArrivalAttitude(attitude) {
	case "bold":
		return "bold"
	case "kind":
		return "kind"
	default:
		return "cautious"
	}
}

func resolveStoryTarget(storyID string) uint64 {
	switch storyRuleKey(storyID) {
	case "reindeer":
		return 30
	default:
		return 34
	}
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
	switch storyRuleKey(storyID) {
	case "reindeer", "dayfarm", "nightfarm", "warmdayfarm", "deepforest", "nightforest", "hotforest":
		return true
	default:
		return false
	}
}

func companionKindForStoryAttitude(storyID string, attitude string) string {
	attitude = normalizeArrivalAttitude(attitude)
	switch storyRuleKey(storyID) {
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
	kind := companionKindForStoryAttitude(storyID, attitude)
	if kind == "" {
		return false
	}
	return playerOwnsCompanionType(playerName, kind)
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
	preface := travelBody + "\nAttitude on arrival: " + normalizeArrivalAttitude(attitude) + "."
	if binding := darkElfHomeBinding(player.Pos); binding != nil {
		title := resolveDarkElvesEncounter(key, player, binding, preface, attitude)
		return true, title
	}
	binding := storyBindingAtForPlayer(key, player.Pos, player.Turns)
	if binding == nil {
		return false, ""
	}
	switch binding.StoryID {
	case "hilltroll":
		title := resolveHillTrollEncounter(key, player, binding, preface, attitude)
		return true, title
	case "benevolentmonk":
		title := resolveBenevolentMonkEncounter(key, player, binding, preface, attitude)
		return true, title
	case "goblinknot":
		title := resolveGoblinEncounter(key, player, binding, preface, attitude)
		return true, title
	case "ashdrake":
		title := resolveAshDrakeEncounter(key, player, binding, preface, attitude)
		return true, title
	case "darkelves":
		title := resolveDarkElvesEncounter(key, player, binding, preface, attitude)
		return true, title
	}
	if storyRuleSets[storyRuleKey(binding.StoryID)] == nil {
		return false, ""
	}
	attitude = normalizeArrivalAttitude(attitude)
	if isCompanionStoryID(binding.StoryID) && totalCompanions(key) >= 3 {
		return false, ""
	}
	if isCompanionStoryID(binding.StoryID) && playerAlreadyOwnsCompanionStoryKind(player.Name, binding.StoryID, attitude) {
		return false, ""
	}

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
	out += "EarnedClaimID: " + result.EarnedClaimID + "\n"
	out += "EarnedCompanion: " + result.EarnedCompanion + "\n"
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
	out += "Roll: " + strconv.Itoa(int(result.Roll)) + "\n"
	out += "Title: " + result.Title + "\n"
	out += "Body: " + result.Body
	return out
}
