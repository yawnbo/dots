# Local commands (including VTR) remain available. Prefer managed CLI tools.
export PATH="$HOME/bin:/usr/local/bin:$HOME/.local/bin:$HOME/.cargo/bin:$PATH"
[[ -d "$HOME/.nix-profile/bin" ]] && export PATH="$HOME/.nix-profile/bin:$PATH"

# Auto-attach remote shells before loading interactive shell integrations.
if [[ -o interactive && -n "${SSH_TTY:-}" && -z "${TMUX:-}" ]] &&
   (( $+commands[tmux] )); then
  if tmux has-session 2>/dev/null; then
    exec tmux attach
  else
    exec tmux -f "$HOME/.tmux.conf.remote" new-session -s main
  fi
fi

# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
# if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
#   source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
# fi
# p10k again
# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
# [[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# Path to your oh-my-zsh installation.
export ZSH="${ZSH:-$HOME/.oh-my-zsh}"
export EDITOR=nvim

if [[ "$TERM" == "dumb" || -z "$TERM" ]]; then
  export TERM=xterm-256color
fi

export LANG=en_US.UTF-8
export LC_CTYPE=en_US.UTF-8
export LC_ALL=en_US.UTF-8

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time oh-my-zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
# gnzh and rjk-repos
#ZSH_THEME="agnoster"

#alt p10k
# ZSH_THEME="powerlevel10k/powerlevel10k"

# Set list of themes to pick from when loading at random
# Setting this variable when ZSH_THEME=random will cause zsh to load
# a theme from this variable instead of looking in $ZSH/themes/
# If set to an empty array, this variable will have no effect.
# ZSH_THEME_RANDOM_CANDIDATES=( "robbyrussell" "agnoster" )

# Uncomment the following line to use case-sensitive completion.
CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion.
# Case-sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment one of the following lines to change the auto-update behavior
# zstyle ':omz:update' mode disabled  # disable automatic updates
# zstyle ':omz:update' mode auto      # update automatically without asking
# zstyle ':omz:update' mode reminder  # just remind me to update when it's time

# Uncomment the following line to change how often to auto-update (in days).
# zstyle ':omz:update' frequency 13

# Uncomment the following line if pasting URLs and other text is messed up.
# DISABLE_MAGIC_FUNCTIONS="true"

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# You can also set it to another string to have that shown instead of the default red dots.
# e.g. COMPLETION_WAITING_DOTS="%F{yellow}waiting...%f"
# Caution: this setting can cause issues with multiline prompts in zsh < 5.7.1 (see #5765)
# COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# You can set one of the optional three formats:
# "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# or set a custom format using the strftime function format specifications,
# see 'man strftime' for details.
# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# The full Oh My Zsh loader spends most of startup initializing unused prompt
# machinery. Load completion, everyday helpers, and the selected plugins directly.
autoload -Uz compinit
_zcompdump="${XDG_CACHE_HOME:-$HOME/.cache}/zsh/zcompdump-$ZSH_VERSION"
[[ -d "${_zcompdump:h}" ]] || mkdir -p "${_zcompdump:h}"
compinit -C -d "$_zcompdump"
unset _zcompdump

ZSH_CUSTOM="${ZSH_CUSTOM:-$ZSH/custom}"
autoload -Uz colors && colors
for _omz_lib in cli clipboard completion diagnostics directories functions git grep history key-bindings misc; do
  source "$ZSH/lib/$_omz_lib.zsh"
done
unset _omz_lib

source "$ZSH/plugins/git/git.plugin.zsh"
source "${DOTS_ZSH_SYNTAX_HIGHLIGHTING:-${ZSH_CUSTOM:-$ZSH/custom}/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh}"

# User configuration

# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
# if [[ -n $SSH_CONNECTION ]]; then
#   export EDITOR='vim'
# else
#   export EDITOR='mvim'
# fi

# Compilation flags
# export ARCHFLAGS="-arch x86_64"

# Set personal aliases, overriding those provided by oh-my-zsh libs,
# plugins, and themes. Aliases can be placed here, though oh-my-zsh
# users are encouraged to define aliases within the ZSH_CUSTOM folder.
# For a full list of active aliases, run `alias`.
#
# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"

#source /usr/share/zsh-theme-powerlevel10k/powerlevel10k.zsh-theme
#source ~/src/themes/comfyline.zsh-theme
#source ~/src/themes/heap.zsh-theme

unsetopt interactivecomments

if [[ "$OSTYPE" == darwin* ]]; then
	# usage "valgrind /bin/sh -c 'cd **LAB**; meson build --reconfigure target; meson compile -C target; valgrind ./target/**LAB**"
	alias valgrind='docker run -it -v $PWD:/tmp -w /tmp valgrind:1.0'
	alias gnu='g++'
	alias lastpad="yabai -m config --space \$(yabai -m query --spaces | jq '.[-1].index') top_padding 56"
  export DOCKER_HOST="unix://$HOME/.colima/default/docker.sock"
