package nisse

import (
	"chain"
	"chain/banker"
	"chain/runtime"
	"strconv"
)

type Peddler struct {
	OwnerPlayer        string
	Model              string
	PearlReserve       uint64
	UGNOTReserve       int64
	PriceUGNOTPerPearl int64
	LatestTrade        string
	Active             bool
}

type PearlPurse struct {
	Holdings map[string]uint64
}

type InheritanceCache struct {
	FallenName    string
	LineageOwner  Address
	Position      Position
	DeathTurn     uint64
	Cause         string
	Purse         *PearlPurse
	UGNOT         int64
	Recovered     bool
}

var pearls map[string]*PearlPurse
var latestPearlTransfer map[string]string
var totalPearlSupply uint64
var ugnotPouch map[string]int64
var latestUGNOTTransfer map[string]string
var peddlers map[string]*Peddler
var peddlerPearls map[string]*PearlPurse
var inheritanceCaches map[string][]*InheritanceCache

func init() {
	pearls = make(map[string]*PearlPurse)
	latestPearlTransfer = make(map[string]string)
	ugnotPouch = make(map[string]int64)
	latestUGNOTTransfer = make(map[string]string)
	peddlers = make(map[string]*Peddler)
	peddlerPearls = make(map[string]*PearlPurse)
	inheritanceCaches = make(map[string][]*InheritanceCache)
}

func pearlOriginMark(playerKey string) string {
	return "pearls:" + playerKey
}

func ensurePearlPouch(playerKey string) *PearlPurse {
	if pearls[playerKey] == nil {
		pearls[playerKey] = &PearlPurse{Holdings: make(map[string]uint64)}
	}
	return pearls[playerKey]
}

func totalPearls(playerKey string) uint64 {
	pouch := ensurePearlPouch(playerKey)
	total := uint64(0)
	for _, amount := range pouch.Holdings {
		total += amount
	}
	return total
}

func totalPearlsInPurse(purse *PearlPurse) uint64 {
	if purse == nil {
		return 0
	}
	total := uint64(0)
	for _, amount := range purse.Holdings {
		total += amount
	}
	return total
}

func sumAllPearls() uint64 {
	total := uint64(0)
	for playerKey := range pearls {
		total += totalPearls(playerKey)
	}
	for _, pouch := range peddlerPearls {
		total += totalPearlsInPurse(pouch)
	}
	for _, guild := range guildTreasuries {
		if guild == nil {
			continue
		}
		total += totalPearlsInPurse(guild.Purse)
	}
	for _, caches := range inheritanceCaches {
		for _, cache := range caches {
			if cache == nil || cache.Recovered {
				continue
			}
			total += totalPearlsInPurse(cache.Purse)
		}
	}
	return total
}

func assertPearlSupply() {
	if sumAllPearls() != totalPearlSupply {
		panic("pearl supply invariant broken")
	}
}

func mintInitialPearls(playerKey string, amount uint64) {
	if amount == 0 {
		return
	}
	origin := pearlOriginMark(playerKey)
	ensurePearlPouch(playerKey).Holdings[origin] += amount
	totalPearlSupply += amount
	assertPearlSupply()
}

func awardFoundPearls(playerKey string, origin string, amount uint64, note string) {
	if amount == 0 {
		return
	}
	label := cleanName(origin)
	if label == "" {
		label = "found"
	}
	ensurePearlPouch(playerKey).Holdings[label] += amount
	totalPearlSupply += amount
	assertPearlSupply()
	if note == "" {
		note = "Found " + strconv.Itoa(int(amount)) + " pearls."
	}
	recordPearlTransfer(playerKey, note)
}

func pearlOrigins(playerKey string) string {
	pouch := ensurePearlPouch(playerKey)
	if len(pouch.Holdings) == 0 {
		return ""
	}

	first := true
	out := ""
	for origin, amount := range pouch.Holdings {
		if amount == 0 {
			continue
		}
		if !first {
			out += ", "
		}
		out += origin
		first = false
	}
	return out
}

