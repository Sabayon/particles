#!/bin/bash

world=/var/lib/portage/world

echo "Zeroing the world file ${world}"

echo > ${world}
