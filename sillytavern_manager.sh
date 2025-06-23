#!/data/data/com.termux/files/usr/bin/bash
# sillytavern_manager.sh
# Copyright by spacesouks
# Version: 0.1
# Last Updated: 2025.06.23

# --- 配置 ---
ST_DIR="$HOME/SillyTavern"
ST_REPO="https://github.com/SillyTavern/SillyTavern.git"
SCRIPT_SELF_PATH="$HOME/.sillytavern_manager.sh" # 脚本在本地的固定路径
RC_FILE_ADDITION_TAG="# SillyTavern Manager Auto-Start" # 用于检测是否已添加到rc文件

# --- 颜色定义 (可选) ---
C_RED='\033[0;31m'
C_GREEN='\033[0;32m'
C_YELLOW='\033[0;33m'
C_BLUE='\033[0;34m'
C_CYAN='\033[0;36m'
C_NC='\033[0m' # No Color

# --- 辅助函数 ---
print_info() { echo -e "${C_CYAN}INFO:${C_NC} $1"; }
print_warn() { echo -e "${C_YELLOW}WARN:${C_NC} $1"; }
print_error() { echo -e "${C_RED}ERROR:${C_NC} $1"; }

check_command() {
    if ! command -v "$1" &> /dev/null; then
        print_error "$1 命令未找到。请确保Termux已正确安装或尝试 'pkg install $1'。"
        if [ "$2" == "critical" ]; then exit 1; fi
        return 1
    fi
    return 0
}

open_url() {
    print_info "正在尝试打开链接: $1"
    if check_command "termux-open-url"; then
        termux-open-url "$1"
    else
        print_warn "termux-open-url 命令不可用。请手动在浏览器中打开以上链接。"
    fi
}

# --- 核心功能函数 ---
install_dependencies() {
    print_info "正在更新软件包列表并安装依赖 (git, nodejs-lts, python)..."
    pkg update -y && pkg upgrade -y
    pkg install -y git nodejs-lts python
    if [ $? -ne 0 ]; then
        print_error "依赖安装失败。"
        return 1
    fi
    print_info "依赖安装完成。"
    return 0
}

clone_sillytavern() {
    if [ -d "$ST_DIR/.git" ]; then # 检查.git判断是否为仓库，而不仅仅是目录存在
        print_warn "SillyTavern 仓库目录已存在 ($ST_DIR)。跳过克隆。"
        return 0
    elif [ -d "$ST_DIR" ]; then # 目录存在但不是git仓库
        print_warn "目录 $ST_DIR 已存在但不是一个有效的Git仓库。建议删除或重命名后重试。"
        # 可以选择询问用户是否删除
        # read -p "是否删除现有目录 $ST_DIR 并重新克隆? (y/N): " confirm_delete
        # if [[ "$confirm_delete" =~ ^[Yy]$ ]]; then
        #     rm -rf "$ST_DIR"
        # else
        #     return 1
        # fi
        return 1 # 暂时先返回错误，让用户手动处理
    fi
    print_info "正在从 $ST_REPO 克隆 SillyTavern 到 $ST_DIR..."
    git clone --depth=1 "$ST_REPO" "$ST_DIR"
    if [ $? -ne 0 ]; then
        print_error "克隆 SillyTavern 失败。"
        return 1
    fi
    print_info "SillyTavern 克隆完成。"
    return 0
}

install_sillytavern_modules() {
    if [ ! -d "$ST_DIR" ]; then
        print_error "SillyTavern 目录 ($ST_DIR) 不存在。无法安装模块。"
        return 1
    fi
    print_info "正在进入 $ST_DIR 并安装 Node.js 模块..."
    cd "$ST_DIR" || { print_error "无法进入目录 $ST_DIR"; return 1; }
    if [ -f "package-lock.json" ]; then
      npm ci # 更快更可靠如果 lock 文件存在
    else
      npm install
    fi
    if [ $? -ne 0 ]; then
        print_error "npm install/ci 失败。"
        cd "$HOME"
        return 1
    fi
    cd "$HOME"
    print_info "SillyTavern Node.js 模块安装完成。"
    return 0
}

