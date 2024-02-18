local QBCore = exports[Config.Core]:GetCoreObject()
local TitmerData = {}

local WebHooks = { -- Has to match with Config.AuthJobs list
    ['police'] = '',
    ['ambulance'] = '',
    ['mechanic'] = '',
    ['cardealer'] = '',
    ['japan'] = '',
    ['bahama'] = '',
}

RegisterNetEvent("kael-dutylog:server:userjoined", function(Job, Duty)
    local Player = QBCore.Functions.GetPlayer(source)
    if not Player then return end
    local CitizenID = Player.PlayerData.citizenid
    local PlayerName = Player.PlayerData.charinfo.firstname .. ' ' .. Player.PlayerData.charinfo.lastname .. ' (' .. Player.PlayerData.name .. ')'
    local DiscordID  = QBCore.Functions.GetIdentifier(source, 'discord')
    DiscordID = DiscordID:gsub("discord:", "")
    local License = Player.PlayerData.license

    if not TitmerData[CitizenID] and Config.AuthJobs[Job] and Duty then 
        TitmerData[CitizenID] = {
            job = Job,
            startTime = os.time(),
            startDate = os.date("%d/%m/%Y %X"),
        }
        SendOnDutyLogToDiscord(PlayerName, Job, DiscordID, License)
    end
end)

RegisterNetEvent("kael-dutylog:server:onDuty", function(Job, Duty)
    local Player = QBCore.Functions.GetPlayer(source)
    if not Player then return end
    local CitizenID = Player.PlayerData.citizenid
    local PlayerName = Player.PlayerData.charinfo.firstname .. ' ' .. Player.PlayerData.charinfo.lastname .. ' (' .. Player.PlayerData.name .. ')'
    local DiscordID  = QBCore.Functions.GetIdentifier(source, 'discord')
    DiscordID = DiscordID:gsub("discord:", "")
    local License = Player.PlayerData.license

    if not TitmerData[CitizenID] and Config.AuthJobs[Job] and Duty then 
        TitmerData[CitizenID] = {
            job = Job,
            startTime = os.time(),
            startDate = os.date("%d/%m/%Y %X"),
        }
        SendOnDutyLogToDiscord(PlayerName, Job, DiscordID, License)
    end
end)

RegisterNetEvent("kael-dutylog:server:offDuty", function(Job, Duty)
    local Player = QBCore.Functions.GetPlayer(source)
    if not Player then return end
    local CitizenID = Player.PlayerData.citizenid
    local PlayerName = Player.PlayerData.charinfo.firstname .. ' ' .. Player.PlayerData.charinfo.lastname .. ' (' .. Player.PlayerData.name .. ')'
    local DiscordID  = QBCore.Functions.GetIdentifier(source, 'discord')
    DiscordID = DiscordID:gsub("discord:", "")
    local License = Player.PlayerData.license
    if TitmerData[CitizenID] and Config.AuthJobs[Job] and not Duty then 
        local Duration = os.time() - TitmerData[CitizenID].startTime
        local Date = TitmerData[CitizenID].startDate
        local TimeText = CalculateTimeText(Duration)
        local Message = "Player Name: **" .. PlayerName .. "**\nDiscordID: <@" .. DiscordID .. ">\nLicense: **" .. License .. "**\nShift Duration: **__" .. TimeText .. "__**\n Start date: **" .. Date .. "**\nEnd date: **" .. os.date("%d/%m/%Y %X") .. "**"
        TitmerData[CitizenID] = nil
        SendTimeLogToDiscord(Message, Job)
    end
end)

AddEventHandler("playerDropped", function(reason)
    local source = source
    local Player = QBCore.Functions.GetPlayer(source)
    if not Player then return end
    local CitizenID = Player.PlayerData.citizenid
    local Job = Player.PlayerData.job.name
    local PlayerName = Player.PlayerData.charinfo.firstname .. ' ' .. Player.PlayerData.charinfo.lastname .. ' (' .. Player.PlayerData.name .. ')'
    local DiscordID  = QBCore.Functions.GetIdentifier(source, 'discord')
    DiscordID = DiscordID:gsub("discord:", "")
    local License = Player.PlayerData.license
    if TitmerData[CitizenID] and Config.AuthJobs[Job]then 
        local Duration = os.time() - TitmerData[CitizenID].startTime
        local Date = TitmerData[CitizenID].startDate
        local TimeText = CalculateTimeText(Duration)
        local Message = "Player Name: **" .. PlayerName .. "**\nDiscordID: <@" .. DiscordID .. ">\nLicense: **" .. License .. "**\nShift Duration: **__" .. TimeText .. "__**\n Start date: **" .. Date .. "**\nEnd date: **" .. os.date("%d/%m/%Y %X") .. "**"
        TitmerData[CitizenID] = nil
        SendTimeLogToDiscord(Message, Job)
    end
end)


function SendOnDutyLogToDiscord(PlayerName, Job, DiscordID, License)
    local embedData = {
        { ['title']         = PlayerName .. " | Going On Duty", ['color'] = Config.AuthJobs[Job].Color,
          ['footer']        = { ['text'] = os.date( "!%a %b %d, %H:%M", os.time() + 6 * 60 * 60 ), },
          ['description']   = "Discord: <@" .. DiscordID .. ">\nLicense: **" .. License .. "**",
          ['author']        = { ['name'] = Config.AuthJobs[Job].LogTitle, ['icon_url'] = Config.AuthJobs[Job].IconURL, },
        }
    }
    if WebHooks[Job] and WebHooks[Job] ~= '' then 
        local WebHook = WebHooks[Job]
        PerformHttpRequest(WebHook, function() end, 'POST', json.encode({ username = Config.AuthJobs[Job].LogTitle, embeds = embedData}), { ['Content-Type'] = 'application/json' })
    end
end

function SendTimeLogToDiscord(Message, Job)
    local embedData = {
        { ["color"]     = Config.AuthJobs[Job].Color, ["title"] = "**".. Config.AuthJobs[Job].LogTitle .."**", ["description"] = Message,
          ["footer"]    = { ["text"] = Config.AuthJobs[Job].LogTitle .. " | " .. os.date( "!%a %b %d, %H:%M", os.time() + 6 * 60 * 60 ), }, } }
    if WebHooks[Job] and WebHooks[Job] ~= '' then 
        local WebHook = WebHooks[Job]
        PerformHttpRequest(WebHook, function() end, 'POST', json.encode({ username = Config.AuthJobs[Job].LogTitle, embeds = embedData}), { ['Content-Type'] = 'application/json' })
    end
end


function CalculateTimeText(Duration)
    local TimeText = ""
    if Duration > 0 and Duration < 60 then
        TimeText = tostring(math.floor(Duration)) .. " Seconds"
    elseif Duration >= 60 and Duration < 3600 then
        TimeText = tostring(math.floor(Duration / 60)) .. " Minutes"
    elseif Duration >= 3600 then
        TimeText = tostring(math.floor(Duration / 3600) .. " Hours, "..tostring(math.floor(math.fmod(Duration, 3600)) / 60)) .. " Minutes"
    end
    return TimeText
end
