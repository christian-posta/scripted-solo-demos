
. $(dirname ${BASH_SOURCE})/../util.sh

SOURCE_DIR=$PWD
tmux split-window -v -d -c $SOURCE_DIR
tmux select-pane -t 0
tmux send-keys -t 1 "consul agent -dev -config-dir=./consul.d" C-m

desc "Check cluster members"
read -s
run "consul members"

desc "Start some services"
read -s

tmux select-pane -t 1
tmux split-window -h -d -c $SOURCE_DIR
tmux send-keys -t 2 "socat -v tcp-l:8181,fork exec:\"/bin/cat\"" C-m
tmux select-pane -t 0

tmux select-pane -t 2
tmux split-window -v -d -c $SOURCE_DIR
tmux send-keys -t 3 "nc 127.0.0.1 8181" C-m
tmux select-pane -t 0

desc "Start the sidecar proxy for socat"
read -s

tmux select-pane -t 2
tmux split-window -v -d -c $SOURCE_DIR
tmux send-keys -t 3 "consul connect proxy -sidecar-for socat" C-m
tmux select-pane -t 0

desc "Start a proxy for web with upstream socat (connect locally 9191)"
read -s

tmux select-pane -t 4
tmux split-window -v -d -c $SOURCE_DIR
tmux send-keys -t 5 "consul connect proxy -sidecar-for web2" C-m
tmux select-pane -t 0

read -s

desc "Let's connec to socat via the proxy; the upstream is exposed on localhost:9191"
read -s
run "nc 127.0.0.1 9191"