func firstPearlOrigin(playerKey string) string {
	pouch := ensurePearlPouch(playerKey)
	selected := ""
	for origin, amount := range pouch.Holdings {
		if amount == 0 {
			continue
		}
		if selected == "" || origin < selected {
			selected = origin
		}
	}
	return selected
}

func recordPearlTransfer(playerKey string, description string) {
	latestPearlTransfer[playerKey] = description
}

func recordUGNOTTransfer(playerKey string, description string) {
	latestUGNOTTransfer[playerKey] = description
}

func ensurePeddlerPearls(ownerKey string) *PearlPurse {
	if peddlerPearls[ownerKey] == nil {
		peddlerPearls[ownerKey] = &PearlPurse{Holdings: make(map[string]uint64)}
	}
	return peddlerPearls[ownerKey]
}

func firstPeddlerPearlOrigin(ownerKey string) string {
	pouch := ensurePeddlerPearls(ownerKey)
	selected := ""
	for origin, amount := range pouch.Holdings {
		if amount == 0 {
			continue
		}
		if selected == "" || origin < selected {
			selected = origin
		}
	}
	return selected
}

func movePearlsBetweenPouches(from *PearlPurse, originPicker func() string, to *PearlPurse, amount uint64) {
	remaining := amount
	for remaining > 0 {
		origin := originPicker()
		if origin == "" {
			panic("not enough pearls")
		}

		available := from.Holdings[origin]
		move := remaining
		if available < move {
			move = available
		}

		from.Holdings[origin] -= move
		if from.Holdings[origin] == 0 {
			delete(from.Holdings, origin)
		}
		to.Holdings[origin] += move
		remaining -= move
	}
}

func spendPearls(playerKey string, amount uint64, note string) {
	if amount == 0 {
		return
	}
	if totalPearls(playerKey) < amount {
		panic("not enough pearls")
	}
	pouch := ensurePearlPouch(playerKey)
	remaining := amount
	for remaining > 0 {
		origin := firstPearlOrigin(playerKey)
		if origin == "" {
			panic("not enough pearls")
		}
		available := pouch.Holdings[origin]
		move := remaining
		if available < move {
			move = available
		}
		pouch.Holdings[origin] -= move
		if pouch.Holdings[origin] == 0 {
			delete(pouch.Holdings, origin)
		}
		remaining -= move
	}
	if totalPearlSupply < amount {
		panic("pearl supply invariant broken")
	}
	totalPearlSupply -= amount
	assertPearlSupply()
	if note != "" {
		recordPearlTransfer(playerKey, note)
	}
}

func clonePearlPurse(source *PearlPurse) *PearlPurse {
	purse := &PearlPurse{Holdings: make(map[string]uint64)}
	if source == nil {
		return purse
	}
	for origin, amount := range source.Holdings {
		if amount == 0 {
			continue
		}
		purse.Holdings[origin] = amount
	}
	return purse
}

func mergePearlPurse(target *PearlPurse, source *PearlPurse) {
	if target == nil || source == nil {
		return
	}
	for origin, amount := range source.Holdings {
		if amount == 0 {
			continue
		}
		target.Holdings[origin] += amount
	}
}

