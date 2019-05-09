
. $(dirname ${BASH_SOURCE})/../util.sh

SOURCE_DIR=$PWD

desc "Cleaning up"
read -s
tmux send-keys -t 5 C-c
tmux send-keys -t 5 "exit" C-m
tmux send-keys -t 4 C-c
tmux send-keys -t 4 "exit" C-m
tmux send-keys -t 3 C-c
tmux send-keys -t 3 "exit" C-m
tmux send-keys -t 2 C-c
tmux send-keys -t 2 "exit" C-m
tmux send-keys -t 1 C-c
tmux send-keys -t 1 "exit" C-m

