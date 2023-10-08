-- work-in-progress
  -- seems like Time Machine stuff is hard, even using command line
  --   drive lists as "synthesized" in `diskutil list` and doesn't show up
  --   if I have it mount the physical disk :-/
  --
  -- explore: https://talk.macpowerusers.com/t/any-way-to-automate-a-time-machine-backup-mount-backup-unmount/16758/9
  --    (archives: https://archive.ph/zLY0r, https://web.archive.org/web/20210512170352/https://talk.macpowerusers.com/t/any-way-to-automate-a-time-machine-backup-mount-backup-unmount/16758/10
  --    post partway down the page)

-- Handles hard drives when I'm docked.
--   1. Adds an icon to the menubar to make ejecting them easy.
--   2. Ejects them when I sleep and re-mounts them when I wake.
-- Ejectify app *should* handle these things, but seems to have trouble
--   remounting encrypted drives (like my Time Machine backup) so trying a littly DIY.

drive_handler = {}
local util = require("util")
drive_handler.log = hs.logger.new("drive-handler", "debug")

drive_handler.ejection = nil

local function ejectionClicked()
  -- drive_handler.log.i("ejection clicked!")
  drive_handler.ejection:setTitle("👀")

  -- without the delay, the title never gets set
  hs.timer.doAfter(0.05, function()
    local vols = hs.fs.volume.allVolumes(true)
    for mountPath, volInfo in pairs(vols) do
      if volInfo["NSURLVolumeIsInternalKey"] == false then
        hs.execute("diskutil umount '" .. mountPath .. "'")
        drive_handler.log.i("unmounting " .. mountPath)
      end
    end

    local allGone = true
    vols = hs.fs.volume.allVolumes(true)
    for _, volInfo in pairs(vols) do
      if volInfo["NSURLVolumeIsInternalKey"] == false then
        allGone = false
      end
    end

    if allGone then
      destroyEjection()
    else
      drive_handler.ejection:setTitle("⏏")
    end
  end)
end

local function destroyEjection()
  drive_handler.ejection:removeFromMenuBar()
  drive_handler.ejection:delete()
  drive_handler.ejection = nil
end

local function makeEjection()
  if drive_handler.ejection ~= nil then
    return drive_handler.ejection
  end
  local ej = hs.menubar.new()
  ej:setTitle("⏏")
  ej:setClickCallback(ejectionClicked)
  return ej
end

local function manualCheck()
  if not util.isDocked() then
    if drive_handler.ejection ~= nil then
      destroyEjection()
    end
  else
    -- drive_handler.log.i("making ejection")
    drive_handler.ejection = makeEjection()
  end
end

-- check to see if the USB hub is already attached here at startup
manualCheck()

-- local tmpVols = hs.fs.volume.allVolumes(true)
-- for mountPath, volInfo in pairs(tmpVols) do
--   drive_handler.log.i("mp: " .. mountPath)
-- end
