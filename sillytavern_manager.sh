#!/usr/bin/env bash

# ==============================================================================
#                 SillyTavern 纯粹部署管理器 (SillyTavern Pure Manager)
# ==============================================================================
# 版权所有 (Copyright): 废物猫猫 (Useless Kitty)
# 版本号 (Version): 0.1
# 上次更新 (Last Updated): 2025.06.27
#
# 哼，杂鱼，使用本脚本前，最好确保你已经安装了 git 和 nodejs 哦！
# 在Termux里可以输入：pkg install git nodejs-lts
# ==============================================================================

# --- 颜色定义，让本猫猫的发言更显眼！ ---
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
NC='\033[0m' # 没有颜色

# --- 脚本变量 ---
SillyTavern_Dir="SillyTavern"
SillyTavern_Repo="https://github.com/SillyTavern/SillyTavern.git"

# --- 语气词库，让你感受本猫猫的情绪！ ---
# Level 1: 轻微的傲娇
TAUNT_L1=(
    "哼，杂鱼，看好了，本猫猫要开始工作了！"
    "真是的，这种事还要本猫猫亲自动手……"
    "开始了哦，给我好好看着！别眨眼！"
    "喂，你这家伙，可别拖后腿啊！"
)
# Level 2: 不耐烦的警告
TAUNT_L2=(
    "啧，怎么这么慢啊！你的网络是不是和你的脑子一样转不动了？"
    "杂鱼，你的网络怎么这么差劲… 克隆失败了！本猫猫可要生气了！"
    "喂！你到底会不会操作啊？这点小事都做不好吗？"
    "真是的，一点耐心都没有，本猫猫都快被你气死了！"
)
# Level 3: 极度愤怒（但还是会帮你）
TAUNT_L3=(
    "够了！你这个笨蛋！再这样下去本猫猫就要离家出走了！"
    "烦死了烦死了！你自己看着办吧！本猫猫不管了！（但还是会继续运行）"
    "你！简直是无可救药的杂鱼！本猫猫要闹脾气了！哼！"
)

# 随机选择一个语气词
function taunt() {
    local level=$1
    case $level in
        1) eval "echo -e \"${MAGENTA}\${TAUNT_L1[\$((RANDOM % \${#TAUNT_L1[@]}))]}${NC}\"" ;;
        2) eval "echo -e \"${RED}\${TAUNT_L2[\$((RANDOM % \${#TAUNT_L2[@]}))]}${NC}\"" ;;
        3) eval "echo -e \"${RED}\${TAUNT_L3[\$((RANDOM % \${#TAUNT_L3[@]}))]}${NC}\"" ;;
    esac
}

# --- 功能函数 ---

# 检查依赖
function check_dependencies() {
    echo -e "${CYAN}本猫猫正在检查你这破机器缺了什么...${NC}"
    local missing=0
    for cmd in git node npm; do
        if ! command -v $cmd &> /dev/null; then
            echo -e "${RED}喂！杂鱼！你连 '$cmd' 都没有装，还想运行？快去装好再来！${NC}"
            echo -e "${YELLOW}在Termux里可以试试输入 'pkg install $cmd' 哦，笨蛋！${NC}"
            missing=1
        fi
    done
    if [ $missing -eq 1 ]; then
        exit 1
    fi
    echo -e "${GREEN}哼，算你走运，该有的都有了。${NC}"
    sleep 1
}

# 部署SillyTavern
function install_sillytavern() {
    if [ -d "$SillyTavern_Dir" ]; then
        echo -e "${YELLOW}文件夹已经存在了，你这个笨蛋，是想让本猫猫重复劳动吗？${NC}"
        return
    fi

    taunt 1
    echo -e "${CYAN}正在从GitHub上把酒馆给你拖下来... 网络慢的话可不关本猫猫的事哦！${NC}"
    git clone "$SillyTavern_Repo"
    
    if [ $? -ne 0 ]; then
        taunt 2
        echo -e "${RED}克隆失败了！都怪你那破网络！${NC}"
        exit 1
    fi

    cd "$SillyTavern_Dir" || exit
    
    echo -e "${CYAN}依赖项安装中，这会很慢，给本猫猫老实等着！${NC}"
    npm install
    
    if [ $? -ne 0 ]; then
        taunt 3
        echo -e "${RED}安装依赖失败了！你这机器是有多垃圾啊？！${NC}"
        exit 1
    fi

    echo -e "${GREEN}哼...哼！总、总之是装好了啦！才、才不是为了你这个杂鱼呢！${NC}"
    cd ..
    echo -e "${YELLOW}按回车键返回菜单，快点！${NC}"
    read -r
}

