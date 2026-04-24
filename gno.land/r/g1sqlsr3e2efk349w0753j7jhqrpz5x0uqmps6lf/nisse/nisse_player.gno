package nisse

import (
	"chain/runtime"
	"strconv"
)

type Player struct {
	ID                uint64
	Owner             Address
	LineageOwner      Address
	Name              string
	Appearance16      string
	Incarnation       uint64
	Alive             bool
	Pos               Position
	Level             uint64
	Boldness          uint64
	Caution           uint64
	Kindness          uint64
	Soul              uint64
	Turns             uint64
	AgeYears          uint64
	DiaryPages        uint64
	NextEntryID       uint64
	ActiveCompanionID uint64
	TravelBonus       uint64
	BagLimit          uint64
}

type FallenPlayer struct {
	ID            uint64
	Name          string
	LineageOwner  Address
	Owner         Address
	Incarnation   uint64
	Cause         string
	DeathTurn     uint64
	DeathPosition Position
	Level         uint64
	DiaryPages    uint64
	Companions    uint64
	Pearls        uint64
	UGNOT         int64
}

type DiaryEntry struct {
	ID        uint64
	Turn      uint64
	Action    string
	Place     string
	TimeOfDay string
	Title     string
	Body      string
}

type CompanionSpecies struct {
	Kind        string
	Name        string
	SpawnWeight uint64
	Ability     string
	Description string
}

type Companion struct {
	ID          uint64
	AssetID     uint64
	OwnerPlayer string
	Species     CompanionSpecies
	FoundAt     Position
	FoundTurn   uint64
	Strength    uint64
	Wisdom      uint64
	Dexterity   uint64
	Boldness    uint64
	Caution     uint64
	Kindness    uint64
	Skill       string
	Trait       string
	Encounters  uint64
}

var players map[string]*Player
var fallenPlayers map[string][]*FallenPlayer
var lineageOwners map[string]Address
var lineageIncarnations map[string]uint64
var diaries map[string]map[uint64]*DiaryEntry
var companions map[string]map[uint64]*Companion
var hiddenCompanions map[uint64]*Companion
var monsterMarks map[string]map[string]bool
var darkElfWarnings map[string]bool
var companionSpecies []CompanionSpecies
var nextCompanionID uint64
var nextPlayerID uint64

func init() {
	players = make(map[string]*Player)
	fallenPlayers = make(map[string][]*FallenPlayer)
	lineageOwners = make(map[string]Address)
	lineageIncarnations = make(map[string]uint64)
	diaries = make(map[string]map[uint64]*DiaryEntry)
	companions = make(map[string]map[uint64]*Companion)
	hiddenCompanions = make(map[uint64]*Companion)
	monsterMarks = make(map[string]map[string]bool)
	darkElfWarnings = make(map[string]bool)
	companionSpecies = []CompanionSpecies{
		{
			Kind:        "land",
			Name:        "Ash Hound",
			SpawnWeight: 4,
			Ability:     "finds hidden trails",
			Description: "A sharp-nosed hound that can pick up traces others miss.",
		},
		{
			Kind:        "land",
			Name:        "Market Falcon",
			SpawnWeight: 3,
			Ability:     "spots movement from afar",
			Description: "A high-circling falcon that notices danger and opportunity before most.",
		},
		{
			Kind:        "land",
			Name:        "Lantern Mare",
			SpawnWeight: 2,
			Ability:     "crosses long roads swiftly",
			Description: "A pale mare with a calm gaze and a gift for the long road.",
		},
		{
			Kind:        "sea",
			Name:        "Moon Eel",
			SpawnWeight: 0,
			Ability:     "slips through reefs and currents",
			Description: "A silver eel that vanishes and returns with uncanny ease.",
		},
		{
			Kind:        "sea",
			Name:        "Tide Ray",
			SpawnWeight: 0,
			Ability:     "feels shifts in weather and tide",
			Description: "A broad ray that moves like a shadow over surf and shoal.",
		},
		{
			Kind:        "sea",
			Name:        "Harbor Seal",
			SpawnWeight: 0,
			Ability:     "guides safe coastal passages",
			Description: "A quick-eyed seal that knows the safer edges of the coast.",
		},
	}
	nextCompanionID = 1
	nextPlayerID = 1
}

func appendFallenPlayer(playerKey string, fallen FallenPlayer) {
	fallenPlayers[playerKey] = append(fallenPlayers[playerKey], &fallen)
}

func latestFallenPlayer(playerKey string) *FallenPlayer {
	lives := fallenPlayers[playerKey]
	if len(lives) == 0 {
		return nil
	}
	return lives[len(lives)-1]
}

func ensureMonsterMarkSet(playerKey string) map[string]bool {
	set, ok := monsterMarks[playerKey]
	if !ok {
		set = make(map[string]bool)
		monsterMarks[playerKey] = set
	}
	return set
}

func playerHasMonsterMark(playerKey string, kind string) bool {
	set := monsterMarks[playerKey]
	if set == nil {
		return false
	}
	return set[normalizeKey(kind)]
}

func grantMonsterMark(playerKey string, kind string) {
	ensureMonsterMarkSet(playerKey)[normalizeKey(kind)] = true
}

