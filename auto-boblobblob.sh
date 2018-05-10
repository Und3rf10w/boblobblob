if [ $# -lt 1 ]; then
    echo 'USAGE: auto-boblobblob.sh "$/path/to/file/to/hide"'
    exit 0
fi

HIDDENFILE="$1"

if [ -e $HIDDENFILE ]; then
    # grab the file and commit hash, and push it
    git add $HIDDENFILE
    HIDDENFILEHASH=`git hash-object $HIDDENFILE`
    git commit -m "added"
    TREEHASH=`git rev-parse HEAD`
    echo -e "\n[*] Pushing commit.\n"
    git push

    # Revoke the file
    echo -e "\n[*] Removing commit.\n"
    git filter-branch --force --index-filter "git rm --cached --ignore-unmatch $HIDDENFILE" --prune-empty --tag-name-filter cat -- --all
    git push origin --force --all
    git for-each-ref --format='delete %(refname)' refs/original | git update-ref --stdin
    git reflog expire --expire=now --all
    git gc --prune=now

    echo "The file is now revoked from GitHub and your .git working directory"
    echo -e "\n\n[*] File hash: $HIDDENFILEHASH\n[*] Tree hash: $TREEHASH"
    exit 0
else
    echo "An error occured"
    exit 1
fi

