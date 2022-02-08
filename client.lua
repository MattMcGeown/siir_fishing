local isFishing = false

local netid = nil
local baitUsed = nil
local inv = exports.ox_inventory

local legalFishing = PolyZone:Create({
    Config.LegalFishing.ZoneOne.pos1,
    Config.LegalFishing.ZoneOne.pos2,
    Config.LegalFishing.ZoneOne.pos3,
    Config.LegalFishing.ZoneOne.pos4,
    Config.LegalFishing.ZoneOne.pos5,
    Config.LegalFishing.ZoneOne.pos6,
    Config.LegalFishing.ZoneOne.pos7,
    Config.LegalFishing.ZoneOne.pos8,
}, {
    name="legal_fishing",
    minZ=10.0,
    maxZ=40.0,
    debugGrid=true,
    gridDivisions=25
})

local illegalFishing = PolyZone:Create({
    Config.IllegalFishing.ZoneOne.pos1,
    Config.IllegalFishing.ZoneOne.pos2,
    Config.IllegalFishing.ZoneOne.pos3,
    Config.IllegalFishing.ZoneOne.pos4,
    Config.IllegalFishing.ZoneOne.pos5,
    Config.IllegalFishing.ZoneOne.pos6,
}, {
    name="illegal_fishing",
    minZ=0.0,
    maxZ=50.0,
    debugGrid=true,
    gridDivisions=25
})

Citizen.CreateThread(function()
    FishingSpot(vector3(1305.3000, 4237.5000, 33.9000), 'Fishing')
end)

function FishingSpot(coords, label)
    local blip = AddBlipForCoord(coords)
    SetBlipSprite(blip, 68)
    SetBlipScale(blip, 0.8)
    SetBlipColour(blip, 3)
    SetBlipAsShortRange(blip, true)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString(label)
    EndTextCommandSetBlipName(blip)
end

local function Notify(style, position, duration, message, sound)
    if not position or position == 'default' then
        position = 'middle-right'
    end

    if not duration or duration == 'default' then
        duration = 600
    end

    exports['t-notify']:Alert({
        style = style,
        position = position,
        duration = duration,
        message = message,
        sound = sound
    })
end

local function TensionText(string, tension)
    if tension >= 0 then
        SetTextColour(99, 255, 0, 255)
    end
    if tension > 60 then
        SetTextColour(255, 127, 0, 255)
    end
    if tension > 85 then
        SetTextColour(255, 0, 0, 255)
    end

    SetTextFont(0)
    SetTextProportional(1)
    SetTextScale(0.0, 0.3)
    SetTextDropshadow(0, 0, 0, 0, 255)
    SetTextEdge(1, 0, 0, 0, 255)
    SetTextJustification(0)
    SetTextDropShadow()
    SetTextOutline()
    SetTextCentre(true)
    SetTextEntry("STRING")
    AddTextComponentString(string)
    DrawText(0.45, 0.405)
end

local function CheckZone()
    local playerPed = ESX.PlayerData
    local playerCoords = GetEntityCoords(playerPed.ped)
    local currentZone = nil

    if legalFishing:isPointInside(playerCoords) then
        currentZone = 'LegalFishing'
    elseif illegalFishing:isPointInside(playerCoords) then
        currentZone = 'IllegalFishing'
    end

    return currentZone
end

local function FishingVector(position, angle, distance)
    local x = distance * math.cos(angle)
    local y = distance * math.sin(angle)
    local result = vector3(position.x + x, position.y + y, position.z)
    return result
end

local function RNG(a, b)
    math.randomseed(GetGameTimer())
    return math.random(a, b)
end

local function StopFishing(restart)
    local playerPed = ESX.PlayerData
    local playerCoords = GetEntityCoords(playerPed.ped)
    isFishing = false
    if not restart or restart == nil then
        ClearPedTasks(playerPed.ped)
        if netid ~= nil then
            DetachEntity(NetToObj(netid), 1, 1)
            DeleteEntity(NetToObj(netid))
            SetModelAsNoLongerNeeded('prop_fishing_rod_01')
        end
        Wait(300)
        ClearAreaOfObjects(playerCoords.x, playerCoords.y, playerCoords.z, 1.0, 0)
        netid = nil
    else
        Wait(800)
        TriggerEvent('siir_fishing:castLine', CheckZone(), RNG(30, 80))
    end
end