func stashInheritanceCache(playerKey string, player *Player, cause string) *InheritanceCache {
	playerPurse := clonePearlPurse(pearls[playerKey])
	stallPurse := clonePearlPurse(peddlerPearls[playerKey])
	merged := &PearlPurse{Holdings: make(map[string]uint64)}
	mergePearlPurse(merged, playerPurse)
	mergePearlPurse(merged, stallPurse)
	ugnot := ugnotPouch[playerKey]
	if stall, ok := peddlers[playerKey]; ok && stall != nil && stall.Active {
		ugnot += stall.UGNOTReserve
	}
	if totalPearlsInPurse(merged) == 0 && ugnot == 0 {
		return nil
	}
	cache := &InheritanceCache{
		FallenName:   player.Name,
		LineageOwner: player.LineageOwner,
		Position:     player.Pos,
		DeathTurn:    player.Turns,
		Cause:        cause,
		Purse:        merged,
		UGNOT:        ugnot,
		Recovered:    false,
	}
	inheritanceCaches[playerKey] = append(inheritanceCaches[playerKey], cache)
	delete(pearls, playerKey)
	delete(peddlerPearls, playerKey)
	delete(peddlers, playerKey)
	delete(ugnotPouch, playerKey)
	return cache
}

func latestUnrecoveredInheritance(playerKey string) *InheritanceCache {
	caches := inheritanceCaches[playerKey]
	for i := len(caches) - 1; i >= 0; i-- {
		cache := caches[i]
		if cache == nil || cache.Recovered {
			continue
		}
		return cache
	}
	return nil
}

func ClaimInheritancePurse(cur realm, playerName string) string {
	key, player, _ := ownedPlayer(playerName)
	cache := latestUnrecoveredInheritance(key)
	if cache == nil {
		return "No hidden inheritance answers your line."
	}
	if !sameTile(player.Pos, cache.Position) {
		return "Your inheritance is hidden elsewhere. The old map points to (" + strconv.Itoa(int(cache.Position.X)) + ", " + strconv.Itoa(int(cache.Position.Y)) + ")."
	}
	mergePearlPurse(ensurePearlPouch(key), cache.Purse)
	if cache.UGNOT > 0 {
		ugnotPouch[key] += cache.UGNOT
	}
	recordPearlTransfer(key, "Recovered the hidden purse left by "+cache.FallenName+".")
	if cache.UGNOT > 0 {
		recordUGNOTTransfer(key, "Recovered " + strconv.Itoa(int(cache.UGNOT)) + " ugnot from the hidden purse left by " + cache.FallenName + ".")
	}
	cache.Purse = &PearlPurse{Holdings: make(map[string]uint64)}
	cache.UGNOT = 0
	cache.Recovered = true
	return "You recover the hidden purse left by " + cache.FallenName + "."
}

func DescribeInheritance(playerName string) string {
	key, player, _ := ownedPlayer(playerName)
	cache := latestUnrecoveredInheritance(key)
	if cache == nil {
		return "No hidden inheritance waits for this line."
	}
	out := "Hidden inheritance for " + player.Name + "\n"
	out += "From: " + cache.FallenName + "\n"
	out += "Place: (" + strconv.Itoa(int(cache.Position.X)) + ", " + strconv.Itoa(int(cache.Position.Y)) + ")\n"
	out += "DeathTurn: " + strconv.Itoa(int(cache.DeathTurn)) + "\n"
	out += "Cause: " + cache.Cause + "\n"
	out += "Pearls: " + strconv.Itoa(int(totalPearlsInPurse(cache.Purse))) + "\n"
	out += "UGNOT: " + strconv.Itoa(int(cache.UGNOT))
	return out
}

