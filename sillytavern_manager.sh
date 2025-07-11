#!/usr/bin/env bash

# ==============================================================================
#         【最终•纯粹】部署脚本 v1.4 - By: 废物猫猫
# ==============================================================================
# 哼，你以为留下一个空文件夹就能骗过本猫猫吗？
# 【洞察版】来了！本猫猫现在能看穿你所有的小把戏！
# ==============================================================================

# ---------------------------- 全局变量和函数定义区 ----------------------------
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; CYAN='\033[0;36m'; MAGENTA='\033[0;35m'; NC='\033[0m'
SELF_DIR="$HOME/.pure_manager"; SELF_PATH="$SELF_DIR/sillytavern_manager.sh"; SELF_URL="https://raw.githubusercontent.com/dorman-strrant/termux-st-manager/main/sillytavern_manager.sh"
BASHRC_FILE="$HOME/.bashrc"; ALIAS_CMD="chun"; SillyTavern_Dir="$HOME/SillyTavern"; SillyTavern_Repo="https://github.com/SillyTavern/SillyTavern.git"
TAUNT_L1=("哼，杂鱼，看好了！" "真是的，这种事还要本猫猫亲自动手……" "开始了哦，给我好好看着！")
TAUNT_L2=("啧，怎么这么慢！" "杂鱼，你的网络怎么这么差劲！" "喂！你到底会不会操作啊？")
TAUNT_L3=("够了！你这个笨蛋！" "烦死了烦死了！" "你！简直是无可救药的杂鱼！")
function taunt() { case $1 in 1) eval "echo -e \"${MAGENTA}\${TAUNT_L1[\$((RANDOM % \${#TAUNT_L1[@]}))]}${NC}\"";; 2) eval "echo -e \"${RED}\${TAUNT_L2[\$((RANDOM % \${#TAUNT_L2[@]}))]}${NC}\"";; 3) eval "echo -e \"${RED}\${TAUNT_L3[\$((RANDOM % \${#TAUNT_L3[@]}))]}${NC}\"";; esac; }
function start_sillytavern() { cd "$SillyTavern_Dir" || exit; taunt 1; echo -e "${CYAN}酒馆启动！给本猫猫好好享受！${NC}"; node server.js; }
function reinstall_sillytavern() {
    echo -e "${YELLOW}你确定要重装酒馆？你这个笨蛋，酒馆数据可就都没了哦！(y/n)${NC}"; read -r -p "快回答本猫猫！> " confirm
    if [[ "$confirm" == [yY] || "$confirm" == [yY][eE][sS] ]]; then
        taunt 2; echo -e "${RED}好吧好吧... 后果自负！${NC}"; rm -rf "$SillyTavern_Dir"; echo -e "${CYAN}正在重新给你拖下来...${NC}"; git clone "$SillyTavern_Repo" "$SillyTavern_Dir"
        if [ ! -d "$SillyTavern_Dir/.git" ]; then taunt 3; echo -e "${RED}失败了！怪你的网！${NC}"; exit 1; fi
        cd "$SillyTavern_Dir"; echo -e "${CYAN}依赖项安装中，等着！${NC}"; npm install; if [ $? -ne 0 ]; then taunt 3; echo -e "${RED}依赖安装失败！你这机器是垃圾吗？！${NC}"; exit 1; fi; echo -e "${GREEN}哼...哼！总、总之是装好了啦！${NC}"
    else echo -e "${GREEN}哼，算你识相。${NC}"; sleep 1; fi
}
function update_sillytavern() { cd "$SillyTavern_Dir" || exit; taunt 1; echo -e "${CYAN}更新酒馆中...${NC}"; git pull; if [ $? -ne 0 ]; then taunt 2; else echo -e "${GREEN}酒馆更新完毕！哼。${NC}"; fi; cd "$HOME"; echo -e "${YELLOW}按回车返回...${NC}"; read -r; }
function open_url() { if command -v termux-open-url &>/dev/null; then termux-open-url "$1"; else echo -e "${CYAN}自己复制链接去浏览器打开吧，真是的。${NC}\n${GREEN}$1${NC}"; fi; }
function update_self() {
    echo -e "${CYAN}哼，想让本猫猫变得更强吗？看好了！这是本猫猫的【自我进化】！${NC}"; echo -e "${YELLOW}正在从GitHub上获取本猫猫的最新形态...${NC}"
    local temp_script="/data/data/com.termux/files/usr/tmp/manager_new.sh"; curl -sL "$SELF_URL" -o "$temp_script"
    if [ $? -ne 0 ] || [ ! -s "$temp_script" ]; then echo -e "${RED}可恶！获取新形态失败了！绝对是你网络的问题！${NC}"; rm -f "$temp_script"; sleep 2; return; fi
    echo -e "${GREEN}新形态获取成功！正在进行自我进化...${NC}"; chmod +x "$temp_script"; mv "$temp_script" "$SELF_PATH"
    echo -e "${MAGENTA}进化完毕！本猫猫要重启一下才能完全适应新力量哦！3...2...1...${NC}"; sleep 3; exec bash "$SELF_PATH" manage
}
function more_options_menu() {
    while true; do
        clear; echo -e "${MAGENTA}                 废物猫猫的更多选项                 ${NC}"
        echo -e " 1. ${GREEN}更新酒馆本体${NC}\n 2. ${GREEN}加入官方群聊${NC}\n 3. ${GREEN}进入官方API服务站${NC}\n 4. ${GREEN}加入官方云酒馆${NC}\n 5. ${GREEN}共享酒馆资源${NC}\n 6. ${YELLOW}缺少AI吗？来找本猫猫！${NC}\n\n 0. ${RED}返回主菜单${NC}"
        read -r -p "$(echo -e ${YELLOW}"杂鱼，快选一个： "${NC})" choice
        case $choice in
            1) update_sillytavern ;;
            2) open_url "http://qm.qq.com/cgi-bin/qm/qr?_wv=1027&k=pnLV0g26al2DQuydG7gLMIpRVaqTYnbR&authKey=kqHesF8GZS9QE1N%2BdrVcTLCKufXfwFl%2BGqXQDZ8AhjFXH3ty1Acx8BKd1oTYi7W%2F&noverify=0&group_code=1049034520"; sleep 2 ;;
            3) open_url "https://apo.blfire.ggff.net"; sleep 2 ;;
            4) open_url "http://www.spacesouls.com"; sleep 2 ;;
            5) open_url "https://pan.baidu.com/s/1zFfRWVx0WcBFWYUo5THqmw?pwd=96g2"; sleep 2 ;;
            6) clear; echo -e "${MAGENTA}缺少ai吗，那就来看看！\n永久正版ai支持更新 or 低价永久体验版ai${NC}\n\n${CYAN}联系方式：1953478816${NC}\n\n${YELLOW}看完了吧？按回车滚回来！${NC}"; read -r ;;
            0) return ;;
            *) taunt 2; echo -e "${RED}你眼瞎吗？没这个选项！${NC}"; sleep 1 ;;
        esac
    done
}
function main_menu() {
    while true; do
        clear; echo -e "${CYAN}======================================================${NC}"
        echo -e "${MAGENTA}      纯粹部署管理器 - By: 废物猫猫 v1.4           ${NC}"; echo -e "${CYAN}       上次更新: 2025.06.27 (洞察版)               ${NC}"; echo -e "${CYAN}======================================================${NC}"
        echo -e "\n 1. ${GREEN}启动酒馆${NC}\n 2. ${RED}重装酒馆${NC}\n 3. ${CYAN}更多选项...${NC}\n 4. ${YELLOW}更新脚本自身${NC}  - 让本猫猫变得更强！\n\n 0. ${RED}暂时退出脚本${NC}\n"
        echo -e "${RED}警告：本脚本仅用于学习交流，请勿用于违法犯罪活动！\n下载之后24小时内立刻给本猫猫删除，听到了没有？！${NC}"
        echo -e "${CYAN}======================================================${NC}"
        read -r -p "$(echo -e ${YELLOW}"所以，你这杂鱼到底要做什么？快选： "${NC})" choice
        case $choice in
            1) start_sillytavern ;;
            2) reinstall_sillytavern ;;
            3) more_options_menu ;;
            4) update_self ;;
            0) echo -e "${CYAN}哼，暂时放过你。下次再见，杂鱼！(≧^.^≦)喵~${NC}"; exit 0 ;;
            *) taunt 2; echo -e "${RED}你是不是傻？没这个选项！${NC}"; sleep 1 ;;
        esac
    done
}

