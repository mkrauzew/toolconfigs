#!/bin/bash

if [[ ! "which dialog" ]]; then
    echo "This script requires the 'dialog' package - please install it."
    exit 1
fi

if [[ -z "${1}" ]]; then
    echo "Usage: ${0} <git_operation_to_be_performed>"
    exit 1
fi

DIALOG_OK=0
DIALOG_CANCEL=1
DIALOG_ESC=255

listed_files=()
while IFS= read -r line; do
	listed_files+=("${line:3}" "$line" "off")
done < <( git status --short )

exec 3>&1
SELECTION=$(dialog \
    --backtitle "Git Interactive by MKW" \
    --clear \
	--no-tags \
    --checklist "Select files for operation: ${1}" \
    0 0 8 \
    "${listed_files[@]}" \
    2>&1 1>&3)

EXIT_STATUS=$?

exec 3>&-

[[ "${EXIT_STATUS}" -ne "${DIALOG_OK}" ]] && exit 1

# If no file selected:
[[ -z "${SELECTION}" ]] && exit 1

echo -n "${1} "
echo ${SELECTION}
echo
read -n 1 -p "Confirm [y/n]?: " line
echo

case ${line:0:1} in
    y|Y )
        ${1} ${SELECTION}
		exit 0
    ;;
    * )
        exit 1
    ;;
esac
