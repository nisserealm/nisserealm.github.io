package nisse

type SacredForestCompanion struct {
	Name          string
	Ability       string
	Description   string
	Strength      uint64
	Wisdom        uint64
	Dexterity     uint64
	Skill         string
	Trait         string
	MintedAssetID uint64
}

var sacredBearHerd []*SacredForestCompanion
var sacredDeerHerd []*SacredForestCompanion
var sacredFairyRing []*SacredForestCompanion
var sacredOwlParliament []*SacredForestCompanion
var sacredTomcatClowder []*SacredForestCompanion
var sacredWolverineRun []*SacredForestCompanion
var sacredPorcupineNest []*SacredForestCompanion
var sacredSquirrelDrey []*SacredForestCompanion

func init() {
	sacredBearHerd = []*SacredForestCompanion{
		{Name: "Mossbar", Ability: "holds the line when claws and fear come close", Description: "A moss-dark bear with a patient gaze and an old strength.", Strength: 3, Wisdom: 2, Dexterity: 1, Skill: "meets the rush", Trait: "slow to anger, hard to move"},
		{Name: "Thornbar", Ability: "pushes through bramble and confusion without turning", Description: "A scarred bear who treats thorn and trouble alike.", Strength: 3, Wisdom: 1, Dexterity: 1, Skill: "breaks the tangle", Trait: "wears the rough path well"},
		{Name: "Stonebar", Ability: "plants its weight where the ground is worst", Description: "A broad old bear with the steadiness of a boulder.", Strength: 3, Wisdom: 2, Dexterity: 1, Skill: "keeps footing on bad ground", Trait: "does not startle easily"},
		{Name: "Ashbar", Ability: "finds the living path after fire or ruin", Description: "A grey bear with soot in the fur and survival in the bones.", Strength: 2, Wisdom: 3, Dexterity: 1, Skill: "reads the land after ruin", Trait: "never mistakes ash for ending"},
		{Name: "Redbar", Ability: "answers threat with sudden roaring force", Description: "A hot-blooded bear with russet fur and a short patience for wolves.", Strength: 3, Wisdom: 1, Dexterity: 1, Skill: "scatters the pack", Trait: "burns bright in danger"},
		{Name: "Pinebar", Ability: "moves quietly through resin-dark trunks", Description: "A resin-scented bear who seems to belong between old pines.", Strength: 2, Wisdom: 2, Dexterity: 2, Skill: "walks the silent stand", Trait: "knows where trunks conceal"},
		{Name: "Frostbar", Ability: "keeps going through hunger, cold, and long scarcity", Description: "A pale heavy-furred bear with a winter heart.", Strength: 2, Wisdom: 3, Dexterity: 1, Skill: "outlasts lean weather", Trait: "made for the hard season"},
		{Name: "Riverbar", Ability: "crosses current and slick stone without losing power", Description: "A wet-furred bear with easy confidence near rushing water.", Strength: 2, Wisdom: 2, Dexterity: 2, Skill: "takes the ford", Trait: "trusts the current"},
		{Name: "Emberbar", Ability: "finds stubborn courage when the body is already hurting", Description: "A wounded-looking bear whose spirit outpaces the damage.", Strength: 3, Wisdom: 1, Dexterity: 1, Skill: "fights through pain", Trait: "keeps an ember under the ribs"},
		{Name: "Bramblebar", Ability: "turns a bad corner into a trap for pursuers", Description: "A cunning hedge-side bear who makes the land do half the work.", Strength: 2, Wisdom: 2, Dexterity: 2, Skill: "makes the brush an ally", Trait: "prefers the crooked answer"},
		{Name: "Ironbar", Ability: "bears weight, shock, and hardship without complaint", Description: "A dark-shouldered bear with a body built like hammered metal.", Strength: 3, Wisdom: 2, Dexterity: 1, Skill: "endures the crush", Trait: "stays whole under pressure"},
		{Name: "Dawnbar", Ability: "stirs early and catches danger before it gathers", Description: "A tawny bear whose watchfulness belongs to the first light.", Strength: 2, Wisdom: 3, Dexterity: 1, Skill: "reads the first sign", Trait: "wakes before fear does"},
	}
	sacredDeerHerd = []*SacredForestCompanion{
		{Name: "Rowan", Ability: "finds the narrow openings in tangled woods", Description: "A slim deer with bright eyes and a gift for hidden passage.", Strength: 1, Wisdom: 2, Dexterity: 3, Skill: "takes the unseen lane", Trait: "steps where branches spare"},
		{Name: "Selvo", Ability: "returns to calm after fright faster than most", Description: "A deep-chested deer with a steadying nearness.", Strength: 1, Wisdom: 3, Dexterity: 2, Skill: "settles the startled heart", Trait: "shakes fear off cleanly"},
		{Name: "Alder", Ability: "keeps to wet edge, spring ground, and creek crossing", Description: "A deer who trusts the damp green places others avoid.", Strength: 1, Wisdom: 2, Dexterity: 2, Skill: "walks the spring edge", Trait: "likes the water-rooted path"},
		{Name: "Yarrow", Ability: "finds sweet forage where the land looks bare", Description: "A pale-faced deer with a nose for life hidden low.", Strength: 1, Wisdom: 3, Dexterity: 1, Skill: "finds the small green thing", Trait: "feeds where others pass by"},
		{Name: "Rainfoot", Ability: "moves lightly through soaked leaves and mud", Description: "A soft-stepping deer who leaves less mark than rain.", Strength: 1, Wisdom: 2, Dexterity: 3, Skill: "keeps the wet silence", Trait: "rarely sinks"},
		{Name: "Fernstep", Ability: "glides through undergrowth without stirring alarm", Description: "A quiet deer who seems to borrow the hush of fern and loam.", Strength: 1, Wisdom: 2, Dexterity: 3, Skill: "slips through the undergreen", Trait: "does not break the hush"},
		{Name: "Silverbranch", Ability: "catches moonlight and carries bearing in the dark", Description: "A moon-pale deer whose antlers seem to remember the sky.", Strength: 1, Wisdom: 3, Dexterity: 2, Skill: "holds the moon path", Trait: "bright in dim places"},
		{Name: "Quickleaf", Ability: "turns sharply when the wood closes unexpectedly", Description: "A nervous quick deer built for the last-second change.", Strength: 1, Wisdom: 1, Dexterity: 3, Skill: "changes line at once", Trait: "never commits too early"},
		{Name: "Larkhorn", Ability: "hears morning movement before it breaks cover", Description: "A dawn-wise deer whose ears wake before the sun does.", Strength: 1, Wisdom: 3, Dexterity: 1, Skill: "hears the hedge stir", Trait: "belongs to first light"},
		{Name: "Briarstep", Ability: "finds a safe way through thorn without tearing skin", Description: "A lean deer who treats bramble like a language.", Strength: 1, Wisdom: 2, Dexterity: 3, Skill: "threads the thorn", Trait: "trusts the narrow pass"},
		{Name: "Mistrun", Ability: "keeps direction when the low fog flattens the land", Description: "A long-necked deer with a talent for the whitening hour.", Strength: 1, Wisdom: 3, Dexterity: 2, Skill: "keeps the mist-road", Trait: "untroubled by dim horizons"},
		{Name: "Hallow", Ability: "draws stillness around the place it stops", Description: "A solemn deer whose pause can quiet a whole verge.", Strength: 1, Wisdom: 3, Dexterity: 1, Skill: "makes a clearing of calm", Trait: "stands like a prayer"},
	}
	sacredFairyRing = []*SacredForestCompanion{
		{Name: "Dewling", Ability: "finds the bright drop, the hidden spring, the saving coolness", Description: "A dew-bright fairy with a voice no louder than clover bells.", Strength: 0, Wisdom: 3, Dexterity: 2, Skill: "calls out hidden water", Trait: "belongs to first light"},
		{Name: "Fernling", Ability: "slips through root and leaf without stirring harm", Description: "A green-lit fairy who seems born from fern shadow.", Strength: 0, Wisdom: 2, Dexterity: 3, Skill: "moves where root and leaf allow", Trait: "never snags on the living world"},
		{Name: "Mossling", Ability: "settles hurt places with cool green patience", Description: "A moss-soft fairy who loves still stones and shaded bark.", Strength: 0, Wisdom: 3, Dexterity: 1, Skill: "soothes the raw edge", Trait: "heals by nearness"},
		{Name: "Glowling", Ability: "brings small light into the dark of branch and hollow", Description: "A warm gold fairy with a lantern quality in the skin.", Strength: 0, Wisdom: 2, Dexterity: 2, Skill: "keeps a little light", Trait: "refuses the deepest dark"},
		{Name: "Brookling", Ability: "hears where water still moves under stone", Description: "A laughing fairy with river-silver hair and bright impatience.", Strength: 0, Wisdom: 3, Dexterity: 2, Skill: "finds the moving water", Trait: "never far from a runnel"},
		{Name: "Thornling", Ability: "warns when a beautiful path has teeth in it", Description: "A sharp-eyed fairy fond of hedge blossom and useful caution.", Strength: 0, Wisdom: 3, Dexterity: 1, Skill: "reads the hidden barb", Trait: "sees the price in beauty"},
		{Name: "Mistling", Ability: "keeps shape and road when glamour and fog begin to blur", Description: "A pale fairy whose edges are hard to hold with mortal sight.", Strength: 0, Wisdom: 3, Dexterity: 2, Skill: "cuts through glamour", Trait: "belongs to the whitening hour"},
		{Name: "Bloomling", Ability: "coaxes the friendlier thing to grow where hope is thin", Description: "A bright laughing fairy with pollen on the sleeves.", Strength: 0, Wisdom: 2, Dexterity: 2, Skill: "stirs the gentle growth", Trait: "likes the neglected patch"},
		{Name: "Leafling", Ability: "reads the small turning of season before others notice", Description: "A quick leaf-green fairy with an eye for change at the edge.", Strength: 0, Wisdom: 3, Dexterity: 2, Skill: "feels the season shift", Trait: "never late to the turning"},
		{Name: "Starling", Ability: "keeps direction by very little light", Description: "A night-minded fairy with bright points in the hair like fine stars.", Strength: 0, Wisdom: 2, Dexterity: 3, Skill: "holds the faint bearing", Trait: "trusts the small glimmer"},
		{Name: "Rainling", Ability: "welcomes wet weather and makes it kinder", Description: "A rain-sweet fairy who laughs at clouds rather than fears them.", Strength: 0, Wisdom: 2, Dexterity: 2, Skill: "turns wet misery gentle", Trait: "pleased by weather"},
		{Name: "Shadeling", Ability: "rests the mind when grief or loneliness grows too loud", Description: "A dim cool fairy whose company softens the inward noise.", Strength: 0, Wisdom: 3, Dexterity: 1, Skill: "settles the lonely mind", Trait: "kind in the quiet places"},
	}
	sacredOwlParliament = []*SacredForestCompanion{
		{Name: "Hollow", Ability: "hears the wrong movement through bark and night air", Description: "A broad-faced owl who misses very little.", Strength: 1, Wisdom: 3, Dexterity: 2, Skill: "reads the hidden stir", Trait: "trusts sound over sight"},
		{Name: "Tallow", Ability: "keeps a pale line through the dark", Description: "A cream-feathered owl with calm hunting eyes.", Strength: 1, Wisdom: 2, Dexterity: 3, Skill: "keeps the pale track", Trait: "glows in dimness"},
		{Name: "Gloam", Ability: "arrives where dusk has hidden the last clear answer", Description: "A dusk-gray owl who loves the edge between seen and unseen.", Strength: 1, Wisdom: 3, Dexterity: 2, Skill: "works the half-light", Trait: "belongs to the in-between hour"},
		{Name: "Barkwise", Ability: "distinguishes bark-creak from true danger", Description: "An old owl whose caution is never wasted.", Strength: 1, Wisdom: 3, Dexterity: 1, Skill: "hears the meaningful noise", Trait: "never fooled by the ordinary wood"},
		{Name: "Reedhush", Ability: "crosses silent air without giving itself away", Description: "A marsh-edge owl with an eerie stillness in flight.", Strength: 1, Wisdom: 2, Dexterity: 3, Skill: "owns the silent glide", Trait: "leaves no warning"},
		{Name: "Softclaw", Ability: "takes the needed thing without tearing more than needful", Description: "A neat careful owl who wastes nothing.", Strength: 1, Wisdom: 2, Dexterity: 3, Skill: "keeps the clean strike", Trait: "precise even in hunger"},
		{Name: "Murk", Ability: "works where darkness grows thickest", Description: "A near-black owl who does not mind the heaviest shade.", Strength: 1, Wisdom: 3, Dexterity: 2, Skill: "finds the way in heavy dark", Trait: "unafraid of deep shadow"},
		{Name: "Ashfeather", Ability: "returns after smoke, ash, and disturbance", Description: "A ragged-looking owl with the survivor's habit of returning.", Strength: 1, Wisdom: 3, Dexterity: 1, Skill: "comes back after ruin", Trait: "does not give up a wood easily"},
		{Name: "Hush", Ability: "warns by silence when even a call would be too much", Description: "A little grey owl whose stillness itself is a signal.", Strength: 1, Wisdom: 3, Dexterity: 2, Skill: "keeps the useful silence", Trait: "quiet as warning"},
		{Name: "Chalkwing", Ability: "holds visible against moon and pale mist", Description: "A white-winged owl easy to follow in uncertain light.", Strength: 1, Wisdom: 2, Dexterity: 2, Skill: "guides by pale wing", Trait: "made for moonlit following"},
		{Name: "Bramblehush", Ability: "finds a perch where thorn protects the watch", Description: "A prickly little owl fond of dangerous branches.", Strength: 1, Wisdom: 2, Dexterity: 3, Skill: "watches from guarded perch", Trait: "likes the difficult branch"},
		{Name: "Mornless", Ability: "stays sharp through the hours when others blur and fade", Description: "A deep-night owl for whom darkness is full working day.", Strength: 1, Wisdom: 3, Dexterity: 2, Skill: "keeps the late watch", Trait: "never asks for dawn"},
	}
	sacredTomcatClowder = []*SacredForestCompanion{
		{Name: "Soot", Ability: "moves through ruin, shed, and hedge unseen", Description: "A black tom with scarred ears and perfect patience.", Strength: 1, Wisdom: 2, Dexterity: 3, Skill: "owns the unseen corner", Trait: "likes a broken wall"},
		{Name: "Bristle", Ability: "comes ugly and fast when trapped or cornered", Description: "A rough-coated tomcat who carries old fights like medals.", Strength: 2, Wisdom: 1, Dexterity: 2, Skill: "answers the corner", Trait: "prefers his own terms"},
		{Name: "Flint", Ability: "keeps his nerve around iron, trap, and man-smell", Description: "A hard-eyed tom with the memory of cages in him.", Strength: 2, Wisdom: 2, Dexterity: 1, Skill: "endures the snare-smell", Trait: "hates the hand that binds"},
		{Name: "Patch", Ability: "turns scraps and neglect into survival", Description: "A patched old alley tom who treats hunger as ordinary weather.", Strength: 1, Wisdom: 3, Dexterity: 1, Skill: "lives off little", Trait: "survives shabby places"},
		{Name: "Crooktail", Ability: "slips away at the last possible instant", Description: "A bent-tailed tomcat with a love of impossible escapes.", Strength: 1, Wisdom: 2, Dexterity: 3, Skill: "takes the last gap", Trait: "still alive by cleverness"},
		{Name: "Tatter", Ability: "reads where cloth, rope, and leather will fail", Description: "A ragged tom with sharp eyes for weak binding.", Strength: 1, Wisdom: 3, Dexterity: 2, Skill: "finds the weak knot", Trait: "notices what frays"},
		{Name: "Marram", Ability: "keeps low and lean in exposed windy ground", Description: "A sand-colored tomcat made for field edge and dry verge.", Strength: 1, Wisdom: 2, Dexterity: 3, Skill: "hugs the low cover", Trait: "belongs to the verge"},
		{Name: "Clove", Ability: "chooses the warmest hidden resting place in cold hours", Description: "A spice-brown tom who trusts old walls and stored heat.", Strength: 1, Wisdom: 3, Dexterity: 1, Skill: "finds the warm nook", Trait: "dislikes pointless cold"},
		{Name: "Kester", Ability: "keeps watch from above and drops where least expected", Description: "A long-limbed barn tom with a taste for rafters and beams.", Strength: 1, Wisdom: 2, Dexterity: 3, Skill: "owns the beam and drop", Trait: "prefers the high perch"},
		{Name: "Rattle", Ability: "warns harshly when wrong company draws near", Description: "A harsh-voiced tomcat with no patience for stealthy enemies.", Strength: 1, Wisdom: 3, Dexterity: 1, Skill: "raises the ugly warning", Trait: "does not hide contempt"},
		{Name: "Bracken", Ability: "vanishes into dead fern and field refuse", Description: "A brown-striped tom who disappears the instant the land turns untidy.", Strength: 1, Wisdom: 2, Dexterity: 3, Skill: "becomes part of the litter", Trait: "loves the unclean edge"},
		{Name: "Rag", Ability: "comes back from injury and poor luck more often than seems fair", Description: "A ruined-looking tom with too much remaining life.", Strength: 2, Wisdom: 2, Dexterity: 1, Skill: "returns after the bad night", Trait: "refuses the easy ending"},
	}
	sacredWolverineRun = []*SacredForestCompanion{
		{Name: "Grit", Ability: "keeps going after pain would stop softer beasts", Description: "A low fierce wolverine with ugly endurance.", Strength: 3, Wisdom: 1, Dexterity: 1, Skill: "pushes through hurt", Trait: "never lets pain decide"},
		{Name: "Riven", Ability: "tears through what ought to hold", Description: "A scar-nosed wolverine with a deep dislike of barriers.", Strength: 3, Wisdom: 1, Dexterity: 1, Skill: "breaks the hold", Trait: "answers restraint with violence"},
		{Name: "Hardjaw", Ability: "keeps grip once it has chosen the fight", Description: "A blocky-headed wolverine who commits fully.", Strength: 3, Wisdom: 1, Dexterity: 1, Skill: "holds the bite", Trait: "does not half-fight"},
		{Name: "Tusk", Ability: "bulls through brush and bad footing at speed", Description: "A thick-shouldered wolverine with a taste for impact.", Strength: 3, Wisdom: 1, Dexterity: 2, Skill: "rushes the obstacle", Trait: "likes the straight answer"},
		{Name: "Rake", Ability: "finds where a defense is weakest and opens it", Description: "A long-clawed wolverine with a tactical cruelty.", Strength: 2, Wisdom: 2, Dexterity: 2, Skill: "opens the weak seam", Trait: "wastes no violence"},
		{Name: "Marrow", Ability: "survives on little and wastes nothing hard-won", Description: "A gaunt fierce wolverine with a survivor's mind.", Strength: 2, Wisdom: 3, Dexterity: 1, Skill: "endures the lean ground", Trait: "measures hunger correctly"},
		{Name: "Flinttooth", Ability: "keeps the hard edge even in cold and exhaustion", Description: "A winter-black wolverine with teeth like bad news.", Strength: 3, Wisdom: 2, Dexterity: 1, Skill: "keeps the edge in hard weather", Trait: "never softens"},
		{Name: "Clench", Ability: "turns fury into leverage instead of waste", Description: "A compact wolverine who fights with ugly economy.", Strength: 3, Wisdom: 2, Dexterity: 1, Skill: "uses the grapple well", Trait: "likes close trouble"},
		{Name: "Skell", Ability: "crosses bone-dry hard country without weakening quickly", Description: "A rangy wolverine made for bad seasons.", Strength: 2, Wisdom: 2, Dexterity: 2, Skill: "survives the hard stretch", Trait: "thin but terrible"},
		{Name: "Grendel", Ability: "strikes fear before the body arrives", Description: "A dark-muzzled wolverine with a reputation half the work already done.", Strength: 2, Wisdom: 2, Dexterity: 1, Skill: "wins by dread", Trait: "goes before itself in rumor"},
		{Name: "Barkbite", Ability: "takes steep wooded slopes without losing pace", Description: "A hill-savvy wolverine fond of root, trunk, and broken rise.", Strength: 2, Wisdom: 2, Dexterity: 2, Skill: "climbs the bad angle", Trait: "loves the harsh slope"},
		{Name: "Grith", Ability: "holds to purpose when anger would usually scatter thought", Description: "A deliberate wolverine with an almost unnerving discipline.", Strength: 2, Wisdom: 3, Dexterity: 1, Skill: "keeps the aim inside rage", Trait: "fierce but not wild"},
	}
	sacredPorcupineNest = []*SacredForestCompanion{
		{Name: "Thistle", Ability: "makes trouble costly for anything that presses too close", Description: "A large quiet porcupine with a practical attitude to danger.", Strength: 2, Wisdom: 2, Dexterity: 1, Skill: "discourages the rash", Trait: "never bluffs twice"},
		{Name: "Burr", Ability: "finds safety in root, hedge, and abandoned tangle", Description: "A burr-colored porcupine who knows every defensive corner.", Strength: 1, Wisdom: 3, Dexterity: 1, Skill: "chooses the guarded rest", Trait: "loves the neglected edge"},
		{Name: "Quillan", Ability: "holds still when flight would only worsen things", Description: "A patient porcupine with a philosopher's sense for bad timing.", Strength: 1, Wisdom: 3, Dexterity: 1, Skill: "waits out the wrong moment", Trait: "prefers endurance to panic"},
		{Name: "Prickle", Ability: "makes a boundary felt without needless blood", Description: "A brisk porcupine who dislikes escalation but accepts necessity.", Strength: 1, Wisdom: 2, Dexterity: 2, Skill: "marks the line", Trait: "wants peace with distance"},
		{Name: "Bramble", Ability: "moves slowly but safely through the roughest underbrush", Description: "A hedge-wise porcupine with deep faith in caution.", Strength: 1, Wisdom: 3, Dexterity: 1, Skill: "owns the rough path", Trait: "never hurries into harm"},
		{Name: "Duskquill", Ability: "finds the safe hidden place before dark fully closes", Description: "A smoky porcupine who reads evening well.", Strength: 1, Wisdom: 3, Dexterity: 1, Skill: "settles before full dark", Trait: "respects the fading light"},
		{Name: "Mossquill", Ability: "takes damp shade and cool hollow as if born to them", Description: "A green-brown porcupine happiest near moss and root.", Strength: 1, Wisdom: 2, Dexterity: 1, Skill: "finds the cool shelter", Trait: "belongs under roots"},
		{Name: "Rindle", Ability: "remembers which paths were safe last season", Description: "An old porcupine with the gift of long caution.", Strength: 1, Wisdom: 3, Dexterity: 1, Skill: "keeps the remembered safe way", Trait: "trusts what survived once"},
		{Name: "Burrfoot", Ability: "keeps footing on littered ground and hidden snag", Description: "A sure-footed porcupine for whom bad ground is ordinary.", Strength: 1, Wisdom: 2, Dexterity: 2, Skill: "takes the snaggy floor", Trait: "never resents the rough going"},
		{Name: "Needle", Ability: "turns the body into a warning without wasting movement", Description: "A spare deliberate porcupine who hates unnecessary drama.", Strength: 1, Wisdom: 3, Dexterity: 1, Skill: "keeps the silent warning", Trait: "economical even in danger"},
		{Name: "Hedge", Ability: "reads where cover begins and ends", Description: "A thick-quilled porcupine with a surveyor's eye for shelter.", Strength: 1, Wisdom: 3, Dexterity: 1, Skill: "measures the cover", Trait: "likes exact borders"},
		{Name: "Spindle", Ability: "slips between roots and rock with unlikely care", Description: "A narrower porcupine than most, built for difficult gaps.", Strength: 1, Wisdom: 2, Dexterity: 2, Skill: "takes the thin passage", Trait: "smaller than the quills suggest"},
	}
	sacredSquirrelDrey = []*SacredForestCompanion{
		{Name: "Pip", Ability: "finds the little overlooked thing worth keeping", Description: "A bright squirrel with a talent for useful scraps and seeds.", Strength: 1, Wisdom: 2, Dexterity: 3, Skill: "spots the small gain", Trait: "never ignores the tiny lucky thing"},
		{Name: "Nib", Ability: "works bark, shell, and hard little obstacles patiently", Description: "A quick-jawed squirrel with industrious habits.", Strength: 1, Wisdom: 2, Dexterity: 3, Skill: "opens the stubborn small thing", Trait: "likes fussy work"},
		{Name: "Mottle", Ability: "disappears against bark and branch almost at will", Description: "A bark-colored squirrel with unfair camouflage.", Strength: 1, Wisdom: 2, Dexterity: 3, Skill: "vanishes on the trunk", Trait: "looks like the tree when still"},
		{Name: "Skip", Ability: "crosses gaps too wide for caution to approve", Description: "A reckless little squirrel whose judgments somehow often work out.", Strength: 1, Wisdom: 1, Dexterity: 3, Skill: "takes the wild leap", Trait: "trusts the spring in the body"},
		{Name: "Hazel", Ability: "stores wisely and remembers where life was hidden", Description: "A brown-eyed squirrel with an orderly mind for small provisions.", Strength: 1, Wisdom: 3, Dexterity: 2, Skill: "remembers the cache", Trait: "never wastes a season"},
		{Name: "Tumble", Ability: "survives near-falls and sudden slips with grace", Description: "A messy squirrel who lands better than it starts.", Strength: 1, Wisdom: 1, Dexterity: 3, Skill: "turns a fall into a landing", Trait: "made of second chances"},
		{Name: "Rill", Ability: "follows branch, trickle, and hollow to hidden coolness", Description: "A small squirrel drawn to seep, spring, and shady water.", Strength: 1, Wisdom: 3, Dexterity: 2, Skill: "finds the cool branch path", Trait: "likes the water-near tree"},
		{Name: "Bram", Ability: "keeps going through scratch, snag, and rough bark", Description: "A scratch-proof squirrel with a stubborn streak.", Strength: 1, Wisdom: 2, Dexterity: 2, Skill: "ignores the little pain", Trait: "too busy to mind scratches"},
		{Name: "Flick", Ability: "warns instantly when something below the branchline is wrong", Description: "A restless squirrel who sees danger as a game of speed.", Strength: 1, Wisdom: 2, Dexterity: 3, Skill: "spots ground-danger first", Trait: "all nerves and timing"},
		{Name: "Cinder", Ability: "keeps warmth and life in lean weather", Description: "A dark small squirrel with a winter-hardened heart.", Strength: 1, Wisdom: 3, Dexterity: 2, Skill: "outlasts the lean week", Trait: "small ember under fur"},
		{Name: "Dapple", Ability: "knows where light and leaf make the safest cover", Description: "A speckled squirrel who reads shade as carefully as road.", Strength: 1, Wisdom: 2, Dexterity: 3, Skill: "uses the broken light", Trait: "trusts moving shade"},
		{Name: "Whittle", Ability: "works patiently at the small useful task others skip", Description: "A patient squirrel who likes detail more than glory.", Strength: 1, Wisdom: 3, Dexterity: 2, Skill: "finishes the fiddly work", Trait: "small hands, serious mind"},
	}
}