RegisterNetEvent('siir_fishing:equipRod')
AddEventHandler('siir_fishing:equipRod', function()
    local playerPed = ESX.PlayerData
    local playerCoords = GetEntityCoords(playerPed.ped)
    
    RequestModel('prop_fishing_rod_01')
    while not HasModelLoaded('prop_fishing_rod_01') do
        Citizen.Wait(0)
    end

    -- If prop doesn't exist (based on network id) then create and network
    if not netid then
        local prop = CreateObject(GetHashKey('prop_fishing_rod_01'), playerCoords.x, playerCoords.y, playerCoords.z, true, true, true)
        netid = ObjToNet(prop)

        SetNetworkIdExistsOnAllMachines(netid, true)
        NetworkSetNetworkIdDynamic(netid, true)
        SetNetworkIdCanMigrate(netid, false)
        AttachEntityToEntity(prop, playerPed.ped, GetPedBoneIndex(playerPed.ped, 18905), 0.13, 0.04, 0.0, 40.0, 180.0, -180.0, true, true, false, true, true, true)
    else
        -- If prop does exist (based on network id) then detach and delete
        DetachEntity(NetToObj(netid), 1, 1)
        DeleteEntity(NetToObj(netid))
        SetModelAsNoLongerNeeded('prop_fishing_rod_01')
        netid = nil
    end
end)

RegisterNetEvent('siir_fishing:equipBait')
AddEventHandler('siir_fishing:equipBait', function(bait)
    ESX.TriggerServerCallback('siir_fishing:checkRod', function(cb)
        if cb and netid then
            local playerPed = ESX.PlayerData
            local playerCoords = GetEntityCoords(playerPed.ped)
            local playerRot = math.rad(GetEntityRotation(playerPed.ped).z + 90)
            local distance = RNG(30, 80)
            -- Get current fishing zone
            local fishingZone = CheckZone()
            
            -- Don't allow fishing outside of defined zones
            if fishingZone == nil then
                Notify('info', 'default', 'default', Locale('not_here'), false)
        
            elseif fishingZone ~= nil then
                local fishingPoint = FishingVector(playerCoords, playerRot, distance) -- Coords for where player is facing
                local facingWater, waterHeight = GetWaterHeight(fishingPoint.x, fishingPoint.y, fishingPoint.z) -- Is player facing water, water height at coords
        
                if facingWater then
                    inv:Progress({
                        duration = 1000,
                        label = 'Using Bait',
                        useWhileDead = false,
                        canCancel = true,
                        disable = {
                            move = true,
                            car = true,
                            combat = true,
                            mouse = false
                        },
                        anim = {
                            dict = 'missheistdockssetup1clipboard@base',
                            clip = 'base',
                            flags = 49
                        }
                    },function(cancel)
                        if not cancel then
                            -- Do Something If Action Wasn't Cancelled
                            TriggerEvent('siir_fishing:castLine', fishingZone, distance)
                            TriggerServerEvent('siir_fishing:removeItem')
                            baitUsed = bait
                        else
                            -- Do Something If Action Was Cancelled
                            StopFishing()
                        end
                    end)
                else
                    Notify('info', 'default', 'default', Locale('on_land'), false)
                end
            end
        elseif not netid then
            Notify('info', 'default', 'default', Locale('equip_rod'), false)
        else
            Notify('info', 'default', 'default', Locale('no_rod'), false)
        end
    end, 'fish_rod')

end)

