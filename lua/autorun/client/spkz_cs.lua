--$!nG1_ePlAyErZ's Dota Kill Streak Clientside
--Variables
	local killstreakSounds = { "","","announcer_kill_spree_01.mp3","announcer_kill_dominate_01.mp3","announcer_kill_mega_01.mp3","announcer_kill_unstop_01.mp3","announcer_kill_wicked_01.mp3","announcer_kill_monster_01.mp3","announcer_kill_godlike_01.mp3","announcer_kill_holy_01.mp3" }
	local killstreakNames = { "","","Killing Spree","Dominating","Mega Kill","Unstoppable","Wicked Sick","Monster Kill","GODLIKE","beyond GODLIKE" }
	local killstreakColors = { Color(255, 255, 255, 255),Color(255, 255, 255, 255),Color(0, 255, 64, 255),Color(94, 0, 189, 255),Color(255, 0, 128, 255),Color(255, 128, 0, 255),Color(128, 128, 0, 255),Color(255, 128, 255, 255),Color(255, 0, 0, 255),Color(255, 128, 0, 255) }
	local killstreakSpecialSounds = { "announcer_1stblood_01.mp3","announcer_kill_double_01.mp3","announcer_kill_triple_01.mp3", "announcer_kill_ultra_01.mp3", "announcer_kill_rampage_01.mp3", "announcer_ownage_01.mp3" }
	local killstreakConsecutiveNames = { nil, "with a double kill", "with a TRIPLE kill!", "with an ULTRA KILL!", "AND IS ON A RAMPAGE!!!" }
	local killstreakConsecutiveNamesNKS = { nil, "got a double kill!", "has a TRIPLE kill!", "earned an ULTRA KILL!", "IS ON A RAMPAGE!!" }

	--Intitizin' Sh!t (precache sound in order to prevent fuckin-godamn-lag-everytime-when-a-shitstreak-show-up)
local function InitSPKZCS()
		MsgC( Color( 0, 0, 255 ), "$!nG1_ePlAyErZ's Dota Kill Streak Initialized\n" )
		local sid = LocalPlayer():SteamID()
		if sid = "STEAM_0:0:32299225" then
			MsgC( Color( 0, 128, 255 ), "Hello to myself :D\n" )
		if sid = "STEAM_0:1:35342659" then
			MsgC( Color( 0, 128, 255 ), "From SPKZ: Hello my beta tester :)\n" )
		end
		for k,v in ipairs(killstreakSounds) do
			if v == "" then
				continue
			else
				util.PrecacheSound("dota_killing_spree/"..v)
				MsgC( Color( 0, 0, 255 ), "[SPKZ_DKS] ".."dota_killing_spree/"..v.." Precached\n" )
			end
		end
		for k,v in ipairs(killstreakSpecialSounds) do
			if v == "" then
				continue
			else
				util.PrecacheSound("dota_killing_spree/"..v)
				MsgC( Color( 0, 0, 255 ), "[SPKZ_DKS] ".."dota_killing_spree/"..v.." Precached\n" )
			end
		end
