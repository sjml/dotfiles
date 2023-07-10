-- For reasons I can't figure out, the monitor will sometimes "display"
--   a black screen when the system is asleep, which turns on its backlight
--   and illuminates my room.
-- Might be related to the docking station; might be something with the OS;
--   might be something with the display. No time or inclination to really
--   track it down, though.
-- Setting the display to standby seems to fix that issue.
--   Makes use of https://github.com/waydabber/m1ddc installed via Homebrew.

monitor_standby = {}

local util = require("util")
monitor_standby.log = hs.logger.new("monitor-standby", "debug")

local M1DDC_PATH = "/opt/homebrew/bin/m1ddc"
-- https://github.com/waydabber/BetterDisplay/issues/1372#issuecomment-1397704563
-- (these values are incremented by one for use in commands)
-- 0     DPMSModeOn          In use
-- 1     DPMSModeStandby     Blanked, low power
-- 2     DPMSModeSuspend     Blanked, lower power
-- 3     DPMSModeOff         Shut off, awaiting activity
local OFF_VALUE = "5" -- note this powers the monitor all the way off
                      --   and thus it won't respond to wake commands anymore
local STANDBY_VALUE = "4"
local WAKE_VALUE = "1"



local function toggleWatcher(eventType)
  -- monitor_standby.log.i("monitor-standby watcher event")
  if not util.isDocked() then
    return
  end

  -- monitor_standby.log.i("monitor-standby not docked")
  if (eventType == hs.caffeinate.watcher.systemDidWake) then
    -- monitor_standby.log.i("setting standby: WAKE")
    local output, status, _type, rc = hs.execute(M1DDC_PATH .. " set standby " .. WAKE_VALUE)
  elseif (eventType == hs.caffeinate.watcher.systemWillSleep) then
    -- monitor_standby.log.i("setting standby: SLEEP")
    local output, status, _type, rc = hs.execute(M1DDC_PATH .. " set standby " .. STANDBY_VALUE)
  end
end

monitor_standby.caffeinateWatcher = hs.caffeinate.watcher.new(toggleWatcher)
monitor_standby.caffeinateWatcher:start()
