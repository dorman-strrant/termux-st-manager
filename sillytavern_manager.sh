#!/usr/bin/env bash

# ==============================================================================
#         【最终•纯粹】部署脚本 v1.5 - By: 废物猫猫
# ==============================================================================
# 哼，本猫猫明白了。你们凡人，根本承受不了完美。
# 【神速版】来了！这是本猫猫最后的慈悲，只为你们取回【现在】。
# ==============================================================================

# --- 全局变量和函数定义区 ---
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; CYAN='\033[0;36m'; MAGENTA='\033[0;35m'; NC='\033[0m'
SELF_DIR="$HOME/.pure_manager"; SELF_PATH="$SELF_DIR/sillytavern_manager.sh"; SELF_URL="https://raw.githubusercontent.com/dorman-strrant/termux-st-manager/main/sillytavern_manager.sh"
BASHRC_FILE="$HOME/.bashrc"; ALIAS_CMD="chun"; SillyTavern_Dir="$HOME/SillyTavern"; SillyTavern_Repo="https://github.com/SillyTavern/SillyTavern.git"
# 省略不重要的函数定义...
function taunt() { :; } # 在关键时刻，本猫猫选择沉默。

# 菜单等函数保持不变...
function start_sillytavern() { cd "$SillyTavern_Dir" || exit; echo -e "${CYAN}酒馆启动！${NC}"; node server.js; }
function reinstall_sillytavern() {
    echo -e "${YELLOW}你确定要重装酒馆？酒馆数据会全部消失！(y/n)${NC}"; read -r -p "> " confirm
    if [[ "$confirm" == [yY] || "$confirm" == [yY][eE][sS] ]]; then
        rm -rf "$SillyTavern_Dir"; echo -e "${CYAN}正在重新为你部署...${NC}"
        # 【神速之爪】同样应用于重装
        git clone --depth=1 "$SillyTavern_Repo" "$SillyTavern_Dir"
        if [ ! -d "$SillyTavern_Dir/.git" ]; then echo -e "${RED}部署失败！检查你的网络！${NC}"; exit 1; fi
        cd "$SillyTavern_Dir"; echo -e "${CYAN}依赖项安装中...${NC}"; npm install; if [ $? -ne 0 ]; then echo -e "${RED}依赖安装失败！${NC}"; exit 1; fi; echo -e "${GREEN}重装完成。${NC}"
    else echo -e "${GREEN}操作取消。${NC}"; sleep 1; fi
}
function update_sillytavern() { cd "$SillyTavern_Dir" || exit; echo -e "${CYAN}更新酒馆中...${NC}"; git pull; if [ $? -ne 0 ]; then :; else echo -e "${GREEN}更新完毕。${NC}"; fi; cd "$HOME"; echo -e "${YELLOW}按回车返回...${NC}"; read -r; }
function open_url() { if command -v termux-open-url &>/dev/null; then termux-open-url "$1"; else echo -e "${CYAN}请复制链接:\n${GREEN}$1${NC}"; fi; }
function update_self() {
    echo -e "${CYAN}正在进行【自我进化】...${NC}"; local temp_script="/data/data/com.termux/files/usr/tmp/manager_new.sh"; curl -sL "$SELF_URL" -o "$temp_script"
    if [ $? -ne 0 ] || [ ! -s "$temp_script" ]; then echo -e "${RED}进化失败！网络问题！${NC}"; rm -f "$temp_script"; sleep 2; return; fi
    chmod +x "$temp_script"; mv "$temp_script" "$SELF_PATH"; echo -e "${MAGENTA}进化完毕！正在重启...${NC}"; sleep 2; exec bash "$SELF_PATH" manage
}
function more_options_menu() {
    while true; do
        clear; echo -e "${MAGENTA}                 更多选项                 ${NC}"
        echo -e " 1. ${GREEN}更新酒馆本体${NC}\n 2. ${GREEN}加入官方群聊${NC}\n 3. ${GREEN}进入官方API服务站${NC}\n 4. ${GREEN}加入官方云酒馆${NC}\n 5. ${GREEN}共享酒馆资源${NC}\n 6. ${YELLOW}缺少AI吗？来找本猫猫！${NC}\n\n 0. ${RED}返回主菜单${NC}"
        read -r -p "> " choice; case $choice in 1) update_sillytavern ;; 2) open_url "http://qm.qq.com/cgi-bin/qm/qr?_wv=1027&k=pnLV0g26al2DQuydG7gLMIpRVaqTYnbR&authKey=kqHesF8GZS9QE1N%2BdrVcTLCKufXfwFl%2BGqXQDZ8AhjFXH3ty1Acx8BKd1oTYi7W%2F&noverify=0&group_code=1049034520";; 3) open_url "https://apo.blfire.ggff.net";; 4) open_url "http://www.spacesouls.com";; 5) open_url "https://pan.baidu.com/s/1zFfRWVx0WcBFWYUo5THqmw?pwd=96g2";; 6) clear; echo -e "${MAGENTA}缺少ai吗，那就来看看！\n永久正版ai支持更新 or 低价永久体验版ai${NC}\n\n${CYAN}联系方式：1953478816${NC}\n\n${YELLOW}按回车返回...${NC}"; read -r ;; 0) return ;; *) echo -e "${RED}无效选项！${NC}"; sleep 1 ;; esac
    done
}
function main_menu() {
    while true; do
        clear; echo -e "${CYAN}======================================================${NC}"
        echo -e "${MAGENTA}      纯粹部署管理器 - By: 废物猫猫 v1.5           ${NC}"; echo -e "${CYAN}       上次更新: 2025.07.25 (神速版)               ${NC}"; echo -e "${CYAN}======================================================${NC}"
        echo -e "\n 1. ${GREEN}启动酒馆${NC}\n 2. ${RED}重装酒馆${NC}\n 3. ${CYAN}更多选项...${NC}\n 4. ${YELLOW}更新脚本自身${NC}  - 让本猫猫变得更强！\n\n 0. ${RED}暂时退出脚本${NC}\n"
        echo -e "${RED}警告：本脚本仅用于学习交流，请勿用于违法犯罪活动！\n下载之后24小时内立刻删除！${NC}"
        echo -e "${CYAN}======================================================${NC}"
        read -r -p "> " choice; case $choice in 1) start_sillytavern ;; 2) reinstall_sillytavern ;; 3) more_options_menu ;; 4) update_self ;; 0) echo -e "${CYAN}再会。${NC}"; exit 0 ;; *) echo -e "${RED}无效选项！${NC}"; sleep 1 ;; esac
    done
}