func SendPearls(cur realm, fromPlayerName string, toPlayerName string, amount uint64) string {
	caller := Address(runtime.OriginCaller())
	fromPlayerName = cleanName(fromPlayerName)
	toPlayerName = cleanName(toPlayerName)

	if fromPlayerName == "" || toPlayerName == "" {
		panic("both player names are required")
	}
	if amount == 0 {
		panic("pearl amount must be greater than zero")
	}

	fromKey := normalizeKey(fromPlayerName)
	toKey := normalizeKey(toPlayerName)
	if fromKey == toKey {
		panic("cannot send pearls to the same player")
	}

	fromPlayer, ok := players[fromKey]
	if !ok {
		panic("sender not found")
	}
	if fromPlayer.Owner != caller {
		panic("only the player owner can send pearls")
	}
	toPlayer, ok := players[toKey]
	if !ok {
		panic("recipient not found")
	}

	if totalPearls(fromKey) < amount {
		panic("not enough pearls")
	}

	fromPouch := ensurePearlPouch(fromKey)
	toPouch := ensurePearlPouch(toKey)
	remaining := amount
	for remaining > 0 {
		origin := firstPearlOrigin(fromKey)
		if origin == "" {
			panic("not enough pearls")
		}

		available := fromPouch.Holdings[origin]
		move := remaining
		if available < move {
			move = available
		}

		fromPouch.Holdings[origin] -= move
		if fromPouch.Holdings[origin] == 0 {
			delete(fromPouch.Holdings, origin)
		}
		toPouch.Holdings[origin] += move
		remaining -= move
	}

	recordPearlTransfer(fromKey, "Sent "+strconv.Itoa(int(amount))+" pearls to "+toPlayer.Name+".")
	recordPearlTransfer(toKey, "Received "+strconv.Itoa(int(amount))+" pearls from "+fromPlayer.Name+".")
	return "pearls sent"
}

func DepositUGNOT(cur realm, playerName string) string {
	runtime.AssertOriginCall()

	playerName = cleanName(playerName)
	key := normalizeKey(playerName)
	player, ok := players[key]
	if !ok {
		panic("player not found")
	}

	caller := Address(runtime.OriginCaller())
	if player.Owner != caller {
		panic("only the player owner can deposit ugnot")
	}

	sent := banker.OriginSend()
	amount := sent.AmountOf("ugnot")
	if amount <= 0 {
		panic("send ugnot with the transaction")
	}

	ugnotPouch[key] += amount
	recordUGNOTTransfer(key, "Loaded "+strconv.Itoa(int(amount))+" ugnot into the pouch.")
	return "ugnot loaded"
}

func SendUGNOT(cur realm, fromPlayerName string, toPlayerName string, amount int64) string {
	caller := Address(runtime.OriginCaller())
	fromPlayerName = cleanName(fromPlayerName)
	toPlayerName = cleanName(toPlayerName)

	if fromPlayerName == "" || toPlayerName == "" {
		panic("both player names are required")
	}
	if amount <= 0 {
		panic("ugnot amount must be greater than zero")
	}

	fromKey := normalizeKey(fromPlayerName)
	toKey := normalizeKey(toPlayerName)
	if fromKey == toKey {
		panic("cannot send ugnot to the same player")
	}

	fromPlayer, ok := players[fromKey]
	if !ok {
		panic("sender not found")
	}
	if fromPlayer.Owner != caller {
		panic("only the player owner can send ugnot")
	}
	toPlayer, ok := players[toKey]
	if !ok {
		panic("recipient not found")
	}

	if ugnotPouch[fromKey] < amount {
		panic("not enough ugnot in pouch")
	}

	ugnotPouch[fromKey] -= amount
	ugnotPouch[toKey] += amount
	recordUGNOTTransfer(fromKey, "Sent "+strconv.Itoa(int(amount))+" ugnot to "+toPlayer.Name+".")
	recordUGNOTTransfer(toKey, "Received "+strconv.Itoa(int(amount))+" ugnot from "+fromPlayer.Name+".")
	return "ugnot sent"
}

func WithdrawUGNOT(cur realm, playerName string, amount int64) string {
	runtime.AssertOriginCall()

	playerName = cleanName(playerName)
	key := normalizeKey(playerName)
	player, ok := players[key]
	if !ok {
		panic("player not found")
	}

	caller := Address(runtime.OriginCaller())
	if player.Owner != caller {
		panic("only the player owner can withdraw ugnot")
	}
	if amount <= 0 {
		panic("ugnot amount must be greater than zero")
	}
	if ugnotPouch[key] < amount {
		panic("not enough ugnot in pouch")
	}

	pkgaddr := runtime.CurrentRealm().Address()
	realmBanker := banker.NewBanker(banker.BankerTypeRealmSend)
	realmBanker.SendCoins(pkgaddr, runtime.OriginCaller(), chain.NewCoins(chain.NewCoin("ugnot", amount)))

	ugnotPouch[key] -= amount
	recordUGNOTTransfer(key, "Withdrew "+strconv.Itoa(int(amount))+" ugnot back to the owner wallet.")
	return "ugnot withdrawn"
}

