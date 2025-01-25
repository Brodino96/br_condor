local allVeh = {vehicle1, vehicle2, vehicle3, vehicle4, vehicle5, vehicle6}
local everyThing = {vehicle1, vehicle2, vehicle3, vehicle4, vehicle5, vehicle6, driver5, passenger9, passenger10, driver6, passenger11, passenger12, driver3, passenger5, passenger6, driver4, passenger7, passenger8, driver1, passenger1, passenger2, driver2, passenger3, passenger4}

RegisterNetEvent("condor_rac:thirdWave", function ()
	Citizen.CreateThread(function ()
		print("Sto spawnando la terza ondata")
		-- Aspetto 30 secondi prima di spawnnare i nemici perchè Gianluu vuole così
        Citizen.Wait(10000)
		
		-- Mi prendo le coordinate del player e un posto safe per spawnare i nemici
		local playerCoords = GetEntityCoords(PlayerPedId())
		local found, spawnPos, spawnHeading = GetClosestVehicleNodeWithHeading(playerCoords.x + math.random(-200, 200), playerCoords.y + math.random(-200, 200), playerCoords.z, 0, 3, 0)
		local found2, spawnPos2, spawnHeading2 = GetClosestVehicleNodeWithHeading(playerCoords.x + math.random(-200, 200), playerCoords.y + math.random(-200, 200), playerCoords.z, 0, 3, 0)

		-- Prendo gli hash dei ped e dei veicoli
		local enemyHash = GetHashKey(Config.Enemies.Ped)
		local enemyVehHash = GetHashKey(Config.Enemies.Vehicle)
		
		-- Carico gli Hash
		RequestModel(enemyVehHash)
		while not HasModelLoaded(enemyVehHash) do
			Wait(1)
		end

		RequestModel(enemyHash)
		while not HasModelLoaded(enemyHash) do
			Wait(1)
		end

		-- Vedo se ha trovato le coordinate di spawn dei veicoli
		while not found do
			Wait(1)
		end

		while not found2 do
			Wait(1)
		end

		-- Questo set up dovrebbe essere per 2 veicoli con dentro 3 nemici ciascuno
		-- vehicle1 = CreateVehicle(enemyVehHash, playerCoords.x , playerCoords.y, playerCoords.z, spawnHeading, true, true)
		vehicle5 = CreateVehicle(enemyVehHash, spawnPos.x , spawnPos.y, spawnPos.z, spawnHeading, true, true)
		driver5 = CreatePedInsideVehicle(vehicle5, 4, enemyHash, -1, true, true)
		passenger9 = CreatePedInsideVehicle(vehicle5, 4, enemyHash, 0, true, true)
		passenger10 = CreatePedInsideVehicle(vehicle5, 4, enemyHash, 1, true, true)

		-- vehicle2 = CreateVehicle(enemyVehHash, playerCoords.x , playerCoords.y, playerCoords.z, spawnHeading2, true, true)
		vehicle6 = CreateVehicle(enemyVehHash, spawnPos2.x , spawnPos2.y, spawnPos2.z, spawnHeading2, true, true)
		driver6 = CreatePedInsideVehicle(vehicle6, 4, enemyHash, -1, true, true)
		passenger11 = CreatePedInsideVehicle(vehicle6, 4, enemyHash, 0, true, true)
		passenger12 = CreatePedInsideVehicle(vehicle6, 4, enemyHash, 1, true, true)

		SetVehicleOnGroundProperly(vehicle5)
		SetVehicleOnGroundProperly(vehicle6)

		fifthGroup = {driver5, passenger9, passenger10}
		sixtGroup = {driver6, passenger11, passenger12}

		enemiesIA3 = {driver5, passenger9, passenger10, driver6, passenger11, passenger12}

		local _, hash = AddRelationshipGroup("condor_enemy")

		for i = 1, #enemiesIA3 do
			Citizen.Wait(100)
			-- Gli do l'arma
			GiveWeaponToPed(enemiesIA3[i], GetHashKey("WEAPON_PISTOL"), 1000, false, true)

			-- Gestisco il comportamento
			SetPedCombatAttributes(enemiesIA3[i], 1, true)
			SetPedCombatAttributes(enemiesIA3[i], 2, true)
			SetPedCombatAttributes(enemiesIA3[i], 3, true)
			SetPedCombatAttributes(enemiesIA3[i], 46, true)
			SetPedCombatAttributes(enemiesIA3[i], 52, true)
			SetPedFleeAttributes(enemiesIA3[i], 0, 0)

			-- Questo dovrebbe servire a far sapere al server che esiste il ped (non so esattamente a che scopo)
			NetworkRegisterEntityAsNetworked(enemiesIA3[i])

			-- Gli impedisce di despawnare
			SetEntityAsMissionEntity(enemiesIA3[i], true, true)

			-- Gli dico chi deve odiare o meno
			SetPedRelationshipGroupHash(enemiesIA3[i], hash)
			SetRelationshipBetweenGroups(5, GetHashKey("PLAYER"), hash)
    		SetRelationshipBetweenGroups(5, hash, GetHashKey("PLAYER"))
    		SetRelationshipBetweenGroups(0, hash, hash)

			-- Vuole inseguire il giocatore
			TaskVehicleChase(enemiesIA3[i], GetPlayerPed(-1))
		end
    end)
end)



