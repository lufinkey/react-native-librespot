#!/bin/sh

if [ -z "$(which make)" ]; then
	>&2 echo "Missing make command"
	exit 1
fi

if [ -z "$(which cargo)" ]; then
	>&2 echo "Missing cargo command"
	exit 1
fi

cd "$(dirname "$0")/rust" || exit $?
make || exit $?
