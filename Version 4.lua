--[[Thanks to:
    -Ren (for helping me out a ton)
    -Jayphen (for helping me a ton with memory)
    -Nowiry (hella help, very cool gamer)
    -Aaron (helped with the whitelisting feature)
    -Lance (steal his player functions setup xD)
    -zPrism, for letting me test stuff with him
    -ValidLocket, for being a homie
    -Chloe, for being really sweet <3

]]

--require("natives-1640181023")
util.require_natives(1640181023)

util.keep_running()

local scriptName = "KeramisScript V.2.1"

local menuroot = menu.my_root()
local menuAction = menu.action
local menuToggle = menu.toggle
local menuToggleLoop = menu.toggle_loop
local joaat = util.joaat
local wait = util.yield

local createPed = PED.CREATE_PED
local getEntityCoords = ENTITY.GET_ENTITY_COORDS
local getPlayerPed = PLAYER.GET_PLAYER_PED
local requestModel = STREAMING.REQUEST_MODEL
local hasModelLoaded = STREAMING.HAS_MODEL_LOADED
local noNeedModel = STREAMING.SET_MODEL_AS_NO_LONGER_NEEDED
local setPedCombatAttr = PED.SET_PED_COMBAT_ATTRIBUTES
local giveWeaponToPed = WEAPON.GIVE_WEAPON_TO_PED



function SE_add_explosion(x, y, z, exptype, dmgscale, isheard, isinvis, camshake, nodmg)
    FIRE.ADD_EXPLOSION(x, y, z, exptype, dmgscale, isheard, isinvis, camshake, nodmg)
end

function SE_add_owned_explosion(ped, x, y, z, exptype, dmgscale, isheard, isinvis, camshake)
    FIRE.ADD_OWNED_EXPLOSION(ped, x, y, z, exptype, dmgscale, isheard, isinvis, camshake)
end

local function getLocalPlayerCoords()
    return ENTITY.GET_ENTITY_COORDS(PLAYER.GET_PLAYER_PED(players.user()), true)
end
local function getLocalPed()
    return PLAYER.PLAYER_PED_ID()
end

local function distanceBetweenTwoEntities(entity1, entity2)
    local v3_1 = ENTITY.GET_ENTITY_COORDS(entity1, false)
    local v3_2 = ENTITY.GET_ENTITY_COORDS(entity2, false)

    local distance = math.sqrt(((v3_2.x - v3_1.x)^2) + ((v3_2.y - v3_1.y)^2) + ((v3_2.z - v3_1.z)^2))
    return distance
end

local function distanceBetweenTwoCoords(v3_1, v3_2)
    local distance = math.sqrt(((v3_2.x - v3_1.x)^2) + ((v3_2.y - v3_1.y)^2) + ((v3_2.z - v3_1.z)^2))
    return distance
end

local function getPlayerName_ped(ped)
    local playerID = NETWORK.NETWORK_GET_PLAYER_INDEX_FROM_PED(ped)
    local playerName = NETWORK.NETWORK_PLAYER_GET_NAME(playerID)
    return playerName
end

local function getPlayerName_pid(pid)
    local playerName = NETWORK.NETWORK_PLAYER_GET_NAME(pid)
    return playerName
end

local function onStartup()
    SE_impactCoord = memory.alloc()
    SE_impactinvismines = memory.alloc()
    SE_pImpactCoord = memory.alloc() -- memory allocation for explosion gun.
    SE_LocalPed = getLocalPed()
    SE_Notifications = false -- notifications globally
    --------
    SE_ArrayList = false --arraylist Global
    SE_ArrayCount = 0 --arraylist count Global
    SE_ArrayOffsetX = 0.0
    SE_ArrayOffsetY = 0.0
    SE_ArrayScale = 0.3 --arraylist text scale
    SE_ArrayColor = {r = 1.0, g = 1.0, b = 1.0, a = 1.0} --arraylist text color
    --------
    BA_visible = false -- block area visibility of props
    util.toast("Ran startup of " .. scriptName)
end

onStartup()

local function fastNet(entity, playerID)
    local netID = NETWORK.NETWORK_GET_NETWORK_ID_FROM_ENTITY(entity)
    NETWORK.NETWORK_REQUEST_CONTROL_OF_ENTITY(entity)
    if not NETWORK.NETWORK_HAS_CONTROL_OF_ENTITY(entity) then
        for i = 1, 30 do
            if not NETWORK.NETWORK_HAS_CONTROL_OF_ENTITY(entity) then
                NETWORK.NETWORK_REQUEST_CONTROL_OF_ENTITY(entity)
                wait(10)
            else
                goto continue
            end    
        end
    end
    ::continue::
    if SE_Notifications then
        util.toast("Has control.")
    end
    NETWORK.NETWORK_REQUEST_CONTROL_OF_NETWORK_ID(netID)
    wait(10)
    NETWORK.SET_NETWORK_ID_EXISTS_ON_ALL_MACHINES(netID)
    wait(10)
    NETWORK.SET_NETWORK_ID_CAN_MIGRATE(netID, false)
    wait(10)
    NETWORK.SET_NETWORK_ID_ALWAYS_EXISTS_FOR_PLAYER(netID, playerID, true)
    wait(10)
    ENTITY.SET_ENTITY_AS_MISSION_ENTITY(entity, true, false)
    wait(10)
    ENTITY._SET_ENTITY_CLEANUP_BY_ENGINE(entity, false)
    wait(10)
    if ENTITY.IS_ENTITY_AN_OBJECT(entity) then
        NETWORK.OBJ_TO_NET(entity)
    end
    wait(10)
    if BA_visible then
        ENTITY.SET_ENTITY_VISIBLE(entity, true, 0)
    else
        ENTITY.SET_ENTITY_VISIBLE(entity, false, 0)
        wait()
        ENTITY.SET_ENTITY_VISIBLE(entity, false, 0)
        wait()
        ENTITY.SET_ENTITY_VISIBLE(entity, false, 0)
    end
end

local function netIt(entity, playerID)
    local netID = NETWORK.NETWORK_GET_NETWORK_ID_FROM_ENTITY(entity)
    NETWORK.NETWORK_REQUEST_CONTROL_OF_ENTITY(entity)
    if not NETWORK.NETWORK_HAS_CONTROL_OF_ENTITY(entity) then
        for i = 1, 100 do
        NETWORK.NETWORK_REQUEST_CONTROL_OF_ENTITY(entity)
        wait(50)
        end
    else
        if SE_Notifications then
            util.toast("Has control.")
        end
    end
    wait(10)
    NETWORK.NETWORK_REQUEST_CONTROL_OF_NETWORK_ID(netID)
    wait(10)
    NETWORK.SET_NETWORK_ID_EXISTS_ON_ALL_MACHINES(netID)
    wait(10)
    NETWORK.SET_NETWORK_ID_CAN_MIGRATE(netID, false)
    wait(10)
    NETWORK.SET_NETWORK_ID_ALWAYS_EXISTS_FOR_PLAYER(netID, playerID, true)
    wait(10)
    ENTITY.SET_ENTITY_AS_MISSION_ENTITY(entity, true, false)
    wait(10)
    ENTITY._SET_ENTITY_CLEANUP_BY_ENGINE(entity, false)
    wait(10)
    if ENTITY.IS_ENTITY_AN_OBJECT(entity) then
        NETWORK.OBJ_TO_NET(entity)
    end
    wait(10)
    if BA_visible then
        ENTITY.SET_ENTITY_VISIBLE(entity, true, 0)
    else
        ENTITY.SET_ENTITY_VISIBLE(entity, false, 0)
        wait()
        ENTITY.SET_ENTITY_VISIBLE(entity, false, 0)
        wait()
        ENTITY.SET_ENTITY_VISIBLE(entity, false, 0)
    end
end

local function netItAll(entity)
    local netID = NETWORK.NETWORK_GET_NETWORK_ID_FROM_ENTITY(entity)
    if not NETWORK.NETWORK_HAS_CONTROL_OF_ENTITY(entity) then
        for i = 1, 100 do
        NETWORK.NETWORK_REQUEST_CONTROL_OF_ENTITY(entity)
        wait(50)
        end
    else
        if SE_Notifications then
            util.toast("Has control.")
        end
    end
    wait(10)
    NETWORK.NETWORK_REQUEST_CONTROL_OF_NETWORK_ID(netID)
    wait(10)
    NETWORK.SET_NETWORK_ID_EXISTS_ON_ALL_MACHINES(netID)
    wait(10)
    NETWORK.SET_NETWORK_ID_CAN_MIGRATE(netID, false)
    wait(10)
    for i = 0, 31, 1 do
        if NETWORK.NETWORK_IS_PLAYER_CONNECTED(i) then
            NETWORK.SET_NETWORK_ID_ALWAYS_EXISTS_FOR_PLAYER(netID, i, true)
            wait(10)
        end
    end
    ENTITY.SET_ENTITY_AS_MISSION_ENTITY(entity, true, false)
    wait(10)
    ENTITY._SET_ENTITY_CLEANUP_BY_ENGINE(entity, false)
    wait(10)
    if ENTITY.IS_ENTITY_AN_OBJECT(entity) then
        NETWORK.OBJ_TO_NET(entity)
    end
    wait(10)
    if BA_visible then
        ENTITY.SET_ENTITY_VISIBLE(entity, true, 0)
    else
        ENTITY.SET_ENTITY_VISIBLE(entity, false, 0)
        wait()
        ENTITY.SET_ENTITY_VISIBLE(entity, false, 0)
        wait()
        ENTITY.SET_ENTITY_VISIBLE(entity, false, 0)
    end
end

local function get_waypoint_pos2()
    if HUD.IS_WAYPOINT_ACTIVE() then
        local blip = HUD.GET_FIRST_BLIP_INFO_ID(8)
        local waypoint_pos = HUD.GET_BLIP_COORDS(blip)
        return waypoint_pos
    else
        util.toast("NO_WAYPOINT_SET")
    end
end

