/**
 * spirit holding component; for items to have spirits inside of them for "advice"
 *
 * Used for the possessed blade and fantasy affixes
 */
/datum/component/spirit_holding
	///bool on if this component is currently polling for observers to inhabit the item
	var/attempting_awakening = FALSE
	/// Allows renaming the bound item
	var/allow_renaming = TRUE
	/// Allows channeling
	var/allow_channeling = TRUE
	/// Allows exorcism
	var/allow_exorcism
	///mob contained in the item.
	var/mob/living/simple_animal/shade/bound_spirit

/datum/component/spirit_holding/Initialize(datum/mind/soul_to_bind, mob/awakener, allow_renaming = TRUE, allow_channeling = TRUE, allow_exorcism = FALSE)
	if(!ismovable(parent)) //you may apply this to mobs, i take no responsibility for how that works out
		return COMPONENT_INCOMPATIBLE
	src.allow_renaming = allow_renaming
	src.allow_channeling = allow_channeling
	src.allow_exorcism = allow_exorcism
	if(soul_to_bind)
		bind_the_soule(soul_to_bind, awakener, soul_to_bind.name)

/datum/component/spirit_holding/Destroy(force)
	. = ..()
	if(bound_spirit)
		QDEL_NULL(bound_spirit)

/datum/component/spirit_holding/RegisterWithParent()
	RegisterSignal(parent, COMSIG_PARENT_EXAMINE, PROC_REF(on_examine))
	RegisterSignal(parent, COMSIG_ATOM_MIDDLE_CLICK, PROC_REF(on_attack_self))
	RegisterSignal(parent, COMSIG_PARENT_QDELETING, PROC_REF(on_destroy))

/datum/component/spirit_holding/UnregisterFromParent()
	UnregisterSignal(parent, list(COMSIG_PARENT_EXAMINE, COMSIG_ATOM_MIDDLE_CLICK, COMSIG_PARENT_QDELETING))

///signal fired on examining the parent
/datum/component/spirit_holding/proc/on_examine(datum/source, mob/user, list/examine_list)
	SIGNAL_HANDLER
	if(!bound_spirit)
		examine_list += span_notice("[parent] sleeps.[allow_channeling ? " Use [parent] in your hands to attempt to awaken it." : ""]")
		return
	examine_list += span_notice("[parent] is alive.")

///signal fired on self attacking parent
/datum/component/spirit_holding/proc/on_attack_self(datum/source, mob/user)
	SIGNAL_HANDLER
	INVOKE_ASYNC(src, PROC_REF(get_ghost), user)

/datum/component/spirit_holding/proc/get_ghost(mob/user)
	if(attempting_awakening)
		to_chat(user, span_notice("already channeling!"))
		return
	if(!allow_channeling && bound_spirit)
		to_chat(user, span_warning("Try as you might, the spirit within slumbers."))
		return
	attempting_awakening = TRUE
	to_chat(user, span_notice("channeling..."))
	var/list/L = pollCandidatesForMob(
		Question = "Do you want to play as [span_notice("Spirit of [span_danger("[user.real_name]'s")] weapon")]?",
		jobbanType = ROLE_PAI,
		poll_time = 20 SECONDS,
		ignore_category = POLL_IGNORE_POSSESSED_BLADE,
	)
	if(L.len > 0)
		var/mob/chosen_one =  pick(L)
		affix_spirit(user, chosen_one)
	else	
		to_chat(user, span_notice("The weapon is silent..."))

/// On conclusion of the ghost poll
/datum/component/spirit_holding/proc/affix_spirit(mob/awakener, mob/ghost)
	if(!ghost || isnull(ghost))
		to_chat(awakener, span_notice("The weapon is silent..."))
		attempting_awakening = FALSE
		return

	// Immediately unregister to prevent making a new spirit
	UnregisterSignal(parent, COMSIG_ITEM_ATTACK_SELF)
	if(QDELETED(parent)) //if the thing that we're conjuring a spirit in has been destroyed, don't create a spirit
		to_chat(ghost, span_userdanger("The new vessel for your spirit has been destroyed! You remain an unbound ghost."))
		return

	bind_the_soule(ghost.mind, awakener)

	attempting_awakening = FALSE

	if(!allow_renaming)
		return
	// Now that all of the important things are in place for our spirit, it's time for them to choose their name.
	var/valid_input_name = custom_name(awakener)
	if(valid_input_name)
		bound_spirit.fully_replace_character_name(null, "[valid_input_name]")

/datum/component/spirit_holding/proc/bind_the_soule(datum/mind/chosen_spirit, mob/awakener, name_override)
	bound_spirit = new(parent)
	chosen_spirit.transfer_to(bound_spirit)
	bound_spirit.fully_replace_character_name(null, "The spirit of [name_override ? name_override : parent]")
	bound_spirit.grant_all_languages(omnitongue=TRUE)

/**
 * custom_name : Simply sends a tgui input text box to the blade asking what name they want to be called, and retries it if the input is invalid.
 *
 * Arguments:
 * * awakener: user who interacted with the blade
 */
/datum/component/spirit_holding/proc/custom_name(mob/awakener, iteration = 1)
	if(iteration > 5)
		return "indecision" // The spirit of indecision
	var/chosen_name = sanitize_name(stripped_input(bound_spirit, "What are you named?"))
	if(!chosen_name) // with the way that sanitize_name works, it'll actually send the error message to the awakener as well.
		to_chat(awakener, span_warning("Your weapon did not select a valid name! Please wait as they try again.")) // more verbose than what sanitize_name might pass in it's error message
		return custom_name(awakener, iteration++)
	return chosen_name

///signal fired from parent being destroyed
/datum/component/spirit_holding/proc/on_destroy(datum/source)
	SIGNAL_HANDLER
	to_chat(bound_spirit, span_userdanger("You were destroyed!"))
	QDEL_NULL(bound_spirit)
