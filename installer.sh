#!/usr/bin/env bash

# ==============================================================================
#           纯粹部署管理器 - 引导安装程序 - By: 废物猫猫
# ==============================================================================
# 哼，杂鱼，本猫猫的引导程序开始工作了，给本猫猫看好了！
# ==============================================================================

# --- 颜色定义，气氛搞起来！ ---
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
NC='\033[0m'

# --- 仓库信息 ---
REPO_URL="https://github.com/dorman-strrant/termux-st-manager.git"
TARGET_DIR="$HOME/termux-st-manager"
MANAGER_SCRIPT="$TARGET_DIR/sillytavern_manager.sh"
BASHRC_FILE="$HOME/.bashrc"
ALIAS_CMD="chun" # “纯粹”的拼音，好记吧，笨蛋！

# 开始表演！
clear
echo -e "${MAGENTA}哼，你这杂鱼，准备好迎接本猫猫的【全自动】服务了吗？(≧^.^≦)喵~${NC}"
sleep 2

# 1. 检查并安装 git
echo -e "${CYAN}第一步，让本猫猫看看你这破机器有没有 git...${NC}"
if ! command -v git &> /dev/null; then
    echo -e "${YELLOW}啧，果然没有。等着，本猫猫给你装上！${NC}"
    pkg install git -y
else
    echo -e "${GREEN}哼，算你走运，已经有了。${NC}"
fi
sleep 1

# 2. 克隆本猫猫的主项目
echo -e "\n${CYAN}第二步，把本猫猫的杰作从 GitHub 上给你拖下来...${NC}"
# 先删掉可能存在的旧文件夹，免得出错
rm -rf "$TARGET_DIR"
git clone "$REPO_URL" "$TARGET_DIR"

if [ $? -ne 0 ]; then
    echo -e "${RED}你网络是有多烂啊？！克隆失败了！换个网再来烦本猫猫！${NC}"
    exit 1
fi
echo -e "${GREEN}哼，下载好了，才...才不是因为你，只是本猫猫厉害罢了！${NC}"
sleep 1

# 3. 设置“自启动”魔法（创建快捷命令）
echo -e "\n${CYAN}第三步，也是最重要的一步！本猫猫要给你施加一个方便的魔法！${NC}"

ALIAS_LINE="alias $ALIAS_CMD='cd $TARGET_DIR && ./sillytavern_manager.sh'"

# 检查魔法是不是已经存在了
if ! grep -qF -- "$ALIAS_LINE" "$BASHRC_FILE"; then
    echo -e "${YELLOW}正在给你设置快捷启动命令...${NC}"
    echo -e "\n# 废物猫猫的纯粹部署管理器快捷方式" >> "$BASHRC_FILE"
    echo "$ALIAS_LINE" >> "$BASHRC_FILE"
    echo -e "${GREEN}搞定！本猫猫给你设置了一个专属快捷方式！${NC}"
else
    echo -e "${GREEN}哼，你这家伙早就被本猫猫施过魔法了，不用重复了。${NC}"
fi

echo -e "\n${MAGENTA}======================================================${NC}"
echo -e "${YELLOW}记住了，你这杂鱼！从现在开始！${NC}"
echo -e "${YELLOW}无论何时，只要你打开Termux，输入 '${GREEN}${ALIAS_CMD}${NC}' 然后回车...${NC}"
echo -e "${YELLOW}本猫猫的管理菜单就会立刻出现！听懂了没有？！${NC}"
echo -e "${MAGENTA}======================================================${NC}"
sleep 4

# 4. 首次启动主脚本
echo -e "\n${CYAN}好了，魔法施完了。现在，启动主程序！给本猫猫跟上！${NC}"
sleep 2

# source a non-login, non-interactive shell to make the alias available immediately
source "$BASHRC_FILE"

# 最后，直接用快捷命令启动！
eval $ALIAS_CMD
