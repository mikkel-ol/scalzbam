-- Create stub
ScalzBam = LibStub("AceAddon-3.0"):GetAddon("ScalzBam")
ScalzBam_Options = ScalzBam:NewModule("ScalzBam_Options", "AceEvent-3.0", "AceHook-3.0")

M = ScalzBam_Options

-- Default DB settings
local dbDefaults = {
	char = {
		enabled = true,
		records = {},
		showMobName = false,
		channel = nil,
		audio = false,
		debug = false,
		minimap = { 
			hide = false, 
		},
		post = {
			enabled = false,
			channel = nil,
			whisper = {
				hidden = true,
				char = nil,
			},
			custom = {
				hidden = true,
				channel = nil,
			}
		}
	}
}

local icon = LibStub("LibDBIcon-1.0")

local scalzLDB = LibStub("LibDataBroker-1.1"):NewDataObject("ScalzBam", {
	type = "data source",
	text = "ScalzBam",
	icon = "Interface\\AddOns\\ScalzBam\\Assets\\minimapicon.blp",
	OnTooltipShow = function(tooltip)
		if not tooltip or not tooltip.AddLine then return end
		tooltip:AddLine("ScalzBam")
		tooltip:AddLine("|cffffff00Click|r to show highscores")
		tooltip:AddLine("|cffffff00Right-click|r to open the options menu")
	end,
	OnClick = function(_, msg)
		if (msg == "LeftButton") then
			ScalzBam:ShowHighscores()
		elseif (msg == "RightButton") then
			LibStub("AceConfigDialog-3.0"):Open("ScalzBam")
		else
			ScalzBam:ShowHighscores()		
		end
	end,
})

function M:OnInitialize()
	ScalzBam.db = LibStub("AceDB-3.0"):New("ScalzBamDB", dbDefaults)
	LibStub("AceConfigDialog-3.0"):AddToBlizOptions("ScalzBam")
	icon:Register("ScalzBam", scalzLDB, ScalzBam.db.char.minimap)

	-- Clear old AA key
	ScalzBam.db.char.records["AA"] = nil

	-- Move record numbers into new table
	for key, value in pairs(ScalzBam.db.char.records) do
		if type(value) == "number" then
			ScalzBam.db.char.records[key] = {
				dmg = value,
				mob = nil
			}
		end
	end

	if (ScalzBam.db.char.enabled) then ScalzBam:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
	else ScalzBam:UnregisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
	end
end

-------------------------------------------------------------------------

