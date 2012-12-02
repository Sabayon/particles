#!/bin/bash
# MATTTER_PORTAGE_REPOSITORY = portage repository
# MATTER_PORTAGE_FAILED_PACKAGE_NAME = CPV of failed package

DATE_DIR=$(date +%Y-%m-%d)
SSH_ARGS="-p 2222 -o ConnectTimeout=5"
SCP_ARGS="-P 2222 -o ConnectTimeout=5"

BUILD_LOG=$(echo -n "${MATTER_PORTAGE_BUILD_LOG_DIR}/${MATTER_PORTAGE_FAILED_PACKAGE_NAME}"*.log)
if [ -z "${BUILD_LOG}" ]; then
	echo "cannot find build log, wtf??"
	exit 1
fi
if [ ! -f "${BUILD_LOG}" ]; then
	echo "cannot find build log file"
	exit 1
fi
REMOTE_DIR="~/tinderbox/${DATE_DIR}/$(uname -m)/${MATTER_PORTAGE_FAILED_PACKAGE_NAME}"

echo "Uploading ${BUILD_LOG} to tinderbox.sabayon.org..."
ssh ${SSH_ARGS} entropy@tinderbox.sabayon.org mkdir -p "${REMOTE_DIR}"
if [ "${?}" != "0" ]; then
	echo "cannot connect to tinderbox"
	exit 1
fi

tmp_path=$(mktemp --suffix=.emerge.info.txt)
emerge --info =${MATTER_PORTAGE_FAILED_PACKAGE_NAME} > "${tmp_path}"
if [ "${?}" != "0" ]; then
	rm "${tmp_path}"
        exit ${?}
fi
chmod 640 "${tmp_path}"
scp ${SCP_ARGS} "${tmp_path}" entropy@tinderbox.sabayon.org:"${REMOTE_DIR}"/
if [ "${?}" != "0" ]; then
	rm "${tmp_path}"
	exit 1
fi
rm "${tmp_path}"
scp ${SCP_ARGS} "${BUILD_LOG}" entropy@tinderbox.sabayon.org:"${REMOTE_DIR}"/ || exit 1

exit 0

