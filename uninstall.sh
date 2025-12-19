#! /bin/bash

set -e

omarchy-show-logo

echo "Uninstalling theme hook.."

rm -rf /tmp/theme-hook/
rm -rf $HOME/.local/share/omarchy/bin/theme-hook-update
rm -rf $HOME/.config/omarchy/hooks/theme-set.d/
rm -rf $HOME/.config/omarchy/hooks/theme-set

echo "Uninstalled theme hook!"

omarchy-show-done
