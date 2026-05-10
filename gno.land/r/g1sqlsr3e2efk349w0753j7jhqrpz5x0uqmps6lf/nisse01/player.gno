package nisse

import (
	"chain/runtime"
	"strconv"
)

type Player struct {
	ID           uint64
	Owner        Address
	Name         string
	Appearance16 string
	Pos          Position
	Level        uint64
	Boldness     uint64
	Caution      uint64
	Kindness     uint64
	Soul         uint64
	Turns        uint64
	DiaryPages   uint64
	NextEntryID  uint64
	TravelBonus  uint64
	BagLimit     uint64
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
	Kind string
	Name string
}

type Companion struct {
	ID          uint64
	AssetID     uint64
	OwnerPlayer string
	Species     CompanionSpecies
	FoundAt     Position
	FoundTurn   uint64
	Boldness    uint64
	Caution     uint64
	Kindness    uint64
	Soul        uint64
	Encounters  uint64
}

var players map[string]*Player
var diaries map[string]map[uint64]*DiaryEntry
var companions map[string]map[uint64]*Companion
var tileCompanions map[uint64]*Companion
var monsterMarks map[string]map[string]bool
var darkElfWarnings map[string]bool
var nextCompanionID uint64
var nextPlayerID uint64

func init() {
	players = make(map[string]*Player)
	diaries = make(map[string]map[uint64]*DiaryEntry)
	companions = make(map[string]map[uint64]*Companion)
	tileCompanions = make(map[uint64]*Companion)
	monsterMarks = make(map[string]map[string]bool)
	darkElfWarnings = make(map[string]bool)
	nextCompanionID = 1
	nextPlayerID = 1
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

func releaseAllRegularCompanionsForMythic(playerKey string, player *Player) string {
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
		if asset.Subtype == "pegasus" || asset.Subtype == "griffin" {
			continue
		}
		released = append(released, asset.DisplayName+" the "+companion.Species.Name)
		delete(collection, companionID)
		tileCompanions[asset.ID] = companion
		storeAssetOnTile(companion.FoundAt, asset.ID, player.Turns)
		recordAssetHistory(asset.ID, player.Turns, "returned_to_origin", player.Name, "", placeName(companion.FoundAt), "ReturnToOrigin")
	}
	if len(released) == 0 {
		return ""
	}
	out := "To make room for the mythic companion, you free your old companions back to their first places:\n"
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

func claimTileCompanion(playerKey string, player *Player, assetID uint64) bool {
	companion := tileCompanions[assetID]
	if companion == nil {
		return false
	}
	if !playerBagHasRoom(player) {
		return false
	}
	companion.OwnerPlayer = player.Name
	ensureCompanionCollection(playerKey)[companion.ID] = companion
	delete(tileCompanions, assetID)
	return true
}

func ReclaimMyItems(cur realm, playerName string) string {
	key, player, _ := ownedPlayer(playerName)
	pos := player.Pos
	entries := tileInventories[tileInventoryKey(pos)]
	if len(entries) == 0 {
		return "There is nothing to pick up here."
	}

	pickedUp := []string{}
	matching := append([]*TileInventoryEntry{}, entries...)
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
			if !claimTileCompanion(key, player, asset.ID) {
				break
			}
		}
		asset.Status = "held"
		asset.OwnerPlayer = player.Name
		asset.LastKnownPos = player.Pos
		recordAssetHistory(asset.ID, player.Turns, "picked_up", "", player.Name, placeName(player.Pos), asset.Code+" is picked up from the tile.")
		removeTileInventoryEntry(pos, asset.ID)
		pickedUp = append(pickedUp, asset.Code)
	}

	if len(pickedUp) == 0 {
		return "Your bag is already full."
	}
	out := "Picked up at " + placeName(player.Pos) + "\n"
	for _, code := range pickedUp {
		out += "- " + code + "\n"
	}
	if !playerBagHasRoom(player) {
		out += "Your bag is full; any remaining items stay on the tile."
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

func aggregateHeldCompanionProfile(playerKey string) (*Companion, bool) {
	collection := companions[playerKey]
	if len(collection) == 0 {
		return nil, false
	}
	aggregate := &Companion{}
	found := false
	for _, companion := range collection {
		if companion == nil {
			continue
		}
		asset := assets[companion.AssetID]
		if asset == nil || asset.Status != "held" {
			continue
		}
		if companionNeedsProfile(companion) {
			deriveCompanionAttitudes(companion)
		}
		if !found {
			aggregate.Boldness = companion.Boldness
			aggregate.Caution = companion.Caution
			aggregate.Kindness = companion.Kindness
			aggregate.Soul = companion.Soul
			found = true
			continue
		}
		if companion.Boldness > aggregate.Boldness {
			aggregate.Boldness = companion.Boldness
		}
		if companion.Caution > aggregate.Caution {
			aggregate.Caution = companion.Caution
		}
		if companion.Kindness > aggregate.Kindness {
			aggregate.Kindness = companion.Kindness
		}
		if companion.Soul > aggregate.Soul {
			aggregate.Soul = companion.Soul
		}
	}
	return aggregate, found
}

func companionNeedsProfile(companion *Companion) bool {
	if companion == nil {
		return false
	}
	if companion.Soul == 0 {
		return true
	}
	if companion.Boldness == 0 && companion.Caution == 0 && companion.Kindness == 0 {
		return true
	}
	return companion.Boldness <= 4 || companion.Caution <= 4 || companion.Kindness <= 4
}

func deriveCompanionAttitudes(companion *Companion) {
	if companion == nil {
		return
	}
	if companion.Soul == 0 {
		companion.Soul = 10
	}
	if companion.Boldness > 4 || companion.Caution > 4 || companion.Kindness > 4 {
		return
	}
	if companion.Boldness > 0 || companion.Caution > 0 || companion.Kindness > 0 {
		companion.Boldness = companionProfileStatValue(companion.Boldness)
		companion.Caution = companionProfileStatValue(companion.Caution)
		companion.Kindness = companionProfileStatValue(companion.Kindness)
		return
	}

	nameKey := normalizeKey(companion.Species.Name)

	switch nameKey {
	case "forest fairy", "fairy":
		companion.Boldness = 0
		companion.Caution = 6
		companion.Kindness = 8
	case "bear", "forest bear", "wolverine", "forest wolverine", "tomcat", "night tomcat":
		companion.Boldness = 8
		companion.Caution = 6
		companion.Kindness = 5
	case "deer", "forest deer", "owl", "night owl", "porcupine", "forest porcupine", "squirrel", "forest squirrel", "donkey":
		companion.Boldness = 5
		companion.Caution = 8
		companion.Kindness = 6
	case "dog", "farm dog", "snow reindeer", "reindeer":
		companion.Boldness = 5
		companion.Caution = 6
		companion.Kindness = 8
	case "mule", "farm mule":
		companion.Boldness = 8
		companion.Caution = 6
		companion.Kindness = 5
	case "market falcon", "falcon", "moon eel", "tide ray":
		companion.Boldness = 6
		companion.Caution = 8
		companion.Kindness = 5
	case "lantern mare", "harbor seal":
		companion.Boldness = 5
		companion.Caution = 6
		companion.Kindness = 8
	default:
		companion.Boldness = 6
		companion.Caution = 6
		companion.Kindness = 6
	}
}

func companionProfileStatValue(value uint64) uint64 {
	switch value {
	case 0:
		return 0
	case 1:
		return 5
	case 2:
		return 6
	case 3:
		return 8
	default:
		return 10
	}
}

func growCompanionAttitude(companion *Companion, attitude string, amount uint64) {
	if companion == nil || amount == 0 {
		return
	}

	for step := uint64(0); step < amount; step++ {
		switch normalizeKey(attitude) {
		case "bold":
			if companion.Boldness == 0 {
				companion.Boldness = 5
			} else if companion.Boldness < 10 {
				companion.Boldness++
			}
		case "cautious":
			if companion.Caution == 0 {
				companion.Caution = 5
			} else if companion.Caution < 10 {
				companion.Caution++
			}
		case "kind":
			if companion.Kindness == 0 {
				companion.Kindness = 5
			} else if companion.Kindness < 10 {
				companion.Kindness++
			}
		}
	}
}

func grantAttitudeSuccessBonus(player *Player, attitude string) string {
	if player == nil {
		return ""
	}
	switch normalizeArrivalAttitude(attitude) {
	case "bold":
		player.Boldness++
		return "Boldness +1."
	case "kind":
		player.Kindness++
		return "Kindness +1."
	default:
		player.Caution++
		return "Caution +1."
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

func describeDiaryEntry(entry *DiaryEntry) string {
	if entry == nil {
		return ""
	}
	out := "EntryID:" + strconv.Itoa(int(entry.ID)) + "\n"
	out += "Turn:" + strconv.Itoa(int(entry.Turn)) + "\n"
	out += "Action:" + entry.Action + "\n"
	out += "Place:" + entry.Place + "\n"
	out += "Time:" + entry.TimeOfDay + "\n"
	out += "Title:" + entry.Title + "\n"
	out += "Body:" + entry.Body
	return out
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
	pos := startPosition()
	seed := uint64(len(players))
	id := nextPlayerID
	nextPlayerID++

	players[key] = &Player{
		ID:           id,
		Owner:        caller,
		Name:         name,
		Appearance16: "",
		Pos:          pos,
		Level:        1,
		Boldness:     10,
		Caution:      10,
		Kindness:     10,
		Soul:         10,
		Turns:        0,
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
	mintInitialPearls(key, 100)
	recordPearlTransfer(key, "Minted 100 initial pearls from "+pearlOriginMark(key)+".")
	body := "PlayerCreated\n"
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
		createDiaryEntry(key, "appearance", placeName(player.Pos), "day", "appearance_skipped", "Appearance:skipped")
		return "Appearance cleared."
	}
	if !validAppearance16(appearance16) {
		panic("appearance must be a 16x16 base36 sprite string")
	}
	player.Appearance16 = appearance16
	createDiaryEntry(key, "appearance", placeName(player.Pos), "day", "appearance_set", "Appearance:set")
	return "Appearance saved."
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
		panic("companion is on a tile and cannot be renamed here")
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
		panic("companion is on a tile and cannot be transferred")
	}

	delete(collection, companionID)

	companion.OwnerPlayer = toPlayer.Name
	ensureCompanionCollection(toKey)[companionID] = companion

	asset.OwnerPlayer = toPlayer.Name
	asset.Status = "held"
	asset.LastKnownPos = toPlayer.Pos
	recordAssetHistory(asset.ID, fromPlayer.Turns, "transferred", fromPlayer.Name, toPlayer.Name, placeName(toPlayer.Pos), asset.Code+" passes into new hands.")
	return asset.Code + " now belongs to " + toPlayer.Name
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

func GetPlayerCoreData(name string) string {
	key := normalizeKey(name)
	player, ok := players[key]
	if !ok {
		panic("player not found")
	}

	out := "Name: " + player.Name + "\n"
	if player.Appearance16 != "" {
		out += "Appearance16: " + player.Appearance16 + "\n"
	} else {
		out += "Appearance16: none\n"
	}
	return out
}

func GetPlayerStatsData(name string) string {
	key := normalizeKey(name)
	player, ok := players[key]
	if !ok {
		panic("player not found")
	}

	out := "Level: " + strconv.Itoa(int(player.Level)) + "\n"
	out += "Boldness: " + strconv.Itoa(int(player.Boldness)) + "\n"
	out += "Caution: " + strconv.Itoa(int(player.Caution)) + "\n"
	out += "Kindness: " + strconv.Itoa(int(player.Kindness)) + "\n"
	out += "Soul: " + strconv.Itoa(int(player.Soul))
	return out
}

func GetPlayerTravelData(name string) string {
	key := normalizeKey(name)
	player, ok := players[key]
	if !ok {
		panic("player not found")
	}

	out := "Position: (" + strconv.Itoa(int(player.Pos.X)) + ", " + strconv.Itoa(int(player.Pos.Y)) + ")\n"
	out += "Turns: " + strconv.Itoa(int(player.Turns)) + "\n"
	out += "MonthIndex: " + strconv.Itoa(int(monthIndexForTurns(player.Turns))) + "\n"
	out += "Season: " + seasonNameForTurns(player.Turns) + "\n"
	out += "SeasonMonth: " + strconv.Itoa(int(seasonMonthForTurns(player.Turns))) + "\n"
	out += "TravelBonus: +" + strconv.Itoa(int(player.TravelBonus)) + "\n"
	out += "Boat: " + boatStatusSummary(key)
	return out
}

func GetPlayerWealthData(name string) string {
	key := normalizeKey(name)
	_, ok := players[key]
	if !ok {
		panic("player not found")
	}

	return "Pearls: " + strconv.Itoa(int(totalPearls(key)))
}

func GetPlayerMapData(name string) string {
	key := normalizeKey(name)
	player, ok := players[key]
	if !ok {
		panic("player not found")
	}

	out := "Name: " + player.Name + "\n"
	out += "PlayerID: " + strconv.Itoa(int(player.ID)) + "\n"
	out += "Position: (" + strconv.Itoa(int(player.Pos.X)) + ", " + strconv.Itoa(int(player.Pos.Y)) + ")\n"
	if player.Appearance16 != "" {
		out += "Appearance16: " + player.Appearance16
	} else {
		out += "Appearance16: none"
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
		out += "\n"
		asset, ok := assets[companion.AssetID]
		if ok {
			out += "  Asset: " + asset.Code + "\n"
			if asset.DisplayName != "" {
				out += "  Name: " + asset.DisplayName + "\n"
			}
			out += "  Status: " + asset.Status + "\n"
		}
		if companionNeedsProfile(companion) {
			deriveCompanionAttitudes(companion)
		}
		out += "  Profile: bold:" + strconv.Itoa(int(companion.Boldness)) +
			" cautious:" + strconv.Itoa(int(companion.Caution)) +
			" kind:" + strconv.Itoa(int(companion.Kindness)) +
			" soul:" + strconv.Itoa(int(companion.Soul)) + "\n"
		out += "  Enc:" + strconv.Itoa(int(companion.Encounters)) +
			" Pos:" + strconv.Itoa(int(companion.FoundAt.X)) + "," + strconv.Itoa(int(companion.FoundAt.Y)) +
			" Turn:" + strconv.Itoa(int(companion.FoundTurn)) + "\n"
	}
	return out
}

func DescribeCompanionRegistry(kind string) string {
	kind = normalizeKey(kind)
	if kind == "" {
		panic("companion kind is required")
	}

	out := "Companion registry: " + kind + "\n"

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
			return describeDiaryEntry(entry)
		}
	}

	panic("player has no story diary entries")
}
