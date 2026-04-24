package nisse

import "strconv"

type TileSceneSeed struct {
	Title    string
	Theme    string
	Text     string
	Keywords string
}

var tileSceneSeeds = map[string]*TileSceneSeed{
	"4,4": {
		Title:    "Deep Forest Edge",
		Theme:    "forest",
		Text:     "The forest thickens here into a darker pocket of trunks, moss, and close green shade where the open country gives way to roots and quiet watchfulness.",
		Keywords: "forest,moss,shade,pines,roots",
	},
	"4,5": {
		Title:    "Quiet Meadow Reach",
		Theme:    "meadow",
		Text:     "The land eases open here into a quieter meadow reach, with softer ground underfoot, low flowers among the growth, and a calm line of light running out toward the wider country.",
		Keywords: "meadow,flowers,soft-ground,open-light",
	},
	"5,4": {
		Title:    "Creekside Fields",
		Theme:    "farm",
		Text:     "You are walking into a gentle fold of worked land where a busy little farmstead keeps close to the creek. Blue birds circle high in the pale air, and even the fences seem to carry the patient rhythm of daily hands.",
		Keywords: "farm,creek,farmstead,blue-birds,workday",
	},
	"14,6": {
		Title:    "Town Streets",
		Theme:    "city_south",
		Text:     "Trade, errands, and conversation gather into these streets. Porters, peddlers, and small daily duties keep the place in motion from one doorway to the next, so that even a brief pause feels folded into a larger human rhythm.",
		Keywords: "city,market,street,harbor,trade",
	},
}

func tileSceneKey(pos Position) string {
	return strconv.Itoa(int(pos.X)) + "," + strconv.Itoa(int(pos.Y))
}

func tileSceneSeedAt(pos Position) *TileSceneSeed {
	return tileSceneSeeds[tileSceneKey(pos)]
}

func tileSceneTheme(pos Position) string {
	terrain := terrainName(GetTile(pos.X, pos.Y))
	if seed := tileSceneSeedAt(pos); seed != nil && seed.Theme != "" {
		return normalizeKey(seed.Theme)
	}
	if terrain == "fishing_village" || terrain == "mountain_village" {
		return "village"
	}
	if terrain == "city_north" || terrain == "city_south" {
		return "city"
	}
	return terrain
}

func tileSceneTitle(pos Position) string {
	if place := currentPlaceName(pos); place != "" {
		return place
	}

	if placeCanBeNamed(pos) {
		return unnamedPlaceLabel(pos)
	}

	if seed := tileSceneSeedAt(pos); seed != nil && seed.Title != "" {
		return seed.Title
	}

	terrain := terrainName(GetTile(pos.X, pos.Y))
	place := currentPlaceName(pos)
	if place != terrain {
		return place
	}

	switch terrain {
	case "coastal":
		if tileSceneTouches(pos, "harbor") {
			return "Harbor Road"
		}
		return "Salt Shore"
	case "moor":
		if tileSceneTouches(pos, "farm") {
			return "Fieldside Moor"
		}
		return "Open Moor"
	case "meadow":
		return "Open Meadow"
	case "forest":
		if tileSceneTouches(pos, "hills") || tileSceneTouches(pos, "mountain") {
			return "Pines Below the Ridge"
		}
		return "Forest Path"
	case "hills":
		if tileSceneTouches(pos, "forest") {
			return "High Hills Below the Pines"
		}
		return "Rolling Hills"
	case "mountain":
		if tileSceneTouches(pos, "forest") {
			return "Mountain Above the Pines"
		}
		return "Snowy Mountainside"
	case "farm":
		return "Farmstead"
	case "village":
		return "Village Lane"
	case "fishing_village":
		return "Fishing Village"
	case "mountain_village":
		return "Mountain Village"
	case "monastery":
		return "Monastery Quiet"
	case "harbor":
		return "Harbor Quarter"
	case "city":
		return "City Gate"
	case "city_north":
		return "Northern City"
	case "city_south":
		return "Southern City"
	case "ocean":
		return "Open Water"
	default:
		return "Island Path"
	}
}

