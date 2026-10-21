/**
 * Native focus-aware cursor.
 *
 * The pi TUI draws its own software cursor as a reverse-video block. That block
 * stays solid even when the terminal window loses focus because it is regular
 * cell styling, not the terminal cursor.
 *
 * Ghostty (and other terminals) already render the *hardware* cursor as a solid
 * block while the surface is focused and a hollow box while it is unfocused.
 * This extension removes the reverse-video software cursor when the hardware
 * cursor is enabled, keeping the zero-width CURSOR_MARKER so pi can still
 * position the hardware cursor for IME support.
 *
 * It patches `CustomEditor.prototype.render` rather than registering a wrapper
 * editor component. Registering a component replaces the editor slot, and Pi
 * reports that slot via `getEditorComponent()`. Editor-owning extensions (for
 * example Plan Build) treat any change of that identity as another extension
 * stealing the editor and disable their own composer. Patching the shared
 * prototype keeps the editor identity untouched, so those composers stay active
 * while the software cursor is still removed.
 *
 * It patches the whole prototype once, so subclasses such as Plan Build's mode
 * composer (which call `super.render`) are covered too.
 *
 * Requires `showHardwareCursor: true` (set in settings.json).
 */

import { CustomEditor, type ExtensionAPI } from "@earendil-works/pi-coding-agent";
import { CURSOR_MARKER } from "@earendil-works/pi-tui";

type RenderableEditor = {
	render(width: number): string[];
	tui?: { getShowHardwareCursor?: () => boolean };
};

const PATCH_FLAG = "__piNativeCursorPatched";

function escapeRegExp(value: string): string {
	return value.replace(/[.*+?^${}()|[\]\\]/g, "\\$&");
}

// The editor emits: CURSOR_MARKER + "\x1b[7m" + <char or space> + "\x1b[0m".
// Capture the character so it survives with only the inverse styling removed.
const SOFTWARE_CURSOR = new RegExp(
	`${escapeRegExp(CURSOR_MARKER)}\x1b\\[7m([\\s\\S]*?)\x1b\\[0m`,
	"g",
);

/**
 * Install the render patch on the shared editor prototype, once per process.
 *
 * The editor instance itself is never replaced, so every other method and
 * property (focus handling, autocomplete, custom composer rendering, ...) is
 * untouched and Pi's editor-slot ownership tracking stays intact.
 */
function installHardwareCursorPatch(): void {
	const proto = CustomEditor.prototype as unknown as RenderableEditor;
	const flags = proto as unknown as Record<string, unknown>;
	if (flags[PATCH_FLAG] === true) return;
	const baseRender = proto.render;
	if (typeof baseRender !== "function") return;
	flags[PATCH_FLAG] = true;
	proto.render = function (this: RenderableEditor, width: number): string[] {
		const lines = baseRender.call(this, width);
		if (this.tui?.getShowHardwareCursor?.() !== true) return lines;
		return lines.map((line) =>
			line.replace(SOFTWARE_CURSOR, (_match, content) => CURSOR_MARKER + content),
		);
	};
}

export default function (pi: ExtensionAPI) {
	// resources_discover fires after every session_start handler, so any
	// editor-owning extension has already installed its composer. Patching the
	// prototype here covers the active editor without replacing the slot.
	pi.on("resources_discover", () => {
		installHardwareCursorPatch();
	});
}
