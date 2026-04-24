package nisse

import "strconv"

type EncounterResult struct {
	EncounterID      string
	EncounterTitle   string
	Attitude         string
	Place            string
	Turn             uint64
	D20Roll          uint64
	PlayerStat       uint64
	CompanionBonus   uint64
	MonsterModifier  int64
	Total            int64
	Target           int64
	ResultBand       string
	SoulGain         uint64
	NerveGain        uint64
	VigorGain        uint64
	SenseGain        uint64
	Title            string
	Body             string
}

func encounterPlayerStat(player *Player, attitude string, monsterKind string) (uint64, string) {
	attitude = normalizeArrivalAttitude(attitude)
	switch normalizeKey(monsterKind) {
	case "monk":
		return player.Kindness, "The monk listens for Kindness."
	case "troll":
		return player.Kindness, "The troll answers only to Kindness."
	case "goblin":
		return player.Boldness, "The goblin buckles only before Boldness."
	case "dragon":
		return player.Caution, "The dragon punishes everything but true Caution."
	default:
		switch attitude {
		case "bold":
			return player.Boldness, "Bold meeting uses Boldness."
		case "kind":
			return player.Kindness, "Kind meeting uses Kindness."
		default:
			return player.Caution, "Cautious meeting uses Caution."
		}
	}
}

func encounterAttitudeBonus(attitude string, monsterKind string) (int64, string) {
	attitude = normalizeArrivalAttitude(attitude)
	switch normalizeKey(monsterKind) {
	case "monk":
		switch attitude {
		case "kind":
			return 5, "Kind mode lets you meet the monk openly."
		case "bold":
			return 0, "Boldness does not offend the monk, but it does not help much either."
		default:
			return -3, "Too much caution keeps you from hearing the warning plainly."
		}
	case "troll":
		switch attitude {
		case "kind":
			return 10, "Kind mode opens the only door a troll truly has."
		case "bold":
			return 0, "Boldness alone does not move the troll."
		default:
			return -5, "Caution keeps you alive, but does not win the troll over."
		}
	case "goblin":
		switch attitude {
		case "bold":
			return 10, "Bold mode breaks the goblin's confidence in its own tricks."
		case "cautious":
			return 0, "Caution sees the lie, but does not break the liar."
		default:
			return -5, "Kindness gives the goblin too much room to play at pain."
		}
	case "dragon":
		switch attitude {
		case "cautious":
			return 10, "Cautious mode keeps you from offering the dragon your own ruin."
		case "kind":
			return 0, "Kindness matters, but not before Caution."
		default:
			return -5, "Boldness alone is exactly what the dragon wants from the unready."
		}
	default:
		return 0, ""
	}
}

