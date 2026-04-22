function fssh -d "SSH 快捷工具"
    # --- 辅助函数：选择 Host ---
    function _fssh_select_host
        set -l host_list (grep -Ei '^Host ' ~/.ssh/config | grep -v '\*' | grep -vi 'github' | awk '{print $2}' | sort -u)
        test -z "$host_list"; and return 1
        printf "%s\n" $host_list | fzf --height 40% --reverse --border --prompt="Select SSH Host: "
    end

    switch $argv[1]
        case -a
            echo "--- 添加新 SSH 配置 (Ctrl+C 可随时退出) ---"
            while true
                read -l -p "echo -n '请输入 主机IP 或 域名 [必填]: '" target_input
                set target_input (string trim $target_input)
                if string match -r -q '^[a-zA-Z0-9.-]+$' $target_input
                    break
                else
                    echo "❌ 格式错误，请重新输入。"
                end
            end
            read -l -p "echo -n '请输入 Host 别名 (默认 $target_input): '" host_alias
            set host_alias (string trim $host_alias)
            test -z "$host_alias"; and set host_alias $target_input
            read -l -p "echo -n '请输入 用户名 (默认 root): '" ssh_user
            set ssh_user (string trim $ssh_user)
            test -z "$ssh_user"; and set ssh_user "root"
            read -l -p "echo -n '请输入 端口 (默认 22): '" ssh_port
            set ssh_port (string trim $ssh_port)
            test -z "$ssh_port"; and set ssh_port 22
            read -l -p "echo -n '是否添加旧版 SSH 兼容配置 (y/n)? ' " confirm
            printf "\nHost %s\n  HostName %s\n  User %s\n  Port %s\n" $host_alias $target_input $ssh_user $ssh_port >> ~/.ssh/config
            if test "$confirm" = "y" -o "$confirm" = "Y"
                printf "  HostKeyAlgorithms +ssh-rsa\n  PubkeyAcceptedAlgorithms +ssh-rsa\n  SetEnv TERM=xterm-256color\n" >> ~/.ssh/config
            end
            echo "✅ 成功添加配置: $host_alias"

        case -c
            set host (_fssh_select_host)
            test -n "$host"; and ssh-copy-id $host

        case -e
            set target_host (_fssh_select_host)
            test -z "$target_host"; and return 1

            # 1. 精准定位起始行和结束行
            set start_line (grep -n "^Host $target_host" ~/.ssh/config | cut -d: -f1 | head -n 1)
            set next_line (grep -n "^Host " ~/.ssh/config | cut -d: -f1 | awk -v s=$start_line '$1 > s {print $1; exit}')
            test -z "$next_line"; and set next_line (math (wc -l < ~/.ssh/config) + 1)
            set end_line (math $next_line - 1)

            while true
                set menu_items "修改别名 (Host)" "修改用户名 (User)" "修改端口 (Port)" "切换旧版兼容 (HostKeyAlgorithms)" "修改完成"
                set choice (printf "%s\n" $menu_items | fzf --height 30% --reverse --prompt="选择要修改的字段: ")
                
                switch $choice
                    case "修改完成"
                        echo "✅ 配置已保存。"
                        break
                    
                    case "切换旧版兼容 (HostKeyAlgorithms)"
                        # 1. 获取当前的行号
                        set -l start_line (grep -n "^Host $target_host" ~/.ssh/config | cut -d: -f1 | head -n 1)
                        set -l next_line (grep -n "^Host " ~/.ssh/config | cut -d: -f1 | awk -v s=$start_line '$1 > s {print $1; exit}')
                        test -z "$next_line"; and set next_line (math (wc -l < ~/.ssh/config) + 1)
                        set -l end_line (math "$next_line" - 1)

                        # 2. 读取当前块内容到变量
                        set -l block_content (sed -n "$start_line,$end_line p" ~/.ssh/config)

                        if string match -q "*HostKeyAlgorithms*" "$block_content"
                            # 已存在，删除对应的行
                            sed -e "$start_line,$end_line { /HostKeyAlgorithms/d; /PubkeyAcceptedAlgorithms/d; /SetEnv/d; }" ~/.ssh/config > ~/.ssh/config.tmp
                            mv ~/.ssh/config.tmp ~/.ssh/config
                            echo "✅ 已移除兼容配置。"
                        else
                            # 不存在，添加配置
                            # 使用 sed 的 'a' (append) 命令直接插入，无需创建临时文件
                            # 缩进完全由这里的字符串决定，非常精准
                            set -l insert_text "    HostKeyAlgorithms +ssh-rsa\n    PubkeyAcceptedAlgorithms +ssh-rsa\n    SetEnv TERM=xterm-256color"
                            
                            sed -e "$end_line a\\
