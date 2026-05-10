package nisse

import "strconv"

type CompanionMintSpec struct {
	Type          string
	BoldSides     uint64
	KindnessSides uint64
	CautSides     uint64
	SoulSides     uint64
	MaxMints      uint64
	UniquePerLine bool
}

type CompanionClaim struct {
	ClaimID string
	Type    string
	Count   uint64
}

var companionMintSpecs map[string]*CompanionMintSpec
var earnedCompanionClaims map[string]map[string]*CompanionClaim
var companionMintedCounts map[string]uint64

func init() {
	companionMintSpecs = map[string]*CompanionMintSpec{
		"reindeer":  {Type: "reindeer", BoldSides: 6, KindnessSides: 6, CautSides: 6, SoulSides: 6, MaxMints: 100, UniquePerLine: true},
		"dog":       {Type: "dog", BoldSides: 4, KindnessSides: 8, CautSides: 6, SoulSides: 6, MaxMints: 0, UniquePerLine: true},
		"donkey":    {Type: "donkey", BoldSides: 6, KindnessSides: 6, CautSides: 4, SoulSides: 6, MaxMints: 0, UniquePerLine: true},
		"mule":      {Type: "mule", BoldSides: 8, KindnessSides: 4, CautSides: 6, SoulSides: 6, MaxMints: 0, UniquePerLine: true},
		"bear":      {Type: "bear", BoldSides: 6, KindnessSides: 6, CautSides: 4, SoulSides: 6, MaxMints: 100, UniquePerLine: true},
		"deer":      {Type: "deer", BoldSides: 4, KindnessSides: 6, CautSides: 8, SoulSides: 6, MaxMints: 100, UniquePerLine: true},
		"fairy":     {Type: "fairy", BoldSides: 3, KindnessSides: 8, CautSides: 6, SoulSides: 8, MaxMints: 100, UniquePerLine: true},
		"owl":       {Type: "owl", BoldSides: 4, KindnessSides: 6, CautSides: 8, SoulSides: 6, MaxMints: 100, UniquePerLine: true},
		"tomcat":    {Type: "tomcat", BoldSides: 6, KindnessSides: 4, CautSides: 8, SoulSides: 6, MaxMints: 100, UniquePerLine: true},
		"wolverine": {Type: "wolverine", BoldSides: 8, KindnessSides: 4, CautSides: 6, SoulSides: 6, MaxMints: 100, UniquePerLine: true},
		"porcupine": {Type: "porcupine", BoldSides: 4, KindnessSides: 6, CautSides: 8, SoulSides: 6, MaxMints: 100, UniquePerLine: true},
		"squirrel":  {Type: "squirrel", BoldSides: 4, KindnessSides: 6, CautSides: 8, SoulSides: 4, MaxMints: 100, UniquePerLine: true},
		"pegasus":   {Type: "pegasus", BoldSides: 8, KindnessSides: 8, CautSides: 8, SoulSides: 8, MaxMints: 20, UniquePerLine: true},
		"griffin":   {Type: "griffin", BoldSides: 8, KindnessSides: 6, CautSides: 8, SoulSides: 8, MaxMints: 20, UniquePerLine: true},
	}
	earnedCompanionClaims = make(map[string]map[string]*CompanionClaim)
	companionMintedCounts = make(map[string]uint64)
}

func companionMintSpec(companionType string) *CompanionMintSpec {
	return companionMintSpecs[normalizeKey(companionType)]
}

func companionMintLimitReached(companionType string) bool {
	spec := companionMintSpec(companionType)
	if spec == nil || spec.MaxMints == 0 {
		return false
	}
	return companionMintedCounts[spec.Type] >= spec.MaxMints
}

func ensureCompanionClaims(playerKey string) map[string]*CompanionClaim {
	if earnedCompanionClaims[playerKey] == nil {
		earnedCompanionClaims[playerKey] = make(map[string]*CompanionClaim)
	}
	return earnedCompanionClaims[playerKey]
}

