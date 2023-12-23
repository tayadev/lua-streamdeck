local StreamDeckXL = require "StreamDeckXL"
local StreamDeckPlus = require "StreamDeckPlus"
local StreamDeck     = require "StreamDeck"

local pretty = require "pprint"

local SDXL = StreamDeckXL.connect_first()
assert(SDXL ~= nil, "Could not connect to StreamDeck XL")

-- local SDP = StreamDeckPlus.connect_first()
-- assert(SDP ~= nil, "Could not connect to StreamDeck Plus")

print("SDXL FW Version: " .. SDXL:get_firmware_version())
-- print("SDP FW Version: " .. SDP:get_firmware_version())

local blackImage = assert(io.open("black.jpeg", "rb"):read("*a"), "Could not open image file")
local image = assert(io.open("placeholder96.jpeg", "rb"):read("*a"), "Could not open image file")

-- blank all keys
for i = 0, 31 do
  SDXL:set_key_image(i, blackImage)
end

local ffi = require "ffi"
ffi.cdef "void Sleep(int ms);"
function sleep(ms)
  ffi.C.Sleep(ms)
end

-- sweep check image across keys
for i = 0, 31 do
  SDXL:set_key_image(i-1, blackImage)
  SDXL:set_key_image(i, image)
  sleep(100)
end
SDXL:set_key_image(31, blackImage)


-- local clickmap = SDXL:_get_state()
-- print("clickmap:", clickmap)

-- local indexOfPressedKey = 0
-- for index, value in ipairs(clickmap) do
--   if value then
--     indexOfPressedKey = index
--     break
--   end
-- end

-- SDXL:set_key_image(indexOfPressedKey-1, image)

-- local SDP = StreamDeckPlus.connect_first()

-- assert(SDP ~= nil, "Could not connect to StreamDeck Plus")

-- print("FW Version: " .. SDP:get_firmware_version())

-- SDP:reset()
-- SDP:set_brightness(100)

-- local state = SDP:_get_state()
-- pretty(state)