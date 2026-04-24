// dragon.gno
// Sovereign Dragon Realm – Hardcoded Package Owner (clean + secure)

package dragon

import (
	"strconv"
	"chain/runtime"
	"gno.land/r/g1m4vzpaj997532stxl85qf7t6lcyypu2ugj3ssd/dragonmap"
)

// 🔐 HARD-CODE YOUR DEPLOYER ADDRESS HERE
// This must be the account that runs `addpkg` and pays the storage deposit.
const SovereignOwner = "g1d5htufpxfpcrl2xd35wz2r2ypjngdelx89xymm"

type DragonBaby struct {
	Name        string
	BirthTime   string
	Trait       string
	ParentRealm string
}

// Global state
var (
	myRealmAddress string
	babies         map[string]DragonBaby
)

//
// 🔐 OWNER CHECK (clean + correct)
//
func isOwner() bool {
	return string(runtime.OriginCaller()) == SovereignOwner
}

//
// 📍 Ensure realm address is stored correctly
//
func ensureRealmAddress(cur realm) {
	if myRealmAddress == "" {
		myRealmAddress = string(cur.Address())
	}
}

//
// 🐣 CreateBaby – OWNER ONLY
//
func CreateBaby(cur realm, name string, trait string) DragonBaby {
	if !isOwner() {
		panic("dragon: only sovereign owner")
	}

	ensureRealmAddress(cur)

	if babies == nil {
		babies = make(map[string]DragonBaby)
	}

	baby := DragonBaby{
		Name:        name,
		BirthTime:   "now",
		Trait:      trait,
		ParentRealm: myRealmAddress,
	}

	babies[name] = baby
	return baby
}

//
// 🌍 RegisterToMother – OWNER ONLY (cross-call protected)
//
func RegisterToMother(cur realm) {
	if !isOwner() {
		panic("dragon: only sovereign owner")
	}

	ensureRealmAddress(cur)

	dragonmap.RegisterDragon(cross, myRealmAddress)
}

//
// 🗑 RemoveBaby – OWNER ONLY
//
func RemoveBaby(cur realm, name string) {
	if !isOwner() {
		panic("dragon: only sovereign owner")
	}

	if babies != nil {
		delete(babies, name)
	}
}

//
// 👁 Read-only functions (public)
//

func GetMyRealmAddress(cur realm) string {
	return myRealmAddress
}

func ListBabies(cur realm) map[string]DragonBaby {
	return babies
}

//
// 🖥 Render (read-only UI)
//
func Render(path string) string {
	count := 0
	if babies != nil {
		count = len(babies)
	}

	out := `# 🐉 Sovereign Dragon Realm

**Sovereign Owner:** ` + SovereignOwner + `

**Realm Address:** ` + myRealmAddress + `

**Babies bred:** ` + strconv.Itoa(count) + `

---

**Security Model**

- Owner is hardcoded at deployment.
- Only that address can mutate state.
- Only that address can perform cross-realm calls.
- Public read access is allowed.

[Global Dragon Map →](/r/g1m4vzpaj997532stxl85qf7t6lcyypu2ugj3ssd/dragonmap)
`

	if count > 0 {
		out += "\n## Your Dragon Babies\n"
		for n, b := range babies {
	    out += "- **" + n + "** — " + b.BirthTime + " — trait: " + b.Trait + "\n"
        }
	} else {
		out += "\nNo babies yet. Call CreateBaby from the Action tab!\n"
	}

	return out
}