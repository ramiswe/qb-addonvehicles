fx_version 'cerulean'
game 'gta5'

author 'RamiS'

description 'Addon vehicles for QBCore'

version '1.0.0'

shared_script '@ox_lib/init.lua'
shared_script {
    'shared.lua',
}
client_script 'client.lua'
server_script 'server.lua'