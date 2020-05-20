-- Create stub
ScalzBam = LibStub("AceAddon-3.0"):GetAddon("ScalzBam")
ScalzBam_HighscoreFrame = ScalzBam:NewModule("ScalzBam_HighscoreFrame", "AceEvent-3.0", "AceHook-3.0")

-- Libs
local AceGUI = LibStub("AceGUI-3.0")

-- Shorten
local S = ScalzBam_HighscoreFrame

-- Create a container frame
local frame = AceGUI:Create("Frame")
frame:SetWidth(380)
frame:SetHeight(400)
frame:SetCallback("OnClose", function(widget) AceGUI:Release(widget) end)
frame:SetTitle("Highscores")
frame:SetStatusText("Are you proud of yourself?")
frame:SetLayout("Fill")

-- Create scrollable container
local scroll = AceGUI:Create("ScrollFrame")
frame:AddChild(scroll)

-- Hide it by default
frame:Hide()

-----------------------------------------------------------------------------
-- Local variables

------------------
--- Module API ---
------------------

function S:Show()
	frame:Show()
end	

function S:AddRow(spell, damage, offset)
	local row = CreateFrame("Frame", nil, frame.content)
	row:SetSize(300, 50)
	row:SetPoint("LEFT", frame.content, "TOPLEFT", 5, -offset*15)

	--local _, __, icon = GetSpellInfo(spell)

	--row.icon = row:CreateTexture()
	--row.icon:SetTexture(icon)

	row.text = row:CreateFontString(nil, "OVERLAY")
	row.text:SetFont("Fonts\\FRIZQT__.TTF", 16)
	row.text:SetPoint("LEFT", 5, 0)
	row.text:SetText("Hej")

	frame:DoLayout()
end

function S:Empty()

end