func heldCompanionEncounterBonus(playerKey string, attitude string, monsterKind string) (uint64, string, int64, string) {
	collection := companions[playerKey]
	if len(collection) == 0 {
		return 0, "", 0, ""
	}

	bestBase := uint64(0)
	bestText := ""
	bestSynergy := int64(0)
	bestSynergyText := ""
	bestScore := int64(-1)
	attitude = normalizeArrivalAttitude(attitude)

	for _, companion := range collection {
		if companion == nil {
			continue
		}
		asset := assets[companion.AssetID]
		if asset == nil || asset.Status != "held" {
			continue
		}
		if companion.Boldness == 0 && companion.Caution == 0 && companion.Kindness == 0 {
			deriveCompanionAttitudes(companion)
		}

		base := uint64(0)
		switch normalizeKey(monsterKind) {
		case "monk":
			base = companion.Kindness
		case "troll":
			base = companion.Kindness
		case "goblin":
			base = companion.Boldness
		case "dragon":
			base = companion.Caution
		default:
			switch attitude {
			case "bold":
				base = companion.Boldness
			case "kind":
				base = companion.Kindness
			default:
				base = companion.Caution
			}
		}

		nameKey := normalizeKey(companion.Species.Name)
		synergy := int64(0)
		synergyText := ""
		if normalizeKey(monsterKind) == "monk" {
			switch nameKey {
			case "forest fairy", "fairy":
				synergy = 4
				synergyText = companion.Species.Name + " helps the monk see the gentle shape of your road."
			case "snow reindeer", "reindeer", "farm dog":
				synergy = 2
				synergyText = companion.Species.Name + " makes the meeting feel warmer and more trustworthy."
			}
		} else if normalizeKey(monsterKind) == "troll" {
			switch nameKey {
			case "forest fairy", "fairy":
				synergy = 4
				synergyText = companion.Species.Name + " knows how to soften a hard meeting."
			case "snow reindeer", "reindeer", "farm dog":
				synergy = 2
				synergyText = companion.Species.Name + " keeps the meeting from turning sour too quickly."
			}
		} else if normalizeKey(monsterKind) == "goblin" {
			switch nameKey {
			case "forest bear", "bear":
				synergy = 4
				synergyText = companion.Species.Name + " makes goblin malice feel smaller than it is."
			case "wolverine", "forest wolverine", "tomcat", "night tomcat", "farm mule":
				synergy = 2
				synergyText = companion.Species.Name + " gives you the hard edge to break a goblin's nerve."
			}
		} else if normalizeKey(monsterKind) == "dragon" {
			switch nameKey {
			case "owl", "night owl":
				synergy = 4
				synergyText = companion.Species.Name + " reads the dangerous line before you step across it."
			case "deer", "forest deer", "fairy", "forest fairy", "porcupine", "forest porcupine":
				synergy = 2
				synergyText = companion.Species.Name + " keeps you from offering the dragon an easy mistake."
			}
		}

		score := int64(base) + synergy
		if score > bestScore {
			bestScore = score
			bestBase = base
			bestSynergy = synergy
			bestSynergyText = synergyText
			if normalizeKey(monsterKind) == "monk" {
				bestText = companion.Species.Name + " offers the strongest kindness in your company."
			} else if normalizeKey(monsterKind) == "troll" {
				bestText = companion.Species.Name + " offers the strongest kindness in your company."
			} else if normalizeKey(monsterKind) == "goblin" {
				bestText = companion.Species.Name + " offers the strongest boldness in your company."
			} else if normalizeKey(monsterKind) == "dragon" {
				bestText = companion.Species.Name + " offers the sharpest caution in your company."
			} else {
				bestText = companion.Species.Name + " lends " + attitude + " strength to the encounter."
			}
		}
	}

	if bestScore < 0 {
		return 0, "", 0, ""
	}
	return bestBase, bestText, bestSynergy, bestSynergyText
}

func heldCompanionAttitudePeak(playerKey string, attitude string) (uint64, string) {
	collection := companions[playerKey]
	if len(collection) == 0 {
		return 0, ""
	}

	best := uint64(0)
	bestText := ""
	for _, companion := range collection {
		if companion == nil {
			continue
		}
		asset := assets[companion.AssetID]
		if asset == nil || asset.Status != "held" {
			continue
		}
		if companion.Boldness == 0 && companion.Caution == 0 && companion.Kindness == 0 {
			deriveCompanionAttitudes(companion)
		}
		value := uint64(0)
		switch normalizeKey(attitude) {
		case "bold":
			value = companion.Boldness
		case "kind":
			value = companion.Kindness
		default:
			value = companion.Caution
		}
		if value > best {
			best = value
			bestText = companion.Species.Name + " carries your strongest " + normalizeKey(attitude) + " support."
		}
	}
	return best, bestText
}

func encounterBand(total int64, target int64) string {
	if total >= target+6 {
		return "triumph"
	}
	if total >= target {
		return "success"
	}
	if total >= target-6 {
		return "setback"
	}
	return "ruin"
}

func lowerStat(value *uint64, amount uint64) uint64 {
	if value == nil || amount == 0 {
		return 0
	}
	if *value <= amount {
		lost := *value
		*value = 0
		return lost
	}
	*value -= amount
	return amount
}

func outcomeTierForEncounterBand(band string) uint64 {
	switch normalizeKey(band) {
	case "triumph":
		return 3
	case "success":
		return 1
	default:
		return 0
	}
}

