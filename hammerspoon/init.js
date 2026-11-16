// Floating web app panes for Hammerspoon 2.
// Cmd+Alt+Ctrl+I toggles ChatGPT, Cmd+Alt+Ctrl+U the Yandex translator.

// AeroSpace hides windows of inactive workspaces in a screen corner and brings
// them back when they belong to the visible workspace, so every open/close goes
// through it: it is what puts a pane in front of the current workspace.
const AEROSPACE =
	'export PATH="/opt/homebrew/bin:/usr/local/bin:$PATH"; aerospace ';

const panes = [
	{ key: "i", title: "ChatGPT", url: "https://chatgpt.com/" },
	{ key: "u", title: "Translate", url: "https://translate.yandex.com/" },
];

function aerospace(args) {
	return hs.task.shell(AEROSPACE + args).then(
		(result) => result.stdout.trim(),
		(result) => {
			console.error("aerospace " + args + ": " + result.stderr.trim());
			return "";
		}
	);
}

// { id, workspace } of a pane as AeroSpace sees it, or null. The listing is not
// filtered by app id because the flag for that changed name across AeroSpace
// versions; the window list itself is small enough to scan.
function paneLocation(title) {
	return aerospace(
		"list-windows --all --format '%{app-name}|%{window-id}|%{workspace}|%{window-title}'"
	).then((output) => {
		const row = output
			.split("\n")
			.map((line) => line.split("|"))
			.find(
				(columns) =>
					columns[0].toLowerCase().startsWith("hammerspoon") &&
					columns[3] === title
			);

		return row ? { id: row[1], workspace: row[2] } : null;
	});
}

function createPane(pane) {
	const frame = hs.screen.main().frame;

	const webview = hs.ui
		.webview()
		.toolbar(["back", "forward", "reload", "url"])
		.loadURL(pane.url);

	pane.win = hs.ui
		.window({
			x: frame.x,
			y: frame.y,
			w: Math.floor(frame.w / 3),
			h: frame.h,
		})
		.windowTitle(pane.title)
		.level("floating")
		.webview(webview)
		.onHide(() => {
			pane.visible = false;

			const saved = pane.windowBeforeOpen;
			pane.windowBeforeOpen = null;
			if (saved) saved.focus();
		});
}

function showPane(pane) {
	pane.win.show();
	pane.visible = true;
	// show() only orders the window in front; the accessory app has to be
	// activated for the window to take keyboard focus.
	hs.application.fromPID(hs.appinfo.pid)?.activate();
}

function togglePane(pane) {
	if (!pane.win) createPane(pane);

	Promise.all([aerospace("list-workspaces --focused"), paneLocation(pane.title)]).then(
		([focusedWorkspace, location]) => {
			// A pane left on another workspace sits in a corner there; treat it as
			// still open and pull it over instead of closing it.
			const inFront = location !== null && location.workspace === focusedWorkspace;
			if (inFront || (location === null && pane.visible)) {
				pane.win.hide();
				return;
			}

			pane.windowBeforeOpen = hs.window.focusedWindow();

			const bring = location
				? aerospace(
						`move-node-to-workspace "${focusedWorkspace}" --window-id ${location.id}`
					)
				: // A pane that was hidden is remembered by AeroSpace and would be
					// restored to its old workspace. This no-op layout command drops
					// that memory, so the pane opens where the user is.
					aerospace(`move-node-to-workspace "${focusedWorkspace}"`);

			bring.then(() => showPane(pane));
		}
	);
}

for (const pane of panes) {
	hs.hotkey.bind(["cmd", "alt", "ctrl"], pane.key, () => togglePane(pane), null, null);
}