$insert_text" ~/.ssh/config > ~/.ssh/config.tmp
                            
                            mv ~/.ssh/config.tmp ~/.ssh/config
                            echo "✅ 已添加兼容配置。"
                        end
                    
                    case "修改别名 (Host)"
                        read -l -p "echo -n '新别名: '" new_val
                        test -n "$new_val"; and sed -i '' -e "$start_line s|Host .*|Host $new_val|" ~/.ssh/config 2>/dev/null; \
                        or sed -i -e "$start_line s|Host .*|Host $new_val|" ~/.ssh/config
                        set target_host $new_val
                        set start_line (grep -n "^Host $target_host" ~/.ssh/config | cut -d: -f1 | head -n 1)
                        # 更新 end_line
                        set next_line (grep -n "^Host " ~/.ssh/config | cut -d: -f1 | awk -v s=$start_line '$1 > s {print $1; exit}')
                        test -z "$next_line"; and set next_line (math (wc -l < ~/.ssh/config) + 1)
                        set end_line (math $next_line - 1)

                    case "修改用户名 (User)"
                        read -l -p "echo -n '新用户名: '" new_val
                        test -n "$new_val"; and sed -i '' -e "$start_line,$end_line s|^\s*User .*|  User $new_val|" ~/.ssh/config 2>/dev/null; \
                        or sed -i -e "$start_line,$end_line s|^\s*User .*|  User $new_val|" ~/.ssh/config
                    
                    case "修改端口 (Port)"
                        read -l -p "echo -n '新端口: '" new_val
                        test -n "$new_val"; and sed -i '' -e "$start_line,$end_line s|^\s*Port .*|  Port $new_val|" ~/.ssh/config 2>/dev/null; \
                        or sed -i -e "$start_line,$end_line s|^\s*Port .*|  Port $new_val|" ~/.ssh/config
                end
            end

        case "-d"
            # 1. 获取所有 Host 列表供用户选择
            set target_host (_fssh_select_host)
            test -z "$target_host"; and return 1

            # 2. 第一次确认 (需要输入 y 并回车)
            read -P "确定要删除 Host '$target_host' 吗？(输入 y 并回车): " confirm1
            if test "$confirm1" != "y"
                echo "操作已取消。"
                return
            end

            # 4. 计算行号并删除
            set -l start_line (grep -n "^Host $target_host" ~/.ssh/config | cut -d: -f1 | head -n 1)
            set -l next_line (grep -n "^Host " ~/.ssh/config | cut -d: -f1 | awk -v s=$start_line '$1 > s {print $1; exit}')
        
            if test -z "$next_line"
                set next_line (math (wc -l < ~/.ssh/config) + 1)
            end
            set -l end_line (math "$next_line" - 1)

            sed -e "$start_line,$end_line d" ~/.ssh/config > ~/.ssh/config.tmp
            mv ~/.ssh/config.tmp ~/.ssh/config
        
            echo "✅ Host '$target_host' 已彻底删除。"

        case ""
            set host (_fssh_select_host)
            test -n "$host"; and ssh "$host"

        case '-h'
            echo "用法: fssh [ -a: add new config | -c: ssh-copy-id | -e: edit | -d: delete | -h: help ]"
    end
end