start_sillytavern() {
    if [ ! -f "$ST_DIR/server.js" ]; then
        print_error "SillyTavern 未安装或安装不完整。请尝试重新安装 (选项 2)。"
        return
    fi
    print_info "正在启动 SillyTavern..."
    print_info "请在浏览器中访问: http://localhost:8000 (或其他指定端口)"
    print_info "按 Ctrl+C 停止 SillyTavern。"
    cd "$ST_DIR" || { print_error "无法进入目录 $ST_DIR"; exit 1; }
    node server.js
    cd "$HOME"
}

update_sillytavern() {
    if [ ! -d "$ST_DIR/.git" ]; then
        print_error "SillyTavern 目录 ($ST_DIR) 不是一个 Git 仓库。无法更新。"
        print_info "请尝试重新安装 (选项 2)。"
        return
    fi
    print_info "正在更新 SillyTavern..."
    cd "$ST_DIR" || { print_error "无法进入目录 $ST_DIR"; exit 1; }
    git pull
    if [ $? -ne 0 ]; then
        print_error "git pull 失败。请检查网络连接或手动解决冲突。"
    else
        print_info "SillyTavern 更新成功，正在重新安装/更新依赖..."
        if [ -f "package-lock.json" ]; then
            npm ci
        else
            npm install
        fi
        if [ $? -ne 0 ]; then
            print_error "依赖更新失败。"
        else
            print_info "依赖更新完成。"
        fi
    fi
    cd "$HOME"
}

reinstall_sillytavern() {
    print_warn "这将删除现有的 SillyTavern 目录并重新安装。"
    read -p "确定要继续吗? (y/N): " confirm
    if [[ "$confirm" =~ ^[Yy]$ ]]; then
        print_info "正在删除旧的 SillyTavern 目录: $ST_DIR"
        rm -rf "$ST_DIR"
        print_info "开始重新安装 SillyTavern..."
        install_dependencies && clone_sillytavern && install_sillytavern_modules
        if [ $? -eq 0 ]; then
            print_info "SillyTavern 重新安装完成。"
        else
            print_error "SillyTavern 重新安装过程中发生错误。"
        fi
    else
        print_info "重新安装已取消。"
    fi
}

