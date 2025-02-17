#!/bin/bash

# Invoke the kind script
source installkind.sh
# Wait for 5 sec
sleep 5

# Invoke the metallb script
source installmetallb.sh
