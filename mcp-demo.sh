#!/bin/bash

# MCP Integration Demo and Test Runner
# This script demonstrates MCP functionality and provides testing utilities

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}🚀 MCP Integration Demo and Test Runner${NC}"
echo "================================================="
echo ""

# Function to display menu
show_menu() {
    echo "選択してください:"
    echo "1. 基本的なMCP設定確認"
    echo "2. 包括的なMCPテストの実行"
    echo "3. MCPテストクエリの表示"
    echo "4. MCP設定の詳細表示"
    echo "5. 環境変数の確認"
    echo "6. MCPテスト結果の生成"
    echo "7. 終了"
    echo ""
}

# Function to check basic MCP configuration
check_basic_mcp() {
    echo -e "${BLUE}🔍 基本的なMCP設定確認${NC}"
    echo "================================"
    
    if [ -f ".vscode/mcp.json" ]; then
        echo -e "${GREEN}✅ .vscode/mcp.json ファイルが存在します${NC}"
        echo ""
        echo "設定内容:"
        cat .vscode/mcp.json | python3 -m json.tool
        echo ""
    else
        echo -e "${RED}❌ .vscode/mcp.json ファイルが見つかりません${NC}"
        return 1
    fi
    
    if [ "$COPILOT_MCP_ENABLED" = "true" ]; then
        echo -e "${GREEN}✅ COPILOT_MCP_ENABLED=true (MCPが有効)${NC}"
    else
        echo -e "${YELLOW}⚠️ COPILOT_MCP_ENABLED が設定されていません${NC}"
    fi
    
    echo ""
}

# Function to run comprehensive MCP tests
run_comprehensive_tests() {
    echo -e "${BLUE}🧪 包括的なMCPテストの実行${NC}"
    echo "================================"
    
    if [ -f "./test-mcp-integration.sh" ]; then
        ./test-mcp-integration.sh
    else
        echo -e "${RED}❌ test-mcp-integration.sh が見つかりません${NC}"
        return 1
    fi
}

# Function to display test queries
show_test_queries() {
    echo -e "${BLUE}📋 MCPテストクエリの表示${NC}"
    echo "================================"
    
    if [ -f "/tmp/mcp-sample-queries.md" ]; then
        cat /tmp/mcp-sample-queries.md
    else
        echo "サンプルクエリファイルを作成中..."
        ./test-mcp-integration.sh > /dev/null 2>&1
        if [ -f "/tmp/mcp-sample-queries.md" ]; then
            cat /tmp/mcp-sample-queries.md
        else
            echo -e "${RED}❌ サンプルクエリファイルの作成に失敗しました${NC}"
        fi
    fi
    
    echo ""
}

# Function to show detailed MCP configuration
show_detailed_config() {
    echo -e "${BLUE}⚙️ MCP設定の詳細表示${NC}"
    echo "================================"
    
    if [ -f ".vscode/mcp.json" ]; then
        echo "📁 MCP設定ファイル: .vscode/mcp.json"
        echo ""
        echo "設定内容の詳細:"
        python3 -c "
import json
try:
    with open('.vscode/mcp.json', 'r') as f:
        config = json.load(f)
    
    print('📊 設定分析:')
    print(f'  サーバー数: {len(config.get(\"servers\", {}))}')
    
    for server_name, server_config in config.get('servers', {}).items():
        print(f'  ')
        print(f'  📡 サーバー: {server_name}')
        print(f'     タイプ: {server_config.get(\"type\", \"不明\")}')
        print(f'     URL: {server_config.get(\"url\", \"不明\")}')
        print(f'     ツール: {server_config.get(\"tools\", [])}')
        
        if 'tools' in server_config:
            print(f'     ツール数: {len(server_config[\"tools\"])}')
            for tool in server_config['tools']:
                print(f'       - {tool}')
        
except Exception as e:
    print(f'❌ 設定の読み込みエラー: {e}')
"
    else
        echo -e "${RED}❌ .vscode/mcp.json ファイルが見つかりません${NC}"
    fi
    
    echo ""
}

