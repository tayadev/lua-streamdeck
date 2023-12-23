local StreamDeck = require "StreamDeck"
local HidDevice = require "HidDevice"

local StreamDeckPlus = StreamDeck:extend()

StreamDeckPlus.KEY_COUNT = 8
StreamDeckPlus.KEY_COLUMNS = 4
StreamDeckPlus.KEY_ROWS = 2
StreamDeckPlus.KEY_IMAGE_WIDTH = 120
StreamDeckPlus.KEY_IMAGE_HEIGHT = 120

StreamDeckPlus.DIAL_COUNT = 4

StreamDeckPlus.TOUCHSCREEN_IMAGE_WIDTH = 800
StreamDeckPlus.TOUCHSCREEN_IMAGE_HEIGHT = 100


function StreamDeckPlus:new(device)
  StreamDeckPlus.super:new(device)
end

function StreamDeckPlus.connect_first()
  local device = HidDevice.open(0xfd9, 0x0084, nil)
  if device == nil then
    return nil
  end
  return StreamDeckPlus(device)
end


function StreamDeckPlus:_get_state()
  local states = self.device:read(14)

  -- print data
  local ffi = require "ffi"
  for i = 0, ffi.sizeof(states) do
    io.write(string.format("%02x ", states[i]))
  end
  io.write("\n")

  -- ? type ? ? data

  if states[1] == 0x00 then
    -- key event
    local keys = {}
    for i = 1, 8 do
      keys[i] = states[i+3] == 1 and true or false
    end
    return keys
  elseif states[1] == 0x02 then
    -- touchscreen event
    local event_type = states[4] -- 1 = short press, 2 = long press, 3 = drag

    local value = {
      x = bit.lshift(states[7], 8) + states[6],
      y = bit.lshift(states[9], 8) + states[8]
    }

    if event_type == 3 then
      value.x_out = bit.lshift(states[11], 8) + states[10]
      value.y_out = bit.lshift(states[13], 8) + states[12]
    end

    return {event_type, value}

  elseif states[1] == 0x03 then
    -- dial event
    local event_type = states[4] == 0x01 and 1 or 2 -- 1 = turn, 2 = push
    local dials = {}
    for i = 1, self.DIAL_COUNT do
      if event_type == 1 then
        -- turn
        local value = states[i+4]
        if value < 0x80 then
          -- clockwise rotation
          dials[i] = value
        else
          -- counterclockwise rotation
          dials[i] = -(0x100 - value)
        end
      else
        -- push
        dials[i] = states[i+4] == 1 and true or false
      end
    end
    return {event_type, dials}
  end
end

function StreamDeckPlus:_reset_key_stream()
  error("Not implemented")
end

function StreamDeckPlus:set_key_image(key, image)
  error("Not implemented")
end

function StreamDeckPlus:set_touchscreen_image(image, x, y, width, height)
  error("Not implemented")
end

return StreamDeckPlus