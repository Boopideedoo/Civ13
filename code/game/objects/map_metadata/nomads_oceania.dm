
/obj/map_metadata/nomads_oceania
	ID = MAP_NOMADS_OCEANIA
	title = "Nomads (Oceania)"
	lobby_icon = 'icons/lobby/oceania.png'
	no_winner = "The round is proceeding normally."
	caribbean_blocking_area_types = list(/area/caribbean/no_mans_land/invisible_wall/)
	respawn_delay = 6000 // 10 minutes!
	has_hunger = TRUE
	faction_organization = list(
		CIVILIAN,)

	roundend_condition_sides = list(
		list(CIVILIAN) = /area/caribbean/british
		)
	age = "5000 B.C."
	civilizations = TRUE
	var/tribes_nr = 1
	faction_distribution_coeffs = list(CIVILIAN = 1)
	battle_name = "Civilizations"
	mission_start_message = "<big>After ages as hunter-gatherers, people are starting to form groups and settle down. Will they be able to work together?</big><br><b>Wiki Guide: https://new-civ13.github.io/civ13-wiki/Civilizations_and_Nomads</b>"
	ambience = list('sound/ambience/jungle1.ogg')
	faction1 = CIVILIAN
	availablefactions = list("Nomad")
	songs = list(
		"Hot Hot Hot:1" = 'sound/music/Hot Hot Hot.ogg',)
	research_active = TRUE
	nomads = TRUE
	gamemode = "Classic (Stone Age Start)"
	var/list/arealist_r = list()
	var/list/arealist_g = list()

/obj/map_metadata/nomads_oceania/New()
	..()
	spawn(18000)
		seasons()

/obj/map_metadata/nomads_oceania/job_enabled_specialcheck(var/datum/job/J)
	if (J.is_nomad == TRUE)
		. = TRUE
	else
		. = FALSE