func resetSacredCompanionMint(subtype string, displayName string) {
	subtype = normalizeKey(subtype)
	displayName = cleanName(displayName)

	switch subtype {
	case "snow-reindeer":
		for _, entry := range snowReindeerHerd {
			if entry != nil && entry.Name == displayName {
				entry.MintedAssetID = 0
				return
			}
		}
	case "farm-dog":
		for _, entry := range sacredDogPack {
			if entry != nil && entry.Name == displayName {
				entry.MintedAssetID = 0
				return
			}
		}
	case "farm-donkey":
		for _, entry := range sacredDonkeyTrain {
			if entry != nil && entry.Name == displayName {
				entry.MintedAssetID = 0
				return
			}
		}
	case "farm-mule":
		for _, entry := range sacredMuleTrain {
			if entry != nil && entry.Name == displayName {
				entry.MintedAssetID = 0
				return
			}
		}
	case "forest-bear":
		for _, entry := range sacredBearHerd {
			if entry != nil && entry.Name == displayName {
				entry.MintedAssetID = 0
				return
			}
		}
	case "forest-deer":
		for _, entry := range sacredDeerHerd {
			if entry != nil && entry.Name == displayName {
				entry.MintedAssetID = 0
				return
			}
		}
	case "forest-fairy":
		for _, entry := range sacredFairyRing {
			if entry != nil && entry.Name == displayName {
				entry.MintedAssetID = 0
				return
			}
		}
	case "night-owl":
		for _, entry := range sacredOwlParliament {
			if entry != nil && entry.Name == displayName {
				entry.MintedAssetID = 0
				return
			}
		}
	case "night-tomcat":
		for _, entry := range sacredTomcatClowder {
			if entry != nil && entry.Name == displayName {
				entry.MintedAssetID = 0
				return
			}
		}
	case "forest-wolverine":
		for _, entry := range sacredWolverineRun {
			if entry != nil && entry.Name == displayName {
				entry.MintedAssetID = 0
				return
			}
		}
	case "forest-porcupine":
		for _, entry := range sacredPorcupineNest {
			if entry != nil && entry.Name == displayName {
				entry.MintedAssetID = 0
				return
			}
		}
	case "forest-squirrel":
		for _, entry := range sacredSquirrelDrey {
			if entry != nil && entry.Name == displayName {
				entry.MintedAssetID = 0
				return
			}
		}
	}
}

func releaseAllRegularCompanionsForPegasus(playerKey string, player *Player) string {
	collection := companions[playerKey]
	if len(collection) == 0 {
		return ""
	}

	released := []string{}
	for companionID, companion := range collection {
		if companion == nil {
			continue
		}
		asset := assets[companion.AssetID]
		if asset == nil || asset.Status != "held" {
			continue
		}
		if asset.Subtype == "sky-pegasus" {
			continue
		}
		released = append(released, asset.DisplayName+" the "+companion.Species.Name)
		recordAssetHistory(asset.ID, player.Turns, "returned_to_origin", player.Name, "", placeName(companion.FoundAt), asset.Code+" returns to its first ground and is no longer bound to "+player.Name+".")
		asset.OwnerPlayer = ""
		asset.OwnerLineage = ""
		asset.Status = "released_to_origin"
		asset.LastKnownPos = companion.FoundAt
		resetSacredCompanionMint(asset.Subtype, asset.DisplayName)
		delete(collection, companionID)
	}
	player.ActiveCompanionID = 0

	if len(released) == 0 {
		return ""
	}
	out := "To make room for the pegasus, you free your old companions back to their first places:\n"
	for _, entry := range released {
		out += "- " + entry + "\n"
	}
	return out
}

func playerHasDarkElfWarning(playerKey string) bool {
	return darkElfWarnings[playerKey]
}

func grantDarkElfWarning(playerKey string) {
	darkElfWarnings[playerKey] = true
}

func archivePlayerDeath(playerKey string, player *Player, cause string) FallenPlayer {
	fallen := FallenPlayer{
		ID:            player.ID,
		Name:          player.Name,
		LineageOwner:  player.LineageOwner,
		Owner:         player.Owner,
		Incarnation:   player.Incarnation,
		Cause:         cause,
		DeathTurn:     player.Turns,
		DeathPosition: player.Pos,
		Level:         player.Level,
		DiaryPages:    player.DiaryPages,
		Companions:    totalCompanions(playerKey),
		Pearls:        totalPearls(playerKey),
		UGNOT:         ugnotPouch[playerKey],
	}
	appendFallenPlayer(playerKey, fallen)
	hideHeldAssetsOnTile(playerKey, player)
	stashActiveListingsOnTileForLineage(player)
	stashInheritanceCache(playerKey, player, cause)
	delete(players, playerKey)
	delete(diaries, playerKey)
	delete(companions, playerKey)
	delete(monsterMarks, playerKey)
	delete(darkElfWarnings, playerKey)
	delete(messages, playerKey)
	delete(boats, playerKey)
	delete(latestPearlTransfer, playerKey)
	delete(latestUGNOTTransfer, playerKey)
	return fallen
}

func hideCompanionOnTile(playerKey string, player *Player, companionID uint64) {
	collection := companions[playerKey]
	companion := collection[companionID]
	if companion == nil {
		return
	}
	asset := assets[companion.AssetID]
	if asset == nil || asset.Status == "hidden_on_tile" {
		return
	}
	delete(collection, companionID)
	if player.ActiveCompanionID == companionID {
		player.ActiveCompanionID = 0
	}
	hiddenCompanions[companion.AssetID] = companion
	storeAssetOnTile(player.Pos, companion.AssetID, player.Name, player.LineageOwner, player.Turns)
}

