#!/bin/bash
	
# see here: https://misc.flogisoft.com/bash/tip_colors_and_formatting
readonly FGRED="\e[31m"
readonly FGGREEN="\e[32m"
readonly FGCYAN="\e[36m"
readonly FGDEFAULT="\e[39m"
readonly SETBOLD="\e[1m"
readonly CLRBOLD="\e[21m"

die() { echo -e "${FGRED}$*\n" >&2 ; exit 1; }

if [ $EUID -ne 0 ]; then die "This utility can be only used by root"; fi

must() {
	"$@"
	local err=$?
	if [ $err -ne 0 ]; then echo -e "${FGRED}${BASH_SOURCE[0]}(${BASH_LINENO[0]}) error: ${SETBOLD}$@${CLRBOLD}${FGDEFAULT}" >$2; exit $err; fi
}

createData() {
	if [ -d data ]; then
		must rm -r data
	fi
	must mkdir data
	must cp -R /etc/* data
	must ../squash s data
	must rm -r data.orig

	# new file
	echo "Hello squash!" > data/test1.txt
	# modified file
	echo "Hello squash!" >> data/network/interfaces
	# removed file
	rm data/passwd
	# new dir
	mkdir data/newdir
	# new really long dir with spaces in it
	mkdir -p "data/very/long/dir/wait up/its not done yet/this dir/goes all the way here/newdir"
	# remove dir
	rm -r data/init

	# todo: experimental whiteout processing on tar.* patch
	# OverlayFS whiteouts are saved in tar sa character devices and tar does
	# not do anything with them, so I am going to precess them. First delete
	# files and directories, then after tar is extracted, remove the special
	# files that whiteouts created
	must ../squash u data
	tar -tvf data-diff.tar.gz | grep '^c---------.*0,0' > whiteouts.txt
	processWhiteouts whiteouts.txt
	echo "Extracting the patch data-diff.tar.gz"
	tar -xf data-diff.tar.gz
	processWhiteouts whiteouts.txt
	rm whiteouts.txt

	rm data-diff.tar.gz
	rm .data.squashfs
}

processWhiteouts() {
	while IFS='' read -r line || [[ -n "$line" ]]; do 
		file=${line:48}
		if [ -f $file ]; then echo "Deleting file $file"; rm $file; fi
		if [ -d $file ]; then echo "Deleting dir $file"; rm -rf $file; fi
		if [ -c $file ]; then echo "Deleting char device $file"; unlink $file; fi
	done < "$1"
}

createData