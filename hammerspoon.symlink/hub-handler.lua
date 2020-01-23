-- Adds an icon to the menubar when a USB hub is plugged in.
--  In my case, the hub also provides ethernet, so switch off
--  WiFi when it's in and turn it back on when it's out.

-- NOTE: this is configured to look for a very specific device
--       attachment; if you are not me, you'll have to change
--       the values.
local USB_VENDOR = 1293
local USB_PRODUCT = 1850
local ETHERNET_VENDOR = 3034
local ETHERNET_PRODUCT = 33107


log = hs.logger.new("menuEject", "debug")

ejection = nil


function checkIDs(vendorID, productID, data)
    if data["vendorID"] == vendorID and data["productID"] == productID then
        return true
    end
    return false
end

function checkStrings(vendorString, productString, data)
    if data["vendorName"] == vendorString and data["productName"] == productString then
        return true
    end
    return false
end


function ejectionClicked()
    local vols = hs.fs.volume.allVolumes(true)
    for mountPath, volInfo in pairs(vols) do
        if volInfo["NSURLVolumeIsInternalKey"] == false then
            hs.execute("diskutil umount '" .. mountPath .. "'")
            -- log.i(mountPath)
        end
    end

    local allGone = true
    vols = hs.fs.volume.allVolumes(true)
    for mountPath, volInfo in pairs(vols) do
        if volInfo["NSURLVolumeIsInternalKey"] == false then
            allGone = false
        end
    end

    if allGone == true then
        ejection:removeFromMenuBar()
        ejection:delete()
        ejection = nil
    end
end

function manualCheck()
  local devices = hs.usb.attachedDevices()
  local foundHub = false
  for _, data in pairs(devices) do
      if checkIDs(USB_VENDOR, USB_PRODUCT, data) then
          foundHub = true
      end
  end
  if not foundHub then
      ejection:removeFromMenuBar()
      ejection:delete()
      ejection = nil
    else
      ejection = makeEjection()
  end
end

function makeEjection()
  if ejection ~= nil then
    return ejection
  end
  local ej = hs.menubar.new()
  ej:setTitle("⏏")
  ej:setClickCallback(ejectionClicked)
  return ej
end

-- check to see if the USB hub is already attached here at startup
manualCheck()






function usbWatcherCallback(data)
    -- look for USB 3.0 hub
    if checkIDs(USB_VENDOR, USB_PRODUCT, data) then
        if data["eventType"] == "added" then
            ejection = makeEjection()
        end
    end

    -- more trouble than it's worth for now; just let the network priorities play it out
    -- -- look for Ethernet adapter
    -- if checkIDs(ETHERNET_VENDOR, ETHERNET_PRODUCT, data) then
    --     if data["eventType"] == "added" then
    --         hs.execute("/usr/sbin/networksetup -setairportpower en0 off")
    --     else
    --         hs.execute("/usr/sbin/networksetup -setairportpower en0 on")
    --     end
    -- end
end

usbWatcher = hs.usb.watcher.new(usbWatcherCallback)
usbWatcher:start()


-- High Sierra gets finicky waking from sleep with USB watching active,
--   for some reason. Shut off watching when we're about to sleep and
--   turn it back on when we wake up.
function toggleWatcher(eventType)
    if (eventType == hs.caffeinate.watcher.systemDidWake) then
        -- hs.execute("/usr/sbin/networksetup -setairportpower en0 on")
        manualCheck(ejection)
        usbWatcher:start()
    elseif (eventType == hs.caffeinate.watcher.systemWillSleep) then
        -- hs.execute("/usr/sbin/networksetup -setairportpower en0 off")
        usbWatcher:stop()
    end
end

caffeinateWatcher = hs.caffeinate.watcher.new(toggleWatcher)
caffeinateWatcher:start()

