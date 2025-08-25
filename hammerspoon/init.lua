local ENGLISH = "com.apple.keylayout.ABC"
local VIETNAMESE = "com.apple.inputmethod.VietnameseIM.VietnameseVNI"

local inputSources = {
    ["com.google.Chrome"] = VIETNAMESE,
    ["com.jetbrains.intellij"] = ENGLISH,
    ["com.jetbrains.WebStorm"] = ENGLISH,
    ["com.googlecode.iterm2"] = ENGLISH,
    ["com.microsoft.VSCode"] = ENGLISH,
    ["com.jetbrains.datagrip"] = ENGLISH,
    ["com.jetbrains.fleet"] = ENGLISH
}

hs.application.watcher.new(function(appName, event, app)
    if event == hs.application.watcher.activated then
        local bundleID = app:bundleID()
        if bundleID then
            local targetInputSource = inputSources[bundleID]
            local currentInputSource = hs.keycodes.currentSourceID()
            if targetInputSource and currentInputSource ~= targetInputSource then
                print("Current input source is " .. (currentInputSource or "none") .. ". Switching to " .. targetInputSource)
                hs.keycodes.currentSourceID(targetInputSource)
            else
                print("Current bundleID " .. bundleID)
                print("No input source change needed for " .. appName)
            end
        end
    end
end):start()
