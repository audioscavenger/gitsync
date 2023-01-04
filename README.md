# gitsync.cmd

Single MSDOS batch to upload and versioning local backups of your project, with fall-backs and fast tracks

## How To Use

1. First, have your local project sync with git like normal
2. drop gitsync.cmd and gitsync.cfg.cmd at the root
3. Next, rename gitsync.cfg.cmd to gitsync.cfg_custom.cmd
4. Next, edit gitsync.cfg_custom.cmd to your liking
5. Finally, you can start backing up and syncing your project with gitsync
6. Enjoy

## Specifics

Gitsync auto-detects versions to tag for you, if you add "set version=x.y.z" somewhere in your main project batch. As you guessed, it works only for MSDOS batches.

## TODO
- [x] merge origin main instead of master
- [ ] detect build release version from other languages like JS or python
