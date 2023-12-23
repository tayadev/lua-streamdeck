local ffi = require 'ffi'
local Object = require 'classic'

ffi.cdef[[
  int hid_init(void);
  int hid_exit(void);

  struct hid_device_;
  typedef struct hid_device_ hid_device;

  struct hid_device_info {
    char *path;                    // Platform-specific device path
    unsigned short vendor_id;      // Device Vendor ID
    unsigned short product_id;     // Device Product ID
    wchar_t *serial_number;        // Serial Number
    unsigned short release_number; // Device Release Number in BCD, aka Device Version Number
    wchar_t *manufacturer_string;  // Manufacturer String
    wchar_t *product_string;       // Product string
    unsigned short usage_page;     // Usage Page for this Device/Interface (Windows/Mac only).
    unsigned short usage;          // Usage for this Device/Interface (Windows/Mac only).
    // The USB interface which this logical device represents.
    // Valid on both Linux implementations in all cases, and valid on the
    // Windows implementation if the device contains more than one interface.
    int interface_number;
    struct hid_device_info *next;  // Pointer to the next device
  };

  struct hid_device_info* hid_enumerate(unsigned short vendor_id, unsigned short product_id);
  void hid_free_enumeration(struct hid_device_info *devs);

  hid_device* hid_open(unsigned short vendor_id, unsigned short product_id, const wchar_t *serial_number);
  void hid_close(hid_device *device);
  hid_device* hid_open_path(const char *path);

  int hid_write(hid_device *device, const unsigned char *data, size_t length);
  int hid_read_timeout(hid_device *dev, unsigned char *data, size_t length, int milliseconds);
  int hid_read(hid_device *device, unsigned char *data, size_t length);
  int hid_set_nonblocking(hid_device *device, int nonblock);
  int hid_send_feature_report(hid_device *device, const unsigned char *data, size_t length);
  int hid_get_feature_report(hid_device *device, unsigned char *data, size_t length);

  int hid_get_manufacturer_string(hid_device *device, wchar_t *string, size_t maxlen);
  int hid_get_product_string(hid_device *device, wchar_t *string, size_t maxlen);
  int hid_get_serial_number_string(hid_device *device, wchar_t *string, size_t maxlen);
  int hid_get_indexed_string(hid_device *device, int string_index, wchar_t *string, size_t maxlen);
  const wchar_t* hid_error(hid_device *device);
]]

local C = ffi.load "hidapi"

local MAX_STR = 255

C.hid_init()

local HidDevice = Object:extend()

function HidDevice:new(handle)
  self.handle = handle
end

function HidDevice.open(vid, pid, serial)
  if serial ~= nil then
    serial = ffi.new("char[?]", #serial, serial)
  end
  local handle = C.hid_open(vid, pid, serial)
  if handle == nil then
    return nil
  end
  return HidDevice(handle)
end

function HidDevice:get_manufacturer()
  local wstr = ffi.new("wchar_t[?]", MAX_STR)
  C.hid_get_manufacturer_string(self.handle, wstr, MAX_STR)
  return ffi.string(wstr, ffi.sizeof(wstr))
end

function HidDevice:get_product()
  local wstr = ffi.new("wchar_t[?]", MAX_STR)
  C.hid_get_product_string(self.handle, wstr, MAX_STR)
  return ffi.string(wstr, ffi.sizeof(wstr))
end

function HidDevice:get_serial_number()
  local wstr = ffi.new("wchar_t[?]", MAX_STR)
  C.hid_get_serial_number_string(self.handle, wstr, MAX_STR)
  return ffi.string(wstr, ffi.sizeof(wstr))
end

function HidDevice:read(length)
  local data = ffi.new("uint8_t[?]", length)
  C.hid_read(self.handle, data, length)
  return data
end

--- @param payload table<number>
function HidDevice:write(payload)
  local data = ffi.new("unsigned char[?]", #payload, payload)
  C.hid_write(self.handle, data, #payload)
end

--- @param payload table<number>
function HidDevice:send_feature(payload)
  local data = ffi.new("unsigned char[?]", #payload, payload)
  C.hid_send_feature_report(self.handle, data, #payload)
end

--- @param id number
function HidDevice:get_feature(id)
  local data = ffi.new("unsigned char[32]", id)
  C.hid_get_feature_report(self.handle, data, 32)
  return ffi.string(data, ffi.sizeof(data))
end

function HidDevice:close()
  C.hid_close(self.handle)
end

function HidDevice:__gc()
  C.hid_exit()
end

return HidDevice