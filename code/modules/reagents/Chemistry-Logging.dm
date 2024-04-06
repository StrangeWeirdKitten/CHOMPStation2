GLOBAL_LIST_EMPTY(chemical_reaction_logs) // CHOMPEdit - Globals

/proc/log_chemical_reaction(atom/A, decl/chemical_reaction/R, multiplier)
	if(!A || !R)
		return

	var/turf/T = get_turf(A)
	var/logstr = "[usr ? key_name(usr) : "EVENT"] mixed [R.name] ([R.result]) (x[multiplier]) in \the [A] at [T ? "[T.x],[T.y],[T.z]" : "*null*"]"

	GLOB.chemical_reaction_logs += "\[[time_stamp()]\] [logstr]" // CHOMPEdit - Globals

	if(R.log_is_important)
		message_admins(logstr)
	log_admin(logstr)

/client/proc/view_chemical_reaction_logs()
	set name = "Show Chemical Reactions"
	set category = "Admin"

	if(!check_rights(R_ADMIN|R_MOD))
		return

	var/html = ""
	for(var/entry in GLOB.chemical_reaction_logs) // CHOMPEdit - Globals
		html += "[entry]<br>"

	usr << browse(html, "window=chemlogs")
