local chatGPT
local applicationBeforeChatGPT

local function chatGPTFrame()
	local screen = hs.screen.mainScreen():frame()

	return hs.geometry.rect(screen.x, screen.y, math.floor(screen.w / 3), screen.h)
end

local function showChatGPT()
	applicationBeforeChatGPT = hs.application.frontmostApplication()
	local frame = chatGPTFrame()

	if not chatGPT then
		chatGPT = hs.webview.new(frame, { privateBrowsing = false })
		chatGPT
			:windowStyle({ "titled", "fullSizeContentView", "utility" })
			:titleVisibility("hidden")
			:shadow(true)
			:allowTextEntry(true)
			:level(hs.drawing.windowLevels.floating)
			:url("https://chatgpt.com/")
	else
		chatGPT:frame(frame)
	end

	chatGPT:show()
end

local function toggleChatGPT()
	if chatGPT and chatGPT:isVisible() then
		chatGPT:hide()
		if applicationBeforeChatGPT and applicationBeforeChatGPT:isRunning() then
			applicationBeforeChatGPT:activate()
		end
	else
		showChatGPT()
	end
end

hs.hotkey.bind({ "cmd", "alt", "ctrl" }, "i", toggleChatGPT)
