export QT_QPA_PLATFORMTHEME=qt5ct
# 设置历史记录文件路径
HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000
# 历史记录配置
setopt APPEND_HISTORY        # 多个会话追加历史记录，而不是覆盖
setopt SHARE_HISTORY         # 多个会话共享历史记录
setopt HIST_IGNORE_DUPS      # 忽略重复命令
setopt HIST_IGNORE_SPACE     # 以空格开头的命令不记录
setopt HIST_VERIFY           # 替换历史后不立即执行，先显示
setopt INC_APPEND_HISTORY    # 每条命令执行后立即写入历史文件

#make nvim the default editor 
export EDITOR='nvim'
export VISUAL='nvim'

# pnpm
export PNPM_HOME="~/.local/share/pnpm"
if [[ ! $PATH =~ $PNPM_HOME ]]; then
    export PATH="$PNPM_HOME:$PATH"
fi

# 添加 ~/.bin和~/.local/bin 到 PATH
if [ -d "$HOME/.bin" ] ; then
    PATH="$HOME/.bin:$PATH"
fi
if [ -d "$HOME/.local/bin" ] ; then
    PATH="$HOME/.local/bin:$PATH"
fi

# 如果是非交互式终端则立刻退出来加快启动速度
[[ $- != *i* ]] && return
export HISTCONTROL=ignoreboth:erasedups

# 自动补全和语法高亮
source ~/.config/ZshPlugins/zsh-autosuggestions/zsh-autosuggestions.zsh
source ~/.config/ZshPlugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
source ~/.config/ZshPlugins/zsh-history-substring-search/zsh-history-substring-search.plugin.zsh
# 绑定上下箭头以进行历史记录子字符串搜索
bindkey '^[[A'  history-substring-search-up    # ESC [ A
bindkey '^[[B'  history-substring-search-down  # ESC [ B
bindkey '^[OA'  history-substring-search-up    # ESC O A
bindkey '^[OB'  history-substring-search-down  # ESC O B

# starship终端美化
eval "$(starship init zsh)"

#zsh进入vi模式
bindkey -v

# 代理设置
proxy() {
    if [[ -n "$http_proxy" ]] || [[ -n "$https_proxy" ]]; then
        unset http_proxy https_proxy HTTP_PROXY HTTPS_PROXY
        echo "🔌 Proxy disabled"
    else
        export http_proxy=http://127.0.0.1:7890
        export https_proxy=http://127.0.0.1:7890
        echo "🚀 Proxy enabled"
    fi
}

### ALIASES ###
# 检测系统发行版并设置 cat 别名
if [ -f /etc/os-release ]; then
    . /etc/os-release
    case "$ID" in
        debian|ubuntu|linuxmint)
            alias cat="batcat"
            ;;
        arch|manjaro|endeavouros)
            alias cat="bat"
            ;;
        *)
            # 其他系统保持默认 cat
            ;;
    esac
fi
alias vi="nvim"
alias winegame="/opt/apps/net.winegame.client/files/bin/winegame"
alias top="btm"
alias fd="fdfind"
alias ls="lsd"
alias tree="lsd --tree"
alias grep="rg"


# ex自动解压所有包
ex ()
{
  if [ -f $1 ] ; then
    case $1 in
      *.tar.bz2)   tar xjf $1   ;;
      *.tar.gz)    tar xzf $1   ;;
      *.bz2)       bunzip2 $1   ;;
      *.rar)       unrar x $1   ;;
      *.gz)        gunzip $1    ;;
      *.tar)       tar xf $1    ;;
      *.tbz2)      tar xjf $1   ;;
      *.tgz)       tar xzf $1   ;;
      *.zip)       unzip $1     ;;
      *.Z)         uncompress $1;;
      *.7z)        7z x -mmt=$(nproc) $1      ;;
      *.deb)       ar x $1      ;;
      *.tar.xz)    tar xf $1    ;;
      *.tar.zst)   tar xf $1    ;;
      *)           echo "'$1' cannot be extracted via ex()" ;;
    esac
  else
    echo "'$1' is not a valid file"
  fi
}
zipa() {
  if [ -n "$1" ]; then
    if [ -d "$1" ]; then
      zip -r "$1.zip" "$1"
    elif [ -f "$1" ]; then
      zip "$1.zip" "$1"
    else
      echo "Error: '$1' is neither a file nor a directory."
    fi
  else
    echo "Usage: z <file_or_directory>"
  fi
}
7za() {
  if [ -n "$1" ]; then
    if [ -d "$1" ]; then
      7z a -mmt$(nproc) "$1.7z" "$1"
    elif [ -f "$1" ]; then
      7z a -mmt$(nproc) "$1.7z" "$1"
    else
      echo "Error: '$1' is neither a file nor a directory."
    fi
  else
    echo "Usage: 7za <file_or_directory>"
  fi
}

fastfetch


