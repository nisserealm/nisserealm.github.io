package nisse

import "strconv"

type GuildTreasury struct {
	Position   Position
	Purse      *PearlPurse
	SalesCount uint64
}

type CompanionListing struct {
	ID                 uint64
	AssetID            uint64
	CompanionID        uint64
	OwnerPlayer        string
	OwnerLineage       Address
	MarketPos          Position
	OwnerPearlPrice    uint64
	GuildMarkupPearls  uint64
	CreatedTurn        uint64
	Active             bool
}

var guildTreasuries map[string]*GuildTreasury
var companionListings map[uint64]*CompanionListing
var listedCompanions map[uint64]*Companion
var nextCompanionListingID uint64

func init() {
	guildTreasuries = make(map[string]*GuildTreasury)
	companionListings = make(map[uint64]*CompanionListing)
	listedCompanions = make(map[uint64]*Companion)
	nextCompanionListingID = 1
}

func cityMarketKey(pos Position) string {
	return tileInventoryKey(pos)
}

func isCityMarketTile(pos Position) bool {
	switch terrainName(GetTile(pos.X, pos.Y)) {
	case "city", "city_north", "city_south":
		return true
	default:
		return false
	}
}

func ensureGuildTreasury(pos Position) *GuildTreasury {
	key := cityMarketKey(pos)
	if guildTreasuries[key] == nil {
		guildTreasuries[key] = &GuildTreasury{
			Position: pos,
			Purse:    &PearlPurse{Holdings: make(map[string]uint64)},
		}
	}
	if guildTreasuries[key].Purse == nil {
		guildTreasuries[key].Purse = &PearlPurse{Holdings: make(map[string]uint64)}
	}
	return guildTreasuries[key]
}

func companionMarkup(ownerPrice uint64) uint64 {
	if ownerPrice == 0 {
		return 0
	}
	return (ownerPrice + 4) / 5
}

func listedPearlPrice(listing *CompanionListing) uint64 {
	if listing == nil {
		return 0
	}
	if ownerListingIsLocal(listing) {
		return listing.OwnerPearlPrice
	}
	return listing.OwnerPearlPrice + listing.GuildMarkupPearls
}

func ownerListingIsLocal(listing *CompanionListing) bool {
	if listing == nil || !listing.Active {
		return false
	}
	ownerKey := normalizeKey(listing.OwnerPlayer)
	player := players[ownerKey]
	if player == nil {
		return false
	}
	if !sameTile(player.Pos, listing.MarketPos) {
		return false
	}
	stall := peddlers[ownerKey]
	return stall != nil && stall.Active
}

func activeListingByAssetID(assetID uint64) *CompanionListing {
	for id := uint64(1); id < nextCompanionListingID; id++ {
		listing := companionListings[id]
		if listing == nil || !listing.Active || listing.AssetID != assetID {
			continue
		}
		return listing
	}
	return nil
}

func removeListedCompanion(assetID uint64) {
	delete(listedCompanions, assetID)
}

func ensureCompanionSellerRecord(player *Player) {
	if player == nil {
		return
	}
	key := normalizeKey(player.Name)
	stall := peddlers[key]
	if stall != nil {
		stall.OwnerPlayer = player.Name
		stall.Active = true
		if stall.Model == "" {
			stall.Model = "fixed"
		}
		if stall.LatestTrade == "" {
			stall.LatestTrade = "Opened a market stall."
		}
		return
	}
	peddlers[key] = &Peddler{
		OwnerPlayer:        player.Name,
		Model:              "fixed",
		PearlReserve:       0,
		UGNOTReserve:       0,
		PriceUGNOTPerPearl: 0,
		LatestTrade:        "Opened a market stall.",
		Active:             true,
	}
}

func reclaimActiveListingsToOwner(playerKey string, player *Player) uint64 {
	if player == nil {
		return 0
	}
	reclaimed := uint64(0)
	for id := uint64(1); id < nextCompanionListingID; id++ {
		listing := companionListings[id]
		if listing == nil || !listing.Active || normalizeKey(listing.OwnerPlayer) != playerKey {
			continue
		}
		asset := assets[listing.AssetID]
		companion := listedCompanions[listing.AssetID]
		listing.Active = false
		removeListedCompanion(listing.AssetID)
		if asset == nil || companion == nil {
			continue
		}
		if playerBagHasRoom(player) {
			ensureCompanionCollection(playerKey)[companion.ID] = companion
			if player.ActiveCompanionID == 0 {
				player.ActiveCompanionID = companion.ID
			}
			asset.Status = "held"
			asset.LastKnownPos = player.Pos
			recordAssetHistory(asset.ID, player.Turns, "listing-closed", player.Name, player.Name, placeName(player.Pos), asset.Code+" returns from the closed stall.")
		} else {
			storeAssetOnTile(player.Pos, asset.ID, player.Name, player.LineageOwner, player.Turns)
		}
		reclaimed++
	}
	return reclaimed
}

