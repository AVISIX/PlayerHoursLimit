# PlayerHoursLimit

A simple GMod Addon to keep new players out of Servers.

## Features

When a Player joins your server, the Addon will check if he has enough Playtime (*See Config*).
If the Player's Playtime is exceeding your defined minimum, his SteamID will be saved in a File (*playerhourslimit/verifiedplayers.json*) so incase he changes his Profile to Private, he will still be verified.
*If you need to manually Verify a Player, just put his SteamID into that File.*

## Setup 

When first launching your Server with the Addon, a Folder called **playerhourslimit**, inside your Server's **Data Folder** will be created. 
This Folder will contain a file called **apikey.json**, in which you must put your **Steam Web API key**.
*The API Key can be generated [here](https://steamcommunity.com/dev/apikey).*

*If you cannot restart the Server to verify the APIKey, call the Concommand 'phl_refresh_apikey' to set the internal value again.*

## Config 

The default minimum Player Hours is **100**, you can set it via console by changing the ConVar: **phl_minhours**. (*Put it into cfg/autoexec to make it persist after Server restart*)
