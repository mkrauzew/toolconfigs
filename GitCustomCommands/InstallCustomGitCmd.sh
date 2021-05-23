#####################################################################
# Custom Git commands by Komislav                                   #
# This script will install them in current user's global Git config #
#                                                                   #
# Make sure you run this while inside a Git repo folder, otherwise  #
# it might not work.                                                #
#                                                                   #
# After installation, run 'git cc' for commands description.        #
#####################################################################

_symbol_present() {
	test -n "$(git config --global alias.$1)" && echo "$1 "
}
PRESENT_SYMBOLS=""

# Test if we would overwrite any present symbols
PRESENT_SYMBOLS+="$(_symbol_present st)"
PRESENT_SYMBOLS+="$(_symbol_present ci)"
PRESENT_SYMBOLS+="$(_symbol_present br)"
PRESENT_SYMBOLS+="$(_symbol_present co)"
PRESENT_SYMBOLS+="$(_symbol_present df)"
PRESENT_SYMBOLS+="$(_symbol_present dc)"
PRESENT_SYMBOLS+="$(_symbol_present lp)"
PRESENT_SYMBOLS+="$(_symbol_present cc)"
PRESENT_SYMBOLS+="$(_symbol_present try-merge)"
PRESENT_SYMBOLS+="$(_symbol_present try-ff)"
PRESENT_SYMBOLS+="$(_symbol_present graph)"
PRESENT_SYMBOLS+="$(_symbol_present branch-cleanup)"
PRESENT_SYMBOLS+="$(_symbol_present find-copies)"

if [ -n "$PRESENT_SYMBOLS" ]; then
	echo "There are some commands, that are already present and would be overwritten:"
	echo -e "\t$PRESENT_SYMBOLS"
	read -n 1 -r -p "Do you wish to continue? [y/n]" yn
	echo
	[ "$yn" != "y" ] && exit 1
fi

echo "Installing custom commands"

# aliases
git config --global alias.st "status"
git config --global alias.ci "commit"
git config --global alias.br "branch"
git config --global alias.co "checkout"
git config --global alias.df "diff"
git config --global alias.dc "diff --cached"
git config --global alias.lp "log -p"

# list custom commands
git config --global alias.cc "!f() { \
local c_RED='\\033[31;1m'; \
local c_WHITE='\\033[37;1m'; \
local c_GREEN='\\033[32;1m'; \
local c_NC='\\033[0m'; \
echo; \
echo \"\${c_GREEN} ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ \${c_NC}\"; \
echo \"\${c_GREEN}/ ================ MKW's Custom Git Commands ================ \\ \${c_NC}\"; \
echo \"\${c_GREEN}~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~\${c_NC}\n\"; \
echo \"\${c_WHITE}git \${c_RED}try-merge\${c_WHITE} <dev> <master> \${c_NC}: see how merge of dev into master would go.\"; \
echo \"In case of conflicts, .our will be master's side and .their will be dev's side.\n\"; \
echo \"\${c_WHITE}git \${c_RED}try-ff\${c_WHITE} <from> <to> \${c_NC}: check if fast-forward merge is possible.\n\"; \
echo \"\${c_WHITE}git \${c_RED}graph\${c_WHITE} [<revision range>|--all] \${c_NC}: git log --graph with nice format.\n\"; \
echo \"\${c_WHITE}git \${c_RED}branch-cleanup\${c_NC} : prune remote-tracking branches for current remote, then delete all local branches that track gone remotes.\"; \
echo \"'Current remote' means remote tracked by current branch, or origin if current branch is non-tracking.\n\"; \
echo \"\${c_WHITE}git \${c_RED}find-copies\${c_WHITE} <commit> \${c_NC}: find copies of a commit (for example ones that were cherry-picked).\"; \
echo \"Warning - on big repos this may take several minutes.\n\"; \
echo \"\${c_GREEN}~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~\${c_NC}\"; \
echo \"\${c_GREEN}\\ =========================================================== / \${c_NC}\"; \
echo \"\${c_GREEN} ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ \${c_NC}\n\"; \
}; f"

# check how the merge of dev into master will go: git try-merge dev master
# .our will be master's side, .their will be dev's side
git config --global alias.try-merge "!f() { GREP_COLOR_OLD=\${GREP_COLOR};\
export GREP_COLOR='01;07;31';\
git merge-tree \`git merge-base \$2 \$1\` \$2 \$1 | grep -E --color=always '<<<<<<< .our|>>>>>>> .their|=======|^merged|^changed in.*$|^added in.*$|^removed in.*$|$' | less -XFR;\
GREP_COLOR=\${GREP_COLOR_OLD}; }; f "

# check if first commit is ancestor of the second (meaning that ff is possible)
git config --global alias.try-ff "!f() { git merge-base --is-ancestor \$1 \$2; \
if [ \$? -eq 0 ]; then \
echo 'FF possible.'; \
else \
echo 'FF not possible.'; \
fi; }; f"

# git log --graph with nice format
git config --global alias.graph "log --graph --abbrev-commit --decorate --format=format:'%C(bold blue)%h%C(reset) - %C(bold cyan)%aD%C(reset) %C(bold green)(%ar)%C(reset)%C(bold yellow)%d%C(reset)%n''          %C(white)%s%C(reset) %C(dim white)- %an%C(reset)%n '"

# prune all remote-tracking branches for current remote, then delete any local branches that no longer point to an existing remote tracking branch
git config --global alias.branch-cleanup "!f() { git fetch --prune; git branch -vv | grep ': gone]' | awk '{print \$1}' | xargs git branch -D; }; f"

# find copies of a commit by patch-id
git config --global alias.find-copies "!f() { PATCHID_TO_FIND=\`git show \$1|git patch-id|cut -d' ' -f1\`; COMMIT_LOOKED_FOR=\`git rev-parse \$1\`; for c in \$(git rev-list --all);\
do git show \$c | git patch-id; done | grep -F \$PATCHID_TO_FIND|cut -d' ' -f2|grep -v \$COMMIT_LOOKED_FOR; }; f"

echo "Installation DONE"

exit 0