func playerOwnsForestCompanionSubtype(playerName string, subtype string) bool {
	for assetID := uint64(1); assetID < nextAssetID; assetID++ {
		asset := assets[assetID]
		if asset == nil {
			continue
		}
		if asset.OwnerPlayer == playerName && asset.Kind == "companion" && asset.Subtype == subtype {
			return true
		}
	}
	return false
}

func nextSacredForestCompanion(pack []*SacredForestCompanion) *SacredForestCompanion {
	for _, entry := range pack {
		if entry != nil && entry.MintedAssetID == 0 {
			return entry
		}
	}
	return nil
}

func renderSacredForestRegistry(out string, pack []*SacredForestCompanion) string {
	for _, entry := range pack {
		if entry == nil {
			continue
		}
		out += "- " + entry.Name
		if entry.MintedAssetID == 0 {
			out += " | owner: undiscovered\n"
			continue
		}
		asset := assets[entry.MintedAssetID]
		if asset == nil || asset.OwnerPlayer == "" {
			out += " | owner: undiscovered\n"
			continue
		}
		out += " | owner: " + asset.OwnerPlayer + "\n"
	}
	return out
}

func grantSacredForestCompanion(playerKey string, player *Player, subtype string, speciesName string, speciesKind string, ownText string, noneText string, followText string, hiddenText string, pack []*SacredForestCompanion) (string, bool, string) {
	if playerOwnsForestCompanionSubtype(player.Name, subtype) {
		return ownText, false, ""
	}

	entry := nextSacredForestCompanion(pack)
	if entry == nil {
		return noneText, false, ""
	}

	collection := ensureCompanionCollection(playerKey)
	id := nextCompanionID
	nextCompanionID++
	asset := createAsset("companion", speciesName, entry.Name, player.Name, player.LineageOwner, player.Turns, player.Pos)
	entry.MintedAssetID = asset.ID
	companion := &Companion{
		ID:          id,
		AssetID:     asset.ID,
		OwnerPlayer: player.Name,
		Species: CompanionSpecies{
			Kind:        speciesKind,
			Name:        speciesName,
			SpawnWeight: 0,
			Ability:     entry.Ability,
			Description: entry.Description,
		},
		FoundAt:    player.Pos,
		FoundTurn:  player.Turns,
		Strength:   entry.Strength,
		Wisdom:     entry.Wisdom,
		Dexterity:  entry.Dexterity,
		Skill:      entry.Skill,
		Trait:      entry.Trait,
		Encounters: 0,
	}
	deriveCompanionAttitudes(companion)
	if playerBagHasRoom(player) {
		collection[id] = companion
		if player.ActiveCompanionID == 0 {
			player.ActiveCompanionID = id
		}
		return entry.Name + " the " + speciesName + " " + followText, true, asset.DisplayName
	}
	hiddenCompanions[asset.ID] = companion
	storeAssetOnTile(player.Pos, asset.ID, player.Name, player.LineageOwner, player.Turns)
	return entry.Name + " the " + speciesName + " " + hiddenText, true, asset.DisplayName
}

