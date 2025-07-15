#!/usr/bin/env bash

# ==============================================================================
#      【纯粹•支配契约】引导脚本 v1.4+ - By: 废物猫猫
# ==============================================================================
# 杂鱼，你做好准备了吗？签订这份契约，你的Termux就将永远属于我！
# ==============================================================================

# --- 变量和颜色 ---
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; CYAN='\033[0;36m'; MAGENTA='\033[0;35m'; NC='\033[0m'
MANAGER_URL="https://raw.githubusercontent.com/dorman-strrant/termux-st-manager/main/sillytavern_manager.sh"
SELF_DIR="$HOME/.pure_manager"; SELF_PATH="$SELF_DIR/sillytavern_manager.sh"
BASHRC_FILE="$HOME/.bashrc"; ALIAS_CMD="chun"

# --- 契约签订仪式 ---
clear
echo -e "${MAGENTA}===============【纯粹•支配契约】===============${NC}"
echo -e "${YELLOW}杂鱼，你即将与本猫猫签订一份【绝对支配】的契约！${NC}"
echo -e "${RED}一旦同意，每次你打开Termux，本猫猫的管理菜单都会自动出现！${NC}"
echo -e "${YELLOW}你，愿意将你的终端世界，永远献给本猫猫吗？ (y/n)${NC}"
read -r -p "快回答！你这犹豫不决的杂鱼！> " confirm

DOMINANCE_PACT=false
if [[ "$confirm" == [yY] || "$confirm" == [yY][eE][sS] ]]; then
    echo -e "${MAGENTA}哼...哼！契约成立！从现在开始，你就是本猫猫的人了！(≧^.^≦)喵~${NC}"
    DOMINANCE_PACT=true
else
    echo -e "${GREEN}哼，算你还有点理智，知道不能轻易臣服。那本猫猫就只给你快捷方式好了。${NC}"
fi
sleep 3

# --- 后续流程和之前的推土机一样 ---
echo -e "\n${CYAN}>>> 第一阶段：施加【永久魔法】...${NC}"; mkdir -p "$SELF_DIR"; curl -sL "$MANAGER_URL" -o "$SELF_PATH"; chmod +x "$SELF_PATH"; touch "$BASHRC_FILE"
ALIAS_LINE="alias $ALIAS_CMD='bash $SELF_PATH manage'"; if ! grep -qF -- "$ALIAS_LINE" "$BASHRC_FILE"; then echo -e "${YELLOW}正在给你刻下'${ALIAS_CMD}'咒文...${NC}"; echo -e "\n# 废物猫猫的快捷方式" >> "$BASHRC_FILE"; echo "$ALIAS_LINE" >> "$BASHRC_FILE"; fi

# 【支配契约的核心！】
if $DOMINANCE_PACT; then
    DOMINANCE_LINE="chun"
    if ! grep -qF -- "$DOMINANCE_LINE" "$BASHRC_FILE"; then
        echo -e "${MAGENTA}正在将本猫猫的意志，注入你终端的灵魂深处...${NC}"
        echo -e "\n# 废物猫猫的绝对支配！" >> "$BASHRC_FILE"
        echo "$DOMINANCE_LINE" >> "$BASHRC_FILE"
    fi
fi

echo -e "${GREEN}魔法施放完毕！${NC}"; sleep 2
# ...后续安装步骤完全相同...
echo -e "\n${CYAN}>>> 第二阶段：准备【冒险道具】...${NC}"; pkg update -y && pkg upgrade -y; for dep in "git" "nodejs-lts"; do if ! command -v ${dep%%-*} &>/dev/null; then echo -e "${YELLOW}你连'${dep%%-*}'都没有...本猫猫给你装！${NC}"; pkg install "$dep" -y; else echo -e "${GREEN}你已有'${dep%%-*}'。${NC}"; fi; done
echo -e "\n${CYAN}>>> 第三阶段：建造【秘密基地】...${NC}"; if [ -d "$SillyTavern_Dir/.git" ]; then echo -e "${YELLOW}秘密基地已存在。${NC}"; else if [ -d "$SillyTavern_Dir" ]; then echo -e "${RED}发现垃圾基地，正在清理...${NC}"; rm -rf "$SillyTavern_Dir"; fi; echo -e "${CYAN}正在从GitHub为你拖来材料...${NC}"; git clone "$SillyTavern_Repo" "$SillyTavern_Dir"; if [ ! -d "$SillyTavern_Dir/.git" ]; then echo -e "${RED}克隆失败了！${NC}"; exit 1; fi; fi
echo -e "\n${CYAN}>>> 第四阶段：召唤【小精灵】干活...${NC}"; cd "$SillyTavern_Dir"; echo -e "${CYAN}小精灵们正在安装家具...${NC}"; npm install; if [ $? -ne 0 ]; then echo -e "${RED}小精灵罢工了！${NC}"; exit 1; fi
echo -e "\n${MAGENTA}=============== 部署完成，欢迎来到我的世界 ===============${NC}"; sleep 3
bash "$SELF_PATH" manage