func resolveHillTrollEncounter(key string, player *Player, binding *TileStoryBinding, preface string, attitude string) string {
	attitude = normalizeArrivalAttitude(attitude)
	place := placeName(player.Pos)

	if playerHasMonsterMark(key, "troll") {
		body := preface + "\nAt " + place + ", the hill troll sees what already lives in your bearing and does not try to cow you. Its club stays low. Its loneliness is still there, but its edge is gone from your road."
		title := "The troll knows you"
		createDiaryEntry(key, "encounter", place, "day", title, body)
		latestStoryResults[key] = &StoryResult{
			StoryID:    binding.StoryID,
			StoryTitle: binding.Title,
			PathCode:   "",
			OutcomeTier: 1,
			Place:      place,
			Turn:       player.Turns,
			Title:      title,
			Body:       body,
		}
		return title
	}

	roll := d20(player, "hill-troll-roll")
	playerStat, playerStatText := encounterPlayerStat(player, attitude, "troll")
	attitudeBonus, attitudeText := encounterAttitudeBonus(attitude, "troll")
	companionBonus, companionText, synergyBonus, synergyText := heldCompanionEncounterBonus(key, attitude, "troll")
	total := int64(roll) + int64(playerStat) + attitudeBonus + int64(companionBonus) + synergyBonus
	target := int64(30)
	band := encounterBand(total, target)

	title := ""
	body := preface
	if body != "" {
		body += "\n"
	}

	switch band {
	case "triumph", "success":
		grantMonsterMark(key, "troll")
		player.Soul += 10
		player.Boldness += 10
		if band == "triumph" {
			title = "The hill troll yields"
			body += "At " + place + ", you meet the hill troll without flinching and without hatred. Something in your bearing reaches what the club never could. The troll lowers its arm, steps aside, and the old loneliness inside it finally has another language to answer to."
		} else {
			title = "The hill troll gives way"
			body += "At " + place + ", you hold the meeting long enough for the hill troll's bluster to break. It sees that it cannot make you live smaller than you are, and the path opens."
		}
		body += "\nYou carry away troll-strength now. No common wild force will make you shrink as it once did."
	case "setback":
		title = "The hill troll drives you back"
		lost := lowerStat(&player.Boldness, 1)
		body += "At " + place + ", you do not hold the meeting. The hill troll bulls you off the path and leaves you shaken, not ruined, but smaller in yourself than when you arrived."
		if lost > 0 {
			body += "\nPenalty: Boldness -" + strconv.Itoa(int(lost)) + "."
		}
	default:
		title = "Broken under the hill troll"
		lostSoul := lowerStat(&player.Soul, 1)
		lostBoldness := lowerStat(&player.Boldness, 2)
		body += "At " + place + ", the hill troll gets exactly what it wanted from you: the flinch, the yielding, the moment where you accept its size as your measure. You come away with your road still yours, but stripped and sore in spirit."
		if lostSoul > 0 || lostBoldness > 0 {
			body += "\nPenalty:"
			if lostSoul > 0 {
				body += " Soul -" + strconv.Itoa(int(lostSoul))
			}
			if lostBoldness > 0 {
				body += " Boldness -" + strconv.Itoa(int(lostBoldness))
			}
			body += "."
		}
	}

	body += "\n\nDice:"
	body += "\nD20: " + strconv.Itoa(int(roll))
	body += "\nPlayer stat: +" + strconv.Itoa(int(playerStat))
	if playerStatText != "" {
		body += " (" + playerStatText + ")"
	}
	if attitudeBonus > 0 {
		body += "\nAttitude bonus: +" + strconv.Itoa(int(attitudeBonus))
	} else {
		body += "\nAttitude bonus: " + strconv.Itoa(int(attitudeBonus))
	}
	if attitudeText != "" {
		body += " (" + attitudeText + ")"
	}
	body += "\nCompanion bonus: +" + strconv.Itoa(int(companionBonus))
	if companionText != "" {
		body += " (" + companionText + ")"
	}
	if synergyBonus != 0 {
		if synergyBonus > 0 {
			body += "\nCompanion fit: +" + strconv.Itoa(int(synergyBonus))
		} else {
			body += "\nCompanion fit: " + strconv.Itoa(int(synergyBonus))
		}
		if synergyText != "" {
			body += " (" + synergyText + ")"
		}
	}
	body += "\nTotal: " + strconv.Itoa(int(total))
	body += "\nTarget: " + strconv.Itoa(int(target))
	body += "\nResult: " + band

	createDiaryEntry(key, "encounter", place, "day", title, body)
	latestStoryResults[key] = &StoryResult{
		StoryID:       binding.StoryID,
		StoryTitle:    binding.Title,
		PathCode:      "",
		OutcomeTier:   outcomeTierForEncounterBand(band),
		LevelGain:     0,
		Place:         place,
		Turn:          player.Turns,
		SuccessChance: 0,
		Roll:          roll,
		Title:         title,
		Body:          body,
	}
	return title
}

