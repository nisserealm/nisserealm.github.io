package nisse

import (
	"chain/runtime"
	"strconv"
	"strings"
)

func cleanName(value string) string {
	return strings.TrimSpace(value)
}

func normalizeKey(value string) string {
	return strings.ToLower(cleanName(value))
}

func ownedPlayer(playerName string) (string, *Player, Address) {
	caller := Address(runtime.OriginCaller())
	playerName = cleanName(playerName)
	key := normalizeKey(playerName)
	player, ok := players[key]
	if !ok {
		panic("player not found")
	}
	if player.Owner != caller {
		panic("only the player owner may do this")
	}
	recoverBoatIfPresent(key, player)
	return key, player, caller
}

func sameTile(a Position, b Position) bool {
	return a.X == b.X && a.Y == b.Y
}

func realmRoll(player *Player, salt string) uint64 {
	source := normalizeKey(player.Name) +
		":" + salt +
		":" + strconv.Itoa(int(player.Pos.X)) +
		":" + strconv.Itoa(int(player.Pos.Y)) +
		":" + strconv.Itoa(int(player.Turns)) +
		":" + strconv.Itoa(int(totalCompanions(normalizeKey(player.Name))))
	sum := uint64(0)
	for i := 0; i < len(source); i++ {
		sum += uint64(source[i]) * uint64(i+3)
	}
	return sum
}

func rollMod(player *Player, salt string, mod uint64) uint64 {
	if mod == 0 {
		return realmRoll(player, salt)
	}
	return realmRoll(player, salt) % mod
}

func percentRoll(player *Player, salt string) uint64 {
	return rollMod(player, salt, 100)
}

func diceRoll(player *Player, salt string, sides uint64) uint64 {
	if sides == 0 {
		panic("dice must have at least one side")
	}
	return rollMod(player, salt, sides) + 1
}

func d20(player *Player, salt string) uint64 {
	return diceRoll(player, salt, 20)
}

func d12(player *Player, salt string) uint64 {
	return diceRoll(player, salt, 12)
}

func d10(player *Player, salt string) uint64 {
	return diceRoll(player, salt, 10)
}

func d8(player *Player, salt string) uint64 {
	return diceRoll(player, salt, 8)
}

func d6(player *Player, salt string) uint64 {
	return diceRoll(player, salt, 6)
}

func d4(player *Player, salt string) uint64 {
	return diceRoll(player, salt, 4)
}

func weightedRoll(player *Player, salt string, weights []uint64) uint64 {
	total := uint64(0)
	for _, weight := range weights {
		total += weight
	}
	if total == 0 {
		panic("no weights configured")
	}

	needle := rollMod(player, salt, total)
	running := uint64(0)
	for idx, weight := range weights {
		running += weight
		if needle < running {
			return uint64(idx)
		}
	}
	panic("weighted roll fell through")
}
