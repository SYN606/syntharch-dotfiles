
set -g __done_min_cmd_duration 5000
set -g __done_exclude git diff ls

function __done_started --on-event fish_preexec
    set -g __done_cmd_start (date +%s%3N)
end

function __done_ended --on-event fish_postexec
    set cmd_duration (math (date +%s%3N) - $__done_cmd_start)
    if test $cmd_duration -lt $__done_min_cmd_duration; or contains $argv[1] $__done_exclude
        return
    end
    set status_icon (test $argv[2] -eq 0; and echo "✔"; or echo "❌")
    __done_notify "$argv[1] ($cmd_duration ms) $status_icon"
end

function __done_notify
    if type -q notify-send
        notify-send "Command Finished" "$argv"
    else if type -q osascript
        osascript -e "display notification \"$argv\" with title \"Command Finished\""
    else if type -q powershell.exe
        powershell.exe -Command "[System.Windows.MessageBox]::Show('$argv', 'Command Finished')"
    end
end