func stashActiveListingsOnTileForLineage(player *Player) {
	if player == nil {
		return
	}
	for id := uint64(1); id < nextCompanionListingID; id++ {
		listing := companionListings[id]
		if listing == nil || !listing.Active || normalizeKey(listing.OwnerPlayer) != normalizeKey(player.Name) {
			continue
		}
		listing.Active = false
		asset := assets[listing.AssetID]
		if asset == nil {
			continue
		}
		storeAssetOnTile(player.Pos, asset.ID, player.Name, player.LineageOwner, player.Turns)
		removeListedCompanion(asset.ID)
	}
}

func ListCompanionForSale(cur realm, playerName string, companionID uint64, pearlPrice uint64) string {
	key, player, _ := ownedPlayer(playerName)
	if !isCityMarketTile(player.Pos) {
		panic("companions can only be listed from a city market tile")
	}
	ensureCompanionSellerRecord(player)
	if pearlPrice == 0 {
		panic("pearl price must be greater than zero")
	}
	collection := companions[key]
	companion, exists := collection[companionID]
	if !exists {
		panic("companion not found")
	}
	asset := assets[companion.AssetID]
	if asset == nil || asset.Status != "held" {
		panic("companion is not currently in your bag")
	}
	if activeListingByAssetID(asset.ID) != nil {
		panic("companion is already listed")
	}

	delete(collection, companionID)
	if player.ActiveCompanionID == companionID {
		player.ActiveCompanionID = 0
	}
	listedCompanions[asset.ID] = companion
	asset.Status = "listed"
	asset.LastKnownPos = player.Pos

	id := nextCompanionListingID
	nextCompanionListingID++
	listing := &CompanionListing{
		ID:                id,
		AssetID:           asset.ID,
		CompanionID:       companion.ID,
		OwnerPlayer:       player.Name,
		OwnerLineage:      player.LineageOwner,
		MarketPos:         player.Pos,
		OwnerPearlPrice:   pearlPrice,
		GuildMarkupPearls: companionMarkup(pearlPrice),
		CreatedTurn:       player.Turns,
		Active:            true,
	}
	companionListings[id] = listing
	recordAssetHistory(asset.ID, player.Turns, "listed", player.Name, "", placeName(player.Pos), asset.Code+" is listed for "+strconv.Itoa(int(listedPearlPrice(listing)))+" pearls.")
	return asset.Code + " is listed for sale in " + placeName(player.Pos)
}

func CancelCompanionListing(cur realm, playerName string, assetCode string) string {
	key, player, _ := ownedPlayer(playerName)
	asset := getAssetByCode(assetCode)
	listing := activeListingByAssetID(asset.ID)
	if listing == nil {
		panic("active listing not found")
	}
	if normalizeKey(listing.OwnerPlayer) != key {
		panic("only the listing owner can cancel this listing")
	}
	if !playerBagHasRoom(player) {
		panic("your bag is full")
	}
	companion := listedCompanions[asset.ID]
	if companion == nil {
		panic("listed companion not found")
	}
	listing.Active = false
	removeListedCompanion(asset.ID)
	ensureCompanionCollection(key)[companion.ID] = companion
	if player.ActiveCompanionID == 0 {
		player.ActiveCompanionID = companion.ID
	}
	asset.Status = "held"
	asset.LastKnownPos = player.Pos
	recordAssetHistory(asset.ID, player.Turns, "listing-cancelled", player.Name, player.Name, placeName(player.Pos), asset.Code+" returns from market custody.")
	return asset.Code + " returns to your side."
}

