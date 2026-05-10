package nisse

import "strconv"

type ResolveTotals struct {
	Bold     uint64
	Cautious uint64
	Kind     uint64
	Soul     uint64
}

func resolveTotals(player *Player, playerKey string, attitude string) ResolveTotals {
	totals := ResolveTotals{
		Bold:     player.Boldness,
		Cautious: player.Caution,
		Kind:     player.Kindness,
		Soul:     player.Soul,
	}

	switch normalizeArrivalAttitude(attitude) {
	case "bold":
		totals.Bold += 10
	case "kind":
		totals.Kind += 10
	default:
		totals.Cautious += 10
	}

	aggregate, ok := aggregateHeldCompanionProfile(playerKey)
	if ok {
		totals.Bold += aggregate.Boldness
		totals.Cautious += aggregate.Caution
		totals.Kind += aggregate.Kindness
		totals.Soul += aggregate.Soul
	}

	return totals
}

func resolveStatTotal(totals ResolveTotals, stat string) uint64 {
	switch normalizeKey(stat) {
	case "bold":
		return totals.Bold
	case "kind":
		return totals.Kind
	case "soul":
		return totals.Soul
	default:
		return totals.Cautious
	}
}

func resolvePrimaryStatForEncounter(monsterKind string) string {
	switch normalizeKey(monsterKind) {
	case "monk", "troll":
		return "kind"
	case "goblin":
		return "bold"
	case "dragon":
		return "cautious"
	default:
		return "cautious"
	}
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
		title := "troll_known"
		body := preface + "\nEncounter:troll\nState:known\nPlace:" + place
		createDiaryEntry(key, "encounter", place, "day", title, body)
		latestStoryResults[key] = &StoryResult{
			StoryID:     binding.StoryID,
			StoryTitle:  binding.Title,
			PathCode:    "",
			OutcomeTier: 1,
			Place:       place,
			Turn:        player.Turns,
			Title:       title,
			Body:        body,
		}
		return title
	}

	roll := d20(player, "hill-troll-roll")
	totals := resolveTotals(player, key, attitude)
	playerStat := resolveStatTotal(totals, resolvePrimaryStatForEncounter("troll"))
	total := int64(roll) + int64(playerStat)
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
		bonusText := grantAttitudeSuccessBonus(player, attitude)
		if band == "triumph" {
			title = "troll_triumph"
		} else {
			title = "troll_success"
		}
		body += "Encounter:troll\nOutcome:" + band + "\nPlace:" + place
		if bonusText != "" {
			body += "\n" + bonusText
		}
	case "setback":
		title = "troll_setback"
		lost := lowerStat(&player.Boldness, 1)
		body += "Encounter:troll\nOutcome:setback\nPlace:" + place
		if lost > 0 {
			body += "\nPenalty: Boldness -" + strconv.Itoa(int(lost)) + "."
		}
	default:
		title = "troll_ruin"
		lostSoul := lowerStat(&player.Soul, 1)
		lostBoldness := lowerStat(&player.Boldness, 2)
		body += "Encounter:troll\nOutcome:ruin\nPlace:" + place
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
	body += "\nResolved stat: kindness"
	body += "\nStat total: +" + strconv.Itoa(int(playerStat))
	body += "\nTotal: " + strconv.Itoa(int(total))
	body += "\nTarget: " + strconv.Itoa(int(target))
	body += "\nResult: " + band

	createDiaryEntry(key, "encounter", place, "day", title, body)
	latestStoryResults[key] = &StoryResult{
		StoryID:     binding.StoryID,
		StoryTitle:  binding.Title,
		PathCode:    "",
		OutcomeTier: outcomeTierForEncounterBand(band),
		LevelGain:   0,
		Place:       place,
		Turn:        player.Turns,
		Roll:        roll,
		Title:       title,
		Body:        body,
	}
	return title
}