func hideHeldAssetsOnTile(playerKey string, player *Player) {
	if player == nil {
		return
	}
	collection := companions[playerKey]
	for companionID := range collection {
		hideCompanionOnTile(playerKey, player, companionID)
	}
	for id := uint64(1); id < nextAssetID; id++ {
		asset, ok := assets[id]
		if !ok || asset.OwnerPlayer != player.Name || asset.Status != "held" {
			continue
		}
		storeAssetOnTile(player.Pos, asset.ID, player.Name, player.LineageOwner, player.Turns)
	}
}

func reclaimHiddenCompanion(playerKey string, player *Player, assetID uint64) bool {
	companion := hiddenCompanions[assetID]
	if companion == nil {
		return false
	}
	if !playerBagHasRoom(player) {
		return false
	}
	ensureCompanionCollection(playerKey)[companion.ID] = companion
	if player.ActiveCompanionID == 0 {
		player.ActiveCompanionID = companion.ID
	}
	delete(hiddenCompanions, assetID)
	return true
}

func ReclaimMyItems(cur realm, playerName string) string {
	key, player, _ := ownedPlayer(playerName)
	pos := player.Pos
	entries := tileInventories[tileInventoryKey(pos)]
	if len(entries) == 0 {
		return "No hidden items answer your name here."
	}

	var matching []*TileInventoryEntry
	for _, entry := range entries {
		if entry == nil {
			continue
		}
		if entry.LastOwnerLineage == player.LineageOwner || normalizeKey(entry.LastOwnerPlayer) == normalizeKey(player.Name) {
			matching = append(matching, entry)
		}
	}
	if len(matching) == 0 {
		return "Nothing hidden here still belongs to your line."
	}

	reclaimed := []string{}
	for len(matching) > 0 && playerBagHasRoom(player) {
		bestIndex := 0
		bestScore := uint64(0)
		for idx, entry := range matching {
			asset := assets[entry.AssetID]
			score := assetCarryPriority(asset)
			if idx == 0 || score > bestScore {
				bestIndex = idx
				bestScore = score
			}
		}
		entry := matching[bestIndex]
		matching = append(matching[:bestIndex], matching[bestIndex+1:]...)
		asset := assets[entry.AssetID]
		if asset == nil {
			removeTileInventoryEntry(pos, entry.AssetID)
			continue
		}
		if asset.Kind == "companion" {
			if !reclaimHiddenCompanion(key, player, asset.ID) {
				break
			}
		}
		asset.Status = "held"
		asset.OwnerPlayer = player.Name
		asset.OwnerLineage = player.LineageOwner
		asset.LastKnownPos = player.Pos
		recordAssetHistory(asset.ID, player.Turns, "reclaimed", "", player.Name, placeName(player.Pos), asset.Code+" is reclaimed from the tile's hidden inventory.")
		removeTileInventoryEntry(pos, asset.ID)
		reclaimed = append(reclaimed, asset.Code)
	}

	if len(reclaimed) == 0 {
		return "Your hidden things are still there, but your bag is already full."
	}
	out := "Reclaimed at " + placeName(player.Pos) + "\n"
	for _, code := range reclaimed {
		out += "- " + code + "\n"
	}
	if !playerBagHasRoom(player) {
		out += "Your bag is full; any remaining hidden items stay with the tile."
	}
	return out
}

func ensureCompanionCollection(playerKey string) map[uint64]*Companion {
	if companions[playerKey] == nil {
		companions[playerKey] = make(map[uint64]*Companion)
	}
	return companions[playerKey]
}

func totalCompanions(playerKey string) uint64 {
	return uint64(len(companions[playerKey]))
}

func activeCompanion(playerKey string) *Companion {
	player := players[playerKey]
	if player == nil || player.ActiveCompanionID == 0 {
		return nil
	}
	collection := companions[playerKey]
	companion := collection[player.ActiveCompanionID]
	if companion == nil {
		return nil
	}
	asset := assets[companion.AssetID]
	if asset == nil || asset.Status != "held" {
		return nil
	}
	if companion.Boldness == 0 && companion.Caution == 0 && companion.Kindness == 0 {
		deriveCompanionAttitudes(companion)
	}
	return companion
}

func deriveCompanionAttitudes(companion *Companion) {
	if companion == nil {
		return
	}

	boldness := companion.Strength
	caution := companion.Dexterity
	kindness := companion.Wisdom
	nameKey := normalizeKey(companion.Species.Name)

	switch nameKey {
	case "forest fairy", "fairy":
		boldness = 0
		kindness += 2
		caution++
	case "bear", "forest bear", "wolverine", "forest wolverine", "tomcat", "night tomcat":
		boldness++
	case "deer", "forest deer", "owl", "night owl", "porcupine", "forest porcupine", "squirrel", "forest squirrel", "donkey":
		caution++
	case "dog", "farm dog", "snow reindeer", "reindeer":
		kindness++
	}

	high := boldness
	if caution > high {
		high = caution
	}
	if kindness > high {
		high = kindness
	}

	if boldness == 0 {
		companion.Boldness = 0
	} else if boldness == high {
		companion.Boldness = 10
	} else {
		companion.Boldness = 5
	}

	if caution == 0 {
		companion.Caution = 0
	} else if caution == high {
		companion.Caution = 10
	} else {
		companion.Caution = 5
	}

	if kindness == 0 {
		companion.Kindness = 0
	} else if kindness == high {
		companion.Kindness = 10
	} else {
		companion.Kindness = 5
	}
}

