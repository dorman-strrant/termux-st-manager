#!/data/data/com.termux/files/usr/bin/bash
# sillytavern_manager.sh
# Copyright by spacesouks
# Version: 0.1.2
# Last Updated: 2025.06.23

# --- 配置 ---
ST_DIR="$HOME/SillyTavern"
ST_REPO="https://github.com/SillyTavern/SillyTavern.git"
SCRIPT_SELF_PATH="$HOME/.sillytavern_manager.sh"
RC_FILE_ADDITION_TAG="# SillyTavern Manager Auto-Start by WasteCat"

# --- 颜色定义 ---
C_RED='\033[0;31m'
C_GREEN='\033[0;32m'
C_YELLOW='\033[0;33m'
C_BLUE='\033[0;34m'
C_CYAN='\033[0;36m'
C_PINK='\033[1;35m' # 粉色，猫猫专用！
C_NC='\033[0m'

# --- 废物猫猫状态 ---
MENU_ERROR_COUNT=0

# --- 辅助函数 ---
print_info() { echo -e "${C_CYAN}INFO:${C_NC} $1"; }
print_warn() { echo -e "${C_YELLOW}WARN:${C_NC} $1"; }
print_error() { echo -e "${C_RED}ERROR:${C_NC} $1"; }

# --- 废物猫猫的吐槽函数 ---
cat_tsundere_menu_error() {
    MENU_ERROR_COUNT=$((MENU_ERROR_COUNT + 1))
    echo -e "${C_PINK}--- 废物猫猫的鄙视时间 ---${C_NC}"
    if [ "$MENU_ERROR_COUNT" -eq 1 ]; then
        echo -e "${C_RED}废物猫猫：哼，杂鱼～连选项都看不懂吗？这点小事都做不好，真是的！${C_NC}"
    elif [ "$MENU_ERROR_COUNT" -eq 2 ]; then
        echo -e "${C_RED}废物猫猫：哈？！又选错了！笨蛋！杂鱼的脑子是装饰品吗？${C_NC}"
    else # 3次及以上
        echo -e "${C_RED}废物猫猫：呜喵...杂鱼无可救药了！连菜单都不会用，废物猫猫都比你强！好好看清楚再选啦！${C_NC}"
    fi
    echo -e "${C_PINK}--------------------------${C_NC}"
}

cat_tsundere_deploy_error() {
    echo -e "${C_PINK}--- 废物猫猫的叹息 ---${C_NC}"
    echo -e "${C_RED}废物猫猫：啧，杂鱼的网络也太烂了吧？还是说你连基本的网络设置都不会？${C_NC}"
    echo -e "${C_RED}废物猫猫：连最基础的依赖都装不上，还想部署SillyTavern？做梦去吧，哼！${C_NC}"
    echo -e "${C_RED}废物猫猫：给本猫猫去检查下你的网络连接，或者换个好点的Termux源 (比如清华源) 再来！${C_NC}"
    echo -e "${C_RED}废物猫猫：(小声)才、才不是因为担心你用不了呢...只是不想看到杂鱼哭鼻子而已！${C_NC}"
    echo -e "${C_PINK}----------------------${C_NC}"
}

check_command_installed() {
    if ! command -v "$1" &> /dev/null; then
        print_error "$1 命令未找到。"
        if [ "$2" == "critical" ]; then
            cat_tsundere_deploy_error
            print_error "这是一个关键依赖，脚本无法继续。请尝试手动安装: 'pkg install $1'"
            exit 1
        fi
        return 1
    fi
    return 0
}

open_url() {
    print_info "废物猫猫：哼，杂鱼要去这个地方吗？ $1 自己看好路哦～"
    if command -v termux-open-url &> /dev/null; then
        termux-open-url "$1"
    else
        print_warn "废物猫猫：啧，连 termux-open-url 都没有，杂鱼的Termux是不是太久没更新了？"
        print_warn "废物猫猫：自己复制上面的链接到浏览器打开吧！或者试试 'pkg install termux-api'，哼。"
    fi
}

