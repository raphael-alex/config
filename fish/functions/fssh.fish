function fssh -d "SSH shortcut tool"
    # --- Helper function: Select Host ---
    function _fssh_select_host
        set -l host_list (grep -Ei '^Host ' ~/.ssh/config | grep -v '\*' | grep -vi 'github' | awk '{print $2}' | sort -u)
        test -z "$host_list"; and return 1
        printf "%s\n" $host_list | fzf --height 40% --reverse --border --prompt="Select SSH Host: "
    end

    switch $argv[1]
        case -a
            echo "--- Add new SSH config (Ctrl+C to exit anytime) ---"
            while true
                read -l -p "echo -n 'Enter host IP or domain [required]: '" target_input
                test $status -ne 0; and return 1
                set target_input (string trim $target_input)
                if string match -r -q '^[a-zA-Z0-9.-]+$' $target_input
                    break
                else
                    echo "❌ Format error, please re-enter."
                end
            end
            read -l -p "echo -n 'Enter Host alias (default $target_input): '" host_alias
            test $status -ne 0; and return 1
            set host_alias (string trim $host_alias)
            test -z "$host_alias"; and set host_alias $target_input
            read -l -p "echo -n 'Enter username (default root): '" ssh_user
            test $status -ne 0; and return 1
            set ssh_user (string trim $ssh_user)
            test -z "$ssh_user"; and set ssh_user "root"
            read -l -p "echo -n 'Enter port (default 22): '" ssh_port
            test $status -ne 0; and return 1
            set ssh_port (string trim $ssh_port)
            test -z "$ssh_port"; and set ssh_port 22
            read -l -p "echo -n 'Add legacy SSH compatibility config (y/n)? ' " confirm
            test $status -ne 0; and return 1
            printf "\nHost %s\n  HostName %s\n  User %s\n  Port %s\n" $host_alias $target_input $ssh_user $ssh_port >> ~/.ssh/config
            if test "$confirm" = "y" -o "$confirm" = "Y"
                printf "  HostKeyAlgorithms +ssh-rsa\n  PubkeyAcceptedAlgorithms +ssh-rsa\n  SetEnv TERM=xterm-256color\n" >> ~/.ssh/config
            end
            echo "✅ Successfully added config: $host_alias"

            # ssh-copy-id
            read -l -p "echo -n 'Do you want to run ssh-copy-id to this host now? (y/n): ' " confirm_copy
            if test "$confirm_copy" = "y" -o "$confirm_copy" = "Y"
                ssh-copy-id $host_alias
            end

        case -e
            set target_host (_fssh_select_host)
            test -z "$target_host"; and return 1

            # 1. Precisely locate start and end lines
            set start_line (grep -n "^Host $target_host" ~/.ssh/config | cut -d: -f1 | head -n 1)
            set next_line (grep -n "^Host " ~/.ssh/config | cut -d: -f1 | awk -v s=$start_line '$1 > s {print $1; exit}')
            test -z "$next_line"; and set next_line (math (wc -l < ~/.ssh/config) + 1)
            set end_line (math $next_line - 1)

            while true
                set menu_items "Modify alias (Host)" "Modify username (User)" "Modify port (Port)" "Toggle legacy compatibility (HostKeyAlgorithms)" "Finish modification"
                set choice (printf "%s\n" $menu_items | fzf --height 30% --reverse --prompt="Select field to modify: ")
                test -z "$choice"; and return 1

                switch $choice
                    case "Finish modification"
                        echo "✅ Configuration saved."
                        break
                    
                    case "Toggle legacy compatibility (HostKeyAlgorithms)"
                        # 1. Get current line numbers
                        set -l start_line (grep -n "^Host $target_host" ~/.ssh/config | cut -d: -f1 | head -n 1)
                        set -l next_line (grep -n "^Host " ~/.ssh/config | cut -d: -f1 | awk -v s=$start_line '$1 > s {print $1; exit}')
                        test -z "$next_line"; and set next_line (math (wc -l < ~/.ssh/config) + 1)
                        set -l end_line (math "$next_line" - 1)

                        # 2. Read current block content into variable
                        set -l block_content (sed -n "$start_line,$end_line p" ~/.ssh/config)

                        if string match -q "*HostKeyAlgorithms*" "$block_content"
                            # Already exists, remove corresponding lines
                            sed -e "$start_line,$end_line { /HostKeyAlgorithms/d; /PubkeyAcceptedAlgorithms/d; /SetEnv/d; }" ~/.ssh/config > ~/.ssh/config.tmp
                            mv ~/.ssh/config.tmp ~/.ssh/config
                            echo "✅ Compatibility config removed."
                        else
                            # Doesn't exist, add configuration
                            # Use sed's 'a' (append) command to insert directly, no temp file needed
                            # Indentation is precisely determined by this string
                            set -l insert_text "    HostKeyAlgorithms +ssh-rsa\n    PubkeyAcceptedAlgorithms +ssh-rsa\n    SetEnv TERM=xterm-256color"
                            
                            sed -e "$end_line a\\
