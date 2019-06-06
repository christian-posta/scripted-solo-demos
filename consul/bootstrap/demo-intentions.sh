
. $(dirname ${BASH_SOURCE})/../../util.sh

SOURCE_DIR=$PWD

tmux select-pane -t 0

tmux split-window -v -d -c $SOURCE_DIR
tmux select-pane -t 0
tmux send-keys -t 1 "nc 127.0.0.1 9191" C-m



read -s
desc "Let's end the connection to netcat upstream"
tmux send-keys -t 1 C-c
read -s
desc "Deny access to socat from web"
run "consul intention create -deny web2 socat"
read -s

tmux send-keys -t 1 "nc 127.0.0.1 9191" C-m

read -s
backtotop
desc "Let's delete the intention"
run "consul intention delete web2 socat"

read -s
desc "Let's try connect again to the socat upstream"
tmux send-keys -t 1 C-c
tmux send-keys -t 1 "nc 127.0.0.1 9191" C-m

tmux select-pane -t 1
