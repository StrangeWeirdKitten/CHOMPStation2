//Since it didn't really belong in any other category, I'm putting this here
//This is for procs to replace all the goddamn 'in world's that are chilling around the code

// CHOMPEdit Start - Globals
var/global/list/player_list = list()				//List of all mobs **with clients attached**. Excludes /mob/new_player
var/global/list/mob_list = list()					//List of all mobs, including clientless
GLOBAL_LIST_EMPTY(human_mob_list)					//List of all human mobs and sub-types, including clientless
GLOBAL_LIST_EMPTY(silicon_mob_list)					//List of all silicon mobs, including clientless
var/global/list/ai_list = list()					//List of all AIs, including clientless
var/global/list/living_mob_list = list()			//List of all alive mobs, including clientless. Excludes /mob/new_player
GLOBAL_LIST_EMPTY(dead_mob_list)					//List of all dead mobs, including clientless. Excludes /mob/new_player
GLOBAL_LIST_EMPTY(observer_mob_list)				//List of all /mob/observer/dead, including clientless.
var/global/list/listening_objects = list()			//List of all objects which care about receiving messages (communicators, radios, etc)
GLOBAL_LIST_EMPTY(cleanbot_reserved_turfs)			//List of all turfs currently targeted by some cleanbot

GLOBAL_LIST_EMPTY(cable_list)						//Index for all cables, so that powernets don't have to look through the entire world all the time
GLOBAL_LIST_EMPTY(landmarks_list)					//list of all landmarks created
GLOBAL_LIST_EMPTY(event_triggers)					//Associative list of creator_ckey:list(landmark references) for event triggers
GLOBAL_LIST_EMPTY(surgery_steps)					//list of all surgery steps  |BS12
// UNUSED / NO REFERENCE IN CODE - side_effects
//GLOBAL_LIST_EMPTY(side_effects)					//list of all medical sideeffects types by thier names |BS12
GLOBAL_LIST_EMPTY(mechas_list)						//list of all mechs. Used by hostile mobs target tracking.
GLOBAL_LIST_EMPTY(joblist)							//list of all jobstypes, minus borg and AI
// CHOMPEdit End

#define all_genders_define_list list(MALE,FEMALE,PLURAL,NEUTER,HERM) //VOREStaton Edit
#define all_genders_text_list list("Male","Female","Plural","Neuter","Herm") //VOREStation Edit

var/list/mannequins_

// Times that players are allowed to respawn ("ckey" = world.time)
GLOBAL_LIST_EMPTY(respawn_timers)

// Holomaps
var/global/list/holomap_markers = list()
var/global/list/mapping_units = list()
var/global/list/mapping_beacons = list()

//Preferences stuff
	//Hairstyles
var/global/list/hair_styles_list = list()			//stores /datum/sprite_accessory/hair indexed by name
var/global/list/hair_styles_male_list = list()
var/global/list/hair_styles_female_list = list()
var/global/list/facial_hair_styles_list = list()	//stores /datum/sprite_accessory/facial_hair indexed by name
var/global/list/facial_hair_styles_male_list = list()
var/global/list/facial_hair_styles_female_list = list()
var/global/list/skin_styles_female_list = list()		//unused
var/global/list/body_marking_styles_list = list()		//stores /datum/sprite_accessory/marking indexed by name
var/global/list/body_marking_nopersist_list = list()	// Body marking styles, minus non-genetic markings and augments
var/global/list/ear_styles_list = list()	// Stores /datum/sprite_accessory/ears indexed by type
var/global/list/tail_styles_list = list()	// Stores /datum/sprite_accessory/tail indexed by type
var/global/list/wing_styles_list = list()	// Stores /datum/sprite_accessory/wing indexed by type

GLOBAL_LIST_INIT(custom_species_bases, new) // Species that can be used for a Custom Species icon base
	//Underwear
var/datum/category_collection/underwear/global_underwear = new()

	//Backpacks
var/global/list/backbaglist = list("Nothing", "Backpack", "Satchel", "Satchel Alt", "Messenger Bag", "Sports Bag", "Strapless Satchel") //VOREStation edit
var/global/list/pdachoicelist = list("Default", "Slim", "Old", "Rugged", "Holographic", "Wrist-Bound","Slider", "Vintage")
var/global/list/exclude_jobs = list(/datum/job/ai,/datum/job/cyborg)

