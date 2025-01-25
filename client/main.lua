-- Roba dello script originale
local PlayerData              	= {}
local currentZone               = ''
local LastZone                  = ''
local CurrentAction             = nil
local CurrentActionMsg          = ''
local CurrentActionData         = {}
local alldeliveries             = {}
local randomdelivery            = 1
local isTaken                   = 0
local isDelivered               = 0
local car						= 0
local copblip
local deliveryblip

-- Roba aggiunta
local timerToEndMission 		= false		-- Tempo massimo per concludere la missione
local checkDistance 			= nil		-- Distanza tra lo spawn del veicolo e posizione attuale del giocatore
local checkDeath 				= false		-- Controllo se personaggio vivo o morto
local checkInVehicle 			= false		-- Controlla se sei nel veicolo
local checkPayloadHealth 		= false  	-- Tiene traccia della vita del carico
local firstWaveSpawned		 	= false		-- Tiene traccia dello spawn della prima ondata
local secondWaveSpawned 		= false		-- Tiene traccia dello spawn della seconda ondata
local thirdWaveSpawned 			= false		-- Tiene traccia dello spawn della terza ondata

ESX = exports["es_extended"]:getSharedObject()

AddEventHandler('playerDropped', function ()
	AbortDelivery()
end)

RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(xPlayer)
  PlayerData = xPlayer
end)

RegisterNetEvent('esx:setJob')
AddEventHandler('esx:setJob', function(job)
  PlayerData.job = job
end)

--Add all deliveries to the table
Citizen.CreateThread(function()
	local deliveryids = 1
	for k,v in pairs(Config.Delivery) do
		table.insert(alldeliveries, {
				id = deliveryids,
				posx = v.Pos.x,
				posy = v.Pos.y,
				posz = v.Pos.z,
				payment = v.Payment,
				car = v.Cars,
		})
		deliveryids = deliveryids + 1  
	end
end)