func resolveBenevolentMonkEncounter(key string, player *Player, binding *TileStoryBinding, preface string, attitude string) string {
	attitude = normalizeArrivalAttitude(attitude)
	place := placeName(player.Pos)

	if playerHasDarkElfWarning(key) {
		title := "monk_known"
		body := preface + "\nEncounter:monk\nState:known\nPlace:" + place
		createDiaryEntry(key, "encounter", place, "day", title, body)
		latestStoryResults[key] = &StoryResult{StoryID: binding.StoryID, StoryTitle: binding.Title, OutcomeTier: 1, Place: place, Turn: player.Turns, Title: title, Body: body}
		return title
	}

	roll := d20(player, "benevolent-monk-roll")
	totals := resolveTotals(player, key, attitude)
	playerStat := resolveStatTotal(totals, resolvePrimaryStatForEncounter("monk"))
	total := int64(roll) + int64(playerStat)
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
		bonusText := grantAttitudeSuccessBonus(player, attitude)
		if band == "triumph" {
			title = "monk_triumph"
		} else {
			title = "monk_success"
		}
		body += "Encounter:monk\nOutcome:" + band + "\nPlace:" + place
		if bonusText != "" {
			body += "\n" + bonusText
		}
	case "setback":
		title = "monk_setback"
		body += "Encounter:monk\nOutcome:setback\nPlace:" + place
	default:
		title = "monk_ruin"
		lost := lowerStat(&player.Kindness, 1)
		body += "Encounter:monk\nOutcome:ruin\nPlace:" + place
		if lost > 0 {
			body += "\nPenalty: Kindness -" + strconv.Itoa(int(lost)) + "."
		}
	}

	body += "\n\nDice:"
	body += "\nD20: " + strconv.Itoa(int(roll))
	body += "\nResolved stat: kindness"
	body += "\nStat total: +" + strconv.Itoa(int(playerStat))
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
		title := "darkelves_known"
		body := preface + "\nEncounter:darkelves\nState:known\nPlace:" + place
		createDiaryEntry(key, "encounter", place, "day", title, body)
		latestStoryResults[key] = &StoryResult{StoryID: binding.StoryID, StoryTitle: binding.Title, OutcomeTier: 1, Place: place, Turn: player.Turns, Title: title, Body: body}
		return title
	}

	roll := d20(player, "dark-elves-roll")
	totals := resolveTotals(player, key, attitude)

	target := int64(34)
	boldTotal := int64(roll) + int64(totals.Bold)
	cautionTotal := int64(roll) + int64(totals.Cautious)
	kindTotal := int64(roll) + int64(totals.Kind)

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
		bonusText := grantAttitudeSuccessBonus(player, attitude)
		if band == "triumph" {
			title = "darkelves_triumph"
		} else {
			title = "darkelves_success"
		}
		body += "Encounter:darkelves\nOutcome:" + band + "\nPlace:" + place
		if pegasusTile {
			claimID := grantCompanionClaim(key, "pegasus")
			body += "\nMintRight:pegasus"
			body += "\nClaim: " + claimID
		}
		if griffinTile {
			claimID := grantCompanionClaim(key, "griffin")
			body += "\nMintRight:griffin"
			body += "\nClaim: " + claimID
		}
		if bonusText != "" {
			body += "\n" + bonusText
		}
	case "setback":
		title = "darkelves_setback"
		body += "Encounter:darkelves\nOutcome:setback\nPlace:" + place
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
		title = "darkelves_ruin"
		body += "Encounter:darkelves\nOutcome:ruin\nPlace:" + place
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
	body += "\nAttitude: " + attitude
	body += "\nBoldness line: " + strconv.Itoa(int(boldTotal)) + " vs " + strconv.Itoa(int(target))
	body += " [resolved " + strconv.Itoa(int(totals.Bold)) + "]"
	body += "\nCaution line: " + strconv.Itoa(int(cautionTotal)) + " vs " + strconv.Itoa(int(target))
	body += " [resolved " + strconv.Itoa(int(totals.Cautious)) + "]"
	body += "\nKindness line: " + strconv.Itoa(int(kindTotal)) + " vs " + strconv.Itoa(int(target))
	body += " [resolved " + strconv.Itoa(int(totals.Kind)) + "]"
	body += "\nResult: " + band

	createDiaryEntry(key, "encounter", place, "day", title, body)
	latestStoryResults[key] = &StoryResult{StoryID: binding.StoryID, StoryTitle: binding.Title, OutcomeTier: outcomeTierForEncounterBand(band), Place: place, Turn: player.Turns, Roll: roll, Title: title, Body: body}
	return title
}