func tileSceneText(pos Position) string {
	if seed := tileSceneSeedAt(pos); seed != nil && seed.Text != "" {
		return seed.Text
	}

	terrain := terrainName(GetTile(pos.X, pos.Y))
	out := ""
	switch terrain {
	case "coastal":
		out = "Salt wind moves over the stones here, and the edge of the sea keeps the whole place bright and restless."
	case "moor":
		out = "The land opens into uncultivated moor where wind runs long over coarse growth and the ground feels older than any road through it."
	case "meadow":
		out = "A broad meadow opens here, gentler than the rougher ground around it, with room for flowers, low grass, and an untroubled horizon."
	case "forest":
		out = "Pines and shadow gather close, and every path feels half-heard before it is fully seen."
	case "hills":
		out = "The land rises in long green-grey folds, with wind over the grass and stone showing through where the slope grows thin."
	case "mountain":
		out = "The ground steepens into harsher stone and old snow, where the air runs thinner and the footing turns treacherous."
	case "farm":
		out = "Worked earth, low fences, and narrow watercourses give this ground a cared-for feeling."
	case "village":
		out = "Low roofs, chimney smoke, and worn footpaths make the place feel lived in before anyone speaks."
	case "fishing_village":
		out = "Boats, nets, and salt-touched boards give the village a working shore rhythm, even when the tide itself is out of sight."
	case "mountain_village":
		out = "Steeper paths, stone walls, and roofs braced against the weather make this village feel tucked into harder country."
	case "monastery":
		out = "Stone, herb air, and a patient hush settle over the ground around you."
	case "harbor":
		out = "Tar, rope, and gull-cries keep the harbor in motion even when no one appears to be hurrying."
	case "city":
		out = "The city gathers trade and footsteps around itself, with more eyes on the road than most places ever hold."
	case "city_north":
		out = "The northern city feels older and more inward, with stone, workshops, and guarded routines holding close around its streets."
	case "city_south":
		out = "The southern city gathers trade and errands in a warmer, busier current, with more movement and open dealings near the street."
	case "ocean":
		out = "Open water rolls under a wide sky, and the island feels briefly far away."
	default:
		out = "The island keeps a small, passing quiet here."
	}

	if tileSceneTouches(pos, "ocean") || tileSceneTouches(pos, "coastal") || tileSceneTouches(pos, "harbor") {
		out += " Somewhere close by, water keeps its own patient noise."
	} else if tileSceneTouches(pos, "forest") && terrain != "forest" {
		out += " A darker line of trees stands close enough to change the wind."
	} else if (tileSceneTouches(pos, "hills") || tileSceneTouches(pos, "mountain")) && terrain != "hills" && terrain != "mountain" {
		out += " Higher ground watches from just beyond the next rise."
	} else if tileSceneTouches(pos, "farm") && terrain != "farm" {
		out += " Nearby, signs of steady work soften the edge of the wild ground."
	} else if tileSceneTouchesAnyVillage(pos) || tileSceneTouchesAnyCity(pos) {
		out += " You can feel nearby hearths and lived routines shaping the air."
	} else if tileSceneTouches(pos, "monastery") {
		out += " A monastic quiet seems to reach farther than the stone itself."
	} else {
		out += " Nothing here asks for a struggle or a vow; the place is simply itself for a moment."
	}

	playerCount := 0
	for _, other := range players {
		if sameTile(other.Pos, pos) {
			playerCount++
		}
	}
	if playerCount > 1 {
		out += " There are other footsteps in the ground as well, and the place feels gently shared."
	}

	resourceCount := 0
	for _, resource := range resources {
		if sameTile(resource.Pos, pos) {
			resourceCount++
		}
	}
	if resourceCount > 0 {
		out += " Something useful or curious also lies close at hand if you choose to look more closely."
	}

	if placeCanBeNamed(pos) {
		out += " No settled name seems to hold here yet."
	}

	return out
}

