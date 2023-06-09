#!/bin/bash

if [[ ! "which dialog" ]]; then
    echo "This script requires the 'dialog' package - please install it."
    exit 1
fi

DIALOG_OK=0
DIALOG_CANCEL=1
DIALOG_ESC=255

exec 3>&1
SELECTION=$(dialog \
    --backtitle "Toolconfigs installation tool" \
    --clear \
    --checklist "Select components to install" \
    0 0 8 \
    "1" "Custom Git Commands" off \
    "2" ".vimrc" off \
    "3" ".dialogrc" off \
    "4" ".bash_aliases" off \
    "5" ".bash_functions" off \
    "6" ".tmux.conf" off \
    2>&1 1>&3)

EXIT_STATUS=$?

exec 3>&-

case ${EXIT_STATUS} in
   ${DIALOG_CANCEL} )
      clear
      echo "Cancelled"
      exit 0
      ;;
   ${DIALOG_ESC} )
      clear
      echo "Aborted"
      exit 0
      ;;
   * )
      clear
      ;;
esac

for s in ${SELECTION}; do
    case "${s}" in
        "1")
            echo ">>>>>> INSTALLING: Custom Git Commands <<<<<<"
            GitCustomCommands/InstallCustomGitCmd.sh
            cp GitCustomCommands/git_interactive.sh ~/.git_interactive
            chmod 755 ~/.git_interactive
            echo
            ;;
        "2")
            echo ">>>>>> INSTALLING: .vimrc <<<<<<"
            cp -i vimrc/vimrc ~/.vimrc 
            cp -i vimrc/ycm.py ~/.vim/ycm.py
            echo
            ;;
        "3")
            echo ">>>>>> INSTALLING: .dialogrc <<<<<<"
            cp -i dialogrc/dialogrc ~/.dialogrc 
            echo
            ;;
        "4")
            echo ">>>>>> INSTALLING: .bash_aliases <<<<<<"
            cp -i bash_aliases/bash_aliases ~/.bash_aliases
            echo
            ;;
        "5")
            echo ">>>>>> INSTALLING: .bash_functions <<<<<<"
            cp -i bash_functions/bash_functions ~/.bash_functions
            echo
            ;;
        "6")
            echo ">>>>>> INSTALLING: .tmux.conf <<<<<<"
            cp -i tmux.conf/tmux.conf ~/.tmux.conf
            echo
            ;;
     esac
done
