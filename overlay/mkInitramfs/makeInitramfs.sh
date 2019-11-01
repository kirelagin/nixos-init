source $stdenv/setup


mkdir -p "$out/etc"
# systemd uses this file to detect that it is in initramfs
cat > "$out"/etc/inird-release <<EOF
NAME=NixOS Stage 1
ID=nixos-stage1
ID_LIKE=nixos
PRETTY_NAME=NixOS Stage 1
EOF
