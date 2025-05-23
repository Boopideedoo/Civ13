/*-------------------------------------------------------------------------------------+\
| Blacksmith's Forge																	|
| Used to heat up objects to make them more malleable for forging or melt for casting	|
| Requires aeration via bellows for additional heat.									|
| Fueled with coal or charcoal	- Fulminating Gold										|
\+-------------------------------------------------------------------------------------*/

/obj/structure/forge
	density = TRUE
	anchored = TRUE
	name = "\improper stone forge"
	icon = 'icons/obj/blacksmithing.dmi'
	icon_state = "forge"
	desc = "A forge for heating up metallic objects."
	var/fuel = 0
	var/fuellimit = 600		// Maximum fuel level.
	var/active = FALSE
	var/nextaeration = 0
	var/aerationheat = 100	// How much objects on the forge are heated by a gust of wind from bellows.
	var/maxtemp = 1200

// Item Interactions
/obj/structure/forge/attackby(obj/item/I, mob/user, params)
	// Toggle Anchoring
	if(istype(I, /obj/item/weapon/wrench))
		to_chat(user, SPAN_NOTICE("You begin to [anchored ? "unsecure" : "secure"] \the [src]..."))
		if (do_after(user, 20, src))
			playsound(loc, 'sound/items/Ratchet.ogg', 50, TRUE)
			anchored = !anchored
			user.visible_message(SPAN_NOTICE("[user] has [anchored ? "secured" : "unsecured"] \the [src]"), \
				SPAN_NOTICE("You begin to [anchored ? "secure" : "unsecure"] \the [src]."))
		return
	// Igniting the Forge
	if(I.ignition_source && !active)
		if(fuel <= 0)
			to_chat(user, "<span class='notice'>I can't ignite \the [src] without fueling it first.</span>")
		else
			to_chat(user, "<span class='notice'>\The [src] ignites.</span>")
			active = TRUE
			processing_objects |= src
	// Hand Bellows
	else if(istype(I, /obj/item/handbellows))
		var/obj/item/handbellows/HB = I
		if(!active)
			to_chat(user, "<span class='notice'>What am I doing, \the [src] isn't ignited.</span>")
		else if(world.time - nextaeration >= 0 && HB.ready())
			if(world.time - nextaeration >= 10)
				to_chat(user, "<span class='notice'>Air wooshes into \the [src], and the flames atop blaze brighter.</span>")
			nextaeration = HB.nextuse
			fuel -= min(3, fuel)
			heatobjects(aerationheat)
			if(do_after(user, HB.usedelay, target = src))
				attackby(I, user)
		else
			to_chat(user, "<span class='notice'>Whew... I need a break...</span>")
	// Adding Coal or Charcoal
	else if(istype(I, /obj/item/stack/ore/coal) || istype(I, /obj/item/stack/ore/charcoal))
		if(fuel >= fuellimit)
			to_chat(user, "<span class='notice'>\The [src] is full.</span>")
		var/obj/item/stack/ore/O = I
		var/fv = round(O.fuel_value / 1.5)
		O.use(1)
		fuel += min(fv, fuellimit - fuel)
		to_chat(user, "<span class='italics'>You add \the [I] to \the [src].</span>")
	// Placing Items
	else if(user.a_intent != I_HARM)
		if(istype(I, /obj/item/heatable/forged/tongs))
			var/obj/item/heatable/forged/tongs/T = I
			if(T.holding)
				I = T.holding
				T.holding = null
				T.updatesprites()
		user.drop_from_inventory(I)
		I.forceMove(get_turf(src))
		I.pixel_x = 0
		I.pixel_y = 5
	// Super
	else
		..()
	// Sprites
	updatesprites()

// Player Interactions
/obj/structure/forge/attack_hand(mob/user)
	if(active)
		to_chat(user, "<span class='italics'>You smother the fire of the forge.</span>")
		active = FALSE
		updatesprites()
	..()

//Examine
/obj/structure/forge/examine(mob/user)
	..()
	to_chat(user, "<span class='notice'>The forge contains [fuel] units of fuel.</span>")

// On Destruction
/obj/structure/forge/Destroy()
	return ..()

// Sprite Updates
/obj/structure/forge/proc/updatesprites()
	icon_state = initial(icon_state)
	if(active)
		icon_state += "-on"

// Processing
/obj/structure/forge/process()
	//Checks
	if(fuel <= 0 || !active)
		active = FALSE
		updatesprites()
		processing_objects -= src
		return
	fuel--
	heatobjects(20)
	updatesprites()

// Heat Local Objects
/obj/structure/forge/proc/heatobjects(var/heat)
	for(var/I in loc.contents)
		if(istype(I, /obj/item/heatable))
			var/obj/item/heatable/H = I
			processing_objects |= I
			if(H.temperature < maxtemp)
				H.temperature += min(heat, maxtemp - H.temperature)
				break