func OpenPeddler(cur realm, playerName string, pearlAmount uint64, ugnotAmount int64) string {
	key, player, _ := ownedPlayer(playerName)
	if existing, ok := peddlers[key]; ok && existing != nil && existing.Active {
		panic("peddler already active")
	}
	if !isCityMarketTile(player.Pos) {
		panic("peddlers can only open in the city")
	}

	if pearlAmount == 0 && ugnotAmount == 0 {
		peddlers[key] = &Peddler{
			OwnerPlayer:        player.Name,
			Model:              "fixed",
			PearlReserve:       0,
			UGNOTReserve:       0,
			PriceUGNOTPerPearl: 0,
			LatestTrade:        "Opened a market stall.",
			Active:             true,
		}
		return "peddler opened"
	}
	if pearlAmount == 0 || ugnotAmount <= 0 {
		panic("fixed peddler exchange needs both pearls and ugnot")
	}
	if totalPearls(key) < pearlAmount {
		panic("not enough pearls")
	}
	if ugnotPouch[key] < ugnotAmount {
		panic("not enough ugnot in pouch")
	}
	if ugnotAmount%int64(pearlAmount) != 0 {
		panic("fixed peddler price must divide evenly")
	}

	price := ugnotAmount / int64(pearlAmount)
	if price <= 0 {
		panic("invalid peddler price")
	}

	playerPouch := ensurePearlPouch(key)
	stallPouch := ensurePeddlerPearls(key)
	movePearlsBetweenPouches(playerPouch, func() string { return firstPearlOrigin(key) }, stallPouch, pearlAmount)
	ugnotPouch[key] -= ugnotAmount

	peddlers[key] = &Peddler{
		OwnerPlayer:        player.Name,
		Model:              "fixed",
		PearlReserve:       pearlAmount,
		UGNOTReserve:       ugnotAmount,
		PriceUGNOTPerPearl: price,
		LatestTrade:        "Opened at " + strconv.Itoa(int(price)) + " ugnot per pearl.",
		Active:             true,
	}

	recordPearlTransfer(key, "Moved " + strconv.Itoa(int(pearlAmount)) + " pearls into the peddler stall.")
	recordUGNOTTransfer(key, "Moved " + strconv.Itoa(int(ugnotAmount)) + " ugnot into the peddler stall.")
	return "peddler opened"
}

func ClosePeddler(cur realm, playerName string) string {
	key, player, _ := ownedPlayer(playerName)
	stall, ok := peddlers[key]
	if !ok || stall == nil || !stall.Active {
		return "No active peddler."
	}
	reclaimedListings := reclaimActiveListingsToOwner(key, player)
	if stall.PearlReserve > 0 {
		stallPouch := ensurePeddlerPearls(key)
		playerPouch := ensurePearlPouch(key)
		movePearlsBetweenPouches(stallPouch, func() string { return firstPeddlerPearlOrigin(key) }, playerPouch, stall.PearlReserve)
		recordPearlTransfer(key, "Returned " + strconv.Itoa(int(stall.PearlReserve)) + " stall pearls to the purse.")
		stall.PearlReserve = 0
	}
	if stall.UGNOTReserve > 0 {
		ugnotPouch[key] += stall.UGNOTReserve
		recordUGNOTTransfer(key, "Returned " + strconv.Itoa(int(stall.UGNOTReserve)) + " stall ugnot to the pouch.")
		stall.UGNOTReserve = 0
	}
	stall.Active = false
	stall.LatestTrade = "Closed at " + placeName(player.Pos) + "."
	if reclaimedListings > 0 {
		return "peddler closed and " + strconv.Itoa(int(reclaimedListings)) + " listing(s) returned"
	}
	return "peddler closed"
}

