do
	local function top_color_blue(value, default_color, upper_thresh, lower_thresh)
		local r, g, b = default_color, default_color, default_color
		local color = 0
		local thresh_diff = upper_thresh - lower_thresh
		if (value - lower_thresh) > 0 then
			if value > upper_thresh then value = upper_thresh end
			-- add some redness, depending on the 'strength'
			b = math.ceil(default_color + ((value - lower_thresh) / thresh_diff) * (0xff - default_color))
			r = math.floor(default_color - ((value - lower_thresh) / thresh_diff) * default_color)
			g = r
		end
    color = (r * 0x10000) + (g * 0x100) + b
		-- return string.format("^fg(#%06x)%4.1f^fg()", color%0xffffff, value)
		return string.format("^fg(#%06x)", color%0xffffff)
	end
	local function top_color_red(value, default_color, upper_thresh, lower_thresh)
		local r, g, b = default_color, default_color, default_color
		local color = 0
		local thresh_diff = upper_thresh - lower_thresh
		if (value - lower_thresh) > 0 then
			if value > upper_thresh then value = upper_thresh end
			-- add some redness, depending on the 'strength'
			r = math.ceil(default_color + ((value - lower_thresh) / thresh_diff) * (0xff - default_color))
			b = math.floor(default_color - ((value - lower_thresh) / thresh_diff) * default_color)
			g = b
		end
    color = (r * 0x10000) + (g * 0x100) + b
		-- return string.format("^fg(#%06x)%4.1f^fg()", color%0xffffff, value)
		return string.format("^fg(#%06x)", color%0xffffff)
	end

	function conky_top_cpu_color(c_name, c_pid, c_cpu, c_mem)
	  local cpu = tonumber(conky_parse(c_cpu))
    local mem = tonumber(conky_parse(c_mem))
    local pid = tonumber(conky_parse(c_pid))
	  local name = conky_parse(c_name)
	  local conky_color = top_color_red(cpu, 0x90, 15, 5)
	  return string.format("%s%s %5.0f    %4.1f     %4.1f^fg()", conky_color, name, pid, cpu, mem)
	end
  function conky_format( format, number )
      return string.format( format, conky_parse( number ) )
  end

	function conky_top_mem_color(c_name, c_pid, c_cpu, c_mem)
	  local cpu = tonumber(conky_parse(c_cpu))
    local mem = tonumber(conky_parse(c_mem))
    local pid = tonumber(conky_parse(c_pid))
	  local name = conky_parse(c_name)
	  local conky_color = top_color_blue(cpu, 0xd3, 4, 1)
	  return string.format("%s%s %5.0f %4.1f %4.1f^fg()", conky_color, name, pid, mem, cpu)
	end
end
