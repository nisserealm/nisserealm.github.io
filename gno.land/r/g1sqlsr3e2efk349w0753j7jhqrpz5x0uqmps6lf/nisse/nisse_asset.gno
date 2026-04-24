package nisse

import "strconv"

type Asset struct {
	ID            uint64
	Kind          string
	Subtype       string
	Code          string
	DisplayName   string
	OwnerPlayer   string
	OwnerLineage  Address
	Status        string
	CreatedTurn   uint64
	HistoryCount  uint64
	LastKnownPos  Position
}

type AssetHistoryEntry struct {
	ID         uint64
	AssetID    uint64
	Turn       uint64
	Event      string
	FromPlayer string
	ToPlayer   string
	Place      string
	Detail     string
}

type TileInventoryEntry struct {
	AssetID          uint64
	LastOwnerPlayer  string
	LastOwnerLineage Address
}

var assets map[uint64]*Asset
var assetHistory map[uint64]map[uint64]*AssetHistoryEntry
var assetCodes map[string]uint64
var assetKindCounters map[string]uint64
var tileInventories map[string][]*TileInventoryEntry
var nextAssetID uint64

func init() {
	assets = make(map[uint64]*Asset)
	assetHistory = make(map[uint64]map[uint64]*AssetHistoryEntry)
	assetCodes = make(map[string]uint64)
	assetKindCounters = make(map[string]uint64)
	tileInventories = make(map[string][]*TileInventoryEntry)
	nextAssetID = 1
}

func assetLabel(kind string, subtype string) string {
	if cleanName(subtype) != "" {
		return slugToken(subtype)
	}
	return slugToken(kind)
}

func slugToken(value string) string {
	out := ""
	dashPending := false
	for i := 0; i < len(value); i++ {
		ch := value[i]
		if ch >= 'A' && ch <= 'Z' {
			ch = ch + ('a' - 'A')
		}
		if (ch >= 'a' && ch <= 'z') || (ch >= '0' && ch <= '9') {
			if dashPending && len(out) > 0 {
				out += "-"
			}
			out += string(ch)
			dashPending = false
			continue
		}
		dashPending = len(out) > 0
	}
	if out == "" {
		return "asset"
	}
	return out
}

func tileInventoryKey(pos Position) string {
	return strconv.Itoa(int(pos.X)) + "," + strconv.Itoa(int(pos.Y))
}

func assetCarryPriority(asset *Asset) uint64 {
	if asset == nil {
		return 0
	}
	switch asset.Kind {
	case "companion":
		if asset.Subtype == "snow-reindeer" {
			return 120
		}
		return 100
	case "relic":
		return 90
	case "book":
		return 70
	case "scroll":
		return 60
	case "tool":
		return 40
	default:
		return 20
	}
}

func bagItemCount(playerName string) uint64 {
	count := uint64(0)
	for id := uint64(1); id < nextAssetID; id++ {
		asset, ok := assets[id]
		if !ok || asset.OwnerPlayer != playerName || asset.Status != "held" {
			continue
		}
		count++
	}
	return count
}

func playerBagHasRoom(player *Player) bool {
	if player == nil {
		return false
	}
	return bagItemCount(player.Name) < player.BagLimit
}

func storeAssetOnTile(pos Position, assetID uint64, lastOwnerPlayer string, lastOwnerLineage Address, turn uint64) {
	asset, ok := assets[assetID]
	if !ok {
		panic("asset not found")
	}
	key := tileInventoryKey(pos)
	tileInventories[key] = append(tileInventories[key], &TileInventoryEntry{
		AssetID:          assetID,
		LastOwnerPlayer:  lastOwnerPlayer,
		LastOwnerLineage: lastOwnerLineage,
	})
	asset.Status = "hidden_on_tile"
	asset.LastKnownPos = pos
	recordAssetHistory(assetID, turn, "hidden_on_tile", lastOwnerPlayer, "", placeName(pos), asset.Code+" is hidden with the tile's inventory.")
}

func removeTileInventoryEntry(pos Position, assetID uint64) {
	key := tileInventoryKey(pos)
	entries := tileInventories[key]
	if len(entries) == 0 {
		return
	}
	next := make([]*TileInventoryEntry, 0, len(entries))
	for _, entry := range entries {
		if entry != nil && entry.AssetID == assetID {
			continue
		}
		next = append(next, entry)
	}
	if len(next) == 0 {
		delete(tileInventories, key)
		return
	}
	tileInventories[key] = next
}

func DescribeTileInventory(x uint64, y uint64) string {
	pos := Position{X: x, Y: y}
	key := tileInventoryKey(pos)
	entries := tileInventories[key]
	out := "Hidden inventory at (" + strconv.Itoa(int(x)) + ", " + strconv.Itoa(int(y)) + ")\n"
	if len(entries) == 0 {
		return out + "No hidden items."
	}
	for _, entry := range entries {
		if entry == nil {
			continue
		}
		asset := assets[entry.AssetID]
		if asset == nil {
			continue
		}
		out += "- " + asset.Code
		if asset.DisplayName != "" {
			out += " \"" + asset.DisplayName + "\""
		}
		out += " [" + asset.Kind + "]"
		if entry.LastOwnerPlayer != "" {
			out += " last owner " + entry.LastOwnerPlayer
		}
		out += "\n"
	}
	return out
}

