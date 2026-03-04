# edpearOS shell defaults
alias ls='eza --icons --group-directories-first'
alias ll='eza -la --icons --group-directories-first'
alias cat='bat --style=plain'
alias grep='grep --color=auto'
alias study='edpear-welcome'
alias focus='edpear-focus toggle'
alias focuson='edpear-focus on'
alias focusoff='edpear-focus off'

# Greeting
if command -v fastfetch &>/dev/null; then
  fastfetch --logo small
fi
