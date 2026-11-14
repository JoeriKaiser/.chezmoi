# Fish shell configuration

set -g fish_greeting

fish_add_path -g ~/.local/bin ~/bin

if status is-interactive
    if type -q fzf
        fzf --fish | source
    end

    if type -q zoxide
        zoxide init fish | source
    end
end
