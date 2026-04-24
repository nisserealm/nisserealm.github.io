package nisse

type SacredPegasus struct {
	Name          string
	Ability       string
	Description   string
	Strength      uint64
	Wisdom        uint64
	Dexterity     uint64
	Skill         string
	Trait         string
	MintedAssetID uint64
}

var sacredPegasusFlight []*SacredPegasus

func init() {
	sacredPegasusFlight = []*SacredPegasus{
		{Name: "Nephele", Ability: "crosses hard country with a sky-born ease", Description: "A pale pegasus with a mane like torn cloud in morning light.", Strength: 4, Wisdom: 4, Dexterity: 4, Skill: "takes the high road", Trait: "belongs more to air than earth"},
		{Name: "Aster", Ability: "keeps true bearing even when night and distance conspire", Description: "A dark pegasus whose hooves flash faintly as if touching stars.", Strength: 4, Wisdom: 4, Dexterity: 4, Skill: "finds the far line", Trait: "never loses the deep direction"},
		{Name: "Achlys", Ability: "passes through fear and confusion without letting them cling", Description: "A silver-grey pegasus with wings soft as hill mist.", Strength: 4, Wisdom: 4, Dexterity: 4, Skill: "slips the snare of dread", Trait: "untouched by lesser glamour"},
		{Name: "Eos", Ability: "turns first light into courage", Description: "A rose-pale pegasus with a sunrise sheen along the wings.", Strength: 4, Wisdom: 4, Dexterity: 4, Skill: "meets the day first", Trait: "lifts the heart by nearness"},
		{Name: "Aeolus", Ability: "makes long hard travel feel brief and clean", Description: "A rangy pegasus with a restless love of height and speed.", Strength: 4, Wisdom: 4, Dexterity: 4, Skill: "rides the upper current", Trait: "hates the cramped road"},
		{Name: "Selene", Ability: "keeps calm and grace under eerie light", Description: "A moon-white pegasus with a solemn patient gaze.", Strength: 4, Wisdom: 4, Dexterity: 4, Skill: "holds the silver hour", Trait: "does not spook at strangeness"},
		{Name: "Hyetos", Ability: "goes gladly through bad weather", Description: "A storm-colored pegasus with rain-dark wings and a warm temper.", Strength: 4, Wisdom: 4, Dexterity: 4, Skill: "takes the weather whole", Trait: "feels most alive under cloud"},
		{Name: "Phoebus", Ability: "breaks the oppressive spell of dark places", Description: "A bright-eyed pegasus with a fierce gold cast under the white.", Strength: 4, Wisdom: 4, Dexterity: 4, Skill: "carries the clear light", Trait: "refuses to bow to dread"},
		{Name: "Ouranos", Ability: "answers danger with joyous speed", Description: "A lighter-built pegasus who seems eager for the open sweep.", Strength: 4, Wisdom: 4, Dexterity: 4, Skill: "leaps into the clean escape", Trait: "finds delight where others find risk"},
		{Name: "Khione", Ability: "keeps strength where lesser creatures would thin and fail", Description: "A cold-bright pegasus with winter in the wing edges.", Strength: 4, Wisdom: 4, Dexterity: 4, Skill: "outlasts the cruel season", Trait: "hard as bright ice"},
		{Name: "Helios", Ability: "lifts weariness from the road and replaces it with stature", Description: "A broad-winged pegasus who carries itself like a vow kept.", Strength: 4, Wisdom: 4, Dexterity: 4, Skill: "raises the bearing", Trait: "makes the traveler seem larger"},
		{Name: "Aither", Ability: "moves as if weight were only a rumor", Description: "An almost translucent pegasus whose nearness feels unreal in the best way.", Strength: 4, Wisdom: 4, Dexterity: 4, Skill: "ignores the drag of the world", Trait: "half air already"},
	}
}

func playerOwnsSacredPegasus(playerName string) bool {
	for assetID := uint64(1); assetID < nextAssetID; assetID++ {
		asset := assets[assetID]
		if asset == nil {
			continue
		}
		if asset.OwnerPlayer == playerName && asset.Kind == "companion" && asset.Subtype == "sky-pegasus" {
			return true
		}
	}
	return false
}

func nextSacredPegasus() *SacredPegasus {
	for _, entry := range sacredPegasusFlight {
		if entry != nil && entry.MintedAssetID == 0 {
			return entry
		}
	}
	return nil
}

func renderSacredPegasusRegistry(out string) string {
	for _, entry := range sacredPegasusFlight {
		if entry == nil {
			continue
		}
		out += "- " + entry.Name
		if entry.MintedAssetID == 0 {
			out += " | owner: undiscovered\n"
			continue
		}
		asset := assets[entry.MintedAssetID]
		if asset == nil || asset.OwnerPlayer == "" {
			out += " | owner: undiscovered\n"
			continue
		}
		out += " | owner: " + asset.OwnerPlayer + "\n"
	}
	return out
}

func grantSacredPegasusCompanion(playerKey string, player *Player) (string, bool, string) {
	if playerOwnsSacredPegasus(player.Name) {
		return "A pegasus already answers your road and will not divide itself between skies.", false, ""
	}

	entry := nextSacredPegasus()
	if entry == nil {
		return "No captive pegasus remains here to be freed into your keeping.", false, ""
	}

	releaseText := releaseAllRegularCompanionsForPegasus(playerKey, player)
	collection := ensureCompanionCollection(playerKey)
	id := nextCompanionID
	nextCompanionID++
	asset := createAsset("companion", "Sky Pegasus", entry.Name, player.Name, player.LineageOwner, player.Turns, player.Pos)
	entry.MintedAssetID = asset.ID
	companion := &Companion{
		ID:          id,
		AssetID:     asset.ID,
		OwnerPlayer: player.Name,
		Species: CompanionSpecies{
			Kind:        "mythic",
			Name:        "Sky Pegasus",
			SpawnWeight: 0,
			Ability:     entry.Ability,
			Description: entry.Description,
		},
		FoundAt:    player.Pos,
		FoundTurn:  player.Turns,
		Strength:   entry.Strength,
		Wisdom:     entry.Wisdom,
		Dexterity:  entry.Dexterity,
		Skill:      entry.Skill,
		Trait:      entry.Trait,
		Encounters: 0,
	}
	deriveCompanionAttitudes(companion)
	collection[id] = companion
	player.ActiveCompanionID = id

	out := ""
	if releaseText != "" {
		out += releaseText
	}
	out += entry.Name + " the Sky Pegasus breaks free of the dark elves and chooses your road."
	return out, true, asset.DisplayName
}
