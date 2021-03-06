#!/bin/bash

echo "MATTER_BUILT_PACKAGES: ${MATTER_BUILT_PACKAGES}"
echo "MATTER_REPOSITORY_ID: ${MATTER_REPOSITORY_ID}"

export EIT_NO_RESOURCES_LOCK=1

if [ -z "${MATTER_BUILT_PACKAGES}" ]; then
    echo "No kernel module packages to rebuild, exiting..."
    exit 0
fi

for pkg in ${MATTER_BUILT_PACKAGES}; do
    echo "Matching ${pkg}"
    atom=$(portageq match / "${pkg}")
    if [ -z "${atom}" ]; then
        echo "No match for ${pkg}" >&2
        continue
    fi

    p=$(portageq metadata / "installed" "${atom}" P)
    rel_path="/etc/kernels/${p}/RELEASE_LEVEL"
    if [ ! -e "${rel_path}" ]; then
        echo "No ${rel_path}, skipping..."
        continue
    fi

    tag=$(cat "${rel_path}")
    if [ -z "${tag}" ]; then
        echo "Nothing inside ${rel_path}" >&2
    fi

    echo "Rebuilding for tag: ${tag}"
    /sabayon/bin/bump_kernel_packages "${tag}" "${tag}" \
        "${MATTER_REPOSITORY_ID}" --non-interactive --disable-shell-wrap
done

exit 0
