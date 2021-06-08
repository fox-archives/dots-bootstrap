# shellcheck shell=bash

util_get_file() {
	if [[ ${1::1} == / ]]; then
		echo "$1"
	else
		echo "$HOME/$1"
	fi
}

# ensure file removed
must_rm() {
	file="$(util_get_file "$1")"

	[ -e "$file" ] && rm "$file" && echo "$file REMOVED"
}

# ensure directory exists
must_dir() {
	[ -d "$1" ] || {
		mkdir -p "$1"
		[ "${1: -1}" != / ] && set -- "$1/"
		echo "'$1' CREATED"
	}
}

# ensure file exists
must_file() {
	[ -d "$(dirname "$1")" ] || mkdir -p "$(dirname "$1")"
	[ -f "$1" ] || {
		touch "$1"
		echo "'$1' CREATED"
    	}
}

# ensure a symlink points to a particular directory
must_link() {
	src="$(util_get_file "$1")"
	link="$(util_get_file "$2")"

	if [ -L "$link" ]; then
		[ "$(readlink "$link")" != "$src" ] && {
			ln -sfT "$src" "$link" && echo "$link RE-SYMLINKED TO $src"
		}
	else
		ln -sT "$src" "$link" && echo "$link SYMLINKED TO $src"
	fi
}


#
# ─── MAIN ───────────────────────────────────────────────────────────────────────
#

# remove potentially autogenerated dotfiles
must_rm .bash_history
must_rm .gitconfig
must_rm .lesshst
must_rm .mkshrc
must_rm .pulse-cookie
must_rm .pam_environment
must_rm .viminfo
must_rm .wget-hsts
must_rm .zlogin
must_rm .zshrc
must_rm .zprofile
must_rm .zcompdump
must_rm "$XDG_CONFIG_HOME/zsh/.zcompdump"

# check to see if these directories exist (they shouldn't)
check_dot .elementary
check_dot .ghc # fixed in later releases
check_dot .gnupg
check_dot .old # used in bootstrap.sh
check_dot .profile-tmp # used in pre-bootstrap.sh
check_dot .scala_history_jline3

# check to see if programs are automatically installed
check_bin dash
check_bin lesspipe.sh
check_bin xclip
check_bin exa
check_bin rsync

# for programs that require a directory to exists before using it
must_dir "$HOME/.history"
must_dir "$XDG_DATA_HOME/maven"
must_dir "$XDG_DATA_HOME"/vim/{undo,swap,backup}
must_dir "$XDG_DATA_HOME"/nano/backups
must_dir "$XDG_DATA_HOME/zsh"
must_dir "$XDG_DATA_HOME/X11"
must_dir "$XDG_DATA_HOME/xsel"
must_dir "$XDG_DATA_HOME/tig"
must_dir "$XDG_CONFIG_HOME/sage" # $DOT_SAGE
must_dir "$XDG_DATA_HOME/gq/gq-state" # $GQ_STATE
must_dir "$XDG_DATA_HOME/sonarlint" # $SONARLINT_USER_HOME
must_file "$XDG_CONFIG_HOME/yarn/config"

# automatically set up links (not covered by dotty since it is a data file)
must_link "$XDG_DATA_HOME/tig/history" "$HOME/.history/tig_history"
for dir in Dls Docs Music Pics Vids .hidden; do
	must_link "/storage/edwin/$dir" "$HOME/$dir"
done
must_link ~/Docs/Programming/repos ~/repos
must_link ~/Docs/Programming/projects ~/projects
must_link ~/Docs/Programming/workspaces ~/workspaces

# vscode save extensions
exts="$(code --list-extensions)"
[[ $(wc -l <<< "$exts") -gt 5 ]] && cat <<< "$exts" > ~/.dots/state/vscode-extensions.txt

"$HOME/scripts/generateRootBash.sh"

# misc
if ! [ "$(curl -LsSo- https://edwin.dev)" = "Hello World" ]; then
		echo "https://edwin.dev OPEN"
fi