RegisterNetEvent("condor_rac:secondWave", function ()
	Citizen.CreateThread(function ()
		print("Sto spawnando la seconda ondata")
		-- Aspetto 30 secondi prima di spawnnare i nemici perchè Gianluu vuole così
        Citizen.Wait(10000)
		
		-- Mi prendo le coordinate del player e un posto safe per spawnare i nemici
		local playerCoords = GetEntityCoords(PlayerPedId())
		local found, spawnPos, spawnHeading = GetClosestVehicleNodeWithHeading(playerCoords.x + math.random(-200, 200), playerCoords.y + math.random(-200, 200), playerCoords.z, 0, 3, 0)
		local found2, spawnPos2, spawnHeading2 = GetClosestVehicleNodeWithHeading(playerCoords.x + math.random(-200, 2001), playerCoords.y + math.random(-200, 200), playerCoords.z, 0, 3, 0)

		-- Prendo gli hash dei ped e dei veicoli
		local enemyHash = GetHashKey(Config.Enemies.Ped)
		local enemyVehHash = GetHashKey(Config.Enemies.Vehicle)
		
		-- Carico gli Hash
		RequestModel(enemyVehHash)
		while not HasModelLoaded(enemyVehHash) do
			Wait(1)
		end

		RequestModel(enemyHash)
		while not HasModelLoaded(enemyHash) do
			Wait(1)
		end

		-- Vedo se ha trovato le coordinate di spawn dei veicoli
		while not found do
			Wait(1)
		end

		while not found2 do
			Wait(1)
		end

		-- Questo set up dovrebbe essere per 2 veicoli con dentro 3 nemici ciascuno
		-- vehicle1 = CreateVehicle(enemyVehHash, playerCoords.x , playerCoords.y, playerCoords.z, spawnHeading, true, true)
		vehicle3 = CreateVehicle(enemyVehHash, spawnPos.x , spawnPos.y, spawnPos.z, spawnHeading, true, true)
		driver3 = CreatePedInsideVehicle(vehicle3, 4, enemyHash, -1, true, true)
		passenger5 = CreatePedInsideVehicle(vehicle3, 4, enemyHash, 0, true, true)
		passenger6 = CreatePedInsideVehicle(vehicle3, 4, enemyHash, 1, true, true)

		-- vehicle2 = CreateVehicle(enemyVehHash, playerCoords.x , playerCoords.y, playerCoords.z, spawnHeading2, true, true)
		vehicle4 = CreateVehicle(enemyVehHash, spawnPos2.x , spawnPos2.y, spawnPos2.z, spawnHeading2, true, true)
		driver4 = CreatePedInsideVehicle(vehicle4, 4, enemyHash, -1, true, true)
		passenger7 = CreatePedInsideVehicle(vehicle4, 4, enemyHash, 0, true, true)
		passenger8 = CreatePedInsideVehicle(vehicle4, 4, enemyHash, 1, true, true)

		SetVehicleOnGroundProperly(vehicle3)
		SetVehicleOnGroundProperly(vehicle4)

		thirdGroup = {driver3, passenger5, passenger6}
		fourthGroup = {driver4, passenger7, passenger8}

		enemiesIA2 = {driver3, passenger5, passenger6, driver4, passenger7, passenger8}

		local _, hash = AddRelationshipGroup("condor_enemy")

		for i = 1, #enemiesIA2 do
			Citizen.Wait(100)
			-- Gli do l'arma
			GiveWeaponToPed(enemiesIA2[i], GetHashKey("WEAPON_PISTOL"), 1000, false, true)

			-- Gestisco il comportamento
			SetPedCombatAttributes(enemiesIA2[i], 1, true)
			SetPedCombatAttributes(enemiesIA2[i], 2, true)
			SetPedCombatAttributes(enemiesIA2[i], 3, true)
			SetPedCombatAttributes(enemiesIA2[i], 46, true)
			SetPedCombatAttributes(enemiesIA2[i], 52, true)
			SetPedFleeAttributes(enemiesIA2[i], 0, 0)

			-- Questo dovrebbe servire a far sapere al server che esiste il ped (non so esattamente a che scopo)
			NetworkRegisterEntityAsNetworked(enemiesIA2[i])

			-- Gli impedisce di despawnare
			SetEntityAsMissionEntity(enemiesIA2[i], true, true)

			-- Gli dico chi deve odiare o meno
			SetPedRelationshipGroupHash(enemiesIA2[i], hash)
			SetRelationshipBetweenGroups(5, GetHashKey("PLAYER"), hash)
    		SetRelationshipBetweenGroups(5, hash, GetHashKey("PLAYER"))
    		SetRelationshipBetweenGroups(0, hash, hash)

			-- Vuole inseguire il giocatore
			TaskVehicleChase(enemiesIA2[i], GetPlayerPed(-1))
		end
    end)
end)



