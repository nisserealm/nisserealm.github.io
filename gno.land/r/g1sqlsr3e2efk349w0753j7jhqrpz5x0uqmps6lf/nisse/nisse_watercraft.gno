package nisse

import "strconv"

type Boat struct {
	OwnerPlayer string
	Name        string
	Pos         Position
	Carried     bool
}

var boats map[string]*Boat

func init() {
	boats = make(map[string]*Boat)
}

func waterTravelTile(code uint8) bool {
	switch code {
	case 0, 1, 8, 11, 13, 14:
		return true
	default:
		return false
	}
}

func oceanTravelTile(code uint8) bool {
	return code == 0
}

func playerBoat(playerKey string) *Boat {
	return boats[playerKey]
}

func playerOwnsBoat(playerKey string) bool {
	return boats[playerKey] != nil
}

func playerCarriesBoat(playerKey string) bool {
	boat := boats[playerKey]
	return boat != nil && boat.Carried
}

func boatTravelBudget(playerKey string) uint64 {
	if playerCarriesBoat(playerKey) {
		return 8
	}
	return 0
}

func grantBoat(playerKey string, player *Player, source string) string {
	if playerOwnsBoat(playerKey) {
		return ""
	}

	boats[playerKey] = &Boat{
		OwnerPlayer: player.Name,
		Name:        "weathered skiff",
		Pos:         player.Pos,
		Carried:     true,
	}
	return "You gain a weathered skiff from " + source + "."
}

func BuyBoat(cur realm, playerName string) string {
	key, player, _ := ownedPlayer(playerName)
	code := GetTile(player.Pos.X, player.Pos.Y)
	if code != 11 {
		panic("boats can only be bought in fishing villages")
	}
	if playerOwnsBoat(key) {
		panic("you already own a boat")
	}
	if totalPearls(key) < 1 {
		panic("you need 1 pearl to buy a boat")
	}

	spendPearls(key, 1, "Spent 1 pearl on a weathered skiff.")
	grantBoat(key, player, placeName(player.Pos))
	createDiaryEntry(
		key,
		"boat",
		placeName(player.Pos),
		"day",
		"A skiff bought at the shore",
		"You buy a weathered skiff for 1 pearl. The village boatmen know how to let a traveler go without asking too many questions.\n\nThe boat is yours now. If you leave the coast for inland roads, it will be left behind on the last coastal tile you departed.",
	)
	return "A skiff bought at the shore"
}

func leaveBoatBehind(playerKey string, pos Position) bool {
	boat := boats[playerKey]
	if boat == nil || !boat.Carried {
		return false
	}

	boat.Carried = false
	boat.Pos = pos
	return true
}

func recoverBoatIfPresent(playerKey string, player *Player) bool {
	boat := boats[playerKey]
	if boat == nil || boat.Carried {
		return false
	}
	if !sameTile(boat.Pos, player.Pos) {
		return false
	}

	boat.Carried = true
	return true
}

func boatStatusSummary(playerKey string) string {
	boat := boats[playerKey]
	if boat == nil {
		return "none"
	}
	if boat.Carried {
		return boat.Name + " (carried)"
	}
	return boat.Name + " left at (" + strconv.Itoa(int(boat.Pos.X)) + ", " + strconv.Itoa(int(boat.Pos.Y)) + ")"
}

func DescribeBoat(playerName string) string {
	key := normalizeKey(playerName)
	player, ok := players[key]
	if !ok {
		panic("player not found")
	}

	boat := boats[key]
	if boat == nil {
		return "Boat for " + player.Name + "\nStatus: none"
	}

	out := "Boat for " + player.Name + "\n"
	out += "Name: " + boat.Name + "\n"
	if boat.Carried {
		out += "Status: carried\n"
		out += "WaterTravel: 8 moves"
		return out
	}

	out += "Status: left behind\n"
	out += "Position: (" + strconv.Itoa(int(boat.Pos.X)) + ", " + strconv.Itoa(int(boat.Pos.Y)) + ")"
	return out
}
