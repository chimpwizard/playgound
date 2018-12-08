packer build \
    --only=virtualbox-iso \
    --var iso_url=rhel-server-5.9-x86_64-dvd.iso \
    --var iso_checksum=F185197AF68FAE4F0E06510A4579FC511BA27616 \
    --var iso_checksum_type=sha1 \
    ./image-specs.json
