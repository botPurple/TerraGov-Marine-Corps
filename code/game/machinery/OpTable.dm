/obj/machinery/optable
	name = "Operating Table"
	desc = "Used for advanced medical procedures."
	icon = 'icons/obj/surgery.dmi'
	icon_state = "table2-idle"
	density = 1
	anchored = 1.0
	use_power = 1
	idle_power_usage = 1
	active_power_usage = 5
	var/mob/living/carbon/human/victim = null
	var/strapped = 0.0

	var/obj/machinery/computer/operating/computer = null

/obj/machinery/optable/New()
	..()
	for(dir in list(NORTH,EAST,SOUTH,WEST))
		computer = locate(/obj/machinery/computer/operating, get_step(src, dir))
		if (computer)
			computer.table = src
			break
//	spawn(100) //Wont the MC just call this process() before and at the 10 second mark anyway?
//		process()

/obj/machinery/optable/ex_act(severity)

	switch(severity)
		if(1.0)
			//SN src = null
			cdel(src)
			return
		if(2.0)
			if (prob(50))
				//SN src = null
				cdel(src)
				return
		if(3.0)
			if (prob(25))
				src.density = 0
		else
	return

/obj/machinery/optable/attack_paw(mob/user as mob)
	if ((HULK in usr.mutations))
		usr << text("\blue You destroy the operating table.")
		visible_message("\red [usr] destroys the operating table!")
		src.density = 0
		cdel(src)
	if (!( locate(/obj/machinery/optable, user.loc) ))
		step(user, get_dir(user, src))
		if (user.loc == src.loc)
			user.layer = TURF_LAYER
			visible_message("The monkey hides under the table!")
	return

/obj/machinery/optable/attack_hand(mob/user as mob)
	if (HULK in usr.mutations)
		usr << text("\blue You destroy the table.")
		visible_message("\red [usr] destroys the operating table!")
		src.density = 0
		cdel(src)
	return

/obj/machinery/optable/CanPass(atom/movable/mover, turf/target)
	if(istype(mover) && mover.checkpass(PASSTABLE))
		return 1
	else
		return 0


/obj/machinery/optable/MouseDrop_T(obj/item/I, mob/user)

	if (!istype(I) || user.get_active_hand() != I)
		return
	if(user.drop_held_item())
		if (I.loc != loc)
			step(I, get_dir(I, src))

/obj/machinery/optable/proc/check_victim()
	if(locate(/mob/living/carbon/human, loc))
		var/mob/living/carbon/human/M = locate(/mob/living/carbon/human, loc)
		if(M.lying)
			victim = M
			icon_state = M.pulse ? "table2-active" : "table2-idle"
			return 1
	victim = null
	stop_processing()
	icon_state = "table2-idle"
	return 0

/obj/machinery/optable/process()
	check_victim()

/obj/machinery/optable/proc/take_victim(mob/living/carbon/C, mob/living/carbon/user)
	if (C == user)
		user.visible_message("[user] climbs on the operating table.","You climb on the operating table.")
	else
		visible_message("\red [C] has been laid on the operating table by [user].")
	C.resting = 1
	C.forceMove(loc)
	for(var/obj/O in src)
		O.loc = loc
	add_fingerprint(user)
	if(ishuman(C))
		var/mob/living/carbon/human/H = C
		victim = H
		start_processing()
		icon_state = H.pulse ? "table2-active" : "table2-idle"
	else
		icon_state = "table2-idle"

/obj/machinery/optable/verb/climb_on()
	set name = "Climb On Table"
	set category = "Object"
	set src in oview(1)

	if(usr.stat || !ishuman(usr) || usr.is_mob_restrained() || !check_table(usr))
		return

	take_victim(usr,usr)

/obj/machinery/optable/attackby(obj/item/W, mob/living/user)
	if (istype(W, /obj/item/grab))
		var/obj/item/grab/G = W
		if(victim)
			user << "<span class='warning'>The table is already occupied!</span>"
			return
		var/mob/living/carbon/M
		if(iscarbon(G.grabbed_thing))
			M = G.grabbed_thing
			if(M.buckled)
				user << "<span class='warning'>Unbuckle first!</span>"
				return
		else if(istype(G.grabbed_thing,/obj/structure/closet/bodybag/cryobag))
			var/obj/structure/closet/bodybag/cryobag/C = G.grabbed_thing
			if(!C.stasis_mob)
				return
			M = C.stasis_mob
			C.open()
			user.stop_pulling()
			user.start_pulling(M)
		else
			return

		take_victim(M,user)

/obj/machinery/optable/proc/check_table(mob/living/carbon/patient as mob)
	if(victim)
		usr << "\blue <B>The table is already occupied!</B>"
		return 0

	if(patient.buckled)
		usr << "\blue <B>Unbuckle first!</B>"
		return 0

	return 1
