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

```
- \[ ]*set version=\[0-9]
- \[ ]*\[#/]\[#/]*\[ ]\[ ]*version\[:=]\[ ]\[ ]*\[0-9]
- \[ ]*\[#/]\[#/]*\[ ]\[ ]*version\[ ]\[ ]*=\[ ]\[ ]*\[0-9]
- \[ ]*\[#/]*version\[:=]\[ ]\[ ]*\[0-9]
- \[ ]*\[#/]*version\[ ]\[ ]*\[:=]\[ ]\[ ]*\[0-9]
- \[ ]*\[#/]*version\[ ]\[ ]*=\[0-9]
- \[ ]*\[#/]*version\[ ]\[ ]*:\[0-9]
```

## Rename branch master to main to catter to the woke mob
1. rename your local branch:

`git branch -m master main`

2. change the tracked branch

`git fetch -p origin`

`git branch -u origin/master main`

3. change the main local branch

`git remote set-head origin -a`

4. remove the master branch, local and remotely:

`git branch -D master`

`git push origin :master`

5. fix upstream

`git branch --unset-upstream`

`git push --set-upstream origin main`


## License

AGPL-3.0-only
