--Get the settings
local time_format = minetest.settings:get("time_format") or "24_hour"
local date_order = minetest.settings:get("date_order") or "day_month_year"
local date_separator = minetest.settings:get("date_separator") or "slash"
local timezone = minetest.settings:get("timezone") or "UTC_00_00"
local daylight_saving_time = minetest.settings:get_bool("daylight_saving_time") or false

--table for interptiting timezones
local timezone_offsets = {
	["UTC_minus_12"] = -12,
	["UTC_minus_11"] = -11,
	["UTC_minus_10"] = -10,
	["UTC_minus_09_30"] = -9.5,
	["UTC_minus_09"] = -9,
	["UTC_minus_08"] = -8,
	["UTC_minus_07"] = -7,
	["UTC_minus_06"] = -6,
	["UTC_minus_05"] = -5,
	["UTC_minus_04_30"] = -4.5,
	["UTC_minus_04"] = -4,
	["UTC_minus_03_30"] = -3.5,
	["UTC_minus_03"] = -3,
	["UTC_minus_02"] = -2,
	["UTC_minus_01"] = -1,
	["UTC_00_00"] = 0,
	["UTC_plus_01"] = 1,
	["UTC_plus_02"] = 2,
	["UTC_plus_03"] = 3,
	["UTC_plus_03_30"] = 3.5,
	["UTC_plus_04"] = 4,
	["UTC_plus_04_30"] = 4.5,
	["UTC_plus_05"] = 5,
	["UTC_plus_05_30"] = 5.5,
	["UTC_plus_05_45"] = 5.75,
	["UTC_plus_06"] = 6,
	["UTC_plus_06_30"] = 6.5,
	["UTC_plus_07"] = 7,
	["UTC_plus_08"] = 8,
	["UTC_plus_08_45"] = 8.75,
	["UTC_plus_09"] = 9,
	["UTC_plus_09_30"] = 9.5,
	["UTC_plus_10"] = 10,
	["UTC_plus_10_30"] = 10.5,
	["UTC_plus_11"] = 11,
	["UTC_plus_12"] = 12,
	["UTC_plus_12_45"] = 12.75,
	["UTC_plus_13"] = 13,
	["UTC_plus_14"] = 14
}

--Convert the settings to the corresponding format strings
if time_format == "24_hour" then 
	time_format = "%H:%M:%S" 
else 
	time_format = "%I:%M:%S %p" 
end

--Set the date separator
if date_separator == "slash" then 
	date_separator_char = "/"
elseif date_separator == "dash" then 
	date_separator_char = "-"
elseif date_separator == "period" then 
	date_separator_char = "."
elseif date_separator == "comma" then 
	date_separator_char = ","
end

--Set date order
if date_order == "month_day_year" then 
	date_format = "%m"..date_separator_char.."%d"..date_separator_char.."%Y" 
elseif date_order == "year_month_day" then 
	date_format = "%Y"..date_separator_char.."%m"..date_separator_char.."%d" 
elseif date_order == "year_day_month" then 
	date_format = "%Y"..date_separator_char.."%d"..date_separator_char.."%m" 
elseif date_order == "day_month_year" then
	date_format = "%d"..date_separator_char.."%m"..date_separator_char.."%Y" 
end

local timezone_offset = timezone_offsets[timezone]

--Dayligh savings support
if daylight_saving_time then
    timezone_offset = timezone_offset + 1
end

local function get_time_and_date()
	local time = os.date(time_format, os.time() + timezone_offset * 60 * 60)
	local date = os.date(date_format)
	local time_and_date = minetest.colorize('yellow', "[Message sent at "..time.." on "..date.."]")
	return time_and_date
end

--Modify chat messages
minetest.register_on_chat_message(function(name, message) 
	minetest.after(0.001, function()
		local time_and_date = get_time_and_date()
		minetest.chat_send_all(time_and_date)
	end)
	return false
end)

local old_msg_command = minetest.registered_chatcommands["msg"].func

minetest.registered_chatcommands["msg"].func = function(name, param)
	--This is to get the player name that the DM is being sent to.
	--If minetest ever allows player names with spaces then this will need to be updated.

	local player_name = param:match("(%w+)")

	--Send the date and time message to the person who is supposed to get the DM.

	minetest.after(0.001, function()
		local time_and_date = get_time_and_date()
		minetest.chat_send_player(player_name, time_and_date)
	end)


    -- Call the origial /msg command to send the message.
    return old_msg_command(name, param)
end