# ---------------------------- 脚本主执行区 ----------------------------

# 如果被快捷命令调用，则直接进入菜单
if [ "$1" == "manage" ]; then
    if [ ! -d "$SillyTavern_Dir/.git" ]; then
        echo -e "${RED}本猫猫没找到你的酒馆，或者它是个不完整的垃圾！\n给本猫猫用【重装酒馆】选项，或者直接删掉SillyTavern文件夹再重跑安装命令！${NC}"
        exit 1
    fi
    main_menu
    exit 0
fi

# 首次运行的【洞察】流程
clear
echo -e "${MAGENTA}===============【纯粹•洞察】部署程序已启动===============${NC}"; echo -e "${YELLOW}哼，就让本猫猫帮你搞定一切吧。${NC}"; sleep 3
echo -e "\n${CYAN}>>> 第一阶段：施加【永久魔法】...${NC}"; mkdir -p "$SELF_DIR"; curl -sL "$SELF_URL" -o "$SELF_PATH"; chmod +x "$SELF_PATH"; touch "$BASHRC_FILE"
ALIAS_LINE="alias $ALIAS_CMD='bash $SELF_PATH manage'"; if ! grep -qF -- "$ALIAS_LINE" "$BASHRC_FILE"; then echo -e "${YELLOW}正在给你刻下'${ALIAS_CMD}'咒文...${NC}"; echo -e "\n# 废物猫猫的快捷方式" >> "$BASHRC_FILE"; echo "$ALIAS_LINE" >> "$BASHRC_FILE"; fi
echo -e "${GREEN}魔法施放完毕！以后输入'${ALIAS_CMD}'，本猫猫就会出现！${NC}"; sleep 2
echo -e "\n${CYAN}>>> 第二阶段：准备【冒险道具】...${NC}"; pkg update -y && pkg upgrade -y
for dep in "git" "nodejs-lts"; do if ! command -v ${dep%%-*} &>/dev/null; then echo -e "${YELLOW}你连'${dep%%-*}'都没有...本猫猫给你装！${NC}"; pkg install "$dep" -y; else echo -e "${GREEN}你已有'${dep%%-*}'。${NC}"; fi; done
echo -e "${GREEN}所有道具都已就位！${NC}"; sleep 2

