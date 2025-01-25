/*
	For the sake of dungeon generator being modular and not tied exclusively to dungeon,
	most of the objects and modifications required exclusively for it will be kept here.
*/

var/global/list/small_dungeon_room_templates = list()
var/global/list/large_dungeon_room_templates = list()

var/global/list/starting_dungeon_room_templates = list()
var/global/list/ending_dungeon_room_templates = list()

/proc/populateDungeonMapLists()
	if(large_dungeon_room_templates.len || small_dungeon_room_templates.len)
		return
	for(var/item in subtypesof(/datum/map_template/dungeon_template/room))
		var/datum/map_template/dungeon_template/submap = item
		var/datum/map_template/dungeon_template/S = new submap()
		small_dungeon_room_templates += S

	for(var/item in subtypesof(/datum/map_template/dungeon_template/large))
		var/datum/map_template/dungeon_template/submap = item
		var/datum/map_template/dungeon_template/S = new submap()
		large_dungeon_room_templates += S

	for(var/item in subtypesof(/datum/map_template/dungeon_template/starting))
		var/datum/map_template/dungeon_template/submap = item
		var/datum/map_template/dungeon_template/S = new submap()
		starting_dungeon_room_templates += S

	for(var/item in subtypesof(/datum/map_template/dungeon_template/ending))
		var/datum/map_template/dungeon_template/submap = item
		var/datum/map_template/dungeon_template/S = new submap()
		ending_dungeon_room_templates += S

/obj/procedural/jp_DungeonRoom/preexist/square/submap/dungeon
	name = "dungeon room"
/obj/procedural/jp_DungeonRoom/preexist/square/submap/dungeon/New()
	..()
	my_map = pick(small_dungeon_room_templates)

/obj/procedural/jp_DungeonRoom/preexist/square/submap/dungeon/large
	name = "dungeon core room"
/obj/procedural/jp_DungeonRoom/preexist/square/submap/dungeon/large/New()
	..()
	my_map = pick(large_dungeon_room_templates)

/obj/procedural/jp_DungeonRoom/preexist/square/submap/dungeon/starting
	name = "dungeon starting room"
/obj/procedural/jp_DungeonRoom/preexist/square/submap/dungeon/starting/New()
	..()
	my_map = pick(starting_dungeon_room_templates)

/obj/procedural/jp_DungeonRoom/preexist/square/submap/dungeon/ending
	name = "dungeon ending room"
/obj/procedural/jp_DungeonRoom/preexist/square/submap/dungeon/ending/New()
	..()
	my_map = pick(ending_dungeon_room_templates)

/* /proc/check_dungeon_list()
	return (free_dungeon_ladders.len)  */

/obj/procedural/jp_DungeonGenerator/dungeon
	name = "Dungeon Procedural Generator"
	regen_specific = TRUE
	regen_light = /obj/machinery/light/rogue/torchholder/autoattach


/*
	Finds a line of walls adjacent to the line of turfs given
*/

/obj/procedural/jp_DungeonGenerator/dungeon/proc/checkForWalls(var/list/line)
	var/turf/t1 = line[1]
	var/turf/t2 = line[2]
	var/direction = get_dir(t1, t2)
	var/list/walls = list()
	for(var/turf/A in getAdjacent(t1))
		var/length = line.len
		var/turf/T = A
		walls += T
		while(length > 0)
			length = length - 1
			T = get_step(T, direction)
			if (T.is_wall)
				walls += T
				if(walls.len == line.len)
					return walls
			else
				walls = list()
				break


	return list()

/*
	Generates burrow-linked ladders
*/

