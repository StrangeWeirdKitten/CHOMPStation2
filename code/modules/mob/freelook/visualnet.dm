// VISUAL NET
//
// The datum containing all the chunks.

#define CHUNK_SIZE 16

/datum/visualnet
	// The chunks of the map, mapping the areas that an object can see.
	var/list/chunks = list()
	var/ready = 0
	var/chunk_type = /datum/chunk

/datum/visualnet/New()
	..()
	GLOB.visual_nets += src // CHOMPEdit - Globals

/datum/visualnet/Destroy()
	GLOB.visual_nets -= src // CHOMPEdit - Globals
	return ..()

// Checks if a chunk has been Generated in x, y, z.
/datum/visualnet/proc/chunkGenerated(x, y, z)
	x &= ~0xf
	y &= ~0xf
	var/key = "[x],[y],[z]"
	return (chunks[key])

// Returns the chunk in the x, y, z.
// If there is no chunk, it creates a new chunk and returns that.
/datum/visualnet/proc/getChunk(x, y, z)
	x &= ~0xf
	y &= ~0xf
	var/key = "[x],[y],[z]"
	if(!chunks[key])
		chunks[key] = new chunk_type(null, x, y, z)

	return chunks[key]

// Updates what the aiEye can see. It is recommended you use this when the aiEye moves or it's location is set.

/datum/visualnet/proc/visibility(list/moved_eyes, client/C, list/other_eyes)
	if(!islist(moved_eyes))
		moved_eyes = moved_eyes ? list(moved_eyes) : list()
	if(islist(other_eyes))
		other_eyes = (other_eyes - moved_eyes)
	else
		other_eyes = list()

	var/list/chunks_pre_seen = list()
	var/list/chunks_post_seen = list()

	for(var/mob/observer/eye/eye as anything in moved_eyes)
		if(C)
			chunks_pre_seen |= eye.visibleChunks
		// 0xf = 15
		var/static_range = eye.static_visibility_range
		var/x1 = max(0, eye.x - static_range) & ~(CHUNK_SIZE - 1)
		var/y1 = max(0, eye.y - static_range) & ~(CHUNK_SIZE - 1)
		var/x2 = min(world.maxx, eye.x + static_range) & ~(CHUNK_SIZE - 1)
		var/y2 = min(world.maxy, eye.y + static_range) & ~(CHUNK_SIZE - 1)

		var/list/visibleChunks = list()

		for(var/x = x1; x <= x2; x += CHUNK_SIZE)
			for(var/y = y1; y <= y2; y += CHUNK_SIZE)
				visibleChunks |= getChunk(x, y, eye.z)

		var/list/remove = eye.visibleChunks - visibleChunks
		var/list/add = visibleChunks - eye.visibleChunks

		for(var/datum/chunk/c as anything in remove)
			c.remove(eye, FALSE)

		for(var/datum/chunk/c as anything in add)
			c.add(eye, FALSE)

		if(C)
			chunks_post_seen |= eye.visibleChunks

	if(C)
		for(var/mob/observer/eye/eye as anything in other_eyes)
			chunks_post_seen |= eye.visibleChunks

		var/list/remove = chunks_pre_seen - chunks_post_seen
		var/list/add = chunks_post_seen - chunks_pre_seen

		for(var/datum/chunk/c as anything in remove)
			C.images -= c.obscured

		for(var/datum/chunk/c as anything in add)
			C.images += c.obscured

// Updates the chunks that the turf is located in. Use this when obstacles are destroyed or	when doors open.

/datum/visualnet/proc/updateVisibility(atom/A, var/opacity_check = 1)

	if(!ticker || (opacity_check && !A.opacity))
		return
	majorChunkChange(A, 2)

/datum/visualnet/proc/updateChunk(x, y, z)
	// 0xf = 15
	if(!chunkGenerated(x, y, z))
		return
	var/datum/chunk/chunk = getChunk(x, y, z)
	chunk.hasChanged()

// Never access this proc directly!!!!
// This will update the chunk and all the surrounding chunks.
// It will also add the atom to the cameras list if you set the choice to 1.
// Setting the choice to 0 will remove the camera from the chunks.
// If you want to update the chunks around an object, without adding/removing a camera, use choice 2.

/datum/visualnet/proc/majorChunkChange(atom/c, var/choice)
	// 0xf = 15
	if(!c)
		return

	var/turf/T = get_turf(c)
	if(T)
		var/x1 = max(0, T.x - 8) & ~0xf
		var/y1 = max(0, T.y - 8) & ~0xf
		var/x2 = min(world.maxx, T.x + 8) & ~0xf
		var/y2 = min(world.maxy, T.y + 8) & ~0xf

		//to_world("X1: [x1] - Y1: [y1] - X2: [x2] - Y2: [y2]")

		for(var/x = x1; x <= x2; x += 16)
			for(var/y = y1; y <= y2; y += 16)
				if(chunkGenerated(x, y, T.z))
					var/datum/chunk/chunk = getChunk(x, y, T.z)
					onMajorChunkChange(c, choice, chunk)
					chunk.hasChanged()

/datum/visualnet/proc/onMajorChunkChange(atom/c, var/choice, var/datum/chunk/chunk)

// Will check if a mob is on a viewable turf. Returns 1 if it is, otherwise returns 0.

/datum/visualnet/proc/checkVis(mob/living/target as mob)
	// 0xf = 15
	var/turf/position = get_turf(target)
	return checkTurfVis(position)

/datum/visualnet/proc/checkTurfVis(var/turf/position)
	var/datum/chunk/chunk = getChunk(position.x, position.y, position.z)
	if(chunk)
		if(chunk.changed)
			chunk.hasChanged(1) // Update now, no matter if it's visible or not.
		if(chunk.visibleTurfs[position])
			return 1
	return 0

// Debug verb for VVing the chunk that the turf is in.
/*
/turf/verb/view_chunk()
	set src in world

	if(cameranet.chunkGenerated(x, y, z))
		var/datum/chunk/chunk = cameranet.getCameraChunk(x, y, z)
		usr.client.debug_variables(chunk)
*/
