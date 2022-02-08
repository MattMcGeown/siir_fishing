fx_version 'cerulean'
game 'gta5'
author 'SiiR'
version '1.0.0'

dependencies {
    'es_extended',
    'pe-lualib',
    'ox_inventory'
}

shared_scripts {
    '@es_extended/imports.lua',
    'locale.lua',
    'locales/*.lua',
    'config.lua'
}

client_scripts {
    '@PolyZone/client.lua',
    '@PolyZone/BoxZone.lua',
    'client.lua'
}

server_scripts {
    'server.lua'
}