// Visual nets
GLOBAL_LIST_EMPTY_TYPED(visual_nets, /datum/visualnet) // CHOMPEdit - Globals
var/datum/visualnet/camera/cameranet = new()
var/datum/visualnet/cult/cultnet = new()

// Runes
GLOBAL_LIST_INIT(rune_list, new()) // CHOMPEdit - Globals
GLOBAL_LIST_EMPTY(escape_list) // CHOMPEdit - Globals
GLOBAL_LIST_EMPTY(endgame_exits) // CHOMPEdit - Globals
GLOBAL_LIST_EMPTY(endgame_safespawns) // CHOMPEdit - Globals

GLOBAL_LIST_INIT(syndicate_access, list(access_maint_tunnels, access_syndicate, access_external_airlocks)) // CHOMPEdit - Globals

// Ores (for mining)
GLOBAL_LIST_EMPTY(ore_data)
GLOBAL_LIST_EMPTY(alloy_data)

// Strings which corraspond to bodypart covering flags, useful for outputting what something covers.
var/global/list/string_part_flags = list(
	"head" = HEAD,
	"face" = FACE,
	"eyes" = EYES,
	"upper body" = UPPER_TORSO,
	"lower body" = LOWER_TORSO,
	"legs" = LEGS,
	"feet" = FEET,
	"arms" = ARMS,
	"hands" = HANDS
)

// Strings which corraspond to slot flags, useful for outputting what slot something is.
var/global/list/string_slot_flags = list(
	"back" = SLOT_BACK,
	"face" = SLOT_MASK,
	"waist" = SLOT_BELT,
	"ID slot" = SLOT_ID,
	"ears" = SLOT_EARS,
	"eyes" = SLOT_EYES,
	"hands" = SLOT_GLOVES,
	"head" = SLOT_HEAD,
	"feet" = SLOT_FEET,
	"exo slot" = SLOT_OCLOTHING,
	"body" = SLOT_ICLOTHING,
	"uniform" = SLOT_TIE,
	"holster" = SLOT_HOLSTER
)

GLOBAL_LIST_EMPTY(mannequins)
/proc/get_mannequin(var/ckey = "NULL")
	var/mob/living/carbon/human/dummy/mannequin/M = GLOB.mannequins[ckey]
	if(!istype(M))
		GLOB.mannequins[ckey] = new /mob/living/carbon/human/dummy/mannequin(null)
		M = GLOB.mannequins[ckey]
	return M

/proc/del_mannequin(var/ckey = "NULL")
	GLOB.mannequins-= ckey

//////////////////////////
/////Initial Building/////
//////////////////////////

