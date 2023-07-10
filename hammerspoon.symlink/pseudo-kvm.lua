-- Inspired by https://github.com/haimgel/display-switch, which
--   sadly does not work on Apple Silicon at the moment. :(
--   Makes use of https://github.com/waydabber/m1ddc installed via Homebrew.

pseudo_kvm = {}
local util = require("util")
pseudo_kvm.log = hs.logger.new("pseudo-kvm", "debug")

local USB_SWITCH_VENDOR = 0x1a40
local USB_SWITCH_PRODUCT = 0x0101

local M1DDC_PATH = "/opt/homebrew/bin/m1ddc"
local MAC_INPUT_ID = "15"
local WIN_INPUT_ID = "17"


local function usbWatcherCallback(data)
  -- pseudo_kvm.log.i("pseudo-kvm watcher event")
  if not util.isDocked() then
    return
  end
  -- pseudo_kvm.log.i("pseudo-kvm not docked")
  if data["vendorID"] == USB_SWITCH_VENDOR and data["productID"] == USB_SWITCH_PRODUCT then
    if data["eventType"] == "added" then
      -- switch showed up on this machine; move to our input
      -- pseudo_kvm.log.i("pseudo-kvm switch added")
      local output, status, _type, rc = hs.execute(M1DDC_PATH .. " set input " .. MAC_INPUT_ID)
    elseif data["eventType"] == "removed" then
      -- switch was removed from this machine; move to other input
      -- pseudo_kvm.log.i("pseudo-kvm switch removed")
      local output, status, _type, rc = hs.execute(M1DDC_PATH .. " set input " .. WIN_INPUT_ID)
    end
  end
end

pseudo_kvm.usbWatcher = hs.usb.watcher.new(usbWatcherCallback)
pseudo_kvm.usbWatcher:start()


-- macOS >= High Sierra gets finicky waking from sleep with USB watching active,
--   for some reason. Shut off watching when we're about to sleep and
--   turn it back on when we wake up.
local function toggleWatcher(eventType)
  if (eventType == hs.caffeinate.watcher.systemDidWake) then
      -- pseudo_kvm.log.i("pseudo-kvm wake event turning OFF usb watcher")
      pseudo_kvm.usbWatcher:start()
    elseif (eventType == hs.caffeinate.watcher.systemWillSleep) then
      -- pseudo_kvm.log.i("pseudo-kvm wake event turning ON usb watcher")
      pseudo_kvm.usbWatcher:stop()
  end
end

pseudo_kvm.caffeinateWatcher = hs.caffeinate.watcher.new(toggleWatcher)
pseudo_kvm.caffeinateWatcher:start()
