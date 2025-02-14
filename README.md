# ScriptApps (sap)

ScriptApps is a simple command-line tool that makes your project's scripts accessible from anywhere in your project directory. It automatically discovers executable scripts in your project's `scripts` directory and provides shell completion.

## Features

- 🔍 Automatically discovers executable scripts in your current directory or git project root
- ⌨️ Provides command completion for zsh
- 🚀 Easy to use: just run `sap <command>` from anywhere in your project
- 📝 Shows available commands and their subcommands
- 🔒 Respects executable permissions

## Installation

### Install/Update

```bash
curl -fsSL https://raw.githubusercontent.com/gilade/scriptapps/master/install.sh | sudo bash
```

### Uninstall
```bash
curl -fsSL https://raw.githubusercontent.com/gilade/scriptapps/master/uninstall.sh | sudo bash
```

## Usage

1. Create a `scripts` directory in your project:
```bash
mkdir scripts
```

2. Add executable scripts to your scripts directory. Scripts must:
   - Be executable (`chmod +x`)
   - Support the `--help` flag
   - Format help output with proper subcommand structure

Example script:
```bash
#!/bin/bash
case "$1" in
    "--help")
        echo "Available commands:"
        echo "  migrate:up      Run migrations up"
        echo "  migrate:down    Roll back migrations"
        echo "  migrate:status  Show migration status"
        ;;
    "migrate:up")   echo "Running migrations up" ;;
    "migrate:down") echo "Rolling back migrations" ;;
    "migrate:status") echo "Showing status" ;;
    *) echo "Unknown command. Use --help to see available commands." ;;
esac
```

3. Run your scripts using `sap`:
```bash
sap db migrate:up
```

4. See available commands:
```bash
sap
```

## Help Format Requirements

For scripts to work with autocompletion, they must output help in this format:
```
Available commands:
  action:subaction      Description of the command
  other_command         Another description
```

Key format rules:
- Each subcommand must start with at least one space
- Subcommands can contain letters, numbers, colons, underscores, and hyphens
- Subcommands must be followed by at least one space
- Description is optional but recommended

Example help outputs:
```
Available commands:
  migrate:up      Run database migrations
  migrate:down    Rollback migrations
  schema:dump     Export current schema
```

```
Usage: test <command>

Commands:
  unit            Run unit tests
  integration     Run integration tests
  e2e             Run end-to-end tests
```

## Project Structure Example
```
your-project/
├── scripts/
│   ├── db              # executable script
│   ├── test            # executable script
│   └── deploy          # executable script
├── src/
└── ...
```

## Requirements

- zsh shell
- sudo privileges for installation
- Unix-like operating system (Linux, macOS)

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
