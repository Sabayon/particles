#!/bin/bash

. /etc/profile

# Move sabayon-hell to sabayon-limbo
export EIT_NO_RESOURCES_LOCK=1
if [ -z "$(eit list sabayon-limbo -q)" ]; then
	eit mv sabayon-hell sabayon-limbo --quick
fi

eix-update

exit 0