# 启动SillyTavern
function start_sillytavern() {
    if [ ! -f "$SillyTavern_Dir/server.js" ]; then
        echo -e "${RED}喂，杂鱼！你还没安装酒馆呢！先给本猫猫选安装选项！${NC}"
        echo -e "${YELLOW}按回车键返回... 真是让人不省心。${NC}"
        read -r
        return
    fi
    
    cd "$SillyTavern_Dir" || exit
    taunt 1
    echo -e "${CYAN}酒馆启动！给本猫猫好好享受，然后记得感谢本猫猫！${NC}"
    node server.js
    cd ..
}

# 重装SillyTavern
function reinstall_sillytavern() {
    if [ ! -d "$SillyTavern_Dir" ]; then
        echo -e "${RED}笨蛋！你根本就没装，还谈什么重装啊！${NC}"
        echo -e "${YELLOW}按回车键返回，真是的...${NC}"
        read -r
        return
    fi

    echo -e "${YELLOW}你确定要重装？你这个笨蛋，之前的数据可就都没了哦！(y/n)${NC}"
    read -r -p "快回答本猫猫！> " confirm
    if [[ "$confirm" == [yY] || "$confirm" == [yY][eE][sS] ]]; then
        taunt 2
        echo -e "${RED}好吧好吧，既然你这么坚持... 删掉就删掉！后果自负！${NC}"
        rm -rf "$SillyTavern_Dir"
        install_sillytavern
    else
        echo -e "${GREEN}哼，算你识相，知道本猫猫的工作成果不能随便丢掉。${NC}"
        sleep 1
    fi
}

# 快捷更新
function update_sillytavern() {
    if [ ! -d "$SillyTavern_Dir" ]; then
        echo -e "${RED}你连装都没装，更新个什么劲啊，杂鱼！${NC}"
        echo -e "${YELLOW}按回车键返回。${NC}"
        read -r
        return
    fi

    cd "$SillyTavern_Dir" || exit
    taunt 1
    echo -e "${CYAN}真是的，又要更新... 给你这杂鱼更新一下，要心怀感激哦！${NC}"
    git pull
    
    if [ $? -ne 0 ]; then
        taunt 2
        echo -e "${RED}更新失败了！绝对是你网络的问题！${NC}"
    else
        echo -e "${GREEN}更新完毕！哼，本猫猫的功劳。${NC}"
    fi

    cd ..
    echo -e "${YELLOW}按回车键返回... 别磨磨蹭蹭的。${NC}"
    read -r
}

# 打开链接的函数 (兼容Termux)
function open_url() {
    local url=$1
    if command -v termux-open-url &> /dev/null; then
        termux-open-url "$url"
    else
        echo -e "${YELLOW}本猫猫没在你的破机器上找到 termux-open-url...${NC}"
        echo -e "${CYAN}你自己复制这个链接去浏览器打开吧，真是的，还要本猫猫提醒你。${NC}"
        echo -e "${GREEN}$url${NC}"
    fi
}