$insert_text" ~/.ssh/config > ~/.ssh/config.tmp
                            
                            mv ~/.ssh/config.tmp ~/.ssh/config
                            echo "✅ Compatibility config added."
                        end
                    
                    case "Modify alias (Host)"
                        read -l -p "echo -n 'New alias: '" new_val
                        test $status -ne 0; and return 1
                        test -n "$new_val"; and sed -i '' -e "$start_line s|Host .*|Host $new_val|" ~/.ssh/config 2>/dev/null; \
                        or sed -i -e "$start_line s|Host .*|Host $new_val|" ~/.ssh/config
                        set target_host $new_val
                        set start_line (grep -n "^Host $target_host" ~/.ssh/config | cut -d: -f1 | head -n 1)
                        # Update end_line
                        set next_line (grep -n "^Host " ~/.ssh/config | cut -d: -f1 | awk -v s=$start_line '$1 > s {print $1; exit}')
                        test -z "$next_line"; and set next_line (math (wc -l < ~/.ssh/config) + 1)
                        set end_line (math $next_line - 1)

                    case "Modify username (User)"
                        read -l -p "echo -n 'New username: '" new_val
                        test $status -ne 0; and return 1
                        test -n "$new_val"; and sed -i '' -e "$start_line,$end_line s|^\s*User .*|  User $new_val|" ~/.ssh/config 2>/dev/null; \
                        or sed -i -e "$start_line,$end_line s|^\s*User .*|  User $new_val|" ~/.ssh/config
                    
                    case "Modify port (Port)"
                        read -l -p "echo -n 'New port: '" new_val
                        test $status -ne 0; and return 1
                        test -n "$new_val"; and sed -i '' -e "$start_line,$end_line s|^\s*Port .*|  Port $new_val|" ~/.ssh/config 2>/dev/null; \
                        or sed -i -e "$start_line,$end_line s|^\s*Port .*|  Port $new_val|" ~/.ssh/config
                end
            end

        case "-d"
            # 1. Get all Host list for user selection
            set target_host (_fssh_select_host)
            test -z "$target_host"; and return 1

            # 2. First confirmation (requires entering y and pressing enter)
            read -P "Confirm deletion of Host '$target_host'? (enter y and press enter): " confirm1
            test $status -ne 0; and return 1
            if test "$confirm1" != "y"
                echo "Operation cancelled."
                return
            end

            # 4. Calculate line numbers and delete
            set -l start_line (grep -n "^Host $target_host" ~/.ssh/config | cut -d: -f1 | head -n 1)
            set -l next_line (grep -n "^Host " ~/.ssh/config | cut -d: -f1 | awk -v s=$start_line '$1 > s {print $1; exit}')
        
            if test -z "$next_line"
                set next_line (math (wc -l < ~/.ssh/config) + 1)
            end
            set -l end_line (math "$next_line" - 1)

            sed -e "$start_line,$end_line d" ~/.ssh/config > ~/.ssh/config.tmp
            mv ~/.ssh/config.tmp ~/.ssh/config
        
            echo "✅ Host '$target_host' has been completely deleted."

        case ""
            set host (_fssh_select_host)
            test -n "$host"; and ssh "$host"

        case '-h'
            echo "Usage: fssh [ -a: add new config | -e: edit | -d: delete | -h: help ]"
    end
end
