local USB_VID_ELGATO = 0x0fd9

local USB_PID_STREAMDECK_ORIGINAL = 0x0060
local USB_PID_STREAMDECK_ORIGINAL_V2 = 0x006d
local USB_PID_STREAMDECK_MINI = 0x0063
local USB_PID_STREAMDECK_XL = 0x006c
local USB_PID_STREAMDECK_XL_V2 = 0x008f
local USB_PID_STREAMDECK_MK2 = 0x0080
local USB_PID_STREAMDECK_PEDAL = 0x0086
local USB_PID_STREAMDECK_MINI_MK2 = 0x0090
local USB_PID_STREAMDECK_PLUS = 0x0084

local StreamDeckXL = require "StreamDeckXL"

local SDXL = StreamDeckXL.connect_first()

print("FW Version: " .. SDXL:get_firmware_version())

SDXL:reset()
SDXL:set_brightness(100)

local imageFile = assert(io.open("check.jpeg", "rb"), "Could not open image file")
local image = imageFile:read("*a")
imageFile:close()

local clickmap = SDXL:_get_state()
print("clickmap:", clickmap)

local indexOfPressedKey = 0
for index, value in ipairs(clickmap) do
  if value then
    indexOfPressedKey = index
    break
  end
end

SDXL:set_key_image(indexOfPressedKey-1, image)