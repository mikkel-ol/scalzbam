-- Create stub
ScalzBam = LibStub("AceAddon-3.0"):GetAddon("ScalzBam")

function ScalzBam:Print(msg)
	print("|cfff26113ScalzBam|r:", msg)
end

function ScalzBam:Error(msg)
	print("|cffff0000Error|r:", msg)
end

function ScalzBam:Post(spell, dmg, inInstance, isShowoff)
	local channel = string.upper(self.db.char.post.channel)
	local msg, channelIndex

	-- handle blocked say/yell
	if not (inInstance) and ((string.upper(channel) == "SAY") or (string.upper(channel) == "YELL")) then
		self:Error("Could not display in '/" .. channel .. "' channel")
		self:Error("You are not in an instance")
		return
	elseif channel == "CHANNEL" then
		channelIndex = GetChannelName(self.db.char.post.custom.channel)
	end

	if (isShowoff) then msg = "[ScalzBam] [Highscore] " .. spell .. ", " .. dmg .. "!"
	else msg = "[ScalzBam] BAM! " .. spell .. " crit for " .. dmg .. "!"
	end

	if self.db.char.showMobName and self.db.char.records[spell].mob then msg = msg .. " [" .. self.db.char.records[spell].mob .. "]" end

	SendChatMessage(msg, channel, "Common", channelIndex)
end
