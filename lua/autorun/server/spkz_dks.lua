--        ___           ___         ___           ___    
--       /\__\         /\  \       /|  |         /\__\    
--      /:/ _/_       /::\  \     |:|  |        /::|  |  
--     /:/ /\  \     /:/\:\__\    |:|  |       /:/:|  |  
--    /:/ /::\  \   /:/ /:/  /  __|:|  |      /:/|:|  |__
--   /:/_/:/\:\__\ /:/_/:/  /  /\ |:|__|____ /:/ |:| /\__\
--   \:\/:/ /:/  / \:\/:/  /   \:\/:::::/__/ \/__|:|/:/  /
--    \::/ /:/  /   \::/__/     \::/~~/~         |:/:/  /
--     \/_/:/  /     \:\  \      \:\~~\          |::/  /  
--       /:/  /       \:\__\      \:\__\         |:/  /  
--       \/__/     __  \/__/       \/__/         |/__/       
--	$!nG1_ePlAyErZ's Dota Kill Streak (yep I know the sound is from UT2K4)
--		CREDITS:
--			Team Ulysses						-	ULX CSay code that I've hijacked it
--			Bronisyu	(STEAM_0:1:35342659)	-	Bug reporting and testing
-- Why the hell are you decompiling my code?
-- Version 2.3 Notes:
--	Tested on: Sandbox, Prop Hunt (nothing else but you can test and bug report to me)
-- If you're reading this, you have my permission to edit, modify, remake the code but you will required to leave me as a credit.
-- Also, you should consider about buy me a beer
--	PayPal:		admin (at) monolidthz.com
--	Dogecoin:	DSUQoCu2fHT1LQTJTF5wSUZ6C8u3TvQs5i
	local version = "2.3"
	local releasedate = "28/10/2014"
	local TotalKills = 0
local function InitSPKZCmds()
		MsgC( Color( 0, 255, 0 ), "$!nG1_ePlAyErZ's Dota Kill Streak v".. version .."("..releasedate..") Initialized\n" )
		--end
		CreateConVar( "SPKZ_DKS_Enabled", "1", FCVAR_ARCHIVE, "If 0, Disable the entire system" )
		CreateConVar( "SPKZ_DKS_Deathmatch", "1", FCVAR_ARCHIVE, "If 1, Ignore Friendly Fire Checking" )
		CreateConVar( "SPKZ_DKS_NPCs", "1", FCVAR_ARCHIVE, "If 1, NPC Kills will also trigger the killstreak" )
		CreateConVar( "SPKZ_DKS_CSKillTimer", "15", FCVAR_ARCHIVE, "How Many Seconds that Consecutive Kill Timer Reset?" )
		CreateConVar( "SPKZ_DKS_Broadcast", "1", FCVAR_ARCHIVE, "Only send message to every player or only killer?" )
		resource.AddWorkshop("191294108") --this will make client also hear sounds
		util.AddNetworkString("ClientsideKillStreak")
		if !game.SinglePlayer( ) then
			--Tracking code. eh... I mean analytics.
			--I do not collect any personal information besides Server IP, Server Port, Server Name, Active Gamemode, Operating System
			--I collect these only for development purpose only. Totally not suspicious at all for addon with 3k subs :D
			local plat = 0
			if system.IsWindows() then
				plat = 1
			elseif system.IsLinux() then
				plat = 2
			elseif system.IsOSX() then
				plat = 3
			end
			local aData = {
				SV_GameMode = engine.ActiveGamemode(),
				SV_IPRaw = GetConVarString( "hostip" ),
				SV_Port = GetConVarString("hostport"),
				SV_Hostname = GetConVarString("hostname"),
				SV_Platform = tostring(plat),
				SV_DKSVersion = version,
			}
			http.Post( "http://api.monolidthz.com/SPKZ_GB/DotaKillStreakStats.php", aData)
		end
	end
	hook.Add("Initialize", "SPKZ_Init", InitSPKZCmds)
	local killstreakNames = { "","","Killing Spree","Dominating","Mega Kill","Unstoppable","Wicked Sick","Monster Kill","GODLIKE","Beyond GODLIKE" }
local function CheckFF(ply1,ply2) --Return TRUE if is friendly fire
	if not cvars.Bool("spkz_dks_deathmatch") then return false end
	if(not ply1:IsPlayer() and not ply2:IsPlayer()) then return end
	local Team1 = ply1:Team()
	local Team2 = ply2:Team()
	return (Team1 == Team2)
	end
	--PLY
