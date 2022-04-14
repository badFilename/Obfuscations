# Obfuscations
## Ofuscated Scripts

#### Personal repository for storing/accessing obfuscated scripts. Most are a work in progress. 

## ObDmp.ps1
#### ObDmp.ps1 is a slightly obfuscated version of Out-Minidump. Comment removal, changing the command name, and adjusting some variable names seemed to be sufficient to bypass WD.
#### However, WD detected the dump file immediately upon write to disk. Apparently WD is detecting the dump based off of the lsass.pdb pointer embedded in the file (credit: ƘȺƞfrƹ
@k4nfr3). The miniDumpWriteDump function unfortunately only provides output to a file, so writing to memory wasn't an option. Instead, I added some code to scan the dump prior to calling the file close function, locate the pointer, an rewrite the 'lsass' portion with 'x's (renaming it to xxxxx.pdb). This apparently was enough to evade detection.
#### The script can therefore be copy/pasted onto a desktop and ran without triggering WD. Exfil the dump file for processing with mimikatz on a friendly system, and cover tracks!
