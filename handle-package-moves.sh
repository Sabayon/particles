#!/bin/bash

# Updates particles using profiles/updates.
# Arguments: file name(s) to profiles/updates/*.
# example: this-script /usr/portage/profiles/updates/*-2012

# Assumes that packages with category foo-bar are in foo-bar.particle
# under $particles_dir.

# (C) 2012 Sławomir Nizio <slawomir.nizio#sabayon.org>
# this scripty is placed in public domain

# path to the glourious script or name if in PATH
modify_script=${modify_script:-modify.pl}

# for example: particles.git/weekly
# default value is useful when it's run from particles.git directory
particles_dir=${particles_dir:-weekly}

# don't edit this
available_after_move=()

if [[ $# -eq 0 ]]; then
	echo "$0 FILE [FILE...]" >&2
	echo "FILE = 4Q-2012, for example" >&2
	exit 1
fi

start() {
	if ! "$modify_script" --help > /dev/null; then
		echo "Looks that I can't execute $modify_script." >&2
		echo "Check if you have that script and adjust \$PATH" >&2
		echo "or \$modify_script if needed."
		exit 1
	fi
	if ! cd "$particles_dir"; then
		echo "cd $particles_dir = nope" >&2
		exit 1
	fi
	for file in "$@"; do
		readfileanddostuff "$file" || { echo "aborted"; exit 1; }
	done
	if [[ ${#available_after_move[@]} -gt 0 ]]; then
		# Here it can print invalid package names if a package was
		# renamed multiple times, or just removed since.
		echo
		echo "new candidates"
		echo "These are packages that weren't present in a particle before"
		echo "their rename, and a particle for their category exists."
		echo "Displaying them in case it's useful (whitespace separated)."
		echo "Check if they refer to packages that are really available!"
		echo "${available_after_move[@]}"
	else
		echo
		echo "No new candidates."
	fi
}

pkgmove() {
	local old="${1}"
	local new="${2}"

	echo "@@@ $old -> $new"
	oldcat=${old%/*}
	newcat=${new%/*}
	# echo "<$oldcat,$newcat>"
	if [[ ! -f $oldcat.particle ]]; then
		echo "no-file-old $oldcat.particle, skipping"
		continue
	fi

	# modify.pl currently returns success when no entry to be deleted
	# so we use this to know if new (replaced) entry should be added
	# or not
	if egrep -q "^\s*$old(,|$)" "$oldcat.particle"; then
		# removed even if new name won't be added
		"$modify_script" --noask --delete "$oldcat.particle" "$old"
		was_present=1
	else
		was_present=0
	fi

	if [[ ! -f $newcat.particle ]]; then
		echo "no-file-new $newcat.particle, skipping the rest"
		continue
	fi

	if [[ $was_present = 1 ]]; then
		"$modify_script" --noask "$newcat.particle" "$new"
	else
		# if it wasn't there before (and it's not now) and a particle
		# for this category exists (checked above), inform about it
		# maybe someone would want to add it
		if ! egrep -q "^\s*$new(,|$)" "$newcat.particle"; then
			available_after_move+=( "$new" )
		fi
	fi
}

readfileanddostuff() {
	local file=$1
	local old new
	local oldcat newcat

	echo "** $file **"
	if [[ ! -r $file ]]; then
		echo "$file doesn't exist or can't be read, or is invalid type" >&2
		return 1
	fi
	while read op old new; do
		if [[ "$op" = "move" ]]; then
			pkgmove "${old}" "${new}"
		elif [[ "$op" = "slotmove" ]]; then
			echo "slotmove not supported yet, line: ${op} ${old} ${new}"
		fi
	done < "$file"
}

start "$@"