func companionClaimID(companionType string) string {
	companionType = normalizeKey(companionType)
	switch companionType {
	case "reindeer":
		return "reindeerstory"
	case "dog":
		return "dogstory"
	case "donkey":
		return "donkeystory"
	case "mule":
		return "mulestory"
	case "bear":
		return "bearstory"
	case "deer":
		return "deerstory"
	case "fairy":
		return "fairystory"
	case "owl":
		return "owlstory"
	case "tomcat":
		return "tomcatstory"
	case "wolverine":
		return "wolverinestory"
	case "porcupine":
		return "porcupinestory"
	case "squirrel":
		return "squirrelstory"
	case "pegasus":
		return "pegasusstory"
	case "griffin":
		return "griffinstory"
	default:
		if companionType == "" {
			return ""
		}
		return companionType + "story"
	}
}

func playerOwnsCompanionType(playerName string, companionType string) bool {
	companionType = normalizeKey(companionType)
	for assetID := uint64(1); assetID < nextAssetID; assetID++ {
		asset := assets[assetID]
		if asset == nil {
			continue
		}
		if asset.OwnerPlayer == playerName && asset.Kind == "companion" && asset.Subtype == companionType {
			return true
		}
	}
	return false
}

func companionLabel(companionType string) string {
	value := normalizeKey(companionType)
	if value == "" {
		return "Companion"
	}
	first := value[0]
	if first >= 'a' && first <= 'z' {
		first = first - ('a' - 'A')
	}
	return string(first) + value[1:]
}

func companionSpeciesDomain(companionType string) string {
	switch normalizeKey(companionType) {
	case "pegasus", "griffin":
		return "mythic"
	case "fairy":
		return "spirit"
	default:
		return "land"
	}
}

func grantCompanionClaim(playerKey string, companionType string) string {
	spec := companionMintSpec(companionType)
	if spec == nil {
		panic("unknown companion kind")
	}
	if companionMintLimitReached(spec.Type) {
		panic("no more mint rights remain for this companion kind")
	}
	claimID := companionClaimID(spec.Type)
	claims := ensureCompanionClaims(playerKey)
	claim := claims[claimID]
	if claim == nil {
		claim = &CompanionClaim{ClaimID: claimID, Type: spec.Type, Count: 0}
		claims[claimID] = claim
	}
	claim.Type = spec.Type
	claim.ClaimID = claimID
	claim.Count++
	return claimID
}

func companionClaim(playerKey string, claimID string) *CompanionClaim {
	return ensureCompanionClaims(playerKey)[normalizeKey(claimID)]
}

func useCompanionClaim(playerKey string, claimID string) *CompanionClaim {
	claimID = normalizeKey(claimID)
	claims := ensureCompanionClaims(playerKey)
	claim := claims[claimID]
	if claim == nil || claim.Count == 0 {
		panic("no companion claim available")
	}
	claim.Count--
	if claim.Count == 0 {
		delete(claims, claimID)
	}
	return claim
}

func companionRollSeed(player *Player, claimID string, companionType string, slot string) uint64 {
	source := normalizeKey(player.Name) +
		":" + normalizeKey(claimID) +
		":" + normalizeKey(companionType) +
		":" + normalizeKey(slot) +
		":" + strconv.Itoa(int(nextAssetID)) +
		":" + strconv.Itoa(int(player.Turns))
	sum := uint64(0)
	for i := 0; i < len(source); i++ {
		sum += uint64(source[i]) * uint64(i+5)
	}
	return sum
}

func rollCompanionStat(player *Player, claimID string, companionType string, slot string, sides uint64) uint64 {
	if sides == 0 {
		return 0
	}
	return (companionRollSeed(player, claimID, companionType, slot) % sides) + 1
}

