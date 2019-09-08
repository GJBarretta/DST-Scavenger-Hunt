name = "testBingo!"
forumthread = "" 
description = "\
Complete 5 tiles in a row to win Don't Starve BINGO.\
\
Click the bolt that pops up when hovering over the board to open the menu.\
The default keyboard toggle to open/close the board is 'v'.\
Misc Menu 3 to open/close the board for controllers.\
Misc Menu 4 to open/close the menu for controllers.\
The default keyboard toggle for controllers to open/close the menu is 'n'."
author = "Giuseppe Barretta"
version = "1.4"
api_version = 10
dont_starve_compatible = false
reign_of_giants_compatible = false
shipwrecked_compatible = false
dst_compatible = true
all_clients_require_mod = false
client_only_mod = true
server_filter_tags = {""}

icon_atlas = "bingo.xml"
icon = "bingo.tex"

local alpha = {"A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z"}
local KEY_A = 97
local keyslist = {}
for i = 1,#alpha do keyslist[i] = {description = alpha[i],data = i + KEY_A - 1} end

configuration_options =
{
	{
		name = "",
		label = "Bingo Board",
			hover = "",
		options =	{
						{description = "", data = 0},
					},
		default = 0,
	},
	{
		name = "boardScale",
		label = "Board Scale",
		hover = "How big the bingo board will be",
		options =
		{
			{description = "Tiny", data = 0.85},
			{description = "Medium", data = 0.9},
			{description = "Large", data = 1},
			{description = "Huge", data = 1.1}
		},
		default = 0.9,
	},
	{
		name = "BoardLoc",
		label = "Board Location",
		hover = "Where the bingo board will be on the screen",
		options =
		{
			{description = "Top Left", data = 5},
			{description = "Top Middle", data = 4},
			{description = "Mid Right", data = 1},
			{description = "Top Right", data = 2},
			{description = "Stay at TR", data = 3},
			{description = "Bottom Right", data = 6},
		},
		default = 2,
	},
	{
		name = "slotColor",
		label = "Slot Color",
		hover = "The background color of the bingo slots",
		options =
		{
			{description = "Default", data = 1},
			{description = "Blue", data = 2},
			{description = "Green", data = 3},
			{description = "Yellow", data = 4},
			{description = "Golden", data = 5},
			{description = "Teal", data = 6},
			{description = "Orange", data = 7},
			{description = "Purple", data = 8},
			{description = "Turqoise", data = 9}
		},
		default = 1,
	},
	{
		name = "",
		label = "Miscellaneous",
			hover = "",
		options =	{
						{description = "", data = 0},
					},
		default = 0,
	},
	{
		name = "OnWin",
		label = "Win Message",
		hover = "Choose what messages to receive when you win bingo",
		options =
		{
			{description = "Nothing", data = 1},
			{description = "Tell others", data = 2},
			{description = "Default", data = 3},
			{description = "Gimme it all", data = 4},
		},
		default = 3,
	},
	{
		name = "OnReward",
		label = "Win Reward",
		hover = "Choose whether or not to get free items when you win bingo\
				Only works if you are hosting the server yourself.",
		options =
		{
			{description = "Give rewards", data = true},
			{description = "No rewards", data = false},
		},
		default = true,
	},
	{
		name = "DoSound",
		label = "Sound",
		hover = "Turn Bingo sound effects on/off",
		options =
		{
			{description = "On", data = 1},
			{description = "Off", data = 2},
		},
		default = 1,
	},
	{
		name = "PRNG_def",
		label = "Board Generator",
		hover = "Choose which board generator to use. Default generates identical boards on every OS, but it's laggy.",
		options =
		{
			{description = "Default, lag", data = 1},
			{description = "Other, no lag", data = 2},
		},
		default = 1,
	},
	{
		name = "",
		label = "Controls",
			hover = "",
		options =	{
						{description = "", data = 0},
					},
		default = 0,
	},
    {
        name = "Toggle_Key",
        label = "Board Toggle Key",
		hover = "The keyboard toggle to open/close the bingo board",
        options = keyslist,
        default = 118, --V
    }, 
		{
        name = "ControllerBoardPress",
        label = "Controller Board Toggle",
		hover = "The toggle for controllers to open/close the bingo board. You can change what button misc menu is bound to in the game options.",
		options =
		{
			{description = "Misc Menu 1", data = 1},
			{description = "Misc Menu 2", data = 2},
			{description = "Misc Menu 3", data = 3},
			{description = "Misc Menu 4", data = 4},
		},
		default = 3,
    }, 
	{
        name = "ControllerMenuPress",
        label = "Controller Menu Toggle",
		hover = "The toggle for controllers to open/close the options menu. You can change what button misc menu is bound to in the game options.",
		options =
		{
			{description = "Misc Menu 1", data = 1},
			{description = "Misc Menu 2", data = 2},
			{description = "Misc Menu 3", data = 3},
			{description = "Misc Menu 4", data = 4},
		},
		default = 4,
    }, 
	{
        name = "ControllerMenuKeyPress",
        label = "Controller Menu Key",
	hover = "The keyboard toggle for controllers to open/close the options menu.",
        options = keyslist,
        default = 110, --N
    }, 
}


