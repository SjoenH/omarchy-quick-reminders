# Quick Reminders

Simple reminder app for Omarchy to quickly jot down tasks and keep momentum going.

## Features

- **Quick capture**: Add reminders with a single text input
- **Simple workflow**: Active → Done → Archive → Delete
- **Bar widget**: Shows active reminder count in your bar
- **Persistent storage**: Reminders saved to `~/.local/share/omarchy/quick-reminders.json`
- **Three tabs**: Active, Done, and Archive views
- **Clean UI**: Dracula-themed interface matching Omarchy style

## Workflow

1. **Add reminder**: Type in the input field and press Enter or click Add
2. **Mark as done**: Click "Done" button to move to Done tab
3. **Archive**: Click "Archive" button in Done tab to move to Archive
4. **Delete**: Click "Delete" button in Archive tab to permanently remove

## Install

```bash
cd ~/.config/omarchy/plugins/
git clone https://github.com/SjoenH/omarchy-quick-reminders henry.quick-reminders
omarchy plugin validate ~/.config/omarchy/plugins/henry.quick-reminders
omarchy plugin enable no.koka.quick-reminders
```

## Remove

```bash
omarchy plugin disable no.koka.quick-reminders
rm -rf ~/.config/omarchy/plugins/henry.quick-reminders
```

## Usage

Click the 📝 icon in your bar to open the reminder panel. The icon turns pink when you have active reminders.

## Development

This plugin uses:
- JSON file storage in `~/.local/share/omarchy/`
- Auto-refresh every 2 seconds
- No external dependencies

## License

MIT License - see LICENSE file for details

## Author

koka.no - https://koka.no