func growCompanionAttitude(companion *Companion, attitude string, amount uint64) {
	if companion == nil || amount == 0 {
		return
	}

	for step := uint64(0); step < amount; step++ {
		switch normalizeKey(attitude) {
		case "bold":
			if companion.Boldness < 5 {
				companion.Boldness = 5
			} else if companion.Boldness < 10 {
				companion.Boldness = 10
			}
			companion.Strength++
		case "cautious":
			if companion.Caution < 5 {
				companion.Caution = 5
			} else if companion.Caution < 10 {
				companion.Caution = 10
			}
			companion.Dexterity++
		case "kind":
			if companion.Kindness < 5 {
				companion.Kindness = 5
			} else if companion.Kindness < 10 {
				companion.Kindness = 10
			}
			companion.Wisdom++
		}
	}
}

func searchCompanionRoll(player *Player) uint64 {
	return percentRoll(player, "companion")
}

func pickCompanionSpecies(player *Player) CompanionSpecies {
	var candidates []CompanionSpecies
	var weights []uint64
	for _, species := range companionSpecies {
		if species.Kind == "land" && species.SpawnWeight > 0 {
			candidates = append(candidates, species)
			weights = append(weights, species.SpawnWeight)
		}
	}
	if len(candidates) == 0 {
		panic("no companion species configured")
	}
	return candidates[weightedRoll(player, "companion-species", weights)]
}

func discoverCompanion(playerKey string, player *Player) Companion {
	species := pickCompanionSpecies(player)
	id := nextCompanionID
	nextCompanionID++
	asset := createAsset("companion", species.Name, species.Name, player.Name, player.LineageOwner, player.Turns, player.Pos)
	companion := Companion{
		ID:          id,
		AssetID:     asset.ID,
		OwnerPlayer: player.Name,
		Species:     species,
		FoundAt:     player.Pos,
		FoundTurn:   player.Turns,
		Strength:    1,
		Wisdom:      1,
		Dexterity:   1,
		Skill:       species.Ability,
		Trait:       "bonded at " + placeName(player.Pos),
		Encounters:  1,
	}
	deriveCompanionAttitudes(&companion)
	if playerBagHasRoom(player) {
		ensureCompanionCollection(playerKey)[id] = &companion
		if players[playerKey] != nil && players[playerKey].ActiveCompanionID == 0 {
			players[playerKey].ActiveCompanionID = id
		}
	} else {
		hiddenCompanions[asset.ID] = &companion
		storeAssetOnTile(player.Pos, asset.ID, player.Name, player.LineageOwner, player.Turns)
	}
	return companion
}

func growCompanion(player *Player, companion *Companion) string {
	companion.Encounters++
	if companion.Encounters%3 == 0 {
		growCompanionAttitude(companion, "cautious", 1)
		return companion.Species.Name + " grows quicker in body and instinct."
	}
	if companion.Encounters%2 == 0 {
		growCompanionAttitude(companion, "bold", 1)
		return companion.Species.Name + " grows stronger."
	}
	growCompanionAttitude(companion, "kind", 1)
	return companion.Species.Name + " grows wiser."
}

func companionStoryEvent(player *Player, companion *Companion) (string, string) {
	event := rollMod(player, "companion-story", 4)
	switch event {
	case 0:
		growCompanionAttitude(companion, "cautious", 1)
		companion.Trait = "pine-secret"
		companion.Skill = "A raven's secret makes it hard to catch."
		return "A secret under the pine", companion.Species.Name + " rests beneath a pine tree while a raven whispers a secret. Caution +1."
	case 1:
		growCompanionAttitude(companion, "kind", 1)
		companion.Trait = "moon-listener"
		companion.Skill = "Night murmurs sharpen its judgment."
		return "A lesson by moonlight", "An old night bird teaches " + companion.Species.Name + " to listen before moving. Kindness +1."
	case 2:
		growCompanionAttitude(companion, "bold", 1)
		companion.Trait = "stone-step"
		companion.Skill = "It learns to brace itself against blunt force."
		return "A hard road lesson", companion.Species.Name + " follows a rough stone path and learns how to hold firm. Boldness +1."
	default:
		growCompanionAttitude(companion, "kind", 1)
		growCompanionAttitude(companion, "cautious", 1)
		companion.Trait = "reed-shadow"
		companion.Skill = "It glides through danger like reeds in wind."
		return "A reed-bed friendship", "A shy marsh creature teaches " + companion.Species.Name + " how to move lightly and think quickly. Kindness +1, Caution +1."
	}
}

func allowedAction(value string) bool {
	switch normalizeKey(value) {
	case "read", "wander", "investigate", "listen", "rest":
		return true
	default:
		return false
	}
}

func allowedPlace(value string) bool {
	switch normalizeKey(value) {
	case "street", "market", "bar", "library", "harbor", "square":
		return true
	default:
		return false
	}
}

func allowedTime(value string) bool {
	switch normalizeKey(value) {
	case "day", "evening", "night", "supper":
		return true
	default:
		return false
	}
}

func createDiaryEntry(playerKey string, action string, place string, timeOfDay string, title string, body string) {
	player, ok := players[playerKey]
	if !ok {
		panic("player not found")
	}
	if diaries[playerKey] == nil {
		diaries[playerKey] = make(map[uint64]*DiaryEntry)
	}

	id := player.NextEntryID
	player.NextEntryID++
	diaries[playerKey][id] = &DiaryEntry{
		ID:        id,
		Turn:      player.Turns,
		Action:    action,
		Place:     place,
		TimeOfDay: timeOfDay,
		Title:     title,
		Body:      body,
	}
	player.DiaryPages++
}

