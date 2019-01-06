# squash
Directory squasher for linux. Compresses directory with SquashFS and overlays it with OverlayFS.

**THIS UTILITY IS CURRENTLY EXPERIMENTAL, IT WORKS WELL FOR ME, BUT NEEDS MORE TESTING**

Suqsh the directory:

squash c <dir>

Replace <dir> with actual path of your directory. After succesfull squashing:

* Original directory will be renamed to <dir>.orig, can be deleted.
* Hidden file .<dir>.squash in parent dir will contain files in SquashFS
* Hidden directory .<dir>.base in parent dir will contain read-only files SquashFS
* Directory <dir> will be upper dir of OverlayFS and merged dir in one

After unmounting OverlayFS, the <dir> will contain only changes, i.e. new, modified and deleted files and dirs.

`unmount <dir>`

After unmounting SquashFS, the .<dir>.base will be empty. 

`unmount .<dir>.base`

