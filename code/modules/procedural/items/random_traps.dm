/obj/random/traps
	name = "random traps"
	alpha = 128

/obj/random/traps/item_to_spawn()
	var/list/possible_traps = list(/obj/item/restraints/legcuffs/beartrap/armed = 1,
		/obj/item/restraints/legcuffs/beartrap/armed/camouflage = 0.5,
		/obj/structure/trap/fire = 1,
		/obj/structure/trap/fire/camouflage = 0.25,
		/obj/structure/trap/damage = 0.1 )

	//Check that its possible to spawn the chosen trap at this location
	while (possible_traps.len)
		var/trap = pickweight(possible_traps)
		if (can_spawn_trap(loc, trap))
			return trap
		else
			possible_traps -= trap

//Checks if a trap can spawn in this location
/proc/can_spawn_trap(var/turf/T, var/trap)
	.=TRUE
	if (locate(/turf/open/water) in dview(3, T))
		return FALSE
	return TRUE
