#!/data/data/com.termux/files/usr/bin/bash
# sillytavern_manager.sh
# Copyright by spacesouks
# Version: 0.1.1 # 版本号小幅更新
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

check_command_installed() {
    if ! command -v "$1" &> /dev/null; then
        print_error "$1 命令未找到。脚本依赖此命令。"
        if [ "$2" == "critical" ]; then
            print_error "这是一个关键依赖，脚本无法继续。请尝试手动安装: 'pkg install $1'"
            exit 1
        fi
        return 1
    fi
    print_info "$1 命令已找到。"
    return 0
}

open_url() {
    print_info "正在尝试打开链接: $1"
    # termux-open-url 可能在非常初始的Termux环境中不存在，所以这里不作为关键依赖检查
    if command -v termux-open-url &> /dev/null; then
        termux-open-url "$1"
    else
        print_warn "termux-open-url 命令不可用。请手动在浏览器中打开以上链接。"
        print_warn "你可以尝试运行 'pkg install termux-api' 来安装它。"
    fi
}

# --- 核心功能函数 ---
install_dependencies() {
    print_info "正在更新软件包列表并安装核心依赖 (git, nodejs-lts, python)..."
    # 确保 pkg 本身是最新的
    pkg update -y && pkg upgrade -y
    # 安装 curl 是为了确保脚本后续如果需要（虽然此脚本目前不需要再次curl）或用户其他操作方便
    pkg install -y git nodejs-lts python curl
    if [ $? -ne 0 ]; then
        print_error "核心依赖安装失败。请检查网络和Termux源设置。"
        return 1
    fi
    print_info "核心依赖安装完成。"
    return 0
}

clone_sillytavern() {
    # 此函数前应确保 git 已安装
    if [ -d "$ST_DIR/.git" ]; then
        print_warn "SillyTavern 仓库目录已存在 ($ST_DIR)。跳过克隆。"
        return 0
    elif [ -d "$ST_DIR" ]; then
        print_warn "目录 $ST_DIR 已存在但不是一个有效的Git仓库。"
        read -p "是否删除现有目录 $ST_DIR 并重新克隆? (y/N): " confirm_delete
        if [[ "$confirm_delete" =~ ^[Yy]$ ]]; then
            print_info "正在删除 $ST_DIR..."
            rm -rf "$ST_DIR"
        else
            print_error "克隆取消。请先处理 $ST_DIR。"
            return 1
        fi
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
    # 此函数前应确保 node 和 npm 已安装
    if [ ! -d "$ST_DIR" ]; then
        print_error "SillyTavern 目录 ($ST_DIR) 不存在。无法安装模块。"
        return 1
    fi
    print_info "正在进入 $ST_DIR 并安装 Node.js 模块..."
    cd "$ST_DIR" || { print_error "无法进入目录 $ST_DIR"; return 1; }
    if [ -f "package-lock.json" ]; then
      npm ci
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
    if ! check_command_installed "node"; then return; fi
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
    if ! check_command_installed "git"; then return; fi
    if ! check_command_installed "npm"; then return; fi
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
        # 重新安装时，也应该确保依赖是最新的
        if install_dependencies; then
            if check_command_installed "git" "critical" && \
               check_command_installed "node" "critical" && \
               check_command_installed "npm" "critical"; then
                clone_sillytavern && install_sillytavern_modules
                if [ $? -eq 0 ]; then
                    print_info "SillyTavern 重新安装完成。"
                else
                    print_error "SillyTavern 重新安装过程中发生错误。"
                fi
            else
                print_error "关键依赖在重新安装前未能成功验证。"
            fi
        else
            print_error "依赖安装失败，无法继续重新安装。"
        fi
    else
        print_info "重新安装已取消。"
    fi
}

show_menu() {
    clear
    echo -e "${C_GREEN}===========================================${C_NC}"
    echo -e "${C_YELLOW}  SillyTavern Termux 管理脚本 v0.1.1 ${C_NC}"
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
        3) print_info "已退出脚本。您现在位于Termux提示符。"; exit 0 ;;
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
            echo "版权: spacesouks | 版本: 0.1.1 | 更新: 2025.06.23"
            exit 0
            ;;
        *) print_error "无效选项。" ;;
    esac

    if [[ "$choice" != "3" && "$choice" != "9" ]]; then
        read -p "按 Enter 返回主菜单..."
        show_menu
    fi
}

