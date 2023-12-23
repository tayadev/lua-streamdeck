local HidDevice = require "HidDevice"
local Object = require "classic"

local StreamDeck = Object:extend()

function StreamDeck:new(device)
  self.device = device
end

function StreamDeck.connect(vid, pid, serial)
  local device = HidDevice.open(vid, pid, serial)
  if device == nil then
    return nil
  end
  return StreamDeck(device)
end

function StreamDeck:reset()
  self.device:send_feature({0x03, 0x02})
end

function StreamDeck:get_firmware_version()
  return string.sub(self.device:get_feature(0x05), 7)
end

function StreamDeck:get_serial_number()
  return string.sub(self.device:get_feature(0x06), 3)
end

function StreamDeck:set_brightness(percent)
  -- percent is between 0 and 100
  self.device:send_feature({0x03, 0x08, percent})
end

return StreamDeck