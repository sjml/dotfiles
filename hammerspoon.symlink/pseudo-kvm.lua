-- Inspired by https://github.com/haimgel/display-switch, which
--   sadly does not work on Apple Silicon at the moment. :(
--   Makes use of a compiled version of https://github.com/waydabber/m1ddc
--   installed via Homebrew.

local log = hs.logger.new("pseudo-kvm", "debug")

local DOCKING_STATION_VENDOR = 0x2188
local DOCKING_STATION_PRODUCT = 0x5500
local USB_SWITCH_VENDOR = 0x1a40
local USB_SWITCH_PRODUCT = 0x0101

local M1DDC_PATH = "/opt/homebrew/bin/m1ddc"
local MAC_INPUT_ID = "15"
local WIN_INPUT_ID = "17"


-- look for the the docking station for my Mac
local function isDocked()
  for _, data in pairs(hs.usb.attachedDevices()) do
    if data["vendorID"] == DOCKING_STATION_VENDOR and data["productID"] == DOCKING_STATION_PRODUCT then
      return true
    end
  end
  return false
end

local function usbWatcherCallback(data)
  if not isDocked() then
    return
  end
  if data["vendorID"] == USB_SWITCH_VENDOR and data["productID"] == USB_SWITCH_PRODUCT then
    if data["eventType"] == "added" then
      -- switch showed up on this machine; move to our input
      local output, status, _type, rc = hs.execute(M1DDC_PATH .. " set input " .. MAC_INPUT_ID)
    elseif data["eventType"] == "removed" then
      -- switch was removed from this machine; move to other input
      local output, status, _type, rc = hs.execute(M1DDC_PATH .. " set input " .. WIN_INPUT_ID)
    end
  end
end

local usbWatcher = hs.usb.watcher.new(usbWatcherCallback)
usbWatcher:start()


-- macOS >= High Sierra gets finicky waking from sleep with USB watching active,
--   for some reason. Shut off watching when we're about to sleep and
--   turn it back on when we wake up.
local function toggleWatcher(eventType)
  if (eventType == hs.caffeinate.watcher.systemDidWake) then
      usbWatcher:start()
  elseif (eventType == hs.caffeinate.watcher.systemWillSleep) then
      usbWatcher:stop()
  end
end

local caffeinateWatcher = hs.caffeinate.watcher.new(toggleWatcher)
caffeinateWatcher:start()
