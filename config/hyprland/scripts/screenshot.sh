grim -g "$(slurp -d)" - | wl-copy && wl-paste > "$HOME/Pictures/Screenshots/Screenshot-$(date +'%Y-%m-%d_%H-%M-%S').png" && notify-send -t 3000 "Screenshot" "Screenshot saved and copied to clipboard"
