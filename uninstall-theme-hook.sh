#!/bin/bash

declare -a removal_errors=()

ask_yes_no() {
    local prompt="$1"
    local response
    while true; do
        read -p "$prompt (y/n): " response
        case "$response" in
            [Yy]*) return 0 ;;
            [Nn]*) return 1 ;;
            *) echo "Please answer y or n." ;;
        esac
    done
}

info() {
    echo -e "\e[34m[INFO]\e[0m $1"
}

success() {
    echo -e "\e[32m[SUCCESS]\e[0m $1"
}

warning() {
    echo -e "\e[33m[WARNING]\e[0m $1"
}

error_msg() {
    echo -e "\e[31m[ERROR]\e[0m $1"
}

if [[ ! -f "$HOME/.config/omarchy/hooks/theme-set" ]]; then
    info "Omarchy theme hook is not installed."
    exit 2
fi

echo ""
info "Omarchy Theme Hook Uninstaller"
echo "================================="
echo ""

if ! ask_yes_no "Are you sure you want to uninstall Omarchy theme hook?"; then
    info "Uninstall cancelled."
    exit 1
fi
echo ""

backup_dir=""
if ask_yes_no "Would you like to create a backup before uninstalling?"; then
    backup_dir="$HOME/omarchy-theme-hook-backup-$(date +%Y%m%d-%H%M%S)"
    mkdir -p "$backup_dir"

    if [[ -f "$HOME/.config/omarchy/hooks/theme-set" ]]; then
        cp "$HOME/.config/omarchy/hooks/theme-set" "$backup_dir/" 2>/dev/null || \
             removal_errors+=("Failed to backup theme-set")
    fi

    if [[ -d "$HOME/.config/omarchy/hooks/theme-set.d" ]]; then
        cp -r "$HOME/.config/omarchy/hooks/theme-set.d" "$backup_dir/" 2>/dev/null || \
            removal_errors+=("Failed to backup theme-set.d/")
    fi

    if [[ -f "$HOME/.local/share/omarchy/bin/theme-hook-update" ]]; then
        mkdir -p "$backup_dir/bin"
        cp "$HOME/.local/share/omarchy/bin/theme-hook-update" "$backup_dir/bin/" 2>/dev/null || \
            removal_errors+=("Failed to backup theme-hook-update")
    fi

    success "Backup created at: $backup_dir"
    echo ""
fi

info "Removing core theme hook files..."

if [[ -f "$HOME/.config/omarchy/hooks/theme-set" ]]; then
    rm "$HOME/.config/omarchy/hooks/theme-set" 2>/dev/null || \
        removal_errors+=("Failed to remove theme-set")
fi

if [[ -d "$HOME/.config/omarchy/hooks/theme-set.d" ]]; then
    rm -rf "$HOME/.config/omarchy/hooks/theme-set.d" 2>/dev/null || \
        removal_errors+=("Failed to remove theme-set.d/")
fi

if [[ -f "$HOME/.local/share/omarchy/bin/theme-hook-update" ]]; then
    rm "$HOME/.local/share/omarchy/bin/theme-hook-update" 2>/dev/null || \
        removal_errors+=("Failed to remove theme-hook-update")
fi

success "Core files removed"
echo ""