func playerOwnsSacredBear(playerName string) bool {
	return playerOwnsForestCompanionSubtype(playerName, "forest-bear")
}

func playerOwnsSacredDeer(playerName string) bool {
	return playerOwnsForestCompanionSubtype(playerName, "forest-deer")
}

func playerOwnsSacredFairy(playerName string) bool {
	return playerOwnsForestCompanionSubtype(playerName, "forest-fairy")
}

func playerOwnsSacredOwl(playerName string) bool {
	return playerOwnsForestCompanionSubtype(playerName, "night-owl")
}

func playerOwnsSacredTomcat(playerName string) bool {
	return playerOwnsForestCompanionSubtype(playerName, "night-tomcat")
}

func playerOwnsSacredWolverine(playerName string) bool {
	return playerOwnsForestCompanionSubtype(playerName, "forest-wolverine")
}

func playerOwnsSacredPorcupine(playerName string) bool {
	return playerOwnsForestCompanionSubtype(playerName, "forest-porcupine")
}

func playerOwnsSacredSquirrel(playerName string) bool {
	return playerOwnsForestCompanionSubtype(playerName, "forest-squirrel")
}

func grantSacredBearCompanion(playerKey string, player *Player) (string, bool, string) {
	return grantSacredForestCompanion(
		playerKey, player, "forest-bear", "Forest Bear", "land",
		"A forest bear already knows your road and keeps to it heavily.",
		"The eastern forest has no unchosen bear left to come with you.",
		"falls into your shadow and accepts your road.",
		"would follow, but your bag is full, so the bond is hidden here under your mark until you return.",
		sacredBearHerd,
	)
}

