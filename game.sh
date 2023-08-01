#!/usr/bin/env bash
# shellcheck disable=SC2001
# shellcheck disable=SC2162
credentials_filename="ID_card.txt"
cookie_filename="cookie.txt"
welcome="Welcome to the True or False Game!"
congratulations=( "Perfect!" "Awesome!" "You are a genius!" "Wow!" "Wonderful!" )
scores_file="scores.txt"
not_found_or_score_empty="File not found or no scores in it!"

# stage 1
function get_credentials() {
 curl --silent --output "$credentials_filename" http://127.0.0.1:8000/download/file.txt
 #cat $credentials_filename
}

# stage 2
function login() {
 username=$(cut -d '"' -f 4 "$credentials_filename")
 password=$(cut -d '"' -f 8 "$credentials_filename")
 curl http://127.0.0.1:8000/login --cookie-jar "$cookie_filename" --user "$username":"$password"
 #printf 'Login message: %s\n' "$(cat "$cookie_filename")"
 #printf 'Login message: %s\n' "$message"
}

 # stage 3
function get_question() {
  username=$(cut -d '"' -f 4 "$credentials_filename")
  password=$(cut -d '"' -f 8 "$credentials_filename")
  response=$(curl http://127.0.0.1:8000/game --user "$username":"$password" --cookie "$cookie_filename")
  printf 'Response: %s\n' "$response"
  return "$response"
}

function out_menu() {
  options=("Exit" "Play a game" "Display scores" "Reset scores")

  for ((i = 0; i < ${#options[@]}; i++)); do
    printf "%s. %s\n" "$i" "${options[i]}"
  done
}

# stage 5
function play_game() {
  RANDOM=4096
  echo "What is your name?" && read name
  answered_question=0
  scores=0
  #question=$(python3 -c "data=$item; print(data.get('question'))")

  while true; do
      item=$(get_question)
      question="$(echo "$item" | sed 's/.*"question": *"\{0,1\}\([^,"]*\)"\{0,1\}.*/\1/')"
      printf "%s\n%s\n" "$question" "True or False?" && read answer
      expected_answer="$(echo "$item" | sed 's/.*"answer": *"\{0,1\}\([^,"]*\)"\{0,1\}.*/\1/')"
      if [[ "$answer" == "$expected_answer" ]]; then
        ((scores+=10))
        ((answered_question++))
        idx=$((RANDOM % ${#congratulations[@]}))
        printf "%s\n\n" "${congratulations[$idx]}"
      else
        printf "User: %s, Score: %d, %s\n" "$name" "$scores" "$(date "+Date: %Y-%m-%d")" >> "$scores_file"
        printf "Wrong answer, sorry!\n%s you have %s correct answer(s).\nYour score is %s points.\n" "$name" "$answered_question" "$scores" && break
      fi
  done
}

function display_scores() {
    if [[ -f $scores_file && -s $scores_file ]]; then
      printf "Player scores\n%s\n" "$(cat "$scores_file")"
    else
      printf "%s\n\n" "$not_found_or_score_empty"
    fi
}

function reset_scores() {
    if [[ -f $scores_file && -s $scores_file ]]; then
      rm "$scores_file"
      echo "File deleted successfully!"
    else
      printf "%s\n\n" "$not_found_or_score_empty"
    fi
}

# stage 4
function main() {
  printf "%s\n\n" "$welcome"
  get_credentials
  login

  while
    true

    out_menu
    echo "Enter an option:" && read option
  do

    case $option in
    0) echo "See you later!" && exit;;
    1) play_game ;;
    2) display_scores ;;
    3) reset_scores ;;
    *)
      echo "Invalid option!"
      ;;
    esac
  done
}

main