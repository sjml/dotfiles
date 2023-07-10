local DOCKING_STATION_VENDOR = 0x2188
local DOCKING_STATION_PRODUCT = 0x5500

return {
  isDocked = function()
    for _, data in pairs(hs.usb.attachedDevices()) do
      if data["vendorID"] == DOCKING_STATION_VENDOR and data["productID"] == DOCKING_STATION_PRODUCT then
        return true
      end
    end
    return false
  end
}
