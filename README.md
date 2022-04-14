# Obfuscations
## Ofuscated Scripts

#### Personal repository for storing/accessing obfuscated scripts. Most are a work in progress/in a private repository. 

## ObDmp.ps1
#### ObDmp.ps1 is a slightly obfuscated version of [Out-Minidump](https://github.com/PowerShellMafia/PowerSploit/blob/master/Exfiltration/Out-Minidump.ps1). Comment removal, changing the command name, and adjusting some variable names seemed to be sufficient to bypass WD.

#### However, WD detected the dump file immediately upon write to disk. Apparently WD is detecting the dump based off of the lsass.pdb pointer embedded in the file (credit: [ƘȺƞfrƹ@k4nfr3](https://www.bussink.net/lsass-minidump-file-seen-as-malicious-by-mcafee-av/)). The miniDumpWriteDump function used in this script unfortunately only provides output to a file, so writing to memory wasn't an option. Instead, I added some code to scan the dump stream prior to calling the file close function, locate the pointer, and rewrite the 'lsass' portion with 'x's (renaming it to xxxxx.pdb). This apparently was enough to evade detection.

#### The script can therefore be copy/pasted onto a desktop and ran without triggering WD. Exfil the dump file for processing with mimikatz on a friendly system, and cover tracks!

#### I'm not a regular developer/code guy so I'm sure someone could improve the script. For example, using a byte array as a buffer is probably not the most efficient way but it seems to get the job done in a few seconds. It's quick and dirty, but it works! (as of 4.13.2022)