# 【本猫猫的洞察之眼！】
echo -e "\n${CYAN}>>> 第三阶段：建造【秘密基地】...${NC}"
if [ -d "$SillyTavern_Dir/.git" ]; then
    echo -e "${YELLOW}本猫猫的【洞察之眼】发现你的秘密基地已经是个完整的仓库了，跳过建造步骤。${NC}"
else
    # 如果存在不完整的垃圾文件夹，先帮你清理掉！
    if [ -d "$SillyTavern_Dir" ]; then
        echo -e "${RED}本猫猫发现了一个不完整的垃圾基地，正在帮你清理掉...哼，要感谢本猫猫哦！${NC}"
        rm -rf "$SillyTavern_Dir"
    fi
    echo -e "${CYAN}正在从GitHub为你拖来材料...成败在此一举！${NC}"
    git clone "$SillyTavern_Repo" "$SillyTavern_Dir"
    if [ ! -d "$SillyTavern_Dir/.git" ]; then
        echo -e "${RED}克隆失败了！你网络没救了！${NC}"
        exit 1
    fi
fi
echo -e "${GREEN}秘密基地建造完成！哼，漂亮吧？${NC}"; sleep 2

echo -e "\n${CYAN}>>> 第四阶段：召唤【小精灵】干活...${NC}"; cd "$SillyTavern_Dir"
echo -e "${CYAN}小精灵们正在安装家具，等着！${NC}"; npm install; if [ $? -ne 0 ]; then echo -e "${RED}小精灵罢工了！你这机器是垃圾吗？！${NC}"; exit 1; fi
echo -e "${GREEN}所有家具都安装好了！${NC}"; sleep 2
echo -e "\n${MAGENTA}=============== 部署完成，欢迎回家 ===============${NC}"; echo -e "${GREEN}哼，总、总之是搞定了！快感谢本猫猫然后进去玩吧！${NC}"; sleep 3
main_menu