func BuyPearlsFromPeddler(cur realm, buyerPlayerName string, sellerPlayerName string, pearlAmount uint64) string {
	buyerKey, buyer, _ := ownedPlayer(buyerPlayerName)
	sellerKey := normalizeKey(sellerPlayerName)
	seller, ok := players[sellerKey]
	if !ok {
		panic("seller not found")
	}
	stall, ok := peddlers[sellerKey]
	if !ok || !stall.Active {
		panic("peddler not found")
	}
	if !sameTile(buyer.Pos, seller.Pos) {
		panic("buyer must stand on the same tile as the peddler")
	}
	if stall.Model != "fixed" {
		panic("peddler model not supported")
	}
	if pearlAmount == 0 {
		panic("pearl amount must be greater than zero")
	}
	if stall.PearlReserve < pearlAmount {
		panic("not enough pearls in the stall")
	}

	cost := int64(pearlAmount) * stall.PriceUGNOTPerPearl
	if ugnotPouch[buyerKey] < cost {
		panic("not enough ugnot in pouch")
	}

	stallPouch := ensurePeddlerPearls(sellerKey)
	buyerPouch := ensurePearlPouch(buyerKey)
	movePearlsBetweenPouches(stallPouch, func() string { return firstPeddlerPearlOrigin(sellerKey) }, buyerPouch, pearlAmount)
	ugnotPouch[buyerKey] -= cost
	stall.UGNOTReserve += cost
	stall.PearlReserve -= pearlAmount
	stall.LatestTrade = buyer.Name + " bought " + strconv.Itoa(int(pearlAmount)) + " pearls for " + strconv.Itoa(int(cost)) + " ugnot."

	recordPearlTransfer(buyerKey, "Bought " + strconv.Itoa(int(pearlAmount)) + " pearls from " + stall.OwnerPlayer + "'s peddler.")
	recordUGNOTTransfer(buyerKey, "Spent " + strconv.Itoa(int(cost)) + " ugnot at " + stall.OwnerPlayer + "'s peddler.")
	recordUGNOTTransfer(sellerKey, "Sold " + strconv.Itoa(int(pearlAmount)) + " pearls to " + buyer.Name + " for " + strconv.Itoa(int(cost)) + " ugnot.")
	return "pearls bought"
}

func BuyUGNOTFromPeddler(cur realm, buyerPlayerName string, sellerPlayerName string, pearlAmount uint64) string {
	buyerKey, buyer, _ := ownedPlayer(buyerPlayerName)
	sellerKey := normalizeKey(sellerPlayerName)
	seller, ok := players[sellerKey]
	if !ok {
		panic("seller not found")
	}
	stall, ok := peddlers[sellerKey]
	if !ok || !stall.Active {
		panic("peddler not found")
	}
	if !sameTile(buyer.Pos, seller.Pos) {
		panic("buyer must stand on the same tile as the peddler")
	}
	if stall.Model != "fixed" {
		panic("peddler model not supported")
	}
	if pearlAmount == 0 {
		panic("pearl amount must be greater than zero")
	}
	if totalPearls(buyerKey) < pearlAmount {
		panic("not enough pearls")
	}

	payout := int64(pearlAmount) * stall.PriceUGNOTPerPearl
	if stall.UGNOTReserve < payout {
		panic("not enough ugnot in the stall")
	}

	buyerPouch := ensurePearlPouch(buyerKey)
	stallPouch := ensurePeddlerPearls(sellerKey)
	movePearlsBetweenPouches(buyerPouch, func() string { return firstPearlOrigin(buyerKey) }, stallPouch, pearlAmount)
	ugnotPouch[buyerKey] += payout
	stall.UGNOTReserve -= payout
	stall.PearlReserve += pearlAmount
	stall.LatestTrade = buyer.Name + " bought " + strconv.Itoa(int(payout)) + " ugnot for " + strconv.Itoa(int(pearlAmount)) + " pearls."

	recordPearlTransfer(buyerKey, "Spent " + strconv.Itoa(int(pearlAmount)) + " pearls at " + stall.OwnerPlayer + "'s peddler.")
	recordUGNOTTransfer(buyerKey, "Bought " + strconv.Itoa(int(payout)) + " ugnot from " + stall.OwnerPlayer + "'s peddler.")
	recordPearlTransfer(sellerKey, "Bought " + strconv.Itoa(int(pearlAmount)) + " pearls from " + buyer.Name + " for " + strconv.Itoa(int(payout)) + " ugnot.")
	return "ugnot bought"
}

