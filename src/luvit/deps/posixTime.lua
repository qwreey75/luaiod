--[[lit-meta
  name = "luaiod/posixTime"
  version = "2.1.0"
  dependencies = {}
  license = "MIT"
  homepage = ""
  description = ""
  tags = {}
]]

local time = os.time;
local diff = time() - time(os.date("!*t"));

return {gmt = diff,now = function ()
	return time() - diff;
end};

