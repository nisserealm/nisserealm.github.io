package nisse

type SacredReindeer struct {
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

var snowReindeerHerd []*SacredReindeer

func init() {
	snowReindeerHerd = []*SacredReindeer{
		{Name: "Iruno", Ability: "finds the coldest true path under blown snow", Description: "A bright-eyed reindeer who never loses the line of the winter road.", Strength: 2, Wisdom: 2, Dexterity: 1, Skill: "reads winter ground", Trait: "walks the oldest line"},
		{Name: "Maitza", Ability: "settles skittish herds and fearful travelers", Description: "A calm reindeer whose nearness lowers panic into steady breath.", Strength: 1, Wisdom: 3, Dexterity: 1, Skill: "steadies the frightened", Trait: "keeps a singer's heart"},
		{Name: "Skari", Ability: "crosses ridges quickly before the weather turns", Description: "A lean reindeer with a love of high routes and fast crossings.", Strength: 1, Wisdom: 1, Dexterity: 3, Skill: "takes the high pass", Trait: "swift on ridgewind"},
		{Name: "Fjora", Ability: "breaks trail through crusted drifts and river ice", Description: "A broad-shouldered reindeer with patience for the hardest ground.", Strength: 3, Wisdom: 1, Dexterity: 1, Skill: "breaks frozen trail", Trait: "shoulders the storm"},
		{Name: "Snari", Ability: "remembers distant camps and the safest return", Description: "A far-looking reindeer who rarely forgets a way once taken.", Strength: 1, Wisdom: 3, Dexterity: 1, Skill: "remembers camp lines", Trait: "carries the long road"},
		{Name: "Hjelta", Ability: "holds direction when the land turns white and blind", Description: "A winter guide whose steps stay true even in whitening fog.", Strength: 2, Wisdom: 3, Dexterity: 1, Skill: "keeps true north", Trait: "never loses bearing"},
		{Name: "Bruni", Ability: "finds hidden lichen and old grazing under ice", Description: "A sure-nosed grazer who uncovers nourishment where others give up.", Strength: 1, Wisdom: 2, Dexterity: 2, Skill: "finds buried forage", Trait: "gentle with hunger"},
		{Name: "Kveli", Ability: "spots danger first in low light and falling snow", Description: "A red-brown sentinel who watches the edge of the campfire's reach.", Strength: 2, Wisdom: 2, Dexterity: 1, Skill: "watches the dusk edge", Trait: "keeps first watch"},
		{Name: "Rosti", Ability: "stands fast against wolves and sudden charge", Description: "A fierce-antlered reindeer who dislikes being driven.", Strength: 3, Wisdom: 1, Dexterity: 1, Skill: "meets the rush", Trait: "fires at a challenge"},
		{Name: "Tjora", Ability: "answers song and leads by rhythm through the dark", Description: "A soft-footed reindeer who seems to move in time with old melodies.", Strength: 1, Wisdom: 2, Dexterity: 2, Skill: "follows the old songs", Trait: "hears what others hum"},
		{Name: "Veska", Ability: "crosses marsh edge, thaw, and meltwater cleanly", Description: "A long-stepping reindeer with surprising grace over broken ground.", Strength: 1, Wisdom: 2, Dexterity: 2, Skill: "steps the meltwater", Trait: "moves like a white shadow"},
		{Name: "Dravi", Ability: "draws hidden things into notice on fortunate nights", Description: "A proud reindeer whose presence seems to bring lost things into view.", Strength: 1, Wisdom: 3, Dexterity: 1, Skill: "stirs hidden finds", Trait: "favored by clear night"},
	}
}

func playerOwnsSnowReindeer(playerName string) bool {
	for assetID := uint64(1); assetID < nextAssetID; assetID++ {
		asset := assets[assetID]
		if asset == nil {
			continue
		}
		if asset.OwnerPlayer == playerName && asset.Kind == "companion" && asset.Subtype == "snow-reindeer" {
			return true
		}
	}
	return false
}

func nextSacredReindeer() *SacredReindeer {
	for _, entry := range snowReindeerHerd {
		if entry != nil && entry.MintedAssetID == 0 {
			return entry
		}
	}
	return nil
}
