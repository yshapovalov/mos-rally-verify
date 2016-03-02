#!/bin/bash -xe
echo "Fix openrc file (add v2.0)"
cmd="sed -i 's|:5000|:5000/v2.0|g' /root/openrc"
for n in $(fuel node | grep controller| awk '{print$1}'); do ssh node-"$n" "$cmd"; done