elif [[ "$OSTYPE" == linux* ]]; then
  # Keep existing NVM installations callable without startup initialization.
  export NVM_DIR="${NVM_DIR:-${XDG_CONFIG_HOME:+$XDG_CONFIG_HOME/nvm}}"
  export NVM_DIR="${NVM_DIR:-$HOME/.nvm}"
  if [[ -s "$NVM_DIR/nvm.sh" ]]; then
    nvm() {
      unfunction nvm
      source "$NVM_DIR/nvm.sh" --no-use || return
      nvm "$@"
    }
  fi
fi
export VIMTEX_OUTPUT_DIRECTORY="$HOME/pdfout/"

function y() {
	local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
	yazi "$@" --cwd-file="$tmp"
	if cwd="$(command cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
		builtin cd -- "$cwd"
	fi
	rm -f -- "$tmp"
}
alias pdfclear='find $HOME/pdfout -type f ! -name "*.pdf" -exec rm -f {} +'
alias skeleton='cp ~/textemp/letterfonts.tex ~/textemp/macros.tex ~/textemp/preamble.tex'

alias kittyplain='KITTY_NO_TMUX=1 kitty'
alias ls='eza'
alias lg='lazygit'
alias t='tmux'
alias spt='spotify_player'
alias v='fd --type f --hidden --exclude .git | fzf-tmux -p | xargs nvim'
alias sio='fd --type f -e pdf --hidden --exclude .git | fzf-tmux -p | xargs sioyek > /dev/null &'
alias listlines="git ls-files --exclude-standard -- ':!:**/*.[pjs][npv]g' ':!:**/*.ai' ':!:.idea' ':!:**/*.eslintrc' ':!:package-lock.json' | xargs wc -l"
alias paste="curl -F 'file=@-' 0x0.st"
alias nv="nvim"
alias fixme='find . -type f -exec sed -i "" "s/\/\/ FIXME:/\/\/ TODO:/g" {} +'
alias l='eza -l'

# z
[[ -r "/usr/share/z/z.sh" ]] && source /usr/share/z/z.sh

_switch_tmux_session() {
  local session="$1"

  if [[ -z "${TMUX:-}" ]]; then
    exec tmux new-session -A -s "$session" -c "$PWD"
  fi

  if ! tmux has-session -t "=$session" 2>/dev/null; then
    tmux new-session -d -s "$session" -c "$PWD" || return
  fi

  tmux switch-client -t "=$session"
}

work() {
  _switch_tmux_session work
}

main() {
  _switch_tmux_session main
}

# launch tmux in kitty
TMUX_PARENT_SESSION="main"
if [ "$TERM" = "xterm-kitty" ] && [ -z "$KITTY_NO_TMUX" ]; then
    if tmux has-session -t "$TMUX_PARENT_SESSION" 2>/dev/null; then
        if [ -n "$(tmux list-clients -t "$TMUX_PARENT_SESSION")" ]; then
            CWD=$PWD
            SHORT_ID=$(mktemp -u XXX)
            UNIQUE_ID="main-$SHORT_ID"
            NEW_WINDOW=$(tmux new-window -d -t "$TMUX_PARENT_SESSION" -c "$CWD" -P -F '#{window_id}')
						exec tmux new-session -t "$TMUX_PARENT_SESSION" -s "$UNIQUE_ID" \; set destroy-unattached on \; select-window -t "$NEW_WINDOW"
        else
            exec tmux attach-session -t "$TMUX_PARENT_SESSION"
        fi
    else
        exec tmux new-session -s "$TMUX_PARENT_SESSION"
    fi
fi

[[ -f ~/.secrets.sh ]] && source ~/.secrets.sh

deploy() {
  local project="${PWD##*/}"
	rsync -avz --exclude target/ --exclude .git/ --exclude '*.db' --exclude '*.db-wal' --exclude '*.db-shm' ./ "${DEPLOY_HOST}":~/"$project"/
}

# Cache Starship's shell integration and refresh it only after upgrades.
if (( $+commands[starship] )); then
  _starship_init_cache="${XDG_CACHE_HOME:-$HOME/.cache}/starship/init.zsh"
  _starship_executable="${commands[starship]:A}"
  # Nix store files have fixed timestamps, so also compare the resolved path.
  if [[ ! -r "$_starship_init_cache" || ! -r "$_starship_init_cache.bin" ||
        "$(< "$_starship_init_cache.bin")" != "$_starship_executable" ||
        "$_starship_executable" -nt "$_starship_init_cache" ]]; then
    mkdir -p "${_starship_init_cache:h}"
    if starship init zsh >| "$_starship_init_cache"; then
      print -r -- "$_starship_executable" >| "$_starship_init_cache.bin"
    fi
  fi
  source "$_starship_init_cache"
  unset _starship_init_cache _starship_executable
fi
if (( $+commands[zoxide] )); then
  eval "$(zoxide init zsh)"
fi

# Optional local opencode installation; do not override Nix-managed commands.
[[ -d "$HOME/.opencode/bin" ]] && export PATH="$PATH:$HOME/.opencode/bin"

# Load Aster after shell plugins so its conservative Tab widget runs first.
if [[ -o interactive && "${TERM:-dumb}" != "dumb" ]] && (( $+commands[aster] )); then
  eval "$(aster init zsh)"
fi

if [[ -o interactive ]] && (( $+commands[lorri] )); then
  eval "$(lorri hook zsh)"
fi