func resolveBenevolentMonkEncounter(key string, player *Player, binding *TileStoryBinding, preface string, attitude string) string {
	attitude = normalizeArrivalAttitude(attitude)
	place := placeName(player.Pos)

	if playerHasDarkElfWarning(key) {
		body := preface + "\nAt " + place + ", the old monk remembers you and needs no second lesson. He only reminds you to keep clear sight and a whole heart when the middle forest grows too still."
		title := "The monk has already warned you"
		createDiaryEntry(key, "encounter", place, "day", title, body)
		latestStoryResults[key] = &StoryResult{StoryID: binding.StoryID, StoryTitle: binding.Title, OutcomeTier: 1, Place: place, Turn: player.Turns, Title: title, Body: body}
		return title
	}

	roll := d20(player, "benevolent-monk-roll")
	playerStat, playerStatText := encounterPlayerStat(player, attitude, "monk")
	attitudeBonus, attitudeText := encounterAttitudeBonus(attitude, "monk")
	companionBonus, companionText, synergyBonus, synergyText := heldCompanionEncounterBonus(key, attitude, "monk")
	total := int64(roll) + int64(playerStat) + attitudeBonus + int64(companionBonus) + synergyBonus
	target := int64(20)
	band := encounterBand(total, target)

	title := ""
	body := preface
	if body != "" {
		body += "\n"
	}

	switch band {
	case "triumph", "success":
		grantDarkElfWarning(key)
		if band == "triumph" {
			title = "The monk opens the warning"
			body += "At " + place + ", the monk studies you only long enough to see whether your kindness is soft or steady. When he finds it steady, he nods and tells you of the western border lands. The first mountains you meet there are the Goblin Ridge; treat them sternly. Beyond that you may find a troll; be kind to them. In the westernmost mountains the dragons keep their lair; be wary of them. But do not, under any circumstance, go into the forest there. There is dark magic in it, and dark elves keep their hidden edges at (7,6) and (8,4)."
		} else {
			title = "The monk gives warning"
			body += "At " + place + ", the monk receives you without hurry and gives you the kind of warning that is also a gift. He says the first western mountains are the Goblin Ridge, and should be met sternly. Past them you may find a troll, and should meet it kindly. In the westernmost mountains the dragons have their lair, and should be approached with care. But the forest there is worse: dark magic lies in it, and dark elves keep themselves hidden at (7,6) and (8,4)."
		}
		body += "\nTheir places now stand out to you on the map like cautions tied to the trees."
	case "setback":
		title = "The monk lets you pass in silence"
		body += "At " + place + ", the monk sees enough goodness in you not to turn you away, but not enough settled kindness to entrust you with his warning. He folds his hands and leaves the lesson unopened."
	default:
		title = "The monk withholds his warning"
		lost := lowerStat(&player.Kindness, 1)
		body += "At " + place + ", you do not meet the monk rightly. He does not curse you, or even rebuke you, but his silence makes plain that you came wanting something before you were ready to receive it."
		if lost > 0 {
			body += "\nPenalty: Kindness -" + strconv.Itoa(int(lost)) + "."
		}
	}

	body += "\n\nDice:"
	body += "\nD20: " + strconv.Itoa(int(roll))
	body += "\nPlayer stat: +" + strconv.Itoa(int(playerStat))
	if playerStatText != "" {
		body += " (" + playerStatText + ")"
	}
	if attitudeBonus > 0 {
		body += "\nAttitude bonus: +" + strconv.Itoa(int(attitudeBonus))
	} else {
		body += "\nAttitude bonus: " + strconv.Itoa(int(attitudeBonus))
	}
	if attitudeText != "" {
		body += " (" + attitudeText + ")"
	}
	body += "\nCompanion bonus: +" + strconv.Itoa(int(companionBonus))
	if companionText != "" {
		body += " (" + companionText + ")"
	}
	if synergyBonus != 0 {
		if synergyBonus > 0 {
			body += "\nCompanion fit: +" + strconv.Itoa(int(synergyBonus))
		} else {
			body += "\nCompanion fit: " + strconv.Itoa(int(synergyBonus))
		}
		if synergyText != "" {
			body += " (" + synergyText + ")"
		}
	}
	body += "\nTotal: " + strconv.Itoa(int(total))
	body += "\nTarget: " + strconv.Itoa(int(target))
	body += "\nResult: " + band

	createDiaryEntry(key, "encounter", place, "day", title, body)
	latestStoryResults[key] = &StoryResult{StoryID: binding.StoryID, StoryTitle: binding.Title, OutcomeTier: outcomeTierForEncounterBand(band), Place: place, Turn: player.Turns, Roll: roll, Title: title, Body: body}
	return title
}

