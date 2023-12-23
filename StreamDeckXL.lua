local StreamDeck = require "StreamDeck"
local HidDevice = require "HidDevice"
local bit = require "bit"

local StreamDeckXL = StreamDeck:extend()

StreamDeckXL.KEY_COUNT = 32
StreamDeckXL.KEY_COLUMNS = 8
StreamDeckXL.KEY_ROWS = 4
StreamDeckXL.KEY_IMAGE_WIDTH = 96
StreamDeckXL.KEY_IMAGE_HEIGHT = 96

function StreamDeckXL:new(device)
  StreamDeckXL.super:new(device)
end

function StreamDeckXL.connect_first()
  local device = HidDevice.open(0xfd9, 0x006c, nil)
  if device == nil then
    return nil
  end
  return StreamDeckXL(device)
end

function StreamDeckXL:_get_state()
  local response = self.device:read(4 + self.KEY_COUNT)
  local keys = {}
  for i = 0, self.KEY_COUNT do
    keys[i] = response[3 + i] == 1 and true or false
  end
  return keys
end


local IMAGE_REPORT_LENGTH = 1024
local IMAGE_REPORT_HEADER_LENGTH = 8
local IMAGE_REPORT_PAYLOAD_LENGTH = IMAGE_REPORT_LENGTH - IMAGE_REPORT_HEADER_LENGTH

function StreamDeckXL:_reset_key_stream()
  local payload = {0x02}
  for i = 1, IMAGE_REPORT_LENGTH do
    table.insert(payload, 0)
  end

  self.device:write(payload)
end

function StreamDeckXL:set_key_image(key, image)
  local page_number = 0
  local bytes_remaining = #image

  while bytes_remaining > 0 do
    local this_length = math.min(bytes_remaining, IMAGE_REPORT_PAYLOAD_LENGTH)
    local bytes_sent = page_number * IMAGE_REPORT_PAYLOAD_LENGTH

    local payload = {
      0x02,
      0x07,
      key,
      this_length == bytes_remaining and 1 or 0,
      bit.band(this_length, 0xFF),
      bit.rshift(this_length, 8),
      bit.band(page_number, 0xFF),
      bit.rshift(page_number, 8)
    }

    for i = 1, this_length do
      table.insert(payload, string.byte(image, bytes_sent + i))
    end

    for i = 1, IMAGE_REPORT_LENGTH - this_length - IMAGE_REPORT_HEADER_LENGTH do
      table.insert(payload, 0)
    end

    self.device:write(payload)

    bytes_remaining = bytes_remaining - this_length
    page_number = page_number + 1
  end
end

return StreamDeckXL