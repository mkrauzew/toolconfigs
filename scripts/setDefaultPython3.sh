#!/bin/bash

BIN_DIR="/usr/bin/"
BACKTITLE="Set default Python3 version"
DIALOG_OK=0
DIALOG_CANCEL=1
DIALOG_ESC=255

# Generates list of menu items
# $1 - list of elements
# $2 - currently active element
generate_menu_list() {
   [[ -z ${1} ]] && exit 1
   [[ -z ${2} ]] && exit 1

   RESULT=""
   for s in ${1}; do
      RESULT="${RESULT} "${s}" "${s}""
      if [[ "${s}" = "${2}" ]]; then
         RESULT="${RESULT} on "
      else
         RESULT="${RESULT} off "
      fi
   done
   echo "${RESULT}"
}

change_python3_version() {
   rm ${BIN_DIR}python3
   ln -s ${BIN_DIR}${1} ${BIN_DIR}python3
   rm ${BIN_DIR}python3m
   ln -s ${BIN_DIR}${1}m ${BIN_DIR}python3m
}

get_current_python3_version() {
   echo "$(ls -l ${BIN_DIR}python3 | awk '{print $NF}' | awk -F '/' '{print $NF}')"
}

dialog_message() {
   dialog --backtitle "${BACKTITLE}" --msgbox "${1}" 0 0
}

AVAILABLE_VERSIONS="$(ls -lpd ${BIN_DIR}python* | grep -E '^-.*python3\.[0-9]+$' | awk -F '/' '{print $NF}')"
AVAILABLE_VERSIONS_COUNT="$(wc -l <<< "${AVAILABLE_VERSIONS}")"
CURRENT_VERSION=$(get_current_python3_version)
MENULIST="$(generate_menu_list "${AVAILABLE_VERSIONS}" "${CURRENT_VERSION}")"

if [[ "${EUID}" -ne 0 ]]; then
   dialog_message "The following versions of Python3 are available (only the folder ${BIN_DIR} considered):\n\n${AVAILABLE_VERSIONS}\n\nThe current default version is: ${CURRENT_VERSION}\n\nIf you want to change the default version, run this script as root."
   clear
   exit 1
fi

exec 3>&1
SELECTION=$(dialog \
   --backtitle "${BACKTITLE}" \
   --title "Select version" \
   --clear \
   --radiolist "The following versions of Python3 are available (only the folder ${BIN_DIR} considered). Select the default one, i.e. the one that will be invoked by 'python3' command.\n\nPress space to select and OK to confirm." \
   0 0 ${AVAILABLE_VERSIONS_COUNT} \
   ${MENULIST} \
   2>&1 1>&3)
EXIT_STATUS=$?
exec 3>&-

case $EXIT_STATUS in
   $DIALOG_CANCEL )
      clear
      echo "Cancelled"
      exit 0
      ;;
   $DIALOG_ESC )
      clear
      echo "Aborted"
      exit 0
      ;;
esac
if [[ "${SELECTION}" != "${CURRENT_VERSION}" ]]; then
   dialog --backtitle "${BACKTITLE}" \
    --title "Confirm change" \
    --yesno "Do you want to change default Python3 version\n\n from ${CURRENT_VERSION}\n to   ${SELECTION}\n\n?" 0 0
   if [[ $? -eq  ${DIALOG_OK} ]]; then
      change_python3_version "${SELECTION}"
   fi
fi

CURRENT_VERSION_AFTER=$(get_current_python3_version)
if [[ "${CURRENT_VERSION_AFTER}" == "${CURRENT_VERSION}" ]]; then
   dialog_message "Version was not changed.\n\nCurrent version: ${CURRENT_VERSION_AFTER}"
else
   dialog_message "Version changed.\n\nCurrent version: ${CURRENT_VERSION_AFTER}"
fi

clear

