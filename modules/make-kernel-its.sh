#!/usr/bin/env bash

toplevel=$1

cd $toplevel

dtb_files=($(find -L dtbs -type f -name '*.dtb'))

fdt_definition() {
    local idx=$1
    local filename=$2
    local basename=$(basename $filename)
    cat <<EOF
        fdt-${idx}{
            description = "${basename}";
            data = /incbin/("${filename}");
            type = "flat_dt";
            arch = "arm64";
            compression = "none";
            hash-1{
                algo = "sha1";
            };
        };
EOF
}

fdt_reference() {
    local idx=$1
    cat <<EOF
        conf-${idx}{
            kernel = "kernel-1";
            fdt = "fdt-${idx}";
            ramdisk = "ramdisk-1";
        };
EOF
}

cat <<EOF
/dts-v1/;

/ {
    description = "Chrome OS kernel image with one or more FDT blobs";
    images {
        kernel-1{
            description = "kernel";
            data = /incbin/("kernel.lzma");
            type = "kernel_noload";
            arch = "arm64";
            os = "linux";
            compression = "lzma";
            load = <0>;
            entry = <0>;
        };
        ramdisk-1 {
            description = "ramdisk";
            data = /incbin/("initrd");
            type = "ramdisk";
            arch = "arm64";
            os = "linux";
            compression = "none";
            hash-1 {
                algo = "sha1";
            };
        };
EOF

for index in "${!dtb_files[@]}"; do
    fdt_definition $index ${dtb_files[$index]}
done

cat <<EOF
    };
    configurations {
        default = "conf-0";
EOF

for index in "${!dtb_files[@]}"; do
    fdt_reference $index
done

cat <<EOF
    };
};
EOF