local function getClosestPlayerWithRange(range)
    local pedPointers = entities.get_all_peds_as_pointers()
    local rangesq = range * range
    local ourCoords = getEntityCoords(getLocalPed())
    local tbl = {}
    local closest_player = 0
    for i = 1, #pedPointers do
        local tarcoords = entities.get_position(pedPointers[i])
        local vdist = SYSTEM.VDIST2(ourCoords.x, ourCoords.y, ourCoords.z, tarcoords.x, tarcoords.y, tarcoords.z)
        if vdist <= rangesq then
            tbl[#tbl+1] = entities.pointer_to_handle(pedPointers[i])
        end
    end
    if tbl ~= nil then
        local dist = 999999
        for i = 1, #tbl do
            if tbl[i] ~= getLocalPed() then
                if PED.IS_PED_A_PLAYER(tbl[i]) then
                    local tarcoords = getEntityCoords(tbl[i])
                    local e = SYSTEM.VDIST2(ourCoords.x, ourCoords.y, ourCoords.z, tarcoords.x, tarcoords.y, tarcoords.z)
                    if e < dist then
                        dist = e
                        closest_player = tbl[i]
                    end
                end
            end
        end
    end
    if closest_player ~= 0 then
        return closest_player
    else
        return nil
    end
end

--[[
local function get_waypoint_pos(callback)
    if HUD.IS_WAYPOINT_ACTIVE() then
        local blip = HUD.GET_FIRST_BLIP_INFO_ID(8)
        local waypoint_pos = HUD.GET_BLIP_COORDS(blip)
        return callback(waypoint_pos)
    else
        lang.toast("NO_WAYPOINT_SET")
    end
end
]]

-----------------------------------------------------------------------------------------------------------------------------------

--menu toggle for if the explosion is invisible or not, uses a GLOBAL 
menuToggle(menuroot, "Invisible Explosion?", {"SE_invis", "seinvis"}, "Toggles whether the explosion will be invisible or not. On = Invisible. // BREAKS THE LONG-LASTING FIRE EFFECT OF THE MOLOTOV", function(on)
    if on then
        SEisExploInvis = true
        if SE_Notifications then
            util.toast("Explosion is invisible!")
        end
    else
        SEisExploInvis = false
        if SE_Notifications then
            util.toast("Explosion is visible!")
        end
    end
end, true) --last "true" is makes invisibility enabled by default.
SEisExploInvis = true --set it to actually be true lmfao

--menu toggle for if the explosion is audible or not, uses a GLOBAL
menuToggle(menuroot, "Audible Explosion?", {"SE_audible", "seaudible"}, "Toggles whether the explosion will be audible or not. On = Audible.", function(on)
    if on then
        SEisExploAudible = true
        if SE_Notifications then
            util.toast("Explosion is audible!")
        end
    else
        SEisExploAudible = false
        if SE_Notifications then
            util.toast("Explosion is not audible!")
        end
    end
end)
-----------------------------------------------------------------------------------------------------------------------------------

local lobbyFeats = menu.list(menuroot, "Lobby Features", {}, "")

local expFeats = menu.list(lobbyFeats, "Explosion Features", {}, "")

menuAction(expFeats, "Everyone explode-suicides", {"allsuicide"}, "Makes everyone commit suicide, with an explosion.", function()
    for i = 0, 31, 1 do
        if players.exists(i) then --checks for if the PID exists in session
            local playerPed = getPlayerPed(i)
            local playerCoords = getEntityCoords(playerPed)
            if PED.IS_PED_IN_ANY_VEHICLE(playerPed, true) then
                for i = 0, 50, 1 do --50 explosions to account for armored vehicles, using type 5, as a tank shell as well xD
                    SE_add_owned_explosion(playerPed, playerCoords.x, playerCoords.y, playerCoords.z, 5, 10, SEisExploAudible, SEisExploInvis, 0)
                    wait(10)
                end
            else
                SE_add_owned_explosion(playerPed, playerCoords.x, playerCoords.y, playerCoords.z, 1, 10, SEisExploAudible, SEisExploInvis, 0)
            end
        end
    end
end)

menu.divider(lobbyFeats, "Toxic Features")

local blockFeats = menu.list(lobbyFeats, "Block Areas", {}, "")

menu.divider(blockFeats, "Casino Blocks")

--preload
BA_iterations = 4

menuAction(blockFeats, "Block the Casino", {}, "Look at the player-casino block for an explanation.", function ()
    local hash = 309416120
    requestModel(hash)
    while not hasModelLoaded(hash) do wait() end

    for i = 1, BA_iterations do
        local b1 = OBJECT.CREATE_OBJECT_NO_OFFSET(hash, 918, 42, 80, true, true, true)
        ENTITY.SET_ENTITY_HEADING(b1, 324)
        
        netItAll(b1)
        wait(100)

        local b1_2 = OBJECT.CREATE_OBJECT_NO_OFFSET(hash, 922, 48, 80, true, true, true)
        ENTITY.SET_ENTITY_HEADING(b1_2, 324)

        netItAll(b1_2)
        wait(100)

        local b1_3 = OBJECT.CREATE_OBJECT_NO_OFFSET(hash, 925, 53, 80, true, true, true)
        ENTITY.SET_ENTITY_HEADING(b1_3, 324)

        netItAll(b1_3)
        wait(100)

        local b2 = OBJECT.CREATE_OBJECT_NO_OFFSET(hash, 928, 55, 80, true, true, true)
        ENTITY.SET_ENTITY_HEADING(b2, 239)

        netItAll(b2)
        wait(100)

        local b2_2 = OBJECT.CREATE_OBJECT_NO_OFFSET(hash, 917, 39, 80, true, true, true)
        ENTITY.SET_ENTITY_HEADING(b2_2, 239)

        netItAll(b2_2)
        wait(100)

        --

        local c1 = OBJECT.CREATE_OBJECT_NO_OFFSET(hash, 918, 42, 82, true, true, true)
        ENTITY.SET_ENTITY_HEADING(c1, 324)

        netItAll(c1)
        wait(100)

        local c1_2 = OBJECT.CREATE_OBJECT_NO_OFFSET(hash, 922, 48, 82, true, true, true)
        ENTITY.SET_ENTITY_HEADING(c1_2, 324)

        netItAll(c1_2)
        wait(100)

        local c1_3 = OBJECT.CREATE_OBJECT_NO_OFFSET(hash, 925, 53, 82, true, true, true)
        ENTITY.SET_ENTITY_HEADING(c1_3, 324)

        netItAll(c1_3)
        wait(100)

        local c2 = OBJECT.CREATE_OBJECT_NO_OFFSET(hash, 928, 55, 82, true, true, true)
        ENTITY.SET_ENTITY_HEADING(c2, 239)

        netItAll(c2)
        wait(100)

        local c2_2 = OBJECT.CREATE_OBJECT_NO_OFFSET(hash, 917, 39, 82, true, true, true)
        ENTITY.SET_ENTITY_HEADING(c2_2, 239)

        netItAll(c2_2)
        wait(100)
        if SE_Notifications then
            util.toast("Spawned with index of " .. i)
        end
    end
    noNeedModel(hash)
end)

menuAction(blockFeats, "Block the Casino Garage", {}, "", function ()
    local hash = 309416120
    requestModel(hash)
    while not hasModelLoaded(hash) do wait() end
    for i = 1, BA_iterations do
        local a1 = OBJECT.CREATE_OBJECT_NO_OFFSET(hash, 935, -1, 78, true, true, true)
        ENTITY.SET_ENTITY_HEADING(a1, 59)

        netItAll(a1)
        wait(100)

        local b1 = OBJECT.CREATE_OBJECT_NO_OFFSET(hash, 939, -1, 78, true, true, true)
        ENTITY.SET_ENTITY_HEADING(b1, 329)

        netItAll(b1)
        wait(100)

        local c1 = OBJECT.CREATE_OBJECT_NO_OFFSET(hash, 933, 3, 78, true, true, true)
        ENTITY.SET_ENTITY_HEADING(c1, 329)

        netItAll(c1)
        wait(100)

        --
        
        local a1_2 = OBJECT.CREATE_OBJECT_NO_OFFSET(hash, 935, -1, 80, true, true, true)
        ENTITY.SET_ENTITY_HEADING(a1_2, 59)

        netItAll(a1_2)
        wait(100)

        local b1_2 = OBJECT.CREATE_OBJECT_NO_OFFSET(hash, 939, -1, 80, true, true, true)
        ENTITY.SET_ENTITY_HEADING(b1_2, 329)

        netItAll(b1_2)
        wait(100)

        local c1_2 = OBJECT.CREATE_OBJECT_NO_OFFSET(hash, 933, 3, 80, true, true, true)
        ENTITY.SET_ENTITY_HEADING(c1_2, 329)

        netItAll(c1_2)
        wait(100)
        if SE_Notifications then
            util.toast("Spawned with index of " .. i)
        end
    end
    noNeedModel(hash)
end)

menu.divider(blockFeats, "Los Santos Customs Blocks")

menuAction(blockFeats, "Block LSC (1/4, by the airport)", {}, "", function ()
    local hash = 309416120
    requestModel(hash)
    while not hasModelLoaded(hash) do wait() end
    for i = 1, BA_iterations do
        local a1 = OBJECT.CREATE_OBJECT_NO_OFFSET(hash, -1144, -1988, 12, true, true, true)
        ENTITY.SET_ENTITY_HEADING(a1, 46)

        netItAll(a1)
        wait(100)

        local b1 = OBJECT.CREATE_OBJECT_NO_OFFSET(hash, -1143, -1992, 12, true, true, true)
        ENTITY.SET_ENTITY_HEADING(b1, 137)

        netItAll(b1)
        wait(100)

        local c1 = OBJECT.CREATE_OBJECT_NO_OFFSET(hash, -1147, -1988, 12, true, true, true)
        ENTITY.SET_ENTITY_HEADING(c1, 137)

        netItAll(c1)
        wait(100)

        --

        local a1_2 = OBJECT.CREATE_OBJECT_NO_OFFSET(hash, -1144, -1988, 14, true, true, true)
        ENTITY.SET_ENTITY_HEADING(a1_2, 46)

        netItAll(a1_2)
        wait(100)

        local b1_2 = OBJECT.CREATE_OBJECT_NO_OFFSET(hash, -1143, -1992, 14, true, true, true)
        ENTITY.SET_ENTITY_HEADING(b1_2, 137)

        netItAll(b1_2)
        wait(100)

        local c1_2 = OBJECT.CREATE_OBJECT_NO_OFFSET(hash, -1147, -1988, 14, true, true, true)
        ENTITY.SET_ENTITY_HEADING(c1_2, 137)

        netItAll(c1_2)
        wait(100)
        if SE_Notifications then
            util.toast("Spawned with index of " .. i)
        end
    end
    noNeedModel(hash)
end)

menuAction(blockFeats, "Block LSC (2/4, right of the map)", {}, "", function ()
    local hash = 309416120
    requestModel(hash)
    while not hasModelLoaded(hash) do wait() end
    for i = 1, BA_iterations do
        local a1 = OBJECT.CREATE_OBJECT_NO_OFFSET(hash, 719, -1089, 21, true, true, true)
        ENTITY.SET_ENTITY_HEADING(a1, 0)

        netItAll(a1)
        wait(100)

        local b1 = OBJECT.CREATE_OBJECT_NO_OFFSET(hash, 721, -1092, 21, true, true, true)
        ENTITY.SET_ENTITY_HEADING(b1, 93)

        netItAll(b1)
        wait(100)

        local c1 = OBJECT.CREATE_OBJECT_NO_OFFSET(hash, 721, -1085, 21, true, true, true)
        ENTITY.SET_ENTITY_HEADING(c1, 93)

        netItAll(c1)
        wait(100)

        --

        local a1_2 = OBJECT.CREATE_OBJECT_NO_OFFSET(hash, 719, -1089, 23, true, true, true)
        ENTITY.SET_ENTITY_HEADING(a1_2, 0)

        netItAll(a1_2)
        wait(100)

        local b1_2 = OBJECT.CREATE_OBJECT_NO_OFFSET(hash, 721, -1092, 23, true, true, true)
        ENTITY.SET_ENTITY_HEADING(b1_2, 93)

        netItAll(b1_2)
        wait(100)

        local c1_2 = OBJECT.CREATE_OBJECT_NO_OFFSET(hash, 721, -1085, 23, true, true, true)
        ENTITY.SET_ENTITY_HEADING(c1_2, 93)

        netItAll(c1_2)
        wait(100)
        if SE_Notifications then
            util.toast("Spawned with index of " .. i)
        end
    end
    noNeedModel(hash)
end)

menuAction(blockFeats, "Block LSC (3/4, middle of the map)", {}, "", function ()
    local hash = 309416120
    requestModel(hash)
    while not hasModelLoaded(hash) do wait() end

    --LSC in the middle of the map, classified as (3/4) on the map.
    for i = 1, BA_iterations do
        local a1 = OBJECT.CREATE_OBJECT_NO_OFFSET(hash, -359, -134, 38, true, true, true)
        ENTITY.SET_ENTITY_HEADING(a1, 340)

        netItAll(a1)
        wait(100)

        local b1 = OBJECT.CREATE_OBJECT_NO_OFFSET(hash, -356, -132, 38, true, true, true)
        ENTITY.SET_ENTITY_HEADING(b1, 252)

        netItAll(b1)
        wait(100)

        local c1 = OBJECT.CREATE_OBJECT_NO_OFFSET(hash, -358, -137, 38, true, true, true)
        ENTITY.SET_ENTITY_HEADING(c1, 250)

        netItAll(c1)
        wait(100)

        --

        local a1_2 = OBJECT.CREATE_OBJECT_NO_OFFSET(hash, -359, -134, 40, true, true, true)
        ENTITY.SET_ENTITY_HEADING(a1_2, 340)

        netItAll(a1_2)
        wait(100)

        local b1_2 = OBJECT.CREATE_OBJECT_NO_OFFSET(hash, -356, -132, 40, true, true, true)
        ENTITY.SET_ENTITY_HEADING(b1_2, 252)

        netItAll(b1_2)
        wait(100)

        local c1_2 = OBJECT.CREATE_OBJECT_NO_OFFSET(hash, -358, -137, 40, true, true, true)
        ENTITY.SET_ENTITY_HEADING(c1_2, 250)

        netItAll(c1_2)
        wait(100)

        if SE_Notifications then
            util.toast("Spawned with index of " .. i)
        end

    end
    noNeedModel(hash)
end)

menuAction(blockFeats, "Block LSC (4/4, top of the map)", {}, "", function ()
    local hash = 309416120
    requestModel(hash)
    while not hasModelLoaded(hash) do wait() end
    for i = 1, BA_iterations do
        local a1 = OBJECT.CREATE_OBJECT_NO_OFFSET(hash, 1182, 2650, 37, true, true, true)
        ENTITY.SET_ENTITY_HEADING(a1, 88+180)

        netItAll(a1)
        wait(100)

        local b1 = OBJECT.CREATE_OBJECT_NO_OFFSET(hash, 1176, 2650, 37, true, true, true)
        ENTITY.SET_ENTITY_HEADING(b1, 88+180)

        netItAll(b1)
        wait(100)

        local c1 = OBJECT.CREATE_OBJECT_NO_OFFSET(hash, 1185, 2647, 37, true, true, true)
        ENTITY.SET_ENTITY_HEADING(c1, 182)

        netItAll(c1)
        wait(100)

        local d1 = OBJECT.CREATE_OBJECT_NO_OFFSET(hash, 1172, 2646, 37, true, true, true)
        ENTITY.SET_ENTITY_HEADING(d1, 2)

        netItAll(d1)
        wait(100)

        --

        local a1_2 = OBJECT.CREATE_OBJECT_NO_OFFSET(hash, 1182, 2650, 39, true, true, true)
        ENTITY.SET_ENTITY_HEADING(a1_2, 88+180)

        netItAll(a1_2)
        wait(100)

        local b1_2 = OBJECT.CREATE_OBJECT_NO_OFFSET(hash, 1176, 2650, 39, true, true, true)
        ENTITY.SET_ENTITY_HEADING(b1_2, 88+180)

        netItAll(b1_2)
        wait(100)

        local c1_2 = OBJECT.CREATE_OBJECT_NO_OFFSET(hash, 1185, 2647, 39, true, true, true)
        ENTITY.SET_ENTITY_HEADING(c1_2, 182)

        netItAll(c1_2)
        wait(100)

        local d1_2 = OBJECT.CREATE_OBJECT_NO_OFFSET(hash, 1172, 2646, 39, true, true, true)
        ENTITY.SET_ENTITY_HEADING(d1_2, 2)

        netItAll(d1_2)
        wait(100)
        if SE_Notifications then
            util.toast("Spawned with index of " .. i)
        end
    end
    noNeedModel(hash)
end)

menuAction(blockFeats, "Block Nearest Road", {}, "", function ()
    local v3pointer = memory.alloc()
    local headpointer = memory.alloc()
    ----
    local closecoord = getEntityCoords(getLocalPed())
    PATHFIND.GET_CLOSEST_VEHICLE_NODE_WITH_HEADING(closecoord.x, closecoord.y, closecoord.z, v3pointer, headpointer, 1, 3.0, 0)
    local v3memory = memory.read_vector3(v3pointer)
    local headmemory = memory.read_float(headpointer)
    ----
    local hash = 309416120
    requestModel(hash)
    while not hasModelLoaded(hash) do wait() end
    for i = 1, BA_iterations do
        local a1 = OBJECT.CREATE_OBJECT(hash, v3memory.x, v3memory.y, v3memory.z, true, true, true)
        ENTITY.SET_ENTITY_HEADING(a1, headmemory + 90)
        netItAll(a1)
        wait(100)
    end
    noNeedModel(hash)
    ----
    memory.free(v3pointer)
    memory.free(headpointer)
end)

menu.divider(blockFeats, "Settings")

menuToggle(blockFeats, "Are props visible?", {}, "Decide whether the blocking walls are visible or not.", function(on)
    if on then
        BA_visible = true
        if SE_Notifications then
            util.toast("Props visible!")
        end
    else
        BA_visible = false
        if SE_Notifications then
            util.toast("Props invisible!")
        end
    end
end)

menu.slider(blockFeats, "Iterations of spawn", {"spawniterations"}, "How many times the objects are spawned, to 'make them stick' to the player. Higher values = more time, but more chance of them sticking.", 1, 10, 4, 1, function(value)
    BA_iterations = value
    if SE_Notifications then
        util.toast("Iteratinos set to " .. BA_iterations)
    end
end)

local function pizzaCAll()
    for p = 0, 31, 1 do
        if ENTITY.DOES_ENTITY_EXIST(getPlayerPed(p)) then
            for i = 1, 10 do
                local cord = getEntityCoords(getPlayerPed(p))
                requestModel(-930879665)
                wait(10)
                requestModel(3613262246)
                wait(10)
                requestModel(452618762)
                wait(10)
                while not hasModelLoaded(-930879665) do wait() end
                while not hasModelLoaded(3613262246) do wait() end
                while not hasModelLoaded(452618762) do wait() end
                local a1 = entities.create_object(-930879665, cord)
                wait(10)
                local a2 = entities.create_object(3613262246, cord)
                wait(10)
                local b1 = entities.create_object(452618762, cord)
                wait(10)
                local b2 = entities.create_object(3613262246, cord)
                wait(300)
                entities.delete_by_handle(a1)
                entities.delete_by_handle(a2)
                entities.delete_by_handle(b1)
                entities.delete_by_handle(b2)
                noNeedModel(452618762)
                wait(10)
                noNeedModel(3613262246)
                wait(10)
                noNeedModel(-930879665)
                wait(10)
            end
            if SE_Notifications then
                util.toast("Finished with player // " .. tostring(PLAYER.GET_PLAYER_NAME(p)) .. " // of index " .. p)
            end
        end
    end
end


-----------------------------------------------------------------------------------------------------------------

Pizzaall = menuAction(lobbyFeats, "Black Plague Crash All", {"plagueall"}, "Blocked by most menus.", function ()
    menu.show_warning(Pizzaall, 1, "This will crash everyone with the plague. Did you mean to click this?", pizzaCAll)
end)

local lobbyremove = menu.list(lobbyFeats, "Removes", {}, "")

menuAction(lobbyremove, "Freemode death all.", {"allfdeath"}, "Will probably not work on some/most menus. A 'delayed kick' of sorts.", function ()
    for p = 0, 31 do
        if p ~= players.user() and NETWORK.NETWORK_IS_PLAYER_CONNECTED(p) then
            for i = -1, 1 do
                for n = -1, 1 do
                    util.trigger_script_event(1 << p, {-65587051, 28, i, n})
                end
            end
            for i = -1, 1 do
                for n = -1, 1 do
                    util.trigger_script_event(1 << p, {1445703181, 28, i, n})
                end
            end
            wait(100)
            util.trigger_script_event(1 << p, {-290218924, -32190, -71399, 19031, 85474, 4468, -2112})
            util.trigger_script_event(1 << p, {-227800145, -1000000, -10000000, -100000000, -100000000, -100000000})
            util.trigger_script_event(1 << p, {2002459655, -1000000, -10000, -100000000})
            util.trigger_script_event(1 << p, {911179316, -38, -30, -75, -59, 85, 82})
        end
        for i = -1, 1 do
            for a = -1, 1 do
                util.trigger_script_event(1 << p, {916721383, i, a, 0, 26})
            end
        end
    end
end)

TXC_SLOW = false

menuAction(lobbyremove, "AIO Kick All.", {"allaiokick", "allaiok"}, "Will probably not work on some menus.", function ()
    menu.trigger_commands("scripthost")
    for i = 0, 31 do
        if i ~= players.user() and NETWORK.NETWORK_IS_PLAYER_CONNECTED(i) then
            util.toast("Player connected " .. tostring(PLAYER.GET_PLAYER_NAME(i) .. ", commencing AIO."))
            util.trigger_script_event(1 << i, {0x37437C28, 1, 15, math.random(-2147483647, 2147483647)})
            wait(10) 
            util.trigger_script_event(1 << i, {-1308840134, 1, 15, math.random(-2147483647, 2147483647)})
            wait(10) 
            util.trigger_script_event(1 << i, {0x4E0350C6, 1, 15, math.random(-2147483647, 2147483647)})
            wait(10) 
            util.trigger_script_event(1 << i, {-0x114C63AC, 1, 15, math.random(-2147483647, 2147483647)})
            wait(10) 
            util.trigger_script_event(1 << i, {-0x15F5B1D4, 1, 15, math.random(-2147483647, 2147483647)})
            wait(10) 
            util.trigger_script_event(1 << i, {-0x249FE11B, 1, 15, math.random(-2147483647, 2147483647)})
            wait(10) 
            util.trigger_script_event(1 << i, {-0x76B11968, 1, 15, math.random(-2147483647, 2147483647)})
            wait(10) 
            util.trigger_script_event(1 << i, {0x9C050EC, 1, 15, math.random(-2147483647, 2147483647)})
            wait(10) 
            util.trigger_script_event(1 << i, {0x3B873479, 1, 15, math.random(-2147483647, 2147483647)})
            wait(10) 
            util.trigger_script_event(1 << i, {0x23F74138, math.random(-2147483647, 2147483647), 1, 115, math.random(-2147483647, 2147483647)})
            wait(10) 
            --[[
            util.trigger_script_event(1 << i, {0xAD63290E, math.random(-2147483647, 2147483647), 1, 115, math.random(-2147483647, 2147483647)})
            wait(10) 
            ]]
            --[[
            util.trigger_script_event(1 << i, {0x39624029, math.random(-2147483647, 2147483647), 1, 115, math.random(-2147483647, 2147483647)})
            wait(10) 
            ]]
            util.trigger_script_event(1 << i, {-0x529CD6F2, math.random(-2147483647, 2147483647), 1, 115, math.random(-2147483647, 2147483647)})
            wait(10) 
            util.trigger_script_event(1 << i, {-0x756DBC8A, math.random(-2147483647, 2147483647), 1, 115, math.random(-2147483647, 2147483647)})
            wait(10) 
            util.trigger_script_event(1 << i, {-0x69532BA0, math.random(-2147483647, 2147483647), 1, 115, math.random(-2147483647, 2147483647)})
            wait(10) 
            util.trigger_script_event(1 << i, {0x68C5399F, math.random(-2147483647, 2147483647), 1, 115, math.random(-2147483647, 2147483647)})
            wait(10) 
            util.trigger_script_event(1 << i, {0x7DE8CAC0, math.random(-2147483647, 2147483647), 1, 115, math.random(-2147483647, 2147483647)})
            wait(10) 
            util.trigger_script_event(1 << i, {0x285DDF33, math.random(-2147483647, 2147483647), 1, 115, math.random(-2147483647, 2147483647)})
            wait(10) 
            util.trigger_script_event(1 << i, {-0x177132B8, math.random(-2147483647, 2147483647), 1, 115, math.random(-2147483647, 2147483647)})
            wait(10)
            --util.toast("Main block done. // AIO")
            util.trigger_script_event(1 << i, {memory.script_global(1893548 + (1 + (i * 600) + 511)), i})
            for a = -1, 1 do
                for n = -1, 1 do
                    util.trigger_script_event(1 << i, {-65587051, 28, a, n})
                    wait(10)
                end
            end
            --util.toast("Second block done. // AIO")
            for a = -1, 1 do
                for n = -1, 1 do
                    util.trigger_script_event(1 << i, {1445703181, 28, a, n})
                    wait(10)
                end
            end
            --util.toast("Third block done. // AIO")
            if TXC_SLOW then
                wait(10)
                util.trigger_script_event(1 << i, {-290218924, -32190, -71399, 19031, 85474, 4468, -2112})
                wait(10)
                util.trigger_script_event(1 << i, {-227800145, -1000000, -10000000, -100000000, -100000000, -100000000})
                wait(10)
                util.trigger_script_event(1 << i, {2002459655, -1000000, -10000, -100000000})
                wait(10)
                util.trigger_script_event(1 << i, {911179316, -38, -30, -75, -59, 85, 82})
                wait(10)
                --[[
                for n = -10, -7 do
                    for a = -60, 60 do
                        util.trigger_script_event(1 << i, {0x39624029, n, 623656, a, 73473741, -7, 856844, -51251, 856844})
                        wait(10)
                    end
                end
                ]]
                util.trigger_script_event(1 << i, {-290218924, -32190, -71399, 19031, 85474, 4468, -2112})
                wait(10)
                util.trigger_script_event(1 << i, {-1386010354, 91645, -99683, 1788, 60877, 55085, 72028})
                wait(10)
                util.trigger_script_event(1 << i, {-227800145, -1000000, -10000000, -100000000, -100000000, -100000000})
                wait(10)
                for g = -28, 0 do
                    for n = -1, 1 do
                        for a = -1, 1 do
                            util.trigger_script_event(1 << i, {1445703181, i, n, a})
                        end
                    end
                    wait(10)
                end
                --[[for a = -28, 20 do
                    for n = -10, 2 do
                        for b = -100, 100 do
                            util.trigger_script_event(1 << i, {-1782442696, b, n, a})
                            util.log("Number 6, iteration " .. b)
                        end
                        util.log("Number 7, iteration " .. n)
                    end
                    util.log("Number 8, iteration " .. a)
                    wait(10)
                end]]
                for a = -11, 11 do
                    util.trigger_script_event(1 << i, {2002459655, -1000000, a, -100000000})
                end
                for a = -10, 10 do
                    for n = 30, -30 do
                        util.trigger_script_event(1 << i, {911179316, a, n, -75, -59, 85, 82})
                    end
                end
                for a = -10, 10 do
                    util.trigger_script_event(1 << i, {-65587051, a, -1, -1})
                end
                util.trigger_script_event(1 << i, {951147709, i, 1000000, nil, nil}) 
                for a = -10, 10 do
                    util.trigger_script_event(1 << i, {-1949011582, a, 1518380048})
                end
                for a = -10, 4 do
                    for n = -10, 5 do
                        util.trigger_script_event(1 << i, {1445703181, 28, a, n})
                    end
                end
            end
            util.toast("Fourth block done. // AIO")
            util.toast("Iteration " .. i .. " complete of AIO kick.")
            util.toast("Player " .. PLAYER.GET_PLAYER_NAME(i) .. " done.")
        end
    end
    wait(100)
end)

menuToggle(lobbyremove, "Slower, but better AIO.", {}, "", function (on)
    if on then
        TXC_SLOW = true
    else
        TXC_SLOW = false
    end
end)

----------------------------------------------------------------------------

menu.divider(lobbyFeats, "Other Features")

menuAction(lobbyFeats, "Remove Vehicle Godmode for All (BETA)", {"allremovevehgod"}, "Removes everyone's vehicle godmode, making them easier to kill :)", function ()
    for i = 0, 31 do
        if NETWORK.NETWORK_IS_PLAYER_CONNECTED(i) then
            local ped = getPlayerPed(i)
            if PED.IS_PED_IN_ANY_VEHICLE(ped, false) then
                local veh = PED.GET_VEHICLE_PED_IS_IN(ped, false)
                ENTITY.SET_ENTITY_CAN_BE_DAMAGED(veh, true)
                ENTITY.SET_ENTITY_INVINCIBLE(veh, false)
            end
        end
    end
end)

menuAction(lobbyFeats, "Teleport everyone's vehicles to ocean (BETA)", {"alltpvehocean"}, "Teleports everyone's vehicles into the ocean.", function()
    local oldcoords = getEntityCoords(getLocalPed())
    for i = 0, 31 do
        if NETWORK.NETWORK_IS_PLAYER_CONNECTED(i) then
            local ped = getPlayerPed(i)
            local pedCoords = getEntityCoords(ped)
            for c = 0, 5 do --teleports us to them so we load their veh
                ENTITY.SET_ENTITY_COORDS_NO_OFFSET(getLocalPed(), pedCoords.x, pedCoords.y, pedCoords.z + 10, false, false, false)
                wait(100)
            end
            if PED.IS_PED_IN_ANY_VEHICLE(ped, false) then
                local veh = PED.GET_VEHICLE_PED_IS_IN(ped, false)
                for a = 0, 10 do
                    NETWORK.NETWORK_REQUEST_CONTROL_OF_ENTITY(veh)
                    ENTITY.SET_ENTITY_COORDS_NO_OFFSET(veh, 4500, -4400, 4, false, false, false)
                    wait(100)
                end
                for b = 0, 10 do
                    ENTITY.SET_ENTITY_COORDS_NO_OFFSET(veh, 4500, -4400, 4, false, false, false)
                end
            end
        end
    end
    ENTITY.SET_ENTITY_COORDS_NO_OFFSET(getLocalPed(), oldcoords.x, oldcoords.y, oldcoords.z, false, false, false)
end)

menuAction(lobbyFeats, "Teleport everyone's vehicles to Maze Bank (BETA)", {"alltpvehmazebank"}, "Teleports everyone's vehicles on top of the Maze Bank tower.", function()
    local oldcoords = getEntityCoords(getLocalPed())
    for i = 0, 31 do
        if NETWORK.NETWORK_IS_PLAYER_CONNECTED(i) then
            local pped = getPlayerPed(i)
            local pedCoords = getEntityCoords(pped)
            for c = 0, 5 do --teleports us to them so we load their veh
                ENTITY.SET_ENTITY_COORDS_NO_OFFSET(getLocalPed(), pedCoords.x, pedCoords.y, pedCoords.z + 10, false, false, false)
                wait(100)
            end
            if PED.IS_PED_IN_ANY_VEHICLE(pped, false) then
                local veh = PED.GET_VEHICLE_PED_IS_IN(pped, false)
                for a = 0, 10 do
                    NETWORK.NETWORK_REQUEST_CONTROL_OF_ENTITY(veh)
                    ENTITY.SET_ENTITY_COORDS_NO_OFFSET(veh, -76, -819, 327, false, false, false)
                    wait(100)
                end
                for b = 0, 10 do
                    ENTITY.SET_ENTITY_COORDS_NO_OFFSET(veh, -76, -819, 327, false, false, false)
                end
            end
        end
    end
    ENTITY.SET_ENTITY_COORDS_NO_OFFSET(getLocalPed(), oldcoords.x, oldcoords.y, oldcoords.z, false, false, false)
end)

-----------------------------------------------------------------------------------------------------------------------------------

--preload

local mFunFeats = menu.list(menuroot, "Fun Features", {}, "")
menu.divider(mFunFeats, "Sticky Bomb Gun")

SE_stickyEntities = {}
SE_stickyCount = 1
----
SE_stickyvec3 = {}
SE_stickyvec3count = 1
----
ARAY_StickyBombGun = false --ArrayList setup
----
menuToggleLoop(mFunFeats, "Improved Sticky Bomb Gun", {"sbgun"}, "Notes where or what you shot, to explode it later.", function ()
    --[[
    if SE_ArrayList then
        ARAY_StickyBombGun = true
    end]]
    local pped = getLocalPed() --get local ped, assign to "pped"
    if PED.IS_PED_SHOOTING(pped) then --check for shooting
        local tarEnt = memory.alloc() --allocate memory to get Target Entity
        local isEntFound = PLAYER.GET_ENTITY_PLAYER_IS_FREE_AIMING_AT(players.user(), tarEnt) --is the entity found withing our aiming range?
        if isEntFound then --if the entity is found, then...
            local entt = memory.read_int(tarEnt) --get the entity handle
            SE_stickyEntities[SE_stickyCount] = entt --assign it to our table
            SE_stickyCount = SE_stickyCount + 1 --make our counter + 1
            if SE_Notifications then
                util.toast("Entity marked.")
            end
        else --if we WEREN't aiming at an entity, then...
            local minevec3 = memory.alloc() --allocate memory for target coords
            local junk = WEAPON.GET_PED_LAST_WEAPON_IMPACT_COORD(pped, minevec3) --get target coords
            local mv3 = memory.read_vector3(minevec3) --get v3 coords
            SE_stickyvec3[SE_stickyvec3count] = mv3 --assign to table
            SE_stickyvec3count = SE_stickyvec3count + 1 --counter + 1
            memory.free(minevec3)
            if SE_Notifications then
                util.toast("Coordinate marked.")
            end
        end
        memory.free(tarEnt)
    end--[[
    if SE_ArrayList then
        if ARAY_StickyBombGun then
            SE_ArrayCount = SE_ArrayCount + 1
            --
            directx.draw_text(SE_ArrayOffsetX, (SE_ArrayCount * 0.02) + SE_ArrayOffsetY, "Improved Sticky Bomb Gun", ALIGN_TOP_LEFT, SE_ArrayScale, SE_ArrayColor, false)
            SE_ArrayCount = SE_ArrayCount - 1
        end
        ARAY_StickyBombGun = false
    end
    ]]
end)

menuAction(mFunFeats, "Explode All Stickybombs", {"expsb"}, "Explodes all marked entities and coordinate with one stickybomb.", function ()
    for i = 1, #SE_stickyEntities do
        local targetC = getEntityCoords(SE_stickyEntities[i])
        SE_add_owned_explosion(getLocalPed(), targetC.x, targetC.y, targetC.z, 2, 10, SEisExploAudible, SEisExploInvis, 0)
    end
    for i = 1, #SE_stickyvec3 do
        local tarc = SE_stickyvec3[i]
        SE_add_owned_explosion(getLocalPed(), tarc.x, tarc.y, tarc.z, 2, 10, SEisExploAudible, SEisExploInvis, 0)
    end
    if SE_Notifications then
        util.toast("Exploded all stickybombs!")
    end
end)

menuAction(mFunFeats, "Clear Stickybombs", {"clearsb"}, "Clears all stickybombs from this script.", function ()
    if SE_Notifications then
        util.toast("Stickybombs deleted!")
    end
    SE_stickyEntities = {}
    SE_stickyCount = 1
    SE_stickyvec3 = {}
    SE_stickyvec3count = 1
end)


----
menu.divider(mFunFeats, "Extinciton Gun")
----


MarkedForExt = {}
MarkedForExtCount = 1
----
ARAY_ExtinctionGun = false --ArrayList setup
----
menuToggleLoop(mFunFeats, "Better Extinction Gun", {}, "", function ()
    --[[
    if SE_ArrayList then
        ARAY_ExtinctionGun = true
    end]]
    local localPed = getLocalPed()
    if PED.IS_PED_SHOOTING(localPed) then
        local point = memory.alloc(4)
        local isEntFound = PLAYER.GET_ENTITY_PLAYER_IS_FREE_AIMING_AT(players.user(), point)
        if isEntFound then
            local entt = memory.read_int(point)
            if ENTITY.IS_ENTITY_A_PED(entt) and PED.IS_PED_IN_ANY_VEHICLE(entt) then
                local pedVeh = PED.GET_VEHICLE_PED_IS_IN(entt, false)
                local maxPassengers = VEHICLE.GET_VEHICLE_MAX_NUMBER_OF_PASSENGERS(pedVeh) - 1
                for i = -1, maxPassengers do
                    local seatFree = VEHICLE.IS_VEHICLE_SEAT_FREE(pedVeh, i, false)
                    if not seatFree then
                        local targetPed = VEHICLE.GET_PED_IN_VEHICLE_SEAT(pedVeh, i, false)
                        MarkedForExt[MarkedForExtCount] = targetPed
                        if SE_Notifications then
                            util.toast("Marked for extinction! Index " .. MarkedForExtCount)
                        end
                        MarkedForExtCount = MarkedForExtCount + 1
                    end
                end
                MarkedForExt[MarkedForExtCount] = pedVeh
                if SE_Notifications then
                    util.toast("Marked for extinction! Index " .. MarkedForExtCount)
                end
                MarkedForExtCount = MarkedForExtCount + 1
            else
                MarkedForExt[MarkedForExtCount] = entt
                if SE_Notifications then
                    util.toast("Marked for extinction! Index " .. MarkedForExtCount)
                end
                MarkedForExtCount = MarkedForExtCount + 1
            end
        end
    end
    --[[
    if SE_ArrayList then
        if ARAY_ExtinctionGun then
            SE_ArrayCount = SE_ArrayCount + 1
            --
            directx.draw_text(SE_ArrayOffsetX, (SE_ArrayCount * 0.02) + SE_ArrayOffsetY, "Better Extinction Gun", ALIGN_TOP_LEFT, SE_ArrayScale, SE_ArrayColor, false)
            SE_ArrayCount = SE_ArrayCount - 1
        end
        ARAY_ExtinctionGun = false
    end
    ]]
end)

menuAction(mFunFeats, "Extinct.", {}, "", function ()
    for i = 1, #MarkedForExt, 1 do
        entities.delete_by_handle(MarkedForExt[i])
    end
    MarkedForExt = {}
    MarkedForExtCount = 1
    -- resets the extinction
    if SE_Notifications then
        util.toast("Deleted! Clearing extinction list...")
    end
end)
menuAction(mFunFeats, "Clear Extinct List", {}, "", function ()
    MarkedForExt = {}
    MarkedForExtCount = 1
end)


----------------------------------------------------------------------------------------------------

menu.divider(mFunFeats, "Proximity Mine Gun")

PROX_Coords = {}
PROX_Count = 1

menuToggleLoop(mFunFeats, "Proximity Mine Gun", {"proxgun"}, "Only works on coordinates, not entities. For that, use sticky bomb gun.", function ()
    local localped = getLocalPed()
    if PED.IS_PED_SHOOTING(localped) then --check if we shooting
        local pointer = memory.alloc() --allocate memory for coords
        local junk = WEAPON.GET_PED_LAST_WEAPON_IMPACT_COORD(localped, pointer) --get pointer to coord
        local coord = memory.read_vector3(pointer) --get coord (read from pointer)
        if coord.x ~= 0.0 and coord.y ~= 0.0 and coord.z ~= 0.0 then --check for dud (if we didn't register the shot)
            PROX_Coords[PROX_Count] = coord --assign coord to table
            PROX_Count = PROX_Count + 1 --make the counter go up
            if SE_Notifications then
                util.toast("Proximity mine placed at " .. coord.x .. " " .. coord.y .. " " .. coord.z)
            end
        end
        memory.free(pointer) --free the memory so we don't bruh moment the script
    end
end)



menuToggleLoop(mFunFeats, "Enable/Disable Proximity Mines", {"enableprox", "proxon"}, "Makes the proximity mines actually check for if entities are by them.", function ()
    if PROX_Coords ~= nil then
        for i = 1, #PROX_Coords do
            local pedTable = entities.get_all_peds_as_handles()
            for a = 1, #pedTable do
                if ENTITY.IS_ENTITY_IN_AREA(pedTable[a], PROX_Coords[i].x + 2, PROX_Coords[i].y + 2, PROX_Coords[i].z, PROX_Coords[i].x - 2, PROX_Coords[i].y - 2, PROX_Coords[i].z + 2, true, true, true) then
                    SE_add_owned_explosion(getLocalPed(), PROX_Coords[i].x, PROX_Coords[i].y, PROX_Coords[i].z, 2, 10, true, false, 0.4)
                end
            end
        end
    end
end)

menuAction(mFunFeats, "Clear Proximity Mines", {"clearprox"}, "Clears all proximity mines that you've placed.", function ()
    util.toast("Cleared all " .. #PROX_Coords .. " proximity mines!")
    PROX_Coords = {}
    PROX_Count = 1
end)

----------------------------------------------------------------------------------------------------
menu.divider(mFunFeats, "Kill Aura")

--preload
KA_Radius = 20
KA_Blame = true
KA_Players = false
KA_Onlyplayers = false
KA_Delvehs = false
KA_Delpeds = false

menuToggleLoop(mFunFeats, "KillAura", {"killaura"}, "Kills peds, optionally players, optionally friends, in a raidus.", function ()
    local tKCount = 1
    local toKill = {}
    local ourcoords = getEntityCoords(getLocalPed())
    local ourped = getLocalPed()
    local weaponhash = 177293209 -- heavy sniper mk2 hash
    --
    local pedPointers = entities.get_all_peds_as_pointers()
    for i = 1, #pedPointers do
        local v3 = entities.get_position(pedPointers[i])
        local vdist = MISC.GET_DISTANCE_BETWEEN_COORDS(ourcoords.x, ourcoords.y, ourcoords.z, v3.x, v3.y, v3.z, true)
        if vdist <= KA_Radius then
            toKill[tKCount] = entities.pointer_to_handle(pedPointers[i])
            tKCount = tKCount + 1
        end
    end
    for i = 1, #toKill do
        if (not KA_Onlyplayers and not PED.IS_PED_A_PLAYER(toKill[i])) or (KA_Players) or (KA_Onlyplayers and PED.IS_PED_A_PLAYER(toKill[i])) then
            if toKill[i] ~= getLocalPed() then
                if not PED.IS_PED_DEAD_OR_DYING(toKill[i]) then
                    if PED.IS_PED_IN_ANY_VEHICLE(toKill[i]) then
                        local veh = PED.GET_VEHICLE_PED_IS_IN(toKill[i], false)
                        local pedcoords = getEntityCoords(toKill[i])
                        if not PED.IS_PED_A_PLAYER(toKill[i]) and KA_Delvehs then
                            entities.delete_by_handle(veh)
                        end
                        if KA_Blame then
                            MISC.SHOOT_SINGLE_BULLET_BETWEEN_COORDS_IGNORE_ENTITY(pedcoords.x, pedcoords.y, pedcoords.z + 0.5, pedcoords.x, pedcoords.y, pedcoords.z, 1000, true, weaponhash, ourped, false, fastNet, -1, veh, true)
                            MISC.SHOOT_SINGLE_BULLET_BETWEEN_COORDS_IGNORE_ENTITY(pedcoords.x, pedcoords.y, pedcoords.z - 0.5, pedcoords.x, pedcoords.y, pedcoords.z, 1000, true, weaponhash, ourped, false, fastNet, -1, veh, true)
                            MISC.SHOOT_SINGLE_BULLET_BETWEEN_COORDS_IGNORE_ENTITY(pedcoords.x + 1, pedcoords.y, pedcoords.z + 0.5, pedcoords.x, pedcoords.y, pedcoords.z, 1000, true, weaponhash, ourped, false, fastNet, -1, veh, true)
                            MISC.SHOOT_SINGLE_BULLET_BETWEEN_COORDS_IGNORE_ENTITY(pedcoords.x - 1, pedcoords.y, pedcoords.z + 0.5, pedcoords.x, pedcoords.y, pedcoords.z, 1000, true, weaponhash, ourped, false, fastNet, -1, veh, true)
                            MISC.SHOOT_SINGLE_BULLET_BETWEEN_COORDS_IGNORE_ENTITY(pedcoords.x, pedcoords.y + 1, pedcoords.z + 0.5, pedcoords.x, pedcoords.y, pedcoords.z, 1000, true, weaponhash, ourped, false, fastNet, -1, veh, true)
                            MISC.SHOOT_SINGLE_BULLET_BETWEEN_COORDS_IGNORE_ENTITY(pedcoords.x, pedcoords.y - 1, pedcoords.z + 0.5, pedcoords.x, pedcoords.y, pedcoords.z, 1000, true, weaponhash, ourped, false, fastNet, -1, veh, true)
                        else
                            MISC.SHOOT_SINGLE_BULLET_BETWEEN_COORDS_IGNORE_ENTITY(pedcoords.x, pedcoords.y, pedcoords.z + 0.5, pedcoords.x, pedcoords.y, pedcoords.z, 1000, true, weaponhash, 0, false, false, -1, veh, true)
                            MISC.SHOOT_SINGLE_BULLET_BETWEEN_COORDS_IGNORE_ENTITY(pedcoords.x, pedcoords.y, pedcoords.z - 0.5, pedcoords.x, pedcoords.y, pedcoords.z, 1000, true, weaponhash, 0, false, false, -1, veh, true)
                            MISC.SHOOT_SINGLE_BULLET_BETWEEN_COORDS_IGNORE_ENTITY(pedcoords.x + 1, pedcoords.y, pedcoords.z + 0.5, pedcoords.x, pedcoords.y, pedcoords.z, 1000, true, weaponhash, 0, false, false, -1, veh, true)
                            MISC.SHOOT_SINGLE_BULLET_BETWEEN_COORDS_IGNORE_ENTITY(pedcoords.x - 1, pedcoords.y, pedcoords.z + 0.5, pedcoords.x, pedcoords.y, pedcoords.z, 1000, true, weaponhash, 0, false, false, -1, veh, true)
                            MISC.SHOOT_SINGLE_BULLET_BETWEEN_COORDS_IGNORE_ENTITY(pedcoords.x, pedcoords.y + 1, pedcoords.z + 0.5, pedcoords.x, pedcoords.y, pedcoords.z, 1000, true, weaponhash, 0, false, false, -1, veh, true)
                            MISC.SHOOT_SINGLE_BULLET_BETWEEN_COORDS_IGNORE_ENTITY(pedcoords.x, pedcoords.y - 1, pedcoords.z + 0.5, pedcoords.x, pedcoords.y, pedcoords.z, 1000, true, weaponhash, 0, false, false, -1, veh, true)
                        end
                        wait(50)
                        if not PED.IS_PED_A_PLAYER(toKill[i]) and PED.IS_PED_DEAD_OR_DYING(toKill[i]) and KA_Delpeds then
                            entities.delete_by_handle(toKill[i])
                        end
                    else
                        local pedcoords = getEntityCoords(toKill[i])
                        if KA_Blame then
                            MISC.SHOOT_SINGLE_BULLET_BETWEEN_COORDS(pedcoords.x, pedcoords.y, pedcoords.z + 2, pedcoords.x, pedcoords.y, pedcoords.z, 1000, true, weaponhash, ourped, false, false, -1)
                        else
                            MISC.SHOOT_SINGLE_BULLET_BETWEEN_COORDS(pedcoords.x, pedcoords.y, pedcoords.z + 2, pedcoords.x, pedcoords.y, pedcoords.z, 1000, true, weaponhash, 0, false, false, -1)
                        end
                        wait(50)
                        if not PED.IS_PED_A_PLAYER(toKill[i]) and PED.IS_PED_DEAD_OR_DYING(toKill[i]) and KA_Delpeds then
                            entities.delete_by_handle(toKill[i])
                        end
                    end
                end
            end
        end
    end
    wait(100)
end)

local killAuraSettings = menu.list(mFunFeats, "KillAura Settings", {}, "Settings for the KillAura functionality.")
menu.divider(killAuraSettings, "KillAura Settings")

menu.slider(killAuraSettings, "KillAura Radius", {"karadius"}, "Radius for killaura.", 1, 100, 20, 1, function (value)
    KA_Radius = value
end)

menuToggle(killAuraSettings, "Blame Killaura on Me?", {"kablame"}, "If toggled off, bullets will not be blamed on you.", function (toggle)
    if toggle then
        KA_Blame = true
    else
        KA_Blame = false
    end
end, true)

menuToggle(killAuraSettings, "Target Players?", {"kaplayers"}, "If toggled off, will only target peds.", function (toggle)
    if toggle then
        KA_Players = true
        if KA_Onlyplayers then
            menu.trigger_commands("kaonlyplayers")
        end
    else
        KA_Players = false
    end
end)

menuToggle(killAuraSettings, "Target ONLY Players?", {"kaonlyplayers"}, "If toggled on, will target ONLY players.", function (toggle)
    if toggle then
        KA_Onlyplayers = true
        if KA_Players then
            menu.trigger_commands("kaplayers")
        end
    else
        KA_Onlyplayers = false
    end
end)

menuToggle(killAuraSettings, "Delete vehicles of peds?", {"kadelvehs"}, "If toggled on, will delete vehicles of non-player peds, which makes them easier to kill.", function (toggle)
    if toggle then
        KA_Delvehs = true
    else
        KA_Delvehs = false
    end
end)

menuToggle(killAuraSettings, "Delete peds after shooting?", {"kasilent"}, "If toggled on, will delete the peds that you have killed.", function (toggle)
    if toggle then
        KA_Delpeds = true
    else
        KA_Delpeds = false
    end
end)

menuToggleLoop(killAuraSettings, "Draw peds in radius", {"kadrawpeds"}, "If toggled on, will draw the number of peds in the selected radius. Does not need KillAura to be enabled.", function ()
    local dcount = 1
    local dtable = {}
    local ourcoords = getEntityCoords(getLocalPed())
    --
    local pedPointers = entities.get_all_peds_as_pointers()
    for i = 1, #pedPointers do
        local v3 = entities.get_position(pedPointers[i])
        local vdist = MISC.GET_DISTANCE_BETWEEN_COORDS(ourcoords.x, ourcoords.y, ourcoords.z, v3.x, v3.y, v3.z, true)
        if vdist <= KA_Radius then
            dtable[dcount] = entities.pointer_to_handle(pedPointers[i])
            dcount = dcount + 1
        end
    end
    local cc = {r = 1.0, g = 1.0, b = 1.0, a = 1.0}
    directx.draw_text(0.0, 0.11, "Peds in radius of >> " .. KA_Radius .. " << " .. #dtable, ALIGN_TOP_LEFT, 0.5, cc, false)
end)

menuAction(killAuraSettings, "Spawn test peds", {}, "", function ()
    local hash = joaat("G_M_M_ChiGoon_02")
    local coords = getEntityCoords(getLocalPed())
    requestModel(hash)
    while not hasModelLoaded(hash) do wait() end
    PED.CREATE_PED(24, hash, coords.x, coords.y, coords.z, 0, true, false)
    noNeedModel(hash)
end)

menuAction(killAuraSettings, "Populate the map.", {}, "After killing a bit too many peds, you can re-populate the map with this neat button. How cool!", function ()
    MISC.POPULATE_NOW()
end)

----------------------------------------------------------------------------------------------------

--[[
menu.divider(mFunFeats, "Crystal Aura")

CA_Radius = 20
CA_Players = false
CA_Blame = true
CA_audible = false
CA_invis = true
CA_delpeds = false
CA_delvehs = false

menuToggleLoop(mFunFeats, "CrystalAura", {"crystalaura"}, "Explodes peds, optionally players, optionally friends, in a radius. Optional invisibility and inaudibility is in settings.", function ()
    local tKCount = 1 -- count
    local toKill = {} -- table
    local ourcoords = getEntityCoords(getLocalPed()) -- our coords
    local ourped = getLocalPed() -- our ped (for blame)
    --
    local pedPointers = entities.get_all_peds_as_pointers()
    for i = 1, #pedPointers do
        local v3 = entities.get_position(pedPointers[i])
        local vdist = MISC.GET_DISTANCE_BETWEEN_COORDS(ourcoords.x, ourcoords.y, ourcoords.z, v3.x, v3.y, v3.z, true)
        if vdist <= CA_Radius then
            toKill[tKCount] = entities.pointer_to_handle(pedPointers[i])
            tKCount = tKCount + 1
        end
    end
    for i = 1, #toKill do
        if (not CA_Players and not PED.IS_PED_A_PLAYER(toKill[i])) or (CA_Players and PED.IS_PED_A_PLAYER(toKill[i])) then
            if not PED.IS_PED_DEAD_OR_DYING(toKill[i]) then
                local veh = PED.GET_VEHICLE_PED_IS_IN(toKill[i], false)
                if CA_delvehs and not PED.IS_PED_A_PLAYER(toKill[i]) then
                    entities.delete_by_handle(veh)
                end
                local entcoords = getEntityCoords(toKill[i])
                if CA_Blame then
                    SE_add_owned_explosion(ourped, entcoords.x, entcoords.y, entcoords.z, 2, 1, CA_audible, CA_invis, 0)
                else
                    SE_add_explosion(entcoords.x, entcoords.y, entcoords.z, 2, 1, CA_audible, CA_invis, 0, false)
                end
            end
            wait(50)
            if PED.IS_PED_DEAD_OR_DYING(toKill[i] and CA_delpeds) then
                entities.delete_by_handle(toKill[i])
            end
        end
    end
end)

local CA_settings = menu.list(mFunFeats, "Crystal Aura Settings", {}, "")

menu.slider(CA_settings, "Crystal Aura Radius", {"caradius"}, "Radius for Crystal Aura.", 1, 100, 20, 1, function (value)
    CA_Radius = value
end)

menuToggle(CA_settings, "Crystal Aura blames me?", {}, "Have the crystal aura blame you for explosions.", function (toggle)
    if toggle then
        CA_Blame = true
    else
        CA_Blame = false
    end
end, true)

--COMMENTED OUT UNTIL I CAN FIND A METHOD TO NOT TARGET MYSELF!
--[[menuToggle(CA_settings, "Crystal Aura targets players?", {}, "Enabling targetting players.", function (toggle)
    if toggle then
        CA_Players = true
    else
        CA_Players = false
    end
end)

menuToggle(CA_settings, "Crystal Aura heard?", {}, "Makes the explosions heard/audible.", function (toggle)
    if toggle then
        CA_audible = true
    else
        CA_audible = false
    end
end)

menuToggle(CA_settings, "Crystal Aura invisible?", {}, "Makes the explosions invisible.", function (toggle)
    if toggle then
        CA_invis = true
    else
        CA_invis = false
    end
end, true)

menuToggle(CA_settings, "Delete peds after killing?", {}, "Makes the peds get deleted after they die.", function (toggle)
    if toggle then
        CA_delpeds = true
    else
        CA_delpeds = false
    end
end)

menuToggle(CA_settings, "Delete cars of peds?", {}, "Makes the peds' cars get delted.", function (toggle)
    if toggle then
        CA_delvehs = true
    else
        CA_delvehs = false
    end
end)

]]
----------------------------------------------------------------------------------------------------

menu.divider(mFunFeats, "PvP / PvE Helper")
local pvphelp = menu.list(mFunFeats, "PvP / PvE Helper", {"pvphelp"}, "")

--preload
AIM_Spine2 = false
AIM_Toe0 = false
AIM_Pelvis = false
AIM_Head = false
AIM_RHand = false
----
AIM_FOV = 1
AIM_Dist = 300
AIM_DMG = 30
----
LOS_CHECK = true
FOV_CHECK = true
--
AIM_WHITELIST = {}
AIM_NPCS = false
--
AIM_LEGITSILENT = true
AIM_HEADVEH = false

menu.divider(pvphelp, "Silent Aimbot")

menuToggleLoop(pvphelp, "Silent Aimbot", {"silentaim", "saimbot"}, "A silent aimbot with bone selection.", function ()
    local ourped = getLocalPed()
    if PED.IS_PED_SHOOTING(ourped) then
        local ourc = getEntityCoords(ourped)
        local entTable = entities.get_all_peds_as_pointers()
        local inRange = {}
        local inCount = 1
        for i = 1, #entTable do
            local ed = entities.get_position(entTable[i])
            local entdist = distanceBetweenTwoCoords(ourc, ed)
            if entdist < AIM_Dist + 1 then
                local handle = entities.pointer_to_handle(entTable[i])
                if handle ~= getLocalPed() then
                    inRange[inCount] = handle
                    inCount = inCount + 1
                end
            end
        end
        local weaponHash = 177293209 --heavy sniper mk2 hash
        local bulletSpeed = 1000
        --util.toast("Entities in range of // " .. AIM_Dist .. " // :" .. #inRange)
        for i = 1, #inRange do
            local coord = getEntityCoords(inRange[i])
            if (PED.IS_PED_A_PLAYER(inRange[i]) and not AIM_NPCS) or (not PED.IS_PED_A_PLAYER(inRange[i]) and AIM_NPCS) then --check if player
                if not PED.IS_PED_DEAD_OR_DYING(inRange[i], 1) then --check for dead/dying
                    if (ENTITY.HAS_ENTITY_CLEAR_LOS_TO_ENTITY(ourped, inRange[i], 17) and LOS_CHECK == true) or (LOS_CHECK == false) then --check if we have line of sight
                        if (PED.IS_PED_FACING_PED(ourped, inRange[i], AIM_FOV) and FOV_CHECK == true) or (FOV_CHECK == false) then --check for FOV
                            if not AIM_WHITELIST[NETWORK.NETWORK_GET_PLAYER_INDEX_FROM_PED(inRange[i])] then --check if PID doesn't match the whitelist
                                if distanceBetweenTwoCoords(coord, getEntityCoords(ourped)) < 401 and AIM_LEGITSILENT and ENTITY.HAS_ENTITY_CLEAR_LOS_TO_ENTITY(ourped, inRange[i], 17) then --check if they're less than 401 meters away (hitscan), and in LOS
                                    --shooting done here, we have all preloads
                                    local playerID = NETWORK.NETWORK_GET_PLAYER_INDEX_FROM_PED(inRange[i])
                                    local playerName = NETWORK.NETWORK_PLAYER_GET_NAME(playerID)
                                    local pveh = PED.GET_VEHICLE_PED_IS_IN(inRange[i], false)
                                    if SE_Notifications then
                                        util.toast("Targeted: " .. tostring(playerName) .. " with Legit Aim")
                                    end
                                    local forwardOffset = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(ourped, 0, 1, 2)
                                    if AIM_Head then
                                        local bonec = PED.GET_PED_BONE_COORDS(inRange[i], 12844, 0, 0, 0)
                                        MISC.SHOOT_SINGLE_BULLET_BETWEEN_COORDS_IGNORE_ENTITY(forwardOffset.x, forwardOffset.y, forwardOffset.z, bonec.x, bonec.y, bonec.z, AIM_DMG, true, weaponHash, getLocalPed(), true, false, bulletSpeed, pveh, true)
                                    elseif not AIM_HEAD and AIM_HEADVEH and PED.IS_PED_IN_ANY_VEHICLE(inRange[i], false) then --check for "target head if target in is vehicle"
                                        util.toast("VehChecked " .. tostring(playerName))
                                        local bonec = PED.GET_PED_BONE_COORDS(inRange[i], 12844, 0, 0, 0)
                                        MISC.SHOOT_SINGLE_BULLET_BETWEEN_COORDS_IGNORE_ENTITY(forwardOffset.x, forwardOffset.y, forwardOffset.z, bonec.x, bonec.y, bonec.z, AIM_DMG, true, weaponHash, getLocalPed(), true, false, bulletSpeed, pveh, true)
                                    end
                                    if AIM_Spine2 then
                                        --(​Ped ped, int boneId, float offsetX, float offsetY, float offsetZ)
                                        local bonec = PED.GET_PED_BONE_COORDS(inRange[i], 24817, 0, 0, 0)
                                        MISC.SHOOT_SINGLE_BULLET_BETWEEN_COORDS_IGNORE_ENTITY(forwardOffset.x, forwardOffset.y, forwardOffset.z, bonec.x, bonec.y, bonec.z, AIM_DMG, true, weaponHash, getLocalPed(), true, false, bulletSpeed, pveh, true)
                                    end
                                    if AIM_Pelvis then
                                        local bonec = PED.GET_PED_BONE_COORDS(inRange[i], 11816, 0, 0, 0)
                                        MISC.SHOOT_SINGLE_BULLET_BETWEEN_COORDS_IGNORE_ENTITY(forwardOffset.x, forwardOffset.y, forwardOffset.z, bonec.x, bonec.y, bonec.z, AIM_DMG, true, weaponHash, getLocalPed(), true, false, bulletSpeed, pveh, true)
                                    end
                                    if AIM_Toe0 then
                                        local bonec = PED.GET_PED_BONE_COORDS(inRange[i], 20781, 0, 0, 0)
                                        MISC.SHOOT_SINGLE_BULLET_BETWEEN_COORDS_IGNORE_ENTITY(forwardOffset.x, forwardOffset.y, forwardOffset.z, bonec.x, bonec.y, bonec.z, AIM_DMG, true, weaponHash, getLocalPed(), true, false, bulletSpeed, pveh, true)
                                    end
                                    if AIM_RHand then
                                        local bonec = PED.GET_PED_BONE_COORDS(inRange[i], 6286, 0, 0, 0)
                                        MISC.SHOOT_SINGLE_BULLET_BETWEEN_COORDS_IGNORE_ENTITY(forwardOffset.x, forwardOffset.y, forwardOffset.z, bonec.x, bonec.y, bonec.z, AIM_DMG, true, weaponHash, getLocalPed(), true, false, bulletSpeed, pveh, true)
                                    end
                                else
                                    --shooting done here, we have all preloads
                                    local playerID = NETWORK.NETWORK_GET_PLAYER_INDEX_FROM_PED(inRange[i])
                                    local playerName = NETWORK.NETWORK_PLAYER_GET_NAME(playerID)
                                    local pveh = PED.GET_VEHICLE_PED_IS_IN(inRange[i], false)
                                    if SE_Notifications then
                                        util.toast("Targeted: " .. tostring(playerName))
                                    end
                                    local forwardOffset = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(inRange[i], 0, 1, 1)
                                    if AIM_Head then
                                        local bonec = PED.GET_PED_BONE_COORDS(inRange[i], 12844, 0, 0, 0)
                                        MISC.SHOOT_SINGLE_BULLET_BETWEEN_COORDS_IGNORE_ENTITY(forwardOffset.x, forwardOffset.y, forwardOffset.z, bonec.x, bonec.y, bonec.z, AIM_DMG, true, weaponHash, getLocalPed(), true, false, bulletSpeed, pveh, true)
                                    elseif not AIM_HEAD and AIM_HEADVEH and PED.IS_PED_IN_ANY_VEHICLE(inRange[i], false) then
                                        util.toast("VehChecked " .. tostring(playerName))
                                        local bonec = PED.GET_PED_BONE_COORDS(inRange[i], 12844, 0, 0, 0)
                                        MISC.SHOOT_SINGLE_BULLET_BETWEEN_COORDS_IGNORE_ENTITY(forwardOffset.x, forwardOffset.y, forwardOffset.z, bonec.x, bonec.y, bonec.z, AIM_DMG, true, weaponHash, getLocalPed(), true, false, bulletSpeed, pveh, true)
                                    end
                                    if AIM_Spine2 then
                                        --(​Ped ped, int boneId, float offsetX, float offsetY, float offsetZ)
                                        local bonec = PED.GET_PED_BONE_COORDS(inRange[i], 24817, 0, 0, 0)
                                        MISC.SHOOT_SINGLE_BULLET_BETWEEN_COORDS_IGNORE_ENTITY(forwardOffset.x, forwardOffset.y, forwardOffset.z, bonec.x, bonec.y, bonec.z, AIM_DMG, true, weaponHash, getLocalPed(), true, false, bulletSpeed, pveh, true)
                                    end
                                    if AIM_Pelvis then
                                        local bonec = PED.GET_PED_BONE_COORDS(inRange[i], 11816, 0, 0, 0)
                                        MISC.SHOOT_SINGLE_BULLET_BETWEEN_COORDS_IGNORE_ENTITY(forwardOffset.x, forwardOffset.y, forwardOffset.z, bonec.x, bonec.y, bonec.z, AIM_DMG, true, weaponHash, getLocalPed(), true, false, bulletSpeed, pveh, true)
                                    end
                                    if AIM_Toe0 then
                                        local bonec = PED.GET_PED_BONE_COORDS(inRange[i], 20781, 0, 0, 0)
                                        MISC.SHOOT_SINGLE_BULLET_BETWEEN_COORDS_IGNORE_ENTITY(forwardOffset.x, forwardOffset.y, forwardOffset.z, bonec.x, bonec.y, bonec.z, AIM_DMG, true, weaponHash, getLocalPed(), true, false, bulletSpeed, pveh, true)
                                    end
                                    if AIM_RHand then
                                        local bonec = PED.GET_PED_BONE_COORDS(inRange[i], 6286, 0, 0, 0)
                                        MISC.SHOOT_SINGLE_BULLET_BETWEEN_COORDS_IGNORE_ENTITY(forwardOffset.x, forwardOffset.y, forwardOffset.z, bonec.x, bonec.y, bonec.z, AIM_DMG, true, weaponHash, getLocalPed(), true, false, bulletSpeed, pveh, true)
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end
end)

local silentAimSettings = menu.list(pvphelp, "Silent Aim Settings", {}, "")

menu.slider(silentAimSettings, "Silent Aimbot Damage", {"silentaimdamage", "silentdamage", "saimdamage"}, "The amount of damage Silent Aimbot does. Not accurate, sadly...", 1, 10000, 30, 10, function(value)
    AIM_DMG = value
end)

menu.slider(silentAimSettings, "Silent Aimbot Range", {"silentaimrange", "silentrange", "saimrange"}, "Silent Aimbot Range", 1, 10000, 300, 1, function (value)
    AIM_Dist = value
end)

menu.slider(silentAimSettings, "Silent Aimbot FOV", {"silentaimfov", "silentfov", "saimfov"}, "The FOV of which players can be targeted. (divided by 10)", 1, 2700, 1, 10, function (value)
    AIM_FOV = value / 10
end)

menuToggle(silentAimSettings, "Vehicle Mode", {"silentaimvehicle", "silentvehice", "saveh"}, "Removes line-of-sight checks. Done to make silent aim work for vehicles. Please do note that the FOV is taken FROM THE VEHICLE, NOT FROM WHERE YOU ARE FACING.", function (on)
    if on then
        LOS_CHECK = false
    else
        LOS_CHECK = true
    end
end)

menuToggle(silentAimSettings, "Legit Silent Aim", {"silentlegit"}, "If you have Line-of-Sight, attempts to shoot a bullet from you to the player. Doesn't always work if they're moving too fast.", function (on)
    if on then
        AIM_LEGITSILENT = true
    else
        AIM_LEGITSILENT = false
    end
end, true)

menuToggle(silentAimSettings, "Vehicle-Head Check", {"silentcheckveh"}, "Will check if the selected player is in a vehicle. If they are in a vehicle, and HEAD isn't selected, will target their head automatically to increase chances of killing.", function (on)
    if on then
        AIM_HEADVEH = true
    else
        AIM_HEADVEH = false
    end
end)

menuToggle(silentAimSettings, "Target ONLY NPCs", {"silentnpc"}, "Toggle this to ONLY silent aimbot NPCs. Toggle off for ONLY players.", function (on)
    if on then
        AIM_NPCS = true
    else
        AIM_NPCS = false
    end
end)

menu.divider(silentAimSettings, "-----------------")

menuToggle(silentAimSettings, "Silent Aimbot Head", {"silentaimhead", "silenthead", "saimhead"}, "Makes the aimbot target the head. Probably doesn't look legitimate, but ok.", function(on)
    if on then
        AIM_Head = true
    else
        AIM_Head = false
    end
end)

menuToggle(silentAimSettings, "Silent Aimbot Body (Spine2)", {"silentaimspine2", "silentspine2", "saimspine2"}, "Makes the aimbot target the body, also known as spine2.", function(on)
    if on then
        AIM_Spine2 = true
    else
        AIM_Spine2 = false
    end
end)

menuToggle(silentAimSettings, "Silent Aimbot Pelvis", {"silentaimpelvis", "silentpelvis", "saimpelvis"}, "Makes the aimbot target the pelvis.", function (on)
    if on then
        AIM_Pelvis = true
    else
        AIM_Pelvis = false
    end
end)

menuToggle(silentAimSettings, "Silent Aimbot Toe (Toe0)", {"silentaimtoe", "silenttoe", "saimtoe"}, "Makes the aimbot target the toe, otherwise known as toe0", function (on)
    if on then
        AIM_Toe0 = true
    else
        AIM_Toe0 = false
    end
end)

menuToggle(silentAimSettings, "Silent Aimbot Hand (R_HAND)", {"silentaimhand", "silenthand", "saimhand"}, "Makes the aimbot target the hand, otherwise known as R_Hand", function (on)
    if on then
        AIM_RHand = true
    else
        AIM_RHand = false
    end
end)

--GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS --for shooting the kneecaps
--https://wiki.gtanet.work/index.php?title=Bones
--IK_Head 	12844
--SKEL_Spine2 	24817
--SKEL_Pelvis 	11816
--SKEL_R_Toe0 	20781
--IK_R_Hand 	6286


----------------------------------------------------------------------------------------------------

menu.divider(pvphelp, "Vehicle Aimbot (experimental)")

--[[ ugh, deprecated. I wasted an hour of my life on this goddamn bruh moment.
menuToggleLoop(pvphelp, "Vehicle Aimbot Toggle", {}, "", function ()
    local p = getClosestPlayerWithRange(200) --get closest player within 200 meters
    local localped = getLocalPed()
    local localCoords = getEntityCoords(localped)
    if p ~= nil then --if the player isn't NIL
        local pcoords = getEntityCoords(p)
        local bottomlength = MISC.GET_DISTANCE_BETWEEN_COORDS(localCoords.x, localCoords.y, localCoords.z, pcoords.x, pcoords.y, pcoords.z, false) --by setting BOOL useZ to false, we get only the 2d plane. (later used in tangent)
        local toplength = pcoords.z - localCoords.z
        if ENTITY.HAS_ENTITY_CLEAR_LOS_TO_ENTITY(localped, p, 17) then
            local pitch = math.atan(bottomlength, toplength)
            -- local yaw = 
        end
    end
end)]]

--TYSM NOWIRY AND AARON!

local function setVehicleMissileSpeed(value)
    local offsets = {0x10D8, 0x70, 0x60, 0x58}
    local addr = entities.handle_to_pointer(PLAYER.PLAYER_PED_ID())
    for i = 1, (#offsets - 1) do
        -- make sure not to read from/write to a null pointer
        if addr == 0 then
            -- got a null pointer at some point
            return -1.0
        end
        addr = memory.read_long(addr + offsets[i])
    end
    addr = addr + offsets[#offsets]
    
    if addr == 0 then
        return -1.0
    else
        memory.write_float(addr, value)
        --memory.read_float(addr)
    end
end

function GetVehicleMissileSpeed()
    local offsets = {0x10D8, 0x70, 0x60, 0x58}
    local addr = entities.handle_to_pointer(PLAYER.PLAYER_PED_ID())
    for i = 1, (#offsets - 1) do
        -- make sure not to read from/write to a null pointer
        if addr == 0 then
            -- got a null pointer at some point
            return -1.0
        end
        addr = memory.read_long(addr + offsets[i])
    end
    addr = addr + offsets[#offsets]
    
    if addr == 0 then
        return -1.0
    else
        return memory.read_float(addr)
    end
end

VEH_MISSILE_SPEED = 10000

menuToggleLoop(pvphelp, "Helicopter Aimbot", {}, "Makes the heli aim at the closest player. Combine this with 'silent aimbot' for it to look like you're super good :)", function ()
    local p = getClosestPlayerWithRange(200)
    local localped = getLocalPed()
    local localCoords = getEntityCoords(localped)
    if p ~= nil and not PED.IS_PED_DEAD_OR_DYING(p) and ENTITY.HAS_ENTITY_CLEAR_LOS_TO_ENTITY(localped, p, 17) and not AIM_WHITELIST[NETWORK.NETWORK_GET_PLAYER_INDEX_FROM_PED(p)] then
        if PED.IS_PED_IN_ANY_VEHICLE(localped) then
            local veh = PED.GET_VEHICLE_PED_IS_IN(localped, false)
            if VEHICLE.GET_VEHICLE_CLASS(veh) == 15 or VEHICLE.GET_VEHICLE_CLASS(veh) == 16 then --vehicle class of heli
                --did all prechecks, time to actually face them
                local pcoords = PED.GET_PED_BONE_COORDS(p, 24817, 0, 0, 0)
                local look = util.v3_look_at(localCoords, pcoords) --x = pitch (vertical), y = roll (fuck no), z = heading (horizontal)
                ENTITY.SET_ENTITY_ROTATION(veh, look.x, look.y, look.z, 1, true)
            end
        end
    end
end)

menuAction(pvphelp, "Modify Missile Speed", {}, "Thank you so much Nowiry for this.", function ()
    local localped = getLocalPed()
    if PED.IS_PED_IN_ANY_VEHICLE(localped) then
        local veh = PED.GET_VEHICLE_PED_IS_IN(localped, false)
        if VEHICLE.GET_VEHICLE_CLASS(veh) == 15 or VEHICLE.GET_VEHICLE_CLASS(veh) == 16 then --vehicle class of heli
            setVehicleMissileSpeed(VEH_MISSILE_SPEED)
        end
    end
end)

menu.slider(pvphelp, "Set missile speed", {"vehmissilespeed"}, "Sets the speed of your missiles.", 1, 2147483647, 10000, 100, function (value)
    VEH_MISSILE_SPEED = value
end)

----------------------------------------------------------------------------------------------------

menu.divider(pvphelp, "RPG Aimbot")

MISL_FRC = false
MISL_RAD = 300
MISL_SPD = 100
MISL_LOS = true

--Later: block rockets (spawn walls when detecting they are in range)

menu.toggle(pvphelp, "RPG Aimbot / Most Vehicles", {"rpgaim"}, "You heard me. Only the REGULAR RPG, not the homing one. Works on vehicles as well, such as Lazer or Buzzard. No guarantees, though!", function (on)
    if on then
        MISL_FRC = true
        local rockethash = util.joaat("w_lr_rpg_rocket")
        util.create_thread(function()
            while MISL_FRC do
                local localped = getLocalPed()
                local localcoords = getEntityCoords(getLocalPed())
                RRocket = OBJECT.GET_CLOSEST_OBJECT_OF_TYPE(localcoords.x, localcoords.y, localcoords.z, 10, rockethash, false, true, true, true)
                local p = getClosestPlayerWithRange(MISL_RAD)
                ----
                if (RRocket ~= 0) and (p ~= nil) and (not PED.IS_PED_DEAD_OR_DYING(p)) and (not AIM_WHITELIST[NETWORK.NETWORK_GET_PLAYER_INDEX_FROM_PED(p)]) and (PED.IS_PED_SHOOTING(localped)) then
                    if (ENTITY.HAS_ENTITY_CLEAR_LOS_TO_ENTITY(localped, p, 17) and MISL_LOS) or not MISL_LOS then
                        if SE_Notifications then
                            util.toast("Precusors done!")
                        end
                        NETWORK.NETWORK_REQUEST_CONTROL_OF_ENTITY(RRocket)
                        if not NETWORK.NETWORK_HAS_CONTROL_OF_ENTITY(RRocket) then
                            for i = 1, 10 do
                                NETWORK.NETWORK_REQUEST_CONTROL_OF_ENTITY(RRocket)
                            end
                        else
                            if SE_Notifications then
                                util.toast("has control")
                            end
                        end
                        while ENTITY.DOES_ENTITY_EXIST(RRocket) do
                            if SE_Notifications then
                                util.toast("rocket exists")
                            end
                            local pcoords = PED.GET_PED_BONE_COORDS(p, 20781, 0, 0, 0)
                            local lc = getEntityCoords(RRocket)
                            local look = util.v3_look_at(lc, pcoords)
                            local dir = util.rot_to_dir(look)
                            ENTITY.APPLY_FORCE_TO_ENTITY_CENTER_OF_MASS(RRocket, 1, dir.x * MISL_SPD, dir.y * MISL_SPD, dir.z * MISL_SPD, true, false, true, true)
                            wait()
                        end
                        --do code here, all precursors done.
                    end
                end
                wait()
            end
        end)
    else
        MISL_FRC = false
    end
end)

menu.slider(pvphelp, "RPG Aimbot Radius", {"msl_frc_rad"}, "Range for missile aimbot, e.g. how far the person can be away.", 1, 10000, 300, 10, function (value)
    MISL_RAD = value
end)

menu.slider(pvphelp, "RPG Speed Multiplier", {"msl_spd_mult"}, "Multiplier for speed. Default is 100, it's good.", 1, 10000, 100, 100, function (value)
    MISL_SPD = value
end)

menuToggle(pvphelp, "RPG LOS Remove", {}, "Removes line-of-sight checks. Do not turn this on unless you know what you're doing.", function (on)
    if on then
        MISL_LOS = false
    else
        MISL_LOS = true
    end
end)

----------------------------------------------------------------------------------------------------

menu.divider(pvphelp, "Orbital Waypoint")

--preload
ORB_Sneaky = false

menuAction(pvphelp, "Orbital Strike Waypoint", {"orbway", "orbwp"}, "Orbital Cannons your selected Waypoint.", function ()
    local wpos = get_waypoint_pos2()
    if SE_Notifications then
        util.toast("Selected Waypoint Coordinates: " .. wpos.x .. " " .. wpos.y .. " " .. wpos.z)
    end
    if ORB_Sneaky then
        for a = 1, 30 do
            SE_add_explosion(wpos.x, wpos.y, wpos.z + 30 - a, 29, 10, true, false, 1, false)
            SE_add_explosion(wpos.x, wpos.y, wpos.z + 30 - a, 59, 10, true, false, 1, false)
            wait(30)
        end
    else
        for i = 1, 30 do
            SE_add_owned_explosion(getLocalPed(), wpos.x, wpos.y, wpos.z + 30 - i, 29, 10, true, false, 1)
            SE_add_owned_explosion(getLocalPed(), wpos.x, wpos.y, wpos.z + 30 - i, 59, 10, true, false, 1)
            wait(30)
        end
    end
end)

menuToggle(pvphelp, "Sneaky Explosion", {}, "Makes the orbital not blamed on you.", function (on)
    if on then
        ORB_Sneaky = true
    else
        ORB_Sneaky = false
    end
end)

----------------------------------------------------------------------------------------------------

menu.divider(pvphelp, "Auto Car-Suicide")

--preload
CAR_S_sneaky = false
CAR_S_BLACKLIST = {}

menuToggleLoop(pvphelp, "Auto Car-Suicide", {"carexplode"}, "Automatically explodes your car when you are next to a player.", function()
    local ourped = getLocalPed()
    if PED.IS_PED_IN_ANY_VEHICLE(ourped, false) then
        local pedTable = entities.get_all_peds_as_pointers()
        local ourCoords = getEntityCoords(ourped)
        for i = 1, #pedTable do
            local handle = entities.pointer_to_handle(pedTable[i])
            if PED.IS_PED_A_PLAYER(handle) then
                local playerID = NETWORK.NETWORK_GET_PLAYER_INDEX_FROM_PED(handle)
                local v3 = entities.get_position(pedTable[i])
                local dist = distanceBetweenTwoCoords(ourCoords, v3)
                if dist < 5 and handle ~= getLocalPed() and not CAR_S_BLACKLIST[playerID] then
                    if CAR_S_sneaky then
                        SE_add_explosion(ourCoords.x, ourCoords.y, ourCoords.z, 2, 10, true, false, 0.1, false)
                        SE_add_explosion(ourCoords.x - 4, ourCoords.y, ourCoords.z, 2, 20, false, true, 0.1, false)
                        SE_add_explosion(ourCoords.x + 4, ourCoords.y, ourCoords.z, 2, 20, false, true, 0.1, false)
                        SE_add_explosion(ourCoords.x, ourCoords.y - 4, ourCoords.z, 2, 20, false, true, 0.1, false)
                        SE_add_explosion(ourCoords.x, ourCoords.y + 4, ourCoords.z, 2, 20, false, true, 0.1, false)
                    else
                        SE_add_owned_explosion(ourped, ourCoords.x, ourCoords.y, ourCoords.z, 2, 10, true, false, 0.1)
                        SE_add_owned_explosion(ourped, ourCoords.x - 4, ourCoords.y, ourCoords.z, 2, 20, false, true, 0.1)
                        SE_add_owned_explosion(ourped, ourCoords.x + 4, ourCoords.y, ourCoords.z, 2, 20, false, true, 0.1)
                        SE_add_owned_explosion(ourped, ourCoords.x, ourCoords.y - 4, ourCoords.z, 2, 20, false, true, 0.1)
                        SE_add_owned_explosion(ourped, ourCoords.x, ourCoords.y + 4, ourCoords.z, 2, 20, false, true, 0.1)
                    end
                end
            end
        end
    end
end)

menuToggle(pvphelp, "Car Suicide Sneaky", {"carexplodesneaky"}, "Makes the explosion of the car bomb not blamed on you.", function(on)
    if on then
        CAR_S_sneaky = true
    else
        CAR_S_sneaky = false
    end
end)

-----------------------------------------------------------------------------------------------------------------------------------

local debugFeats = menu.list(menuroot, "Debug Features", {}, "")

menuAction(debugFeats, "Get V3 Coords", {"printcoords"}, "Toasts your coordinates.", function()
    local playerCoords = getEntityCoords(getPlayerPed(players.user()), true)
    if SE_Notifications then
        util.toast("X:" .. tostring(playerCoords['x']) .. " Y:".. tostring(playerCoords['y']) .. " Z:" ..tostring(playerCoords['z']))
    end
end)

menuToggleLoop(debugFeats, "Request Control?", {}, "", function ()
    ::start::
    local localPed = getLocalPed()
    if PED.IS_PED_SHOOTING(localPed) then
        local contr = memory.alloc(4)
        local isEntFound = PLAYER.GET_ENTITY_PLAYER_IS_FREE_AIMING_AT(players.user(), contr)
        if isEntFound then
            local ent = memory.read_int(contr)
            local wascoord = getEntityCoords(ent)
            NETWORK.NETWORK_REQUEST_CONTROL_OF_ENTITY(ent)
            ENTITY.SET_ENTITY_COORDS_NO_OFFSET(ent, 1000, 1000, 1000, true, true, true)
            wait(100)
            ENTITY.SET_ENTITY_COORDS_NO_OFFSET(ent, wascoord.x, wascoord.y, wascoord.z, true, true, true)
            if not NETWORK.NETWORK_HAS_CONTROL_OF_ENTITY(ent) then
                for i = 1, 20, 1 do
                    NETWORK.NETWORK_REQUEST_CONTROL_OF_ENTITY(ent)
                    wait(100) 
                end
            end
            if not NETWORK.NETWORK_HAS_CONTROL_OF_ENTITY(ent) then util.toast("Waited 2 seconds, couldn't get control!") goto start end
            util.toast("Has control!")
        end
        memory.free(contr)
    end
end)


menuToggleLoop(debugFeats, "Get V3 Of Entity", {"entcoords"}, "Toasts the coodinates of the entity you shoot.", function ()
    local pp = getLocalPed()
    if PED.IS_PED_SHOOTING(pp) then
        local pointer = memory.alloc(4)
        local found = PLAYER.GET_ENTITY_PLAYER_IS_FREE_AIMING_AT(players.user(), pointer)
        if found then
            local v3coords = getEntityCoords(memory.read_int(pointer))
            util.toast(v3coords.x .. " " .. v3coords.y .. " " .. v3coords.z)
        end
        memory.free(pointer)
    end
end)

menuAction(debugFeats, "Get Heading", {}, "", function ()
    local pp = getLocalPed()
    util.toast(ENTITY.GET_ENTITY_HEADING(pp))
end)

--[[menuAction(debugFeats, "BLOCK TESTING", {}, "", function ()
    local hash = 309416120
    requestModel(hash)
    while not hasModelLoaded(hash) do wait() end

    local a1 = OBJECT.CREATE_OBJECT_NO_OFFSET(hash, 1182, 2650, 37, true, true, true)
    ENTITY.SET_ENTITY_HEADING(a1, 88+180)

    local b1 = OBJECT.CREATE_OBJECT_NO_OFFSET(hash, 1176, 2650, 37, true, true, true)
    ENTITY.SET_ENTITY_HEADING(b1, 88+180)

    local c1 = OBJECT.CREATE_OBJECT_NO_OFFSET(hash, 1185, 2647, 37, true, true, true)
    ENTITY.SET_ENTITY_HEADING(c1, 182)

    local d1 = OBJECT.CREATE_OBJECT_NO_OFFSET(hash, 1172, 2646, 37, true, true, true)
    ENTITY.SET_ENTITY_HEADING(d1, 2)

    --

    local a1_2 = OBJECT.CREATE_OBJECT_NO_OFFSET(hash, 1182, 2650, 39, true, true, true)
    ENTITY.SET_ENTITY_HEADING(a1_2, 88+180)

    local b1_2 = OBJECT.CREATE_OBJECT_NO_OFFSET(hash, 1176, 2650, 39, true, true, true)
    ENTITY.SET_ENTITY_HEADING(b1_2, 88+180)

    local c1_2 = OBJECT.CREATE_OBJECT_NO_OFFSET(hash, 1185, 2647, 39, true, true, true)
    ENTITY.SET_ENTITY_HEADING(c1_2, 182)

    local d1_2 = OBJECT.CREATE_OBJECT_NO_OFFSET(hash, 1172, 2646, 39, true, true, true)
    ENTITY.SET_ENTITY_HEADING(d1_2, 2)

    noNeedModel(hash)
end)]]

menuToggleLoop(debugFeats, "Get player name from shot", {}, "", function ()
    local pped = getPlayerPed(players.user())
    if PED.IS_PED_SHOOTING(pped) then
        local playerPointer = memory.alloc(4)
        local isEntFound = PLAYER.GET_ENTITY_PLAYER_IS_FREE_AIMING_AT(players.user(), playerPointer)
        if isEntFound then
            util.toast("Entity found!")
            local playerHandle = memory.read_int(playerPointer)
            if ENTITY.IS_ENTITY_A_PED(playerHandle) then
                util.toast("Is a ped!")
                util.toast(tostring(playerHandle))
                if PED.IS_PED_A_PLAYER(playerHandle) then
                    util.toast("Is a player!")
                    local playerID = NETWORK.NETWORK_GET_PLAYER_INDEX_FROM_PED(playerHandle)
                    util.toast(playerID .. " is their playerID!")
                    local playerName = NETWORK.NETWORK_PLAYER_GET_NAME(playerID)
                    util.toast(playerName .. " is their name!")
                end
            end
        end
    end
end)

local toolFeats = menu.list(menuroot, "Tools", {}, "")

menuAction(toolFeats, "Teleport high up", {"tphigh"}, "Teleports you very high up, for testing parachutes/falldamage.", function ()
    local pcoords = getEntityCoords(getLocalPed())
    ENTITY.SET_ENTITY_COORDS_NO_OFFSET(getLocalPed(), pcoords.x, pcoords.y, pcoords.z + 1000, false, false, false)
end)

--preload
DR_TXT_SCALE = 0.5


menuToggleLoop(toolFeats, "Draw position", {"drawpos"},  "", function ()
    local pos = getEntityCoords(getLocalPed())
    local cc = {r = 1.0, g = 1.0, b = 1.0, a = 1.0}
    directx.draw_text(0.0, 0.0, "x: " .. pos.x .. " // y: " .. pos.y .. " // z: " .. pos.z, ALIGN_TOP_LEFT, DR_TXT_SCALE, cc, false)
end)

--preload
EP_drawveh = true
EP_drawped = true
EP_drawobj = true
EP_drawpick = true
----
EPS_vehx = 0.0
EPS_vehy = 0.03
--
EPS_pedx = 0.0
EPS_pedy = 0.05
--
EPS_objx = 0.0
EPS_objy = 0.07
--
EPS_pickx = 0.0
EPS_picky = 0.09
--

menuToggleLoop(toolFeats, "Draw Entity Pool", {"drawentpool"}, "", function ()
    local cc = {r = 1.0, g = 1.0, b = 1.0, a = 1.0}
    if EP_drawveh then
        local vehpool = entities.get_all_vehicles_as_pointers()
        directx.draw_text(EPS_vehx, EPS_vehy, "vehicles: " .. #vehpool, ALIGN_TOP_LEFT, DR_TXT_SCALE, cc, false)
    end
    if EP_drawped then
        local pedpool = entities.get_all_peds_as_pointers()
        directx.draw_text(EPS_pedx, EPS_pedy, "peds: " .. #pedpool, ALIGN_TOP_LEFT, DR_TXT_SCALE, cc, false)
    end
    if EP_drawobj then
        local objpool = entities.get_all_objects_as_pointers()
        directx.draw_text(EPS_objx, EPS_objy, "objects: " .. #objpool, ALIGN_TOP_LEFT, DR_TXT_SCALE, cc, false)
    end
    if EP_drawpick then
        local pickpool = entities.get_all_pickups_as_pointers()
        directx.draw_text(EPS_pickx, EPS_picky, "pickups: " .. #pickpool, ALIGN_TOP_LEFT, DR_TXT_SCALE, cc, false)
    end
end)

local ePS = menu.list(toolFeats, "Entity Pool Settings", {}, "")
menuToggle(ePS, "Draw Vehicles?", {}, "", function (toggle)
    if toggle then
        EP_drawveh = true
    else
        EP_drawveh = false
    end
end, true)
menu.slider(ePS, "Vehicle Text Placement X", {"epvehposx"}, "/100", 0, 100, 0, 1, function (value)
    EPS_vehx = value / 100
end) 
menu.slider(ePS, "Vehicle Text Placement Y", {"epvehposy"}, "/100", 0, 100, 3, 1, function (value)
    EPS_vehy = value / 100
end)
menuToggle(ePS, "Draw Peds?", {}, "", function (toggle)
    if toggle then 
        EP_drawped = true
    else
        EP_drawped = false
    end
end, true)
menu.slider(ePS, "Ped Text Placement X", {"eppedposx"}, "/100", 0, 100, 0, 1, function (value)
    EPS_pedx = value / 100
end)
menu.slider(ePS, "Ped Text Placement Y", {"eppedposy"}, "/100", 0, 100, 5, 1, function (value)
    EPS_pedy = value / 100
end)
menuToggle(ePS, "Draw Objects?", {}, "", function (toggle)
    if toggle then
        EP_drawobj = true
    else
        EP_drawobj = false
    end
end, true)
menu.slider(ePS, "Object Text Placement X", {"epobjposx"}, "/100", 0, 100, 0, 1, function (value)
    EPS_objx = value / 100
end)
menu.slider(ePS, "Object Text Placement Y", {"epobjposy"}, "/100", 0, 100, 7, 1, function (value)
    EPS_objy = value / 100
end)
menuToggle(ePS, "Draw Pickups?", {}, "", function (toggle)
    if toggle then
        EP_drawpick = true
    else
        EP_drawpick = false
    end
end, true)
menu.slider(ePS, "Pickups Text Placement X", {"epickjposx"}, "/100", 0, 100, 0, 1, function (value)
    EPS_pickx = value / 100
end)
menu.slider(ePS, "Pickups Text Placement Y", {"epickjposy"}, "/100", 0, 100, 9, 1, function (value)
    EPS_picky = value / 100
end)

menu.divider(toolFeats, "Settings")
menu.slider(toolFeats, "Text Size (/10)", {"drscale"}, "Sets the scale of the text to the value you assign, divided by 10. This is because it only takes integer values.", 1, 50, 5, 1, function (value)
    DR_TXT_SCALE = value / 10
end)

menu.divider(toolFeats, "Others")
menuAction(toolFeats, "Set every single thing that is a minute long to 0", {}, "", function ()
    memory.write_int(memory.script_global(262145+30775),0)
    wait(50) 
    memory.write_int(memory.script_global(262145+30813),0)
    wait(50) 
    memory.write_int(memory.script_global(262145+31315),0)
    wait(50) 
    memory.write_int(memory.script_global(262145+32109),0)
    wait(50) 
    memory.write_int(memory.script_global(262145+16756),0)
    wait(50) 
    memory.write_int(memory.script_global(262145+16935),0)
    wait(50) 
    memory.write_int(memory.script_global(262145+17202),0)
    wait(50) 
    memory.write_int(memory.script_global(262145+17206),0)
    wait(50) 
    memory.write_int(memory.script_global(262145+17207),0)
    wait(50) 
    memory.write_int(memory.script_global(262145+17211),0)
    wait(50) 
    memory.write_int(memory.script_global(262145+17240),0)
    wait(50) 
    memory.write_int(memory.script_global(262145+19291),0)
    wait(50) 
    memory.write_int(memory.script_global(262145+21103),0)
    wait(50) 
    memory.write_int(memory.script_global(262145+21103),0)
    wait(50) 
    memory.write_int(memory.script_global(262145+21104),0)
    wait(50) 
    memory.write_int(memory.script_global(262145+21129),0)
    wait(50) 
    memory.write_int(memory.script_global(262145+22400),0)
    wait(50) 
    memory.write_int(memory.script_global(262145+22404),0)
    wait(50) 
    memory.write_int(memory.script_global(262145+22408),0)
    wait(50) 
    memory.write_int(memory.script_global(262145+22524),0)
    wait(50) 
    memory.write_int(memory.script_global(262145+22858),0)
    wait(50) 
    memory.write_int(memory.script_global(262145+23213),0)
    wait(50) 
    memory.write_int(memory.script_global(262145+23762),0)
    wait(50) 
    memory.write_int(memory.script_global(262145+24100),0)
    wait(50) 
    memory.write_int(memory.script_global(262145+24417),0)
    wait(50) 
    memory.write_int(memory.script_global(262145+24544),0)
    wait(50) 
    memory.write_int(memory.script_global(262145+25058),0)
    wait(50) 
    memory.write_int(memory.script_global(262145+25065),0)
    wait(50) 
    memory.write_int(memory.script_global(262145+25436),0)
    wait(50) 
    memory.write_int(memory.script_global(262145+28058),0)
    wait(50) 
    memory.write_int(memory.script_global(262145+28419),0)
    wait(50) 
    memory.write_int(memory.script_global(262145+153),0)
    wait(50) 
    memory.write_int(memory.script_global(262145+51),0)
    wait(50) 
    memory.write_int(memory.script_global(262145+56),0)
    wait(50) 
    memory.write_int(memory.script_global(262145+4667),0)
    wait(50) 
    memory.write_int(memory.script_global(262145+4138),0)
    wait(50) 
    memory.write_int(memory.script_global(262145+7435),0)
    wait(50) 
    memory.write_int(memory.script_global(262145+8042),0)
    wait(50) 
    memory.write_int(memory.script_global(262145+9877),0)
    wait(50) 
    memory.write_int(memory.script_global(262145+10395),0)
    wait(50) 
    memory.write_int(memory.script_global(262145+10610),0)
    wait(50) 
    memory.write_int(memory.script_global(262145+10761),0)
    wait(50) 
    memory.write_int(memory.script_global(262145+10863),0)
    wait(50) 
    memory.write_int(memory.script_global(262145+11191),0)
    wait(50) 
    memory.write_int(memory.script_global(262145+11333),0)
    wait(50) 
    memory.write_int(memory.script_global(262145+11425),0)
    wait(50) 
    memory.write_int(memory.script_global(262145+11808),0)
    wait(50) 
    memory.write_int(memory.script_global(262145+11812),0)
    wait(50) 
    memory.write_int(memory.script_global(262145+12805),0)
    wait(50) 
    memory.write_int(memory.script_global(262145+15297),0)
    wait(50) 
    memory.write_int(memory.script_global(262145+16403),0)
    wait(50) 
    memory.write_int(memory.script_global(262145+23818),0)
    --[[
    memory.write_int(memory.script_global(262145+30775),0)
    memory.write_int(memory.script_global(262145+30813),0)
    memory.write_int(memory.script_global(262145+31315),0)
    memory.write_int(memory.script_global(262145+32109),0)
    memory.write_int(memory.script_global(262145+16756),0)
    memory.write_int(memory.script_global(262145+16935),0)
    memory.write_int(memory.script_global(262145+17202),0)
    memory.write_int(memory.script_global(262145+17206),0)
    memory.write_int(memory.script_global(262145+17207),0)
    memory.write_int(memory.script_global(262145+17211),0)
    memory.write_int(memory.script_global(262145+17240),0)
    memory.write_int(memory.script_global(262145+19291),0)
    memory.write_int(memory.script_global(262145+21103),0)
    memory.write_int(memory.script_global(262145+21103),0)
    memory.write_int(memory.script_global(262145+21104),0)
    memory.write_int(memory.script_global(262145+21129),0)
    memory.write_int(memory.script_global(262145+22400),0)
    memory.write_int(memory.script_global(262145+22404),0)
    memory.write_int(memory.script_global(262145+22408),0)
    memory.write_int(memory.script_global(262145+22524),0)
    memory.write_int(memory.script_global(262145+22858),0)
    memory.write_int(memory.script_global(262145+23213),0)
    memory.write_int(memory.script_global(262145+23762),0)
    memory.write_int(memory.script_global(262145+24100),0)
    memory.write_int(memory.script_global(262145+24417),0)
    memory.write_int(memory.script_global(262145+24544),0)
    memory.write_int(memory.script_global(262145+25058),0)
    memory.write_int(memory.script_global(262145+25065),0)
    memory.write_int(memory.script_global(262145+25436),0)
    memory.write_int(memory.script_global(262145+28058),0)
    memory.write_int(memory.script_global(262145+28419),0)
    memory.write_int(memory.script_global(262145+153),0)
    memory.write_int(memory.script_global(262145+51),0)
    memory.write_int(memory.script_global(262145+56),0)
    memory.write_int(memory.script_global(262145+4667),0)
    memory.write_int(memory.script_global(262145+4138),0)
    memory.write_int(memory.script_global(262145+7435),0)
    memory.write_int(memory.script_global(262145+8042),0)
    memory.write_int(memory.script_global(262145+9877),0)
    memory.write_int(memory.script_global(262145+10395),0)
    memory.write_int(memory.script_global(262145+10610),0)
    memory.write_int(memory.script_global(262145+10761),0)
    memory.write_int(memory.script_global(262145+10863),0)
    memory.write_int(memory.script_global(262145+11191),0)
    memory.write_int(memory.script_global(262145+11333),0)
    memory.write_int(memory.script_global(262145+11425),0)
    memory.write_int(memory.script_global(262145+11808),0)
    memory.write_int(memory.script_global(262145+11812),0)
    memory.write_int(memory.script_global(262145+12805),0)
    memory.write_int(memory.script_global(262145+15297),0)
    memory.write_int(memory.script_global(262145+16403),0)
    memory.write_int(memory.script_global(262145+23818),0)
    ]]
end)

--------------------------------------------------------------------------------------------------------------------------

local vehicleFeats = menu.list(menuroot, "Vehicle Options", {"vehicleFeats"}, "")

menuToggleLoop(vehicleFeats, "Unlock Vehicle that you shoot", {"unlockvehshot"}, "Unlocks a vehicle that you shoot. This will work on locked player cars.", function ()
    ::start::
    local localPed = getLocalPed()
    if PED.IS_PED_SHOOTING(localPed) then
        local pointer = memory.alloc(4)
        local isEntFound = PLAYER.GET_ENTITY_PLAYER_IS_FREE_AIMING_AT(players.user(), pointer)
        if isEntFound then
            local entity = memory.read_int(pointer)
            if ENTITY.IS_ENTITY_A_PED(entity) and PED.IS_PED_IN_ANY_VEHICLE(entity) then
                local vehicle = PED.GET_VEHICLE_PED_IS_IN(entity)
                ---------------------------------------------
                NETWORK.NETWORK_REQUEST_CONTROL_OF_ENTITY(vehicle)
                if not NETWORK.NETWORK_HAS_CONTROL_OF_ENTITY(vehicle) then
                    for i = 1, 20 do
                        NETWORK.NETWORK_REQUEST_CONTROL_OF_ENTITY(vehicle)
                        wait(100)
                    end
                end
                if not NETWORK.NETWORK_HAS_CONTROL_OF_ENTITY(vehicle) then
                    util.toast("Waited 2 secs, couldn't get control!")
                    goto start
                else
                    util.toast("Has control.")
                end
                VEHICLE.SET_VEHICLE_DOORS_LOCKED(vehicle, 1)
                VEHICLE.SET_VEHICLE_DOORS_LOCKED_FOR_ALL_PLAYERS(vehicle, true)
                VEHICLE.SET_VEHICLE_DOORS_LOCKED_FOR_PLAYER(vehicle, players.user(), false)
            elseif ENTITY.IS_ENTITY_A_VEHICLE(entity) then
                NETWORK.NETWORK_REQUEST_CONTROL_OF_ENTITY(entity)
                if not NETWORK.NETWORK_HAS_CONTROL_OF_ENTITY(entity) then
                    for i = 1, 20 do
                        NETWORK.NETWORK_REQUEST_CONTROL_OF_ENTITY(entity)
                        wait(100)
                    end
                end
                if not NETWORK.NETWORK_HAS_CONTROL_OF_ENTITY(entity) then
                    util.toast("Waited 2 secs, couldn't get control!")
                    goto start
                else
                    if SE_Notifications then
                        util.toast("Has control.")
                    end
                end
                VEHICLE.SET_VEHICLE_DOORS_LOCKED(entity, 1)
                VEHICLE.SET_VEHICLE_DOORS_LOCKED_FOR_ALL_PLAYERS(entity, false)
                VEHICLE.SET_VEHICLE_DOORS_LOCKED_FOR_PLAYER(entity, players.user(), false)
                VEHICLE.SET_VEHICLE_HAS_BEEN_OWNED_BY_PLAYER(veh, false)
            end
        end
    end
end)

menuToggleLoop(vehicleFeats, "Unlock vehicle that you try to get into", {"unlockvehget"}, "Unlocks a vehicle that you try to get into. This will work on locked player cars.", function ()
    ::start::
    local localPed = getLocalPed()
    local veh = PED.GET_VEHICLE_PED_IS_TRYING_TO_ENTER(localPed)
    if PED.IS_PED_IN_ANY_VEHICLE(localPed, false) then
        local v = PED.GET_VEHICLE_PED_IS_IN(localPed, false)
        VEHICLE.SET_VEHICLE_DOORS_LOCKED(v, 1)
        VEHICLE.SET_VEHICLE_DOORS_LOCKED_FOR_ALL_PLAYERS(v, false)
        VEHICLE.SET_VEHICLE_DOORS_LOCKED_FOR_PLAYER(v, players.user(), false)
        wait()
    else
        if SE_Notifications then
            util.toast(tostring(veh))
        end
            if veh ~= 0 then
            NETWORK.NETWORK_REQUEST_CONTROL_OF_ENTITY(veh)
            if not NETWORK.NETWORK_HAS_CONTROL_OF_ENTITY(veh) then
                for i = 1, 20 do
                    NETWORK.NETWORK_REQUEST_CONTROL_OF_ENTITY(veh)
                    wait(100)
                end
            end
            if not NETWORK.NETWORK_HAS_CONTROL_OF_ENTITY(veh) then
                util.toast("Waited 2 secs, couldn't get control!")
                goto start
            else
                if SE_Notifications then
                    util.toast("Has control.")
                end
            end
            VEHICLE.SET_VEHICLE_DOORS_LOCKED(veh, 1)
            VEHICLE.SET_VEHICLE_DOORS_LOCKED_FOR_ALL_PLAYERS(veh, false)
            VEHICLE.SET_VEHICLE_DOORS_LOCKED_FOR_PLAYER(veh, players.user(), false)
            VEHICLE.SET_VEHICLE_HAS_BEEN_OWNED_BY_PLAYER(veh, false)
        end
    end
end)

menuToggleLoop(vehicleFeats, "Turn Car On Instantly", {"turnvehonget"}, "Turns the car engine on instantly when you get into it, so you don't have to wait.", function ()
    local localped = getLocalPed()
    if PED.IS_PED_GETTING_INTO_A_VEHICLE(localped) then
        local veh = PED.GET_VEHICLE_PED_IS_ENTERING(localped)
        if not VEHICLE.GET_IS_VEHICLE_ENGINE_RUNNING(veh) then
            VEHICLE.SET_VEHICLE_FIXED(veh)
            VEHICLE.SET_VEHICLE_ENGINE_HEALTH(veh, 1000)
            VEHICLE.SET_VEHICLE_ENGINE_ON(veh, true, true, false)
        end
    end
end)

menuToggleLoop(vehicleFeats, "Stop Vehicle On Getting In", {"stopvehonget"}, "Set's the car's velocity to 0 when you try to get into it. Useful on roads.", function ()
    local localped = getLocalPed()
    if PED.IS_PED_GETTING_INTO_A_VEHICLE(localped) then
        local veh = PED.GET_VEHICLE_PED_IS_TRYING_TO_ENTER(localped)
        if not VEHICLE.IS_VEHICLE_STOPPED(veh) then
            ENTITY.FREEZE_ENTITY_POSITION(veh, true)
            ENTITY.SET_ENTITY_VELOCITY(veh, 0, 0, 0)
            ENTITY.FREEZE_ENTITY_POSITION(veh, false)
        end
    end
end)

--------------------------------------------------------------------------------------------------------------------------

menu.divider(menuroot, "----------Settings----------")

menuToggle(menuroot, "Enable/Disable notifications", {}, "Disables notifications like 'stickybomb placed!' or 'entity marked.' Stuff like that. Those get annoying with the Pan feature especially.", function(on)
    if on then
        SE_Notifications = true
    else
        SE_Notifications = false
    end
end)

menuToggle(menuroot, "Enable/Disable ArrayList", {"arraylist"}, "God, please, save me. Save me from this.", function(on)
    if on then
        SE_ArrayList = true
    else
        SE_ArrayList = false
    end
end)

--[[
menuAction(debugFeats, "Get Vehicle and Do something", {}, "", function ()
    local pped = getPlayerPed(players.user())
    local ourveh = PED.GET_VEHICLE_PED_IS_IN(pped, false)
    VEHICLE.ROLL_DOWN_WINDOWS(ourveh)
end)]]


-----------------------------------------------------------------------------------------------------------------------------------

--SET_CAM_ACTIVE : set cam as active
--IS_CAM_ACTIVE : is cam active?
--CREATE_CAM : create a cam
--SET_ENTITY_CAN_BE_DAMAGED : entity damaged?
--IS_PROJECTILE_IN_AREA : is a proj in area, can BOOL for only player-owned. (Maybe rocket deleter?) (with CLEAR_AREA_OF_PROJECTILES)



-----------------------------------------------------------------------------------------------------------------------------------


--preload explosion delay
SE_explodeDelay = 0
local function playerActionsSetup(pid) --set up player actions (necessary for each PID)
    menu.divider(menu.player_root(pid), scriptName)
    local playerMain = menu.list(menu.player_root(pid), scriptName, {"SneakyE", "SneakyExplodes"}, "")
    menu.divider(playerMain, scriptName)
    local playerSuicides = menu.list(playerMain, "Suicides", {}, "") --suicides parent
    local playerWeapons = menu.list(playerMain, "Weapons", {}, "") -- weapons parent
    local playerTools = menu.list(playerMain, "Tools", {}, "") --tools parent
    local playerOtherTrolling = menu.list(playerMain, "Trolling", {}, "")
    
    
    --suicides

    menuAction(playerSuicides, "Make Player Explode Themselves", {"suicide"}, "", function()
        local playerPed = getPlayerPed(pid)
        local playerCoords = getEntityCoords(playerPed)
        -- checks for interior, godmode, and vehicle all in one if / elseif statement...
        if players.is_godmode(pid) and not players.is_in_interior(pid) then
            util.toast("Player is in godmode, stopping explode...")
        elseif players.is_in_interior(pid) then
            util.toast("Player is in an interior, stopping explode...")
        elseif PED.IS_PED_IN_ANY_VEHICLE(playerPed, true) then
            for i = 0, 50, 1 do --50 explosions to account for armored vehicles, using type 5, as a tank shell as well xD
                SE_add_owned_explosion(playerPed, playerCoords.x, playerCoords.y, playerCoords.z, 5, 10, SEisExploAudible, SEisExploInvis, 0)
                wait(10)
            end
        else
            SE_add_owned_explosion(playerPed, playerCoords.x, playerCoords.y, playerCoords.z, 1, 10, SEisExploAudible, SEisExploInvis, 0)
        end
    end)
    menuToggleLoop(playerSuicides, "Loop Explode Suicide", {"loopsuicide"}, "Loops suicidal explosions.", function()
        local playerPed = getPlayerPed(pid)
        local playerCoords = getEntityCoords(playerPed)
        -- checks for interior, godmode in one if / elseif statement...
        if players.is_godmode(pid) and not players.is_in_interior(pid) then
            util.toast("Player is in godmode, stopping explode...")
        elseif players.is_in_interior(pid) then
            util.toast("Player is in an interior, stopping explode...")
        else
            SE_add_owned_explosion(playerPed, playerCoords.x, playerCoords.y, playerCoords.z, 1, 10, SEisExploAudible, SEisExploInvis, 0)
        end
        wait(SE_explodeDelay)
    end)
    menuAction(playerSuicides, "Make Player Molotov Themselves", {"suimolly", "suimolotov"}, "Fire will not stay on the player if invisibility is enabled.", function()
        local playerPed = getPlayerPed(pid)
        local playerCoords = getEntityCoords(playerPed)
        --checks for godmode and interior
        if players.is_godmode(pid) and not players.is_in_interior(pid) then
            util.toast("Player is in godmode, stopping explode...")
        elseif players.is_in_interior(pid) then
            util.toast("Player is in an interior, stopping explode...")
        else
            SE_add_owned_explosion(playerPed, playerCoords.x, playerCoords.y, playerCoords.z, 3, 10, SEisExploAudible, SEisExploInvis, 0)
        end
    end)
    menuToggleLoop(playerSuicides, "Loop Molotov Suicide", {"loopsuimolly", "loopsuimolotov"}, "Loops suicidal molotovs.", function()
        local playerPed = getPlayerPed(pid)
        local playerCoords = getEntityCoords(playerPed)
        --checks for godmode and interior
        if players.is_godmode(pid) and not players.is_in_interior(pid) then
            util.toast("Player is in godmode, stopping explode...")
        elseif players.is_in_interior(pid) then
            util.toast("Player is in an interior, stopping explode...")
        else
            SE_add_owned_explosion(playerPed, playerCoords.x, playerCoords.y, playerCoords.z, 3, 10, SEisExploAudible, SEisExploInvis, 0)
        end
        wait(SE_explodeDelay)
    end)

    menu.click_slider(playerSuicides, "Change explosion delay (ms)", {"SEexpdel"}, "Changes the explosion delay in milliseconds. Max 10sec (10000ms)", 0, 10000, 0, 10, function(val)
        SE_explodeDelay = val
    end)

    -----------------------------------------------------------------------------------------------------------------------------------

    --weapons

    menuToggleLoop(playerWeapons, "Explosion Gun", {"pexplogun"}, "Gives the player an explosion gun.", function ()
        local pped = getPlayerPed(pid)
        local shot = WEAPON.GET_PED_LAST_WEAPON_IMPACT_COORD(pped, SE_pImpactCoord)
        if shot then
            local explo = memory.read_vector3(SE_pImpactCoord)
            SE_add_owned_explosion(pped, explo.x, explo.y, explo.z, 2, 10, SEisExploAudible, SEisExploInvis, 0)
        end
    end)


   --[[ menuToggleLoop(playerWeapons, "Kick gun", {"pkickgun"}, "Gives the player a delete gun.", function ()
        local pped = getPlayerPed(pid)
        if PED.IS_PED_SHOOTING(pped) then
            local allocCord = memory.alloc()
            local junk = WEAPON.GET_PED_LAST_WEAPON_IMPACT_COORD(pped, allocCord)
            local coord = memory.read_vector3(allocCord)
            if coord.x == 0 and coord.y == 0 and coord.z == 0 then
                --check if the shot was shot into the air, and if it was, do nothing.
            else
                if SE_Notifications then
                    util.toast(coord.x .. " " .. coord.y .. " " .. coord.z)
                end
                local ourEntity = FIRE._GET_ENTITY_INSIDE_EXPLOSION_SPHERE(1, coord.x, coord.y, coord.z, 5)
                if ENTITY.IS_ENTITY_A_PED(ourEntity) then
                    util.toast("Valid ped.")
                end
            end
            memory.free(allocCord)
        end
    end)]]
    -----------------------------------------------------------------------------------------------------------------------------------

    --other trolling

    menu.divider(playerOtherTrolling, "Vehicle Trolling")
    local vehicletrolling = menu.list(playerOtherTrolling, "Vehicle trolling", {}, "")
    menuAction(vehicletrolling, "Place wall in front of player", {}, "Places walls in front of player. Delete after half a second. Use this when they are driving forward for EPIC TROLLING.", function ()
        local ped = getPlayerPed(pid)
        local forwardOffset = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(ped, 0, 4, 0)
        local pheading = ENTITY.GET_ENTITY_HEADING(ped)
        local hash = 309416120
        requestModel(hash)
        while not hasModelLoaded(hash) do wait() end
        local a1 = OBJECT.CREATE_OBJECT(hash, forwardOffset.x, forwardOffset.y, forwardOffset.z - 1, true, true, true)
        ENTITY.SET_ENTITY_HEADING(a1, pheading + 90)
        fastNet(a1, pid)
        local b1 = OBJECT.CREATE_OBJECT(hash, forwardOffset.x, forwardOffset.y, forwardOffset.z + 1, true, true, true)
        ENTITY.SET_ENTITY_HEADING(b1, pheading + 90)
        fastNet(b1, pid)
        wait(500)
        entities.delete_by_handle(a1)
        entities.delete_by_handle(b1)
    end)

    --preload
    VehTroll_VehicleName = "adder"
    VehTroll_Invis = false

    menu.divider(vehicletrolling, "Drop Vehicle")

    menuAction(vehicletrolling, "Drop vehicle on player", {}, "", function ()
        local ped = getPlayerPed(pid)
        local pc = getEntityCoords(ped)
        local hash = joaat(VehTroll_VehicleName)
        requestModel(hash)
        while not hasModelLoaded(hash) do wait() end
        local ourveh = VEHICLE.CREATE_VEHICLE(hash, pc.x, pc.y, pc.z + 5, 0, true, true, false)
        if VehTroll_Invis then
            ENTITY.SET_ENTITY_VISIBLE(ourveh, false, 0)
        end
        noNeedModel(hash)
        wait(1200)
        entities.delete_by_handle(ourveh)
    end)

    menu.text_input(vehicletrolling, "Input Vehicle Name", {"vehtrollname"}, "Input a vehicle name for vehicle drop. The actual NAME that is assigned to it in RAGE, e.g. OppressorMK2 = oppressor2.", function (text)
        VehTroll_VehicleName = tostring(text)
    end, "adder")

    menuToggle(vehicletrolling, "Make Vehicle Invisible?", {"vehtrollinvis"}, "Makes the vehicle trolling vehicle invisible.", function(toggle)
        VehTroll_Invis = toggle
    end)

    -----------------------------------------------------------------------------

    menu.divider(vehicletrolling, "Teleport Player's Vehicle")

    menuAction(vehicletrolling, "Teleport Player Into Ocean", {"tpocean"}, "Telepots the player's vehicle into the ocean. May need multiple clicks.", function()
        local ped = getPlayerPed(pid)
        local pc = getEntityCoords(ped)
        local oldcoords = getEntityCoords(getLocalPed())
        for o = 0, 10 do
            ENTITY.SET_ENTITY_COORDS_NO_OFFSET(getLocalPed(), pc.x, pc.y, pc.z + 10, false, false, false)
            wait(50)
        end
        if PED.IS_PED_IN_ANY_VEHICLE(ped, false) then
            local veh = PED.GET_VEHICLE_PED_IS_IN(ped, false)
            for a = 0, 10 do
                NETWORK.NETWORK_REQUEST_CONTROL_OF_ENTITY(veh)
                ENTITY.SET_ENTITY_COORDS_NO_OFFSET(veh, 4500, -4400, 4, false, false, false)
                wait(100)
            end
            if SE_Notifications then
                util.toast("Teleported " .. getPlayerName_pid(pid) .. " into the farthest ocean!")
            end
        else
            util.toast("Player " .. getPlayerName_pid(pid) .. " is not in a vehicle!")
        end
        ENTITY.SET_ENTITY_COORDS_NO_OFFSET(getLocalPed(), oldcoords.x, oldcoords.y, oldcoords.z, false, false, false)
    end)

    menuAction(vehicletrolling, "Teleport Player Onto Maze Bank", {"tpmazebank"}, "Telepots the player's vehicle onto the Maze Bank tower. May need multiple clicks.", function()
        local ped = getPlayerPed(pid)
        local pc = getEntityCoords(ped)
        local oldcoords = getEntityCoords(getLocalPed())
        for o = 0, 10 do
            ENTITY.SET_ENTITY_COORDS_NO_OFFSET(getLocalPed(), pc.x, pc.y, pc.z + 10, false, false, false)
            wait(50)
        end
        if PED.IS_PED_IN_ANY_VEHICLE(ped, false) then
            local veh = PED.GET_VEHICLE_PED_IS_IN(ped, false) 
            for a = 0, 10 do
                NETWORK.NETWORK_REQUEST_CONTROL_OF_ENTITY(veh)
                ENTITY.SET_ENTITY_COORDS_NO_OFFSET(veh, -76, -819, 327, false, false, false)
                wait(100)
            end
            if SE_Notifications then
                util.toast("Teleported " .. getPlayerName_pid(pid) .. " onto the Maze Bank tower!")
            end
        else
            util.toast("Player " .. getPlayerName_pid(pid) .. " is not in a vehicle!")
        end
        ENTITY.SET_ENTITY_COORDS_NO_OFFSET(getLocalPed(), oldcoords.x, oldcoords.y, oldcoords.z, false, false, false)
    end)

    menuToggleLoop(vehicletrolling, "FakeLag Player's Vehicle", {"vehfakelag"}, "Teleports the player's vehicle behind them a bit, simulating lag.", function ()
        local ped = getPlayerPed(pid)
        if PED.IS_PED_IN_ANY_VEHICLE(ped) then
            local veh = PED.GET_VEHICLE_PED_IS_IN(ped, false)
            local velocity = ENTITY.GET_ENTITY_VELOCITY(veh)
            local oldcoords = getEntityCoords(ped)
            wait(500)
            local nowcoords = getEntityCoords(ped)
            for a = 1, 10 do
                NETWORK.NETWORK_REQUEST_CONTROL_OF_ENTITY(veh)
                wait()
            end
            ENTITY.SET_ENTITY_COORDS_NO_OFFSET(veh, oldcoords.x, oldcoords.y, oldcoords.z, false, false, false)
            wait(200)
            for b = 1, 10 do
                NETWORK.NETWORK_REQUEST_CONTROL_OF_ENTITY(veh)
                wait()
            end
            ENTITY.SET_ENTITY_VELOCITY(veh, velocity.x, velocity.y, velocity.z)
            for c = 1, 10 do
                NETWORK.NETWORK_REQUEST_CONTROL_OF_ENTITY(veh)
                wait()
            end
            ENTITY.SET_ENTITY_COORDS_NO_OFFSET(veh, nowcoords.x, nowcoords.y, nowcoords.z, false, false, false)
            for d = 1, 10 do
                NETWORK.NETWORK_REQUEST_CONTROL_OF_ENTITY(veh)
                wait()
            end
            ENTITY.SET_ENTITY_VELOCITY(veh, velocity.x, velocity.y, velocity.z)
            wait(500)
        else
            util.toast("Player " .. getPlayerName_pid(pid) .. " is not in a vehicle!")
        end
    end)

    -----------------------------------------------------------------------------------------------------------------------------------





    menu.divider(playerOtherTrolling, "Toss Features")
    local ptossf = menu.list(playerOtherTrolling, "Toss Features", {}, "")

    menuToggleLoop(ptossf, "Toss Player Around", {"tossplayer", "toss", "ragtoss"}, "Loops no-damage explosions on the player. They will be invisible if you set them as such.", function()
        local playerCoords = ENTITY.GET_ENTITY_COORDS(PLAYER.GET_PLAYER_PED(pid), true)

        SE_add_explosion(playerCoords['x'], playerCoords['y'], playerCoords['z'], 1, 1, SEisExploAudible, SEisExploInvis, 0, true)
    end)


    --ty Jayphen for helping out a ton :)
    menuToggleLoop(ptossf, "Get Weapon Impact", {}, "Gets the coodinates that you want them to go to from your shot.", function()
        local junk = WEAPON.GET_PED_LAST_WEAPON_IMPACT_COORD(SE_LocalPed, SE_impactCoord)
        if junk then
            Want = memory.read_vector3(SE_impactCoord)
            if SE_Notifications then
                util.toast(Want.x .. " " .. Want.y .. " " .. Want.z)
            end
        end
    end)

    menuAction(ptossf, "Weapon Impact Debug", {}, "", function ()
        util.toast(Want.x .. " " .. Want.y .. " " .. Want.z)
    end)

    menuAction(ptossf, "Clear location memory", {}, "", function ()
        memory.free(SE_impactCoord)
        Want.x = 0
        Want.y = 0
        Want.z = 0
    end)
    -----------------------------------

    menuToggleLoop(ptossf, "Better Toss", {"bettertoss"}, "IT'S FINALLY HERE!.", function ()
        local targetPed = getPlayerPed(pid)
        local targetcoords = getEntityCoords(targetPed)
        if targetcoords.z >= Want.z then
            if targetcoords.x > Want.x - 2 and targetcoords.x < Want.x + 2 then
                if targetcoords.y > Want.y - 2 and targetcoords.y < Want.y + 2 then
                    for i = 1, 5, 1 do
                        SE_add_explosion(targetcoords.x, targetcoords.y, targetcoords.z + 2, 1, 1, SEisExploAudible, SEisExploInvis, 0, true)
                        wait()
                    end
                    util.toast("Player " .. tostring(PLAYER.GET_PLAYER_NAME(pid)) .. " has reached the desired location.")
                    util.toast("Shutting off Better Toss.")
                    menu.trigger_commands("bettertoss" .. PLAYER.GET_PLAYER_NAME(pid) .. " off")
                end
            end
        end
        if targetcoords.z < Want.z + 3 then --levitate the target up to the desired HEIGHT
            SE_add_explosion(targetcoords.x, targetcoords.y, targetcoords.z - 2, 1, 1, SEisExploAudible, SEisExploInvis, 0, true) --add explosion under them

            --explosions around the player, like a "wall" that stops them from ragdolling too far off to the side
            SE_add_explosion(targetcoords.x - 1, targetcoords.y, targetcoords.z, 1, 1, SEisExploAudible, SEisExploInvis, 0, true)
            SE_add_explosion(targetcoords.x + 1, targetcoords.y, targetcoords.z, 1, 1, SEisExploAudible, SEisExploInvis, 0, true)
            SE_add_explosion(targetcoords.x, targetcoords.y - 1, targetcoords.z, 1, 1, SEisExploAudible, SEisExploInvis, 0, true)
            SE_add_explosion(targetcoords.x, targetcoords.y + 1, targetcoords.z, 1, 1, SEisExploAudible, SEisExploInvis, 0, true)
        else
            if targetcoords.x < Want.x - 2 then
                SE_add_explosion(targetcoords.x - 2, targetcoords.y, targetcoords.z + 1.5, 1, 1, SEisExploAudible, SEisExploInvis, 0, true)
            elseif targetcoords.x > Want.x - 2 then
                SE_add_explosion(targetcoords.x + 2, targetcoords.y, targetcoords.z + 1.5, 1, 1, SEisExploAudible, SEisExploInvis, 0, true)
            end
            if targetcoords.y < Want.y - 2 then
                SE_add_explosion(targetcoords.x, targetcoords.y - 2, targetcoords.z + 1.5, 1, 1, SEisExploAudible, SEisExploInvis, 0, true)
            elseif targetcoords.y > Want.y - 2 then
                SE_add_explosion(targetcoords.x, targetcoords.y + 2, targetcoords.z + 1.5, 1, 1, SEisExploAudible, SEisExploInvis, 0, true)
            end
        end
    end)

    menu.divider(playerOtherTrolling, "Toxic Features")
    local ptoxic = menu.list(playerOtherTrolling, "Toxic Features", {}, "")
    -----------------------------------

    menu.divider(ptoxic, "Bro Hug")

    menuAction(ptoxic, "Freemode Death", {"fdeath"}, "Freemode death on player.", function ()
        for i = -1, 1 do
            for n = -1, 1 do
                util.trigger_script_event(1 << pid, {-65587051, 28, i, n})
            end
        end
        for i = -1, 1 do
            for n = -1, 1 do
                util.trigger_script_event(1 << pid, {1445703181, 28, i, n})
            end
        end
        wait(100)
        util.trigger_script_event(1 << pid, {-290218924, -32190, -71399, 19031, 85474, 4468, -2112})
        util.trigger_script_event(1 << pid, {-227800145, -1000000, -10000000, -100000000, -100000000, -100000000})
        util.trigger_script_event(1 << pid, {2002459655, -1000000, -10000, -100000000})
        util.trigger_script_event(1 << pid, {911179316, -38, -30, -75, -59, 85, 82})
        for i = -1, 1 do
            for a = -1, 1 do
                util.trigger_script_event(1 << pid, {916721383, i, a, 0, 26})
            end
        end
    end)

    CU_SE_MAIN = 0
    CU_SE_PARAM1 = 0
    CU_SE_PARAM2 = 0
    CU_SE_PARAM3 = 0
    CU_SE_PARAM4 = 0

    menuAction(ptoxic, "Send Custom Script Event", {"sendcustomse"}, "Advanced users only.", function ()
        util.trigger_script_event(1 << pid, {CU_SE_MAIN, CU_SE_PARAM1, CU_SE_PARAM2, CU_SE_PARAM3, CU_SE_PARAM4})
    end)

    menu.slider(ptoxic, "Custom Script Event Hash", {"customsehash"}, "", -2147483648, 2147483647, 0, 1, function (value)
        CU_SE_MAIN = value
    end)

    menu.slider(ptoxic, "Param1", {"customparam1"}, "", -2147483648, 2147483647, 0, 1, function (value)
        CU_SE_PARAM1 = value
    end)

    menu.slider(ptoxic, "Param2", {"customparam2"}, "", -2147483648, 2147483647, 0, 1, function (value)
        CU_SE_PARAM2 = value
    end)

    menu.slider(ptoxic, "Param3", {"customparam3"}, "", -2147483648, 2147483647, 0, 1, function (value)
        CU_SE_PARAM3 = value
    end)


    menuAction(ptoxic, "AIO kick.", {"aiok", "aiokick"}, "If 'slower, but better aio' is enabled in lobby features, then uses it here as well.", function ()
        if SE_Notifications then
            util.toast("Player connected " .. tostring(PLAYER.GET_PLAYER_NAME(pid) .. ", commencing AIO."))
        end
        util.trigger_script_event(1 << pid, {0x37437C28, 1, 15, math.random(-2147483647, 2147483647)})
        wait(10) 
        util.trigger_script_event(1 << pid, {-1308840134, 1, 15, math.random(-2147483647, 2147483647)})
        wait(10) 
        util.trigger_script_event(1 << pid, {0x4E0350C6, 1, 15, math.random(-2147483647, 2147483647)})
        wait(10) 
        util.trigger_script_event(1 << pid, {-0x114C63AC, 1, 15, math.random(-2147483647, 2147483647)})
        wait(10) 
        util.trigger_script_event(1 << pid, {-0x15F5B1D4, 1, 15, math.random(-2147483647, 2147483647)})
        wait(10) 
        util.trigger_script_event(1 << pid, {-0x249FE11B, 1, 15, math.random(-2147483647, 2147483647)})
        wait(10) 
        util.trigger_script_event(1 << pid, {-0x76B11968, 1, 15, math.random(-2147483647, 2147483647)})
        wait(10) 
        util.trigger_script_event(1 << pid, {0x9C050EC, 1, 15, math.random(-2147483647, 2147483647)})
        wait(10) 
        util.trigger_script_event(1 << pid, {0x3B873479, 1, 15, math.random(-2147483647, 2147483647)})
        wait(10) 
        util.trigger_script_event(1 << pid, {0x23F74138, math.random(-2147483647, 2147483647), 1, 115, math.random(-2147483647, 2147483647)})
        wait(10) 
        --[[
        util.trigger_script_event(1 << pid, {0xAD63290E, math.random(-2147483647, 2147483647), 1, 115, math.random(-2147483647, 2147483647)})
        wait(10)
        ]]
        --[[ 
        util.trigger_script_event(1 << pid, {0x39624029, math.random(-2147483647, 2147483647), 1, 115, math.random(-2147483647, 2147483647)})
        wait(10) 
        ]]
        util.trigger_script_event(1 << pid, {-0x529CD6F2, math.random(-2147483647, 2147483647), 1, 115, math.random(-2147483647, 2147483647)})
        wait(10) 
        util.trigger_script_event(1 << pid, {-0x756DBC8A, math.random(-2147483647, 2147483647), 1, 115, math.random(-2147483647, 2147483647)})
        wait(10) 
        util.trigger_script_event(1 << pid, {-0x69532BA0, math.random(-2147483647, 2147483647), 1, 115, math.random(-2147483647, 2147483647)})
        wait(10) 
        util.trigger_script_event(1 << pid, {0x68C5399F, math.random(-2147483647, 2147483647), 1, 115, math.random(-2147483647, 2147483647)})
        wait(10) 
        util.trigger_script_event(1 << pid, {0x7DE8CAC0, math.random(-2147483647, 2147483647), 1, 115, math.random(-2147483647, 2147483647)})
        wait(10) 
        util.trigger_script_event(1 << pid, {0x285DDF33, math.random(-2147483647, 2147483647), 1, 115, math.random(-2147483647, 2147483647)})
        wait(10) 
        util.trigger_script_event(1 << pid, {-0x177132B8, math.random(-2147483647, 2147483647), 1, 115, math.random(-2147483647, 2147483647)})
        wait(10)
        --util.toast("Main block done. // AIO")
        util.trigger_script_event(1 << pid, {memory.script_global(1893548 + (1 + (pid * 600) + 511)), pid})
        for a = -1, 1 do
            for n = -1, 1 do
                util.trigger_script_event(1 << pid, {-65587051, 28, a, n})
                wait(10)
            end
        end
        --util.toast("Second block done. // AIO")
        for a = -1, 1 do
            for n = -1, 1 do
                util.trigger_script_event(1 << pid, {1445703181, 28, a, n})
                wait(10)
            end
        end
        --util.toast("Third block done. // AIO")
        if TXC_SLOW then
            wait(10)
            util.trigger_script_event(1 << pid, {-290218924, -32190, -71399, 19031, 85474, 4468, -2112})
            wait(10)
            util.trigger_script_event(1 << pid, {-227800145, -1000000, -10000000, -100000000, -100000000, -100000000})
            wait(10)
            util.trigger_script_event(1 << pid, {2002459655, -1000000, -10000, -100000000})
            wait(10)
            util.trigger_script_event(1 << pid, {911179316, -38, -30, -75, -59, 85, 82})
            wait(10)
            --[[
            for n = -10, -7 do
                for a = -60, 60 do
                    util.trigger_script_event(1 << pid, {0x39624029, n, 623656, a, 73473741, -7, 856844, -51251, 856844})
                    wait(10)
                end
            end]]
            util.trigger_script_event(1 << pid, {-290218924, -32190, -71399, 19031, 85474, 4468, -2112})
            wait(10)
            util.trigger_script_event(1 << pid, {-1386010354, 91645, -99683, 1788, 60877, 55085, 72028})
            wait(10)
            util.trigger_script_event(1 << pid, {-227800145, -1000000, -10000000, -100000000, -100000000, -100000000})
            wait(10)
            for g = -28, 0 do
                for n = -1, 1 do
                    for a = -1, 1 do
                        util.trigger_script_event(1 << pid, {1445703181, g, n, a})
                    end
                end
                wait(10)
            end
            --[[for a = -28, 20 do
                for n = -10, 2 do
                    for b = -100, 100 do
                        util.trigger_script_event(1 << pid, {-1782442696, b, n, a})
                        util.log("Number 6, iteration " .. b)
                    end
                    util.log("Number 7, iteration " .. n)
                end
                util.log("Number 8, iteration " .. a)
                wait(10)
            end]]
            for a = -11, 11 do
                util.trigger_script_event(1 << pid, {2002459655, -1000000, a, -100000000})
            end
            for a = -10, 10 do
                for n = 30, -30 do
                    util.trigger_script_event(1 << pid, {911179316, a, n, -75, -59, 85, 82})
                end
            end
            for a = -10, 10 do
                util.trigger_script_event(1 << pid, {-65587051, a, -1, -1})
            end
            util.trigger_script_event(1 << pid, {951147709, pid, 1000000, nil, nil}) 
            for a = -10, 10 do
                util.trigger_script_event(1 << pid, {-1949011582, a, 1518380048})
            end
            for a = -10, 4 do
                for n = -10, 5 do
                    util.trigger_script_event(1 << pid, {1445703181, 28, a, n})
                end
            end
        end
        if SE_Notifications then
            util.toast("Fourth block done. // AIO")
            util.toast("Iteration " .. pid .. " complete of AIO kick.")
            util.toast("Player " .. PLAYER.GET_PLAYER_NAME(pid) .. " done.")
        end
    end)

    --hehehoho

    menu.divider(ptoxic, "Casino Blocks")

    menuAction(ptoxic, "Block Casino, Semi-Permanently.", {}, "Blocks the casino for them, so they have to restart their game in order to access it. Joining a new session will not work for them. This sometimes doesn't work, but most of the time, it does.", function ()
    local hash = 309416120
    requestModel(hash)
    while not hasModelLoaded(hash) do wait() end

    for i = 1, BA_iterations do
        local b1 = OBJECT.CREATE_OBJECT_NO_OFFSET(hash, 918, 42, 80, true, true, true)
        ENTITY.SET_ENTITY_HEADING(b1, 324)
        
        netIt(b1, pid)
        wait(10)

        local b1_2 = OBJECT.CREATE_OBJECT_NO_OFFSET(hash, 922, 48, 80, true, true, true)
        ENTITY.SET_ENTITY_HEADING(b1_2, 324)

        netIt(b1_2, pid)
        wait(10)

        local b1_3 = OBJECT.CREATE_OBJECT_NO_OFFSET(hash, 925, 53, 80, true, true, true)
        ENTITY.SET_ENTITY_HEADING(b1_3, 324)

        netIt(b1_3, pid)
        wait(10)

        local b2 = OBJECT.CREATE_OBJECT_NO_OFFSET(hash, 928, 55, 80, true, true, true)
        ENTITY.SET_ENTITY_HEADING(b2, 239)

        netIt(b1_2, pid)
        wait(10)

        local b2_2 = OBJECT.CREATE_OBJECT_NO_OFFSET(hash, 917, 39, 80, true, true, true)
        ENTITY.SET_ENTITY_HEADING(b2_2, 239)

        netIt(b2_2, pid)
        wait(10)

        --

        local c1 = OBJECT.CREATE_OBJECT_NO_OFFSET(hash, 918, 42, 82, true, true, true)
        ENTITY.SET_ENTITY_HEADING(c1, 324)

        netIt(c1, pid)
        wait(10)

        local c1_2 = OBJECT.CREATE_OBJECT_NO_OFFSET(hash, 922, 48, 82, true, true, true)
        ENTITY.SET_ENTITY_HEADING(c1_2, 324)

        netIt(c1_2, pid)
        wait(10)

        local c1_3 = OBJECT.CREATE_OBJECT_NO_OFFSET(hash, 925, 53, 82, true, true, true)
        ENTITY.SET_ENTITY_HEADING(c1_3, 324)

        netIt(c1_3, pid)
        wait(10)

        local c2 = OBJECT.CREATE_OBJECT_NO_OFFSET(hash, 928, 55, 82, true, true, true)
        ENTITY.SET_ENTITY_HEADING(c2, 239)

        netIt(c2, pid)
        wait(10)

        local c2_2 = OBJECT.CREATE_OBJECT_NO_OFFSET(hash, 917, 39, 82, true, true, true)
        ENTITY.SET_ENTITY_HEADING(c2_2, 239)

        netIt(c2_2, pid)
        wait(10)
        if SE_Notifications then
            util.toast("Spawned with index of " .. i)
        end
    end

    noNeedModel(hash)
    end)

    menuAction(ptoxic, "Block Casino Garage", {}, "Same as 'block casino'", function ()
        local hash = 309416120
        requestModel(hash)
        while not hasModelLoaded(hash) do wait() end
        for i = 1, BA_iterations do
            local a1 = OBJECT.CREATE_OBJECT_NO_OFFSET(hash, 935, -1, 78, true, true, true)
            ENTITY.SET_ENTITY_HEADING(a1, 59)
    
            netIt(a1, pid)
            wait(10)
    
            local b1 = OBJECT.CREATE_OBJECT_NO_OFFSET(hash, 939, -1, 78, true, true, true)
            ENTITY.SET_ENTITY_HEADING(b1, 329)
    
            netIt(b1, pid)
            wait(10)
    
            local c1 = OBJECT.CREATE_OBJECT_NO_OFFSET(hash, 933, 3, 78, true, true, true)
            ENTITY.SET_ENTITY_HEADING(c1, 329)
    
            netIt(c1, pid)
            wait(10)
    
            --
            
            local a1_2 = OBJECT.CREATE_OBJECT_NO_OFFSET(hash, 935, -1, 80, true, true, true)
            ENTITY.SET_ENTITY_HEADING(a1_2, 59)
    
            netIt(a1_2, pid)
            wait(10)
    
            local b1_2 = OBJECT.CREATE_OBJECT_NO_OFFSET(hash, 939, -1, 80, true, true, true)
            ENTITY.SET_ENTITY_HEADING(b1_2, 329)
    
            netIt(b1_2, pid)
            wait(10)
    
            local c1_2 = OBJECT.CREATE_OBJECT_NO_OFFSET(hash, 933, 3, 80, true, true, true)
            ENTITY.SET_ENTITY_HEADING(c1_2, 329)
    
            netIt(c1_2, pid)
            wait(10)
            if SE_Notifications then
                util.toast("Spawned with index of " .. i)
            end
        end
        noNeedModel(hash)
    end)

    menu.divider(ptoxic, "Block Los Santos Customs")

    menuAction(ptoxic, "Block LSC (1/4, by the airport)", {}, "", function ()
        local hash = 309416120
        requestModel(hash)
        while not hasModelLoaded(hash) do wait() end
        for i = 1, BA_iterations do
            local a1 = OBJECT.CREATE_OBJECT_NO_OFFSET(hash, -1144, -1988, 12, true, true, true)
            ENTITY.SET_ENTITY_HEADING(a1, 46)
    
            netIt(a1, pid)
            wait(100)
    
            local b1 = OBJECT.CREATE_OBJECT_NO_OFFSET(hash, -1143, -1992, 12, true, true, true)
            ENTITY.SET_ENTITY_HEADING(b1, 137)
    
            netIt(b1, pid)
            wait(100)
    
            local c1 = OBJECT.CREATE_OBJECT_NO_OFFSET(hash, -1147, -1988, 12, true, true, true)
            ENTITY.SET_ENTITY_HEADING(c1, 137)
    
            netIt(c1, pid)
            wait(100)
    
            --
    
            local a1_2 = OBJECT.CREATE_OBJECT_NO_OFFSET(hash, -1144, -1988, 14, true, true, true)
            ENTITY.SET_ENTITY_HEADING(a1_2, 46)
    
            netIt(a1_2, pid)
            wait(100)
    
            local b1_2 = OBJECT.CREATE_OBJECT_NO_OFFSET(hash, -1143, -1992, 14, true, true, true)
            ENTITY.SET_ENTITY_HEADING(b1_2, 137)
    
            netIt(b1_2, pid)
            wait(100)
    
            local c1_2 = OBJECT.CREATE_OBJECT_NO_OFFSET(hash, -1147, -1988, 14, true, true, true)
            ENTITY.SET_ENTITY_HEADING(c1_2, 137)
    
            netIt(c1_2, pid)
            wait(100)
            if SE_Notifications then
                util.toast("Spawned with index of " .. i)
            end
        end
        noNeedModel(hash)
    end)

    menuAction(ptoxic, "Block LSC (2/4, right of the map)", {}, "", function ()
    local hash = 309416120
    requestModel(hash)
    while not hasModelLoaded(hash) do wait() end
    for i = 1, BA_iterations do
        local a1 = OBJECT.CREATE_OBJECT_NO_OFFSET(hash, 719, -1089, 21, true, true, true)
        ENTITY.SET_ENTITY_HEADING(a1, 0)

        netIt(a1, pid)
        wait(100)

        local b1 = OBJECT.CREATE_OBJECT_NO_OFFSET(hash, 721, -1092, 21, true, true, true)
        ENTITY.SET_ENTITY_HEADING(b1, 93)

        netIt(b1, pid)
        wait(100)

        local c1 = OBJECT.CREATE_OBJECT_NO_OFFSET(hash, 721, -1085, 21, true, true, true)
        ENTITY.SET_ENTITY_HEADING(c1, 93)

        netIt(c1, pid)
        wait(100)

        --

        local a1_2 = OBJECT.CREATE_OBJECT_NO_OFFSET(hash, 719, -1089, 23, true, true, true)
        ENTITY.SET_ENTITY_HEADING(a1_2, 0)

        netIt(a1_2, pid)
        wait(100)

        local b1_2 = OBJECT.CREATE_OBJECT_NO_OFFSET(hash, 721, -1092, 23, true, true, true)
        ENTITY.SET_ENTITY_HEADING(b1_2, 93)

        netIt(b1_2, pid)
        wait(100)

        local c1_2 = OBJECT.CREATE_OBJECT_NO_OFFSET(hash, 721, -1085, 23, true, true, true)
        ENTITY.SET_ENTITY_HEADING(c1_2, 93)

        netIt(c1_2, pid)
        wait(100)
        if SE_Notifications then
            util.toast("Spawned with index of " .. i)
        end
    end
    noNeedModel(hash)
    end)

    menuAction(ptoxic, "Block LSC (3/4, middle of the map)", {}, "", function ()
        local hash = 309416120
        requestModel(hash)
        while not hasModelLoaded(hash) do wait() end
    
        --LSC in the middle of the map, classified as (3/4) on the map.
        for i = 1, BA_iterations do
            local a1 = OBJECT.CREATE_OBJECT_NO_OFFSET(hash, -359, -134, 38, true, true, true)
            ENTITY.SET_ENTITY_HEADING(a1, 340)
    
            netIt(a1, pid)
            wait(100)
    
            local b1 = OBJECT.CREATE_OBJECT_NO_OFFSET(hash, -356, -132, 38, true, true, true)
            ENTITY.SET_ENTITY_HEADING(b1, 252)
    
            netIt(b1, pid)
            wait(100)
    
            local c1 = OBJECT.CREATE_OBJECT_NO_OFFSET(hash, -358, -137, 38, true, true, true)
            ENTITY.SET_ENTITY_HEADING(c1, 250)
    
            netIt(c1, pid)
            wait(100)
    
            --
    
            local a1_2 = OBJECT.CREATE_OBJECT_NO_OFFSET(hash, -359, -134, 40, true, true, true)
            ENTITY.SET_ENTITY_HEADING(a1_2, 340)
    
            netIt(a1_2, pid)
            wait(100)
    
            local b1_2 = OBJECT.CREATE_OBJECT_NO_OFFSET(hash, -356, -132, 40, true, true, true)
            ENTITY.SET_ENTITY_HEADING(b1_2, 252)
    
            netIt(b1_2, pid)
            wait(100)
    
            local c1_2 = OBJECT.CREATE_OBJECT_NO_OFFSET(hash, -358, -137, 40, true, true, true)
            ENTITY.SET_ENTITY_HEADING(c1_2, 250)
    
            netIt(c1_2, pid)
            wait(100)
    
            if SE_Notifications then
                util.toast("Spawned with index of " .. i)
            end
    
        end
        noNeedModel(hash)
    end)

    menuAction(ptoxic, "Block LSC (4/4, top of the map)", {}, "", function ()
    local hash = 309416120
    requestModel(hash)
    while not hasModelLoaded(hash) do wait() end
    for i = 1, BA_iterations do
        local a1 = OBJECT.CREATE_OBJECT_NO_OFFSET(hash, 1182, 2650, 37, true, true, true)
        ENTITY.SET_ENTITY_HEADING(a1, 88+180)

        netIt(a1, pid)
        wait(100)

        local b1 = OBJECT.CREATE_OBJECT_NO_OFFSET(hash, 1176, 2650, 37, true, true, true)
        ENTITY.SET_ENTITY_HEADING(b1, 88+180)

        netIt(b1, pid)
        wait(100)

        local c1 = OBJECT.CREATE_OBJECT_NO_OFFSET(hash, 1185, 2647, 37, true, true, true)
        ENTITY.SET_ENTITY_HEADING(c1, 182)

        netIt(c1, pid)
        wait(100)

        local d1 = OBJECT.CREATE_OBJECT_NO_OFFSET(hash, 1172, 2646, 37, true, true, true)
        ENTITY.SET_ENTITY_HEADING(d1, 2)

        netIt(d1, pid)
        wait(100)

        --

        local a1_2 = OBJECT.CREATE_OBJECT_NO_OFFSET(hash, 1182, 2650, 39, true, true, true)
        ENTITY.SET_ENTITY_HEADING(a1_2, 88+180)

        netIt(a1_2, pid)
        wait(100)

        local b1_2 = OBJECT.CREATE_OBJECT_NO_OFFSET(hash, 1176, 2650, 39, true, true, true)
        ENTITY.SET_ENTITY_HEADING(b1_2, 88+180)

        netIt(b1_2, pid)
        wait(100)

        local c1_2 = OBJECT.CREATE_OBJECT_NO_OFFSET(hash, 1185, 2647, 39, true, true, true)
        ENTITY.SET_ENTITY_HEADING(c1_2, 182)

        netIt(c1_2, pid)
        wait(100)

        local d1_2 = OBJECT.CREATE_OBJECT_NO_OFFSET(hash, 1172, 2646, 39, true, true, true)
        ENTITY.SET_ENTITY_HEADING(d1_2, 2)

        netIt(d1_2, pid)
        wait(100)
        if SE_Notifications then
            util.toast("Spawned with index of " .. i)
        end
    end
    noNeedModel(hash)
    end)


    menu.divider(ptoxic, "Settings")

    menu.slider(ptoxic, "Iterations of spawn", {"spawniterations"}, "How many times the objects are spawned, to 'make them stick' to the player. Higher values = more time, but more chance of them sticking.", 1, 10, 4, 1, function(value)
        BA_iterations = value
        if SE_Notifications then
            util.toast("Iteratinos set to " .. BA_iterations)
        end
    end)

    menuAction(ptoxic, "Plague Crash", {"byeplague"}, "Works on very few menus, but works on legits.", function ()
        for i = 1, 10 do
        local cord = getEntityCoords(getPlayerPed(pid))
        requestModel(-930879665)
        wait(10)
        requestModel(3613262246)
        wait(10)
        requestModel(452618762)
        wait(10)
        while not hasModelLoaded(-930879665) do wait() end
        while not hasModelLoaded(3613262246) do wait() end
        while not hasModelLoaded(452618762) do wait() end
        local a1 = entities.create_object(-930879665, cord)
        wait(10)
        local a2 = entities.create_object(3613262246, cord)
        wait(10)
        local b1 = entities.create_object(452618762, cord)
        wait(10)
        local b2 = entities.create_object(3613262246, cord)
        wait(300)
        entities.delete_by_handle(a1)
        entities.delete_by_handle(a2)
        entities.delete_by_handle(b1)
        entities.delete_by_handle(b2)
        noNeedModel(452618762)
        wait(10)
        noNeedModel(3613262246)
        wait(10)
        noNeedModel(-930879665)
        wait(10)
        end
        if SE_Notifications then
            util.toast("Finished.")
        end
    end)

    -----------------------------------------------------------------------------------------------------------------------------------

    --[[
    menu.divider(playerOtherTrolling, "Less Toxic")
    menuAction(playerOtherTrolling, "Give them a wanted star!", {"gwant"}, "Kills some peds to give the player 1 (sometimes 2) wanted star(s).", function ()
        local hash = joaat("G_M_M_ChiGoon_02")
        local ped = getPlayerPed(pid)
        local c = getEntityCoords(ped)
        local myped = getLocalPed()
        requestModel(hash)
        while not hasModelLoaded(hash) do wait() end
        local peds = {}
        for i = 1, 5 do
            peds[i] = PED.CREATE_PED(24, hash, c.x, c.y, c.z + 10, 0, true, false)
            wait(10)
        end
        SE_add_owned_explosion(ped, c.x, c.y, c.z + 10, 2, 20, false, true, 0)
        SE_add_owned_explosion(ped, c.x, c.y, c.z + 9, 2, 20, false, true, 0)
        SE_add_owned_explosion(ped, c.x, c.y, c.z + 8, 2, 20, false, true, 0)
        wait(3000)
        for i = 1, #peds do
            entities.delete_by_handle(peds[i])
        end
        noNeedModel(hash)
    end)
    ]]

    -----------------------------------------------------------------------------------------------------------------------------------

    menuAction(playerTools, "God Check", {"godcheck"}, "", function()
        if (players.is_godmode(pid) and not players.is_in_interior(pid)) then
            util.toast(players.get_name(pid) .. " is in godmode!")
        elseif (players.is_in_interior(pid)) then
            util.toast(players.get_name(pid) .. " is in an interior!")
        else
            util.toast(players.get_name(pid) .. " is not in godmode!")
        end
    end)

    --preload
    SE_waittime = 1000
    menuToggleLoop(playerTools, "Move Check", {"movecheck"}, "Notifies you if the selected player is moving. Useful for people who were AFK.", function ()
        local pped = getPlayerPed(pid)
        local pcoords1 = getEntityCoords(pped)
        wait(SE_waittime)
        local pcoords2 = getEntityCoords(pped)
        if pcoords1.x ~= pcoords2.x or pcoords1.y ~= pcoords2.y or pcoords1.z ~= pcoords2.z then
            local playerName = tostring(PLAYER.GET_PLAYER_NAME(pid))
            util.toast(playerName .. " is moving!")
        end
    end)

    menu.slider(playerTools, "Move Check Interval (ms)", {"movecheckms"}, "How many milliseconds need to pass for it to check for movement, 1000ms = 1sec", 1, 60000, 1000, 100, function(value)
        SE_waittime = value
        if SE_Notifications then
            util.toast("Set move check interval to " .. SE_waittime)
        end
    end)

    menu.divider(playerTools, "Debug Features, in Testing/for testing.")

    Ptools_PanTable = {}
    Ptools_PanCount = 1
    Ptools_FishPan = 20

    menuAction(playerTools, "Pan.", {"pan"}, "Pan feature.", function ()
        local targetped = getPlayerPed(pid)
        local targetcoords = getEntityCoords(targetped)

        local hash = joaat("tug")
        requestModel(hash)
        while not hasModelLoaded(hash) do wait() end

        for i = 1, Ptools_FishPan do
            Ptools_PanTable[Ptools_PanCount] = VEHICLE.CREATE_VEHICLE(hash, targetcoords.x, targetcoords.y, targetcoords.z, 0, true, true, true)
            ----
            local netID = NETWORK.NETWORK_GET_NETWORK_ID_FROM_ENTITY(Ptools_PanTable[Ptools_PanCount])
            NETWORK.NETWORK_REQUEST_CONTROL_OF_ENTITY(Ptools_PanTable[Ptools_PanCount])
            NETWORK.NETWORK_REQUEST_CONTROL_OF_NETWORK_ID(netID)
            NETWORK.SET_NETWORK_ID_EXISTS_ON_ALL_MACHINES(netID)
            NETWORK.SET_NETWORK_ID_CAN_MIGRATE(netID, false)
            NETWORK.SET_NETWORK_ID_ALWAYS_EXISTS_FOR_PLAYER(netID, pid, true)
            ENTITY.SET_ENTITY_AS_MISSION_ENTITY(Ptools_PanTable[Ptools_PanCount], true, false)
            ENTITY.SET_ENTITY_VISIBLE(Ptools_PanTable[Ptools_PanCount], false, 0)
            ----
            if SE_Notifications then
                util.toast("Spawned with index of " .. Ptools_PanCount)
            end
            Ptools_PanCount = Ptools_PanCount + 1
        end
    end)

    --preload

    menu.slider(playerTools, "Number of fried fish.", {"friedfish"}, "The number of flippity flops", 1, 300, 20, 1, function(value)
        Ptools_FishPan = value
    end)

    menuAction(playerTools, "Remove Pan.", {"rmpan"}, "Yep", function ()
        for x = 1, 5, 1 do
            for i = 1, #Ptools_PanTable do
                entities.delete_by_handle(Ptools_PanTable[i])
                wait(10)
            end
        end
        --
        Ptools_PanCount = 1
        Ptools_PanTable = {}
        noNeedModel(util.joaat("tug"))
    end)

    menuToggleLoop(playerTools, "Remove Player Godmode (BETA)", {"rmgod"}, "Removes the player's godmode, if they're not on a good paid menu.", function ()
        util.trigger_script_event(1 << pid, {801199324, pid, 869796886})
    end)

    ----------------------------------------------------------------------------

    menu.divider(playerMain, "Settings")

    menuToggle(playerMain, "Blacklist from Silent Aimbot", {"aimblacklist"}, "Blacklists the selected player from silent aimbot.", function(on)
        if on then
            AIM_WHITELIST[pid] = true
        else
            AIM_WHITELIST[pid] = false
        end
    end)

    menuToggle(playerMain, "Blacklist from Auto Car-Suicide", {"carbombblacklist"}, "Blacklists the selected player from flagging a Car Suicide Explosion.", function(on)
        if on then
            CAR_S_BLACKLIST[pid] = true
        else
            CAR_S_BLACKLIST[pid] = false
        end
    end)

end

--skidded from LanceScript, hope Lance won't mind ;)
--[[deprecated code, ty vsus for newer version
for k,p in pairs(players.list(true, true, true)) do
    playerActionsSetup(p)
end
players.on_join(function(pid)
    playerActionsSetup(pid)
end)
]]

players.on_join(playerActionsSetup)
players.dispatch_on_join()

--[[ WEAPON HASHES
weapon hash: 584646201
actual gun: AP Pistol
--------------------------------------------------------------------
weapon hash: 727643628
actual gun: Ceramic Pistol
--------------------------------------------------------------------
weapon hash: 911657153
actual gun: Stun Gun
--------------------------------------------------------------------
weapon hash: 1171102963
actual gun: Stun Gun
--------------------------------------------------------------------
weapon hash: 1198879012
actual gun: Flare Gun
--------------------------------------------------------------------
weapon hash: 1470379660
actual gun: Perico Pistol
--------------------------------------------------------------------
weapon hash: 1593441988
actual gun: Combat Pistol
--------------------------------------------------------------------
weapon hash: 2285322324
actual gun: SNS Pistol Mk II
--------------------------------------------------------------------
weapon hash: 2441047180
actual gun: Navy Revolver
--------------------------------------------------------------------
weapon hash: 2548703416
actual gun: Double-Action Revolver
--------------------------------------------------------------------
weapon hash: 2578377531
actual gun: Pistol .50
--------------------------------------------------------------------
weapon hash: 2939590305
actual gun: Up-n-Atomizer
--------------------------------------------------------------------
weapon hash: 3218215474
actual gun: SNS Pistol
--------------------------------------------------------------------
weapon hash: 3219281620
actual gun: Pistol Mk II
--------------------------------------------------------------------
weapon hash: 3249783761
actual gun: Heavy Revolver
--------------------------------------------------------------------
weapon hash: 3415619887
actual gun: Heavy Revolver Mk II
--------------------------------------------------------------------
weapon hash: 3523564046
actual gun: Heavy Pistol
--------------------------------------------------------------------
weapon hash: 3696079510
actual gun: Marksman Pistol
--------------------------------------------------------------------
weapon hash: 171789620
actual gun: Combat PDW
--------------------------------------------------------------------
weapon hash: 324215364
actual gun: Micro SMG
--------------------------------------------------------------------
weapon hash: 736523883
actual gun: SMG
--------------------------------------------------------------------
weapon hash: 1198256469
actual gun: Unholy Hellbringer
--------------------------------------------------------------------
weapon hash: 1627465347
actual gun: Gusenberg Sweeper
--------------------------------------------------------------------
weapon hash: 2024373456
actual gun: SMG Mk II
--------------------------------------------------------------------
weapon hash: 2144741730
actual gun: Combat MG
--------------------------------------------------------------------
weapon hash: 2634544996
actual gun: MG
--------------------------------------------------------------------
weapon hash: 3173288789
actual gun: Mini SMG
--------------------------------------------------------------------
weapon hash: 3675956304
actual gun: Machine Pistol
--------------------------------------------------------------------
weapon hash: 3686625920
actual gun: Combat MG Mk II
--------------------------------------------------------------------
weapon hash: 4024951519
actual gun: Assault SMG
--------------------------------------------------------------------
weapon hash: 961495388
actual gun: Assault Rifle Mk II
--------------------------------------------------------------------
weapon hash: 1649403952
actual gun: Compact Rifle
--------------------------------------------------------------------
weapon hash: 2132975508
actual gun: Bullpup Rifle
--------------------------------------------------------------------
weapon hash: 2210333304
actual gun: Carbine Rifle
--------------------------------------------------------------------
weapon hash: 2228681469
actual gun: Bullpup Rifle Mk II
--------------------------------------------------------------------
weapon hash: 2526821735
actual gun: Special Carbine Mk II
--------------------------------------------------------------------
weapon hash: 2636060646
actual gun: Military Rifle
--------------------------------------------------------------------
weapon hash: 2937143193
actual gun: Advanced Rifle
--------------------------------------------------------------------
weapon hash: 3220176749
actual gun: Assault Rifle
--------------------------------------------------------------------
weapon hash: 3231910285
actual gun: Special Carbine
--------------------------------------------------------------------
weapon hash: 3347935668
actual gun: Heavy Rifle
--------------------------------------------------------------------
weapon hash: 4208062921
actual gun: Carbine Rifle Mk II
--------------------------------------------------------------------
weapon hash: 100416529
actual gun: Sniper Rifle
--------------------------------------------------------------------
weapon hash: 177293209
actual gun: Heavy Sniper Mk II
--------------------------------------------------------------------
weapon hash: 205991906
actual gun: Heavy Sniper
--------------------------------------------------------------------
weapon hash: 1785463520
actual gun: Marksman Rifle Mk II
--------------------------------------------------------------------
weapon hash: 3342088282
actual gun: Marksman Rifle
--------------------------------------------------------------------
weapon hash: 419712736
actual gun: Pipe Wrench
--------------------------------------------------------------------
weapon hash: 940833800
actual gun: Stone Hatchet
--------------------------------------------------------------------
weapon hash: 1141786504
actual gun: Golf Club
--------------------------------------------------------------------
weapon hash: 1317494643
actual gun: Hammer
--------------------------------------------------------------------
weapon hash: 1737195953
actual gun: Nightstick
--------------------------------------------------------------------
weapon hash: 2227010557
actual gun: Crowbar
--------------------------------------------------------------------
weapon hash: 2343591895
actual gun: Flashlight
--------------------------------------------------------------------
weapon hash: 2460120199
actual gun: Antique Cavalry Dagger
--------------------------------------------------------------------
weapon hash: 2484171525
actual gun: Pool Cue
--------------------------------------------------------------------
weapon hash: 2508868239
actual gun: Baseball Bat
--------------------------------------------------------------------
weapon hash: 2578778090
actual gun: Knife
--------------------------------------------------------------------
weapon hash: 3441901897
actual gun: Battle Axe
--------------------------------------------------------------------
weapon hash: 3638508604
actual gun: Knuckle Duster
--------------------------------------------------------------------
weapon hash: 3713923289
actual gun: Machete
--------------------------------------------------------------------
weapon hash: 3756226112
actual gun: Switchblade
--------------------------------------------------------------------
weapon hash: 4191993645
actual gun: Hatchet
--------------------------------------------------------------------
weapon hash: 4192643659
actual gun: Bottle
--------------------------------------------------------------------
weapon hash: 94989220
actual gun: Combat Shotgun
--------------------------------------------------------------------
weapon hash: 317205821
actual gun: Sweeper Shotgun
--------------------------------------------------------------------
weapon hash: 487013001
actual gun: Pump Shotgun
--------------------------------------------------------------------
weapon hash: 984333226
actual gun: Heavy Shotgun
--------------------------------------------------------------------
weapon hash: 1432025498
actual gun: Pump Shotgun Mk II
--------------------------------------------------------------------
weapon hash: 2017895192
actual gun: Sawed-Off Shotgun
--------------------------------------------------------------------
weapon hash: 2640438543
actual gun: Bullpup Shotgun
--------------------------------------------------------------------
weapon hash: 2828843422
actual gun: Musket
--------------------------------------------------------------------
weapon hash: 3800352039
actual gun: Assault Shotgun
--------------------------------------------------------------------
weapon hash: 4019527611
actual gun: Double Barrel Shotgun
--------------------------------------------------------------------
weapon hash: 125959754
actual gun: Compact Grenade Launcher
--------------------------------------------------------------------
weapon hash: 1119849093
actual gun: Minigun
--------------------------------------------------------------------
weapon hash: 1672152130
actual gun: Homing Launcher
--------------------------------------------------------------------
weapon hash: 1752584910
actual gun: RPG
--------------------------------------------------------------------
weapon hash: 1834241177
actual gun: Railgun
--------------------------------------------------------------------
weapon hash: 2138347493
actual gun: Firework Launcher
--------------------------------------------------------------------
weapon hash: 2726580491
actual gun: Grenade Launcher
--------------------------------------------------------------------
weapon hash: 2982836145
actual gun: RPG
--------------------------------------------------------------------
weapon hash: 3056410471
actual gun: Widowmaker
--------------------------------------------------------------------
weapon hash: 3676729658
actual gun: Compact EMP Launcher
--------------------------------------------------------------------
weapon hash: 101631238
actual gun: Fire Extinguisher
--------------------------------------------------------------------
weapon hash: 126349499
actual gun: Snowball
--------------------------------------------------------------------
weapon hash: 406929569
actual gun: Fertilizer Can
--------------------------------------------------------------------
weapon hash: 600439132
actual gun: Ball
--------------------------------------------------------------------
weapon hash: 615608432
actual gun: Molotov
--------------------------------------------------------------------
weapon hash: 741814745
actual gun: Sticky Bomb
--------------------------------------------------------------------
weapon hash: 883325847
actual gun: Jerry Can
--------------------------------------------------------------------
weapon hash: 1233104067
actual gun: Flare
--------------------------------------------------------------------
weapon hash: 2481070269
actual gun: Grenade
--------------------------------------------------------------------
weapon hash: 2694266206
actual gun: BZ Gas
--------------------------------------------------------------------
weapon hash: 2874559379
actual gun: Proximity Mine
--------------------------------------------------------------------
weapon hash: 3125143736
actual gun: Pipe Bomb
--------------------------------------------------------------------
weapon hash: 3126027122
actual gun: Hazardous Jerry Can
--------------------------------------------------------------------
weapon hash: 4256991824
actual gun: Tear Gas
--------------------------------------------------------------------
]]

--[[

menu.action(
        explosions,
        "Airstrike",
        {"orbairstrike"},
        "",
        function(on_click)
            local selectedPlayer = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)
            local playerPed = PLAYER.PLAYER_PED_ID()
            local coords = ENTITY.GET_ENTITY_COORDS(selectedPlayer, 1)
            local airStrike = MISC.GET_HASH_KEY("WEAPON_AIRSTRIKE_ROCKET")
            WEAPON.REQUEST_WEAPON_ASSET(airStrike, 31, false)
            while not WEAPON.HAS_WEAPON_ASSET_LOADED(airStrike) do
                util.yield()
            end
            MISC.SHOOT_SINGLE_BULLET_BETWEEN_COORDS(
                coords.x,
                coords.y,
                coords.z + 50,
                coords.x,
                coords.y,
                coords.z,
                250,
                1,
                airStrike,
                playerPed,
                1,
                0,
                -1.0
            )
        end
    )
]]