RegisterNetEvent("condor_rac:firstWave", function ()
    Citizen.CreateThread(function ()
		print("Sto spawnando la prima ondata")
		-- Aspetto 30 secondi prima di spawnnare i nemici perchè Gianluu vuole così
        Citizen.Wait(10000)
		
		-- Mi prendo le coordinate del player e un posto safe per spawnare i nemici
		local playerCoords = GetEntityCoords(PlayerPedId())
		local found, spawnPos, spawnHeading = GetClosestVehicleNodeWithHeading(playerCoords.x + math.random(-200, 200), playerCoords.y + math.random(-200, 200), playerCoords.z, 0, 3, 0)
		local found2, spawnPos2, spawnHeading2 = GetClosestVehicleNodeWithHeading(playerCoords.x + math.random(-200, 200), playerCoords.y + math.random(-200, 200), playerCoords.z, 0, 3, 0)

		-- Prendo gli hash dei ped e dei veicoli
		local enemyHash = GetHashKey(Config.Enemies.Ped)
		local enemyVehHash = GetHashKey(Config.Enemies.Vehicle)
		
		-- Carico gli Hash
		RequestModel(enemyVehHash)
		while not HasModelLoaded(enemyVehHash) do
			Wait(1)
		end

		RequestModel(enemyHash)
		while not HasModelLoaded(enemyHash) do
			Wait(1)
		end

		-- Vedo se ha trovato le coordinate di spawn dei veicoli
		while not found do
			Wait(1)
		end

		while not found2 do
			Wait(1)
		end

		-- Questo set up dovrebbe essere per 2 veicoli con dentro 3 nemici ciascuno
		-- vehicle1 = CreateVehicle(enemyVehHash, playerCoords.x , playerCoords.y, playerCoords.z, spawnHeading, true, true)
		vehicle1 = CreateVehicle(enemyVehHash, spawnPos.x , spawnPos.y, spawnPos.z, spawnHeading, true, true)
		driver1 = CreatePedInsideVehicle(vehicle1, 4, enemyHash, -1, true, true)
		passenger1 = CreatePedInsideVehicle(vehicle1, 4, enemyHash, 0, true, true)
		passenger2 = CreatePedInsideVehicle(vehicle1, 4, enemyHash, 1, true, true)

		-- vehicle2 = CreateVehicle(enemyVehHash, playerCoords.x , playerCoords.y, playerCoords.z, spawnHeading2, true, true)
		vehicle2 = CreateVehicle(enemyVehHash, spawnPos2.x , spawnPos2.y, spawnPos2.z, spawnHeading2, true, true)
		driver2 = CreatePedInsideVehicle(vehicle2, 4, enemyHash, -1, true, true)
		passenger3 = CreatePedInsideVehicle(vehicle2, 4, enemyHash, 0, true, true)
		passenger4 = CreatePedInsideVehicle(vehicle2, 4, enemyHash, 1, true, true)

		SetVehicleOnGroundProperly(vehicle1)
		SetVehicleOnGroundProperly(vehicle2)

		firstGroup = {driver1, passenger1, passenger2}
		secondGroup = {driver2, passenger3, passenger4}

		enemiesIA = {driver1, passenger1, passenger2, driver2, passenger3, passenger4}

		local _, hash = AddRelationshipGroup("condor_enemy")

		for i = 1, #enemiesIA do
			Citizen.Wait(100)
			-- Gli do l'arma
			GiveWeaponToPed(enemiesIA[i], GetHashKey("WEAPON_PISTOL"), 1000, false, true)

			-- Gestisco il comportamento
			SetPedCombatAttributes(enemiesIA[i], 1, true)
			SetPedCombatAttributes(enemiesIA[i], 2, true)
			SetPedCombatAttributes(enemiesIA[i], 3, true)
			SetPedCombatAttributes(enemiesIA[i], 46, true)
			SetPedCombatAttributes(enemiesIA[i], 52, true)
			SetPedFleeAttributes(enemiesIA[i], 0, 0)

			-- Questo dovrebbe servire a far sapere al server che esiste il ped (non so esattamente a che scopo)
			NetworkRegisterEntityAsNetworked(enemiesIA[i])

			-- Gli impedisce di despawnare
			SetEntityAsMissionEntity(enemiesIA[i], true, true)

			-- Gli dico chi deve odiare o meno
			SetPedRelationshipGroupHash(enemiesIA[i], hash)
			SetRelationshipBetweenGroups(5, GetHashKey("PLAYER"), hash)
    		SetRelationshipBetweenGroups(5, hash, GetHashKey("PLAYER"))
    		SetRelationshipBetweenGroups(0, hash, hash)

			-- Vuole inseguire il giocatore
			TaskVehicleChase(enemiesIA[i], GetPlayerPed(-1))

			SetTaskVehicleChaseBehaviorFlag(enemiesIA[i], 1, true)
			SetTaskVehicleChaseIdealPursuitDistance(enemiesIA[i], 15)
		end
    end)
end)