func BuyListedCompanion(cur realm, buyerPlayerName string, assetCode string) string {
	buyerKey, buyer, _ := ownedPlayer(buyerPlayerName)
	asset := getAssetByCode(assetCode)
	listing := activeListingByAssetID(asset.ID)
	if listing == nil {
		panic("active listing not found")
	}
	if sameTile(buyer.Pos, listing.MarketPos) == false {
		panic("buyer must stand on the market tile")
	}
	if !playerBagHasRoom(buyer) {
		panic("your bag is full")
	}
	if normalizeKey(listing.OwnerPlayer) == buyerKey {
		panic("cannot buy your own listing")
	}

	price := listedPearlPrice(listing)
	if totalPearls(buyerKey) < price {
		panic("not enough pearls")
	}

	buyerPouch := ensurePearlPouch(buyerKey)
	ownerKey := normalizeKey(listing.OwnerPlayer)
	ownerPouch := ensurePearlPouch(ownerKey)
	movePearlsBetweenPouches(buyerPouch, func() string { return firstPearlOrigin(buyerKey) }, ownerPouch, listing.OwnerPearlPrice)
	markup := price - listing.OwnerPearlPrice
	if markup > 0 {
		guild := ensureGuildTreasury(listing.MarketPos)
		movePearlsBetweenPouches(buyerPouch, func() string { return firstPearlOrigin(buyerKey) }, guild.Purse, markup)
		guild.SalesCount++
	}

	companion := listedCompanions[asset.ID]
	if companion == nil {
		panic("listed companion not found")
	}
	listing.Active = false
	removeListedCompanion(asset.ID)
	companion.OwnerPlayer = buyer.Name
	ensureCompanionCollection(buyerKey)[companion.ID] = companion
	if buyer.ActiveCompanionID == 0 {
		buyer.ActiveCompanionID = companion.ID
	}
	asset.OwnerPlayer = buyer.Name
	asset.OwnerLineage = buyer.LineageOwner
	asset.Status = "held"
	asset.LastKnownPos = buyer.Pos
	if owner := players[ownerKey]; owner != nil && owner.Soul > 0 {
		owner.Soul--
		createDiaryEntry(ownerKey,
			"market",
			placeName(listing.MarketPos),
			"day",
			"A companion sold in the city",
			"The city trade leaves a mark on you.\n"+
				"Soul: -1 after selling "+asset.DisplayName+" for pearls in "+placeName(listing.MarketPos)+".")
	}
	recordPearlTransfer(ownerKey, "Sold "+asset.Code+" for "+strconv.Itoa(int(listing.OwnerPearlPrice))+" pearls in "+placeName(listing.MarketPos)+".")
	recordPearlTransfer(buyerKey, "Bought "+asset.Code+" for "+strconv.Itoa(int(price))+" pearls in "+placeName(listing.MarketPos)+".")
	recordAssetHistory(asset.ID, buyer.Turns, "sold", listing.OwnerPlayer, buyer.Name, placeName(listing.MarketPos), asset.Code+" leaves the market for "+strconv.Itoa(int(price))+" pearls.")
	return asset.Code + " now belongs to " + buyer.Name
}

func DescribeGuildTreasury(x uint64, y uint64) string {
	pos := Position{X: x, Y: y}
	if !isCityMarketTile(pos) {
		return "No guild treasury stands on this tile."
	}
	guild := ensureGuildTreasury(pos)
	out := "Guild treasury at (" + strconv.Itoa(int(x)) + ", " + strconv.Itoa(int(y)) + ")\n"
	out += "Pearls: " + strconv.Itoa(int(totalPearlsInPurse(guild.Purse))) + "\n"
	out += "Sales: " + strconv.Itoa(int(guild.SalesCount))
	return out
}

func ListCompanionListings() string {
	out := "Companion listings\n"
	count := 0
	for id := uint64(1); id < nextCompanionListingID; id++ {
		listing := companionListings[id]
		if listing == nil || !listing.Active {
			continue
		}
		asset := assets[listing.AssetID]
		if asset == nil {
			continue
		}
		count++
		out += "- " + asset.Code
		if asset.DisplayName != "" {
			out += " \"" + asset.DisplayName + "\""
		}
		out += " owner " + listing.OwnerPlayer
		out += " net " + strconv.Itoa(int(listing.OwnerPearlPrice)) + " pearls"
		price := listedPearlPrice(listing)
		if price != listing.OwnerPearlPrice {
			out += " listed " + strconv.Itoa(int(price)) + " pearls"
		}
		if ownerListingIsLocal(listing) {
			out += " [local]"
		} else {
			out += " [remote]"
		}
		out += " @ (" + strconv.Itoa(int(listing.MarketPos.X)) + ", " + strconv.Itoa(int(listing.MarketPos.Y)) + ")\n"
	}
	if count == 0 {
		return "No companion listings."
	}
	return out
}