func DescribePeddler(playerName string) string {
	key := normalizeKey(playerName)
	stall, ok := peddlers[key]
	if !ok || !stall.Active {
		return "No active peddler."
	}

	out := "Peddler: " + stall.OwnerPlayer + "\n"
	out += "Model: " + stall.Model + "\n"
	out += "Place: " + placeName(players[key].Pos) + "\n"
	out += "Pearls: " + strconv.Itoa(int(stall.PearlReserve)) + "\n"
	out += "UGNOT: " + strconv.Itoa(int(stall.UGNOTReserve)) + "\n"
	out += "Price: " + strconv.Itoa(int(stall.PriceUGNOTPerPearl)) + " ugnot per pearl\n"
	out += "Latest: " + stall.LatestTrade
	return out
}

func ListPeddlers() string {
	count := 0
	out := "Peddlers\n"
	for _, stall := range peddlers {
		if stall == nil || !stall.Active {
			continue
		}
		count++
		place := "unknown"
		if player := players[normalizeKey(stall.OwnerPlayer)]; player != nil {
			place = placeName(player.Pos)
		}
		out += "- " + stall.OwnerPlayer + " [" + stall.Model + "] " +
			"at " + place + " " +
			strconv.Itoa(int(stall.PriceUGNOTPerPearl)) + " ugnot/pearl " +
			"pearls " + strconv.Itoa(int(stall.PearlReserve)) + " ugnot " + strconv.Itoa(int(stall.UGNOTReserve)) + "\n"
	}
	if count == 0 {
		return "No active peddlers."
	}
	return out
}

func DescribePearlPouch(playerName string) string {
	key := normalizeKey(playerName)
	player, ok := players[key]
	if !ok {
		panic("player not found")
	}

	pouch := ensurePearlPouch(key)
	out := "Pearl pouch for " + player.Name + "\n"
	out += "Total: " + strconv.Itoa(int(totalPearls(key))) + "\n"
	out += "RealmSupply: " + strconv.Itoa(int(totalPearlSupply)) + "\n"
	if len(pouch.Holdings) == 0 {
		out += "Holdings: empty\n"
	} else {
		out += "Holdings:\n"
		for origin, amount := range pouch.Holdings {
			if amount == 0 {
				continue
			}
			out += "- " + origin + " (" + strconv.Itoa(int(amount)) + ")\n"
		}
	}
	latest := latestPearlTransfer[key]
	if latest == "" {
		latest = "No pearl transfers yet."
	}
	out += "Latest: " + latest
	return out
}

func DescribeUGNOTPouch(playerName string) string {
	key := normalizeKey(playerName)
	player, ok := players[key]
	if !ok {
		panic("player not found")
	}

	out := "UGNOT pouch for " + player.Name + "\n"
	out += "Total: " + strconv.Itoa(int(ugnotPouch[key])) + "\n"
	latest := latestUGNOTTransfer[key]
	if latest == "" {
		latest = "No ugnot transfers yet."
	}
	out += "Latest: " + latest
	return out
}
