# squash
Directory squasher for linux. Compresses directory with SquashFS and overlays it with OverlayFS.

**This tool is experimental, works well form me, but needs more testing**

## Usage

The script requires root privileges. You can install it in the path, for example /usr/local/bin and `chmod +x`

### Squash Directory

`squash s <dir>`

Replace <dir> with actual path of your directory. After succesfull squashing:

* Original directory will be renamed to <dir>.orig, can be deleted.
* Hidden file .<dir>.squashfs in parent dir will contain files in SquashFS
* Hidden directory .<dir>.base in parent dir will contain read-only files SquashFS
* Directory <dir> will be upper dir of OverlayFS and merged dir in one

### Unmount Directory

`squash u <dir>`

* unmounts OverlayFS from <dir>
* unmounts SquashFS from .<dir>.base
* removes .<dir>.base (must be empty, if this fails, operation aborts)
* compresses <dir> now containing only changes into <dir>-diff.tar.gz relative to the parent dir
* removes <dir>
* renames <dir>.orig to <dir>, or if not exists unsquashes file .<dir>.squashfs into it (TBD, not yet implemented)