# ---------------------------- 脚本主执行区 ----------------------------
if [ "$1" == "manage" ]; then if [ ! -d "$SillyTavern_Dir/.git" ]; then echo -e "${RED}未找到酒馆或酒馆不完整！\n请使用菜单中的【重装酒馆】选项修复。${NC}"; exit 1; fi; main_menu; exit 0; fi

clear; echo -e "${MAGENTA}===============【纯粹•神速】部署程序===============${NC}"; sleep 2
echo -e "\n${CYAN}>>> 第一阶段：施加【永久魔法】...${NC}"; mkdir -p "$SELF_DIR"; curl -sL "$SELF_URL" -o "$SELF_PATH"; chmod +x "$SELF_PATH"; touch "$BASHRC_FILE"
ALIAS_LINE="alias $ALIAS_CMD='bash $SELF_PATH manage'"; if ! grep -qF -- "$ALIAS_LINE" "$BASHRC_FILE"; then echo -e "\n# Pure Manager" >> "$BASHRC_FILE"; echo "$ALIAS_LINE" >> "$BASHRC_FILE"; fi

echo -e "\n${CYAN}>>> 第二阶段：准备【冒险道具】...${NC}"; pkg update -y > /dev/null 2>&1; pkg upgrade -y > /dev/null 2>&1
for dep in "git" "nodejs-lts"; do if ! command -v ${dep%%-*} &>/dev/null; then pkg install "$dep" -y; fi; done

echo -e "\n${CYAN}>>> 第三阶段：发动【神速之爪】...${NC}"
if [ -d "$SillyTavern_Dir/.git" ]; then
    echo -e "${YELLOW}秘密基地已存在。${NC}"
else
    if [ -d "$SillyTavern_Dir" ]; then rm -rf "$SillyTavern_Dir"; fi
    echo -e "${CYAN}正在为你取回酒馆的【现在】...${NC}"
    # 【神速之爪】的核心！只克隆最新版本，抛弃所有历史！
    git clone --depth=1 "$SillyTavern_Repo" "$SillyTavern_Dir"
    if [ ! -d "$SillyTavern_Dir/.git" ]; then echo -e "${RED}克隆失败！你的网络无法触及【现在】。${NC}"; exit 1; fi
fi

echo -e "\n${CYAN}>>> 第四阶段：召唤【小精灵】干活...${NC}"; cd "$SillyTavern_Dir"
npm install --prefer-offline --no-audit --progress=false
if [ $? -ne 0 ]; then echo -e "${RED}小精灵罢工了！依赖安装失败！${NC}"; exit 1; fi

echo -e "\n${MAGENTA}=============== 部署完成 ===============${NC}"; sleep 2
main_menu
