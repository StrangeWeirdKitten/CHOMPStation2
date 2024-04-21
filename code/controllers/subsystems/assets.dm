SUBSYSTEM_DEF(assets)
	name = "Assets"
	init_order = INIT_ORDER_ASSETS
	flags = SS_NO_FIRE
	var/list/datum/asset_cache_item/cache = list()
	var/list/preload = list()
	var/datum/asset_transport/transport = new()

<<<<<<< HEAD
/datum/controller/subsystem/assets/OnConfigLoad() // CHOMPEdit
	var/newtransporttype = /datum/asset_transport
	switch (CONFIG_GET(string/asset_transport)) // CHOMPEdit
=======
/datum/controller/subsystem/assets/proc/OnConfigLoad()
	var/newtransporttype = /datum/asset_transport
	switch (config.asset_transport)
>>>>>>> c7b6c3e42b... Revert "Revert "Garbage collection, asset delivery, icon2html revolution, and…" (#15816)
		if ("webroot")
			newtransporttype = /datum/asset_transport/webroot

	if (newtransporttype == transport.type)
		return

	var/datum/asset_transport/newtransport = new newtransporttype ()
	if (newtransport.validate_config())
		transport = newtransport
	transport.Load()



/datum/controller/subsystem/assets/Initialize()
	OnConfigLoad()

	for(var/type in typesof(/datum/asset))
		var/datum/asset/A = type
		if (type != initial(A._abstract))
			load_asset_datum(type)

	transport.Initialize(cache)

	subsystem_initialized = TRUE
	return SS_INIT_SUCCESS

/datum/controller/subsystem/assets/Recover()
	cache = SSassets.cache
	preload = SSassets.preload
