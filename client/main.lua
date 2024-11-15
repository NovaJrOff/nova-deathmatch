local shared = require 'config.shared'
local config = require 'config.client'
Zones = {}
local zonedata = {}
local Blips = {}

local function GetRandomLocation()
    local locations = shared.zones[zonedata.zoneid].spawns
    local randomlocation = locations[math.random(1, #locations)]
    if randomlocation then
        SetEntityCoords(cache.ped, randomlocation.x, randomlocation.y, randomlocation.z - 1, false, false, false, false)
        SetEntityHeading(cache.ped, randomlocation.w)
        GiveWeaponToPed(cache.ped, joaat(shared.zones[zonedata.zoneid].weapon), 9999, false, true)
        SetCurrentPedWeapon(cache.ped, joaat(shared.zones[zonedata.zoneid].weapon), true)
        SetPedAmmo(cache.ped, cache.weapon, 9999)
    end
    SetPedArmour(cache.ped, 100)
    ResetEntityAlpha(cache.ped)
end
local function Respawn()
    Wait(5000)
    TriggerEvent('hospital:client:Revive')
    CreateThread(function()
        SetEntityAlpha(cache.ped, 120, false)
        SetEntityInvincible(cache.ped, true)
        SetCanAttackFriendly(cache.ped, false, false)
        Wait(5000)
        ResetEntityAlpha(cache.ped)
        SetEntityInvincible(cache.ped, false)
        SetCanAttackFriendly(cache.ped, true, true)
    end)

    GetRandomLocation()
end

local function CreateBlips(data)
    local blip = AddBlipForCoord(data.coords.x, data.coords.y, data.coords.z)
    SetBlipAsShortRange(blip, true)
    SetBlipColour(blip,27)
    SetBlipSprite(blip, 84)
    SetBlipDisplay(blip, 4)
    SetBlipScale(blip, 0.8)
    BeginTextCommandSetBlipName('STRING')
    AddTextComponentSubstringPlayerName('Deathmatch-' .. data.weapon)
    EndTextCommandSetBlipName(blip)
    Blips[#Blips + 1] = blip
end
local function onEnter(self)
    zonedata = self
    lib.callback.await('nova-deathmatch:server:setplayerdata', false, self)
    Respawn()
end
local function inside(self)
    if cache.weapon then
        if cache.weapon ~= joaat(shared.zones[self.zoneid].weapon) then
            GiveWeaponToPed(cache.ped, joaat(shared.zones[zonedata.zoneid].weapon), 9999, false, true)
            SetCurrentPedWeapon(cache.ped, joaat(shared.zones[zonedata.zoneid].weapon), true)
            SetPedAmmo(cache.ped, cache.weapon, 9999)
        end
    end
end

local function onExit(self)
    zonedata = {}
    ResetEntityAlpha(cache.ped)
    SetEntityInvincible(cache.ped, false)
    SetCanAttackFriendly(cache.ped, true, true)
    lib.callback.await('nova-deathmatch:server:setplayerdata', false, {})
end

AddEventHandler('gameEventTriggered', function(event, data)
    if event == 'CEventNetworkEntityDamage' then
        if not zonedata then return end
        local victim, attacker, victimDied, weapon = data[1], data[2], data[4], data[7]
        if not IsEntityAPed(victim) then return end
        if victimDied and NetworkGetPlayerIndexFromPed(victim) == PlayerId() and IsEntityDead(PlayerPedId()) then
            if IsEntityAPed(attacker) then
                TriggerServerEvent('nova-deathmatch:server:killed',
                    GetPlayerServerId(NetworkGetPlayerIndexFromPed(attacker)))
            end
            Respawn()
        end
    end
end)

CreateThread(function()
    for k, v in pairs(shared.zones) do
        CreateBlips(v)
        local zone = lib.zones.sphere({
            coords = v.coords,
            radius = v.radius,
            debug = config.debug,
            inside = inside,
            onEnter = function(self)
                self.zoneid = k
                onEnter(self)
            end,
            onExit = function(self)
                self.zoneid = k
                onExit(self)
            end
        })

        Zones[#Zones + 1] = zone
    end
end)
