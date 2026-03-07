# Essential Bash Keyboard Shortcuts

[BASH](shells.md#bash-bourne-again-shell) has a ton of shortcuts, but you don’t
need to know them all right away. Start with these — they’ll save you a ton of
keystrokes and make life at the command line way smoother.

| Shortcut      | What it Does                                                                 |
| ------------- | ---------------------------------------------------------------------------- |
| `TAB`       | Autocompletes a partially typed command. If there’s more than one match, Bash shows you the options. |
| `↑ / ↓`     | Scroll back/forward through your command history. |
| `Ctrl+e`    | Jump to the **end** of the current line. (e = end) |
| `Ctrl+a`    | Jump to the **start** of the current line. (a = alphabet’s start) |
| `Ctrl+u`    | Delete everything from the cursor **back to the start** of the line. |
| `Ctrl+k`    | Delete everything from the cursor **to the end** of the line. |
| `Ctrl+w`    | Delete the word just before the cursor. |
| `Ctrl+y`    | Paste back (yank) the last thing you deleted with `Ctrl+u`, `Ctrl+k`, or `Ctrl+w`. |
| `Ctrl+l`    | Clear the screen (like the `clear` command). |
| `Ctrl+c`    | Cancel/kill the currently running command or process. |
| `Ctrl+z`    | Pause the current job (suspends it in the background). |
| `fg`        | Resume the most recent job that was paused with `Ctrl+z`. |
| `bg`        | Resume the paused job, but keep it running in the background. |
| `Ctrl+d`    | Log out of the current shell (or send an EOF if in a prompt). |
| `Ctrl+r`    | Reverse search through your command history. Type part of a command and Bash will find it. (Game-changer!) |
| `!!`        | Run the last command again. (`sudo !!` is a classic trick.) |

👉 Pro tip: Start with `TAB`, `Ctrl+r`, and `Ctrl+c`. Those three alone will change your Bash life.