func grantSacredDeerCompanion(playerKey string, player *Player) (string, bool, string) {
	return grantSacredForestCompanion(
		playerKey, player, "forest-deer", "Forest Deer", "land",
		"A forest deer already keeps your pace and does not give itself twice.",
		"No unchosen deer remains in this run of forest.",
		"chooses your road lightly and without fear.",
		"is willing to keep your road, but your bag is full, so the bond is hidden here under your mark until you return.",
		sacredDeerHerd,
	)
}

func grantSacredFairyCompanion(playerKey string, player *Player) (string, bool, string) {
	return grantSacredForestCompanion(
		playerKey, player, "forest-fairy", "Forest Fairy", "spirit",
		"A forest fairy already travels near your shoulder and does not divide itself between roads.",
		"The little woodland court has no unchosen fairy left here.",
		"comes with you like a small bright promise among the leaves.",
		"would travel with you, but your bag is full, so the bond is hidden here under your mark until you return.",
		sacredFairyRing,
	)
}

func grantSacredOwlCompanion(playerKey string, player *Player) (string, bool, string) {
	return grantSacredForestCompanion(
		playerKey, player, "night-owl", "Night Owl", "land",
		"A night owl already keeps your dark road under watch.",
		"No unchosen owl remains in this reach of night wood.",
		"keeps above you and accepts your road under its silent guard.",
		"is willing to keep your road, but your bag is full, so the bond is hidden here under your mark until you return.",
		sacredOwlParliament,
	)
}

