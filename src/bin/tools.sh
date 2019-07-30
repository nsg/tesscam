
has_media_permissions() {
    ls /media 2>&1 > /dev/null
}

detect_media() {
    if ! has_media_permissions; then
        echo "Unable to access /media, please run 'tesscam.detect'"
    fi
}
