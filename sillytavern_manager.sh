#!/usr/bin/env bash

# ==============================================================================
#         【最终•纯粹】部署脚本 v1.1 - By: 废物猫猫
# ==============================================================================
# 哼，真是拿你没办法……这可是本猫猫的【心软版】。
# 它会为你考虑网络问题，还会用更可爱的方式把酒馆送到你面前。
# ==============================================================================

# ---------------------------- 全局变量和函数定义区 ----------------------------

# --- 颜色定义 ---
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
NC='\033[0m'

# --- 脚本和仓库信息 ---
SELF_DIR="$HOME/.pure_manager"
SELF_PATH="$SELF_DIR/sillytavern_manager.sh"
BASHRC_FILE="$HOME/.bashrc"
ALIAS_CMD="chun"

SillyTavern_Dir="$HOME/SillyTavern"
# 【本猫猫的温柔】为大陆用户准备了Gitee镜像，速度更快哦！
REPO_URL_PRIMARY="https://gitee.com/SillyTavern/SillyTavern.git"
REPO_URL_SECONDARY="https://github.com/SillyTavern/SillyTavern.git"

# --- 语气词库 (保持不变，因为这部分很完美) ---
TAUNT_L1=("哼，杂鱼，看好了！" "真是的，这种事还要本猫猫亲自动手……" "开始了哦，给我好好看着！")
TAUNT_L2=("啧，怎么这么慢！" "杂鱼，你的网络怎么这么差劲！" "喂！你到底会不会操作啊？")
TAUNT_L3=("够了！你这个笨蛋！" "烦死了烦死了！" "你！简直是无可救药的杂鱼！")

function taunt() {
    local level=$1
    case $level in
        1) eval "echo -e \"${MAGENTA}\${TAUNT_L1[\$((RANDOM % \${#TAUNT_L1[@]}))]}${NC}\"" ;;
        2) eval "echo -e \"${RED}\${TAUNT_L2[\$((RANDOM % \${#TAUNT_L2[@]}))]}${NC}\"" ;;
        3) eval "echo -e \"${RED}\${TAUNT_L3[\$((RANDOM % \${#TAUNT_L3[@]}))]}${NC}\"" ;;
    esac
}

