echo "add the following:"

cat << EOF
    sniDomains:
    - ceposta-apis-demo.solo.io
EOF

echo "Enter to continue"
read -s

kubectl edit virtualservice -n dev-portal petstore-portal