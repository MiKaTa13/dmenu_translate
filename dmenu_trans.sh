#!/usr/local/bin/bash

# Cache
CACHE_DIR="/tmp/my_cache"
mkdir -p "$CACHE_DIR"

# Read the contents of the clipboard into a variable
CLIPBOARD_CONTENT=$(xclip -o -)
if [[ -z $CLIPBOARD_CONTENT ]]; then
  # Exit if the clipboard is empty
  exit 1
  fi

# Option to use as qutebrowser script.
SELECTED_CONTENT="${CLIPBOARD_CONTENT:-QUTE_SELECTION}"

# Set the directory path to save translations.
TRANSLATIONS_DIR="$HOME/Documents/Translations"

# Target language for translation
TARGET_LANG="uk"

 # Popup in the center of the monitor
WIN_WIDTH=700
POS_X=$((960 - WIN_WIDTH / 2))
POS_Y=540
LINE_NUM=25

# Function to generate a cache key using md5 hash
get_hash() {
  printf '%s' "$(md5 <<< "$1")"
}

# Function to translate the input data
translate() {
  trans -no-warn "$1" -b -to "$TARGET_LANG"
}

# Function to clear cache files
clear_cache() {
  rm -f "$CACHE_DIR"/*.cache
}

# Function to handle cache operations
handle_cache() {
  local cache_hash
  local input_hash
  local translated_text

# Compute the hash of the new input data
  input_hash=$(get_hash "$1")
  local cache_file="$CACHE_DIR/$input_hash.cache"

  # Check if the cache file exists
  if [[ -f $cache_file ]]; then
    # Extract hash from the first line of the cache file
    cache_hash=$(sed -n '1p' "$cache_file")
  fi

  # Compare hashes and update cache if different
  if [[ "$cache_hash" != "$input_hash" ]]; then
    clear_cache && debug $DEBUG_STATE "<<<Cache cleared.>>>"
    # Translate the input data and update the cache
    translated_text=$(translate "$1")
    printf '%s\n%s' "$input_hash" "$translated_text" > "$cache_file"
    printf '%s' "$translated_text" # Show translated text
    debug $DEBUG_STATE "<<<Caching file.>>>"
  else
    # Print cached content except the first line (hash line)
    sed '1d' "$cache_file" && debug $DEBUG_STATE "<<<Using cached file.>>>"
  fi
}

# Main function to execute the script logic
main() {
  local translated_content
  local saved_filename
  translated_content=$(handle_cache "$1")
  saved_filename="$(echo "$translated_content" | awk 'NR==2 {print $1"_"$2"_"$3}')_trans.txt"

   # Pass the translated text to 'dmenu' command
  if echo "$translated_content" | fold -s -w 80 | dmenu -l $LINE_NUM -x $POS_X -y $POS_Y -z $WIN_WIDTH > /dev/null; then
    # Check if the directory exists, if not, create it
    if [ ! -d "$TRANSLATIONS_DIR" ]; then
      mkdir -p "$TRANSLATIONS_DIR" || { echo "Failed to create translations directory." ; exit 1 ; }
    fi
    # Save the translated content, except the first line (hash line) to a file
    "$(translated_content)" > "$TRANSLATIONS_DIR/$saved_filename"
    exit 0
    fi
  }

# Call the main function with the selected content
main "$SELECTED_CONTENT"
