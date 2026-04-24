package nisse

type SacredDog struct {
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

var sacredDogPack []*SacredDog

func init() {
	sacredDogPack = []*SacredDog{
		{Name: "Lurko", Ability: "holds the flock-line and turns strays back", Description: "A broad-chested farm dog who understands the invisible edge of a moving flock.", Strength: 2, Wisdom: 2, Dexterity: 1, Skill: "keeps the flock-line", Trait: "never lets the field fray"},
		{Name: "Harri", Ability: "warns early when strangers or wolves draw near", Description: "A quick-eared dog with a low growl and excellent judgment about trouble.", Strength: 1, Wisdom: 3, Dexterity: 1, Skill: "reads distant trouble", Trait: "hears the wrong footstep"},
		{Name: "Basan", Ability: "drives loose stock out of hedges and thorn", Description: "A compact, stubborn dog who loves the thickest part of the work.", Strength: 2, Wisdom: 1, Dexterity: 2, Skill: "flushes hedge-runaways", Trait: "works where bramble bites"},
		{Name: "Otso", Ability: "stands his ground when bigger beasts press in", Description: "A heavy-shouldered dog who does not forget the shape of a threat.", Strength: 3, Wisdom: 1, Dexterity: 1, Skill: "meets the rush", Trait: "holds when others break"},
		{Name: "Amez", Ability: "settles frightened animals with steady nearness", Description: "A quiet herding dog whose calm reaches flock and traveler alike.", Strength: 1, Wisdom: 3, Dexterity: 1, Skill: "steadies the skittish", Trait: "carries a still heart"},
		{Name: "Izar", Ability: "finds the right path home in blowing weather", Description: "A path-wise dog who seems to remember tracks after the world has blurred them away.", Strength: 1, Wisdom: 2, Dexterity: 2, Skill: "keeps the road home", Trait: "remembers in wind"},
		{Name: "Egur", Ability: "works patiently through rain, mud, and long days", Description: "A dark, weatherproof dog more enduring than flashy.", Strength: 2, Wisdom: 2, Dexterity: 1, Skill: "outlasts the weather", Trait: "hard as wet timber"},
		{Name: "Zaldi", Ability: "runs wide and fast to turn the flock's edge", Description: "A long-legged dog who seems built of spring and field-sense.", Strength: 1, Wisdom: 1, Dexterity: 3, Skill: "cuts the wide arc", Trait: "fast on open ground"},
		{Name: "Aintz", Ability: "finds movement in mist before others notice it", Description: "A pale dog whose attention sharpens when the land grows unclear.", Strength: 1, Wisdom: 3, Dexterity: 1, Skill: "reads the mist edge", Trait: "keeps watch in whitening air"},
		{Name: "Urtzi", Ability: "holds courage when thunder or shouting unsettle the yard", Description: "A storm-steady dog who does not startle easily once duty is set.", Strength: 2, Wisdom: 2, Dexterity: 1, Skill: "steadies in storm", Trait: "untroubled by thunder"},
		{Name: "Zorri", Ability: "circles craftily and drives trouble where you want it", Description: "A sly red-coated dog with a talent for angles and feints.", Strength: 1, Wisdom: 2, Dexterity: 2, Skill: "works the clever angle", Trait: "likes to outthink the chase"},
		{Name: "Elur", Ability: "crosses drift and frost without losing the trail", Description: "A pale farm dog who moves easily over winter ground and frozen paths.", Strength: 1, Wisdom: 2, Dexterity: 2, Skill: "keeps the frost trail", Trait: "light on snow crust"},
	}
}

func playerOwnsSacredDog(playerName string) bool {
	for assetID := uint64(1); assetID < nextAssetID; assetID++ {
		asset := assets[assetID]
		if asset == nil {
			continue
		}
		if asset.OwnerPlayer == playerName && asset.Kind == "companion" && asset.Subtype == "farm-dog" {
			return true
		}
	}
	return false
}

func nextSacredDog() *SacredDog {
	for _, entry := range sacredDogPack {
		if entry != nil && entry.MintedAssetID == 0 {
			return entry
		}
	}
	return nil
}

func grantSacredDogCompanion(playerKey string, player *Player) (string, bool, string) {
	if playerOwnsSacredDog(player.Name) {
		return "A farm dog already keeps your road and does not leave it lightly.", false, ""
	}

	dog := nextSacredDog()
	if dog == nil {
		return "The old farm pack has already scattered into other roads. No sacred dog remains here to choose a new master.", false, ""
	}

	collection := ensureCompanionCollection(playerKey)
	id := nextCompanionID
	nextCompanionID++
	asset := createAsset("companion", "Farm Dog", dog.Name, player.Name, player.LineageOwner, player.Turns, player.Pos)
	dog.MintedAssetID = asset.ID
	companion := &Companion{
		ID:          id,
		AssetID:     asset.ID,
		OwnerPlayer: player.Name,
		Species: CompanionSpecies{
			Kind:        "land",
			Name:        "Farm Dog",
			SpawnWeight: 0,
			Ability:     dog.Ability,
			Description: dog.Description,
		},
		FoundAt:    player.Pos,
		FoundTurn:  player.Turns,
		Strength:   dog.Strength,
		Wisdom:     dog.Wisdom,
		Dexterity:  dog.Dexterity,
		Skill:      dog.Skill,
		Trait:      dog.Trait,
		Encounters: 0,
	}
	deriveCompanionAttitudes(companion)
	if playerBagHasRoom(player) {
		collection[id] = companion
		if player.ActiveCompanionID == 0 {
			player.ActiveCompanionID = id
		}
		return dog.Name + " the Farm Dog falls into step beside you and accepts your road.", true, asset.DisplayName
	}
	hiddenCompanions[asset.ID] = companion
	storeAssetOnTile(player.Pos, asset.ID, player.Name, player.LineageOwner, player.Turns)
	return dog.Name + " the Farm Dog is willing to follow, but your bag is full, so the bond is hidden here under your mark until you return.", true, asset.DisplayName
}
