#!/usr/bin/env bash

toplevel=$1
shift

cd $toplevel

if [ "$#" -eq 0 ]; then
    dtb_files=($(find -L dtbs -type f -name '*.dtb'))
else
    dtb_files=("$@")
fi

fdt_definition() {
    local idx=$1
    local filename=$2
    local basename=$(basename $filename)
    cat <<EOF
        fdt@${idx}{
            description = "${basename}";
            data = /incbin/("${filename}");
            type = "flat_dt";
            arch = "arm64";
            compression = "none";
            hash@1{
                algo = "sha1";
            };
        };
EOF
}

fdt_reference() {
    local idx=$1
    cat <<EOF
        conf@${idx}{
            kernel = "kernel@1";
            fdt = "fdt@${idx}";
            ramdisk = "ramdisk@1";
        };
EOF
}

cat <<EOF
/dts-v1/;

/ {
    description = "Chrome OS kernel image with one or more FDT blobs";
    images {
        kernel@1{
            description = "kernel";
            data = /incbin/("kernel");
            type = "kernel_noload";
            arch = "arm64";
            os = "linux";
            compression = "none";
            load = <0>;
            entry = <0>;
        };
        ramdisk@1 {
            description = "ramdisk";
            data = /incbin/("initrd");
            type = "ramdisk";
            arch = "arm64";
            os = "linux";
            compression = "none";
            hash@1 {
                algo = "sha1";
            };
        };
EOF

for index in "${!dtb_files[@]}"; do
    fdt_definition $(($index + 1)) ${dtb_files[$index]}
done

cat <<EOF
    };
    configurations {
        default = "conf@1";
EOF

for index in "${!dtb_files[@]}"; do
    fdt_reference $(($index + 1))
done

cat <<EOF
    };
};
EOF