theme_dir="$HOME/.config/omarchy/current/theme"
if [[ -d "$theme_dir" ]]; then
    theme_files=(
        "alacritty.toml"
        "cava_theme"
        "chromium.theme"
        "colors.fish"
        "firefox.css"
        "fzf.fish"
        "ghostty.conf"
        "hyprland.conf"
        "hyprlock.conf"
        "kitty.conf"
        "mako.ini"
        "nwg-dock.css"
        "qt6ct.conf"
        "starship.toml"
        "steam.css"
        "superfile.toml"
        "swayosd.css"
        "vencord.theme.css"
        "vicinae.toml"
        "vscode_colors.json"
        "walker.css"
        "waybar.css"
        "zen.css"
        "zed.json"
    )

    existing_theme_files=()
    for file in "${theme_files[@]}"; do
        if [[ -f "$theme_dir/$file" ]]; then
            existing_theme_files+=("$theme_dir/$file")
        fi
    done

    if [[ ${#existing_theme_files[@]} -gt 0 ]]; then
        echo "The following generated theme files were found:"
        for file in "${existing_theme_files[@]}"; do
            echo "  - $file"
        done
        echo ""

        if ask_yes_no "Remove these generated theme files?"; then
            for file in "${existing_theme_files[@]}"; do
                rm "$file" 2>/dev/null || \
                    removal_errors+=("Failed to remove $file")
            done
            success "Generated theme files removed (${#existing_theme_files[@]} files)"
        else
            info "Skipped generated theme files"
        fi
        echo ""
    fi
fi

echo "Application-specific theme files are copied to various app config directories."
if ask_yes_no "Remove application-specific theme files?"; then

    vencord_paths=(
        "$HOME/.config/Vencord/themes/vencord.theme.css"
        "$HOME/.config/vesktop/themes/vencord.theme.css"
        "$HOME/.config/Equicord/themes/vencord.theme.css"
        "$HOME/.config/equibop/themes/vencord.theme.css"
        "$HOME/.var/app/dev.vencord.Vesktop/config/vesktop/themes/vencord.theme.css"
    )

    for path in "${vencord_paths[@]}"; do
        if [[ -f "$path" ]]; then
            rm "$path" 2>/dev/null || removal_errors+=("Failed to remove $path")
        fi
    done

    if [[ -f "$HOME/.config/nwg-dock-hyprland/colors.css" ]]; then
        rm "$HOME/.config/nwg-dock-hyprland/colors.css" 2>/dev/null || \
            removal_errors+=("Failed to remove nwg-dock colors.css")
    fi

    if [[ -f "$HOME/.config/qt6ct/colors/omarchy.conf" ]]; then
        rm "$HOME/.config/qt6ct/colors/omarchy.conf" 2>/dev/null || \
            removal_errors+=("Failed to remove qt6ct omarchy.conf")
    fi

    if [[ -d "$HOME/.config/spicetify/Themes/omarchy" ]]; then
        rm -rf "$HOME/.config/spicetify/Themes/omarchy" 2>/dev/null || \
            removal_errors+=("Failed to remove spicetify theme")
    fi

    if [[ -f "$HOME/.config/superfile/theme/omarchy.toml" ]]; then
        rm "$HOME/.config/superfile/theme/omarchy.toml" 2>/dev/null || \
            removal_errors+=("Failed to remove superfile theme")
    fi

    if [[ -f "$HOME/.local/share/vicinae/themes/omarchy.toml" ]]; then
        rm "$HOME/.local/share/vicinae/themes/omarchy.toml" 2>/dev/null || \
            removal_errors+=("Failed to remove vicinae theme")
    fi

    if [[ -f "$HOME/.config/zed/themes/omarchy.json" ]]; then
        rm "$HOME/.config/zed/themes/omarchy.json" 2>/dev/null || \
            removal_errors+=("Failed to remove zed theme")
    fi

    if [[ -f "$HOME/.config/cava/themes/omarchy" ]]; then
        rm "$HOME/.config/cava/themes/omarchy" 2>/dev/null || \
            removal_errors+=("Failed to remove cava theme")
    fi

    if [[ -f "$HOME/.config/cava/config" ]]; then
        if grep -q "theme = 'omarchy'" "$HOME/.config/cava/config"; then
            sed -i "/theme = 'omarchy'/d" "$HOME/.config/cava/config" 2>/dev/null || \
                removal_errors+=("Failed to remove omarchy theme from cava config")
        fi
    fi

    if command -v firefox >/dev/null 2>&1; then
        find_firefox_profile() {
            awk -F= '
                /^\[Install/ { in_install=1 }
                in_install && /^Default=/ { print $2; exit }
            ' "$HOME/.mozilla/firefox/profiles.ini" 2>/dev/null
        }

        firefox_profile_name=$(find_firefox_profile)
        if [[ -n "$firefox_profile_name" ]]; then
            firefox_profile="$HOME/.mozilla/firefox/$firefox_profile_name"
            if [[ -d "$firefox_profile/chrome" ]]; then
                if [[ -f "$firefox_profile/chrome/colors.css" ]]; then
                    rm "$firefox_profile/chrome/colors.css" 2>/dev/null || \
                        removal_errors+=("Failed to remove Firefox colors.css")
                fi

                prefs_file="$firefox_profile/prefs.js"
                if [[ -f "$prefs_file" ]]; then
                    if grep -q 'user_pref("toolkit.legacyUserProfileCustomizations.stylesheets", true)' "$prefs_file"; then
                        sed -i.bak 's/user_pref("toolkit.legacyUserProfileCustomizations.stylesheets", true);/user_pref("toolkit.legacyUserProfileCustomizations.stylesheets", false);/' "$prefs_file" 2>/dev/null || \
                            removal_errors+=("Failed to disable Firefox userchrome")
                    fi
                fi
            fi
        fi
    fi

    if command -v zen-browser >/dev/null 2>&1; then
        find_zen_profile() {
            awk -F= '
                /^\[Install/ { in_install=1 }
                in_install && /^Default=/ { print $2; exit }
            ' "$HOME/.zen/profiles.ini" 2>/dev/null
        }

        zen_profile_name=$(find_zen_profile)
        if [[ -n "$zen_profile_name" ]]; then
            zen_profile="$HOME/.zen/$zen_profile_name"
            if [[ -d "$zen_profile/chrome" ]]; then
                if [[ -f "$zen_profile/chrome/colors.css" ]]; then
                    rm "$zen_profile/chrome/colors.css" 2>/dev/null || \
                        removal_errors+=("Failed to remove Zen Browser colors.css")
                fi

                prefs_file="$zen_profile/prefs.js"
                if [[ -f "$prefs_file" ]]; then
                    if grep -q 'user_pref("toolkit.legacyUserProfileCustomizations.stylesheets", true)' "$prefs_file"; then
                        sed -i.bak 's/user_pref("toolkit.legacyUserProfileCustomizations.stylesheets", true);/user_pref("toolkit.legacyUserProfileCustomizations.stylesheets", false);/' "$prefs_file" 2>/dev/null || \
                            removal_errors+=("Failed to disable Zen Browser userchrome")
                    fi
                fi
            fi
        fi
    fi

    success "Application-specific files processed"
else
    info "Skipped application-specific files"
fi
echo ""

if [[ -d "$HOME/.local/share/steam-adwaita" ]]; then
    echo "Steam theme uses a cloned git repository with modifications."
    echo "Options:"
    echo "  1. Remove only Omarchy-specific files (keep Adwaita-for-Steam)"
    echo "  2. Remove entire steam-adwaita directory"
    echo "  3. Skip Steam theme cleanup"
    echo ""
    read -p "Choose option (1/2/3): " steam_choice

    case "$steam_choice" in
        1)
            if [[ -d "$HOME/.local/share/steam-adwaita/adwaita/colorthemes/omarchy" ]]; then
                rm -rf "$HOME/.local/share/steam-adwaita/adwaita/colorthemes/omarchy" 2>/dev/null || \
                    removal_errors+=("Failed to remove Steam omarchy theme")
            fi

            install_py="$HOME/.local/share/steam-adwaita/install.py"
            if [[ -f "$install_py" ]]; then
                if grep -q '"omarchy"' "$install_py"; then
                    sed -i.bak 's/, "omarchy"//g' "$install_py" 2>/dev/null || \
                        removal_errors+=("Failed to remove omarchy from Steam install.py")
                fi
            fi
            success "Removed Omarchy-specific Steam files"
            ;;
        2)
            rm -rf "$HOME/.local/share/steam-adwaita" 2>/dev/null || \
                removal_errors+=("Failed to remove steam-adwaita directory")
            success "Removed entire steam-adwaita directory"
            ;;
        3)
            info "Skipped Steam theme cleanup"
            ;;
        *)
            warning "Invalid choice. Skipping Steam theme cleanup"
            ;;
    esac
    echo ""
fi

if command -v pacman >/dev/null 2>&1; then
    if pacman -Qi "adw-gtk-theme" &>/dev/null; then
        echo "The package 'adw-gtk-theme' was installed as a prerequisite."
        if ask_yes_no "Uninstall adw-gtk-theme package? (requires sudo)"; then
            if sudo pacman -R adw-gtk-theme 2>/dev/null; then
                success "Uninstalled adw-gtk-theme"
            else
                removal_errors+=("Failed to uninstall adw-gtk-theme")
            fi
        else
            info "Kept adw-gtk-theme installed"
        fi
        echo ""
    fi
fi

if [[ ${#removal_errors[@]} -gt 0 ]]; then
    echo "================================="
    warning "Errors encountered during uninstallation:"
    echo "================================="
    for err in "${removal_errors[@]}"; do
        echo "  ✗ $err"
    done
    echo ""
fi

echo "================================="
echo "Uninstall Summary"
echo "================================="
echo "✓ Core theme hook files removed"
echo "✓ Theme scripts removed"
if [[ -n "$backup_dir" && -d "$backup_dir" ]]; then
    echo "✓ Backup created at: $backup_dir"
fi
echo "================================="
echo ""
success "Omarchy theme hook has been uninstalled"
echo ""
echo "Note: Your system themes may still be applied until you:"
echo "  - Restart affected applications"
echo "  - Apply a different theme manually"
echo ""

if [[ ${#removal_errors[@]} -gt 0 ]]; then
    exit 1
else
    exit 0
fi