RegisterNetEvent('siir_fishing:castLine')
AddEventHandler('siir_fishing:castLine', function(fishingZone, castDistance)
    isFishing = true

    local playerPed = ESX.PlayerData
    local playerCoords = GetEntityCoords(playerPed.ped)
    local playerRot = math.rad(GetEntityRotation(playerPed.ped).z + 90)
    local biteTimer = RNG(3, 10) * 1000
    local markerPos = FishingVector(playerCoords, playerRot, castDistance)
    local facingWater, waterHeight = GetWaterHeight(playerCoords.x, playerCoords.y, playerCoords.z)

    -- if netid ~= nil then
    --     DetachEntity(NetToObj(netid), 1, 1)
    --     DeleteEntity(NetToObj(netid))
    --     SetModelAsNoLongerNeeded('prop_fishing_rod_01')
    -- end

    Wait(200)
    Notify('info', 'default', 'default', Locale('line_cast'), false)
    TaskStartScenarioAtPosition(playerPed.ped, "WORLD_HUMAN_STAND_FISHING", vec3(GetEntityCoords(playerPed.ped)), GetEntityHeading(playerPed.ped), 0, 0, 0)
    -- Disable inv access

    while isFishing do
        Citizen.Wait(0)
        DrawMarker(3, markerPos.x, markerPos.y, waterHeight+3, 0.0, 0.0, 0.0, 0.0, 180.0, 0.0, 1.5, 1.5, 1.5, 204, 255, 255, 255, false, false, 2, true, false, false, false)
        biteTimer = biteTimer - 10

        if biteTimer <= 0 then
            TriggerEvent('siir_fishing:hookFish', fishingZone, castDistance, markerPos, waterHeight)
            break
        end
        
        if IsControlJustReleased(0, 73) then
            Notify('info', 'default', 'default', Locale('canceled'), false)
            StopFishing()
        end

        if IsControlJustPressed(0, 24) then
            StopFishing()
            Notify('error', false, false, Locale('too_soon'), false)
        end
    end
end)

RegisterNetEvent('siir_fishing:hookFish')
AddEventHandler('siir_fishing:hookFish', function(fishingZone, castDistance, markerPos, waterHeight)
    local playerPed = ESX.PlayerData
    local playerCoords = GetEntityCoords(playerPed.ped)
    local playerRot = math.rad(GetEntityRotation(playerPed.ped).z + 90)
    local markerPos = markerPos
    local hookTimer = 500
    local tension = 0
    local tensionMod = 0
    
    Notify('info', 'default', 'default', Locale('bite'), true)

    while true do
        Citizen.Wait(0)
        DrawMarker(32, markerPos.x, markerPos.y, waterHeight+3, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.5, 1.5, 1.5, 255, 255, 0, 255, false, false, 2, true, false, false, false)
        hookTimer = hookTimer - 1

        if hookTimer <= 0 then
            Notify('error', false, false, Locale('escaped'), false)
            StopFishing()
            break
        end
        if IsControlJustPressed(0, 24) then
            break
        end
    end
    while isFishing do
        Citizen.Wait(0)
        markerPos = FishingVector(playerCoords, playerRot, castDistance)
        local waterHeight = waterHeight

        DrawMarker(3, markerPos.x, markerPos.y, waterHeight+1, 0.0, 0.0, 0.0, 0.0, 180.0, 0.0, 0.8, 0.8, 0.8, 51, 204, 51, 255, true, false, 2, true, false, false, false)
        TensionText("Line Tension: " .. math.floor(tension) .. "%", tension)
        
        if IsControlJustPressed(0, 24) then
            tensionMod = RNG(5, 9)
        end
        if IsControlJustReleased(0, 24) then
            tensionMod = RNG(5, 9)
        end
        
        if IsControlJustReleased(0, 73) then
            Notify('info', 'default', 'default', Locale('canceled'), false)
            StopFishing()
            baitUsed = nil
        end
        
        if IsControlPressed(0, 24) then
            castDistance = castDistance - (tensionMod * 0.02)
            tension = tension + (tensionMod * 0.04)

            if castDistance < 0.30 then
                StopFishing(true)
                TriggerServerEvent('siir_fishing:giveItem', baitUsed, fishingZone)
                break
            end

            if tension >= 100 then
                StopFishing()
                baitUsed = nil
                Notify('error', 'default', 'default', Locale('line_broke'), false)
            end
        end

        if tension > 0 then
            tension = tension - (tensionMod * 0.01)
            castDistance = castDistance + (tensionMod * 0.003)
        elseif tension < 0 then
            StopFishing()
            baitUsed = nil
            Notify('error', 'default', 'default', Locale('escaped'), false)
        end
    end
end)

RegisterNetEvent('siir_fishing:spawnModel')
AddEventHandler('siir_fishing:spawnModel', function(model)
    RequestModel(model)
    while not HasModelLoaded(model) do
        Citizen.Wait(0)
    end
    
	local playerCoords = GetEntityCoords(ESX.PlayerData.ped)
	local ped = CreatePed(29, GetHashKey(model), playerCoords.x, playerCoords.y, playerCoords.z, 90.0, true, false)
	SetEntityHealth(ped, 0)
	DecorSetInt(ped, "propHack", 74)
	SetModelAsNoLongerNeeded(model)
	Wait(5000)
    DeletePed(ped)
end)