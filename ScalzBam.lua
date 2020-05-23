-- Create stub
ScalzBam = LibStub("AceAddon-3.0"):NewAddon("ScalzBam", "AceConsole-3.0", "AceEvent-3.0")

-----------------------------------------------------

function ScalzBam:HandleCombatEvent(spellName, dmg, destName, inInstance)
	local currentRecord = self.db.char.records[spellName]

	-- First time
	if (currentRecord == nil) then
		currentRecord = {
			dmg = 0,
			mob = nil,
		}
	end

	if (dmg > currentRecord.dmg) then
		-- new record
		currentRecord.dmg = dmg
		currentRecord.mob = destName
		self.db.char.records[spellName] = currentRecord

		-- play audio if enabled
		if (self.db.char.audio) then PlaySoundFile("Interface\\AddOns\\ScalzBam\\Assets\\crazy.ogg") end

		-- print
		msg = "New highscore, " .. spellName .. " with " .. dmg .. "!"
		if self.db.char.showMobName then msg = msg .. " [" .. currentRecord.mob .. "]" end
		self:Print(msg)

		-- tell
		if self.db.char.post.enabled then self:Post(spellName, dmg, inInstance) end
	end
end

function ScalzBam:NEW_ShowHighscores()
	local frame = ScalzBam:GetModule("ScalzBam_HighscoreFrame")

	local count = 0
	for spell, damage in pairs(self.db.char.records) do
		frame:AddRow(spell, damage, count+1)
		count = count + 1
	end
	if (count == 0) then
		frame:Empty()
	end

	frame:Show()
end

function ScalzBam:ShowHighscores()
	-- testing
	--self.db.char.records["TESTING"] = {
	--	dmg = 300,
	--	mob = "Big dick mob"
	--}

	local AceGUI = LibStub("AceGUI-3.0")

	-- Create a container frame
	local frame = AceGUI:Create("Frame")
	frame:SetWidth(480)
	frame:SetHeight(500)
	frame:SetCallback("OnClose", function(widget) AceGUI:Release(widget) end)
	frame:SetTitle("Highscores")
	frame:SetStatusText("Are you proud of yourself?")
	frame:SetLayout("Fill")

	-- Create scrollable container
	local scroll = AceGUI:Create("ScrollFrame")
	scroll:SetLayout("List")
	frame:AddChild(scroll)
	
	--
	-- Iterate all highscores
	--
	local count = 0
	for spell, record in pairs(self.db.char.records) do
		-- Create highscore container
		local container = AceGUI:Create("SimpleGroup")
		container:SetAutoAdjustHeight(false)
		container:SetLayout("Flow")
		container:SetFullWidth(true)
		container:SetHeight(100)

		local _, __, spellIcon = GetSpellInfo(spell)
		-- auto attack fix
		if (spell == "Auto attack") then
			spellIcon = "Interface\\ICONS\\Ability_MeleeDamage"
		end
		local i = AceGUI:Create("Icon")
		i:SetImage(spellIcon)
		i:SetImageSize(48, 48)
		i:SetCallback("OnClick", function(button)
			if (self.db.char.post.channel) then
				local _, type = GetInstanceInfo()
				if (type == "none") then isInInstance = false
				else isInInstance = true end
				if self.db.char.post.enabled then self:Post(spell, record.dmg, isInInstance, true) end
			else
				self:Print("You do not have a channel selected")
				self:Print("Select one with '/bam channel'")
			end
		end)
		container:AddChild(i)

		local l = AceGUI:Create("Label")
		l:SetFullWidth(true)
		l:SetFont("Fonts\\FRIZQT__.TTF", 16)
		local msg = "|cffe6d417" .. spell .. "|r" .. " with |cffff0000" .. record.dmg .. "|r damage!"
		if self.db.char.showMobName and record.mob then msg = msg .. " |cff909090[" .. record.mob .. "]|r" end
		l:SetText(msg)
		container:AddChild(l)

		count = count + 1

		scroll:AddChild(container)
	end
	if (count == 0) then
		local l = AceGUI:Create("Label")
		l:SetText("No highscores recorded yet!")
		container:AddChild(l)
	end

	frame:DoLayout()
end

local timer, seconds
function ScalzBam:OnTimerTick()
	seconds = seconds + 1
end

function ScalzBam:OnInitialize()
	-- check time
	timestamp = time()
	randomWednesdayAt2100 = 1589396400
	secondsInAWeek = 604800
	secondsToWednesdayAt2100 = secondsInAWeek - ((timestamp-randomWednesdayAt2100) % secondsInAWeek)

	testSeconds = 60

	C_Timer.After(testSeconds, function()
		seconds = 0
		timer = C_Timer.NewTicker(1, ScalzBam.OnTimerTick)
	end)

	C_ChatInfo.RegisterAddonMessagePrefix("ScalzBam")
end

function ScalzBam:COMBAT_LOG_EVENT_UNFILTERED()
	local eventInfo = { CombatLogGetCurrentEventInfo() }
	local type = eventInfo[2]
	local sourceGUID = eventInfo[4]
	local sourceFlags = eventInfo[6]
	local destName = eventInfo[9]
	local isTotem = (bit.band(sourceFlags, 0x00002001) == 0x00002001)

	if (self.db.char.debug) then
		print("Type: " .. type)
		print("SourceFlags: " .. string.format( "0x%8.8X", sourceFlags ))
	end

	-- Ignore from anything other than self, pet or totem
	if not (sourceGUID == UnitGUID("player")) and not (sourceGUID == UnitGUID("pet")) and not (isTotem) then
		return
	end

	local _, instanceType = GetInstanceInfo()
	if (instanceType == "none") then instanceType = false
	else instanceType = true
	end

	local spellName, amount, isCrit

	if (type == "SWING_DAMAGE") then
		isCrit = eventInfo[18]
		spellName = "Auto attack"
		amount = eventInfo[12]

	elseif (type == "SPELL_DAMAGE") or (type == "RANGE_DAMAGE") then
		isCrit = eventInfo[21]
		spellName = eventInfo[13]
		amount = eventInfo[15]

	elseif (type == "SPELL_HEAL") then
		isCrit = eventInfo[18]
		spellName = eventInfo[13]
		amount = eventInfo[15]
	else
		-- Ignore other types
		return;
	end

	-- Ignore non crits
	if not (isCrit) then
		return
	end

	self:HandleCombatEvent(spellName, amount, destName, instanceType)
end

function ScalzBam:CHAT_MSG_ADDON(_, prefix, text, channel, sender, target, zoneChannelID, localID, name, instanceID)
	if prefix == "ScalzBam" then
		if text == "DISABLE_TIMER" then return timer:Cancel() end
		local delim = ":"
		local msg = string.match(text, "(.*)" .. delim)
		local channel = string.match(text, delim .. "(.*)")
		SendChatMessage(msg, channel)
	end
end

-------------------------------------------------------------------------


-- Register events
ScalzBam:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
ScalzBam:RegisterEvent("CHAT_MSG_ADDON")