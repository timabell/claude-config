# Claude config

Claude Code config for allowed commands and "agents"

## Usage

1. Add .claude to user-wide .gitignore
2. Symlink this repo into target repo as .claude/
3. Symlink `global/CLAUDE.md` into `~/.claude/CLAUDE.md` to give claude guidance across all repos
4. Hope that claude code is listening

```
ln -s ~/repo/claude-config/global/CLAUDE.md ~/.claude/
cd somerepo
ln -s ~/repo/claude-config .claude
```


## License

Not that I expect anyone will be using this other than me, but it's A-GPL v3