func actionOutcome(action string, place string, timeOfDay string) (string, string, uint64) {
	actionKey := normalizeKey(action)
	placeKey := normalizeKey(place)
	timeKey := normalizeKey(timeOfDay)

	if actionKey == "read" && placeKey == "library" {
		return "A quiet page turns", "You read patiently in the library and leave with a small but steady insight.", 1
	}
	if actionKey == "wander" && placeKey == "street" && timeKey == "evening" {
		return "Restless footsteps", "You wander the evening street and sense that a living creature or sudden encounter might reveal itself here.", 1
	}
	if actionKey == "investigate" && placeKey == "market" {
		return "Market traces", "You investigate the market closely and notice patterns in goods, glances, and absences.", 1
	}
	if actionKey == "listen" && (placeKey == "bar" || placeKey == "square") {
		return "A rumor settles", "You listen more than you speak and carry away a rumor that may matter later.", 1
	}
	if actionKey == "rest" {
		return "A pause in the day", "You rest for a while and let the world gather itself around you.", 0
	}

	return "A small turn", "You spend a turn " + actionKey + " in the " + placeKey + " during the " + timeKey + ".", 0
}

func MintPlayer(cur realm, name string) string {
	caller := Address(runtime.OriginCaller())
	name = cleanName(name)

	if name == "" {
		panic("player name is required")
	}

	key := normalizeKey(name)
	if _, exists := players[key]; exists {
		panic("player already exists")
	}
	if lineageOwner, exists := lineageOwners[key]; exists && lineageOwner != caller {
		panic("name belongs to another lineage")
	}

	pos := startPosition()
	seed := uint64(len(players))
	id := nextPlayerID
	nextPlayerID++
	incarnation := lineageIncarnations[key] + 1
	lineageOwners[key] = caller
	lineageIncarnations[key] = incarnation

	players[key] = &Player{
		ID:           id,
		Owner:        caller,
		LineageOwner: caller,
		Name:         name,
		Appearance16: "",
		Incarnation:  incarnation,
		Alive:        true,
		Pos:          pos,
		Level:        1,
		Boldness:     10,
		Caution:      10,
		Kindness:     10,
		Soul:         10,
		Turns:        0,
		AgeYears:     0,
		DiaryPages:   0,
		NextEntryID:  1,
		TravelBonus:  0,
		BagLimit:     10,
	}
	player := players[key]
	player.Boldness = 10 + d10(player, "boldness")
	player.Caution = 10 + d10(player, "caution")
	player.Kindness = 10 + d10(player, "kindness")
	player.Soul = 10 + d10(player, "soul")
	diaries[key] = make(map[uint64]*DiaryEntry)
	messages[key] = make(map[uint64]*Message)
	mintInitialPearls(key, 100)
	recordPearlTransfer(key, "Minted 100 initial pearls from "+pearlOriginMark(key)+".")
	body := "You arrive in a coastal town on the northeastern shore and the world begins to take note of you.\n\n"
	body += "Boldness: " + strconv.Itoa(int(player.Boldness)) + "\n"
	body += "Caution: " + strconv.Itoa(int(player.Caution)) + "\n"
	body += "Kindness: " + strconv.Itoa(int(player.Kindness)) + "\n"
	body += "Soul: " + strconv.Itoa(int(player.Soul))
	createDiaryEntry(
		key,
		"birth",
		placeName(pos),
		"day",
		"Day one",
		body,
	)
	if cache := latestUnrecoveredInheritance(key); cache != nil {
		body := "A weathered stranger finds you before dusk and speaks of your late kinsman " + cache.FallenName + ". "
		body += "They press a marked scrap into your hand and tell you where the misfortune happened: (" + strconv.Itoa(int(cache.Position.X)) + ", " + strconv.Itoa(int(cache.Position.Y)) + "). "
		body += "Some hidden purse or burden may still be waiting there if you choose to go."
		createDiaryEntry(key, "inheritance", placeName(pos), "day", "News of an old misfortune", body)
	}

	spawnStarterWorld(seed, pos)
	return name
}

func validAppearance16(value string) bool {
	if len(value) != 256 {
		return false
	}
	for i := 0; i < len(value); i++ {
		ch := value[i]
		if (ch >= '0' && ch <= '9') || (ch >= 'a' && ch <= 'z') {
			continue
		}
		return false
	}
	return true
}

func SetPlayerAppearance(cur realm, playerName string, appearance16 string) string {
	key, player, _ := ownedPlayer(playerName)
	appearance16 = normalizeKey(appearance16)
	if appearance16 == "" || appearance16 == "none" {
		player.Appearance16 = ""
		createDiaryEntry(key, "appearance", placeName(player.Pos), "day", "A likeness set aside", "You leave your painted likeness unfinished for now.")
		return "Appearance cleared."
	}
	if !validAppearance16(appearance16) {
		panic("appearance must be a 16x16 base36 sprite string")
	}
	player.Appearance16 = appearance16
	createDiaryEntry(key, "appearance", placeName(player.Pos), "day", "A likeness remembered", "You commit a small painted likeness of yourself to the realm.")
	return "Appearance saved."
}