func romanNumeral(value uint64) string {
	if value == 0 {
		return "n"
	}

	pairs := []struct {
		Value  uint64
		Symbol string
	}{
		{1000, "m"},
		{900, "cm"},
		{500, "d"},
		{400, "cd"},
		{100, "c"},
		{90, "xc"},
		{50, "l"},
		{40, "xl"},
		{10, "x"},
		{9, "ix"},
		{5, "v"},
		{4, "iv"},
		{1, "i"},
	}

	out := ""
	remaining := value
	for _, pair := range pairs {
		for remaining >= pair.Value {
			out += pair.Symbol
			remaining -= pair.Value
		}
	}
	return out
}

func ensureAssetHistory(assetID uint64) map[uint64]*AssetHistoryEntry {
	if assetHistory[assetID] == nil {
		assetHistory[assetID] = make(map[uint64]*AssetHistoryEntry)
	}
	return assetHistory[assetID]
}

func createAsset(kind string, subtype string, displayName string, ownerPlayer string, ownerLineage Address, createdTurn uint64, pos Position) Asset {
	id := nextAssetID
	nextAssetID++

	label := assetLabel(kind, subtype)
	assetKindCounters[label]++
	code := label + "-" + romanNumeral(assetKindCounters[label])
	asset := Asset{
		ID:           id,
		Kind:         slugToken(kind),
		Subtype:      slugToken(subtype),
		Code:         code,
		DisplayName:  cleanName(displayName),
		OwnerPlayer:  ownerPlayer,
		OwnerLineage: ownerLineage,
		Status:       "held",
		CreatedTurn:  createdTurn,
		LastKnownPos: pos,
	}

	assets[id] = &asset
	assetCodes[code] = id
	recordAssetHistory(id, createdTurn, "minted", "", ownerPlayer, placeName(pos), code+" enters the realm.")
	return asset
}

func recordAssetHistory(assetID uint64, turn uint64, event string, fromPlayer string, toPlayer string, place string, detail string) {
	asset, ok := assets[assetID]
	if !ok {
		panic("asset not found")
	}

	asset.HistoryCount++
	ensureAssetHistory(assetID)[asset.HistoryCount] = &AssetHistoryEntry{
		ID:         asset.HistoryCount,
		AssetID:    assetID,
		Turn:       turn,
		Event:      event,
		FromPlayer: fromPlayer,
		ToPlayer:   toPlayer,
		Place:      place,
		Detail:     detail,
	}
}

func getAssetByCode(code string) *Asset {
	id, ok := assetCodes[slugToken(code)]
	if !ok {
		id, ok = assetCodes[cleanName(code)]
	}
	if !ok {
		panic("asset not found")
	}
	asset := assets[id]
	if asset == nil {
		panic("asset not found")
	}
	return asset
}

func DescribeAsset(code string) string {
	asset := getAssetByCode(code)
	out := "Asset: " + asset.Code + "\n"
	out += "Kind: " + asset.Kind + "\n"
	if asset.Subtype != "" && asset.Subtype != asset.Kind {
		out += "Subtype: " + asset.Subtype + "\n"
	}
	if asset.DisplayName != "" {
		out += "DisplayName: " + asset.DisplayName + "\n"
	}
	out += "OwnerPlayer: " + asset.OwnerPlayer + "\n"
	out += "OwnerLineage: " + string(asset.OwnerLineage) + "\n"
	out += "Status: " + asset.Status + "\n"
	out += "CreatedTurn: " + strconv.Itoa(int(asset.CreatedTurn)) + "\n"
	out += "HistoryEntries: " + strconv.Itoa(int(asset.HistoryCount)) + "\n"
	out += "LastKnownPosition: (" + strconv.Itoa(int(asset.LastKnownPos.X)) + ", " + strconv.Itoa(int(asset.LastKnownPos.Y)) + ")"
	return out
}

func DescribeAssetHistory(code string) string {
	asset := getAssetByCode(code)
	out := "History for " + asset.Code + "\n"
	entryMap := assetHistory[asset.ID]
	if len(entryMap) == 0 {
		return out + "No history."
	}

	for id := uint64(1); id <= asset.HistoryCount; id++ {
		entry, ok := entryMap[id]
		if !ok {
			continue
		}
		out += "- #" + strconv.Itoa(int(entry.ID)) + " turn " + strconv.Itoa(int(entry.Turn)) + " " + entry.Event
		if entry.FromPlayer != "" || entry.ToPlayer != "" {
			out += " [" + entry.FromPlayer + " -> " + entry.ToPlayer + "]"
		}
		if entry.Place != "" {
			out += " at " + entry.Place
		}
		if entry.Detail != "" {
			out += ": " + entry.Detail
		}
		out += "\n"
	}
	return out
}

func ListPlayerAssets(playerName string) string {
	key := normalizeKey(playerName)
	player, ok := players[key]
	if !ok {
		panic("player not found")
	}

	out := "Assets for " + player.Name + "\n"
	count := 0
	for id := uint64(1); id < nextAssetID; id++ {
		asset, ok := assets[id]
		if !ok || asset.OwnerPlayer != player.Name {
			continue
		}
		count++
		out += "- " + asset.Code + " [" + asset.Kind
		if asset.Subtype != "" && asset.Subtype != asset.Kind {
			out += "/" + asset.Subtype
		}
		out += "]"
		if asset.DisplayName != "" {
			out += " \"" + asset.DisplayName + "\""
		}
		out += " {" + asset.Status + "}"
		out += "\n"
	}
	if count == 0 {
		out += "No assets."
	}
	return out
}
