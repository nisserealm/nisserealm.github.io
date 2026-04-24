package dragon0

import (
	"chain/runtime"
	"strconv"
	"strings"
)

// ──────────────
// Types & State
// ──────────────

type Address string

type Dragon struct {
	Owner        Address
	ID           uint64
	Color        string
	Constitution string
	Pearls       uint64
	Level        uint64
}

type Town struct {
	Owner  Address
	Name   string
	Amount uint64
}

type Listing struct {
	Name        string
	Price       uint64
	Description string
	Quantity    uint64
	Location    string
}

type Message struct {
	FromCitizen string
	ToCitizen   string
	Body        string
}

type Citizen struct {
	Owner         Address
	Name          string
	TownName      string
	Role          string
	Listings      map[string]*Listing
	MessageBoard  map[uint64]*Message
	NextMessageID uint64
}

var dragons      map[uint64]*Dragon
var towns        map[string]*Town
var citizens     map[string]*Citizen
var nextDragonID uint64

func cleanName(value string) string {
	return strings.TrimSpace(value)
}

func normalizeKey(value string) string {
	return strings.ToLower(cleanName(value))
}

func citizenKey(townName string, citizenName string) string {
	return normalizeKey(townName) + "::" + normalizeKey(citizenName)
}

// ──────────────
// Init
// ──────────────

func init() {
	if dragons == nil {
		dragons = make(map[uint64]*Dragon)
	}
	if towns == nil {
		towns = make(map[string]*Town)
	}
	if citizens == nil {
		citizens = make(map[string]*Citizen)
	}
	nextDragonID = 1
}

// ──────────────
// Crossing function: MintDragon
// ──────────────

func MintDragon(cur realm, constitution string) uint64 {
	caller := Address(runtime.PreviousRealm().Address())

	if constitution == "" {
		constitution = "I am a custom dragon. My constitution is my only law."
	}
	if len(constitution) < 1 || len(constitution) > 1024 {
		panic("constitution must be 1-1024 characters")
	}

	id := nextDragonID
	nextDragonID++

	d := &Dragon{
		Owner:        caller,
		ID:           id,
		Color:        "default",
		Constitution: constitution,
		Pearls:       1000,
		Level:        1,
	}

	dragons[id] = d
	return id
}

func MintTown(cur realm, name string, amount uint64) string {
	caller := Address(runtime.OriginCaller())
	name = cleanName(name)

	if name == "" {
		panic("town name is required")
	}
	if amount == 0 {
		panic("town amount must be greater than zero")
	}
	if towns == nil {
		towns = make(map[string]*Town)
	}
	key := normalizeKey(name)
	if _, exists := towns[key]; exists {
		panic("town already exists")
	}

	towns[key] = &Town{
		Owner:  caller,
		Name:   name,
		Amount: amount,
	}

	return name
}

func MintCitizen(cur realm, townName string, citizenName string) string {
	caller := Address(runtime.OriginCaller())
	townName = cleanName(townName)
	citizenName = cleanName(citizenName)

	if townName == "" {
		panic("town name is required")
	}
	if citizenName == "" {
		panic("citizen name is required")
	}
	if towns == nil {
		towns = make(map[string]*Town)
	}
	if citizens == nil {
		citizens = make(map[string]*Citizen)
	}
	townKey := normalizeKey(townName)
	if _, exists := towns[townKey]; !exists {
		towns[townKey] = &Town{
			Owner:  caller,
			Name:   townName,
			Amount: 1,
		}
	}

	key := citizenKey(townName, citizenName)
	if _, exists := citizens[key]; exists {
		panic("citizen already exists in town")
	}

	citizens[key] = &Citizen{
		Owner:         caller,
		Name:          citizenName,
		TownName:      townName,
		Role:          "merchant",
		Listings:      make(map[string]*Listing),
		MessageBoard:  make(map[uint64]*Message),
		NextMessageID: 1,
	}

	return key
}

func MoveCitizenTown(cur realm, fromTownName string, citizenName string, toTownName string) string {
	caller := Address(runtime.OriginCaller())
	fromTownName = cleanName(fromTownName)
	citizenName = cleanName(citizenName)
	toTownName = cleanName(toTownName)

	if fromTownName == "" || toTownName == "" {
		panic("both town names are required")
	}
	if citizenName == "" {
		panic("citizen name is required")
	}
	if towns == nil {
		towns = make(map[string]*Town)
	}
	if citizens == nil {
		citizens = make(map[string]*Citizen)
	}

	oldKey := citizenKey(fromTownName, citizenName)
	citizen, ok := citizens[oldKey]
	if !ok {
		panic("citizen not found")
	}
	if citizen.Owner != caller {
		panic("only the citizen owner can move this citizen")
	}

	newTownKey := normalizeKey(toTownName)
	if _, exists := towns[newTownKey]; !exists {
		towns[newTownKey] = &Town{
			Owner:  caller,
			Name:   toTownName,
			Amount: 1,
		}
	}

	newKey := citizenKey(toTownName, citizenName)
	if newKey == oldKey {
		return newKey
	}
	if _, exists := citizens[newKey]; exists {
		panic("citizen already exists in destination town")
	}

	delete(citizens, oldKey)
	citizen.TownName = towns[newTownKey].Name
	citizens[newKey] = citizen

	return newKey
}

