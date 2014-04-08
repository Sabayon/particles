#!/bin/bash

world=/var/lib/portage/world

# echo "Generating the world file at ${world}"
# qlist -ICS > "${world}"

# Move sabayon-limbo to sabayonlinux.org
EIT_NO_RESOURCES_LOCK=1 eit mv sabayon-limbo sabayonlinux.org --quick

exit 0