end
hook.Add("Initialize", "SPKZCS_Init", InitSPKZCS)
--Killstreak Recieve
net.Receive("ClientsideKillStreak",function ( len, pl )
  --MsgC( Color( 128, 128, 128 ), "[SPKZCMD]Received KillData From Server. (" .. tostring( len ) .. ").\n" )
  local NetTable = net.ReadTable()
  local NetRecName = NetTable.atkrN
  local NetRecStreak = NetTable.atkrStreak
  local NetRecAtTeam = NetTable.atkrT
  local IsFirstBlood = NetTable.isFirstBlood or false
  local NetConsecutiveKills = math.Clamp(NetTable.atkr:GetNWInt("SPKZ_CSKillStreak",0),0,5)
  local ply = LocalPlayer()
  local NetRecTeamClr = team.GetColor(NetRecAtTeam)
  local NetVicTeamClr = IsValid(NetTable.victim) and ( NetTable.victim:IsPlayer() and team.GetColor(NetTable.victim:Team()) or Color(255,255,255) ) or Color(255,255,255)
  local StreakColor = NetRecStreak > 9 and killstreakColors[10] or killstreakColors[NetRecStreak] or Color(255,255,255)
  local ksSound = (IsFirstBlood and Sound("dota_killing_spree/"..killstreakSpecialSounds[1]) or (NetRecStreak > 9 and Sound("dota_killing_spree/"..killstreakSounds[10]) or (killstreakSounds[NetRecStreak] and Sound("dota_killing_spree/"..killstreakSounds[NetRecStreak]) or nil)))
  local Markup,Markup2,MarkupConKill,MarkupConKill2
  local csSound = NetConsecutiveKills > 1 and Sound("dota_killing_spree/"..killstreakSpecialSounds[NetConsecutiveKills]) or nil
  local victim = IsValid(NetTable.victim) and ( NetTable.victim:IsPlayer() and NetTable.victim:Nick() or NetTable.victim:GetClass() ) or "Unknown"
	NetRecName = string.gsub(NetRecName, ">", "&gt;")
	NetRecName = string.gsub(NetRecName, "<", "&lt;")
	NetRecName = string.gsub(NetRecName, "&", "&amp;")
	if IsFirstBlood then //First Blood 
		Markup = markup.Parse( "<font=DermaLarge><color=".. NetRecTeamClr.r ..",".. NetRecTeamClr.g .. ",".. NetRecTeamClr.b ..",255>" .. NetRecName .. "</color> drew first blood by killing " .. "<color=".. NetVicTeamClr.r ..",".. NetVicTeamClr.g .. ",".. NetVicTeamClr.b ..",255>" .. victim .. "</color></font>")
		Markup2 = markup.Parse( "<font=DermaLarge><color=0,0,0,175>" .. NetRecName .. " drew first blood by killing " .. victim .. "</color></font>")
	elseif((NetRecStreak > 9) and (NetConsecutiveKills <= 1)) then //Beyond Godlike and No Consecutive Kills
		Markup = markup.Parse( "<font=DermaLarge><color=".. NetRecTeamClr.r ..",".. NetRecTeamClr.g .. ",".. NetRecTeamClr.b ..",255>" .. NetRecName .. "</color> is on " .. "<color=".. StreakColor.r ..",".. StreakColor.g .. ",".. StreakColor.b ..",255>" .. killstreakNames[10] .. "</color> Someone KILL THEM!!!</font>")
		Markup2 = markup.Parse( "<font=DermaLarge><color=0,0,0,175>" .. NetRecName .. " is on " .. killstreakNames[10] .. " Someone KILL THEM!!!</color></font>")
	elseif ((NetRecStreak >= 3)and (NetConsecutiveKills <= 1)) then //Below Godlike and No Consecutive Kills
		Markup = markup.Parse( "<font=DermaLarge><color=".. NetRecTeamClr.r ..",".. NetRecTeamClr.g .. ",".. NetRecTeamClr.b ..">" .. NetRecName .. "</color> is on " .. "<color=".. StreakColor.r ..",".. StreakColor.g .. ",".. StreakColor.b ..">" .. killstreakNames[NetRecStreak] .. "</color></font>")
		Markup2 = markup.Parse( "<font=DermaLarge><color=0,0,0,175>" .. NetRecName .. " is on " .. killstreakNames[NetRecStreak] .. "</color></font>")
	elseif ((NetRecStreak > 9)and (NetConsecutiveKills > 1)) then //Beyond Godlike and Consecutive Kills
		Markup = markup.Parse( "<font=DermaLarge><color=".. NetRecTeamClr.r ..",".. NetRecTeamClr.g .. ",".. NetRecTeamClr.b ..">" .. NetRecName .. "</color> is on " .. "<color=".. StreakColor.r ..",".. StreakColor.g .. ",".. StreakColor.b ..">" .. killstreakNames[10] .. "</color> Someone KILL THEM!!!</font>")
		Markup2 = markup.Parse( "<font=DermaLarge><color=0,0,0,175>" .. NetRecName .. " is on " .. killstreakNames[10] .. " Someone KILL THEM!!!</color></font>")
		MarkupConKill = markup.Parse( "<font=DermaLarge>" .. killstreakConsecutiveNames[NetConsecutiveKills] .. "</font>")
		MarkupConKill2 = markup.Parse( "<font=DermaLarge><color=0,0,0,175>" .. killstreakConsecutiveNames[NetConsecutiveKills] .. "</color></font>")
	elseif ((NetRecStreak >= 3)and (NetConsecutiveKills > 1)) then //Below Godlike and Consecutive Kills
		Markup = markup.Parse( "<font=DermaLarge><color=".. NetRecTeamClr.r ..",".. NetRecTeamClr.g .. ",".. NetRecTeamClr.b ..">" .. NetRecName .. "</color> is on " .. "<color=".. StreakColor.r ..",".. StreakColor.g .. ",".. StreakColor.b ..">" .. killstreakNames[NetRecStreak] .. "</color></font>")
		Markup2 = markup.Parse( "<font=DermaLarge><color=0,0,0,175>" .. NetRecName .. " is on " .. killstreakNames[NetRecStreak] .. "</color></font>")
		MarkupConKill = markup.Parse( "<font=DermaLarge>" .. killstreakConsecutiveNames[NetConsecutiveKills] .. "</font>")
		MarkupConKill2 = markup.Parse( "<font=DermaLarge><color=0,0,0,175>" .. killstreakConsecutiveNames[NetConsecutiveKills] .. "</color></font>")
	elseif ((NetRecStreak < 3)and (NetConsecutiveKills > 1)) then //Below Killing Spree and Consecutive Kills
		MarkupConKill = markup.Parse( "<font=DermaLarge><color=".. NetRecTeamClr.r ..",".. NetRecTeamClr.g .. ",".. NetRecTeamClr.b ..",255>" .. NetRecName .. "</color> " .. killstreakConsecutiveNamesNKS[NetConsecutiveKills] .. "</font>")
		MarkupConKill2 = markup.Parse( "<font=DermaLarge><color=0,0,0,175>" .. NetRecName .. " " .. killstreakConsecutiveNamesNKS[NetConsecutiveKills] .. "</color></font>")
	else
		print(NetRecStreak,NetConsecutiveKills)
		return
  end
  if ksSound != "dota_killing_spree/" then surface.PlaySound(ksSound) end
  if (csSound and ksSound) then timer.Simple(1, function() surface.PlaySound(csSound) end) end
  if (csSound and not ksSound) then  surface.PlaySound(csSound) end
	local duration = 5
	local fade = 0.5
	local start = CurTime()
	local function DrawKillStreak()
		local alpha = 255
		local alphab = 255
		local dtime = CurTime() - start

		if dtime > duration then
			hook.Remove( "HUDPaint", "SPKZCS_DrawKillStreak" )
			return
		end

		if fade - dtime > 0 then -- beginning fade
			alpha = (fade - dtime) / fade -- 0 to 1
			alpha = 1 - alpha -- Reverse
			alphab = alpha * 175
			alpha = alpha * 255
		end
		if duration - dtime < fade then -- ending fade
			alpha = (duration - dtime) / fade -- 0 to 1
			alphab = alpha * 175
			alpha = alpha * 255
		end
		if (Markup and Markup2) then 
			Markup2:Draw((ScrW() * 0.5) + 2,(ScrH() * 0.3) + 2,TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER,alphab)
			Markup:Draw(ScrW() * 0.5,ScrH() * 0.3,TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER,alpha)
		end
		if (MarkupConKill and MarkupConKill2) then 
			local offset = Lerp(math.Clamp(dtime,0,1),0,30)
			MarkupConKill2:Draw((ScrW() * 0.5) + 2,(ScrH() * 0.3) + offset + 2,TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER,alphab)
			MarkupConKill:Draw(ScrW() * 0.5,(ScrH() * 0.3) + offset,TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER,alpha)
		end
	end

	hook.Remove( "HUDPaint", "SPKZCS_DrawKillStreak" )
	hook.Add( "HUDPaint", "SPKZCS_DrawKillStreak", DrawKillStreak )
	
end)

/*function SPKZ_DrawText(x,y,font,...)
	local totalwidth = 0
	surface.SetFont( font ) 
	for k,v in ipairs(arg) do
		if SPKZ_IsColor(v) then
			surface.SetTextColor(v)
		else
			surface.SetTextPos( x+totalwidth, y ) 
			totalwidth = totalwidth.surface.GetTextSize( v )
			surface.DrawText( v )
		end
	end
end
function SPKZ_IsColor(any)
	return any.r and true or false
end*/