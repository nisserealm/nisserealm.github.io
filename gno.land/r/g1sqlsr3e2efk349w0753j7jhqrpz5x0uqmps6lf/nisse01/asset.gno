package nisse

import "strconv"

type Asset struct {
	ID           uint64
	Kind         string
	Subtype      string
	Code         string
	DisplayName  string
	OwnerPlayer  string
	Status       string
	CreatedTurn  uint64
	HistoryCount uint64
	LastKnownPos Position
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
	AssetID uint64
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
		if asset.Subtype == "reindeer" {
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

func storeAssetOnTile(pos Position, assetID uint64, turn uint64) {
	asset, ok := assets[assetID]
	if !ok {
		panic("asset not found")
	}
	previousOwner := asset.OwnerPlayer
	key := tileInventoryKey(pos)
	tileInventories[key] = append(tileInventories[key], &TileInventoryEntry{
		AssetID: assetID,
	})
	asset.OwnerPlayer = ""
	asset.Status = "on_tile"
	asset.LastKnownPos = pos
	recordAssetHistory(assetID, turn, "placed_on_tile", previousOwner, "", placeName(pos), asset.Code+" is left on the tile.")
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

func ensureAssetHistory(assetID uint64) map[uint64]*AssetHistoryEntry {
	if assetHistory[assetID] == nil {
		assetHistory[assetID] = make(map[uint64]*AssetHistoryEntry)
	}
	return assetHistory[assetID]
}

func createAsset(kind string, subtype string, displayName string, ownerPlayer string, createdTurn uint64, pos Position) Asset {
	id := nextAssetID
	nextAssetID++

	label := assetLabel(kind, subtype)
	assetKindCounters[label]++
	code := label + "-" + strconv.Itoa(int(assetKindCounters[label]))
	asset := Asset{
		ID:           id,
		Kind:         slugToken(kind),
		Subtype:      slugToken(subtype),
		Code:         code,
		DisplayName:  cleanName(displayName),
		OwnerPlayer:  ownerPlayer,
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
