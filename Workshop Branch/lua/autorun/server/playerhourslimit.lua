if CLIENT then 
    print("PlayerHoursLimit is a Serverside Addon!")
    return 
end 

MsgC(Color(255,255,255), "The ", Color(255,0,0), "PlayerHoursLimit Addon", Color(255,255,255), " is brought to you by ", Color(0,0,255), "Sixmax", Color(255,255,255), "!\n")

local hoursLimit = CreateConVar("phl_minhours", "100", FCVAR_NEVER_AS_STRING, "Define the Minimum amount of hours a Player should have.", 0)

local root = "playerhourslimit"
local verifiedPlayers = root .. "/verifiedPlayers.json"
local apiKeyDir = root .. "/apikey.json" 

-- Create the Directory if it doesnt exist.
if file.Exists(root, "DATA") == false then file.CreateDir(root) end 

local function getVerifiedPlayers()
    if file.Exists(verifiedPlayers, "DATA") == false then 
        file.Write(verifiedPlayers, "[]")
        return {}
    end

    return util.JSONToTable(file.Read(verifiedPlayers, "DATA"))  
end

local function isVerifiedPlayer(player)
    if IsValid(player) == false then return false, {} end 

    local verified = getVerifiedPlayers()
  
    for _, v in pairs(verified) do 
        if v == player:SteamID() then
            return true, verified 
        end  
    end

    return false, verified
end 

local function addVerifiedPlayer(player)
    local isAlreadyVerified, allVerified = isVerifiedPlayer(player)

    if IsValid(player) == false or isAlreadyVerified == true then return end 

    table.insert(allVerified, player:SteamID())

    file.Write(verifiedPlayers, util.TableToJSON(allVerified))
end

local function getApiKey()
    if file.Exists(apiKeyDir, "DATA") == false then 
        file.Write(apiKeyDir, util.TableToJSON({steamAPIKey = ""}))
        return nil  
    end 

    local result = util.JSONToTable(file.Read(apiKeyDir, "DATA")).steamAPIKey

    return result ~= "" and result or nil 
end

local apikey = getApiKey() 

if apikey == nil then  
    MsgC(Color(255,0,0), "PlayerHoursLimit requieres you to register a SteamAPI key and put it in 'data/playerhourslimit/apikey.json'.\n")
end

concommand.Add("phl_refresh_apikey", function()
    apikey = getApiKey()
end, nil, "If the ApiKey was set while the Server was running, call this Concommand to set it inside the Addon.")

local function apiResponseInvalidKey(body)
    return string.gsub(string.gsub(body, "^(.*)<title>", ""), "</title>(.*)", "") == "Unauthorized"
end

local function apiResponsePrivateProfile(body)
    return string.gsub(string.gsub(body, "^(.*)<title>", ""), "</title>(.*)", "") == "500 Internal Server Error" -- Wish they could just send error code 500 so i could handle it in the error callback... :(
end

local function verifyPlayer(player)
    if not apikey then return end 
    if isVerifiedPlayer(player) == true then return end 

    http.Fetch("http://api.steampowered.com/IPlayerService/GetOwnedGames/v0001/?key=" .. apikey .. "&steamid=" .. player:SteamID64() .. "&format=json",
    function(body, size, headers, code) 
        local limit = (hoursLimit == nil and 100 or hoursLimit:GetInt())

        local function drop()
            if IsValid(player) == false then return end 
            player:Kick("\nYou do not have enough playtime (min: " .. limit.. ") in Garry's Mod to play on this Server.\n\nIf you are certain to have enough hours, try to unprivate your profile.\nAfter verification you can set it back to Private :)")
        end 

        if apiResponsePrivateProfile(body) == true then 
            drop()
            return 
        end

        if apiResponseInvalidKey(body) == true then 
            MsgC(Color(255,0,0), "Failed to verify " .. player:GetName() .. " (" .. player:SteamID() .. "), reason: 'Invalid API Key'.\n") 
            return     
        end

        body = util.JSONToTable(body)
         
        if not body.response or not body.response.games then
            MsgC(Color(255,0,0), "Failed to verify " .. player:GetName() .. " (" .. player:SteamID() .. "), reasson: " .. error or "Unknown Error\n")
            return 
        end 

        for _, game in ipairs(body.response.games) do 
            if game.appid == 4000 then -- 4000 is gmod
                local playtime = game.playtime_forever / 60 

                if playtime >= limit then  
                    MsgC(Color(0,0,255), player:GetName(), Color(0,255,0), " has been verified with a total of ", Color(255,0,0), math.floor(playtime) .. " hours", Color(0,255,0), " in GMod!\n")
                    addVerifiedPlayer(player)
                else 
                    drop()
                end

                return 
            end
        end

        drop()
    end,
    function(error)
        MsgC(Color(255,0,0), "Failed to verify " .. player:GetName() .. " (" .. player:SteamID() .. "), reasson: " .. error or "Unknown Error\n")
    end)
end

hook.Remove("player_spawn", "PlayerHoursLimit_Spawn_Join_Hook")
gameevent.Listen("player_spawn")
hook.Add("player_spawn", "PlayerHoursLimit_Spawn_Join_Hook", function(userID)
    if not userID then return end 

    userID = userID.userid  

    local player = Player(userID)

    if IsValid(player) == false then return end 

    if apikey == nil or string.gsub(apikey, "%s", "") == "" then 
        MsgC(Color(255,0,0), "Failed to verify " .. player:GetName() .. " (" .. player:SteamID() .. ") because the SteamApi Key is not set!\n")
        return 
    end 

    verifyPlayer(player)
end)