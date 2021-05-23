#####################################################################
# Custom Git commands by Komislav                                   #
# This script will install them in current user's global Git config #
#                                                                   #
# Make sure you run this while inside a Git repo folder, otherwise  #
# it might not work.                                                #
#                                                                   #
# After installation, run 'git cc' for commands description.        #
#####################################################################

_config_present() {
	test -n "$(git config --global $1)" && echo "$1 "
}

_alias_present() {
	test -n "$(git config --global alias.$1)" && echo "$1 "
}

# Test if we would overwrite any present aliases
PRESENT_ALIASES=""
PRESENT_ALIASES+="$(_alias_present st)"
PRESENT_ALIASES+="$(_alias_present ci)"
PRESENT_ALIASES+="$(_alias_present br)"
PRESENT_ALIASES+="$(_alias_present belongs)"
PRESENT_ALIASES+="$(_alias_present co)"
PRESENT_ALIASES+="$(_alias_present df)"
PRESENT_ALIASES+="$(_alias_present dc)"
PRESENT_ALIASES+="$(_alias_present lp)"
PRESENT_ALIASES+="$(_alias_present cc)"
PRESENT_ALIASES+="$(_alias_present smi)"
PRESENT_ALIASES+="$(_alias_present smu)"
PRESENT_ALIASES+="$(_alias_present smur)"
PRESENT_ALIASES+="$(_alias_present iadd)"
PRESENT_ALIASES+="$(_alias_present iunstage)"
PRESENT_ALIASES+="$(_alias_present ico)"

PRESENT_ALIASES+="$(_alias_present try-merge)"
PRESENT_ALIASES+="$(_alias_present try-ff)"
PRESENT_ALIASES+="$(_alias_present graph)"
PRESENT_ALIASES+="$(_alias_present branch-cleanup)"
PRESENT_ALIASES+="$(_alias_present find-copies)"

# Test if we would overwrite any other present configs
PRESENT_CONFIGS=""
PRESENT_CONFIGS+="$(_config_present diff.submodule)"
PRESENT_CONFIGS+="$(_config_present push.recurseSubmodules)"
PRESENT_CONFIGS+="$(_config_present core.editor)"
PRESENT_CONFIGS+="$(_config_present core.autocrlf)"

if [ -n "$PRESENT_ALIASES" ]; then
	echo "There are some commands, that are already present and would be overwritten:"
	echo -e "\t$PRESENT_ALIASES"
	read -n 1 -r -p "Do you wish to continue? [y/n]" yn
	echo
	[ "$yn" != "y" ] && echo "Aborting" && exit 1
fi

if [ -n "$PRESENT_CONFIGS" ]; then
	echo "There are some config options, that are already present and would be overwritten:"
	echo -e "\t$PRESENT_CONFIGS"
	read -n 1 -r -p "Do you wish to continue? [y/n]" yn
	echo
	[ "$yn" != "y" ] && echo "Aborting" && exit 1
fi

echo "Installing custom commands & configs"

# SIMPLE ALIASES:
git config --global alias.st		"status"
git config --global alias.ci		"commit"
git config --global alias.br		"branch"
git config --global alias.belongs	"branch -a --contains"
git config --global alias.co		"checkout"
git config --global alias.df		"diff"
git config --global alias.dc		"diff --cached"
git config --global alias.lp		"log -p"
git config --global alias.smi		"submodule init"
git config --global alias.smu		"submodule update"
git config --global alias.smur		"submodule update --remote"
git config --global alias.iadd		"!bash ~/.git_interactive \"git add\""
git config --global alias.iunstage	"!bash ~/.git_interactive \"git reset HEAD\""
git config --global alias.ico		"!bash ~/.git_interactive \"git checkout --\""

# OTHER CONFIGS:

# Show summary also for submodules, when doing git diff
git config --global diff.submodule log
# When pushing, also check if there is anything to push in submodules
git config --global push.recurseSubmodules check
# Set editor to vim
git config --global core.editor "vim"
# Set autocrlf to 'input'
# This converts CRLF to LF on commit, but not on checkout.
# It should make sure that the repository has LF line endings
git config --global core.autocrlf input

# COMPOSITE COMMANDS:

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

