# Clipboard Translation Script

This script translates the content from the clipboard using `trans` and caches the results to improve performance. It also supports integration with `qutebrowser`.

## Features

- Reads content from the clipboard.
- Translates the content to a target language.
- Caches translation results to avoid redundant translations.
- Displays the translated content using `dmenu`.
- Saves the translated content to a specified directory.

## Requirements

- `bash`
- `xclip`
- `trans`
- `md5sum`
- `dmenu`

## Usage

1. Ensure you have the required dependencies installed.
2. Copy some text to the clipboard.
3. Run the script.

## Integration with qutebrowser

1. Create a symlink in the qutebrowser scripts folder pointing to dmenu_trans.sh.
    `ln -s /path/to/dmenu_trans.sh ~/.config/qutebrowser/scripts/translate`
2. Add a keybind in your qutebrowser configuration (usually config.py).
    `config.bind('<Ctrl+Shift+T>', 'spawn --userscript translate')`

```bash
./path/to/dmenu_trans.sh
