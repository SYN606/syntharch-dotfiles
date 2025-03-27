# Function to check when a command has ended
function __done_ended
    set cmd $argv[1]
    set status (status last)

    # Ensure at least two arguments exist before checking status
    if test (count $argv) -ge 2
        test $argv[2] -eq 0; and echo "✔"; or echo "❌"
    else
        echo "❌ Error: Missing argument"
    end

    # Notify user if command took long enough and terminal is not focused
    if test $status -ne 0
        set status_text "❌ Failed"
    else
        set status_text "✔ Success"
    end

    echo "Command '$cmd' finished with status: $status_text"
end

# Function to check the active window
function __done_get_focused_window_id
    if command -q swaymsg
        swaymsg -t get_tree | jq '.. | select(.focused?) | .id'
    else if command -q xprop
        xprop -root _NET_ACTIVE_WINDOW | awk '{print $5}'
    else if command -q gdbus
        gdbus call --session --dest org.gnome.Shell --object-path /org/gnome/Shell \
        --method org.gnome.Shell.Eval "global.display.focus_window.get_xid();" | awk '{print $2}'
    else
        echo "0"
    end
end

# Function to check if the terminal is in focus
function __done_is_process_window_focused
    set win_id (__done_get_focused_window_id)
    if test "$win_id" != "0"
        return 0
    else
        return 1
    end
end

# Function to uninstall this script
function __done_uninstall
    functions -e __done_ended __done_get_focused_window_id __done_is_process_window_focused
    echo "✔ done.fish uninstalled successfully."
end
