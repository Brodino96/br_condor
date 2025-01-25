fx_version "cerulean"
game "gta5"

shared_script "@es_extended/imports.lua"

author "Brodino"
description "Condor per la fazione RAC, basato su ESX Car Thief"

version "1.0.0"

server_scripts {
    "@es_extended/locale.lua",
	"config.lua",
	"server/main.lua",
	"locales/en.lua",
	"locales/es.lua",
	"locales/fr.lua"
}

client_scripts {
	"@es_extended/locale.lua",
	"config.lua",
	"client/main.lua",
	"client/peds.lua",
	"locales/en.lua",
	"locales/es.lua",
	"locales/fr.lua",
	"@NativeUI/NativeUI.lua"
}

dependency "es_extended"
