for i in 1 2; do
   for j in 1 2; do
       echo Trying to connect from deploy/sleep-v$i to helloworld-v$j
       (kubectl exec deploy/sleep-v$i -- curl -s http://helloworld-v$j:5000/hello --max-time 2 && echo "Connection success.")|| echo "Connection Failed."
       echo
   done
done