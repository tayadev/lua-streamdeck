# Lua Streamdeck

A lua library for directly interfacing with the Elgato Streamdeck via HID

# TODO
- better selection/creation of device
- fix sumneko or me being confused about classes
- flip images
- SD+
- close hid device properly on garbage collection
- then make actual usable interface over the pure hw commands

# Credits
- [hidapi](https://github.com/libusb/hidapi)

# Notes
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