function tablelength(T)
  local count = 0
  for _ in pairs(T) do count = count + 1 end
  return count
end


placement = 0 -- 1 or 2 points

wand_grab = 0 -- 1.5

deaths = 0 -- -0.5
coin_ship = 0 -- -0.5
fanfare = 0 -- -0.5

-- keep flower, hammer kill, no stars, w2 boss kill, w4 fort, hammer basement
-- door 3, jesus clip, zclip 7-7, zclip w6, wall jump 6-9, clip 7-6, clip 7-9
-- deathless, tunnel, fast 2-2, fast 3-1, wendy kill, w5 movements, clip 7-1, rangless, elavator skip, hands
-- give up, big slow, w4 star bro, shaft
Points = {
	false, false, true, false, false, false,
	false, false, false, false, false, false, false,
	true, false, false, false, false, false, false, false, false, false,
	false, false, false, false
}

POINTS_LEN = tablelength(Points)

POINT_TRANS = { -- what something is if it is true
	3, 1, 0.5, 0.5, 0.5, 0.5,
	0.5, 3, 1, 1.5, 0.5, 0.5, 1.5,
	1, 0.5, 0.5, 0.5, 0.5, -0.5, 0.5, 0.5, 0.5, 0.5,
	-1, -1, -0.5, -0.5
}

function get_time()
	return tonumber(memory.readbyte(0x05EE) ..memory.readbyte(0x05EF).. memory.readbyte(0x05F0))
end

function get_pos()
	return memory.readword(0x90, 0x75)
end

lives = 0
function check_death()
	l = memory.readbyte(0x0736)
	if lives > l then
		deaths = deaths + 1
	end
	lives = l
	if deaths > 0 then
		Points[14] = false -- deathless point is gone
	end
end	

enter_6f = false
flower = false
function check_first_flower() -- checks to see if you lost your first fire flower prior to 6-f
	level = memory.readword(0x7EB9, 0x7EBA)
	if level == 0xB151 then
		enter_6f = true
	end
	if enter_6f ~= true then
		power_up = memory.readbyte(0xED)
		power_up_ow = memory.readbyte(0x0746)
		if flower then
			if power_up ~= 0x02 then
				if not power_up == 0x00 and power_up_ow == 0x02 then
					flower = false
					Points[1] = false
				end
				if power_up_ow ~= 0x02 then
					flower = false
					Points[1] = false
				end
				if power_up == 0x01 then
					flower = false
					Points[1] = false
				end
			end
		else
			if power_up == 0x02 then
				flower = true
				Points[1] = true
			end
		end
	end
end

function check_used_star()
	power_up_ow = memory.readbyte(0x03F2)
	if power_up_ow == 0x01 then
		Points[3] = false
	end
end

eligable_2a = true
enter_2a = false
function check_for_fast_w2_kill()
	level = memory.readword(0x7EB9, 0x7EBA)
	if level == 0xAEAB then
		enter_2a = true
	end
	if eligable_2a then
		if enter_2a then
			timer_end = memory.readbyte(0x07BD)
			if timer_end == 0x04 then
				eligable_2a = false
				if get_time() >= 221 then
					Points[4] = true
				end
			end
		end
	end
end

eligable_4f = true
enter_4f = false
function check_for_fast_w4_fort()
	level = memory.readword(0x7EB9, 0x7EBA)
	if level == 0xB6A6 then
		enter_4f = true
	end
	if eligable_4f then
		if enter_4f then
			timer_end = memory.readbyte(0x04F4) -- actually the checking for the victory song
			if timer_end == 0x04 then
				eligable_4f = false
				if get_time() >= 288 then
					Points[5] = true
				end
			end
		end
	end
end

enter_5f = false
function check_for_jesus_clip()
	level = memory.readword(0x7EB9, 0x7EBA)
	if level == 0xA857 then
		enter_5f = true
	else
		enter_5f = false
	end
	if enter_5f then
		xhi = memory.readbyte(0x75)
		if xhi == 1 then
			Points[8] = true
		end
	end
end

enter_77 = false
function check_for_w7_zclip()
	level = memory.readword(0x7EB9, 0x7EBA)
	if level == 0xAAA8 then
		enter_77 = true
	else
		enter_77 = false
	end
	if enter_77 then
		xhi = memory.readbyte(0x75)
		xlo = memory.readbyte(0x90)
		if xhi == 1 and xlo == 0x30 then
			Points[9] = true
		end
	end
