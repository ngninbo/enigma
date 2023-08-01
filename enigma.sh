#!/usr/bin/env bash
# shellcheck disable=SC2162
welcome="Welcome to the Enigma!"
filename_msg="Enter the filename:"
file_not_found="File not found!"
z=90
a=65
#alphabet='A-Z'
#shifted_alphabet="D-ZA-C"
space=32
key=3

function out_menu() {
  options=("Exit" "Create a file" "Read a file" "Encrypt a file" "Decrypt a file")

  for ((i = 0; i < ${#options[@]}; i++)); do
    printf "%s. %s\n" "$i" "${options[i]}"
  done
}

function main() {
  printf "%s\n\n" "$welcome"

  while
    true

    out_menu
    echo "Enter an option:" && read option
  do

    case $option in
    0) echo "See you later!" && exit;;
    1) create_file ;;
    2) read_file ;;
    3) ssl_cipher "e" ;;
    4) ssl_cipher "d" ;;
    *)
      echo "Invalid option!"
      ;;
    esac
  done
}

function create_file() {
  printf "%s\n" "$filename_msg" && read filename
  if [[ "$filename" =~ ^[a-zA-Z.]+$ ]]; then
    echo "Enter a message:" && read msg
    if [[ $(check_input "$msg") == true ]]; then
      echo "$msg" >> "$filename"
      printf "The file was created successfully!\n\n"
    else
      printf "This is not a valid message!\n\n"
    fi
  else
    printf "File name can contain letters and dots only!\n\n"
  fi
}

function read_file() {
  printf "%s\n" "$filename_msg" && read filename
  if [[ -f "$filename" ]]; then
    printf "File content:\n%s\n\n" "$(cat "$filename")"
  else
    printf "%s\n\n" "$file_not_found"
  fi
}

function ssl_cipher() {
  printf "%s\n" "$filename_msg" && read file_name
  if [[ -f "$file_name" ]]; then
    echo "Enter password:" && read -s password
    output_file="$([[ $1 == "e" ]] && echo "$file_name.enc" || echo "${file_name%.*}")"
    openssl enc -aes-256-cbc "-$1" -pbkdf2 -nosalt -in "$file_name" -out "$output_file" -pass pass:"$password" &>/dev/null
    remove_file_on_success "$file_name" $?
  else
    printf "%s\n\n" "$file_not_found"
  fi
}

function remove_file_on_success() {
  if [[ $2 -ne 0 ]]; then
    echo "Fail"
  else
    rm "$1"
    printf "Success\n\n"
  fi
}

function encryption() {
  printf "Type 'e' to encrypt, 'd' to decrypt a message:\nEnter a command:\n" && read command
  if [[ "$command" =~ ^[d-e]$ ]]; then
    echo "Enter a message:" && read message
    if [[ $(check_input "$message") == true ]]; then
      decrypt_or_encrypt_text "$message" "$command"
    else
      echo "This is not a valid message!" && exit
    fi
  else
    printf "Invalid command!\n\n"
  fi
}

function decrypt_or_encrypt_text() {
  case $2 in
  e) encrypt_text "$1" ;;
  d) decrypt_text "$1" ;;
  *) ;;

  esac
}

function encrypt_file() {
  printf "%s\n" "$filename_msg" && read filename
  if [[ -f "$filename" ]]; then
    text="$(encrypt_text "$(cat "$filename")")"
    echo "$text" >> "$filename.esc"
  else
    printf "%s\n\n" "$file_not_found"
  fi
}

function decrypt_file() {
  printf "%s\n" "$filename_msg" && read filename
  if [[ -f "$filename" ]]; then
    text="$(decrypt_text "$(cat "$filename")")"
    echo "$text" >> "${filename%.*}"
    rm "$filename"
    printf "Success\n\n"
  else
    printf "%s\n\n" "$file_not_found"
  fi
}

function encrypt_text() {
  message=$1
  result=""
  for ((i = 0; i < ${#message}; i++)); do
    char=${message:$i:1}
    value=$(val "$char")
    if [[ $value -eq $space ]]; then
      result=$(printf "%s%s" "$result" "$char")
    else
      result=$(printf "%s%s" "$result" "$(shift_letter_right "$char" $key)")
    fi
  done
  #printf "Encrypted message:\n%s\n" "$(echo "$1" | tr $alphabet $shifted_alphabet)"
  printf "%s\n" "$result"
}

function decrypt_text() {
  message=$1
  result=""
  for ((i = 0; i < ${#message}; i++)); do
    char=${message:$i:1}
    value=$(val "$char")
    if [[ $value -eq $space ]]; then
      result=$(printf "%s%s" "$result" "$char")
    else
      result=$(printf "%s%s" "$result" "$(shift_letter_left "$char" $key)")
    fi
  done
  #printf "Decrypted message:\n%s\n" "$(echo "$1" | tr $shifted_alphabet $alphabet)"
  printf "%s\n" "$result"
}

function check_input() {
  re='^[A-Z ]+$'
  [[ "$1" =~ $re ]] && echo true || echo false
}

function is_uppercase_letter() {
  [[ "$1" =~ ^[A-Z]$ ]] && echo true || echo false
}

function is_digit() {
  [[ "$1" =~ ^[0-9]$ ]] && echo true || echo false
}

function shift_letter_right() {
  value=$(val "$1")

  for ((i = 1; i <= $2; i++)); do
    ((value++))
    if [ "$value" -gt $z ]; then
      value=$a
    fi
  done

  printf "%s" "$(character "$value")"
}

function shift_letter_left() {
  value=$(val "$1")

  for ((i = 1; i <= $2; i++)); do
    ((value--))
    if [ "$value" -lt $a ]; then
      value=$z
    fi
  done

  printf "%s" "$(character "$value")"
}

function character() {
  printf "%b" "$(printf "\\%03o" "$1")"
}

function val() {
  printf "%d\n" "'$1"
}

main