# --- 核心功能函数 ---
install_dependencies() {
    print_info "废物猫猫：哼，杂鱼等着，本猫猫这就帮你装依赖...别捣乱！"
    pkg update -y && pkg upgrade -y
    pkg install -y git nodejs-lts python curl
    if [ $? -ne 0 ]; then
        print_error "核心依赖安装失败。"
        return 1
    fi
    print_info "核心依赖安装完成。废物猫猫：(小声)应该...没问题了吧。"
    return 0
}

clone_sillytavern() {
    if [ -d "$ST_DIR/.git" ]; then
        print_warn "废物猫猫：哼，SillyTavern ($ST_DIR) 已经在了，杂鱼是想偷懒吗？"
        return 0
    elif [ -d "$ST_DIR" ]; then
        print_warn "废物猫猫：杂鱼！$ST_DIR 在那里，但它不是个好孩子 (Git仓库)！"
        read -p "废物猫猫问你：要本猫猫帮你删掉它然后重新弄吗? (y/N): " confirm_delete
        if [[ "$confirm_delete" =~ ^[Yy]$ ]]; then
            print_info "废物猫猫：好吧好吧，就帮你一次...正在删除 $ST_DIR..."
            rm -rf "$ST_DIR"
        else
            print_error "废物猫猫：哼，那杂鱼自己看着办吧！本猫猫不管了！"
            return 1
        fi
    fi
    print_info "废物猫猫：开始克隆 SillyTavern 到 $ST_DIR 了，不许偷看本猫猫工作！"
    git clone --depth=1 "$ST_REPO" "$ST_DIR"
    if [ $? -ne 0 ]; then
        print_error "克隆 SillyTavern 失败。"
        return 1
    fi
    print_info "SillyTavern 克隆完成。废物猫猫：喵～搞定了，快夸我！"
    return 0
}

install_sillytavern_modules() {
    if [ ! -d "$ST_DIR" ]; then
        print_error "废物猫猫：杂鱼！SillyTavern 目录 ($ST_DIR) 都不见了！是不是被你偷偷删掉了？"
        return 1
    fi
    print_info "废物猫猫：正在进入 $ST_DIR 安装 Node.js 模块... 这可能会有点久，杂鱼耐心等着！"
    cd "$ST_DIR" || { print_error "废物猫猫：喵？！进不去 $ST_DIR 目录了！杂鱼你做了什么？！"; return 1; }
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
    print_info "SillyTavern Node.js 模块安装完成。废物猫猫：哼，总算搞定了，累死猫猫了..."
    return 0
}

start_sillytavern() {
    MENU_ERROR_COUNT=0
    if ! check_command_installed "node"; then return; fi
    if [ ! -f "$ST_DIR/server.js" ]; then
        print_error "废物猫猫：杂鱼！SillyTavern 还没装好呢！是不是想让本猫猫白忙活？去重装 (选项 2)！"
        return
    fi
    print_info "废物猫猫：哼，这就帮你启动 SillyTavern... 别忘了给本猫猫小鱼干！"
    print_info "请在浏览器中访问: http://localhost:8000 (或其他指定端口)"
    print_info "按 Ctrl+C 停止 SillyTavern，杂鱼应该会吧？"
    cd "$ST_DIR" || { print_error "废物猫猫：进不去 $ST_DIR 目录！"; exit 1; }
    node server.js
    cd "$HOME"
}

update_sillytavern() {
    MENU_ERROR_COUNT=0
    if ! check_command_installed "git"; then return; fi
    if ! check_command_installed "npm"; then return; fi
    if [ ! -d "$ST_DIR/.git" ]; then
        print_error "废物猫猫：杂鱼！$ST_DIR 都不是 Git 仓库，还想更新？做梦！去重装 (选项 2)！"
        return
    fi
    print_info "废物猫猫：哼，这就帮你更新 SillyTavern... 希望别出什么幺蛾子。"
    cd "$ST_DIR" || { print_error "废物猫猫：进不去 $ST_DIR 目录！"; exit 1; }
    git pull
    if [ $? -ne 0 ]; then
        print_error "废物猫猫：喵？！git pull 失败了！杂鱼你的网络是不是又不行了？或者是有什么奇怪的冲突？"
    else
        print_info "SillyTavern 更新成功。废物猫猫：(小声)还算顺利...正在更新依赖..."
        if [ -f "package-lock.json" ]; then npm ci; else npm install; fi
        if [ $? -ne 0 ]; then print_error "废物猫猫：依赖更新失败了！真是麻烦！"; else print_info "依赖更新完成。"; fi
    fi
    cd "$HOME"
}