func EndPlayerLife(cur realm, playerName string, cause string) string {
	key, player, _ := ownedPlayer(playerName)
	cause = cleanName(cause)
	if cause == "" {
		cause = "the road ended unnamed"
	}

	fallen := archivePlayerDeath(key, player, cause)
	return fallen.Name + " falls at turn " + strconv.Itoa(int(fallen.DeathTurn)) + ". The name remains bound to lineage " + string(fallen.LineageOwner) + "."
}

func RenameCompanion(cur realm, playerName string, companionID uint64, displayName string) string {
	key, player, _ := ownedPlayer(playerName)
	displayName = cleanName(displayName)
	if displayName == "" {
		panic("display name is required")
	}

	collection := companions[key]
	companion, exists := collection[companionID]
	if !exists {
		panic("companion not found")
	}

	asset, ok := assets[companion.AssetID]
	if !ok {
		panic("companion asset not found")
	}
	if asset.Status != "held" {
		panic("companion is hidden on a tile and cannot be renamed here")
	}
	previous := asset.DisplayName
	asset.DisplayName = displayName
	asset.LastKnownPos = player.Pos
	recordAssetHistory(asset.ID, player.Turns, "renamed", player.Name, player.Name, placeName(player.Pos), previous+" -> "+displayName)
	return asset.Code + " now answers to " + displayName
}

func TransferCompanion(cur realm, fromPlayerName string, toPlayerName string, companionID uint64) string {
	fromKey, fromPlayer, _ := ownedPlayer(fromPlayerName)
	toPlayerName = cleanName(toPlayerName)
	toKey := normalizeKey(toPlayerName)
	toPlayer, ok := players[toKey]
	if !ok {
		panic("recipient not found")
	}
	if !sameTile(fromPlayer.Pos, toPlayer.Pos) {
		panic("both players must stand on the same tile")
	}

	collection := companions[fromKey]
	companion, exists := collection[companionID]
	if !exists {
		panic("companion not found")
	}

	asset, ok := assets[companion.AssetID]
	if !ok {
		panic("companion asset not found")
	}
	if asset.Status != "held" {
		panic("companion is hidden on a tile and cannot be transferred")
	}

	delete(collection, companionID)
	if fromPlayer.ActiveCompanionID == companionID {
		fromPlayer.ActiveCompanionID = 0
	}

	companion.OwnerPlayer = toPlayer.Name
	ensureCompanionCollection(toKey)[companionID] = companion
	if toPlayer.ActiveCompanionID == 0 {
		toPlayer.ActiveCompanionID = companionID
	}

	asset.OwnerPlayer = toPlayer.Name
	asset.OwnerLineage = toPlayer.LineageOwner
	asset.Status = "held"
	asset.LastKnownPos = toPlayer.Pos
	recordAssetHistory(asset.ID, fromPlayer.Turns, "transferred", fromPlayer.Name, toPlayer.Name, placeName(toPlayer.Pos), asset.Code+" passes into new hands.")
	return asset.Code + " now belongs to " + toPlayer.Name
}

func ListPlayers() uint64 {
	return uint64(len(players))
}

func ListPlayerPositions() string {
	if len(players) == 0 {
		return "No players."
	}

	out := "Player positions\n"
	for _, player := range players {
		out += "- " + player.Name + " @ (" + strconv.Itoa(int(player.Pos.X)) + ", " + strconv.Itoa(int(player.Pos.Y)) + ")\n"
	}
	return out
}

func DescribePlayer(name string) string {
	key := normalizeKey(name)
	player, ok := players[key]
	if !ok {
		panic("player not found")
	}

	out := "Player: " + player.Name + "\n"
	out += "PlayerID: " + strconv.Itoa(int(player.ID)) + "\n"
	out += "Incarnation: " + strconv.Itoa(int(player.Incarnation)) + "\n"
	out += "Status: alive\n"
	out += "Owner: " + string(player.Owner) + "\n"
	out += "LineageOwner: " + string(player.LineageOwner) + "\n"
	out += "Level: " + strconv.Itoa(int(player.Level)) + "\n"
	out += "Boldness: " + strconv.Itoa(int(player.Boldness)) + "\n"
	out += "Caution: " + strconv.Itoa(int(player.Caution)) + "\n"
	out += "Kindness: " + strconv.Itoa(int(player.Kindness)) + "\n"
	out += "Soul: " + strconv.Itoa(int(player.Soul)) + "\n"
	out += "Turns: " + strconv.Itoa(int(player.Turns)) + "\n"
	out += "AgeYears: " + strconv.Itoa(int(player.AgeYears)) + "\n"
	out += "DiaryPages: " + strconv.Itoa(int(player.DiaryPages)) + "\n"
	total := totalPearls(key)
	if total > 0 {
		out += "Pearls: " + strconv.Itoa(int(total)) + " total"
		origins := pearlOrigins(key)
		if origins != "" {
			out += " [" + origins + "]"
		}
		out += "\n"
	}
	if ugnotPouch[key] > 0 {
		out += "UGNOT: " + strconv.Itoa(int(ugnotPouch[key])) + "\n"
	}
	out += "TravelBonus: +" + strconv.Itoa(int(player.TravelBonus)) + "\n"
	out += "Bag: " + strconv.Itoa(int(bagItemCount(player.Name))) + "/" + strconv.Itoa(int(player.BagLimit)) + "\n"
	out += "Boat: " + boatStatusSummary(key) + "\n"
	if player.Appearance16 != "" {
		out += "Appearance16: " + player.Appearance16 + "\n"
	} else {
		out += "Appearance16: none\n"
	}
	if totalCompanions(key) > 0 {
		out += "Companions: " + strconv.Itoa(int(totalCompanions(key))) + "\n"
		active := activeCompanion(key)
		if active != nil {
			out += "ActiveCompanion: " + active.Species.Name + "\n"
		}
	}
	out += "Position: (" + strconv.Itoa(int(player.Pos.X)) + ", " + strconv.Itoa(int(player.Pos.Y)) + ")\n"
	out += "Zone: " + terrainName(GetTile(player.Pos.X, player.Pos.Y)) + "\n"
	out += "Place: " + placeName(player.Pos)
	return out
}

