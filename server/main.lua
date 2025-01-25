ESX = exports["es_extended"]:getSharedObject()

RegisterNetEvent("condor_rac:payOther", function(id)
	local xPlayer = ESX.GetPlayerFromId(source)
	local xPlayer2 = ESX.GetPlayerFromId(id)
	if xPlayer.job.name ~= xPlayer2.job.name then
		exports.ox_inventory:AddItem(id, Config.PaymentItem, Config.defaultPayment, nil, 1, nil)
		TriggerClientEvent("condor_rac:enemyWon", id)
	end
end)

-- Questo dovrebbe essere l'attiva disattiva condor
local condorattivo = true

ESX.RegisterServerCallback("condor_rac:condorattivo", function (cb)
	cb(condorattivo)
end)

RegisterCommand("condorrac", function ()
	if condorattivo == true then
		condorattivo = false
		print(condorattivo)
	else
		if condorattivo == false then
			condorattivo = true
			print(condorattivo)
		end
	end
end)

-- Questo lo ha aggiunto brodo, fa un check della fazione in cui sei, se sei del rac ritorna true altrimenti ritorna false
ESX.RegisterServerCallback("condor_rac:check_job", function(source, cb)
	local xPlayer = ESX.GetPlayerFromId(source)
	local job = xPlayer.job.name
	if job == "rac" then
		fazione = "rac"
	else
		fazione = "noa"
	end
	cb(fazione)
end)

local activity = 0
local activitySource = 0
local cooldown = 0

RegisterServerEvent('condor_rac:pay')
AddEventHandler('condor_rac:pay', function(payment)
	local _source = source
	local xPlayer = ESX.GetPlayerFromId(_source)
	-- Rimpiazza "cartina" con l'item che si vuole dare come ricompensa
	-- Rimpiazza "10" con il numero di item che vuoi dare
	-- Copia la linea di codice se vuoi dare più di un item
	exports.ox_inventory:AddItem(_source, Config.PaymentItem, Config.defaultPayment, nil, 1, nil)
	-- Questo aggiunge la valuta
	-- xPlayer.addAccountMoney('money',tonumber(payment))
	
	--Add cooldown
	cooldown = Config.CooldownMinutes * 60000
end)

ESX.RegisterServerCallback('condor_rac:anycops',function(source, cb)
  local anycops = 0
  local playerList = ESX.GetPlayers()
  for i=1, #playerList, 1 do
    local _source = playerList[i]
    local xPlayer = ESX.GetPlayerFromId(_source)
    if xPlayer.job.name == 'noa' then
      anycops = anycops + 1
    end
  end
  cb(anycops)
end)

ESX.RegisterServerCallback('condor_rac:isActive',function(source, cb)
  cb(activity, cooldown)
end)

RegisterServerEvent('condor_rac:registerActivity')
AddEventHandler('condor_rac:registerActivity', function(value)
	activity = value
	if value == 1 then
		activitySource = source
		--Send notification to cops
		local xPlayers = ESX.GetPlayers()
		for i=1, #xPlayers, 1 do
			local xPlayer = ESX.GetPlayerFromId(xPlayers[i])
			if xPlayer.job.name == 'noa' then
				TriggerClientEvent('condor_rac:setcopnotification', xPlayers[i])
			end
		end
	else
		activitySource = 0
	end
end)

RegisterServerEvent('condor_rac:alertcops')
AddEventHandler('condor_rac:alertcops', function(cx,cy,cz)
	local source = source
	local xPlayer = ESX.GetPlayerFromId(source)
	local xPlayers = ESX.GetPlayers()
	
	for i=1, #xPlayers, 1 do
		local xPlayer = ESX.GetPlayerFromId(xPlayers[i])
		if xPlayer.job.name == 'noa' then
			TriggerClientEvent('condor_rac:setcopblip', xPlayers[i], cx,cy,cz)
		end
	end
end)

RegisterServerEvent('condor_rac:stopalertcops')
AddEventHandler('condor_rac:stopalertcops', function()
	local source = source
	local xPlayer = ESX.GetPlayerFromId(source)
	local xPlayers = ESX.GetPlayers()
	
	for i=1, #xPlayers, 1 do
		local xPlayer = ESX.GetPlayerFromId(xPlayers[i])
		if xPlayer.job.name == 'noa' then
			TriggerClientEvent('condor_rac:removecopblip', xPlayers[i])
		end
	end
end)

AddEventHandler('playerDropped', function ()
	local _source = source
	if _source == activitySource then
		--Remove blip for all cops
		local xPlayers = ESX.GetPlayers()
		for i=1, #xPlayers, 1 do
			local xPlayer = ESX.GetPlayerFromId(xPlayers[i])
			if xPlayer.job.name == 'noa' then
				TriggerClientEvent('condor_rac:removecopblip', xPlayers[i])
			end
		end
		--Set activity to 0
		activity = 0
		activitySource = 0
	end
end)

--Cooldown manager
AddEventHandler('onResourceStart', function(resource)
	while true do
		Wait(5000)
		if cooldown > 0 then
			cooldown = cooldown - 5000
		end
	end
end)
