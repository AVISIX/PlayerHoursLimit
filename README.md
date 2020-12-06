# PlayerHoursLimit

---

A simple GMod Addon to keep new players out of Servers.

## Setup 

When first launching your Server with the Addon, a Folder containing a file called "apikey.json" will be created.
In this file you must set the Steam Web API key, which can be generated [here](https://steamcommunity.com/dev/apikey).

*If you cannot restart the Server to verify the APIKey, call the Concommand 'phl_refresh_apikey' to set the internal value again.*

## Config 

The default minimum Player Hours is 100, you can set it via console by changing the ConVar: 'phl_minhours'. (Put it into cfg/autoexec to make it persist after Server restart)

