mash = {"⌘", "⌥", "⌃"}

require "apps"
require "grid"

-- hs.hotkey.bind({"cmd", "alt"}, "V", function() hs.pasteboard.setContents("M99**g1ggle")  hs.eventtap.keyStrokes(hs.pasteboard.getContents()) end)

hs.hotkey.bind(mash, "r", function() hs.reload(); end)
hs.hotkey.bind(mash, "w", function() hs.eventtap.keyStrokes('¯\\_(ツ)_/¯'); end)
hs.hotkey.bind(mash, "a", function() hs.caffeinate.lockScreen(); end)
hs.hotkey.bind(mash, "v", function() hs.eventtap.keyStrokes('M99**g1ggle'); end)

hs.alert("Hammerspoon config loaded")

-- hs.loadSpoon("EjectMenu")
-- 
-- spoon.EjectMenu.notify = true
-- spoon.EjectMenu.eject_on_sleep = false
-- -- spoon.EjectMenu.never_eject = { "/Volumes/Archive"}
-- spoon.EjectMenu:start()
--spoon.EjectMenu:bindHotkeys({ ejectAll = {{"ctrl","cmd", "alt"}, "e"}})

-- hs.loadSpoon("TimeMachineProgress")

-- spoon.TimeMachineProgress:start()