func resolveDarkElvesEncounter(key string, player *Player, binding *TileStoryBinding, preface string, attitude string) string {
	attitude = normalizeArrivalAttitude(attitude)
	place := placeName(player.Pos)
	pegasusTile := player.Pos.X == 8 && player.Pos.Y == 4
	griffinTile := player.Pos.X == 7 && player.Pos.Y == 6

	if playerHasMonsterMark(key, "darkelves") {
		body := preface + "\nAt " + place + ", the dark elves find no open seam in you anymore. Their glamour does not settle, their cruelty does not root, and they fade back into the dark wood without purchase on your road."
		title := "The dark elves know you"
		createDiaryEntry(key, "encounter", place, "day", title, body)
		latestStoryResults[key] = &StoryResult{StoryID: binding.StoryID, StoryTitle: binding.Title, OutcomeTier: 1, Place: place, Turn: player.Turns, Title: title, Body: body}
		return title
	}

	roll := d20(player, "dark-elves-roll")
	boldCompanion, boldCompanionText := heldCompanionAttitudePeak(key, "bold")
	cautionCompanion, cautionCompanionText := heldCompanionAttitudePeak(key, "cautious")
	kindCompanion, kindCompanionText := heldCompanionAttitudePeak(key, "kind")

	boldModeBonus := int64(0)
	cautionModeBonus := int64(0)
	kindModeBonus := int64(0)
	attitudeText := ""
	switch attitude {
	case "bold":
		boldModeBonus = 10
		attitudeText = "Bold mode braces one side of you, but only one."
	case "kind":
		kindModeBonus = 10
		attitudeText = "Kind mode protects only the gentle part of you."
	default:
		cautionModeBonus = 10
		attitudeText = "Cautious mode sharpens only one line of defense."
	}

	target := int64(34)
	boldTotal := int64(roll) + int64(player.Boldness) + int64(boldCompanion) + boldModeBonus
	cautionTotal := int64(roll) + int64(player.Caution) + int64(cautionCompanion) + cautionModeBonus
	kindTotal := int64(roll) + int64(player.Kindness) + int64(kindCompanion) + kindModeBonus

	passedBold := boldTotal >= target
	passedCaution := cautionTotal >= target
	passedKind := kindTotal >= target
	passed := 0
	if passedBold {
		passed++
	}
	if passedCaution {
		passed++
	}
	if passedKind {
		passed++
	}

	band := "ruin"
	if passed == 3 {
		if boldTotal >= target+6 && cautionTotal >= target+6 && kindTotal >= target+6 {
			band = "triumph"
		} else {
			band = "success"
		}
	} else if passed == 2 {
		band = "setback"
	}

	title := ""
	body := preface
	if body != "" {
		body += "\n"
	}

	switch band {
	case "triumph", "success":
		grantMonsterMark(key, "darkelves")
		player.Soul += 10
		if band == "triumph" {
			title = "The dark elves lose their glamour"
			body += "At " + place + ", the dark elves try every door at once: fear, false prudence, and the counterfeit tenderness that leads a traveler off their own road. You close all three. Their glamour tears, and the hidden wood has nothing left to hold you with."
		} else {
			title = "The dark elves give way"
			body += "At " + place + ", the dark elves press on every weakness they know, but find none open enough to master. Their deceptions dim, and the dark wood gives you back your own shape."
		}
		body += "\nYou carry away a harder soul now. Western deception no longer finds you as easy to divide."
		if pegasusTile {
			grantText, granted, _ := grantSacredPegasusCompanion(key, player)
			if granted && grantText != "" {
				body += "\n\n" + grantText
			}
		}
		if griffinTile {
			grantText, granted, _ := grantSacredGriffinCompanion(key, player)
			if granted && grantText != "" {
				body += "\n\n" + grantText
			}
		}
	case "setback":
		title = "The dark elves almost divide you"
		body += "At " + place + ", the dark elves fail to take you whole, but they do slip inside one weakness before you pull free. You leave with your road still yours, though one part of you has been thinned."
		body += "\nPenalty:"
		if !passedBold {
			lost := lowerStat(&player.Boldness, 1)
			if lost > 0 {
				body += " Boldness -" + strconv.Itoa(int(lost))
			}
		}
		if !passedCaution {
			lost := lowerStat(&player.Caution, 1)
			if lost > 0 {
				body += " Caution -" + strconv.Itoa(int(lost))
			}
		}
		if !passedKind {
			lost := lowerStat(&player.Kindness, 1)
			if lost > 0 {
				body += " Kindness -" + strconv.Itoa(int(lost))
			}
		}
		body += "."
	default:
		title = "Unmade by the dark elves"
		body += "At " + place + ", the dark elves do exactly what the monk feared: they do not strike one thing in you, but all the seams between them. They set boldness against caution, caution against kindness, and leave you walking out thinner in every direction."
		lostSoul := lowerStat(&player.Soul, 1)
		body += "\nPenalty:"
		if lostSoul > 0 {
			body += " Soul -" + strconv.Itoa(int(lostSoul))
		}
		if !passedBold {
			lost := lowerStat(&player.Boldness, 1)
			if lost > 0 {
				body += " Boldness -" + strconv.Itoa(int(lost))
			}
		}
		if !passedCaution {
			lost := lowerStat(&player.Caution, 1)
			if lost > 0 {
				body += " Caution -" + strconv.Itoa(int(lost))
			}
		}
		if !passedKind {
			lost := lowerStat(&player.Kindness, 1)
			if lost > 0 {
				body += " Kindness -" + strconv.Itoa(int(lost))
			}
		}
		body += "."
	}

	body += "\n\nDice:"
	body += "\nD20: " + strconv.Itoa(int(roll))
	if attitudeText != "" {
		body += "\nAttitude: " + attitude + " (" + attitudeText + ")"
	}
	body += "\nBoldness line: " + strconv.Itoa(int(boldTotal)) + " vs " + strconv.Itoa(int(target))
	body += " [B " + strconv.Itoa(int(player.Boldness))
	if boldModeBonus > 0 {
		body += " + mode " + strconv.Itoa(int(boldModeBonus))
	}
	body += " + companion " + strconv.Itoa(int(boldCompanion)) + "]"
	if boldCompanionText != "" {
		body += " (" + boldCompanionText + ")"
	}
	body += "\nCaution line: " + strconv.Itoa(int(cautionTotal)) + " vs " + strconv.Itoa(int(target))
	body += " [C " + strconv.Itoa(int(player.Caution))
	if cautionModeBonus > 0 {
		body += " + mode " + strconv.Itoa(int(cautionModeBonus))
	}
	body += " + companion " + strconv.Itoa(int(cautionCompanion)) + "]"
	if cautionCompanionText != "" {
		body += " (" + cautionCompanionText + ")"
	}
	body += "\nKindness line: " + strconv.Itoa(int(kindTotal)) + " vs " + strconv.Itoa(int(target))
	body += " [K " + strconv.Itoa(int(player.Kindness))
	if kindModeBonus > 0 {
		body += " + mode " + strconv.Itoa(int(kindModeBonus))
	}
	body += " + companion " + strconv.Itoa(int(kindCompanion)) + "]"
	if kindCompanionText != "" {
		body += " (" + kindCompanionText + ")"
	}
	body += "\nResult: " + band

	createDiaryEntry(key, "encounter", place, "day", title, body)
	latestStoryResults[key] = &StoryResult{StoryID: binding.StoryID, StoryTitle: binding.Title, OutcomeTier: outcomeTierForEncounterBand(band), Place: place, Turn: player.Turns, Roll: roll, Title: title, Body: body}
	return title
}

