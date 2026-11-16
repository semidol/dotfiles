// Floating ChatGPT browser window for Hammerspoon 2.
// Cmd+Alt+Ctrl+I toggles a web view pinned to the left third of the screen,
// with back/forward/reload buttons and a URL bar in its toolbar.

const START_URL = "https://chatgpt.com/";
const WIDTH_DIVISOR = 3;

let browser = null; // { win, webview, rectKey }
let visible = false;
let appBeforeOpen = null;

function currentScreen() {
	return hs.screen.main() || hs.screen.primary();
}

function targetRect(screen) {
	const frame = screen.frame;

	return new HSRect(
		frame.x,
		frame.y,
		Math.floor(frame.w / WIDTH_DIVISOR),
		frame.h
	);
}

function rectKey(rect) {
	return [rect.x, rect.y, rect.w, rect.h].join(",");
}

function buildBrowser(rect) {
	const webview = hs.ui
		.webview()
		.toolbar(["back", "forward", "reload", "url"])
		.loadURL(START_URL);

	const win = hs.ui
		.window({ x: rect.x, y: rect.y, w: rect.w, h: rect.h })
		.windowTitle("ChatGPT")
		.titled(true)
		.miniaturizable(false)
		.level("floating")
		.webview(webview)
		.onShow(() => {
			visible = true;
		})
		.onHide(() => {
			// Also fires when the window's close button is clicked.
			visible = false;
			if (appBeforeOpen && appBeforeOpen.isRunning) {
				appBeforeOpen.activate();
			}
		});

	return { win, webview, rectKey: rectKey(rect) };
}

function toggleBrowser() {
	const screen = currentScreen();

	if (!screen) {
		hs.ui.alert("ChatGPT window: no screen available").duration(3).show();
		return;
	}

	if (typeof hs.ui.webview !== "function") {
		hs.ui
			.alert("ChatGPT window needs macOS 26 or later")
			.duration(3)
			.show();
		return;
	}

	const rect = targetRect(screen);

	if (browser && browser.rectKey !== rectKey(rect)) {
		// A shown window cannot be moved or resized, so start over when the
		// screen layout changed since it was created.
		visible = false;
		browser.win.destroy();
		browser = null;
	}

	if (!browser) {
		try {
			browser = buildBrowser(rect);
		} catch (err) {
			console.error("ChatGPT window: " + err.message);
			hs.ui
				.alert("ChatGPT window failed: " + err.message)
				.duration(3)
				.show();
			return;
		}
	}

	if (visible) {
		browser.win.hide();
		visible = false;
		return;
	}

	const front = hs.application.frontmost();
	if (front && front.bundleID !== hs.appinfo.bundleIdentifier) {
		appBeforeOpen = front;
	}

	browser.win.show();
	visible = true;
}

hs.hotkey.bind(["cmd", "alt", "ctrl"], "i", toggleBrowser, null, null);
