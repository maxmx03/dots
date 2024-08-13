#!/bin/bash
export DOTS_DIR="${XDG_DATA_HOME:-$HOME}/dotfiles"
export DOTS_DATA_FILE="$DOTS_DIR/dots.txt"

function _dots_remove() {
  declare config answer
  config=$(gum choose $(grep "" "$DOTS_DATA_FILE"))

  if [ -n "$config" ] && [ -e "$HOME/$config" ]; then
    gum style --foreground 37 "the followings commands are going to be executed:"
    gum style --foreground 160 "rm -rf $HOME/$config"
    gum confirm "proceed with these commands?" && answer="y"

    if [ "$answer" = "y" ]; then
      gum spin --spinner dot --title "removing $HOME/$config" -- sleep 3
      rm -rf "$HOME/$config"
      gum log --structured --level info "the $HOME/$config has been removed"
    else
      gum log --structured --level info "operation canceled"
    fi
  else
    gum log --structured --level error "config not found"
  fi
}

function _dots_list() {
  if [ ! -e "$DOTS_DATA_FILE" ]; then
    touch "$DOTS_DATA_FILE"
  fi
  gum pager <"$DOTS_DATA_FILE"
}

function _dots_installation() {
  declare config answer
  config=$1

  gum style --foreground 37 "the followings commands are going to be executed:"
  gum style --foreground 160 "cp -r $DOTS_DIR/$config $HOME/$config"
  gum confirm "proceed with these commands?" && answer="y"

  if [ "$answer" = y ]; then
    gum spin --spinner dot --title "installing $DOTS_DIR/$config to $HOME/$config" -- sleep 3
    cp -r "$DOTS_DIR/$config" "$HOME/$config"
    gum log --structured --level info "the $config has been installed"
  else
    gum log --structured --level info "operation canceled"
  fi
}

function _dots_add() {
  gum write --placeholder "You can add multiple config ex: .config/nvim .config/kitty" >>"$DOTS_DATA_FILE"
}

function _dots_install() {
  declare config answer
  config=$(gum choose $(grep "" "$DOTS_DATA_FILE"))

  if [ "$DOTS_DIR/$config" == ".bashrc" ]; then
    echo >>"$HOME/.bashrc"
    gum spin --spinner dot --title "installing $config..." -- sleep 3
    exit 1
  fi

  if [ -n "$config" ]; then
    if [ -e "$HOME/$config" ]; then
      gum style --foreground 37 "'$HOME/$config' already exists."
      gum confirm "Do you want to overwrite it?" && answer="y"

      if [ "$answer" = "y" ]; then
        gum spin --spinner dot --title "removing '$HOME/$config..." -- sleep 3
        rm -rf "$HOME/$config"
        _dots_installation "$config"
      else
        gum log --structured --level info "operation canceled: $answer"
      fi
    else
      _dots_installation "$config"
    fi
  else
    gum log --structured --level error "config not found"
  fi
}

function _dots_update() {
  declare config answer
  config=$(gum choose $(grep "" "$DOTS_DATA_FILE"))

  if [ -n "$config" ] || [ -e "$HOME/$config" ]; then
    gum style --foreground 37 "the followings commands are going to be executed:"
    gum style --foreground 160 "rm -rf '$DOTS_DIR/$config'"
    gum style --foreground 160 "cp -r '$HOME/$config' '$DOTS_DIR/$config'"
    gum confirm "proceed with these commands?" && answer="y"

    if [ "$answer" = "y" ]; then
      gum spin --spinner dot --title "removing '$DOTS_DIR/$config'..." -- sleep 5
      rm -rf "$DOTS_DIR/$config"
      gum style --foreground 37 "copying '$HOME/$config' to '$DOTS_DIR/$config'"
      gum spin --spinner dot --title "copying '$HOME/$config' to '$DOTS_DIR/$config'..." -- sleep 5
      cp -r "$HOME/$config" "$DOTS_DIR/$config"
      gum log --structured --level info "the $DOTS_DIR/$config  has been updated"
    else
      gum log --structured --level info "operation canceled"
    fi
  else
    gum log --structured --level error "$config not found"
  fi
}

function _dots_exit() {
  exit 1
}

function dots() {
  declare DOTS_CMD
  DOTS_CMD=$(gum choose --limit 1 "add" "install" "update" "list" "remove" "exit")

  declare -A subcmds=(
    [update]="_dots_update"
    [add]="_dots_add"
    [install]="_dots_install"
    [list]="_dots_list"
    [remove]="_dots_remove"
    [exit]="_dots_exit"
  )

  if [[ -n "${subcmds[$DOTS_CMD]}" ]]; then
    ${subcmds[$DOTS_CMD]}
  fi
}