/proc/makeDatumRefLists()
	var/list/paths

	//Hair - Initialise all /datum/sprite_accessory/hair into an list indexed by hair-style name
	paths = subtypesof(/datum/sprite_accessory/hair)
	for(var/path in paths)
		var/datum/sprite_accessory/hair/H = new path()
		hair_styles_list[H.name] = H
		switch(H.gender)
			if(MALE)	hair_styles_male_list += H.name
			if(FEMALE)	hair_styles_female_list += H.name
			else
				hair_styles_male_list += H.name
				hair_styles_female_list += H.name

	//Facial Hair - Initialise all /datum/sprite_accessory/facial_hair into an list indexed by facialhair-style name
	paths = subtypesof(/datum/sprite_accessory/facial_hair)
	for(var/path in paths)
		var/datum/sprite_accessory/facial_hair/H = new path()
		facial_hair_styles_list[H.name] = H
		switch(H.gender)
			if(MALE)	facial_hair_styles_male_list += H.name
			if(FEMALE)	facial_hair_styles_female_list += H.name
			else
				facial_hair_styles_male_list += H.name
				facial_hair_styles_female_list += H.name

	//Body markings - Initialise all /datum/sprite_accessory/marking into an list indexed by marking name
	paths = subtypesof(/datum/sprite_accessory/marking)
	for(var/path in paths)
		var/datum/sprite_accessory/marking/M = new path()
		body_marking_styles_list[M.name] = M
		if(!M.genetic)
			body_marking_nopersist_list[M.name] = M

	//Surgery Steps - Initialize all /datum/surgery_step into a list
	paths = subtypesof(/datum/surgery_step)
	for(var/T in paths)
		var/datum/surgery_step/S = new T
		GLOB.surgery_steps += S // CHOMPEdit - Globals
	sort_surgeries()

	//List of job. I can't believe this was calculated multiple times per tick!
	paths = subtypesof(/datum/job)
	paths -= exclude_jobs
	for(var/T in paths)
		var/datum/job/J = new T
		GLOB.joblist[J.title] = J // CHOMPEdit - Globals

	//Languages
	paths = subtypesof(/datum/language)
	for(var/T in paths)
		var/datum/language/L = new T
		if (isnull(GLOB.all_languages[L.name]))
			GLOB.all_languages[L.name] = L
		else
			log_debug("Language name conflict! [T] is named [L.name], but that is taken by [GLOB.all_languages[L.name].type]")
			if(isnull(GLOB.language_name_conflicts[L.name]))
				GLOB.language_name_conflicts[L.name] = list(GLOB.all_languages[L.name])
			GLOB.language_name_conflicts[L.name] += L

	for (var/language_name in GLOB.all_languages)
		var/datum/language/L = GLOB.all_languages[language_name]
		if(!(L.flags & NONGLOBAL))
			if(isnull(GLOB.language_keys[L.key]))
				GLOB.language_keys[L.key] = L
			else
				log_debug("Language key conflict! [L] has key [L.key], but that is taken by [(GLOB.language_keys[L.key])]")
				if(isnull(GLOB.language_key_conflicts[L.key]))
					GLOB.language_key_conflicts[L.key] = list(GLOB.language_keys[L.key])
				GLOB.language_key_conflicts[L.key] += L

	//Species
	var/rkey = 0
	paths = subtypesof(/datum/species)
	for(var/T in paths)

		rkey++

		var/datum/species/S = T
		if(!initial(S.name))
			continue

		S = new T
		S.race_key = rkey //Used in mob icon caching.
		GLOB.all_species[S.name] = S

	//Shakey shakey shake
	sortTim(GLOB.all_species, GLOBAL_PROC_REF(cmp_species), associative = TRUE)

	//Split up the rest
	for(var/speciesname in GLOB.all_species)
		var/datum/species/S = GLOB.all_species[speciesname]
		if(!(S.spawn_flags & SPECIES_IS_RESTRICTED))
			GLOB.playable_species += S.name
		if(S.spawn_flags & SPECIES_IS_WHITELISTED)
			GLOB.whitelisted_species += S.name

	// Suit cyclers
	paths = subtypesof(/datum/suit_cycler_choice/department)
	for(var/datum/suit_cycler_choice/SCC as anything in paths)
		if(!initial(SCC.name))
			continue
		GLOB.suit_cycler_departments += new SCC()
	paths = subtypesof(/datum/suit_cycler_choice/species)
	for(var/datum/suit_cycler_choice/SCC as anything in paths)
		if(!initial(SCC.name))
			continue
		GLOB.suit_cycler_species += new SCC()
	paths = subtypesof(/datum/suit_cycler_choice/department/emag)
	for(var/datum/suit_cycler_choice/SCC as anything in paths)
		if(!initial(SCC.name))
			continue
		GLOB.suit_cycler_emagged += new SCC()

	//Ores
	paths = subtypesof(/ore)
	for(var/oretype in paths)
		var/ore/OD = new oretype()
		GLOB.ore_data[OD.name] = OD

	paths = subtypesof(/datum/alloy)
	for(var/alloytype in paths)
		GLOB.alloy_data += new alloytype()

	//Closet appearances
	GLOB.closet_appearances = decls_repository.get_decls_of_type(/decl/closet_appearance)

	paths = subtypesof(/datum/sprite_accessory/ears)
	for(var/path in paths)
		var/obj/item/clothing/head/instance = new path()
		ear_styles_list[path] = instance

	// Custom Tails
	paths = subtypesof(/datum/sprite_accessory/tail) - /datum/sprite_accessory/tail/taur
	for(var/path in paths)
		var/datum/sprite_accessory/tail/instance = new path()
		tail_styles_list[path] = instance

	// Custom Wings
	paths = subtypesof(/datum/sprite_accessory/wing)
	for(var/path in paths)
		var/datum/sprite_accessory/wing/instance = new path()
		wing_styles_list[path] = instance

	// VOREStation Add - Vore Modes!
	paths = typesof(/datum/digest_mode)
	for(var/T in paths)
		var/datum/digest_mode/DM = new T
		GLOB.digest_modes[DM.id] = DM
	// VOREStation Add End
	init_crafting_recipes(GLOB.crafting_recipes)