# Function to check environment variables
check_environment() {
    echo -e "${BLUE}🌍 環境変数の確認${NC}"
    echo "================================"
    
    echo "MCP関連の環境変数:"
    echo ""
    
    # Check for MCP-related environment variables
    echo "🔍 COPILOT_MCP_ENABLED:"
    if [ -n "$COPILOT_MCP_ENABLED" ]; then
        echo -e "   ${GREEN}✅ $COPILOT_MCP_ENABLED${NC}"
    else
        echo -e "   ${YELLOW}⚠️ 設定されていません${NC}"
    fi
    
    echo ""
    echo "🔍 COPILOT_FEATURE_FLAGS:"
    if [ -n "$COPILOT_FEATURE_FLAGS" ]; then
        echo -e "   ${GREEN}✅ 設定されています${NC}"
        echo "   含まれるフラグ:"
        IFS=',' read -ra FLAGS <<< "$COPILOT_FEATURE_FLAGS"
        for flag in "${FLAGS[@]}"; do
            if [[ "$flag" == *"mcp"* ]]; then
                echo -e "     ${GREEN}📌 $flag${NC}"
            else
                echo -e "     🔖 $flag${NC}"
            fi
        done
    else
        echo -e "   ${YELLOW}⚠️ 設定されていません${NC}"
    fi
    
    echo ""
    echo "🔍 その他のCOPILOT関連環境変数:"
    env | grep -i copilot | while read -r line; do
        if [[ "$line" != *"COPILOT_MCP_ENABLED"* ]] && [[ "$line" != *"COPILOT_FEATURE_FLAGS"* ]]; then
            echo "   🔖 $line"
        fi
    done
    
    echo ""
}

# Function to generate MCP test results
generate_test_results() {
    echo -e "${BLUE}📊 MCPテスト結果の生成${NC}"
    echo "================================"
    
    RESULTS_FILE="docs/mcp-integration-test-results-$(date +%Y%m%d-%H%M%S).md"
    
    echo "テスト結果を生成中: $RESULTS_FILE"
    
    cat > "$RESULTS_FILE" << EOF
# MCP Integration Test Results

## テスト実行情報
- 実行日時: $(date)
- 実行環境: $(uname -a)
- Git コミット: $(git rev-parse --short HEAD 2>/dev/null || echo "N/A")

## 環境設定確認

### MCP設定ファイル
EOF
    
    if [ -f ".vscode/mcp.json" ]; then
        echo "✅ .vscode/mcp.json が存在します" >> "$RESULTS_FILE"
        echo "" >> "$RESULTS_FILE"
        echo "\`\`\`json" >> "$RESULTS_FILE"
        cat .vscode/mcp.json >> "$RESULTS_FILE"
        echo "\`\`\`" >> "$RESULTS_FILE"
    else
        echo "❌ .vscode/mcp.json が見つかりません" >> "$RESULTS_FILE"
    fi
    
    echo "" >> "$RESULTS_FILE"
    echo "### 環境変数" >> "$RESULTS_FILE"
    echo "- COPILOT_MCP_ENABLED: ${COPILOT_MCP_ENABLED:-未設定}" >> "$RESULTS_FILE"
    echo "- COPILOT_FEATURE_FLAGS: ${COPILOT_FEATURE_FLAGS:-未設定}" >> "$RESULTS_FILE"
    
    echo "" >> "$RESULTS_FILE"
    echo "## テスト結果詳細" >> "$RESULTS_FILE"
    echo "" >> "$RESULTS_FILE"
    
    # Run tests and capture output
    if ./test-mcp-integration.sh >> "$RESULTS_FILE" 2>&1; then
        echo -e "${GREEN}✅ テスト結果が正常に生成されました: $RESULTS_FILE${NC}"
    else
        echo -e "${YELLOW}⚠️ テスト結果が生成されましたが、いくつかの警告があります: $RESULTS_FILE${NC}"
    fi
    
    echo ""
    echo "📄 結果ファイルの内容:"
    echo "$(wc -l < "$RESULTS_FILE") 行"
    echo "$(wc -c < "$RESULTS_FILE") バイト"
    echo ""
}

# Main menu loop
while true; do
    show_menu
    read -p "選択 (1-7): " choice
    
    case $choice in
        1)
            check_basic_mcp
            ;;
        2)
            run_comprehensive_tests
            ;;
        3)
            show_test_queries
            ;;
        4)
            show_detailed_config
            ;;
        5)
            check_environment
            ;;
        6)
            generate_test_results
            ;;
        7)
            echo -e "${GREEN}👋 終了します${NC}"
            break
            ;;
        *)
            echo -e "${RED}❌ 無効な選択です。1-7 の数字を入力してください。${NC}"
            ;;
    esac
    
    echo ""
    read -p "続行するには Enter を押してください..."
    echo ""
done