func resolveGoblinEncounter(key string, player *Player, binding *TileStoryBinding, preface string, attitude string) string {
	attitude = normalizeArrivalAttitude(attitude)
	place := placeName(player.Pos)

	if playerHasMonsterMark(key, "goblin") {
		title := "goblin_known"
		body := preface + "\nEncounter:goblin\nState:known\nPlace:" + place
		createDiaryEntry(key, "encounter", place, "day", title, body)
		latestStoryResults[key] = &StoryResult{StoryID: binding.StoryID, StoryTitle: binding.Title, OutcomeTier: 1, Place: place, Turn: player.Turns, Title: title, Body: body}
		return title
	}

	roll := d20(player, "goblin-roll")
	totals := resolveTotals(player, key, attitude)
	playerStat := resolveStatTotal(totals, resolvePrimaryStatForEncounter("goblin"))
	total := int64(roll) + int64(playerStat)
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
		bonusText := grantAttitudeSuccessBonus(player, attitude)
		if band == "triumph" {
			title = "goblin_triumph"
		} else {
			title = "goblin_success"
		}
		body += "Encounter:goblin\nOutcome:" + band + "\nPlace:" + place
		if bonusText != "" {
			body += "\n" + bonusText
		}
	case "setback":
		title = "goblin_setback"
		lost := lowerStat(&player.Caution, 1)
		body += "Encounter:goblin\nOutcome:setback\nPlace:" + place
		if lost > 0 {
			body += "\nPenalty: Caution -" + strconv.Itoa(int(lost)) + "."
		}
	default:
		title = "goblin_ruin"
		lostSoul := lowerStat(&player.Soul, 1)
		lostCaution := lowerStat(&player.Caution, 2)
		body += "Encounter:goblin\nOutcome:ruin\nPlace:" + place
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
	body += "\nResolved stat: boldness"
	body += "\nStat total: +" + strconv.Itoa(int(playerStat))
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
		title := "dragon_known"
		body := preface + "\nEncounter:dragon\nState:known\nPlace:" + place
		createDiaryEntry(key, "encounter", place, "day", title, body)
		latestStoryResults[key] = &StoryResult{StoryID: binding.StoryID, StoryTitle: binding.Title, OutcomeTier: 1, Place: place, Turn: player.Turns, Title: title, Body: body}
		return title
	}

	roll := d20(player, "ash-drake-roll")
	totals := resolveTotals(player, key, attitude)
	playerStat := resolveStatTotal(totals, resolvePrimaryStatForEncounter("dragon"))
	total := int64(roll) + int64(playerStat)
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
		bonusText := grantAttitudeSuccessBonus(player, attitude)
		if band == "triumph" {
			title = "dragon_triumph"
		} else {
			title = "dragon_success"
		}
		body += "Encounter:dragon\nOutcome:" + band + "\nPlace:" + place
		awardFoundPearls(key, "dragon-hoard:"+tileStoryKey(player.Pos), 10, "Pearls+10 from dragon hoard.")
		if bonusText != "" {
			body += "\n" + bonusText
		}
	case "setback":
		title = "dragon_setback"
		lost := lowerStat(&player.Caution, 1)
		body += "Encounter:dragon\nOutcome:setback\nPlace:" + place
		if lost > 0 {
			body += "\nPenalty: Caution -" + strconv.Itoa(int(lost)) + "."
		}
	default:
		title = "dragon_ruin"
		lostSoul := lowerStat(&player.Soul, 1)
		lostCaution := lowerStat(&player.Caution, 2)
		body += "Encounter:dragon\nOutcome:ruin\nPlace:" + place
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
	body += "\nResolved stat: caution"
	body += "\nStat total: +" + strconv.Itoa(int(playerStat))
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
