// Experimental compatibility subset of The Dictator's DicsLibrary.ash.
// Original package attribution: Prusias-kol/pTrack and The Dictator (DicsLibrary.ash).
// Derived from https://github.com/donCannoli-burns/dTrack/blob/main/kolmafia/scripts/ptrackSuite/DicsLibrary.ash
// Maintains original pTrack count, override, and valuation rules; USE AT YOUR OWN RISK.
// The broad, action-heavy DicsLibrary helpers are intentionally NOT exposed.
script "don_track_compat";
since r20300;
import <don_master_lib.ash>;

float ITEM_PRICE_MULTIPLIER = 0.9;

int[item] userPriceOverrides;
boolean checkUserPriceOverrides = false;
if (get_property("prusias_ptrack_priceOverrides") != "") {
	checkUserPriceOverrides = true;
	foreach x, it in get_property("prusias_ptrack_priceOverrides").split_string('(?<!\\\\)(, |,)') {
		string[int] split_map = split_string(it, ":");
		item overrideItem = to_item(split_map[0].to_int());
		int overridePrice = split_map[1].to_int();
		userPriceOverrides[overrideItem] = overridePrice;
	}

int get_property_int( string property ) {
	if ( substring(property,0,1) != "_" && !property_exists(property) )
		abort("Couldn't find preference "+property);
	return to_int(get_property(property));
}

boolean get_property_bool( string property ) {
	if ( !property_exists(property) && substring(property,0,1) != "_" )
		abort("Couldn't find preference "+property);
	return to_boolean(get_property(property));
}

static {
	boolean [item] GardenList = $items[Peppermint Pip Packet, packet of dragon's teeth, packet of beer seeds, packet of winter seeds, packet of thanksgarden seeds, packet of tall grass seeds,packet of mushroom spores];
	boolean [item] WorkshedList = $items[warbear jackhammer drill press, warbear auto-anvil, warbear induction oven, warbear chemistry lab, warbear high-efficiency still, warbear lp-rom burner, spinning wheel, snow machine, Asdon Martin keyfob (on ring), portable mayo clinic, little geneticist dna-splicing lab, diabolic pizza cube];
}

int total_amount( item it ) {
	int amount = item_amount(it);
		amount += equipped_amount(it);	// Does not include equips on familiars in terrarium
		amount += closet_amount(it);
		amount += storage_amount(it);
		amount += display_amount(it);
		amount += shop_amount(it);
	foreach f in $familiars[]
		if ( have_familiar(f) && my_familiar() != f && familiar_equipped_equipment(f) == it )
			amount++;
	if ( get_property_bool("autoSatisfyWithStash") )
		amount += stash_amount(it);
	if ( (GardenList contains it || WorkshedList contains it) && get_campground() contains it )
		amount += get_campground()[it];
	return amount;
}

int recent_price(item it) {
	if ( !it.tradeable )								// untradeable items don't have mall value
		return 0;
	else if ( historical_age(it) < 7.0 )				// 1 week sounds about right
		return historical_price(it) * ITEM_PRICE_MULTIPLIER;
	else if (mall_price(it)>0)
		return mall_price(it) * ITEM_PRICE_MULTIPLIER;
	else if (mall_price(it)<0 && my_hash() != "")	{ 	// items that are not in the mall return -1
		if ( is_npc_item(it) )							// Includes items such as lucky lindy, which are marked tradable, but can never be owned
			return 0;
		else if ( historical_age(it) < 4015 )			// historical age returns infinite for items that have never been seen before: 11 years should do it
			return historical_price(it) * ITEM_PRICE_MULTIPLIER;
		else
			return 1000000000;
	}
	else {
		abort("No idea how to price item: "+it);
		return -1;
	}
}

int averageValue ( boolean [item] itemList );

string[int] priceHash;

if(get_property("prusias_profitTracking_use_irrat_list").to_boolean() == true){
	string[int, int, int] irrat_list;
	file_to_map("irrats_item_prices.txt", irrat_list);

	foreach id, soldLastWeek, price in irrat_list {
		priceHash[id] = price;
	}
}


int itemValue ( item it ) {
	//User overrides
	if (checkUserPriceOverrides) {
		if (userPriceOverrides contains it) {
			return userPriceOverrides[it];
		}
	}

	//absolute exceptions that should override mall price
	switch (it) {
		//mob penguin
		case $item[Mob Penguin cellular phone]:
			return 0;
		//loathing idol
		case $item[Loathing Idol Microphone (75% charged)]:
			return 0.75 * itemValue($item[Loathing Idol Microphone]);
		case $item[Loathing Idol Microphone (50% charged)]:
			return 0.5 * itemValue($item[Loathing Idol Microphone]);
		case $item[Loathing Idol Microphone (25% charged)]:
			return 0.25 * itemValue($item[Loathing Idol Microphone]);
	}
	
	int specialValue ( item it ) {
		switch (it) {
			case $item[spooky putty monster]:
				return itemValue($item[spooky putty sheet]);
			case $item[empty Rain-Doh can]:
				return itemValue($item[can of Rain-Doh]);
			case $item[coffee pixie stick]:
				return itemValue($item[Game Grid ticket])*10;
			case $item[roll of hob-os]:
				return 4.5*averageValue($items[sterno-flavored Hob-O, frostbite-flavored Hob-O, fry-oil-flavored Hob-O, strawberry-flavored Hob-O, garbage-juice-flavored Hob-O]);
			case $item[bricko brick]:
				return 90;
			case $item[bricko trunk]:
				return 5*itemValue($item[BRICKO brick])+itemValue($item[BRICKO eye brick])/10;
			case $item[d4]:
				return 2.5*itemValue($item[generic restorative potion]);
			case $item[d6]:
				return 3.5*itemValue($item[generic mana potion]);
			case $item[d8]:
				return 4.5*itemValue($item[generic healing potion]);
			case $item[bag of park garbage]:
				return 200;
			case $item[gathered meat-clip]:
				return 520;
			case $item[1,970 carat gold]:
				return 20500; //Torturebot
			case $item[unfinished ice sculpture]:
				return 3*itemValue($item[snow berries])+3*itemValue($item[ice harvest]);
			case $item[free-range mushroom]:
				return 3*itemValue($item[mushroom filet]);
			case $item[plump free-range mushroom]:
				return itemValue($item[free-range mushroom])+3*itemValue($item[mushroom filet]);
			case $item[bulky free-range mushroom]:
				return itemValue($item[plump free-range mushroom])+3*itemValue($item[mushroom filet]);
			case $item[giant free-range mushroom]:
				return itemValue($item[bulky free-range mushroom])+itemValue($item[mushroom slab]);
			case $item[immense free-range mushroom]:
				return itemValue($item[giant free-range mushroom])+itemValue($item[mushroom slab]);
			case $item[colossal free-range mushroom]:
				return itemValue($item[immense free-range mushroom])+itemValue($item[house-sized mushroom]);
            case $item[Freddy Kruegerand]:
                //FK items low volume, extra multiplier (sellbot pricing)
                return 0.95* max(itemValue($item[	bottle of Bloodweiser]), itemValue($item[electric Kool-Aid])) / 200;
            //FunFunds
            case $item[8205]:
                return itemValue($item[one-day ticket to Dinseylandfill]) / 20;
            case $item[Beach Buck]:
                return itemValue($item[one-day ticket to Spring Break Beach]) / 100;
            case $item[Volcoino]:
                return itemValue($item[one-day ticket to That 70s Volcano]) / 3;
            case $item[Coinspiracy]:
                return itemValue($item[one-day ticket to Conspiracy Island]) / 100;
            case $item[Wal-Mart gift certificate]:
                return itemValue($item[one-day ticket to The Glaciest]) / 50;
			case $item[fake hand]:
				return 50000;
			case $item[Source Essence]:
				return 10;
			default:
				if ( npc_price(it) > 0 )
					return npc_price(it);
				return 0;
		}
	}

	int singularValue( item it ) {
		int minValue = specialValue(it);
		if(get_property("prusias_profitTracking_use_irrat_list").to_boolean() == true && minValue == 0){
			return priceHash[it.id].to_int();
		}

		if ( recent_price(it) <= max(100,2* autosell_price(it)) )
			return max( minValue , autosell_price(it) );
		else
			return max( minValue , recent_price(it) );
	}

	int maxValue = singularValue(it);
	if ( count(get_related(it,"fold")) > 0 )
		foreach j in get_related(it,"fold")
			maxValue = min( maxValue, singularValue(j) );
	if ( count(get_related(it,"zap")) > 0 )
		foreach j in get_related(it,"zap")
			maxValue = min( maxValue, singularValue(j) );

	return maxValue;
}

int averageValue ( boolean [item] itemList ) {
	int total;
	if ( count(itemList) == 0 )
		return 0;
	foreach it in itemList
		total += itemValue(it);
	return total/count(itemList);
}

int totalValue ( int [item] itemList ) {
	int total;
	foreach it in itemList
		total += itemValue(it)*itemList[it];
	return total;
}

int totalValue ( float [item] itemList ) {
	int total;
	foreach it in itemList
		total += itemValue(it)*itemList[it];
	return total;
}
