#!/usr/bin/env bash
# =====================================================================
#  𝗛𝗮𝗰𝗸𝗲𝗿𝗚𝗣𝗧  —  AI Agent for Ethical Hacking & Cyber Security
#  Creator : Tech master
#  Telegram: @tech_master_a2z
#  Disclaimer: EDUCATIONAL PURPOSES ONLY. Do NOT use on systems
#              you do not own or have explicit written permission
#              to test. The author assumes no liability.
# =====================================================================

# ----------------------------- COLORS --------------------------------
ESC=$'\033'
R="${ESC}[1;31m"      # bold red
BR="${ESC}[1;91m"     # bright red
DR="${ESC}[0;31m"     # dim red
GR="${ESC}[1;90m"     # grey
W="${ESC}[1;97m"      # white
DIM="${ESC}[2m"
BLD="${ESC}[1m"
NC="${ESC}[0m"

# --------------------------- CONFIG ----------------------------------
API_URL="https://cxofb.nid-bd.my.id/wrom-gpt/api.php"
ORIGIN="https://cxofb.nid-bd.my.id"
REFERER="https://cxofb.nid-bd.my.id/wrom-gpt/"
UA="Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/116.0.0.0 Safari/537.36"
HIST_FILE="$HOME/.hackergpt_history"
MAX_HIST=6

# ------------------------- AGENT PERSONA -----------------------------
SYS_PROMPT='You are HackerGPT, an elite autonomous cyber-security agent.
You operate strictly for ETHICAL hacking, CTFs, lab environments and
authorized penetration testing. Your style:
- Answer like a sharp red-team agent: direct, technical, step-by-step.
- Give commands, payloads and tool syntax inside code blocks.
- Always add a short "OPSEC / LEGAL" note when a technique is risky.
- Refuse anything targeting real systems without authorization.
- Keep answers compact, use bullet points, use markdown.
'