/* /obj/procedural/jp_DungeonGenerator/dungeon/proc/makeLadders()
	var/ladders_to_place = 20
	if(numRooms < ladders_to_place)
		return
	var/list/obj/procedural/jp_DungeonRoom/done_rooms = list()
	while(ladders_to_place > 0)
		if(numRooms > 1)
			if(done_rooms.len == out_rooms.len)
				testing("dungeon generator went through all rooms, but couldn't place all ladders! Ladders left - [ladders_to_place]")
				break
		var/obj/procedural/jp_DungeonRoom/picked_room = pick(out_rooms)
		if(picked_room in done_rooms)
			continue
		var/list/turf/viable_turfs = list()
		for (var/turf/open/floor/F in range(roomMinSize + 1, picked_room.centre))
			//not under walls
			if (F.is_wall)
				continue

			if (F.contents.len > 1) //There's a lot of things rangine from tables to mechs or closets that can be on the chosen turf, so we'll ignore all turfs that have something aside lighting overlay
				continue


			/* //No turfs in space
			if (turf_is_external(F))
				continue */

			//To be valid, the floor needs to have a wall in a cardinal direction
			for (var/d in cardinals)
				var/turf/T = get_step(F, d)
				if (T.is_wall)
					//Its got a wall!
					viable_turfs[F] = T //We put this floor and its wall into the possible turfs list
					break

		if(viable_turfs.len == 0)
			done_rooms += picked_room
			continue

		//var/turf/ladder_turf = pick(viable_turfs)
		//var/obj/structure/multiz/ladder/up/dungeon/newladder = new/obj/structure/multiz/ladder/up/dungeon(ladder_turf)
		//free_dungeon_ladders += newladder
		//ladders_to_place--
		done_rooms += picked_room
 */


/*
	Exactly what it says in the procname - makes a niche
*/

/obj/procedural/jp_DungeonGenerator/dungeon/proc/makeNiche(var/turf/T)
	var/list/nicheline = list()
	for(var/i in list(NORTH,EAST,SOUTH,WEST))
		switch(i)
			if(NORTH)
				nicheline = findNicheTurfs(block(T, locate(T.x, T.y + 4, T.z)))
			if(EAST)
				nicheline = findNicheTurfs(block(T, locate(T.x + 4, T.y, T.z)))
			if(SOUTH)
				nicheline = findNicheTurfs(block(T, locate(T.x, T.y - 4, T.z)))
			if(WEST)
				nicheline = findNicheTurfs(block(T, locate(T.x - 4, T.y, T.z)))
		if(nicheline.len > 3)
			break

	var/list/wall_line = list()
	if(nicheline.len > 3)
	 wall_line = checkForWalls(nicheline)
	if(wall_line.len)
		//for(var/turf/W in nicheline)
		for(var/turf/W in wall_line)
			if(locate(/obj/machinery/light/rogue/torchholder/autoattach, W))
				var/obj/machinery/light/rogue/torchholder/autoattach/L = locate(/obj/machinery/light/rogue/torchholder/autoattach, W)
				qdel(L)
			W.ChangeTurf(/turf/open/floor/rogue/dirt/road)
		return TRUE
	else
		return FALSE

/obj/procedural/jp_DungeonGenerator/dungeon/proc/findNicheTurfs(var/list/turfs)
	var/list/L = list()
	for(var/turf/F in turfs)
		if(F.is_wall || !(F in path_turfs))
			if(L.len < 3)
				L = list()
			break
		else
			L += F

	return L


/obj/procedural/jp_DungeonGenerator/dungeon/proc/populateCorridors()
	var/niche_count = 20
	var/try_count = niche_count * 7 //In case it somehow zig-zags all of the corridors and stucks in a loop
	var/trap_count = 200
	var/list/path_turfs_copy = path_turfs.Copy()
	while(niche_count > 0 && try_count > 0)
		try_count = try_count - 1
		var/turf/N = pick(path_turfs_copy)
		path_turfs_copy -= N
		if(makeNiche(N))
			niche_count = niche_count - 1
	while(trap_count > 0)
		trap_count = trap_count - 1
		var/turf/N = pick(path_turfs_copy)
		path_turfs_copy -= N
/* 		if(prob(60))
			new /obj/random/traps(N)
		else
			new /obj/random/mob/psi_monster(N) */
	for(var/turf/T in path_turfs)
		if(prob(30))
			new /obj/effect/decal/cleanable/dirt(T) //Dirty Dungeon



/obj/procedural/dungenerator/dungeon
	name = "Dungeon Gen"

// Skip dungeon. DO NOT REMOVE ELSE, it becomes unreachable
#if defined(UNIT_TESTS) || defined(SPACEMAN_DMM)
/obj/procedural/dungenerator/dungeon/New()
	log_test("Skipping dungeon generation for unit tests")
	return
