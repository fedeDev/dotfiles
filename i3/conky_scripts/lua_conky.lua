function conky_format( format, number )
    return string.format( format, conky_parse( number ) )
end
function conky_netspeed( speedstr )
  local speed = tonumber(conky_parse( speedstr ))
  if speed <= 9.9 then
    return string.format("%1.1fK", speed)
  else
    if speed > 999 then
      return string.format("%1.1fM", speed/1000)
    else
      return string.format("%3.0fK", speed)
    end
  end
end