// ──────────────
// Non-crossing function: ListAllDragons
// Returns just the number of dragons
// ──────────────

func ListAllDragons() uint64 {
	return uint64(len(dragons))
}

func DragonExists(id uint64) bool {
	if dragons == nil {
		return false
	}

	_, ok := dragons[id]
	return ok
}

func GetDragon(id uint64) Dragon {
	if dragons == nil {
		panic("no dragons minted yet")
	}

	d, ok := dragons[id]
	if !ok {
		panic("dragon not found")
	}

	return *d
}

func DescribeDragon(id uint64) string {
	d := GetDragon(id)

	return "Dragon #" + strconv.Itoa(int(d.ID)) +
		"\nOwner: " + string(d.Owner) +
		"\nColor: " + d.Color +
		"\nConstitution: " + d.Constitution +
		"\nPearls: " + strconv.Itoa(int(d.Pearls)) +
		"\nLevel: " + strconv.Itoa(int(d.Level))
}

func ListAllTowns() uint64 {
	return uint64(len(towns))
}

func GetTown(name string) Town {
	if towns == nil {
		panic("no towns minted yet")
	}

	t, ok := towns[normalizeKey(name)]
	if !ok {
		panic("town not found")
	}

	return *t
}

func DescribeTown(name string) string {
	t := GetTown(name)

	return "Town: " + t.Name +
		"\nOwner: " + string(t.Owner) +
		"\nAmount: " + strconv.Itoa(int(t.Amount))
}

func ListAllCitizens() uint64 {
	return uint64(len(citizens))
}

func GetCitizen(townName string, citizenName string) Citizen {
	if citizens == nil {
		panic("no citizens minted yet")
	}

	key := citizenKey(townName, citizenName)
	c, ok := citizens[key]
	if !ok {
		panic("citizen not found")
	}

	return *c
}

func DescribeCitizen(townName string, citizenName string) string {
	c := GetCitizen(townName, citizenName)

	return "Citizen: " + c.Name +
		"\nTown: " + c.TownName +
		"\nOwner: " + string(c.Owner) +
		"\nRole: " + c.Role +
		"\nListings: " + strconv.Itoa(len(c.Listings)) +
		"\nMessages: " + strconv.Itoa(len(c.MessageBoard))
}

func Render(path string) string {
	dragonCount := 0
	if dragons != nil {
		dragonCount = len(dragons)
	}
	townCount := 0
	if towns != nil {
		townCount = len(towns)
	}
	citizenCount := 0
	if citizens != nil {
		citizenCount = len(citizens)
	}

	out := "# Dragon0 Realm\n\n"
	out += "This realm is being shaped for qeval-first interaction.\n\n"
	out += "Minted dragons: " + strconv.Itoa(dragonCount) + "\n"
	out += "Minted towns: " + strconv.Itoa(townCount) + "\n"
	out += "Minted citizens: " + strconv.Itoa(citizenCount) + "\n"

	if dragonCount == 0 {
		out += "\nNo dragons minted yet.\n"
	} else {
		out += "\nKnown dragon ids:\n"
		for id := uint64(1); id < nextDragonID; id++ {
			if DragonExists(id) {
				out += "- " + strconv.Itoa(int(id)) + "\n"
			}
		}
	}

	if townCount == 0 {
		out += "\nNo towns minted yet.\n"
	} else {
		out += "\nKnown towns:\n"
		for name := range towns {
			out += "- " + name + "\n"
		}
	}

	if citizenCount == 0 {
		out += "\nNo citizens minted yet.\n"
	} else {
		out += "\nKnown citizens:\n"
		for _, citizen := range citizens {
			out += "- " + citizen.Name + " of " + citizen.TownName + "\n"
		}
	}

	out += "\nSuggested qeval calls:\n"
	out += "- dragon0.ListAllDragons()\n"
	out += "- dragon0.DescribeDragon(1)\n"
	out += "- dragon0.GetDragon(1)\n"
	out += "- dragon0.ListAllTowns()\n"
	out += "- dragon0.DescribeTown(\"my-town\")\n"
	out += "- dragon0.ListAllCitizens()\n"
	out += "- dragon0.DescribeCitizen(\"my-town\", \"my-citizen\")\n"
	out += "- dragon0.MoveCitizenTown(fromTownName, citizenName, toTownName) is a signed call\n"

	out += "\nSigned terminal call:\n"
	out += "- MintTown(name, amount) should be run with gnokey from the CLI.\n"
	out += "- MintCitizen(townName, citizenName) auto-creates the town with amount 1 if needed.\n"
	out += "- MoveCitizenTown(fromTownName, citizenName, toTownName) auto-creates destination town with amount 1 if needed.\n"

	return out
}