function SpawnCar()

	-- Controllo che sei della fazione corretta
	ESX.TriggerServerCallback("revolt:check_job", function(fazione)
		if fazione == "rac" then

			-- Se lo script è attivo e non in cooldown
			ESX.TriggerServerCallback('condor_rac:isActive', function(isActive, cooldown)
				if cooldown <= 0 then
					if isActive == 0 then
						-- Se ci sono abbastanza membri della fazione opposta
						ESX.TriggerServerCallback('condor_rac:anycops', function(anycops)
							if anycops >= Config.CopsRequired then
								-- Se sei della fazione corretta
						

								--Get a random delivery point
								randomdelivery = math.random(1,#alldeliveries)
								
								-- Cancella i veicoli nella zona di spawn (così da non glitchare ma macchina)
								ClearAreaOfVehicles(Config.VehicleSpawnPoint.Pos.x, Config.VehicleSpawnPoint.Pos.y, Config.VehicleSpawnPoint.Pos.z, 10.0, false, false, false, false, false)
								
								-- Rimuovo il vecchio veicolo (se la scorsa consegna si è conclusa bene non fa nulla)
								SetEntityAsNoLongerNeeded(car)
								DeleteVehicle(car)
								RemoveBlip(deliveryblip)
								

								--Get random car
								randomcar = math.random(1,#alldeliveries[randomdelivery].car)

								--Spawn Car
								local vehiclehash = GetHashKey(alldeliveries[randomdelivery].car[randomcar])
								RequestModel(vehiclehash)
								while not HasModelLoaded(vehiclehash) do
									RequestModel(vehiclehash)
									Citizen.Wait(1)
								end
								car = CreateVehicle(vehiclehash, Config.VehicleSpawnPoint.Pos.x, Config.VehicleSpawnPoint.Pos.y, Config.VehicleSpawnPoint.Pos.z, Config.VehicleSpawnPoint.Pos.alpha, true, false)
								SetEntityAsMissionEntity(car, true, true)
								
								SetPedIntoVehicle(GetPlayerPed(-1), car, -1)

								TriggerEvent("brodoPlayer:PlayOnOne", "condor/condor_rac_startMission", 1.0)

								-- Questo abilita le modifiche
								-- SetVehicleModKit(car, 0)

								-- ToggleVehicleMod(car, 18, true)		-- Turbo
								-- SetVehicleMod(car, 16, 4, true) 	-- armatura (veicolo commerciali e di servizio non ce l'hanno)
								SetVehicleTyresCanBurst(car, false) -- Gomme antiproiettile
								
								--Set delivery blip
								deliveryblip = AddBlipForCoord(alldeliveries[randomdelivery].posx, alldeliveries[randomdelivery].posy, alldeliveries[randomdelivery].posz)
								SetBlipSprite(deliveryblip, 1)
								SetBlipDisplay(deliveryblip, 4)
								SetBlipScale(deliveryblip, 1.0)
								SetBlipColour(deliveryblip, 5)
								SetBlipAsShortRange(deliveryblip, true)
								BeginTextCommandSetBlipName("STRING")
								AddTextComponentString("Delivery point")
								EndTextCommandSetBlipName(deliveryblip)
								
								SetBlipRoute(deliveryblip, true)

								--Register acitivity for server
								TriggerServerEvent('condor_rac:registerActivity', 1)
								
								--For delivery blip
								isTaken = 1
								--For delivery blip
								isDelivered = 0

								-- Inizio a controllare quando muore
								checkForDeath()
								checkCaricoHealth()

								-- Inizio a calcolare la distanza dallo spawn del veicolo (per spawnare i nemici)
								checkDistanceFromSpawn()

								-- Inizio a controllare quando esce dal veicolo
								checkInsideVeh()

								-- Timer di conclusione missione
								TriggerEvent("revolt:timerstart", Config.MissionLenght, "La finestra di consegna si chiuderà tra: ", " secondi, porta il veicolo a destinazione in tempo", 4, 0.5, 0.5, 0.8)
								Citizen.CreateThread(function ()
									timerToEndMission = true
									local tempo = Config.MissionLenght
									while timerToEndMission do
										Citizen.Wait(1000)
										tempo = tempo - 1
										if tempo == 0 then
											AbortDelivery()
											TriggerEvent("brodoPlayer:PlayOnOne", "condor/condor_rac_timeRanOut", 1.0)
										end
									end
								end)

							else
								TriggerEvent("brodoPlayer:PlayOnOne", "condor/condor_rac_notEnoughEnemies", 1.0)
								-- ESX.ShowAdvancedNotification("Joe", nil, "C'è troppo movimento in giro, non è sicuro al momento", "CHAR_JOE", 1)
							end
						end)
					else
						TriggerEvent("brodoPlayer:PlayOnOne", "condor/condor_rac_alredyInUse", 1.0)
						-- ESX.ShowAdvancedNotification("Joe", nil, "C'è già un carico in movimento", "CHAR_JOE", 1)
						
					end
			
			
				else
					TriggerEvent("brodoPlayer:PlayOnOne", "condor/condor_rac_inCooldown", 1.0)
					-- ESX.ShowAdvancedNotification("Joe", nil, "Non ho niente da darti ora, torna tra un po'", "CHAR_JOE", 1)
				end
			end)
		else
			TriggerEvent("brodoPlayer:PlayOnOne", "condor/condor_rac_wrongSide", 1.0)
			-- ESX.ShowAdvancedNotification("Joe", nil, "Chi sei tu? Non dovresti essere qui. Non faccio affari con gente del NOA", "CHAR_JOE", 1)	
		end
	end)
end

function checkDistanceFromSpawn()
	Citizen.CreateThread(function()

		checkDistance = true
		firstWaveSpawned = false
		secondWaveSpawned = false
		thirdWaveSpawned = false

		local distanceFirstWave = math.random(800, 1000)
		local distanceSecondWave = math.random(5000, 6000)

		while checkDistance do

			Citizen.Wait(1000)

			local liveCoords = GetEntityCoords(PlayerPedId())
			local liveDistance = GetDistanceBetweenCoords(liveCoords.x, liveCoords.y, liveCoords.z, Config.VehicleSpawnPoint.Pos.x, Config.VehicleSpawnPoint.Pos.y, Config.VehicleSpawnPoint.Pos.z, false)
			local liveDistanceEnd = GetDistanceBetweenCoords(liveCoords.x, liveCoords.y, liveCoords.z, v.posx, v.posy, v.posz, false)

			local inVeh = IsPedInAnyVehicle(PlayerPedId(), false)
			
			if liveDistanceEnd < 500 and thirdWaveSpawned == false and inVeh then
				-- E tu ti bencchi il quarto
				TriggerEvent("brodoPlayer:PlayOnOne", "condor/condor_rac_fourthWave", 1.0)
				TriggerEvent("condor_rac:thirdWave")
				thirdWaveSpawned = true
				checkDistance = false

			elseif liveDistance > distanceSecondWave and secondWaveSpawned == false and inVeh then
				-- Sono speciale e mi manca l'audio della seconda wave, quindi tu ti becchi il terzo
				TriggerEvent("brodoPlayer:PlayOnOne", "condor/condor_rac_thirdWave", 1.0)
				TriggerEvent("condor_rac:secondWave")
				secondWaveSpawned = true

			elseif liveDistance > distanceFirstWave and firstWaveSpawned == false and inVeh then
				TriggerEvent("brodoPlayer:PlayOnOne", "condor/condor_rac_firstWave", 1.0)
				TriggerEvent("condor_rac:firstWave")
				firstWaveSpawned = true

				-- Un percento di chance che parta questo audio 15 secondi dopo la prima ondata
				Citizen.CreateThread(function ()
					Citizen.Wait(15000)
					if math.random(1, 100) > 0 then
						TriggerEvent("brodoPlayer:PlayOnOne", "condor/condor_rac_country", 1.0)
					end
				end)

			end
		end
	end)
end

function checkCaricoHealth()
	checkPayloadHealth = true
	local voiceLine1 = false
	local voiceLine2 = false
	local aborted = false

	Citizen.CreateThread(function()
		while checkPayloadHealth do
			Citizen.Wait(1000)
			
			local vita = GetVehicleEngineHealth(car)

			if vita <= 0.0 and not aborted then
				aborted = true
				AbortDelivery()

			elseif vita <= 300.0 and not voiceLine2 then
				voiceLine2 = true
				TriggerEvent("brodoPlayer:PlayOnOne", "condor/condor_rac_payloadLotDamage", 1.0)
			
			elseif vita <= 650.0 and not voiceLine1 then
				voiceLine1 = true
				TriggerEvent("brodoPlayer:PlayOnOne", "condor/condor_rac_payloadDamaged", 1.0)

			end
		end
	end)
end



function checkInsideVeh()
	checkInVehicle = true
	local timeOutsideVehicle = 120

	Citizen.CreateThread(function()
		while checkInVehicle do
			Citizen.Wait(1000)
			if isTaken == 1 and isDelivered == 0 and not (GetVehiclePedIsIn(GetPlayerPed(-1), false) == car) then
				timeOutsideVehicle = timeOutsideVehicle - 1
			else
				timeOutsideVehicle = 120
			end
			if timeOutsideVehicle == 119 then
				TriggerEvent("brodoPlayer:PlayOnOne", "condor/condor_rac_twoMinutes", 1.0)
			elseif timeOutsideVehicle == 60 then
				TriggerEvent("brodoPlayer:PlayOnOne", "condor/condor_rac_oneMinute", 1.0)
			elseif timeOutsideVehicle == 20 then
				TriggerEvent("brodoPlayer:PlayOnOne", "condor/condor_rac_twentySeconds", 1.0)
			elseif timeOutsideVehicle == 0 then
				AbortDelivery()
			end
		end
	end)
end


function checkForDeath()
	checkDeath = true
	Citizen.CreateThread(function()
		while checkDeath do
			Citizen.Wait(1000)
			if IsEntityDead(PlayerPedId()) then
				local death = GetPedSourceOfDeath(PlayerPedId())
				local localPlayer = NetworkGetPlayerIndexFromPed(death)
				local serverPlayer = GetPlayerServerId(localPlayer)
				-- Se vuoi usare un solo local puoi usare quelo qua sotto, ma concorderai con me che sembra molto stupido
				-- local strangeMethod = GetPlayerServerId(NetworkGetPlayerIndexFromPed(GetPedSourceOfDeath(PlayerPedId())))
				AbortDelivery()
				TriggerServerEvent("condor_rac:payOther", serverPlayer)
				checkDeath = false
			end
		end
	end)
end

-- Notifica a schermo per la persona che ha ucciso il "protagonista" della quest
RegisterNetEvent("condor_rac:enemyWon", function()
	ESX.ShowAdvancedNotification("Joe", nil, "Hai impedito che il nemico consegnasse le risorse, ottimo lavoro", "CHAR_JOE", 1)
end)

function FinishDelivery()
  	if(GetVehiclePedIsIn(GetPlayerPed(-1), false) == car) then
		if GetEntitySpeed(car) < 3 then

			timerToEndMission = false
			checkPayloadHealth 	= false
			checkDeath = false
			checkInVehicle = false
			TriggerEvent("condor_rac:stopEnemies")


			--Delete Car
			SetEntityAsNoLongerNeeded(car)
			DeleteEntity(car)

			--Remove delivery zone
			RemoveBlip(deliveryblip)

			--Pay the poor fella
			local finalpayment = Config.defaultPayment
			TriggerServerEvent('condor_rac:pay', finalpayment)

			--Register Activity
			TriggerServerEvent('condor_rac:registerActivity', 0)

			--For delivery blip
			isTaken = 0

			--For delivery blip
			isDelivered = 1
				
				--Remove Last Cop Blips
			TriggerServerEvent('condor_rac:stopalertcops')
			TriggerEvent("revolt:timerstop")

			ESX.ShowAdvancedNotification("???", nil, "Grazie mille, finalmente potremo mangiare. Tieni questi sono per te, il resto lo darò a Joe", "CHAR_BLANK_ENTRY", 1)

			Citizen.Wait(5000)

			TriggerEvent("brodoPlayer:PlayOnOne", "condor/condor_rac_missionCompleted", 1.0)
			-- ESX.ShowAdvancedNotification("Joe", nil, "Il mio contatto dice che il carico è giunto a destinazione. Ottimo lavoro", "CHAR_JOE", 1)

			-- PlayMissionCompleteAudio("FRANKLIN_BIG_01")
			
		else
			ESX.ShowAdvancedNotification("Joe", nil, "Ferma il veicolo prima di consegnarlo", "CHAR_JOE", 1)
		end
	else
		TriggerEvent("brodoPlayer:PlayOnOne", "condor/condor_rac_wrongVehicle", 1.0)
		-- ESX.ShowAdvancedNotification("Joe", nil, "Questo non è uno dei miei carichi", "CHAR_JOE", 1)
	end
end

function AbortDelivery()

	timerToEndMission = false
	checkPayloadHealth 	= false
	checkDeath = false
	checkInVehicle = false
	TriggerEvent("condor_rac:stopEnemies")

	Citizen.CreateThread(function ()
		SetEntityAsNoLongerNeeded(car)
		-- DeleteEntity(car)

		--Remove delivery zone
		RemoveBlip(deliveryblip)

		--Register Activity
		TriggerServerEvent('condor_rac:registerActivity', 0)

		--For delivery blip
		isTaken = 0

		--For delivery blip
		isDelivered = 1

		--Remove Last Cop Blips
		TriggerServerEvent('condor_rac:stopalertcops')
		TriggerEvent("revolt:timerstop")
		
	end)

	local numeroFortunato = math.random(1, 100)
	if numeroFortunato == 7 then
	-- if numeroFortunato > 0 then
		TriggerEvent("brodoPlayer:PlayOnOne", "condor/condor_rac_heMad", 1.0)
	else
		TriggerEvent("brodoPlayer:PlayOnOne", "condor/condor_rac_missionAborted", 1.0)
		
		Citizen.Wait(10000)

		TriggerEvent("brodoPlayer:PlayOnOne", "condor/condor_rac_payloadAboutToExplode", 1.0)
	end

	ESX.ShowAdvancedNotification(nil, nil, "Il veicolo si autodistruggerà tra "..Config.TimeBeforeBoom.." secondi", "CHAR_DETONATEBOMB", 1)
	Citizen.Wait(Config.TimeBeforeBoom * 1000)

	local carCoords = GetEntityCoords(car)
	local explosionType = 8
	local damageScale = 1.0
	local isAudible = true
	local isInvisible = false
	local cameraShake = 1.0
	AddExplosion(carCoords.x, carCoords.y, carCoords.z, explosionType, damageScale, isAudible, isInvisible, cameraShake)
end



-- Send location
Citizen.CreateThread(function()
  while true do
    Citizen.Wait(Config.BlipUpdateTime)
    if isTaken == 1 and IsPedInAnyVehicle(GetPlayerPed(-1)) then
			local coords = GetEntityCoords(GetPlayerPed(-1))
      TriggerServerEvent('condor_rac:alertcops', coords.x, coords.y, coords.z)
		elseif isTaken == 1 and not IsPedInAnyVehicle(GetPlayerPed(-1)) then
			TriggerServerEvent('condor_rac:stopalertcops')
    end
  end
end)

RegisterNetEvent('condor_rac:removecopblip')
AddEventHandler('condor_rac:removecopblip', function()
		RemoveBlip(copblip)
end)

RegisterNetEvent('condor_rac:setcopblip')
AddEventHandler('condor_rac:setcopblip', function(cx,cy,cz)
		RemoveBlip(copblip)
		copblip = AddBlipForRadius(cx, cy, cz, 100.0)
    --copblip = AddBlipForCoord(cx,cy,cz)
    --SetBlipSprite(copblip , 161)
    --SetBlipScale(copblipy , 2.0)
		SetBlipColour(copblip, 11)
		--PulseBlip(copblip)
end)

RegisterNetEvent('condor_rac:setcopnotification')
AddEventHandler('condor_rac:setcopnotification', function()
	ESX.ShowAdvancedNotification("Joe", nil, "Segnalato un carico della RAC in movimento", "CHAR_JOE", 1)
	ESX.ShowNotification(_U('car_stealing_in_progress'))
end)

AddEventHandler('condor_rac:hasEnteredMarker', function(zone)
  if LastZone == 'menucarthief' then
    CurrentAction     = 'carthief_menu'
    CurrentActionMsg  = _U('steal_a_car')
    CurrentActionData = {zone = zone}
  elseif LastZone == 'cardelivered' then
    CurrentAction     = 'cardelivered_menu'
    CurrentActionMsg  = _U('drop_car_off')
    CurrentActionData = {zone = zone}
  end
end)

AddEventHandler('condor_rac:hasExitedMarker', function(zone)
	CurrentAction = nil
	ESX.UI.Menu.CloseAll()
end)

-- Enter / Exit marker events
Citizen.CreateThread(function()
  while true do
		Wait(0)
		local coords      = GetEntityCoords(GetPlayerPed(-1))
		local isInMarker  = false
		local currentZone = nil
    
      
		if(GetDistanceBetweenCoords(coords, Config.Zones.VehicleSpawner.Pos.x, Config.Zones.VehicleSpawner.Pos.y, Config.Zones.VehicleSpawner.Pos.z, true) < 3) then
			isInMarker  = true
			currentZone = 'menucarthief'
			LastZone    = 'menucarthief'
		end
      
		if isTaken == 1 and (GetDistanceBetweenCoords(coords, alldeliveries[randomdelivery].posx, alldeliveries[randomdelivery].posy, alldeliveries[randomdelivery].posz, true) < 3) then
			isInMarker  = true
			currentZone = 'cardelivered'
			LastZone    = 'cardelivered'
		end
        
      
		if isInMarker and not HasAlreadyEnteredMarker then
			HasAlreadyEnteredMarker = true
			TriggerEvent('condor_rac:hasEnteredMarker', currentZone)
		end
		if not isInMarker and HasAlreadyEnteredMarker then
			HasAlreadyEnteredMarker = false
			TriggerEvent('condor_rac:hasExitedMarker', LastZone)
		end
	end
end)

-- Key Controls
Citizen.CreateThread(function()
  while true do
    Citizen.Wait(0)
    if CurrentAction ~= nil then
      SetTextComponentFormat('STRING')
      AddTextComponentString(CurrentActionMsg)
      DisplayHelpTextFromStringLabel(0, 0, 1, -1)
      if IsControlJustReleased(0, 38) then
        if CurrentAction == 'carthief_menu' then
          SpawnCar()
        elseif CurrentAction == 'cardelivered_menu' then
          FinishDelivery()
        end
        CurrentAction = nil
      end
    end
  end
end)

-- Display markers
Citizen.CreateThread(function()
  while true do
    Wait(0)
    local coords = GetEntityCoords(GetPlayerPed(-1))
    
			for k,v in pairs(Config.Zones) do
					if (v.Type ~= -1 and GetDistanceBetweenCoords(coords, v.Pos.x, v.Pos.y, v.Pos.z, true) < Config.DrawDistance) then
						DrawMarker(v.Type, v.Pos.x, v.Pos.y, v.Pos.z, 0.0, 0.0, 0.0, 0, 0.0, 0.0, v.Size.x, v.Size.y, v.Size.z, v.Color.r, v.Color.g, v.Color.b, 100, false, true, 2, false, false, false, false)
					end
			end
    
  end
end)

-- Display markers for delivery place
Citizen.CreateThread(function()
  while true do
    Wait(0)
    if isTaken == 1 and isDelivered == 0 then
    local coords = GetEntityCoords(GetPlayerPed(-1))
      v = alldeliveries[randomdelivery]
			if (GetDistanceBetweenCoords(coords, v.posx, v.posy, v.posz, true) < Config.DrawDistance) then
				DrawMarker(1, v.posx, v.posy, v.posz, 0.0, 0.0, 0.0, 0, 0.0, 0.0, 5.0, 5.0, 1.0, 204, 204, 0, 100, false, false, 2, false, false, false, false)
			end
    end
  end
end)

-- Blip in mappa
AddEventHandler('esx:playerLoaded', function(playerData)
	Citizen.CreateThread(function()
		if ESX.PlayerData.job.name == "rac" then
			info = Config.Zones.VehicleSpawner
			info.blip = AddBlipForCoord(info.Pos.x, info.Pos.y, info.Pos.z)
			SetBlipSprite(info.blip, info.Id)
			SetBlipDisplay(info.blip, 4)
			SetBlipScale(info.blip, 1.0)
			SetBlipColour(info.blip, info.Colour)
			SetBlipAsShortRange(info.blip, true)
			BeginTextCommandSetBlipName("STRING")
			AddTextComponentString(_U('vehicle_robbery'))
			EndTextCommandSetBlipName(info.blip)
		end
	end)
end)

RegisterCommand("condorabort", function ()
	AbortDelivery()
end)

RegisterCommand("condorfinish", function()
	FinishDelivery()
end)