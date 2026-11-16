// Floating ChatGPT browser window for Hammerspoon 2.
// Cmd+Alt+Ctrl+I opens and closes it.

const START_URL = "https://chatgpt.com/";
const PANE_TITLE = "ChatGPT";

// AeroSpace hides windows of inactive workspaces in a screen corner and brings
// them back when they belong to the visible workspace, so every open/close goes
// through it: it is what puts the pane in front of the current workspace.
const AEROSPACE =
	'export PATH="/opt/homebrew/bin:/usr/local/bin:$PATH"; aerospace ';

let win = null;
let visible = false;
let windowBeforeOpen = null;

function aerospace(args) {
	return hs.task.shell(AEROSPACE + args).then(
		(result) => result.stdout.trim(),
		(result) => {
			console.error("aerospace " + args + ": " + result.stderr.trim());
			return "";
		}
	);
}

// { id, workspace } of the pane as AeroSpace sees it, or null. The listing is
// not filtered by app id because the flag for that changed name across
// AeroSpace versions; the window list itself is small enough to scan.
function paneLocation() {
	return aerospace(
		"list-windows --all --format '%{app-name}|%{window-id}|%{workspace}|%{window-title}'"
	).then((output) => {
		const row = output
			.split("\n")
			.map((line) => line.split("|"))
			.find(
				(columns) =>
					columns[0].toLowerCase().startsWith("hammerspoon") &&
					columns[3] === PANE_TITLE
			);

		return row ? { id: row[1], workspace: row[2] } : null;
	});
}

function createPane() {
	const frame = hs.screen.main().frame;

	const webview = hs.ui
		.webview()
		.toolbar(["back", "forward", "reload", "url"])
		.loadURL(START_URL);

	return hs.ui
		.window({
			x: frame.x,
			y: frame.y,
			w: Math.floor(frame.w / 3),
			h: frame.h,
		})
		.windowTitle(PANE_TITLE)
		.level("floating")
		.webview(webview)
		.onHide(() => {
			visible = false;

			const saved = windowBeforeOpen;
			windowBeforeOpen = null;
			if (saved) saved.focus();
		});
}

function showPane() {
	win.show();
	visible = true;
	// show() only orders the window in front; the accessory app has to be
	// activated for the window to take keyboard focus.
	hs.application.fromPID(hs.appinfo.pid)?.activate();
}

function toggleChatGPT() {
	if (!win) win = createPane();

	Promise.all([aerospace("list-workspaces --focused"), paneLocation()]).then(
		([focusedWorkspace, pane]) => {
			// A pane left on another workspace sits in a corner there; treat it as
			// still open and pull it over instead of closing it.
			const inFront = pane !== null && pane.workspace === focusedWorkspace;
			if (inFront || (pane === null && visible)) {
				win.hide();
				return;
			}

			windowBeforeOpen = hs.window.focusedWindow();

			const bring = pane
				? aerospace(
						`move-node-to-workspace "${focusedWorkspace}" --window-id ${pane.id}`
					)
				: // A pane that was hidden is remembered by AeroSpace and would be
					// restored to its old workspace. This no-op layout command drops
					// that memory, so the pane opens where the user is.
					aerospace(`move-node-to-workspace "${focusedWorkspace}"`);

			bring.then(showPane);
		}
	);
}

hs.hotkey.bind(["cmd", "alt", "ctrl"], "i", toggleChatGPT, null, null);
