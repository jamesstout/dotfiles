hs.hotkey.bind({"cmd", "alt"}, "V", function() hs.pasteboard.setContents("M99**g1ggle")  hs.eventtap.keyStrokes(hs.pasteboard.getContents()) end)

-- hs.loadSpoon("EjectMenu")
-- 
-- spoon.EjectMenu.notify = true
-- spoon.EjectMenu.eject_on_sleep = false
-- -- spoon.EjectMenu.never_eject = { "/Volumes/Archive"}
-- spoon.EjectMenu:start()
--spoon.EjectMenu:bindHotkeys({ ejectAll = {{"ctrl","cmd", "alt"}, "e"}})

hs.loadSpoon("TimeMachineProgress")

spoon.TimeMachineProgress:start()
