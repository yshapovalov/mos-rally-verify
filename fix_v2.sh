#!/bin/bash -xe
echo "Fix openrc file (add v2.0)"
sed -i 's|:5000|:5000/v2.0|g' /root/openrc
