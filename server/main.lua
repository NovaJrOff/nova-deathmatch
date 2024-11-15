local PlayersData = {}

lib.callback.register('nova-deathmatch:server:setplayerdata', function(source, data)
    PlayersData[source] = data
    return true
end)


RegisterNetEvent('nova-deathmatch:server:killed', function(target)
    local src = source
    if PlayersData[target] then
        if PlayersData[src].zoneid == PlayersData[target].zoneid then
            lib.notify(src,
                {
                    description = "You were killed by " .. GetPlayerName(target) .. '-' .. target,
                    type = "error",
                    position = 'top',
                    style = {
                        backgroundColor = 'black',
                    },
                    duration = 5000,
                    iconAnimation = 'bounce',
                    alignIcon = 'center',
                    iconColor = 'red',
                    icon =
                    "fa-solid fa-skull"
                })
            lib.notify(target,
                {
                    description = "You killed " .. GetPlayerName(src) .. '-' .. src,
                    type = "success",
                    duration = 5000,
                    iconColor = 'yellow',
                    iconAnimation = 'shake',
                    style = {
                        backgroundColor = 'black'
                    },
                    position = 'top',
                    icon =
                    "fa-solid fa-gun",
                    alignIcon = 'center'
                })
        end
    end
end)
