// Floating ChatGPT browser window for Hammerspoon 2.
// Cmd+Alt+Ctrl+I opens and closes it.

const START_URL = "https://chatgpt.com/";

// AeroSpace remembers the workspace of a hidden window and restores it, pulling
// the visible workspace along. Every layout command clears that memory, and
// moving the focused window to the focused workspace does nothing else, so this
// makes the pane open in the current workspace.
const FORGET_HIDDEN_WINDOWS =
	'export PATH="/opt/homebrew/bin:/usr/local/bin:$PATH"; ' +
	'aerospace move-node-to-workspace "$(aerospace list-workspaces --focused)"';

let win = null;
let visible = false;
let windowBeforeOpen = null;

function toggleChatGPT() {
	if (!win) {
		const frame = hs.screen.main().frame;

		const webview = hs.ui
			.webview()
			.toolbar(["back", "forward", "reload", "url"])
			.loadURL(START_URL);

		win = hs.ui
			.window({
				x: frame.x,
				y: frame.y,
				w: Math.floor(frame.w / 3),
				h: frame.h,
			})
			.windowTitle("ChatGPT")
			.level("floating")
			.webview(webview)
			.onHide(() => {
				visible = false;

				const saved = windowBeforeOpen;
				windowBeforeOpen = null;
				if (saved) saved.focus();
			});
	}

	if (visible) {
		win.hide();
		return;
	}

	windowBeforeOpen = hs.window.focusedWindow();

	hs.task.shell(FORGET_HIDDEN_WINDOWS).then(() => {
		win.show();
		visible = true;
		// show() only orders the window in front; the accessory app has to be
		// activated for the window to take keyboard focus.
		hs.application.fromPID(hs.appinfo.pid)?.activate();
	});
}

hs.hotkey.bind(["cmd", "alt", "ctrl"], "i", toggleChatGPT, null, null);
