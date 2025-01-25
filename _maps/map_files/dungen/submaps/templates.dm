/datum/map_template/dungeon_template/room
	name = "Dungeon Template"
	desc = "Deep. Dark. Marvelous."
	//template_group = null // If this is set, no more than one template in the same group will be spawned, per submap seeding.
	width = 6
	height = 6
	mappath = null
	annihilate = FALSE // If true, all (movable) atoms at the location where the map is loaded will be deleted before the map is loaded in.
	var/room_tag = null


/datum/map_template/dungeon_template/core
	name = "Dungeon Large Template"
	desc = "Deeper. Darker. Marvelous-er."
	width = 11
	height = 11
	
