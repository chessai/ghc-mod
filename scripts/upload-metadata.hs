#!/bin/sh

is_term() {
    [ -t 0 ]
}

# Disable echo while typing the password if in a terminal
hidden_prompt() {
    if is_term; then
	settings=$(stty -g)
	trap "stty '$settings'" 0
	stty -echo
	echo -n "$1: "
	IFS="" read -r $2
	echo
	stty "$settings"
    else
	IFS="" read -r $2
    fi
}



set -e

PACKAGE=$1
OUTDIR=$2

read -p "Username: " user
hidden_prompt "Password" pw


versions="$(curl http://hackage.haskell.org/package/"$PACKAGE"/preferred.json | jq '."normal-version"[]' -r)"

for v in $versions; do
    rev=$(cat $OUTDIR/$PACKAGE-$v.cabal | grep -i "^x-revision:" | tr -s '[:blank:]*' '\t' | cut -f 2)

    if [ -z "$rev" ]; then
        rev=0
    fi

    content=$( ( echo "X-Revision: $((rev + 1))"; cat $OUTDIR/$PACKAGE-$v.cabal | sed '/^X-Revision:/Id' ) )

    resp=$(curl --form-string "cabalfile=$content" -F "publish=Publish new revision" http://hackage.haskell.org/package/"${PACKAGE}-${v}"/"${PACKAGE}.cabal"/edit -u "$user:$pw")

    changes=$(printf '%s\n' "$resp" | sed -n '/Changes in this revision/,/<\/ul>/p' | w3m -dump -T text/html)

    errors=$(printf '%s\n' "$resp" | sed -n '/Errors/,/<\/form>/p')

    notpublished=$(printf '%s\n' "$resp" | grep "Cannot publish new revision")

    if [ -z "$changes" -o -n "$notpublished" ]; then
        if printf '%s\n' "$errors" | grep -q "No changes"; then
            continue;
        fi

        printf '%s\n' "$resp" > /tmp/hackage-metadata-error
        printf '%s\n' "$errors" | w3m -dump -T text/html

        exit 1
    fi
done
