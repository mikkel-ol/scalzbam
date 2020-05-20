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
	if not (inInstance) and ((channel == "say") or (channel == "yell")) then
		self:Error("Could not display in '/" .. channel .. "' channel")
		self:Error("You are not in an instance")
	elseif channel == "CHANNEL" then
		channelIndex = GetChannelName(self.db.char.post.custom.channel)
	end

	if (isShowoff) then msg = "[ScalzBam] [Highscore] " .. spell .. ", " .. dmg .. "!"
	else msg = "[ScalzBam] BAM! " .. spell .. " crit for " .. dmg .. "!"
	end

	SendChatMessage(msg, channel, "Common", channelIndex)
end