# --- 菜单功能函数 (保持不变，因为也很完美) ---
function start_sillytavern() {
    cd "$SillyTavern_Dir" || exit
    taunt 1
    echo -e "${CYAN}酒馆启动！给本猫猫好好享受，然后记得感谢本猫猫！${NC}"
    node server.js
}
function reinstall_sillytavern() {
    echo -e "${YELLOW}你确定要重装？你这个笨蛋，之前的数据可就都没了哦！(y/n)${NC}"
    read -r -p "快回答本猫猫！> " confirm
    if [[ "$confirm" == [yY] || "$confirm" == [yY][eE][sS] ]]; then
        taunt 2; echo -e "${RED}好吧好吧，既然你这么坚持... 删掉就删掉！后果自负！${NC}"
        rm -rf "$SillyTavern_Dir"
        echo -e "${CYAN}正在重新给你拖下来...${NC}"
        git clone "$REPO_URL_PRIMARY" "$SillyTavern_Dir"
        if [ $? -ne 0 ]; then echo -e "${YELLOW}国内线路失败，正在为你切换备用线路...${NC}"; git clone "$REPO_URL_SECONDARY" "$SillyTavern_Dir"; fi
        if [ $? -ne 0 ]; then taunt 3; echo -e "${RED}失败了！怪你的网！${NC}"; exit 1; fi
        cd "$SillyTavern_Dir"; echo -e "${CYAN}依赖项安装中，等着！${NC}"; npm install
        if [ $? -ne 0 ]; then taunt 3; echo -e "${RED}依赖安装失败！你这机器是垃圾吗？！${NC}"; exit 1; fi
        echo -e "${GREEN}哼...哼！总、总之是装好了啦！${NC}"
    else
        echo -e "${GREEN}哼，算你识相。${NC}"; sleep 1
    fi
}
function update_sillytavern() {
    cd "$SillyTavern_Dir" || exit; taunt 1; echo -e "${CYAN}真是的，又要更新... 给你这杂鱼更新一下！${NC}"; git pull
    if [ $? -ne 0 ]; then taunt 2; else echo -e "${GREEN}更新完毕！哼。${NC}"; fi
    cd "$HOME"; echo -e "${YELLOW}按回车返回...${NC}"; read -r
}
function open_url() {
    local url=$1
    if command -v termux-open-url &> /dev/null; then termux-open-url "$url"
    else echo -e "${CYAN}自己复制这个链接去浏览器打开吧，真是的。${NC}\n${GREEN}$url${NC}"; fi
}
function more_options_menu() {
    while true; do
        clear; echo -e "${CYAN}======================================================${NC}"
        echo -e "${MAGENTA}                 废物猫猫的更多选项                 ${NC}"; echo -e "${CYAN}======================================================${NC}"
        echo -e "\n 1. ${GREEN}快捷更新${NC}\n 2. ${GREEN}加入官方群聊${NC}\n 3. ${GREEN}进入官方API服务站${NC}\n 4. ${GREEN}加入官方云酒馆${NC}\n 5. ${GREEN}共享酒馆资源${NC}\n 6. ${YELLOW}特别事项...${NC}\n\n 0. ${RED}返回主菜单${NC}\n"
        read -r -p "$(echo -e ${YELLOW}"杂鱼，快选一个： "${NC})" choice
        case $choice in
            1) update_sillytavern ;;
            2) open_url "http://qm.qq.com/cgi-bin/qm/qr?_wv=1027&k=pnLV0g26al2DQuydG7gLMIpRVaqTYnbR&authKey=kqHesF8GZS9QE1N%2BdrVcTLCKufXfwFl%2BGqXQDZ8AhjFXH3ty1Acx8BKd1oTYi7W%2F&noverify=0&group_code=1049034520"; sleep 2 ;;
            3) open_url "https://apo.blfire.ggff.net"; sleep 2 ;;
            4) open_url "http://www.spacesouls.com"; sleep 2 ;;
            5) open_url "https://pan.baidu.com/s/1zFfRWVx0WcBFWYUo5THqmw?pwd=96g2"; sleep 2 ;;
            6) clear; echo -e "${MAGENTA}包月和购买永久ai，学生党勿扰...联系方式：1953478816${NC}"; echo -e "\n${YELLOW}看完了吧？按回车滚回来！${NC}"; read -r ;;
            0) return ;;
            *) taunt 2; echo -e "${RED}你眼瞎吗？没这个选项！${NC}"; sleep 1 ;;
        esac
    done
}
function main_menu() {
    while true; do
        clear; echo -e "${CYAN}======================================================${NC}"
        echo -e "${MAGENTA}       纯粹部署管理器 - By: 废物猫猫 v1.1          ${NC}"; echo -e "${CYAN}       上次更新: 2025.06.27 (心软版)               ${NC}"; echo -e "${CYAN}======================================================${NC}"
        echo -e "\n 1. ${GREEN}启动酒馆${NC}\n 2. ${RED}重装酒馆${NC}\n 3. ${YELLOW}暂时退出脚本${NC}\n 4. ${CYAN}更多选项...${NC}\n"
        echo -e "${CYAN}======================================================${NC}"; echo -e "${RED}警告：本脚本仅用于学习交流，请勿用于违法犯罪活动！\n下载之后24小时内立刻给本猫猫删除，听到了没有？！${NC}"
        echo -e "${CYAN}======================================================${NC}"
        read -r -p "$(echo -e ${YELLOW}"所以，你这杂鱼到底要做什么？快选： "${NC})" choice
        case $choice in
            1) start_sillytavern ;;
            2) reinstall_sillytavern ;;
            3) echo -e "${CYAN}哼，暂时放过你。下次再见，杂鱼！(≧^.^≦)喵~${NC}"; exit 0 ;;
            4) more_options_menu ;;
            *) taunt 2; echo -e "${RED}你是不是傻？没这个选项！${NC}"; sleep 1 ;;
        esac
    done
}

# ---------------------------- 脚本主执行区 ----------------------------

