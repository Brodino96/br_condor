Config              	= {}
Config.DrawDistance 	= 100.0
Config.CopsRequired 	= 0			-- Quanti giocatori della fazione opposta devono esserci per far partire il condor 
Config.BlipUpdateTime 	= 5000 		--Millisecondi. Ogni quanto il blip di chi ha fatto il furto deve aggiornarsi
Config.CooldownMinutes 	= 0			-- Autoesplicativo
Config.Locale 			= 'en'
Config.TimeBeforeBoom 	= 10 		-- Secondi. Tempo che ci mette il veicolo a esplodere dopo aver fallito la missione
Config.PaymentItem		= "npass"
Config.defaultPayment 	= 1  		-- Quantita di item che deve consegnare (Per chi vince il minigioco)
Config.MissionLenght	= 600		-- Secondi. Durata massima della queest

Config.Enemies = {
	Ped = "csb_mweather",
	Vehicle = "kamacho"
}

Config.Zones = {
	VehicleSpawner = {
		-- Se per prendere le coordinate stai in piedi sul punto che vuoi, fai -1 alla Z (se in gioco è 25.72, metti 24.72)
		-- Se non vedi il blip prova ad aumentare la Z, probabilmente sta clippando con qualcosa
		Pos   = {x = -1639.54, y = -981.41, z = 6.59},
		Size  = {x = 3.0, y = 3.0, z = 1.0},
		Color = {r = 204, g = 204, b = 0},
		-- Type = Default (1) | Invisibile (-1)
		Type  = -1,
		Colour    = 6, --BLIP
		Id        = 229, --BLIP
	},
}

Config.VehicleSpawnPoint = {
      Pos   = {x = -1626.46, y = -988.27, z = 7.67, alpha = 47.89}, --alpha is the orientation of the car 
      Size  = {x = 3.0, y = 3.0, z = 1.0},
      Type  = -1,
}

-- Per cambiare i veicoli basta sostituire i nomi qui sotto
-- Al momento il "payment" givva l'item cartina (è un placeholder), per cambiare reward andare nello script server alla linea 32
Config.Delivery = {
	--Desert
	--Trevor Airfield 9.22KM
	Delivery1 = {
		Pos      = {x = 2130.68, y = 4781.32, z = 39.87},
		Size  = {x = 3.0, y = 3.0, z = 1.0},
		Color = {r = 204, g = 204, b = 0},
		Type  = 1,
		Payment  = 10,
		Cars = {'biff','stockade3','burrito5','scrap','rubble'},
	},
	--Lighthouse 9.61KM
	Delivery4 = {
		Pos      = {x = 3333.51, y = 5159.91, z = 17.20},
		Size  = {x = 3.0, y = 3.0, z = 1.0},
		Color = {r = 204, g = 204, b = 0},
		Type  = 1,
		Payment  = 10,
		Cars = {'biff','stockade3','burrito5','scrap','rubble'},
	},
	--House in Paleto 12.94KM
	Delivery7 = {
		Pos      = {x = -437.56, y = 6254.53, z = 29.02},
		Size  = {x = 3.0, y = 3.0, z = 1.0},
		Color = {r = 204, g = 204, b = 0},
		Type  = 1,
		Payment  = 10,
		Cars = {'biff','stockade3','burrito5','scrap','rubble'},
	},
	--Great Ocean Highway 10.47KM
	Delivery10 = {
		Pos      = {x = -2177.51, y = 4269.51, z = 47.93},
		Size  = {x = 3.0, y = 3.0, z = 1.0},
		Color = {r = 204, g = 204, b = 0},
		Type  = 1,
		Payment  = 10,
		Cars = {'biff','stockade3','burrito5','scrap','rubble'},
	},
	--Marina Drive Desert 8.15KM
	Delivery13 = {
		Pos      = {x = 895.02, y = 3603.87, z = 31.72},
		Size  = {x = 3.0, y = 3.0, z = 1.0},
		Color = {r = 204, g = 204, b = 0},
		Type  = 1,
		Payment  = 10,
		Cars = {'biff','stockade3','burrito5','scrap','rubble'},
	},
}
