package nisse

func advanceEventPlayer(player *Player) {
	player.Turns++
	if player.Turns%365 == 0 {
		player.AgeYears++
	}
}

func partialEventReward(reward uint64) uint64 {
	if reward == 0 {
		return 0
	}
	if reward == 1 {
		return 1
	}
	return reward / 2
}
