package nisse

import (
	"chain/runtime"
	"strconv"
)

type WorldResource struct {
	ID     uint64
	Kind   string
	Status string
	Pos    Position
	Level  uint64
	Tier   uint64
}

var terrain [][]uint8
var resources map[uint64]*WorldResource
var nextResourceID uint64
var spawnPoints []Position
var startCityPos Position

func init() {
	terrain = [][]uint8{
		{0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
		{0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 0, 1, 1, 1, 1, 0, 0, 0},
		{0, 0, 0, 1, 13, 3, 3, 2, 2, 2, 11, 3, 3, 3, 1, 1, 0, 0},
		{0, 1, 1, 1, 3, 3, 3, 12, 3, 10, 3, 3, 7, 3, 2, 1, 1, 0},
		{0, 1, 11, 3, 3, 5, 5, 10, 3, 10, 15, 3, 3, 3, 10, 4, 1, 0},
		{0, 8, 5, 3, 15, 12, 10, 7, 10, 10, 3, 3, 3, 5, 5, 1, 1, 0},
		{0, 1, 3, 3, 3, 4, 10, 3, 10, 4, 11, 2, 2, 5, 14, 1, 0, 0},
		{0, 1, 1, 3, 11, 2, 2, 2, 2, 2, 1, 1, 1, 1, 1, 0, 0, 0},
		{0, 0, 1, 1, 0, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0},
		{0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
	}

	resources = make(map[uint64]*WorldResource)
	nextResourceID = 1
	startCityPos = Position{X: 14, Y: 6}
	spawnPoints = []Position{
		startCityPos,
		{X: 8, Y: 3},
		{X: 3, Y: 5},
		{X: 9, Y: 5},
		{X: 13, Y: 5},
		{X: 5, Y: 7},
		{X: 10, Y: 7},
	}
}

func terrainName(code uint8) string {
	switch code {
	case 0:
		return "ocean"
	case 1:
		return "coastal"
	case 2:
		return "moor"
	case 3:
		return "forest"
	case 4:
		return "hills"
	case 5:
		return "farm"
	case 6:
		return "village"
	case 7:
		return "monastery"
	case 8:
		return "harbor"
	case 9:
		return "city"
	case 10:
		return "mountain"
	case 11:
		return "fishing_village"
	case 12:
		return "mountain_village"
	case 13:
		return "city_north"
	case 14:
		return "city_south"
	case 15:
		return "meadow"
	default:
		return "unknown"
	}
}

func terrainResources(code uint8) string {
	switch terrainName(code) {
	case "forest":
		return "berries,nuts"
	case "mountain":
		return "gems,gold"
	case "coastal", "harbor", "fishing_village":
		return "flint,shells"
	case "hills":
		return "iron,berries"
	case "meadow", "moor":
		return "herbs,vegetables"
	case "farm":
		return "milk,eggs"
	default:
		return ""
	}
}

func monthIndexForTurns(turns uint64) uint64 {
	return turns % 12
}

func seasonNameForTurns(turns uint64) string {
	switch monthIndexForTurns(turns) / 3 {
	case 0:
		return "spring"
	case 1:
		return "summer"
	case 2:
		return "fall"
	default:
		return "winter"
	}
}

func seasonMonthForTurns(turns uint64) uint64 {
	return monthIndexForTurns(turns) % 3
}

func placeName(pos Position) string {
	if name := currentPlaceName(pos); name != "" {
		return name
	}
	return terrainName(GetTile(pos.X, pos.Y))
}

func mapHeight() uint64 {
	return uint64(len(terrain))
}

func mapWidth() uint64 {
	if len(terrain) == 0 {
		return 0
	}
	return uint64(len(terrain[0]))
}

func inBounds(x uint64, y uint64) bool {
	return y < mapHeight() && x < mapWidth()
}

func isLand(x uint64, y uint64) bool {
	return inBounds(x, y) && terrain[y][x] != 0
}

func hasPlayerAt(pos Position) bool {
	for _, player := range players {
		if player.Pos.X == pos.X && player.Pos.Y == pos.Y {
			return true
		}
	}
	return false
}

func selectSpawnPoint() Position {
	if len(spawnPoints) == 0 {
		panic("no spawn points configured")
	}

	start := len(players) % len(spawnPoints)
	for offset := 0; offset < len(spawnPoints); offset++ {
		pos := spawnPoints[(start+offset)%len(spawnPoints)]
		if isLand(pos.X, pos.Y) && !hasPlayerAt(pos) {
			return pos
		}
	}

	panic("all spawn points are occupied")
}

func absDiff(a uint64, b uint64) uint64 {
	if a >= b {
		return a - b
	}
	return b - a
}

func createResource(kind string, status string, pos Position) {
	if !isLand(pos.X, pos.Y) {
		return
	}

	id := nextResourceID
	nextResourceID++

	level := uint64(1)
	tier := uint64(0)
	if stringsContains(kind, "house") {
		level = 0
		tier = 1
	}

	resources[id] = &WorldResource{
		ID:     id,
		Kind:   kind,
		Status: status,
		Pos:    pos,
		Level:  level,
		Tier:   tier,
	}
}

func spawnStarterWorld(seed uint64, center Position) {
	pattern := []Position{
		{X: center.X + 1, Y: center.Y},
		{X: center.X, Y: center.Y + 1},
		{X: center.X + 1, Y: center.Y + 1},
		{X: center.X + 2, Y: center.Y},
		{X: center.X, Y: center.Y + 2},
	}

	kinds := []string{
		"vacant-house",
		"wild-horse",
		"wild-hound",
		"wild-falcon",
		"pearl-cache",
		"knowledge-cache",
	}

	statuses := []string{
		"available",
		"wandering",
		"wandering",
		"wandering",
		"hidden",
		"hidden",
	}

	for i := 0; i < 3; i++ {
		index := int((seed + uint64(i)) % uint64(len(kinds)))
		pos := pattern[(int(seed)+i)%len(pattern)]
		createResource(kinds[index], statuses[index], pos)
	}
}

func startPosition() Position {
	return startCityPos
}

func terrainMoveCost(code uint8) uint64 {
	switch code {
	case 0:
		panic("cannot move through the sea")
	case 3:
		return 2
	case 4:
		return 2
	case 10:
		return 3
	default:
		return 1
	}
}

func travelBudget(player *Player) uint64 {
	return 3 + player.TravelBonus
}

func savedTravelBonus(budget uint64, spent uint64) uint64 {
	if spent >= budget {
		return 0
	}
	remaining := budget - spent
	if remaining > 1 {
		return 1
	}
	return remaining
}

func travelNodeIndex(x uint64, y uint64, width uint64) uint64 {
	return y*width + x
}

func landTravelPathDetails(start Position, dest Position) (uint64, bool) {
	if sameTile(start, dest) {
		return 0, false
	}

	width := mapWidth()
	height := mapHeight()
	total := width * height
	unreachable := ^uint64(0)
	dist := make([]uint64, total)
	visited := make([]bool, total)
	prev := make([]uint64, total)
	for i := uint64(0); i < total; i++ {
		dist[i] = unreachable
		prev[i] = unreachable
	}

	startIdx := travelNodeIndex(start.X, start.Y, width)
	destIdx := travelNodeIndex(dest.X, dest.Y, width)
	dist[startIdx] = 0

	for {
		bestCost := unreachable
		bestIdx := unreachable
		for idx := uint64(0); idx < total; idx++ {
			if visited[idx] {
				continue
			}
			if dist[idx] < bestCost {
				bestCost = dist[idx]
				bestIdx = idx
			}
		}

		if bestIdx == unreachable {
			break
		}
		if bestIdx == destIdx {
			cursor := destIdx
			leavesBoat := false
			for cursor != unreachable && cursor != startIdx {
				x := cursor % width
				y := cursor / width
				if !waterTravelTile(GetTile(x, y)) {
					leavesBoat = true
				}
				cursor = prev[cursor]
			}
			return bestCost, leavesBoat
		}

		visited[bestIdx] = true
		x := bestIdx % width
		y := bestIdx / width
		for dx := int64(-1); dx <= 1; dx++ {
			for dy := int64(-1); dy <= 1; dy++ {
				if dx == 0 && dy == 0 {
					continue
				}

				nxSigned := int64(x) + dx
				nySigned := int64(y) + dy
				if nxSigned < 0 || nySigned < 0 {
					continue
				}

				nx := uint64(nxSigned)
				ny := uint64(nySigned)
				if nx >= width || ny >= height || !isLand(nx, ny) {
					continue
				}

				nextIdx := travelNodeIndex(nx, ny, width)
				candidate := bestCost + terrainMoveCost(GetTile(nx, ny))
				if candidate < dist[nextIdx] {
					dist[nextIdx] = candidate
					prev[nextIdx] = bestIdx
				}
			}
		}
	}

	panic("no land route to that tile")
}

func boatTravelPathCost(start Position, dest Position) uint64 {
	if sameTile(start, dest) {
		return 0
	}
	if !waterTravelTile(GetTile(start.X, start.Y)) || !waterTravelTile(GetTile(dest.X, dest.Y)) {
		panic("boat travel requires coastal, harbor, or water tiles")
	}

	width := mapWidth()
	height := mapHeight()
	total := width * height
	unreachable := ^uint64(0)
	dist := make([]uint64, total)
	queue := make([]uint64, total)
	for i := uint64(0); i < total; i++ {
		dist[i] = unreachable
	}

	startIdx := travelNodeIndex(start.X, start.Y, width)
	destIdx := travelNodeIndex(dest.X, dest.Y, width)
	head := 0
	tail := 0
	dist[startIdx] = 0
	queue[tail] = startIdx
	tail++

	for head < tail {
		idx := queue[head]
		head++
		if idx == destIdx {
			return dist[idx]
		}

		x := idx % width
		y := idx / width
		for dx := int64(-1); dx <= 1; dx++ {
			for dy := int64(-1); dy <= 1; dy++ {
				if dx == 0 && dy == 0 {
					continue
				}

				nxSigned := int64(x) + dx
				nySigned := int64(y) + dy
				if nxSigned < 0 || nySigned < 0 {
					continue
				}

				nx := uint64(nxSigned)
				ny := uint64(nySigned)
				if nx >= width || ny >= height || !waterTravelTile(GetTile(nx, ny)) {
					continue
				}

				nextIdx := travelNodeIndex(nx, ny, width)
				if dist[nextIdx] == unreachable {
					dist[nextIdx] = dist[idx] + 1
					queue[tail] = nextIdx
					tail++
				}
			}
		}
	}

	panic("no boat route to that tile")
}

func TravelPlayer(cur realm, playerName string, x uint64, y uint64, attitude string) string {
	caller := Address(runtime.OriginCaller())
	playerName = cleanName(playerName)
	attitude = normalizeArrivalAttitude(attitude)

	key := normalizeKey(playerName)
	player, ok := players[key]
	if !ok {
		panic("player not found")
	}
	if player.Owner != caller {
		panic("only the player owner can travel")
	}
	if !inBounds(x, y) {
		panic("tile out of bounds")
	}

	dest := Position{X: x, Y: y}
	if sameTile(player.Pos, dest) {
		panic("player is already on that tile")
	}
	origin := player.Pos

	originCode := GetTile(origin.X, origin.Y)
	destCode := GetTile(x, y)
	cost := uint64(0)
	budget := uint64(0)
	useBoat := false
	boatDropped := false
	boatRecovered := false

	landCost := uint64(0)
	landLeavesBoat := false
	landFeasible := false
	if isLand(origin.X, origin.Y) && isLand(x, y) {
		landCost, landLeavesBoat = landTravelPathDetails(origin, dest)
		budget = travelBudget(player)
		if landCost <= budget {
			landFeasible = true
		}
	}

	boatCost := uint64(0)
	boatFeasible := false
	if playerCarriesBoat(key) && waterTravelTile(originCode) && waterTravelTile(destCode) {
		boatCost = boatTravelPathCost(origin, dest)
		if boatCost <= boatTravelBudget(key) {
			boatFeasible = true
		}
	}

	if destCode == 0 && !boatFeasible {
		panic("you need a carried boat to travel onto the water")
	}

	if boatFeasible && (!landFeasible || originCode == 0 || destCode == 0 || boatCost < landCost) {
		useBoat = true
		cost = boatCost
		budget = boatTravelBudget(key)
	} else if landFeasible {
		cost = landCost
		budget = travelBudget(player)
	} else if playerCarriesBoat(key) && waterTravelTile(originCode) && waterTravelTile(destCode) {
		panic("boat travel requires " + strconv.Itoa(int(boatCost)) + " water moves but only 8 are available")
	} else if isLand(origin.X, origin.Y) && isLand(x, y) {
		panic("travel requires " + strconv.Itoa(int(landCost)) + " moves but only " + strconv.Itoa(int(travelBudget(player))) + " are available")
	} else {
		panic("that route is not available")
	}

	if !useBoat && playerCarriesBoat(key) && waterTravelTile(originCode) && landLeavesBoat {
		boatDropped = leaveBoatBehind(key, origin)
	}

	player.Pos = dest
	if !useBoat {
		player.TravelBonus = savedTravelBonus(budget, cost)
	}
	boatRecovered = recoverBoatIfPresent(key, player)
	player.Turns++

	title := "A short crossing"
	body := "You travel to " + placeName(player.Pos) + ".\n"
	if useBoat {
		title = "A coastal sailing"
		body = "You sail to " + placeName(player.Pos) + ".\n"
		body += "Water cost: " + strconv.Itoa(int(cost)) + " moves from a boat budget of 8.\n"
	} else {
		body += "Travel cost: " + strconv.Itoa(int(cost)) + " move"
		if cost != 1 {
			body += "s"
		}
		body += " from a budget of " + strconv.Itoa(int(budget)) + ".\n"
		if player.TravelBonus > 0 {
			body += "You keep your footing and carry +" + strconv.Itoa(int(player.TravelBonus)) + " move into the next journey."
		} else {
			body += "You spend the whole turn's momentum getting there."
		}
	}
	if boatDropped {
		body += "\nYou leave your boat behind at (" + strconv.Itoa(int(origin.X)) + ", " + strconv.Itoa(int(origin.Y)) + ")."
	}
	if boatRecovered {
		body += "\nYou recover your boat from the shore and keep it with you again."
	}
	resolvedStory, storyTitle := resolveArrivalStoryOnEntry(key, player, attitude, body)
	if resolvedStory {
		return storyTitle
	}
	createDiaryEntry(key, "travel", placeName(player.Pos), "day", title, body)
	return title
}

func GetTile(x uint64, y uint64) uint8 {
	if !inBounds(x, y) {
		panic("tile out of bounds")
	}
	return terrain[y][x]
}

func stringsContains(value string, needle string) bool {
	for i := 0; i+len(needle) <= len(value); i++ {
		if value[i:i+len(needle)] == needle {
			return true
		}
	}
	return false
}