func DescribeLineage(name string) string {
	key := normalizeKey(name)
	lineageOwner, ok := lineageOwners[key]
	if !ok {
		panic("lineage not found")
	}

	out := "Lineage: " + cleanName(name) + "\n"
	out += "LineageOwner: " + string(lineageOwner) + "\n"
	out += "Incarnations: " + strconv.Itoa(int(lineageIncarnations[key])) + "\n"
	player, alive := players[key]
	if alive {
		out += "CurrentStatus: alive\n"
		out += "CurrentPlayerID: " + strconv.Itoa(int(player.ID)) + "\n"
		out += "CurrentOwner: " + string(player.Owner) + "\n"
		out += "CurrentTurn: " + strconv.Itoa(int(player.Turns)) + "\n"
	} else {
		out += "CurrentStatus: fallen\n"
	}

	lives := fallenPlayers[key]
	out += "FallenLives: " + strconv.Itoa(len(lives)) + "\n"
	latest := latestFallenPlayer(key)
	if latest != nil {
		out += "LastDeathTurn: " + strconv.Itoa(int(latest.DeathTurn)) + "\n"
		out += "LastDeathCause: " + latest.Cause + "\n"
		out += "LastDeathPlace: (" + strconv.Itoa(int(latest.DeathPosition.X)) + ", " + strconv.Itoa(int(latest.DeathPosition.Y)) + ")\n"
	}
	cache := latestUnrecoveredInheritance(key)
	if cache != nil {
		out += "HiddenInheritance: yes\n"
		out += "InheritancePlace: (" + strconv.Itoa(int(cache.Position.X)) + ", " + strconv.Itoa(int(cache.Position.Y)) + ")\n"
		out += "InheritancePearls: " + strconv.Itoa(int(totalPearlsInPurse(cache.Purse))) + "\n"
		out += "InheritanceUGNOT: " + strconv.Itoa(int(cache.UGNOT))
	}
	return out
}

func DescribeCompanion(playerName string) string {
	key := normalizeKey(playerName)
	player, ok := players[key]
	if !ok {
		panic("player not found")
	}

	collection := companions[key]
	if len(collection) == 0 {
		return "No companions."
	}

	out := "Companions for " + player.Name + "\n"
	for id := uint64(1); id < nextCompanionID; id++ {
		companion, exists := collection[id]
		if !exists {
			continue
		}
		out += "- #" + strconv.Itoa(int(companion.ID)) + " " + companion.Species.Name
		if player.ActiveCompanionID == companion.ID {
			out += " [active]"
		}
		out += "\n"
		asset, ok := assets[companion.AssetID]
		if ok {
			out += "  Asset: " + asset.Code + "\n"
			if asset.DisplayName != "" {
				out += "  Name: " + asset.DisplayName + "\n"
			}
			out += "  Status: " + asset.Status + "\n"
		}
		out += "  Nature: " + companion.Species.Description + "\n"
		out += "  Skill: " + companion.Skill + "\n"
		if companion.Trait != "" {
			out += "  Trait: " + companion.Trait + "\n"
		}
		if companion.Boldness == 0 && companion.Caution == 0 && companion.Kindness == 0 {
			deriveCompanionAttitudes(companion)
		}
		out += "  Boldness: " + strconv.Itoa(int(companion.Boldness)) +
			" Caution: " + strconv.Itoa(int(companion.Caution)) +
			" Kindness: " + strconv.Itoa(int(companion.Kindness)) + "\n"
		out += "  Encounters: " + strconv.Itoa(int(companion.Encounters)) +
			" Found: (" + strconv.Itoa(int(companion.FoundAt.X)) + ", " + strconv.Itoa(int(companion.FoundAt.Y)) + ") on turn " + strconv.Itoa(int(companion.FoundTurn)) + "\n"
	}
	return out
}

