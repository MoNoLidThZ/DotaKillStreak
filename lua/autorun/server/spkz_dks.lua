--Hello and why the hell are you decompiling my code?
--$!nG1_ePlAyErZ's Dota 2 Kill Streak Display
	local version = "2.2a"
	local releasedate = "10/6/2014"
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
	if not cvars.Bool("spkz_dks_enabled") then return end
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
	--Assists SOON!
	
	--Reset All code (for fretta based gamemode and uhh... TTT)
function SPKZ_ResetAll()
	for _,ply in ipairs(player.GetAll()) do
		ply:SetNetworkedInt('SPKZ_KillStreak',0)
		ply:SetNWInt("SPKZ_CSKillStreak",1)
	end
end
hook.Add("RoundEnd","SPKZ_ResetAll",SPKZ_ResetAll)
hook.Add("TTTEndRound","SPKZ_ResetAll",SPKZ_ResetAll)
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