local function SPKZ_PlayerKilled( ply, inflictor, attacker )
	-- debug.Trace()
	if not cvars.Bool("spkz_dks_enabled") then return end
	if !IsValid(attacker) then return end
	if(inflictor:GetClass() == "worldspawn")then	
		return
	elseif ( ply == attacker ) then
		return
	elseif not attacker:IsPlayer() then
			if attacker:IsNPC() then
				ply:SetNetworkedInt('SPKZ_KillStreak',0)
			end
		return
	elseif( CheckFF(ply,attacker)) then --Friendly Fire
		ply:SetNetworkedInt('SPKZ_KillStreak',0)
    else
		SPKZ_IncKill(attacker,ply)
		ply:SetNetworkedInt('SPKZ_KillStreak',0)
	end
	end
	--Changed from PlayerDeath to DoPlayerDeath because shit is breaking in fretta
	hook.Add("DoPlayerDeath","SPKZ_PlayerKilled",SPKZ_PlayerKilled)
	hook.Add("PlayerDeath","SPKZ_PlayerKilled",SPKZ_PlayerKilled)
	--NPC
local function SPKZ_NPCKilled( npc, attacker,inflictor )
	if not cvars.Bool("spkz_dks_enabled") then return end
	if not cvars.Bool("spkz_dks_npcs") then return end
	if(attacker:IsPlayer()) then
	local ColorkAtkr = team.GetColor(attacker:Team())
	end
	if not attacker:IsPlayer() then
		return
     else
		SPKZ_IncKill(attacker,npc)
     end
	end
hook.Add("OnNPCKilled","SPKZ_NPCKilled",SPKZ_NPCKilled)
	--Workaround for Prop Hunt Gamemode
function SPKZ_EntityTakeDamage(ent, dmginfo)
    local att = dmginfo:GetAttacker()
	if ent:GetClass() != "ph_prop" then return end
	ent.SPKZ_LastDamaged = att
end
hook.Add("EntityTakeDamage", "SPKZ_EntityTakeDamage", SPKZ_EntityTakeDamage)
function SPKZ_PlayerSilentDeath(ply)
	if !ply.ph_prop then return end
	if !ply.ph_prop.SPKZ_LastDamaged then return end
	SPKZ_IncKill(ply.ph_prop.SPKZ_LastDamaged,ply)
end
hook.Add("PlayerSilentDeath", "SPKZ_PlayerSilentDeath", SPKZ_PlayerSilentDeath)
	--Assists SOON!
	
	--Reset All code (for fretta based gamemode and uhh... TTT)
function SPKZ_ResetAll()
	MsgC( Color( 0, 128, 255 ), "[SPKZDKS]: Resetting all Killstreak Data...\n" )
	for _,ply in ipairs(player.GetAll()) do
		ply:SetNetworkedInt('SPKZ_KillStreak',0)
		ply:SetNWInt("SPKZ_CSKillStreak",1)
	end
	TotalKills = 0
end
hook.Add("TTTEndRound","SPKZ_ResetAll",SPKZ_ResetAll)
function SPKZ_PostGamemodeLoaded()
	if GAMEMODE.OnRoundEnd or GAMEMODE.BaseClass.OnRoundEnd then
		local oldfn = GAMEMODE.OnRoundEnd or GAMEMODE.BaseClass.OnRoundEnd
		function GAMEMODE:OnRoundEnd(...)
			SPKZ_ResetAll()
			oldfn(...)
		end
	end
end
hook.Add("PostGamemodeLoaded","SPKZ_PostGamemodeLoaded",SPKZ_PostGamemodeLoaded)
function SPKZ_IncKill(killer,victim)
	if not killer:IsPlayer() then return end
	local FirstBlood = (TotalKills == 0)
	local killstreakAtkr = killer:GetNetworkedInt('SPKZ_KillStreak',0)
	killer:SetNetworkedInt('SPKZ_KillStreak',killstreakAtkr + 1)
	local csk = SPKZ_IncCSKill(killer)
	local KillStreakTable = {
		atkr = killer,
		atkrN = killer:Nick(),
		atkrT = killer:Team(),
		atkrStreak = killstreakAtkr + 1,
		atkrCStreak = csk,
		isFirstBlood = FirstBlood,
		victim = victim
	}
	net.Start("ClientsideKillStreak")
	net.WriteTable(KillStreakTable)
	if cvars.Bool("spkz_dks_Broadcast") then 
		net.Broadcast()
	else
		net.Send(killer)
	end
	TotalKills = TotalKills + 1
end

function SPKZ_IncCSKill(killer)
	if not IsValid(killer) then return end
	local n = killer:GetNWInt("SPKZ_CSKillStreak",1) + 1
	killer:SetNWInt("SPKZ_CSKillStreak",n)
	local timerName = "CSKill"..killer:UserID()
	timer.Create(timerName , cvars.Number("spkz_dks_CSKillTimer") , 1, function()
		if not IsValid(killer) then return end
		killer:SetNWInt("SPKZ_CSKillStreak",1)
	end)
	return n
end