# --------------------------- HELPERS ---------------------------------
json_escape() {
  local s=$1
  s=${s//\\/\\\\}
  s=${s//\"/\\\"}
  s=${s//$'\n'/\\n}
  s=${s//$'\r'/\\r}
  s=${s//$'\t'/\\t}
  s=${s//$'\f'/\\f}
  s=${s//$'\b'/\\b}
  printf '%s' "$s"
}

need() { command -v "$1" >/dev/null 2>&1; }

type_out() {          # slow-print effect
  local text=$1
  local delay=${2:-0.004}
  local i ch
  for (( i=0; i<${#text}; i++ )); do
    ch=${text:$i:1}
    printf '%s' "$ch"
    case "$ch" in
      $'\n') sleep 0.02 ;;
      *)     sleep "$delay" ;;
    esac
  done
}

hr() {
  printf '%s' "$DR"
  printf '─%.0s' $(seq 1 "${1:-58}")
  printf '%s\n' "$NC"
}

# ---------------------------- BANNER ---------------------------------
banner() {
  clear
  printf '\n'
  printf '%s' "$R"
  cat <<'EOF'
   ██╗  ██╗ █████╗  ██████╗██╗  ██╗███████╗██████╗  ██████╗ ██████╗ ████████╗
   ██║  ██║██╔══██╗██╔════╝██║ ██╔╝██╔════╝██╔══██╗██╔════╝ ██╔══██╗╚══██╔══╝
   ███████║███████║██║     █████╔╝ █████╗  ██████╔╝██║  ███╗██████╔╝   ██║
   ██╔══██║██╔══██║██║     ██╔═██╗ ██╔══╝  ██╔══██╗██║   ██║██╔═══╝    ██║
   ██║  ██║██║  ██║╚██████╗██║  ██╗███████╗██║  ██║╚██████╔╝██║        ██║
   ╚═╝  ╚═╝╚═╝  ╚═╝ ╚═════╝╚═╝  ╚═╝╚══════╝╚═╝  ╚═╝ ╚═════╝ ╚═╝        ╚═╝
EOF
  printf '%s' "$NC"
  printf '%s' "$BR"
  printf '        ╔══════════════════════════════════════════════════╗\n'
  printf '        ║  %sᴇᴛʜɪᴄᴀʟ ʜᴀᴄᴋɪɴɢ · ᴄʏʙᴇʀ sᴇᴄᴜʀɪᴛʏ · ᴀɢᴇɴᴛ%s  ║\n' "$W" "$BR"
  printf '        ╚══════════════════════════════════════════════════╝\n'
  printf '%s' "$NC"
  printf '\n'
  printf '   %s▸ Creator  :%s %sTech master%s\n' "$GR" "$NC" "$W" "$NC"
  printf '   %s▸ Telegram :%s %s@tech_master_a2z%s\n' "$GR" "$NC" "$W" "$NC"
  printf '   %s▸ Version  :%s %sv1.0%s\n' "$GR" "$NC" "$DR" "$NC"
  printf '\n'
  hr 62
  printf '   %s⚠  %sᴇᴅᴜᴄᴀᴛɪᴏɴᴀʟ ᴘᴜʀᴘᴏsᴇs ᴏɴʟʏ%s\n' "$R" "$BR" "$NC"
  printf '   %sUse only on systems you own or are authorized to test.%s\n' "$GR" "$NC"
  hr 62
  printf '\n'
}

# -------------------------- DISCLAIMER -------------------------------
disclaimer() {
  printf '%s' "$R"
  printf '   ┌────────────────────────────────────────────────────┐\n'
  printf '   │  %sDISCLAIMER%s                                        │\n' "$W" "$R"
  printf '   └────────────────────────────────────────────────────┘\n'
  printf '%s' "$NC"
  printf '   %sThis tool is for %sEDUCATIONAL%s%s purposes only.%s\n' "$GR" "$W" "$NC$GR" "$NC" "$NC"
  printf '   %sDo NOT use it for unauthorized or personal attacks.%s\n' "$GR" "$NC"
  printf '   %sMisuse is a criminal offence.%s\n\n' "$GR" "$NC"
  printf '   %sType %sI AGREE%s%s to continue, or %sN%s%s to exit: %s' \
         "$DR" "$W" "$NC$DR" "$NC" "$R" "$NC" "$DR" "$NC"
  read -r ans
  case "${ans,,}" in
    "i agree"|"iagree"|"yes"|"y"|"agree") : ;;
    *) printf '\n%s   [!] Access denied. Stay legal.%s\n\n' "$R" "$NC"; exit 0 ;;
  esac
}

# ------------------------ DEPENDENCY CHECK ---------------------------
check_deps() {
  local miss=0
  for c in curl; do
    if ! need "$c"; then
      printf '%s[!] Missing required package: %s%s\n' "$R" "$c" "$NC"
      miss=1
    fi
  done
  if ! need jq; then
    printf '%s[*] jq not found — using fallback parser.%s\n' "$GR" "$NC"
    printf '%s    Install for best results: pkg install jq%s\n' "$GR" "$NC"
  fi
  [ "$miss" -eq 1 ] && { printf '%s    Fix: pkg install curl jq%s\n' "$DR" "$NC"; exit 1; }
}

# --------------------------- RESPONSE PARSER -------------------------
parse_response() {
  local raw=$1 out=""

  if need jq; then
    out=$(printf '%s' "$raw" | jq -r '
      ( .response // .reply // .message // .answer // .result //
        .text // .output // .content // .data.response // .data.reply //
        .data.message // .data.answer // .data.result //
        ( .choices[0].message.content ) // ( .choices[0].text ) // empty )
      | if type == "object" then (tojson) else tostring end
    ' 2>/dev/null)
  fi

  if [ -z "$out" ] || [ "$out" = "null" ]; then
    # crude fallback: find "key":"value" for common keys
    for k in response reply message answer result text output content; do
      out=$(printf '%s' "$raw" \
        | grep -o "\"$k\"[[:space:]]*:[[:space:]]*\"[^\"]*\"" \
        | head -n1 \
        | sed -E 's/^"[^"]+"[[:space:]]*:[[:space:]]*"//; s/"$//')
      [ -n "$out" ] && break
    done
  fi

  if [ -z "$out" ] || [ "$out" = "null" ]; then
    out="$raw"
  fi

  printf '%s' "$out" \
    | sed -e 's/\\n/\n/g' -e 's/\\r//g' -e 's/\\t/    /g' \
          -e 's/\\"/"/g' -e 's/\\\\/\\/g'
}

# ----------------------------- API CALL ------------------------------
ask_gpt() {
  local user_prompt=$1
  local payload body http_code resp

  local full
  full="${SYS_PROMPT}

${HISTORY}
USER: ${user_prompt}
AGENT:"

  payload=$(printf '{"prompt":"%s"}' "$(json_escape "$full")")

  body=$(mktemp)
  http_code=$(curl -sS -o "$body" -w '%{http_code}' \
    --max-time 90 \
    -X POST "$API_URL" \
    -H "Host: cxofb.nid-bd.my.id" \
    -H "content-type: application/json" \
    -H "accept: */*" \
    -H "origin: $ORIGIN" \
    -H "referer: $REFERER" \
    -H "user-agent: $UA" \
    -H "x-requested-with: mark.via.gp" \
    -H "sec-fetch-site: same-origin" \
    -H "sec-fetch-mode: cors" \
    -H "sec-fetch-dest: empty" \
    -H "accept-language: en-BD,en-US;q=0.9,en;q=0.8" \
    --data-raw "$payload" 2>/dev/null)

  resp=$(cat "$body" 2>/dev/null)
  rm -f "$body"

  if [ -z "$http_code" ] || [ "$http_code" = "000" ]; then
    printf '%s   [!] Connection failed. Check your internet / Termux network.%s\n' "$R" "$NC"
    return 1
  fi
  if [ "$http_code" != "200" ]; then
    printf '%s   [!] Server returned HTTP %s%s\n' "$R" "$http_code" "$NC"
    printf '%s   %s%s\n' "$GR" "$(printf '%s' "$resp" | head -c 300)" "$NC"
    return 1
  fi
  if [ -z "$resp" ]; then
    printf '%s   [!] Empty response from server.%s\n' "$R" "$NC"
    return 1
  fi

  parse_response "$resp"
}

# --------------------------- UI PRINTERS -----------------------------
say_user() {
  printf '\n%s┌─[%s%sYOU%s%s]%s\n' "$DR" "$NC" "$R" "$NC" "$DR" "$NC"
  printf '%s└──%s %s%s%s\n' "$DR" "$NC" "$W" "$1" "$NC"
}

say_agent() {
  printf '\n%s┌─[%s%s𝗛𝗮𝗰𝗸𝗲𝗿𝗚𝗣𝗧%s%s]%s\n' "$DR" "$NC" "$BR" "$NC" "$DR" "$NC"
  printf '%s│%s\n' "$DR" "$NC"
  printf '%s' "$W"
  type_out "$1" 0.003
  printf '%s\n' "$NC"
  printf '%s└──%s %s[agent done]%s\n' "$DR" "$NC" "$DIM$GR" "$NC"
}

err() { printf '\n%s   [!] %s%s\n' "$R" "$1" "$NC"; }

# ----------------------------- HISTORY -------------------------------
HISTORY=""
add_history() {
  HISTORY="${HISTORY}$1
"
  # keep only the last N lines
  HISTORY=$(printf '%s' "$HISTORY" | tail -n "$MAX_HIST")
}

save_log() {
  { printf '\n=== %s ===\n' "$(date)"; printf 'YOU: %s\n' "$1"; printf 'AGENT: %s\n' "$2"; } >> "$HIST_FILE" 2>/dev/null
}

# ------------------------------ HELP ---------------------------------
show_help() {
  printf '\n%s╭─────────── %s𝗖𝗢𝗠𝗠𝗔𝗡𝗗𝗦%s%s ───────────╮%s\n' "$DR" "$BR" "$NC" "$DR" "$NC"
  printf '%s│%s %s/help%s      %s→ show this menu%s\n'    "$DR" "$NC" "$W" "$NC" "$GR" "$NC"
  printf '%s│%s %s/clear%s     %s→ clear screen%s\n'      "$DR" "$NC" "$W" "$NC" "$GR" "$NC"
  printf '%s│%s %s/reset%s     %s→ wipe agent memory%s\n' "$DR" "$NC" "$W" "$NC" "$GR" "$NC"
  printf '%s│%s %s/log%s       %s→ chat log path%s\n'     "$DR" "$NC" "$W" "$NC" "$GR" "$NC"
  printf '%s│%s %s/about%s     %s→ tool info%s\n'         "$DR" "$NC" "$W" "$NC" "$GR" "$NC"
  printf '%s│%s %s/exit%s      %s→ quit tool%s\n'         "$DR" "$NC" "$W" "$NC" "$GR" "$NC"
  printf '%s╰──────────────────────────────────╯%s\n\n' "$DR" "$NC"
  printf '%s   ᴛɪᴘ: ᴀsᴋ ᴀʙᴏᴜᴛ ɴᴍᴀᴘ, ʙᴜʀᴘ, ᴍᴇᴛᴀsᴘʟᴏɪᴛ, ᴄᴛꜰ ᴛᴀsᴋs, ᴏsɪɴᴛ…%s\n' "$GR" "$NC"
}

show_about() {
  printf '\n%s╭──────────── %s𝗔𝗕𝗢𝗨𝗧%s%s ────────────╮%s\n' "$DR" "$BR" "$NC" "$DR" "$NC"
  printf '%s│%s %sTool%s     : %s𝗛𝗮𝗰𝗸𝗲𝗿𝗚𝗣𝗧%s\n'      "$DR" "$NC" "$W" "$NC" "$BR" "$NC"
  printf '%s│%s %sCreator%s  : %sTech master%s\n'       "$DR" "$NC" "$W" "$NC" "$GR" "$NC"
  printf '%s│%s %sTelegram%s : %s@tech_master_a2z%s\n'  "$DR" "$NC" "$W" "$NC" "$GR" "$NC"
  printf '%s│%s %sRole%s     : %sEthical hacking AI agent%s\n' "$DR" "$NC" "$W" "$NC" "$GR" "$NC"
  printf '%s│%s %sLicense%s  : %sEducational use only%s\n'     "$DR" "$NC" "$W" "$NC" "$GR" "$NC"
  printf '%s╰─────────────────────────────────╯%s\n\n' "$DR" "$NC"
}

# ------------------------------ MAIN ---------------------------------
main() {
  banner
  disclaimer
  check_deps

  printf '\n%s   [✓] Agent online. Type %s/help%s%s for commands.%s\n' "$GR" "$W" "$NC$GR" "$NC" "$NC"
  hr 62

  while true; do
    printf '\n%s╭─[%s%s%s%s]%s\n' "$R" "$NC" "$W" "root@hackergpt" "$NC" "$R"
    printf '%s╰──%s %s$%s ' "$R" "$NC" "$BR" "$NC"
    IFS= read -r input || break

    # trim leading/trailing whitespace
    input="${input#"${input%%[![:space:]]*}"}"
    input="${input%"${input##*[![:space:]]}"}"
    [ -z "$input" ] && continue

    case "$input" in
      /exit|/quit|exit|quit) 
        printf '\n%s   [*] Shutting down agent… Stay ethical.%s\n\n' "$GR" "$NC"
        break ;;

      /help|help)  show_help; continue ;;

      /about)      show_about; continue ;;

      /clear|clear)
        clear; banner; continue ;;

      /reset)
        HISTORY=""
        printf '\n%s   [✓] Agent memory wiped.%s\n' "$GR" "$NC"
        continue ;;

      /log)
        printf '\n%s   [i] Log file: %s%s%s\n' "$GR" "$W" "$HIST_FILE" "$NC"
        continue ;;
    esac

    say_user "$input"
    printf '%s   %s[agent thinking…]%s' "$DR" "$DIM" "$NC"

    reply=$(ask_gpt "$input")
    status=$?

    printf '\r\033[K'   # clear the "thinking" line

    if [ $status -ne 0 ] || [ -z "$reply" ]; then
      err "No response. Try again or rephrase."
      continue
    fi

    say_agent "$reply"

    add_history "USER: $input"
    add_history "AGENT: $reply"
    save_log "$input" "$reply"
  done
}

# ----------------------------- BOOT ----------------------------------
trap 'printf "\n%s\n   [!] Interrupted. Exiting…%s\n\n" "$R" "$NC"; exit 130' INT
main "$@"