func resolveGoblinEncounter(key string, player *Player, binding *TileStoryBinding, preface string, attitude string) string {
	attitude = normalizeArrivalAttitude(attitude)
	place := placeName(player.Pos)

	if playerHasMonsterMark(key, "goblin") {
		body := preface + "\nAt " + place + ", the goblins taste no sport in you anymore. Their lies slide off, their little cruelties fail to take root, and they shrink back into their own smallness."
		title := "The goblin knows you"
		createDiaryEntry(key, "encounter", place, "day", title, body)
		latestStoryResults[key] = &StoryResult{StoryID: binding.StoryID, StoryTitle: binding.Title, OutcomeTier: 1, Place: place, Turn: player.Turns, Title: title, Body: body}
		return title
	}

	roll := d20(player, "goblin-roll")
	playerStat, playerStatText := encounterPlayerStat(player, attitude, "goblin")
	attitudeBonus, attitudeText := encounterAttitudeBonus(attitude, "goblin")
	companionBonus, companionText, synergyBonus, synergyText := heldCompanionEncounterBonus(key, attitude, "goblin")
	total := int64(roll) + int64(playerStat) + attitudeBonus + int64(companionBonus) + synergyBonus
	target := int64(30)
	band := encounterBand(total, target)

	title := ""
	body := preface
	if body != "" {
		body += "\n"
	}

	switch band {
	case "triumph", "success":
		grantMonsterMark(key, "goblin")
		player.Soul += 10
		player.Caution += 10
		if band == "triumph" {
			title = "The goblin knot breaks"
			body += "At " + place + ", you do not answer trick with trick. You answer it with such plain boldness that the goblin knot loses faith in its own cunning. Their little malice caves in on itself."
		} else {
			title = "The goblin gives way"
			body += "At " + place + ", you push through the goblin's lie before it can harden into danger. It retreats into muttering and spite, but it no longer holds the upper hand."
		}
		body += "\nYou carry away goblin-knowledge now. Their deception no longer sits on you as it once did."
	case "setback":
		title = "The goblin wrong-foots you"
		lost := lowerStat(&player.Caution, 1)
		body += "At " + place + ", the goblin gets one clean lie past you. It is not enough to ruin you, but enough to leave you doubting what you should have seen."
		if lost > 0 {
			body += "\nPenalty: Caution -" + strconv.Itoa(int(lost)) + "."
		}
	default:
		title = "Snared by the goblin"
		lostSoul := lowerStat(&player.Soul, 1)
		lostCaution := lowerStat(&player.Caution, 2)
		body += "At " + place + ", the goblin leads you exactly where it wanted: into the cheap triumph of a smaller mind. You come away diminished, not by force, but by having believed what should have disgusted you."
		if lostSoul > 0 || lostCaution > 0 {
			body += "\nPenalty:"
			if lostSoul > 0 {
				body += " Soul -" + strconv.Itoa(int(lostSoul))
			}
			if lostCaution > 0 {
				body += " Caution -" + strconv.Itoa(int(lostCaution))
			}
			body += "."
		}
	}

	body += "\n\nDice:"
	body += "\nD20: " + strconv.Itoa(int(roll))
	body += "\nPlayer stat: +" + strconv.Itoa(int(playerStat))
	if playerStatText != "" {
		body += " (" + playerStatText + ")"
	}
	if attitudeBonus > 0 {
		body += "\nAttitude bonus: +" + strconv.Itoa(int(attitudeBonus))
	} else {
		body += "\nAttitude bonus: " + strconv.Itoa(int(attitudeBonus))
	}
	if attitudeText != "" {
		body += " (" + attitudeText + ")"
	}
	body += "\nCompanion bonus: +" + strconv.Itoa(int(companionBonus))
	if companionText != "" {
		body += " (" + companionText + ")"
	}
	if synergyBonus != 0 {
		if synergyBonus > 0 {
			body += "\nCompanion fit: +" + strconv.Itoa(int(synergyBonus))
		} else {
			body += "\nCompanion fit: " + strconv.Itoa(int(synergyBonus))
		}
		if synergyText != "" {
			body += " (" + synergyText + ")"
		}
	}
	body += "\nTotal: " + strconv.Itoa(int(total))
	body += "\nTarget: " + strconv.Itoa(int(target))
	body += "\nResult: " + band

	createDiaryEntry(key, "encounter", place, "day", title, body)
	latestStoryResults[key] = &StoryResult{StoryID: binding.StoryID, StoryTitle: binding.Title, OutcomeTier: outcomeTierForEncounterBand(band), Place: place, Turn: player.Turns, Roll: roll, Title: title, Body: body}
	return title
}