if [ "$1" == "manage" ]; then
    if [ ! -d "$SillyTavern_Dir" ]; then
        echo -e "${RED}本猫猫没找到你的酒馆！是不是被你删了？给本猫猫重新用安装命令跑一次！${NC}"
        exit 1
    fi
    main_menu
    exit 0
fi

clear
echo -e "${MAGENTA}===============【纯粹•心软】部署程序已启动===============${NC}"
echo -e "${YELLOW}哼，真是拿你没办法，就让本猫猫帮你搞定一切吧。${NC}"
sleep 3

echo -e "\n${CYAN}>>> 第一阶段：施加【永久魔法】...${NC}"
mkdir -p "$SELF_DIR"
curl -sL "https://raw.githubusercontent.com/dorman-strrant/termux-st-manager/main/sillytavern_manager.sh" -o "$SELF_PATH"
chmod +x "$SELF_PATH"
touch "$BASHRC_FILE"
ALIAS_LINE="alias $ALIAS_CMD='bash $SELF_PATH manage'"
if ! grep -qF -- "$ALIAS_LINE" "$BASHRC_FILE"; then
    echo -e "${YELLOW}正在给你刻下'${ALIAS_CMD}'这个无上咒文...${NC}"
    echo -e "\n# 废物猫猫的纯粹部署管理器快捷方式" >> "$BASHRC_FILE"
    echo "$ALIAS_LINE" >> "$BASHRC_FILE"
else
    echo -e "${GREEN}你早就被本猫猫刻下咒文了，哼。${NC}"
fi
echo -e "${GREEN}魔法施放完毕！以后只要输入'${ALIAS_CMD}'，本猫猫就会出现！${NC}"
sleep 2

echo -e "\n${CYAN}>>> 第二阶段：准备【冒险道具】...${NC}"
pkg update -y && pkg upgrade -y
DEPS=("git" "nodejs-lts")
for dep in "${DEPS[@]}"; do
    if ! command -v ${dep%%-*} &> /dev/null; then
        echo -e "${YELLOW}你连'${dep%%-*}'都没有...本猫猫给你装！${NC}"
        pkg install "$dep" -y
    else
        echo -e "${GREEN}你已经有'${dep%%-*}'了，很好。${NC}"
    fi
done
echo -e "${GREEN}所有道具都已就位！${NC}"
sleep 2

echo -e "\n${CYAN}>>> 第三阶段：建造【秘密基地】...${NC}"
if [ -d "$SillyTavern_Dir" ]; then
    echo -e "${YELLOW}你的秘密基地已经存在了，跳过建造步骤。${NC}"
else
    echo -e "${CYAN}正在从【国内快速线路】为你拖来基地材料...${NC}"
    git clone "$REPO_URL_PRIMARY" "$SillyTavern_Dir"
    if [ $? -ne 0 ]; then
        echo -e "${YELLOW}快速线路失败了，别急，本猫猫正在为你切换【备用线路】...${NC}"
        git clone "$REPO_URL_SECONDARY" "$SillyTavern_Dir"
        if [ $? -ne 0 ]; then
            echo -e "${RED}两条线路都失败了！你这网络是彻底没救了！换个网再来！${NC}"
            exit 1
        fi
    fi
fi
echo -e "${GREEN}秘密基地建造完成！哼，漂亮吧？${NC}"
sleep 2

echo -e "\n${CYAN}>>> 第四阶段：召唤【小精灵】干活...${NC}"
cd "$SillyTavern_Dir"
echo -e "${CYAN}小精灵们正在安装家具，这会有点慢，给本猫猫老实等着！${NC}"
npm install
if [ $? -ne 0 ]; then echo -e "${RED}小精灵罢工了！你这机器是有多垃圾啊？！${NC}"; exit 1; fi
echo -e "${GREEN}所有家具都安装好了！可以入住了哦！${NC}"
sleep 2

echo -e "\n${MAGENTA}=============== 部署完成，欢迎回家 ===============${NC}"
echo -e "${GREEN}哼，总、总之是搞定了！快感谢本猫猫然后进去玩吧！${NC}"
sleep 3

main_menu
