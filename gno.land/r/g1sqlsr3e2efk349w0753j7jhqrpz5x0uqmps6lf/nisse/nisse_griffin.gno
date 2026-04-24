package nisse

type SacredGriffin struct {
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

var sacredGriffinEyrie []*SacredGriffin

func init() {
	sacredGriffinEyrie = []*SacredGriffin{
		{Name: "Aetos", Ability: "sees the ambush before it closes", Description: "A gold-eyed griffin with the patient gaze of a mountain hunter.", Strength: 4, Wisdom: 4, Dexterity: 4, Skill: "spots the closing trap", Trait: "lives above deceit"},
		{Name: "Grypos", Ability: "breaks fear with a single diving cry", Description: "A storm-feathered griffin with a hooked beak and terrible certainty.", Strength: 4, Wisdom: 4, Dexterity: 4, Skill: "strikes the heart first", Trait: "never doubts the drop"},
		{Name: "Thyros", Ability: "holds the high ridge against all comers", Description: "A broad-shouldered griffin with bronze pinions and a keeper's mind.", Strength: 4, Wisdom: 4, Dexterity: 4, Skill: "keeps the ridge", Trait: "made for the hard watch"},
		{Name: "Keryx", Ability: "carries warning faster than panic can spread", Description: "A lean bright griffin whose cry reaches farther than most horns.", Strength: 4, Wisdom: 4, Dexterity: 4, Skill: "outruns the alarm", Trait: "comes before disaster"},
		{Name: "Notos", Ability: "rides troubled wind without losing command", Description: "A dark-winged griffin who seems pleased by weather that grounds lesser things.", Strength: 4, Wisdom: 4, Dexterity: 4, Skill: "masters the crosswind", Trait: "likes the difficult sky"},
		{Name: "Lykon", Ability: "hunts the hidden thing in rough country", Description: "A slate-feathered griffin with a lion's patience and an eagle's cruelty.", Strength: 4, Wisdom: 4, Dexterity: 4, Skill: "finds the concealed prey", Trait: "trusts instinct over noise"},
		{Name: "Pyrros", Ability: "answers threat with blazing force", Description: "A copper-maned griffin whose temper rises like sparks from iron.", Strength: 4, Wisdom: 4, Dexterity: 4, Skill: "meets force with force", Trait: "burns hot in danger"},
		{Name: "Sideros", Ability: "endures shock, cold, and long heights", Description: "A steel-feathered griffin built like a fortress set in motion.", Strength: 4, Wisdom: 4, Dexterity: 4, Skill: "outlasts the harsh climb", Trait: "hard as the pass stone"},
		{Name: "Zephyros", Ability: "turns speed into perfect timing", Description: "A pale swift griffin who seems to lean on the wind rather than fight it.", Strength: 4, Wisdom: 4, Dexterity: 4, Skill: "arrives at the exact moment", Trait: "loves the open sweep"},
		{Name: "Orion", Ability: "keeps bearing through distance and darkness", Description: "A night-marked griffin whose eyes hold the line between stars and earth.", Strength: 4, Wisdom: 4, Dexterity: 4, Skill: "holds the far pursuit", Trait: "never loses the quarry"},
		{Name: "Chryson", Ability: "finds what was hidden by greed or fear", Description: "A bright-crested griffin with a treasure-finder's disdain for lies.", Strength: 4, Wisdom: 4, Dexterity: 4, Skill: "uncovers the hidden hoard", Trait: "despises concealment"},
		{Name: "Kratos", Ability: "makes lesser terrors feel suddenly small", Description: "A black-taloned griffin whose presence alone changes the balance of a place.", Strength: 4, Wisdom: 4, Dexterity: 4, Skill: "masters the air of fear", Trait: "carries command in the bones"},
	}
}

func playerOwnsSacredGriffin(playerName string) bool {
	for assetID := uint64(1); assetID < nextAssetID; assetID++ {
		asset := assets[assetID]
		if asset == nil {
			continue
		}
		if asset.OwnerPlayer == playerName && asset.Kind == "companion" && asset.Subtype == "sky-griffin" {
			return true
		}
	}
	return false
}

func nextSacredGriffin() *SacredGriffin {
	for _, entry := range sacredGriffinEyrie {
		if entry != nil && entry.MintedAssetID == 0 {
			return entry
		}
	}
	return nil
}

func renderSacredGriffinRegistry(out string) string {
	for _, entry := range sacredGriffinEyrie {
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

func grantSacredGriffinCompanion(playerKey string, player *Player) (string, bool, string) {
	if playerOwnsSacredPegasus(player.Name) {
		return "The dark elves held a griffin here once, but none will choose a rider already bound to a pegasus.", false, ""
	}
	if playerOwnsSacredGriffin(player.Name) {
		return "A griffin already keeps your higher road and will not divide itself between eyries.", false, ""
	}

	entry := nextSacredGriffin()
	if entry == nil {
		return "No captive griffin remains here to be freed into your keeping.", false, ""
	}

	releaseText := releaseAllRegularCompanionsForPegasus(playerKey, player)
	collection := ensureCompanionCollection(playerKey)
	id := nextCompanionID
	nextCompanionID++
	asset := createAsset("companion", "Sky Griffin", entry.Name, player.Name, player.LineageOwner, player.Turns, player.Pos)
	entry.MintedAssetID = asset.ID
	companion := &Companion{
		ID:          id,
		AssetID:     asset.ID,
		OwnerPlayer: player.Name,
		Species: CompanionSpecies{
			Kind:        "mythic",
			Name:        "Sky Griffin",
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
	out += entry.Name + " the Sky Griffin breaks free of the dark elves and chooses your road."
	return out, true, asset.DisplayName
}
