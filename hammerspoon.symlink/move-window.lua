-- for those times the laptop is hooked to
--   an external monitor that is set to a
--   different input but I wish to summon the
--   browser or similar

function cycleDisplaysForWindow()
  local displays = hs.screen.allScreens()
  if #displays == 1 then
    return
  end
  table.insert(displays, displays[1])
  local win = hs.window.focusedWindow()
  local currentScreen = win:screen()
  local newScreen = nil
  local useNext = false
  for i,v in ipairs(displays) do
    if useNext then
      newScreen = v
      break
    end
    if v == currentScreen then
      useNext = true
    end
  end
  if newScreen then
    win:moveToScreen(newScreen, false, true, 0)
  end
end

hs.hotkey.bind(hyper, "tab", cycleDisplaysForWindow)