# --- 首次运行设置 ---
initial_setup() {
    print_info "进行首次运行设置..."

    # 0. 首先安装基础依赖
    if ! install_dependencies; then
        print_error "基础依赖安装失败。脚本无法继续进行首次设置。"
        print_warn "请检查您的网络连接和Termux软件源设置，然后重试。"
        exit 1
    fi

    # 0.1 验证关键依赖是否已成功安装
    if ! check_command_installed "git" "critical"; then exit 1; fi
    if ! check_command_installed "node" "critical"; then exit 1; fi
    if ! check_command_installed "npm" "critical"; then exit 1; fi
    # python 通常随 nodejs-lts 安装，这里可以不强制检查，或设为非 critical

    # 1. 将脚本自身复制到永久位置
    print_info "正在将脚本安装到 $SCRIPT_SELF_PATH..."
    mkdir -p "$(dirname "$SCRIPT_SELF_PATH")"
    cat "${BASH_SOURCE[0]}" > "$SCRIPT_SELF_PATH"
    if [ $? -ne 0 ]; then
        print_error "无法将脚本复制到 $SCRIPT_SELF_PATH。请检查权限。"
        exit 1
    fi
    chmod +x "$SCRIPT_SELF_PATH"
    print_info "脚本已安装到 $SCRIPT_SELF_PATH 并设为可执行。"

    # 2. 添加到 .bashrc 或 .zshrc 实现自动启动
    RC_FILE=""
    if [ -f "$HOME/.bashrc" ]; then RC_FILE="$HOME/.bashrc"; fi
    # zshrc 的检查可以后加，如果用户普遍使用的话
    # elif [ -f "$HOME/.zshrc" ]; then RC_FILE="$HOME/.zshrc"; fi

    if [ -n "$RC_FILE" ]; then
        if ! grep -qF "$RC_FILE_ADDITION_TAG" "$RC_FILE"; then
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
        print_warn "未找到 .bashrc。无法配置自动启动。"
        print_info "您需要手动将以下行添加到您的shell配置文件中以实现自动启动："
        print_info "$SCRIPT_SELF_PATH"
    fi

    # 3. 安装 SillyTavern 核心组件
    print_info "开始安装 SillyTavern 核心组件..."
    # 依赖已在步骤0安装和验证，这里直接克隆和安装模块
    if clone_sillytavern && install_sillytavern_modules; then
        print_info "SillyTavern 核心组件安装完成！"
    else
        print_error "SillyTavern 核心组件安装失败。"
        print_warn "你可以尝试从菜单中选择 '重新安装 SillyTavern'。"
    fi

    echo ""
    print_info "首次设置完成！下次启动Termux时，此菜单将自动显示。"
    print_info "按 Enter 继续进入菜单..."
    read -r
}

# --- 主逻辑 ---

# 判断是否是首次通过 curl | bash 运行
# 主要通过检查 $SCRIPT_SELF_PATH 是否存在且内容是否和当前脚本一致来判断
# 如果 $0 (当前执行的脚本) 不是 $SCRIPT_SELF_PATH (目标安装路径)，则认为是首次运行或从非标准路径运行
IS_FIRST_CURL_RUN=false
if [ ! -f "$SCRIPT_SELF_PATH" ]; then
    # 目标脚本不存在，肯定是首次curl运行
    IS_FIRST_CURL_RUN=true
else
    # 目标脚本存在，比较内容判断是否是curl运行了一个新版本来覆盖旧的
    # 或者判断执行路径是否为 $SCRIPT_SELF_PATH
    # realpath "$0" 可能因环境不存在，更简单的方式是直接比较路径字符串
    # BASH_SOURCE[0] 在 curl <() 时是 /dev/fd/XXX
    current_script_path="${BASH_SOURCE[0]}"
    # 如果当前脚本路径不是固定的安装路径，则认为是curl运行
    if [ "$current_script_path" != "$SCRIPT_SELF_PATH" ]; then
        # 进一步检查内容是否相同，避免用户只是在别处运行了已安装的脚本
        # 但考虑到复杂性，简单地认为路径不同就是需要执行 initial_setup 更直接
        # 或者用户就是想通过curl来更新并重新执行initial_setup的部分逻辑
        # 这种情况下，initial_setup 内部的逻辑需要能处理已存在的情况（例如 .bashrc 的修改）
        IS_FIRST_CURL_RUN=true
    fi
fi


if [ "$IS_FIRST_CURL_RUN" = true ]; then
    initial_setup
    # initial_setup 后会提示按 Enter，然后自然会进入 show_menu
    # 如果 initial_setup 失败退出，则不会执行到 show_menu
else
    # 非首次curl运行 (即脚本是从 $SCRIPT_SELF_PATH 启动的，通常是.bashrc自动启动)
    # 此时才进行严格的依赖检查，因为这些依赖应该在initial_setup时已安装
    if ! check_command_installed "git" "critical"; then exit 1; fi
    if ! check_command_installed "node" "critical"; then exit 1; fi
    if ! check_command_installed "npm" "critical"; then exit 1; fi
    # python 检查可选
fi

# 无论如何，最后都显示菜单 (除非 initial_setup 或上述检查中途退出)
show_menu