show_menu() {
    # 检查是否从 .bashrc/.zshrc 自动启动，如果是，可能不需要清屏
    # 不过对于菜单来说，清屏通常更好
    clear
    echo -e "${C_GREEN}===========================================${C_NC}"
    echo -e "${C_YELLOW}  SillyTavern Termux 管理脚本 v0.1 ${C_NC}"
    echo -e "${C_GREEN}===========================================${C_NC}"
    echo "版权: spacesouks | 更新: 2025.06.23"
    echo ""
    echo -e "${C_CYAN}请选择操作 (直接按 Enter 启动 SillyTavern):${C_NC}"
    echo "  0. 启动 SillyTavern"
    echo "  1. 更新 SillyTavern"
    echo "  2. 重新安装 SillyTavern"
    echo "  3. ${C_YELLOW}暂时退出脚本 (返回Termux提示符)${C_NC}"
    echo "  4. 加入官方QQ群聊 (1049034520)"
    echo "  5. 进入官方API服务站 (apo.blfire.ggff.net)"
    echo "  6. 加入官方云酒馆 (www.spacesouls.com)"
    echo "  8. 共享酒馆资源 (百度网盘)"
    echo "  9. ${C_RED}完全退出并显示警告 (下次Termux启动时仍会显示此菜单)${C_NC}"
    echo ""
    echo -e "${C_RED}警告: 本脚本仅用于学习交流，请勿用于违法犯罪活动。下载之后24小时内立刻删除。${C_NC}"
    echo "-------------------------------------------"
    read -p "输入选项数字: " choice

    case "$choice" in
        ""|0) start_sillytavern ;;
        1) update_sillytavern ;;
        2) reinstall_sillytavern ;;
        3) print_info "已退出脚本。您现在位于Termux提示符。"; exit 0 ;; # 关键：退出脚本，让.bashrc继续
        4) open_url "http://qm.qq.com/cgi-bin/qm/qr?_wv=1027&k=pnLV0g26al2DQuydG7gLMIpRVaqTYnbR&authKey=kqHesF8GZS9QE1N%2BdrVcTLCKufXfwFl%2BGqXQDZ8AhjFXH3ty1Acx8BKd1oTYi7W%2F&noverify=0&group_code=1049034520" ;;
        5) open_url "https://apo.blfire.ggff.net" ;;
        6) open_url "http://www.spacesouls.com" ;;
        8) open_url "https://pan.baidu.com/s/1zFfRWVx0WcBFWYUo5THqmw?pwd=96g2" ;;
        9)
            clear
            echo -e "${C_RED}==================== 重要警告 ====================${C_NC}"
            echo -e "${C_YELLOW}本脚本及 SillyTavern 仅用于学习和技术交流目的。${C_NC}"
            echo -e "${C_YELLOW}严禁用于任何违反当地法律法规的活动。${C_NC}"
            echo -e "${C_YELLOW}使用者应对其所有行为负全部责任。${C_NC}"
            echo -e "${C_YELLOW}请在下载和使用后24小时内自行删除本脚本及相关内容。${C_NC}"
            echo -e "${C_RED}===============================================${C_NC}"
            echo "版权: spacesouks | 版本: 0.1 | 更新: 2025.06.23"
            exit 0 # 同样退出脚本
            ;;
        *) print_error "无效选项。" ;;
    esac

    # 如果不是退出选项，则操作完成后暂停并重新显示菜单
    if [[ "$choice" != "3" && "$choice" != "9" ]]; then
        read -p "按 Enter 返回主菜单..."
        show_menu # 循环显示菜单
    fi
}