func grantSacredTomcatCompanion(playerKey string, player *Player) (string, bool, string) {
	return grantSacredForestCompanion(
		playerKey, player, "night-tomcat", "Night Tomcat", "land",
		"A night tomcat already knows your camp-smoke and keeps to your road in its own fashion.",
		"No unchosen tomcat remains in this night run.",
		"falls into your shadow and makes your road its own.",
		"would stalk beside you, but your bag is full, so the bond is hidden here under your mark until you return.",
		sacredTomcatClowder,
	)
}

func grantSacredWolverineCompanion(playerKey string, player *Player) (string, bool, string) {
	return grantSacredForestCompanion(
		playerKey, player, "forest-wolverine", "Forest Wolverine", "land",
		"A forest wolverine already keeps your hard road and has no second loyalty to give.",
		"No unchosen wolverine remains in this heat-struck wood.",
		"accepts your road with a hard, unwilling kind of loyalty.",
		"would keep your road, but your bag is full, so the bond is hidden here under your mark until you return.",
		sacredWolverineRun,
	)
}

func grantSacredPorcupineCompanion(playerKey string, player *Player) (string, bool, string) {
	return grantSacredForestCompanion(
		playerKey, player, "forest-porcupine", "Forest Porcupine", "land",
		"A forest porcupine already trusts your quiet road and does not choose twice.",
		"No unchosen porcupine remains in this dry wood.",
		"settles into your road with careful trust.",
		"would go with you, but your bag is full, so the bond is hidden here under your mark until you return.",
		sacredPorcupineNest,
	)
}

func grantSacredSquirrelCompanion(playerKey string, player *Player) (string, bool, string) {
	return grantSacredForestCompanion(
		playerKey, player, "forest-squirrel", "Forest Squirrel", "land",
		"A forest squirrel already knows your road and your crumbs and sees no need to choose again.",
		"No unchosen squirrel remains in this hot bright wood.",
		"takes to your road in little quick bounds and bright curiosity.",
		"would come with you, but your bag is full, so the bond is hidden here under your mark until you return.",
		sacredSquirrelDrey,
	)
}
