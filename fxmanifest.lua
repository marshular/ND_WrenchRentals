fx_version "cerulean"
game "gta5"
lua54 "yes"
version "1.5"
author "The Wrench"
description "Leo car renting"

shared_script {
    '@ox_lib/init.lua',
    '@ND_Core/init.lua',
    "config.lua"
}

client_script "source/client/main.lua"
server_script "source/server/main.lua"

dependencies {
    "ND_Core",
    "ox_lib"
}