#!/bin/bash
semantics="$1"
input_file="$2"

echo "./mu-toksia -p $semantics -f $input_file -fo apx | wc -l"
LINE_NO=$(./mu-toksia -p $semantics -f $input_file -fo apx | wc -l)
EXTENSION_COUNT=$(($LINE_NO-2)) # Remove the brackets

if [ "$EXTENSION_COUNT" -lt 0 ] ; then
    echo 0
else
    echo $EXTENSION_COUNT
fi

