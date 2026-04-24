package nisse

type SacredMule struct {
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

var sacredMuleTrain []*SacredMule

func init() {
	sacredMuleTrain = []*SacredMule{
		{Name: "Juanillo", Ability: "keeps a wagon steady over bad hill roads", Description: "A sure-footed mule who does not waste strength on panic.", Strength: 2, Wisdom: 2, Dexterity: 1, Skill: "steadies the wagon road", Trait: "trusts the careful hand"},
		{Name: "Paco", Ability: "holds a load straight even when the slope turns cruel", Description: "A compact mule with a low opinion of haste and a high opinion of balance.", Strength: 3, Wisdom: 1, Dexterity: 1, Skill: "bears the steep pull", Trait: "stubborn in the useful way"},
		{Name: "Pepe", Ability: "finds the safest footing through shale, rut, and wash", Description: "A watchful mule who places each hoof as if the road were a question to answer.", Strength: 1, Wisdom: 3, Dexterity: 2, Skill: "finds the sure footing", Trait: "thinks with its hooves"},
		{Name: "Manolo", Ability: "endures long roads and longer tempers without breaking", Description: "A weathered mule who seems to have outlived several foolish owners.", Strength: 2, Wisdom: 2, Dexterity: 1, Skill: "outlasts the hard day", Trait: "patient with the road"},
		{Name: "Curro", Ability: "turns quickly in narrow lanes and stone farm bends", Description: "A quick-turning mule with a surprising talent for cramped ground.", Strength: 1, Wisdom: 2, Dexterity: 3, Skill: "cuts the narrow bend", Trait: "light in tight places"},
		{Name: "Perico", Ability: "senses danger on the road before men admit it", Description: "An alert mule whose ears know trouble before words do.", Strength: 1, Wisdom: 3, Dexterity: 1, Skill: "reads the roadside danger", Trait: "ears for the wrong silence"},
		{Name: "Rufino", Ability: "drives through rain, wind, and bad country without complaint", Description: "A dark, road-hardened mule made for weather that sends softer beasts sulking.", Strength: 2, Wisdom: 2, Dexterity: 1, Skill: "walks through bad weather", Trait: "hard under rain"},
		{Name: "Tomasin", Ability: "keeps to the home road even after panic and confusion", Description: "A homing mule with a gift for returning to the right gate and yard.", Strength: 1, Wisdom: 3, Dexterity: 1, Skill: "remembers the home road", Trait: "never forgets a gate"},
		{Name: "Chiqui", Ability: "slips past rough men and broken carts with sly timing", Description: "A smaller mule with bright eyes and a talent for surviving other people's foolishness.", Strength: 1, Wisdom: 2, Dexterity: 3, Skill: "dodges the broken road", Trait: "small and unbothered"},
		{Name: "Moreno", Ability: "holds the line when noise and blows unsettle the team", Description: "A dark-coated mule whose steadiness can shame a frightened man.", Strength: 3, Wisdom: 1, Dexterity: 1, Skill: "holds under pressure", Trait: "dark and immovable"},
		{Name: "Rubio", Ability: "keeps pace on high sunny roads and long loaded climbs", Description: "A pale mule with a bright hide and a long appetite for distance.", Strength: 2, Wisdom: 2, Dexterity: 1, Skill: "keeps the climbing pace", Trait: "likes the long rise"},
		{Name: "Canela", Ability: "draws small luck from a hard road and lightens grim travel", Description: "A warm-brown mule with a calm gaze and the kind of presence that makes bad roads feel shorter.", Strength: 1, Wisdom: 3, Dexterity: 2, Skill: "lightens the road's temper", Trait: "warm luck on a cold road"},
	}
}

func playerOwnsSacredMule(playerName string) bool {
	for assetID := uint64(1); assetID < nextAssetID; assetID++ {
		asset := assets[assetID]
		if asset == nil {
			continue
		}
		if asset.OwnerPlayer == playerName && asset.Kind == "companion" && asset.Subtype == "farm-mule" {
			return true
		}
	}
	return false
}

func nextSacredMule() *SacredMule {
	for _, entry := range sacredMuleTrain {
		if entry != nil && entry.MintedAssetID == 0 {
			return entry
		}
	}
	return nil
}

func grantSacredMuleCompanion(playerKey string, player *Player) (string, bool, string) {
	if playerOwnsSacredMule(player.Name) {
		return "A farm mule already keeps your road and does not trade one burden for another lightly.", false, ""
	}

	mule := nextSacredMule()
	if mule == nil {
		return "The old mule line has already passed into other roads. No sacred mule remains here to choose a new keeper.", false, ""
	}

	collection := ensureCompanionCollection(playerKey)
	id := nextCompanionID
	nextCompanionID++
	asset := createAsset("companion", "Farm Mule", mule.Name, player.Name, player.LineageOwner, player.Turns, player.Pos)
	mule.MintedAssetID = asset.ID
	companion := &Companion{
		ID:          id,
		AssetID:     asset.ID,
		OwnerPlayer: player.Name,
		Species: CompanionSpecies{
			Kind:        "land",
			Name:        "Farm Mule",
			SpawnWeight: 0,
			Ability:     mule.Ability,
			Description: mule.Description,
		},
		FoundAt:    player.Pos,
		FoundTurn:  player.Turns,
		Strength:   mule.Strength,
		Wisdom:     mule.Wisdom,
		Dexterity:  mule.Dexterity,
		Skill:      mule.Skill,
		Trait:      mule.Trait,
		Encounters: 0,
	}
	deriveCompanionAttitudes(companion)
	if playerBagHasRoom(player) {
		collection[id] = companion
		if player.ActiveCompanionID == 0 {
			player.ActiveCompanionID = id
		}
		return mule.Name + " the Farm Mule falls into step beside you and accepts your road.", true, asset.DisplayName
	}
	hiddenCompanions[asset.ID] = companion
	storeAssetOnTile(player.Pos, asset.ID, player.Name, player.LineageOwner, player.Turns)
	return mule.Name + " the Farm Mule is willing to follow, but your bag is full, so the bond is hidden here under your mark until you return.", true, asset.DisplayName
}
