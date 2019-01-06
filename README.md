# squash
Directory squasher for linux. Compresses directory with SquashFS and overlays it with OverlayFS.

Beside reasonable space savings, this tool provides also differential backups.
During resquash and unmount the tool generates -diff.tar.gz files that contain
all changes aplicable to main *.squashfs file. These files are not cumulative,
so user needs to store each and every -diff.tar.gz file and their order, and/or
copy full backup of the system since last resquash anytime.

First setup: squash -s <dir>
Maintenance: stop services; squash -r <dir>; start services; upload <dir>-diff.tar.gz to backup server
Uninstall:   stop services; squash -u <dir>; start services; upload <dir>-diff.tar.gz to backup server

**This tool is experimental, works well form me, but needs more testing**

## Usage

The script requires root privileges. Install it into /usr/local/bin and `chmod +x`

### Squash

`squash s <dir>`

First time. I measured 31% compression ratio from 5G of emails with default gzip.

If the <dir>.squashfs already exists, it just mounts it, so if you need to recompress, delete it.

Replace <dir> with actual path of your directory. After succesfull squashing:

* Original directory will be renamed to <dir>.orig, can be deleted.
* Hidden file .<dir>.squashfs in parent dir will contain files in SquashFS
* Hidden directory .<dir>.base in parent dir will contain read-only files SquashFS
* Directory <dir> will be upper dir of OverlayFS and merged dir in one

### Resquash

`squash r <dir>`

Maintenance resquash, needs free space of size of new squash file. It is slower
than first squash because it takes data from overlay, which has SquashFS decoding
files in the lower layer.

While unmounted, this feature creates patch called <dir>-diff.tar.gz, which can be used for backup purposes.

### Unmount

`squash u <dir>`

Unmounts overlay and squash and creates patch.

* unmounts OverlayFS from <dir>
* unmounts SquashFS from .<dir>.base
* removes .<dir>.base (must be empty, if this fails, operation aborts)
* compresses <dir> now containing only changes into <dir>-diff.tar.gz relative to the parent dir
* removes <dir>
* renames <dir>.orig to <dir>, or if not exists unsquashes file .<dir>.squashfs into it (TBD, not yet implemented)