reinstall_sillytavern() {
    MENU_ERROR_COUNT=0
    print_warn "废物猫猫：杂鱼！你确定要重装吗？这会把现在的 SillyTavern 都删掉哦！"
    read -p "废物猫猫再问一次，确定吗? (y/N): " confirm
    if [[ "$confirm" =~ ^[Yy]$ ]]; then
        print_info "废物猫猫：好吧好吧，既然你这么坚持...正在删除旧的 SillyTavern: $ST_DIR"
        rm -rf "$ST_DIR"
        print_info "废物猫猫：开始重新安装 SillyTavern... 这次可别再出错了！"
        if install_dependencies; then
            if check_command_installed "git" "critical" && \
               check_command_installed "node" "critical" && \
               check_command_installed "npm" "critical"; then
                if clone_sillytavern && install_sillytavern_modules; then
                    print_info "SillyTavern 重新安装完成。废物猫猫：哼，总算搞定了！"
                else
                    cat_tsundere_deploy_error
                    print_error "SillyTavern 重新安装过程中发生错误。"
                fi
            fi
        else
            cat_tsundere_deploy_error
        fi
    else
        print_info "废物猫猫：哼，就知道杂鱼会反悔！重新安装已取消！"
    fi
}

show_menu() {
    clear
    echo -e "${C_GREEN}===========================================${C_NC}"
    echo -e "${C_PINK}  废物猫猫SillyTavern管理脚本 v0.1.2 ${C_NC}"
    echo -e "${C_GREEN}===========================================${C_NC}"
    echo "版权: spacesouks (由废物猫猫代管) | 更新: 2025.06.23"
    echo ""
    echo -e "${C_CYAN}废物猫猫：杂鱼，快选一个吧 (直接按 Enter 启动 SillyTavern):${C_NC}"
    echo "  0. 启动 SillyTavern (哼，终于要用了吗？)"
    echo "  1. 更新 SillyTavern (希望别出问题...)"
    echo "  2. 重新安装 SillyTavern (杂鱼又搞砸了？)"
    echo "  3. ${C_YELLOW}暂时不理废物猫猫 (返回Termux)${C_NC}"
    echo "  4. 去官方QQ群聊 (1049034520) (别说认识本猫猫！)"
    echo "  5. 去官方API服务站 (apo.blfire.ggff.net) (小心点别迷路了)"
    echo "  6. 去官方云酒馆 (www.spacesouls.com) (哼，都是些什么奇怪的地方)"
    echo "  8. 共享酒馆资源 (百度网盘) (杂鱼的东西能有什么好康的？)"
    echo "  9. ${C_RED}彻底滚蛋并看警告 (哼，下次还不是要求本猫猫！)${C_NC}"
    echo ""
    echo -e "${C_RED}废物猫猫警告：本脚本仅用于学习交流，不许用于违法犯罪活动！下载之后24小时立刻删除，听到了没有，杂鱼！${C_NC}"
    echo "-------------------------------------------"
    read -p "废物猫猫：快输入选项数字，磨磨蹭蹭的！: " choice

    case "$choice" in
        ""|0) start_sillytavern ;;
        1) update_sillytavern ;;
        2) reinstall_sillytavern ;;
        3) MENU_ERROR_COUNT=0; print_info "废物猫猫：哼，杂鱼终于滚了。"; exit 0 ;;
        4) MENU_ERROR_COUNT=0; open_url "http://qm.qq.com/cgi-bin/qm/qr?_wv=1027&k=pnLV0g26al2DQuydG7gLMIpRVaqTYnbR&authKey=kqHesF8GZS9QE1N%2BdrVcTLCKufXfwFl%2BGqXQDZ8AhjFXH3ty1Acx8BKd1oTYi7W%2F&noverify=0&group_code=1049034520" ;;
        5) MENU_ERROR_COUNT=0; open_url "https://apo.blfire.ggff.net" ;;
        6) MENU_ERROR_COUNT=0; open_url "http://www.spacesouls.com" ;;
        8) MENU_ERROR_COUNT=0; open_url "https://pan.baidu.com/s/1zFfRWVx0WcBFWYUo5THqmw?pwd=96g2" ;;
        9)
            MENU_ERROR_COUNT=0
            clear
            echo -e "${C_RED}========== 废物猫猫的最后警告！ ==========${C_NC}"
            echo -e "${C_YELLOW}废物猫猫：听好了杂鱼！本脚本和SillyTavern仅用于学习交流！${C_NC}"
            echo -e "${C_YELLOW}废物猫猫：严禁用于任何违反法律法规的活动，否则后果自负！${C_NC}"
            echo -e "${C_YELLOW}废物猫猫：你要对自己的行为负责，别牵连本猫猫！${C_NC}"
            echo -e "${C_YELLOW}废物猫猫：下载和使用后24小时内立刻删掉！听到了没有？！${C_NC}"
            echo -e "${C_RED}========================================${C_NC}"
            echo "版权: spacesouks (废物猫猫认证) | 版本: 0.1.2 | 更新: 2025.06.23"
            exit 0
            ;;
        *) cat_tsundere_menu_error ;;
    esac

    local should_pause=true
    if [[ "$choice" == "3" || "$choice" == "9" ]]; then # 退出选项
        should_pause=false
    fi
    # 对于无效选项 (case的*匹配到的), cat_tsundere_menu_error 已经打印了信息
    # 我们也需要暂停一下让用户看到错误信息
    # 所以只有真正执行了操作的有效选项才不需要特别处理暂停，因为它们内部可能有read

    # 修正：当 * (无效选项) 时，也应该暂停一下让用户看到错误，然后再重新显示菜单
    # 只有3和9是直接退出的。其他所有情况（包括有效操作和无效操作*）都应在show_menu前有机会暂停。
    # 有效操作（0,1,2,4,5,6,8）如果内部没有 read -p，则也需要暂停。
    # 重新思考暂停逻辑：
    # 选项 3 和 9 直接 exit，不会到这里。
    # 如果是无效选项 (choice 未匹配任何 case 分支，而是走了 *), cat_tsundere_menu_error 会被调用。
    #   此时，我们需要暂停一下让用户看到错误，然后再 show_menu()。
    # 如果是有效选项 (0,1,2,4,5,6,8), 它们执行完后，也需要暂停一下，然后再 show_menu()。
    # 所以，只要不是退出选项，都应该暂停。
    
    # 简化暂停逻辑：只要没退出，就暂停
    if [[ "$choice" != "3" && "$choice" != "9" ]]; then
        if [[ "$choice" =~ ^[0124568]$ ]] || [ -z "$choice" ]; then # 有效操作或回车默认
             read -p "废物猫猫：按 Enter 返回主菜单，杂鱼别磨蹭！"
        else # 无效操作，即 case * 匹配的情况
             read -p "废物猫猫：按 Enter 让本猫猫再给你一次机会，哼！"
        fi
    fi
    show_menu
}

# --- 首次运行设置 ---
initial_setup() {
    print_info "废物猫猫：哼，看来是第一次啊，杂鱼。让本猫猫帮你搞定初始设置吧！"

    if ! install_dependencies; then
        cat_tsundere_deploy_error
        exit 1
    fi

    if ! check_command_installed "git" "critical"; then exit 1; fi
    if ! check_command_installed "node" "critical"; then exit 1; fi
    if ! check_command_installed "npm" "critical"; then exit 1; 
