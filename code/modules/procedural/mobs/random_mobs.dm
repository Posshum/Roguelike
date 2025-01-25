//This needs to be fleshed out further in the future after a lot of cleanup.
/obj/random/mob/skeleton
	name = "random skeleton"
	alpha = 128

/obj/random/mob/skeleton/item_to_spawn()
	mobs = list(/mob/living/carbon/human/species/skeleton/npc = 1)
	return pickweight(mobs)

//Basic mobs. Something weak and common to fight. These generate throughout the dungeon.
/obj/random/mob/any_roguemob
	name = "random rogue enemy"
	alpha = 128

/obj/random/mob/any_roguemob/item_to_spawn()
	mobs = list(/mob/living/simple_animal/hostile/retaliate/rogue/bigrat = 3,
				/mob/living/carbon/human/species/skeleton/npc = 2,
				/mob/living/carbon/human/species/goblin/npc = 2,
				/mob/living/simple_animal/hostile/retaliate/rogue/wolf = 1,
				/mob/living/simple_animal/hostile/retaliate/rogue/spider = 1
	)
	return pickweight(mobs)

//"Elite" enemies, so to speak. Can contain unique mobs, strong enemies, or 'mini' bosses. Spawn rate is handled in dungeon.dm for world generation.
/obj/random/mob/rare_roguemob
	name = "random rare rogue enemy"
	alpha = 128

/obj/random/mob/rare_roguemob/item_to_spawn()
	mobs = list(/mob/living/simple_animal/hostile/retaliate/rogue/bogtroll = 2,
				/mob/living/simple_animal/hostile/retaliate/rogue/cavetroll = 2,
				/mob/living/simple_animal/hostile/retaliate/rogue/minotaur = 1,
				/mob/living/simple_animal/hostile/retaliate/rogue/mole = 1
	)
	return pickweight(mobs)
