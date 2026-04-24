package nisse

type SacredDonkey struct {
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

var sacredDonkeyTrain []*SacredDonkey

func init() {
	sacredDonkeyTrain = []*SacredDonkey{
		{Name: "Chico", Ability: "keeps to the surest track through broken farm roads", Description: "A steady little donkey with more sense than noise.", Strength: 2, Wisdom: 2, Dexterity: 1, Skill: "keeps the sure track", Trait: "small but deliberate"},
		{Name: "Ze", Ability: "waits out panic and settles heavy loads", Description: "A patient donkey who does not waste motion on fear.", Strength: 2, Wisdom: 3, Dexterity: 1, Skill: "steadies burden and handler", Trait: "slow heart, strong back"},
		{Name: "Tico", Ability: "picks narrow ways between stone walls and hedges", Description: "A quick-footed donkey who loves the tight path others avoid.", Strength: 1, Wisdom: 2, Dexterity: 3, Skill: "threads the narrow lane", Trait: "nimble in cramped ground"},
		{Name: "Nico", Ability: "finds dry footing in mud and churned yard", Description: "A mud-wise donkey who rarely puts a hoof wrong.", Strength: 1, Wisdom: 3, Dexterity: 2, Skill: "finds the dry step", Trait: "careful in soft earth"},
		{Name: "Bento", Ability: "carries awkward loads without complaint", Description: "A broad, work-worn donkey with the gift of balance.", Strength: 3, Wisdom: 2, Dexterity: 1, Skill: "bears the uneven burden", Trait: "made for long carrying"},
		{Name: "Micas", Ability: "notices weak fence, bad rope, and failing harness", Description: "An alert donkey whose eye for failing gear saves trouble early.", Strength: 1, Wisdom: 3, Dexterity: 1, Skill: "spots the weak point", Trait: "sees what gives way"},
		{Name: "Gaspar", Ability: "endures long road weather and little comfort", Description: "A road-seasoned donkey who keeps going when finer beasts would sulk.", Strength: 2, Wisdom: 2, Dexterity: 1, Skill: "outlasts bad weather", Trait: "hard under rain"},
		{Name: "Baltasar", Ability: "holds firm when startled beasts or men break order", Description: "A dark-coated donkey with a stubborn courage that steadies others.", Strength: 3, Wisdom: 1, Dexterity: 1, Skill: "holds the line", Trait: "stubborn at the right moment"},
		{Name: "Simao", Ability: "finds homeward turns even after wandering fields", Description: "A homing donkey who remembers gate, shed, and byre with uncanny certainty.", Strength: 1, Wisdom: 3, Dexterity: 1, Skill: "remembers the home lane", Trait: "never forgets a yard"},
		{Name: "Lourenco", Ability: "climbs rough hill farms without losing pace", Description: "A long-breathed donkey who treats slopes as ordinary business.", Strength: 2, Wisdom: 2, Dexterity: 1, Skill: "keeps the uphill pace", Trait: "made for the rise"},
		{Name: "Farrusco", Ability: "works through noise, quarrel, and rough handling", Description: "A shaggy, weathered donkey who has seen too much to startle easily.", Strength: 2, Wisdom: 2, Dexterity: 1, Skill: "ignores useless noise", Trait: "old temper, good heart"},
		{Name: "Estrelinha", Ability: "draws the lucky eye toward hidden path or dropped thing", Description: "A bright-natured donkey who seems to make small fortunate finds more likely.", Strength: 1, Wisdom: 3, Dexterity: 2, Skill: "stirs a lucky find", Trait: "carries a small star of luck"},
	}
}

func playerOwnsSacredDonkey(playerName string) bool {
	for assetID := uint64(1); assetID < nextAssetID; assetID++ {
		asset := assets[assetID]
		if asset == nil {
			continue
		}
		if asset.OwnerPlayer == playerName && asset.Kind == "companion" && asset.Subtype == "farm-donkey" {
			return true
		}
	}
	return false
}

func nextSacredDonkey() *SacredDonkey {
	for _, entry := range sacredDonkeyTrain {
		if entry != nil && entry.MintedAssetID == 0 {
			return entry
		}
	}
	return nil
}

func grantSacredDonkeyCompanion(playerKey string, player *Player) (string, bool, string) {
	if playerOwnsSacredDonkey(player.Name) {
		return "A farm donkey already knows your pace and does not trade one road for another lightly.", false, ""
	}

	donkey := nextSacredDonkey()
	if donkey == nil {
		return "The old donkey line has already passed into other roads. No sacred donkey remains here to choose a new keeper.", false, ""
	}

	collection := ensureCompanionCollection(playerKey)
	id := nextCompanionID
	nextCompanionID++
	asset := createAsset("companion", "Farm Donkey", donkey.Name, player.Name, player.LineageOwner, player.Turns, player.Pos)
	donkey.MintedAssetID = asset.ID
	companion := &Companion{
		ID:          id,
		AssetID:     asset.ID,
		OwnerPlayer: player.Name,
		Species: CompanionSpecies{
			Kind:        "land",
			Name:        "Farm Donkey",
			SpawnWeight: 0,
			Ability:     donkey.Ability,
			Description: donkey.Description,
		},
		FoundAt:    player.Pos,
		FoundTurn:  player.Turns,
		Strength:   donkey.Strength,
		Wisdom:     donkey.Wisdom,
		Dexterity:  donkey.Dexterity,
		Skill:      donkey.Skill,
		Trait:      donkey.Trait,
		Encounters: 0,
	}
	deriveCompanionAttitudes(companion)
	if playerBagHasRoom(player) {
		collection[id] = companion
		if player.ActiveCompanionID == 0 {
			player.ActiveCompanionID = id
		}
		return donkey.Name + " the Farm Donkey lowers its head and accepts your road.", true, asset.DisplayName
	}
	hiddenCompanions[asset.ID] = companion
	storeAssetOnTile(player.Pos, asset.ID, player.Name, player.LineageOwner, player.Turns)
	return donkey.Name + " the Farm Donkey is willing to follow, but your bag is full, so the bond is hidden here under your mark until you return.", true, asset.DisplayName
}
