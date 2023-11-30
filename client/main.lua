local QBCore = exports[Config.Core]:GetCoreObject()

RegisterNetEvent("QBCore:Client:OnPlayerLoaded", function()
    local PlayerData = QBCore.Functions.GetPlayerData()
    local PlayerJob = PlayerData.job
    local PlayerJobName = PlayerJob.name
    local PlayerDuty = PlayerJob.onduty
    TriggerServerEvent("kael-dutylog:server:userjoined", PlayerJobName, PlayerDuty)
end)

RegisterNetEvent("QBCore:Client:SetDuty", function(Duty)
    local PlayerData = QBCore.Functions.GetPlayerData()
    local PlayerJob = PlayerData.job
    local PlayerJobName = PlayerJob.name
    if Duty then
        TriggerServerEvent("kael-dutylog:server:onDuty", PlayerJobName, Duty)
    else
        TriggerServerEvent("kael-dutylog:server:offDuty", PlayerJobName, Duty)
    end
end)

AddEventHandler('onResourceStart', function(resourceName)
    if GetCurrentResourceName() ~= resourceName then return false end
    local PlayerData = QBCore.Functions.GetPlayerData()
    local PlayerJob = PlayerData.job
    local PlayerJobName = PlayerJob.name
    local PlayerDuty = PlayerJob.onduty
    TriggerServerEvent("kael-dutylog:server:userjoined", PlayerJobName, PlayerDuty)
end)