func tileSceneKeywords(pos Position) string {
	terrain := terrainName(GetTile(pos.X, pos.Y))
	out := terrain
	theme := tileSceneTheme(pos)
	if theme != terrain {
		out += "," + theme
	}

	place := currentPlaceName(pos)
	if place != "" && place != terrain {
		out += "," + normalizeKey(place)
	}
	if tileSceneTouches(pos, "forest") {
		out += ",trees"
	}
	if tileSceneTouches(pos, "ocean") || tileSceneTouches(pos, "coastal") || tileSceneTouches(pos, "harbor") {
		out += ",water"
	}
	if tileSceneTouches(pos, "hills") || tileSceneTouches(pos, "mountain") {
		out += ",ridge"
	}
	if tileSceneTouches(pos, "farm") {
		out += ",worked-land"
	}
	if tileSceneTouchesAnyVillage(pos) || tileSceneTouchesAnyCity(pos) {
		out += ",hearth"
	}
	if tileSceneTouches(pos, "monastery") {
		out += ",bells"
	}

	if seed := tileSceneSeedAt(pos); seed != nil && seed.Keywords != "" {
		out += "," + seed.Keywords
	}

	return out
}

func tileSceneImagePath(pos Position) string {
	return "/stories/fallback/images/tiles/" + strconv.Itoa(int(pos.X)) + "_" + strconv.Itoa(int(pos.Y)) + ".svg"
}

func tileSceneFallbackImagePath(pos Position) string {
	theme := tileSceneTheme(pos)
	if theme == "farm" {
		theme = "farmland"
	}
	return "/stories/fallback/images/themes/" + theme + ".svg"
}

func tileSceneTouchesAnyVillage(pos Position) bool {
	return tileSceneTouches(pos, "village") || tileSceneTouches(pos, "fishing_village") || tileSceneTouches(pos, "mountain_village")
}

func tileSceneTouchesAnyCity(pos Position) bool {
	return tileSceneTouches(pos, "city") || tileSceneTouches(pos, "city_north") || tileSceneTouches(pos, "city_south")
}

func tileSceneTouches(pos Position, terrain string) bool {
	if pos.X > 0 && terrainName(GetTile(pos.X-1, pos.Y)) == terrain {
		return true
	}
	if pos.X+1 < mapWidth() && terrainName(GetTile(pos.X+1, pos.Y)) == terrain {
		return true
	}
	if pos.Y > 0 && terrainName(GetTile(pos.X, pos.Y-1)) == terrain {
		return true
	}
	if pos.Y+1 < mapHeight() && terrainName(GetTile(pos.X, pos.Y+1)) == terrain {
		return true
	}
	return false
}

func DescribeTileScene(playerName string) string {
	key := normalizeKey(playerName)
	player, ok := players[key]
	if !ok {
		return "TileSceneID: none"
	}

	return describeTileSceneBlockAt(player.Pos)
}

func describeTileSceneBlock(player *Player) string {
	return describeTileSceneBlockAt(player.Pos)
}

func DescribeTileSceneAt(x uint64, y uint64) string {
	if !inBounds(x, y) {
		panic("tile out of bounds")
	}
	return describeTileSceneBlockAt(Position{X: x, Y: y})
}

func describeTileSceneBlockAt(pos Position) string {
	out := "TileSceneID: tile-" + strconv.Itoa(int(pos.X)) + "-" + strconv.Itoa(int(pos.Y)) + "\n"
	out += "TileSceneTitle: " + tileSceneTitle(pos) + "\n"
	out += "TileScenePlaceName: " + currentPlaceName(pos) + "\n"
	if placeCanBeNamed(pos) {
		out += "TileSceneCanName: yes\n"
	} else {
		out += "TileSceneCanName: no\n"
	}
	out += "TileSceneTheme: " + tileSceneTheme(pos) + "\n"
	out += "TileSceneImage: " + tileSceneImagePath(pos) + "\n"
	out += "TileSceneFallbackImage: " + tileSceneFallbackImagePath(pos) + "\n"
	out += "TileSceneKeywords: " + tileSceneKeywords(pos) + "\n"
	out += "TileSceneText: " + tileSceneText(pos) + "\n"
	if placeCanBeNamed(pos) {
		out += "TileScenePrompt: Type `nametile <name>` if you want to give this frontier place its first name, or `retreat` when you are ready to move on."
	} else {
		out += "TileScenePrompt: Type `retreat` when you are ready to move on."
	}
	return out
}
