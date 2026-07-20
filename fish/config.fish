source /usr/share/cachyos-fish-config/cachyos-config.fish

# overwrite greeting
# potentially disabling fastfetch
#function fish_greeting
#    # smth smth
#end

alias --save l='ls -lah'

function mkcd --description "mkdir and cd into it"
    mkdir -p $argv[1]; and cd $argv[1]
end