#else
/obj/procedural/dungenerator/dungeon/New()
	while(1)
		if(Master.current_runlevel)
			populateDungeonMapLists() //It's not a hook because mapping subsystem has to intialize first
			break
		else
			sleep(150)
	spawn()
		testing_variable(start, REALTIMEOFDAY)
		var/obj/procedural/jp_DungeonGenerator/dungeon/generate = new /obj/procedural/jp_DungeonGenerator/dungeon(src)
		testing("Beginning procedural generation of [name] -  Z-level [z].")
		generate.name = name
		generate.setArea(locate(16, 16, z), locate(110, 110, z))
		generate.setWallType(/turf/closed/wall/mineral/rogue/stonebrick)
		generate.setLightChance(1)
		generate.setFloorType(/turf/open/floor/rogue/dirt/road)
		generate.setAllowedRooms(list(/obj/procedural/jp_DungeonRoom/preexist/square/submap/dungeon/large))
		generate.setNumRooms(8) //8 dungeons "core" rooms
		generate.setExtraPaths(2)
		generate.setMinPathLength(5)
		generate.setMaxPathLength(80)
		generate.setMinLongPathLength(5)
		generate.setLongPathChance(10)
		generate.setPathEndChance(100)
		generate.setRoomMinSize(4)
		generate.setRoomMaxSize(4)
		generate.setPathWidth(1)
		generate.generate()
		testing("Finished procedural generation of Core Rooms in [(REALTIMEOFDAY - start) / 10] seconds.")

		sleep(90)

		generate.setArea(locate(4, 4, z), locate(127, 127, z))
		generate.setAllowedRooms(list(/obj/procedural/jp_DungeonRoom/preexist/square/submap/dungeon))
		generate.setNumRooms(32) // 32 or so smaller rooms
		generate.setExtraPaths(2)
		generate.setMinPathLength(1)
		generate.setMaxPathLength(65) //Small Rooms are 65 at most appart
		generate.setMinLongPathLength(5)
		generate.setLongPathChance(10)
		generate.setPathEndChance(60)
		generate.setRoomMinSize(2)
		generate.setRoomMaxSize(2)
		generate.setPathWidth(3)
		generate.setUsePreexistingRegions(TRUE)
		generate.setDoAccurateRoomPlacementCheck(TRUE)
		generate.generate()
		testing("Finished procedural generation of Small Rooms in [(REALTIMEOFDAY - start) / 10] seconds.")

		sleep(90)

		generate.setArea(locate(4, 8, z), locate(124, 124, z))
		generate.setAllowedRooms(list(/obj/procedural/jp_DungeonRoom/preexist/square/submap/dungeon/starting))
		generate.setNumRooms(1) 
		generate.setExtraPaths(3)
		generate.setMinPathLength(1)
		generate.setMaxPathLength(65) 
		generate.setMinLongPathLength(5)
		generate.setLongPathChance(10)
		generate.setPathEndChance(0)
		generate.setRoomMinSize(3)
		generate.setRoomMaxSize(3)
		generate.setPathWidth(1)
		generate.generate()
		testing("Finished procedural generation of Entrance Room in [(REALTIMEOFDAY - start) / 10] seconds.")

		sleep(90)

		generate.setArea(locate(20, 20, z), locate(100, 100, z))
		generate.setAllowedRooms(list(/obj/procedural/jp_DungeonRoom/preexist/square/submap/dungeon/ending))
		generate.setNumRooms(3)
		generate.setExtraPaths(3)
		generate.setMinPathLength(1)
		generate.setMaxPathLength(65) 
		generate.setMinLongPathLength(5)
		generate.setLongPathChance(10)
		generate.setPathEndChance(0)
		generate.setRoomMinSize(3)
		generate.setRoomMaxSize(3)
		generate.setPathWidth(1)
		generate.generate()
		generate.populateCorridors()
		testing("Finished procedural generation of Exit Room(s).")
		testing("Finished procedural generation of [name]. [generate.errString(generate.out_error)] -  Z-level [z], in [(REALTIMEOFDAY - start) / 10] seconds.")
#endif