RegisterNetEvent("condor_rac:stopEnemies", function ()
	Citizen.CreateThread(function ()
		Citizen.Wait(1)
		for i = 1, #firstGroup do
			ClearPedTasks(firstGroup[i])
			TaskVehicleDriveWander(firstGroup[i], vehicle1, 75.0, 524812)
			SetEntityAsNoLongerNeeded(firstGroup[i])
		end
	end)
	Citizen.CreateThread(function ()
		Citizen.Wait(1)
		for i = 1, #secondGroup do
			ClearPedTasks(secondGroup[i])
			TaskVehicleDriveWander(secondGroup[i], vehicle2, 75.0, 524812)
			SetEntityAsNoLongerNeeded(secondGroup[i])
		end
	end)
	Citizen.CreateThread(function ()
		Citizen.Wait(1)
		for i = 1, #thirdGroup do
			ClearPedTasks(thirdGroup[i])
			TaskVehicleDriveWander(thirdGroup[i], vehicle3, 75.0, 524812)
			SetEntityAsNoLongerNeeded(thirdGroup[i])
		end
	end)
	Citizen.CreateThread(function ()
		Citizen.Wait(1)
		for i = 1, #fourthGroup do
		ClearPedTasks(fourthGroup[i])
		TaskVehicleDriveWander(fourthGroup[i], vehicle4, 75.0, 524812)
		SetEntityAsNoLongerNeeded(fourthGroup[i])
		end
	end)
	Citizen.CreateThread(function ()
		Citizen.Wait(1)
		for i = 1, #fifthGroup do
			ClearPedTasks(fifthGroup[i])
			TaskVehicleDriveWander(fifthGroup[i], vehicle5, 75.0, 524812)
			SetEntityAsNoLongerNeeded(fifthGroup[i])
		end
	end)
	Citizen.CreateThread(function ()
		Citizen.Wait(1)
		for i = 1, #sixtGroup do
			ClearPedTasks(sixtGroup[i])
			TaskVehicleDriveWander(sixtGroup[i], vehicle6, 75.0, 524812)
			SetEntityAsNoLongerNeeded(sixtGroup[i])
		end
	end)
	Wait(1000)
	Citizen.CreateThread(function ()
		Citizen.Wait(1)
		for i = 1, #allVeh do
			SetEntityAsNoLongerNeeded(allVeh[i])
			DeleteVehicle(allVeh[i])
		end
	end)
end)