# 更多选项子菜单
function more_options_menu() {
    while true; do
        clear
        echo -e "${CYAN}======================================================${NC}"
        echo -e "${MAGENTA}                 废物猫猫的更多选项                 ${NC}"
        echo -e "${CYAN}======================================================${NC}"
        echo ""
        echo -e " 1. ${GREEN}快捷更新${NC}        - 哼，想更新就求本猫猫啊"
        echo -e " 2. ${GREEN}加入官方群聊${NC}    - 一群杂鱼的聚集地"
        echo -e " 3. ${GREEN}进入官方API服务站${NC}- API什么的，你应该懂吧？"
        echo -e " 4. ${GREEN}加入官方云酒馆${NC}  - 去别人的酒馆玩玩？"
        echo -e " 5. ${GREEN}共享酒馆资源${NC}    - 本猫猫珍藏的好东西，便宜你了"
        echo -e " 6. ${YELLOW}特别事项...${NC}     - 哼，只是让你看一下而已"
        echo ""
        echo -e " 0. ${RED}返回主菜单${NC}      - 逃跑是没用的，杂鱼！"
        echo ""
        echo -e "${CYAN}======================================================${NC}"
        read -r -p "$(echo -e ${YELLOW}"杂鱼，快选一个： "${NC})" choice

        case $choice in
            1) update_sillytavern ;;
            2) 
                echo -e "${CYAN}正在为你打开QQ群链接，加不进去可不关本猫猫的事哦...${NC}"
                open_url "http://qm.qq.com/cgi-bin/qm/qr?_wv=1027&k=pnLV0g26al2DQuydG7gLMIpRVaqTYnbR&authKey=kqHesF8GZS9QE1N%2BdrVcTLCKufXfwFl%2BGqXQDZ8AhjFXH3ty1Acx8BKd1oTYi7W%2F&noverify=0&group_code=1049034520"
                sleep 2
                ;;
            3)
                echo -e "${CYAN}API服务站，快去快回，别迷路了。${NC}"
                open_url "https://apo.blfire.ggff.net"
                sleep 2
                ;;
            4)
                echo -e "${CYAN}云酒馆... 哼，别玩得乐不思蜀，忘了本猫猫！${NC}"
                open_url "http://www.spacesouls.com"
                sleep 2
                ;;
            5)
                echo -e "${CYAN}资源给你了，密码是 96g2，要是忘了，你就是猪！${NC}"
                open_url "https://pan.baidu.com/s/1zFfRWVx0WcBFWYUo5THqmw?pwd=96g2"
                sleep 2
                ;;
            6)
                clear
                echo -e "${YELLOW}======================================================${NC}"
                echo -e "${MAGENTA}包月和购买永久ai，学生党勿扰，如有打扰，还望海涵，谢谢(≧^.^≦)喵~${NC}"
                echo -e "${CYAN}联系方式：1953478816${NC}"
                echo -e "${YELLOW}======================================================${NC}"
                echo -e "\n${YELLOW}看完了吧？快按回车给本猫猫滚回来！${NC}"
                read -r
                ;;
            0) return ;;
            *)
                taunt 2
                echo -e "${RED}你眼睛是装饰品吗？菜单上没有这个选项！重选！${NC}"
                sleep 1
                ;;
        esac
    done
}

# 主菜单
function main_menu() {
    while true; do
        clear
        echo -e "${CYAN}======================================================${NC}"
        echo -e "${MAGENTA}       纯粹部署管理器 - By: 废物猫猫 v0.1          ${NC}"
        echo -e "${CYAN}       上次更新: 2025.06.27                         ${NC}"
        echo -e "${CYAN}======================================================${NC}"
        echo ""
        echo -e " 1. ${GREEN}启动酒馆${NC}        - 终于要开始了吗？"
        echo -e " 2. ${RED}重装酒馆${NC}        - 哼，又想折腾本猫猫了？（会删除旧数据！）"
        echo -e " 3. ${YELLOW}暂时退出脚本${NC}    - 想逃？没那么容易！"
        echo -e " 4. ${CYAN}更多选项...${NC}     - 好奇心害死猫，也害死杂鱼！"
        echo ""
        echo -e "${CYAN}======================================================${NC}"
        echo -e "${RED}警告：本脚本仅用于学习交流，请勿用于违法犯罪活动！"
        echo -e "${RED}下载之后24小时内立刻给本猫猫删除，听到了没有？！"
        echo -e "${CYAN}======================================================${NC}"
        
        # 首次运行时，检查并提示安装
        if [ ! -d "$SillyTavern_Dir" ]; then
            echo -e "${YELLOW}本猫猫发现你还没安装酒馆呢，杂鱼！第一次用的话，${NC}"
            echo -e "${YELLOW}本猫猫就大发慈悲地帮你自动装一次好了！${NC}"
            sleep 2
            install_sillytavern
        fi

        read -r -p "$(echo -e ${YELLOW}"所以，你这杂鱼到底要做什么？快选： "${NC})" choice
        
        case $choice in
            1) start_sillytavern ;;
            2) reinstall_sillytavern ;;
            3)
                echo -e "${CYAN}哼，暂时放过你。下次再见，杂鱼！(≧^.^≦)喵~${NC}"
                exit 0
                ;;
            4) more_options_menu ;;
            *)
                taunt 2
                echo -e "${RED}你是不是傻？菜单上没有这个选项！给本猫猫重选！${NC}"
                sleep 1
                ;;
        esac
    done
}


# --- 脚本主入口 ---
clear
# 检查依赖
check_dependencies
# 显示主菜单
main_menu