# --- 首次运行设置 ---
initial_setup() {
    print_info "进行首次运行设置..."

    # 1. 将脚本自身复制到永久位置
    # $0 在 bash <(curl ...) 中可能是 /dev/fd/XX 或类似
    # 我们需要确保能正确读取当前执行的脚本内容
    print_info "正在将脚本安装到 $SCRIPT_SELF_PATH..."
    # 使用 cat <(cat "$0") 来处理可能的管道问题，确保读取脚本内容
    # 或者，如果 $0 是一个有效的文件描述符，直接 cat "$0" 应该也可以
    # 为了保险，可以使用更明确的方式，但通常 `cat "$0"` 在这种场景下是有效的
    # 如果脚本是通过 `bash <(curl ...)` 执行的, `$0` 实际上是 `bash` 或者一个指向脚本内容的文件描述符路径
    # 如果直接用 `cp "$0" "$SCRIPT_SELF_PATH"`，当$0为"bash"时会复制bash程序，这是错误的。
    # 我们需要复制的是被执行的脚本内容。
    # `cat /proc/$$/fd/0 > file` 是一个获取stdin的方法，但这里bash已经读取了脚本。
    # 最可靠的方法是让用户通过 curl 先下载再执行，或者脚本包含其自身内容的heredoc。
    # 对于 `bash <(curl ...)` 模式，`cat "$BASH_SOURCE"` 通常可以工作，或者通过一个临时文件。
    # 鉴于简易性，我们假设`cat "$0"`能工作，如果不行，则需要调整安装命令。
    #
    # 更稳妥的复制方法：确保目录存在，然后复制。
    # $BASH_SOURCE[0] 在 source 时是脚本路径，直接执行时也是脚本路径。
    # 当通过 `bash <(curl ...)` 执行时，$BASH_SOURCE[0] 通常是 `/dev/fd/63` 这样的形式，指向脚本内容。
    mkdir -p "$(dirname "$SCRIPT_SELF_PATH")"
    cat "${BASH_SOURCE[0]}" > "$SCRIPT_SELF_PATH"
    if [ $? -ne 0 ]; then
        print_error "无法将脚本复制到 $SCRIPT_SELF_PATH。请检查权限。"
        print_warn "你可以尝试手动下载脚本到 $SCRIPT_SELF_PATH 并赋予执行权限，然后重新运行。"
        exit 1
    fi
    chmod +x "$SCRIPT_SELF_PATH"
    print_info "脚本已安装到 $SCRIPT_SELF_PATH 并设为可执行。"

    # 2. 添加到 .bashrc 或 .zshrc 实现自动启动
    RC_FILE=""
    SHELL_CONFIG_INFO=""
    if [ -f "$HOME/.bashrc" ]; then
        RC_FILE="$HOME/.bashrc"
        SHELL_CONFIG_INFO="bashrc"
    elif [ -f "$HOME/.zshrc" ]; then
        RC_FILE="$HOME/.zshrc"
        SHELL_CONFIG_INFO="zshrc"
    fi

    if [ -n "$RC_FILE" ]; then
        if ! grep -qF "$RC_FILE_ADDITION_TAG" "$RC_FILE"; then # -F 精确匹配字符串
            print_info "正在添加脚本到 $RC_FILE 以实现自动启动..."
            {
                echo -e "\n$RC_FILE_ADDITION_TAG"
                echo "$SCRIPT_SELF_PATH # Remove this line to disable auto-start"
            } >> "$RC_FILE"
            print_info "已添加到 $RC_FILE。"
            print_warn "请运行 'source $RC_FILE' 或重启 Termux 以使自动启动生效。"
        else
            print_info "脚本已配置在 $RC_FILE 中自动启动。"
        fi
    else
        print_warn "未找到 .bashrc 或 .zshrc。无法配置自动启动。"
        print_info "您需要手动将以下行添加到您的shell配置文件中以实现自动启动："
        print_info "$SCRIPT_SELF_PATH"
    fi

    # 3. 安装 SillyTavern 核心组件
    print_info "开始安装 SillyTavern 核心组件..."
    install_dependencies && clone_sillytavern && install_sillytavern_modules
    if [ $? -ne 0 ]; then
        print_error "SillyTavern 核心组件安装失败。"
        print_warn "你可以尝试从菜单中选择 '重新安装 SillyTavern'。"
        # 不退出，让用户看到菜单
    else
        print_info "SillyTavern 核心组件安装完成！"
    fi

    echo ""
    print_info "首次设置完成！下次启动Termux时，此菜单将自动显示。"
    print_info "按 Enter 继续进入菜单..."
    read -r
}

# --- 主逻辑 ---
check_command "git" "critical"
check_command "node" "critical"
check_command "npm" "critical"

# 判断是否是首次运行 (通过检查 $SCRIPT_SELF_PATH 是否存在且内容是否和当前脚本一致)
# 或者更简单：如果当前执行的脚本路径不是 $SCRIPT_SELF_PATH，则认为是首次通过curl运行
# 或者 $SCRIPT_SELF_PATH 文件不存在
if [ ! -f "$SCRIPT_SELF_PATH" ] || [ "$(realpath "$0")" != "$(realpath "$SCRIPT_SELF_PATH" 2>/dev/null)" ]; then
    # 如果 SCRIPT_SELF_PATH 存在但路径不匹配，可能是用户从别处运行了已安装的脚本的副本，
    # 或者就是通过 curl 运行的。
    # 如果 SCRIPT_SELF_PATH 不存在，那肯定是首次。
    initial_setup
    # initial_setup 后会提示按 Enter，然后自然会进入 show_menu
fi

# 无论如何，最后都显示菜单 (除非 initial_setup 中途退出)
show_menu
