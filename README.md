# gitsync.cmd

Single MSDOS batch to upload and versioning local backups of your project, with fall-backs and fast tracks

## How To Use

1. First, have your local project sync with git like normal
2. drop gitsync.cmd and gitsync.cfg.cmd at the root
3. Next, rename `gitsync.cfg.cmd` to `gitsync.cfg_custom.cmd`
4. Next, edit gitsync.cfg_custom.cmd to your liking
5. Finally, you can start backing up and syncing your project with gitsync
6. Enjoy

## Specifics

Gitsync auto-detects versions to tag for you with regex, in your main project file `projectConfig`, as defined in `gitsync.cfg_custom.cmd`.
Regex looked for, case insensitive:

- \[ ]*set version=\[0-9]
- \[ ]*\[#/]\[#/]*\[ ]\[ ]*version\[:=]\[ ]\[ ]*\[0-9]
- \[ ]*\[#/]\[#/]*\[ ]\[ ]*version\[ ]\[ ]*=\[ ]\[ ]*\[0-9]
- \[ ]*\[#/]*version\[:=]\[ ]\[ ]*\[0-9]
- \[ ]*\[#/]*version\[ ]\[ ]*\[:=]\[ ]\[ ]*\[0-9]
- \[ ]*\[#/]*version\[ ]\[ ]*=\[0-9]
- \[ ]*\[#/]*version\[ ]\[ ]*:\[0-9]



## TODO
- [x] merge origin main instead of master
- [x] detect build release version from other languages like JS or python