end

enter_6f3 = false
function check_for_w6_zclip()
	level = memory.readword(0x7EB9, 0x7EBA)
	if level == 0xB032 then
		enter_6f3 = true
	else
		enter_6f3 = false
	end
	if enter_6f3 then
		xhi = memory.readbyte(0x75)
		xlo = memory.readbyte(0x90)
		if xhi == 9 and xlo == 0x00 then
			Points[10] = true
		end
	end
end

enter_69 = false
air_69_time_now = false
air_69_time_last = false
air_69_time = 0
function check_for_w6_wall_jump()
	level = memory.readword(0x7EB9, 0x7EBA)
	if level == 0xBCEE then
		enter_69 = true
	else
		enter_69 = false
	end
	if enter_69 then
		xhi = memory.readbyte(0x75)
		yhi = memory.readbyte(0x87)
		if yhi == 0x00 then
			air_69_time_now = true
		else
			air_69_time_now = false
		end
		if air_69_time_now and not air_69_time_last then
			air_69_time = air_69_time + 1
			print(air_69_time)
		end
		if air_69_time <= 2 and xhi == 0x02 then
			Points[11] = true
		end
		air_69_time_last = air_69_time_now
	end
end

last_xhi_76 = 0
eligable_76 = true
function check_for_76_clip()
	level = memory.readword(0x7EB9, 0x7EBA)
	if eligable_76 then
		if level == 0xB332 then
			xhi = memory.readbyte(0x75)
			xlo = memory.readbyte(0x90)
			if last_xhi_76 == 1 and xhi == 0 then
				eligable_76 = false
			end
			if xhi == 1 and xlo == 0x80 then
				Points[12] = true
			end
			last_xhi_76 = xhi
		end
	end
end

eligable_79 = true
attempts_79 = 0
dodge_79_dection = 0
last_79_position = 0
function check_for_79_clips()
	level = memory.readword(0x7EB9, 0x7EBA)
	if eligable_79 then
		if level == 0xB23F then
			if memory.readbyte(0x87) == 0 then
				dodge_79_dection = dodge_79_dection + 1
				if dodge_79_dection > 5 then
					eligable_79 = false
				end
			end
			pos = get_pos()
			if last_79_position ~= pos then
				if pos == 0x06F2 or pos == 0x07F2 then
					attempts_79 = attempts_79 + 1
					if attempts_79 > 1 then
						eligable_79 = false
					end
				end
				if pos == 0x0800 then
					Points[13] = true
				end
			end
			last_79_position = pos
		end
	end
end

title_last_state = 0
function check_for_start()
	title_state = memory.readbyte(0xDE)
	if title_state == 4 and title_state ~= title_last_state then
		return true
	else
		return false
	end
	title_last_state = timer_start
end

function update_points()
	check_death()
	check_first_flower()
	check_used_star()
	check_for_fast_w2_kill()
	check_for_fast_w4_fort()
	check_for_jesus_clip()
	check_for_w7_zclip()
	check_for_w6_zclip()
	check_for_w6_wall_jump()
	check_for_76_clip()
	check_for_79_clips()
end

function points()
	update_points()
	local points = 0
	for i=1,POINTS_LEN do
		if Points[i] == true then
			points = points + POINT_TRANS[i]
		end
	end
	points = points + (wand_grab * 1.5) + (deaths * -0.5) + (coin_ship * -0.5) + (fanfare * -0.5)
	return points
end

ctime = 0
function timer()
	ctime = ctime + 1
	return math.floor(ctime/3600), math.floor((ctime/60)+0.5) % 60
end

function reset()
	Points = {
	false, false, true, false, false, false,
	false, false, false, false, false, false,
	true, false, false, false, false, false, false, false, false, false,
	false, false, false, false
	}
	ctime = 0
end

begun = false
while true do
	if check_for_start() then
		begun = true
	end

	if begun then
		minutes, seconds = timer()
		gui.text(0, 10, "Points: "..points().. " Time: " ..minutes.. ":" ..string.format("%02d", seconds))
	else
		gui.text(0, 10, "Waiting for race to start")
	end

	emu.frameadvance()
end


	





















