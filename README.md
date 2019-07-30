# Tesscam

This snap scans removable media for TeslaCam directories, it will merge the files to one long video for easier viewing.

## Install
```
snap install --edge tesscam
```

## Commands

### Detect

`tesscam.detect` is used to detect if you have all permissions setup.

### List

To list all saved clips, insert the USB-key and run `tesscam.list`. The output of the command can be piped in to encode.

### Encode

Pipe one of more saved clips directories to merge and encode them to a single video file.

```
tesscam.list | tesscam.encode
```

... or maybe filter it down a little :)

```
tesscam.list | grep 2019-07-28 | tesscam.encode
```

The output will end up in `$SNAP_USER_DATA`, that's probably `~/snap/tesscam/`