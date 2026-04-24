package nisse

type MonsterTemplate struct {
	Name              string
	Kind              string
	Nature            string
	Clues             []string
	Gift              string
	Danger            uint64
	PearlReward       uint64
	FavoredAttitude   string
	SecondaryAttitude string
	RejectedAttitude  string
	PrimaryStat       string
	SupportStat       string
	SoulGain          uint64
	BoldnessGain      uint64
	CautionGain       uint64
	KindnessGain      uint64
	Reasoning         string
}

var monsterTemplates []MonsterTemplate

func init() {
	monsterTemplates = []MonsterTemplate{
		{
			Name:              "Goblin Knot",
			Kind:              "goblin",
			Nature:            "Small, mean, and clever enough to believe cruelty is wit. Alone they break quickly. In a knot they borrow courage from a leader.",
			Clues:             []string{"snickering under the roots", "bait left too neatly on a stone", "tiny bare prints circling back on themselves", "a charm bundle made to sour luck"},
			Gift:              "the broken secret behind goblin deceit",
			Danger:            12,
			PearlReward:       3,
			FavoredAttitude:   "bold",
			SecondaryAttitude: "cautious",
			RejectedAttitude:  "kind",
			PrimaryStat:       "boldness",
			SupportStat:       "caution",
			SoulGain:          10,
			CautionGain:       10,
			Reasoning:         "Goblins live by deception and borrowed spite. Overcoming one breaks the glamour of their lie, so the reward is a great increase in Soul and an equally great increase in Caution.",
		},
		{
			Name:              "Hill Troll",
			Kind:              "troll",
			Nature:            "A lonely, selfish being with a club and no better language than hunger, ownership, and wounded pride. What it lacks is not force but fellowship.",
			Clues:             []string{"stones rolled from the hillside", "an old bridge beam snapped in two", "a cooking fire much too large for any traveler", "deep prints circling the same lonely rise"},
			Gift:              "the still center that leaves trolls no way to cow you",
			Danger:            13,
			PearlReward:       4,
			FavoredAttitude:   "kind",
			SecondaryAttitude: "bold",
			RejectedAttitude:  "cautious",
			PrimaryStat:       "kindness",
			SupportStat:       "soul",
			SoulGain:          10,
			BoldnessGain:      10,
			Reasoning:         "A troll tries to make you flinch, yield, and live small. It is overcome by true Kindness rather than force or calculation. If you overcome one, your Soul deepens and your Boldness jumps so sharply that common wild force no longer makes you shrink.",
		},
		{
			Name:              "Ash Drake",
			Kind:              "dragon",
			Nature:            "A creature of unclear first making: cunning, ancient, proud, and wholly beyond the small violences that settle lesser foes. It judges presence and folly in a single breath.",
			Clues:             []string{"trees burnt from above rather than below", "stone melted into black glass", "a hot gust carrying soot and scale dust", "the smell of thunder with no rain behind it"},
			Gift:              "dragon-force, taken into the bones without taking on dragon-pride",
			Danger:            18,
			PearlReward:       6,
			FavoredAttitude:   "kind",
			SecondaryAttitude: "bold",
			RejectedAttitude:  "cautious",
			PrimaryStat:       "soul",
			SupportStat:       "boldness",
			SoulGain:          10,
			KindnessGain:      10,
			Reasoning:         "A dragon is raw sovereign force. To stand before one without being unmade enlarges Soul and deepens Kindness into majesty rather than panic, the only answer to force that does not become force's servant.",
		},
	}
}