func DescribeCompanionRegistry(kind string) string {
	kind = normalizeKey(kind)
	if kind == "" {
		panic("companion kind is required")
	}

	out := "Companion registry: " + kind + "\n"
	if kind == "reindeer" || kind == "snow-reindeer" {
		for _, reindeer := range snowReindeerHerd {
			if reindeer == nil {
				continue
			}
			out += "- " + reindeer.Name
			if reindeer.MintedAssetID == 0 {
				out += " | owner: undiscovered\n"
				continue
			}
			asset := assets[reindeer.MintedAssetID]
			if asset == nil || asset.OwnerPlayer == "" {
				out += " | owner: undiscovered\n"
				continue
			}
			out += " | owner: " + asset.OwnerPlayer + "\n"
		}
		return out
	}
	if kind == "dog" || kind == "farm-dog" {
		for _, dog := range sacredDogPack {
			if dog == nil {
				continue
			}
			out += "- " + dog.Name
			if dog.MintedAssetID == 0 {
				out += " | owner: undiscovered\n"
				continue
			}
			asset := assets[dog.MintedAssetID]
			if asset == nil || asset.OwnerPlayer == "" {
				out += " | owner: undiscovered\n"
				continue
			}
			out += " | owner: " + asset.OwnerPlayer + "\n"
		}
		return out
	}
	if kind == "donkey" || kind == "farm-donkey" {
		for _, donkey := range sacredDonkeyTrain {
			if donkey == nil {
				continue
			}
			out += "- " + donkey.Name
			if donkey.MintedAssetID == 0 {
				out += " | owner: undiscovered\n"
				continue
			}
			asset := assets[donkey.MintedAssetID]
			if asset == nil || asset.OwnerPlayer == "" {
				out += " | owner: undiscovered\n"
				continue
			}
			out += " | owner: " + asset.OwnerPlayer + "\n"
		}
		return out
	}
	if kind == "mule" || kind == "farm-mule" {
		for _, mule := range sacredMuleTrain {
			if mule == nil {
				continue
			}
			out += "- " + mule.Name
			if mule.MintedAssetID == 0 {
				out += " | owner: undiscovered\n"
				continue
			}
			asset := assets[mule.MintedAssetID]
			if asset == nil || asset.OwnerPlayer == "" {
				out += " | owner: undiscovered\n"
				continue
			}
			out += " | owner: " + asset.OwnerPlayer + "\n"
		}
		return out
	}
	if kind == "bear" || kind == "forest-bear" {
		return renderSacredForestRegistry(out, sacredBearHerd)
	}
	if kind == "deer" || kind == "forest-deer" {
		return renderSacredForestRegistry(out, sacredDeerHerd)
	}
	if kind == "fairy" || kind == "forest-fairy" {
		return renderSacredForestRegistry(out, sacredFairyRing)
	}
	if kind == "owl" || kind == "night-owl" {
		return renderSacredForestRegistry(out, sacredOwlParliament)
	}
	if kind == "tomcat" || kind == "night-tomcat" {
		return renderSacredForestRegistry(out, sacredTomcatClowder)
	}
	if kind == "wolverine" || kind == "forest-wolverine" {
		return renderSacredForestRegistry(out, sacredWolverineRun)
	}
	if kind == "porcupine" || kind == "forest-porcupine" {
		return renderSacredForestRegistry(out, sacredPorcupineNest)
	}
	if kind == "squirrel" || kind == "forest-squirrel" {
		return renderSacredForestRegistry(out, sacredSquirrelDrey)
	}
	if kind == "pegasus" || kind == "sky-pegasus" {
		return renderSacredPegasusRegistry(out)
	}
	if kind == "griffin" || kind == "sky-griffin" {
		return renderSacredGriffinRegistry(out)
	}

	matched := false
	for assetID := uint64(1); assetID < nextAssetID; assetID++ {
		asset := assets[assetID]
		if asset == nil || asset.Kind != "companion" {
			continue
		}
		if asset.Subtype != kind {
			continue
		}
		matched = true
		out += "- " + asset.Code
		if asset.DisplayName != "" {
			out += " \"" + asset.DisplayName + "\""
		}
		if asset.OwnerPlayer != "" {
			out += " | owner: " + asset.OwnerPlayer + "\n"
		} else {
			out += " | owner: undiscovered\n"
		}
	}
	if !matched {
		return out + "No companions match this kind."
	}
	return out
}

func ListDiaryPages(playerName string) uint64 {
	key := normalizeKey(playerName)
	player, ok := players[key]
	if !ok {
		panic("player not found")
	}

	return player.DiaryPages
}

func DescribeDiaryEntry(playerName string, entryID uint64) string {
	key := normalizeKey(playerName)
	entryMap, ok := diaries[key]
	if !ok {
		panic("player diary not found")
	}
	entry, ok := entryMap[entryID]
	if !ok {
		panic("diary entry not found")
	}

	out := "Diary Entry #" + strconv.Itoa(int(entry.ID)) + "\n"
	out += "Turn: " + strconv.Itoa(int(entry.Turn)) + "\n"
	out += "Action: " + entry.Action + "\n"
	out += "Place: " + entry.Place + "\n"
	out += "Time: " + entry.TimeOfDay + "\n"
	out += "Title: " + entry.Title + "\n"
	out += "Body: " + entry.Body
	return out
}

func DescribeLatestDiaryEntry(playerName string) string {
	key := normalizeKey(playerName)
	player, ok := players[key]
	if !ok {
		panic("player not found")
	}
	if player.DiaryPages == 0 {
		panic("player diary is empty")
	}

	return DescribeDiaryEntry(playerName, player.NextEntryID-1)
}

func DescribeLatestStoryDiaryEntry(playerName string) string {
	key := normalizeKey(playerName)
	player, ok := players[key]
	if !ok {
		panic("player not found")
	}
	if player.DiaryPages == 0 {
		panic("player diary is empty")
	}

	entryMap, ok := diaries[key]
	if !ok {
		panic("player diary not found")
	}

	for entryID := player.NextEntryID; entryID > 1; entryID-- {
		entry := entryMap[entryID-1]
		if entry != nil && normalizeKey(entry.Action) == "story" {
			return DescribeDiaryEntry(playerName, entry.ID)
		}
	}

	panic("player has no story diary entries")
}
