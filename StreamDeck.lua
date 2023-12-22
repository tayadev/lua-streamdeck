local HidDevice = require "HidDevice"

--- @class StreamDeck
--- @field KEY_COUNT number
--- @field KEY_COLUMNS number
--- @field KEY_ROWS number
--- @field KEY_IMAGE_WIDTH number
--- @field KEY_IMAGE_HEIGHT number
--- @protected device HidDevice
local StreamDeck = {}

function StreamDeck:new(device)
  local o = {}
  setmetatable(o, self)
  self.__index = self
  o.device = device
  return o
end

--- @param vid number VendorId
--- @param pid number ProductId
--- @param serial? string SerialNumber
--- @return StreamDeck?
function StreamDeck.connect(vid, pid, serial)
  local device = HidDevice.open(vid, pid, serial)
  if device == nil then
    return nil
  end
  return StreamDeck:new(device)
end

function StreamDeck:reset()
  self.device:send_feature({0x03, 0x02})
end

---@return string
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