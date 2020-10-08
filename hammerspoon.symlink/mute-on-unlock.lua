function muteOnUnlock(eventType)
  if (eventType == hs.caffeinate.watcher.screensDidUnlock) then
    local output = hs.audiodevice.defaultOutputDevice()
    output:setMuted(true)
    hs.alert.show("Audio Muted 🔇")
  end
end
caffeinateWatcher = hs.caffeinate.watcher.new(muteOnUnlock)

caffeinateWatcher:start()