func resolveAshDrakeEncounter(key string, player *Player, binding *TileStoryBinding, preface string, attitude string) string {
	attitude = normalizeArrivalAttitude(attitude)
	place := placeName(player.Pos)

	if playerHasMonsterMark(key, "dragon") {
		body := preface + "\nAt " + place + ", the ash drake finds nothing rash enough in you to feed on. It watches, judges, and lets you pass because you are no longer easy fire."
		title := "The dragon knows you"
		createDiaryEntry(key, "encounter", place, "day", title, body)
		latestStoryResults[key] = &StoryResult{StoryID: binding.StoryID, StoryTitle: binding.Title, OutcomeTier: 1, Place: place, Turn: player.Turns, Title: title, Body: body}
		return title
	}

	roll := d20(player, "ash-drake-roll")
	playerStat, playerStatText := encounterPlayerStat(player, attitude, "dragon")
	attitudeBonus, attitudeText := encounterAttitudeBonus(attitude, "dragon")
	companionBonus, companionText, synergyBonus, synergyText := heldCompanionEncounterBonus(key, attitude, "dragon")
	total := int64(roll) + int64(playerStat) + attitudeBonus + int64(companionBonus) + synergyBonus
	target := int64(30)
	band := encounterBand(total, target)

	title := ""
	body := preface
	if body != "" {
		body += "\n"
	}

	switch band {
	case "triumph", "success":
		grantMonsterMark(key, "dragon")
		player.Soul += 10
		player.Kindness += 10
		if band == "triumph" {
			title = "The ash drake yields its hoard"
			body += "At " + place + ", you give the ash drake nothing foolish to strike. Your caution holds even under majesty and fire, and in that withheld ruin the great beast finds no purchase. The hoard opens instead."
		} else {
			title = "The ash drake relents"
			body += "At " + place + ", you do not give the ash drake the wrong step it waits for. Its force rolls past you without claiming you, and something of its old treasure spills back into the world."
		}
		body += "\nYou carry away dragon-knowledge now, and a portion of what the long hoard had kept."
		awardFoundPearls(key, "dragon-hoard:"+tileStoryKey(player.Pos), 10, "Recovered 10 pearls from the ash drake's loosened hoard.")
	case "setback":
		title = "The ash drake scorches your judgment"
		lost := lowerStat(&player.Caution, 1)
		body += "At " + place + ", the ash drake catches you in one bad reading of the moment. You escape, but with your judgment singed and your next step less certain."
		if lost > 0 {
			body += "\nPenalty: Caution -" + strconv.Itoa(int(lost)) + "."
		}
	default:
		title = "Burned by the ash drake"
		lostSoul := lowerStat(&player.Soul, 1)
		lostCaution := lowerStat(&player.Caution, 2)
		body += "At " + place + ", the ash drake takes the one foolish opening you gave it and turns it into fire, terror, and waste. You live, but only because it had no use for finishing what fear had already done."
		if lostSoul > 0 || lostCaution > 0 {
			body += "\nPenalty:"
			if lostSoul > 0 {
				body += " Soul -" + strconv.Itoa(int(lostSoul))
			}
			if lostCaution > 0 {
				body += " Caution -" + strconv.Itoa(int(lostCaution))
			}
			body += "."
		}
	}

	body += "\n\nDice:"
	body += "\nD20: " + strconv.Itoa(int(roll))
	body += "\nPlayer stat: +" + strconv.Itoa(int(playerStat))
	if playerStatText != "" {
		body += " (" + playerStatText + ")"
	}
	if attitudeBonus > 0 {
		body += "\nAttitude bonus: +" + strconv.Itoa(int(attitudeBonus))
	} else {
		body += "\nAttitude bonus: " + strconv.Itoa(int(attitudeBonus))
	}
	if attitudeText != "" {
		body += " (" + attitudeText + ")"
	}
	body += "\nCompanion bonus: +" + strconv.Itoa(int(companionBonus))
	if companionText != "" {
		body += " (" + companionText + ")"
	}
	if synergyBonus != 0 {
		if synergyBonus > 0 {
			body += "\nCompanion fit: +" + strconv.Itoa(int(synergyBonus))
		} else {
			body += "\nCompanion fit: " + strconv.Itoa(int(synergyBonus))
		}
		if synergyText != "" {
			body += " (" + synergyText + ")"
		}
	}
	body += "\nTotal: " + strconv.Itoa(int(total))
	body += "\nTarget: " + strconv.Itoa(int(target))
	body += "\nResult: " + band

	createDiaryEntry(key, "encounter", place, "day", title, body)
	latestStoryResults[key] = &StoryResult{StoryID: binding.StoryID, StoryTitle: binding.Title, OutcomeTier: outcomeTierForEncounterBand(band), Place: place, Turn: player.Turns, Roll: roll, Title: title, Body: body}
	return title
}

func DescribeMonsterMarks(playerName string) string {
	key := normalizeKey(playerName)
	player, ok := players[key]
	if !ok {
		panic("player not found")
	}

	out := "Monster marks for " + player.Name + "\n"
	for _, kind := range []string{"troll", "goblin", "dragon", "darkelves"} {
		state := "no"
		if playerHasMonsterMark(key, kind) {
			state = "yes"
		}
		out += "- " + kind + ": " + state + "\n"
	}
	return out
}