func mintCompanionProfile(player *Player, claimID string, companionType string) (uint64, uint64, uint64, uint64) {
	spec := companionMintSpec(companionType)
	if spec == nil {
		panic("unknown companion kind")
	}
	return rollCompanionStat(player, claimID, companionType, "bold", spec.BoldSides),
		rollCompanionStat(player, claimID, companionType, "kind", spec.KindnessSides),
		rollCompanionStat(player, claimID, companionType, "caut", spec.CautSides),
		rollCompanionStat(player, claimID, companionType, "soul", spec.SoulSides)
}

func mintCompanionWithProfile(playerKey string, player *Player, companionType string, displayName string, bold uint64, kindn uint64, caut uint64, soul uint64) (string, bool, string) {
	spec := companionMintSpec(companionType)
	if spec == nil {
		panic("unknown companion kind")
	}
	if spec.UniquePerLine && playerOwnsCompanionType(player.Name, spec.Type) {
		return "", false, ""
	}

	displayName = cleanName(displayName)
	if displayName == "" {
		displayName = companionLabel(spec.Type)
	}

	collection := ensureCompanionCollection(playerKey)
	id := nextCompanionID
	nextCompanionID++
	asset := createAsset("companion", spec.Type, displayName, player.Name, player.Turns, player.Pos)
	companion := &Companion{
		ID:          id,
		AssetID:     asset.ID,
		OwnerPlayer: player.Name,
		Species: CompanionSpecies{
			Kind: companionSpeciesDomain(spec.Type),
			Name: companionLabel(spec.Type),
		},
		FoundAt:    player.Pos,
		FoundTurn:  player.Turns,
		Boldness:   bold,
		Kindness:   kindn,
		Caution:    caut,
		Soul:       soul,
		Encounters: 0,
	}
	deriveCompanionAttitudes(companion)
	if playerBagHasRoom(player) {
		collection[id] = companion
		return "", true, asset.DisplayName
	}
	tileCompanions[asset.ID] = companion
	asset.OwnerPlayer = ""
	storeAssetOnTile(player.Pos, asset.ID, player.Turns)
	return "", true, asset.DisplayName
}

func MintEarnedCompanion(cur realm, playerName string, claimID string, displayName string) string {
	key, player, _ := ownedPlayer(playerName)
	claim := companionClaim(key, claimID)
	if claim == nil || claim.Count == 0 {
		panic("no earned companion from this claim is ready to mint")
	}
	spec := companionMintSpec(claim.Type)
	if companionMintLimitReached(spec.Type) {
		panic("mint cap reached for this companion kind")
	}
	if spec.UniquePerLine && playerOwnsCompanionType(player.Name, spec.Type) {
		panic("you already own this companion kind")
	}

	useCompanionClaim(key, claimID)
	name := cleanName(displayName)
	if name == "" {
		name = companionLabel(spec.Type)
	}
	releaseText := ""
	if spec.Type == "pegasus" || spec.Type == "griffin" {
		releaseText = releaseAllRegularCompanionsForMythic(key, player)
	}
	bold, kindn, caut, soul := mintCompanionProfile(player, claim.ClaimID, spec.Type)
	_, minted, mintedName := mintCompanionWithProfile(key, player, spec.Type, name, bold, kindn, caut, soul)
	if !minted {
		panic("companion could not be minted")
	}
	companionMintedCounts[spec.Type]++
	out := ""
	if releaseText != "" {
		out += releaseText + "\n"
	}
	out += mintedName + " is minted as your " + companionLabel(spec.Type) + "."
	return out
}

func DescribeCompanionClaims(playerName string) string {
	key := normalizeKey(playerName)
	player, ok := players[key]
	if !ok {
		panic("player not found")
	}
	claims := ensureCompanionClaims(key)
	out := "Companion claims for " + player.Name + "\n"
	count := 0
	for _, claim := range claims {
		if claim == nil || claim.Count == 0 {
			continue
		}
		count++
		out += "- " + claim.ClaimID + ": " + claim.Type + " x" + strconv.Itoa(int(claim.Count)) + "\n"
	}
	if count == 0 {
		out += "No earned companion claims."
	}
	return out
}
