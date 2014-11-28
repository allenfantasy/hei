cordova prepare && if ! pgrep node; then ripple emulate --path platforms/ios/www; exit; fi
exec <"$0" || exit; read v; read v; exec /usr/bin/osascript - "$@"; exit
tell application "Google Chrome"
  activate
  tell application "System Events"
    tell process "Google Chrome"
      keystroke "r" using {command down, shift down}
    end tell
  end tell
end tell