ScalzBam_Options = {
    name = "ScalzBam",
    handler = ScalzBam,
    type = 'group',
    args = {
    	cfg = {
    		name = "Config window",
    		desc = "Opens config window",
    		guiHidden = true,
    		type = 'execute',
            func = function() LibStub("AceConfigDialog-3.0"):Open("ScalzBam") end,
    	},
    	g = {
    		name = "General",
    		type = "group",
    		order = 0,
    		args = {
    			enable = {
					order = 1, -- first
					name = "Addon enable",
					desc = "Enables / disables the addon",
					type = "toggle",
					set = function(info, val)
							ScalzBam.db.char.enabled = val
							
							if (val) then ScalzBam:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
							else ScalzBam:UnregisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
							end
						end,
					get = function(info) return ScalzBam.db.char.enabled end
				},
		        audio = {
		        	name = 'Audio enable',
		        	desc = 'Enables / disables audio on new highscore',
		            type = 'toggle',
		            set = function(info, val) ScalzBam.db.char.audio = val end,
		            get = function(info) return ScalzBam.db.char.audio end,
				},
				mob = {
					name = "Show mob name",
					desc = "Display name of mob on highscores",
					type = "toggle",
					set = function(info, val) ScalzBam.db.char.showMobName = val end,
					get = function(info) return ScalzBam.db.char.showMobName end,
				},
		        minimap = {
					order = -1, -- last
		        	name = "Minimap icon",
		        	desc = "Enables / disables minimap icon",
		        	type = "toggle",
		        	set = function(info, val) 
		        			ScalzBam.db.char.minimap.hide = not ScalzBam.db.char.minimap.hide 
		        			if val then icon:Show("ScalzBam") 
		        			else icon:Hide("ScalzBam") 
		        			end 
		        		end,
		        	get = function(info) return not ScalzBam.db.char.minimap.hide end,
		        }
    		}
    	},
	   	ch = {
    		name = "Channel",
    		type = "group",
    		order = 1,
    		args = {
    			enable = {
    				order = 1,
    				name = "Post highscore",
    				desc = "Send new highscore to channel",
    				type = "toggle",
    				get = function(info) return ScalzBam.db.char.post.enabled end,
    				set = function(info, val) ScalzBam.db.char.post.enabled = val end,
    			},
    			channel = {
    				order = 2,
    				hidden = function() return not ScalzBam.db.char.post.enabled end,
					name = "Set channel",
					desc = "Set text channel for highscore output",
					type = "select",
					values = {
						say="/say*",
						yell="|cffff4040/yell*",
						party="|cffaaaaff/party",
						raid="|cffff7f00/raid",
						rw="|cffff4800/rw",
						guild="|cff40ff40/guild",
						officer="|cff40c040/officer",
						whisper="|cffff80ff/whisper",
						channel="Custom channel",
					},
					get = function(info) return ScalzBam.db.char.post.channel end,
					set = function(info, val)
						ScalzBam.db.char.post.whisper.hidden = true
						ScalzBam.db.char.post.custom.hidden = true

						if (val == "whisper") then ScalzBam.db.char.post.whisper.hidden = false
						elseif (val == "channel") then ScalzBam.db.char.post.custom.hidden = false
						end

						ScalzBam.db.char.post.channel = val

						if (val == "say") or (val == "yell") then ScalzBam:Print("NOTE: This channel only works in instances!") end
					end,
				},
				whisperchar = {
					order = -1, -- last
					hidden = function() return (not ScalzBam.db.char.post.enabled) or ScalzBam.db.char.post.whisper.hidden end,
					name = "Character name",
					desc = "Who to whisper to?",
					type = "input",
					validate = function(info, val) if string.match(val, "%a+") == val then return true else return "Not a valid character name" end end,
					get = function(info) return ScalzBam.db.char.post.whisper.char end,
					set = function(info, val) ScalzBam.db.char.post.whisper.char = val end,
				},
				customchannel = {
					order = -1, -- last
					hidden = function() return (not ScalzBam.db.char.post.enabled) or ScalzBam.db.char.post.custom.hidden end,
					name = "Channel name",
					desc = [[Name on custom channel
(ex. '/customchannel' or '/2')]],
					type = "input",
					validate = function(info, val) if string.match(val, "/?%w+") == val then return true else return "Not a valid channel name" end end,
					get = function(info) return ScalzBam.db.char.post.custom.channel end,
					set = function(info, val) ScalzBam.db.char.post.custom.channel = string.match(val, "%w+") end,
				}
    		}
    	},
    	hs = {
    		name = "Highscores",
    		type = "group",
    		order = 2,
    		args = {
			 	show = {
		        	name = 'Show highscores',
		        	desc = 'Show all current highscores',
		            type = 'execute',
		            func = "ShowHighscores"
		        },
                clear = {
		        	name = 'Clear highscores',
					desc = 'Clear entire collection of highscores',
					confirm = function() return "Are you sure you want to clear entire database of records?" end,
		            type = 'execute',
		            func = function() 
			            	ScalzBam.db.char.records = {}
							ScalzBam:Print("Cleared highscores")
						end,
		        },
    		}
    	},
    	debug = {
    		name = "Debug",
    		type = "group",
    		order = -1, -- last
    		args = {
		        debugmode = {
		        	name = "Debug mode",
					desc = [[Turn on / off debug mode
CAREFUL! WILL OUTPUT ALOT!]],
		        	type = "toggle",
		        	set  = function(info, val)
			        		ScalzBam.db.char.debug = val
							if (val) then ScalzBam:Print("Debug mode ON")
							else ScalzBam:Print("Debug mode OFF")
							end
						end,
		        	get = function(info) return ScalzBam.db.char.debug end,
		        }
    		}
    	}
    },
}

LibStub("AceConfig-3.0"):RegisterOptionsTable("ScalzBam", ScalzBam_Options, {"bam", "scalzbam"})
