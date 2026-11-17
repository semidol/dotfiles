// Floating web app panes for Hammerspoon 2.
// Cmd+Alt+Ctrl+I toggles ChatGPT, Cmd+Alt+Ctrl+U the Yandex translator.

// AeroSpace hides windows of inactive workspaces in a screen corner and brings
// them back when they belong to the visible workspace, so every open/close goes
// through it: it is what puts a pane in front of the current workspace. A window
// shown while it still belongs to another workspace is either restored to that
// workspace (dragging the visible one along) or left in the corner it was parked
// in, so the move has to finish before the pane is shown.
const AEROSPACE =
	'export PATH="/opt/homebrew/bin:/usr/local/bin:$PATH"; aerospace ';

const panes = [
	{ key: "i", title: "ChatGPT", url: "https://chatgpt.com/", side: "right" },
	{ key: "u", title: "Translate", url: "https://translate.yandex.com/" },
];

function aerospace(args) {
	return hs.task.shell(AEROSPACE + args).then(
		(result) => result.stdout.trim(),
		(result) => {
			const message = args + ": " + (result.stderr || "").trim();
			console.error("aerospace " + message);
			throw new Error(message);
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

// AeroSpace drops a window from its window list as soon as the pane is hidden,
// so a remembered id stops being accepted after that ("Invalid <window-id>")
// and has to be learned again once the pane is on screen; the lookup runs after
// the pane is shown, off the keypress path.
function learnWindowId(pane) {
	if (pane.windowId) return;

	paneLocation(pane.title).then((location) => {
		if (location) pane.windowId = location.id;
	});
}

// One CLI call: the id form moves the pane itself, the id-less form is the no-op
// layout command that clears AeroSpace's memory of a pane it has already dropped
// (it moves the focused window to the workspace it is already on).
function movePane(pane, workspace) {
	const addressed = pane.windowId
		? aerospace(`move-node-to-workspace "${workspace}" --window-id ${pane.windowId}`)
		: Promise.reject(new Error("no window id"));

	return addressed.then(
		() => true,
		() => {
			// A rejected promise means the pane was not moved, so a move that only
			// looks like it succeeded must not be recorded.
			pane.windowId = undefined;
			return aerospace(`move-node-to-workspace "${workspace}"`).then(
				() => true,
				() => false
			);
		}
	);
}

// A third of the screen, on the left by default.
function paneFrame(pane) {
	const frame = hs.screen.main().frame;
	const width = Math.floor(frame.w / 3);

	return {
		x: pane.side === "right" ? frame.x + frame.w - width : frame.x,
		y: frame.y,
		w: width,
		h: frame.h,
	};
}

function createPane(pane) {
	const webview = hs.ui
		.webview()
		.toolbar(["back", "forward", "reload", "url"])
		.loadURL(pane.url);

	pane.win = hs.ui
		.window(paneFrame(pane))
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

	aerospace("list-workspaces --focused")
		.catch(() => "")
		.then((workspace) => {
			if (!workspace) return;

			// The pane is in front of this workspace: the press is a close. AeroSpace
			// forgets the window on hide, so the remembered id goes with it.
			if (pane.visible && pane.workspace === workspace) {
				pane.visible = false;
				pane.windowId = undefined;
				pane.win.hide();
				return;
			}

			pane.windowBeforeOpen = hs.window.focusedWindow();

			// A pane that is only hidden and already belongs here needs no command
			// at all: the workspace AeroSpace would restore it to is the one it is
			// shown on.
			if (!pane.visible && pane.workspace === workspace) {
				showPane(pane);
				learnWindowId(pane);
				return;
			}

			// A pane left on another workspace sits in a corner there, so it has to
			// belong to the focused one before it is shown.
			movePane(pane, workspace).then((placed) => {
				pane.workspace = placed ? workspace : null;
				showPane(pane);
				learnWindowId(pane);
			});
		});
}

for (const pane of panes) {
	hs.hotkey.bind(["cmd", "alt", "ctrl"], pane.key, () => togglePane(pane), null, null);
}
