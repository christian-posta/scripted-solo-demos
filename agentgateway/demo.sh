. $(dirname ${BASH_SOURCE})/../util.sh
SOURCE_DIR=$PWD




backtotop
desc "We will use agent gateway to implement MCP policy"
read -s

run "agentgateway --help"

desc "Let's take a look at a basic resource"
run "cat resources/basic.yaml"

desc "Let's run the agent gateway with this basic configuration"
desc "Go to http://localhost:15000/ui to run the demo"

run "agentgateway -f resources/basic.yaml"


backtotop
desc "Let's take a look at Multiplexing"
read -s

desc "Let's take a look at a configuration with multiple backends"
run "cat resources/multiplex.yaml"

run "agentgateway -f resources/multiplex.yaml"


backtotop
desc "Let's take a look at Authorization"
read -s

desc "Let's take a look at locking down with auth"
run "cat resources/authorization.yaml"

desc "We will need a few JWT tokens for this. First one is an authenticated user"
desc "but does not have any nested claims:"
run "cat resources/jwt/example2.key"

desc "This second JWT is an auth'd user and has nested claims:"
run "cat resources/jwt/example1.key"

run "agentgateway -f resources/authorization.yaml"


backtotop
desc "Combine auth with multiplexing: virtual MCP service"
read -s

desc "Let's take a look at locking down with auth"
run "cat resources/virtualmcp.yaml"

run "agentgateway -f resources/virtualmcp.yaml"


backtotop
desc "Let's take a look at Tracing / Observability"
read -s

desc "In another window, run the following and press enter to continue:"
desc "docker compose up"
read -s

desc "You can query for metrics with the following:"
desc "curl localhost:15020/metrics -s | grep -v '#'"
read -s

run "cat resources/tracing.yaml"


run "agentgateway -f resources/tracing.yaml"




