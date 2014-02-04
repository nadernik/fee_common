MERCURIAL README

This code repository has mercurial version control.  

The point is to centralize lab code, keeping track of changes so we don't irreveribly overwrite important files.  

Please only put code in this repository, no data, because each person will clone a copy onto their computer, so we don't want it too big.</p>

DOWNLOADS

http://mercurial.selenic.com/

If you want the GUI, download TortoiseHg: https://bitbucket.org/tortoisehg/thg/wiki/Home
(this is more difficult if you're using a mac -- if it works for you
on a mac, let Emily know, and post how here.)

good tutorial: http://hginit.com/

COMMAND LINE INSTRUCTIONS
Basic idea: clone the repository onto your computer, update your code, then push changes to the server

-Make sure you are connected to the shared folder of feebox1
 (On mac, open Finder; Go:Connect to server; smb://feebox1.mit.edu/)

-In a terminal, navigate to where you want to place your copy of the repository

-Clone the repository: hg clone ~/../../Volumes/shared/code
(the code folder should appear)

-Set your username: nano .hg/hgrc
Add to the end of the file (substituting your name and email for mine): 
[ui]
username = Emily Mackevicius <elm@mit.edu>
(then type ^O to save and ^X to exit nano)

-When you change something: hg add; hg commit -m "message explaining what you
 changed"
(this keeps a record in your personal version of the repository)

-To push your changes to the server: hg push
(if you get an error saying to force with -f, DO NOT DO THIS.  instead
pull, merge and push again)

-To pull others' changes from the server: hg pull

-To update your version: hg update
(you may get an error that this creates multiple heads.  In this case, merge instead.  DO NOT force (-f))

-To merge your version with the server's version (after you pull): hg
 merge

SUMMARY OF TYPICAL COMMANDS, IN ORDER:

--Tracking changes on your local computer--
hg add
hg commit -m "message explaining what you
 changed"
--Check if anyone else made changes--
hg pull
--Merge if they did, update if they didn't--
hg update
hg merge
--Push your changes to the server-- 
hg push

OTHER USEFUL COMMANDS
--If want to just get the server's version, and write over your local version--
hg update --clean

--If you want to update, and ignore any uncommited changes in your local repository:
hg update -C

--Get a list of the last 3 changes--
hg log -l 3

--Revert to the last commit--
hg revert filename

--Undo one commit--
hg rollback

For more, look at tutorials, for example: http://hginit.com/