/*
	// Custom species traits
	paths = subtypesof(/datum/trait)
	for(var/path in paths)
		var/datum/trait/instance = new path()
		if(!instance.name)
			continue //A prototype or something
		var/cost = instance.cost
		traits_costs[path] = cost
		all_traits[path] = instance
		switch(cost)
			if(-INFINITY to -0.1)
				negative_traits[path] = instance
			if(0)
				neutral_traits[path] = instance
			if(0.1 to INFINITY)
				positive_traits[path] = instance
*/

	// Custom species icon bases
	var/list/blacklisted_icons = list(SPECIES_CUSTOM,SPECIES_PROMETHEAN) //VOREStation Edit
	var/list/whitelisted_icons = list(SPECIES_FENNEC,SPECIES_XENOHYBRID, SPECIES_SHADEKIN) //CHOMPedit
	for(var/species_name in GLOB.playable_species)
		if(species_name in blacklisted_icons)
			continue
		var/datum/species/S = GLOB.all_species[species_name]
		if(S.spawn_flags & SPECIES_IS_WHITELISTED)
			continue
		GLOB.custom_species_bases += species_name
	for(var/species_name in whitelisted_icons)
		GLOB.custom_species_bases += species_name

	return 1 // Hooks must return 1


/// Inits the crafting recipe list, sorting crafting recipe requirements in the process.
/proc/init_crafting_recipes(list/crafting_recipes)
	for(var/path in subtypesof(/datum/crafting_recipe))
		var/datum/crafting_recipe/recipe = new path()
		recipe.reqs = sortList(recipe.reqs, GLOBAL_PROC_REF(cmp_crafting_req_priority))
		crafting_recipes += recipe
	return crafting_recipes
/* // Uncomment to debug chemical reaction list.
/client/verb/debug_chemical_list()

	for (var/reaction in chemical_reactions_list)
		. += "chemical_reactions_list\[\"[reaction]\"\] = \"[chemical_reactions_list[reaction]]\"\n"
		if(islist(chemical_reactions_list[reaction]))
			var/list/L = chemical_reactions_list[reaction]
			for(var/t in L)
				. += "    has: [t]\n"
	to_world(.)
*/
//Hexidecimal numbers
var/global/list/hexNums = list("0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "A", "B", "C", "D", "E", "F")

/*
// Many global vars aren't GLOB type. This puts them there to be more easily inspected.
GLOBAL_LIST_EMPTY(legacy_globals)

/proc/populate_legacy_globals()
	//Note: these lists cannot be changed to a new list anywhere in code!
	//If they are, these will cause the old list to stay around!
	//Check by searching for "<GLOBAL_NAME> =" in the entire codebase
	GLOB.legacy_globals["player_list"] = player_list
	GLOB.legacy_globals["mob_list"] = mob_list
	GLOB.legacy_globals["human_mob_list"] = human_mob_list
	GLOB.legacy_globals["silicon_mob_list"] = silicon_mob_list
	GLOB.legacy_globals["ai_list"] = ai_list
	GLOB.legacy_globals["living_mob_list"] = living_mob_list
	GLOB.legacy_globals["dead_mob_list"] = dead_mob_list
	GLOB.legacy_globals["observer_mob_list"] = observer_mob_list
	GLOB.legacy_globals["listening_objects"] = listening_objects
	GLOB.legacy_globals["cleanbot_reserved_turfs"] = cleanbot_reserved_turfs
	GLOB.legacy_globals["cable_list"] = cable_list
	GLOB.legacy_globals["landmarks_list"] = landmarks_list
	GLOB.legacy_globals["event_triggers"] = event_triggers
	GLOB.legacy_globals["side_effects"] = side_effects
	GLOB.legacy_globals["mechas_list"] = mechas_list
	GLOB.legacy_globals["mannequins_"] = mannequins_
	//visual nets
	GLOB.legacy_globals["visual_nets"] = visual_nets
	GLOB.legacy_globals["cameranet"] = cameranet
	GLOB.legacy_globals["cultnet"] = cultnet
	GLOB.legacy_globals["item_tf_spawnpoints"] = item_tf_spawnpoints
	GLOB.legacy_globals["existing_solargrubs"] = existing_solargrubs
	*/
