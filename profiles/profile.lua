local launch = require "plugins/launch"

main = {
  {
    title = "VS Code",
    image = "icons/vscode.png",
    command = function() launch("code") end,
  },
  {
    title = "OBS",
    image = "icons/obs.png",
    command = function()
      if not isOpen('obs') then launch("obs") end
      loadProfile("obs")
    end,
  }
}

-- Path: profiles/obs.lua
local obs = require "plugins/obs"
local profile = require "plugins/profile"

local obsProfile = {
  {
    title = "Home",
    image = "icons/home.png",
    command = function() profile:set('home') end,
  },
  {
    title = "Webcam",
    image = "icons/webcam.png",
    command = function() obs:setScene("just webcam") end,
  },
  {
    title = "Desktop",
    image = "icons/desktop.png",
    command = function() obs:setScene("desktop") end,
  },
  {
    title = "Be Right Back",
    image = "icons/brb.png",
    command = function() obs:setScene("brb") end,
  },
  {
    title = "Camera Transparency",
    command = function() obs:toggleFilter("Camera BG Removal") end,
    image = function ()
      if obs:isFilterEnabled("Camera BG Removal") then
        return "icons/transparent.png"
      else
        return "icons/opaque.png"
      end
    end
  }
}