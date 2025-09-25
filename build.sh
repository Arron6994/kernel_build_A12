#!/bin/bash
# Xiaomi 12 Pro (Zeus) Kernel Build Script
# Android 12 - Kernel 5.10.* with KernelSU-Next and SusFS support

set -e

# Configuration
DEVICE="zeus"
DEVICE_FULL_NAME="Xiaomi 12 Pro"
ANDROID_VERSION="12"
KERNEL_VERSION="5.10"
ARCH="arm64"
SUBARCH="arm64"

# Paths
KERNEL_DIR="$(pwd)/kernel"
TOOLCHAIN_DIR="$(pwd)/toolchain"
OUT_DIR="$(pwd)/out"
ANYKERNEL_DIR="$(pwd)/AnyKernel3"

# Toolchain Configuration
TOOLCHAIN_URL="https://android.googlesource.com/platform/prebuilts/gcc/linux-x86/aarch64/aarch64-linux-android-4.9"
CLANG_URL="https://android.googlesource.com/platform/prebuilts/clang/host/linux-x86"

# KernelSU Configuration
KERNELSU_ENABLED=true
KERNELSU_URL="https://github.com/KernelSU-Next//KernelSU-Next"
KERNELSU_BRANCH="next"

# SusFS Configuration  
SUSFS_ENABLED=true
SUSFS_URL="https://github.com/sidex15/SusFS4KernelSU"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to clone or update repository
clone_or_update() {
    local url=$1
    local dir=$2
    local branch=${3:-"main"}

    if [ -d "$dir" ]; then
        log_info "Updating $dir..."
        cd "$dir"
        git fetch origin
        git reset --hard origin/$branch
        cd - > /dev/null
    else
        log_info "Cloning $url to $dir..."
        git clone --depth=1 -b "$branch" "$url" "$dir"
    fi
}

# Function to setup toolchain
setup_toolchain() {
    log_info "Setting up toolchain..."

    # Create toolchain directory
    mkdir -p "$TOOLCHAIN_DIR"

    # Download and setup clang
    if [ ! -d "$TOOLCHAIN_DIR/clang" ]; then
        log_info "Downloading Clang toolchain..."
        cd "$TOOLCHAIN_DIR"
        git clone --depth=1 https://gitlab.com/vermouth/android_prebuilts_clang_host_linux-x86_clang-r536225.git clang
        cd - > /dev/null
    fi

    # Setup cross-compile toolchain
    if [ ! -d "$TOOLCHAIN_DIR/gcc" ]; then
        log_info "Downloading GCC toolchain..."
        cd "$TOOLCHAIN_DIR"
        git clone --depth=1 https://github.com/LineageOS/android_prebuilts_gcc_linux-x86_aarch64_aarch64-linux-android-4.9 gcc
        cd - > /dev/null
    fi
}

# Function to setup kernel source
setup_kernel() {
    log_info "Setting up kernel source..."

    if [ ! -d "$KERNEL_DIR" ]; then
        log_error "Kernel source directory not found!"
        log_info "Please place your Xiaomi 12 Pro kernel source in: $KERNEL_DIR"
        log_info "You can clone it from: https://github.com/Arron6994/kernel_build_A12"
        log_info "Branch: main (for Android 12)"
        exit 1
    fi
}

# Function to setup KernelSU
setup_kernelsu() {
    if [ "$KERNELSU_ENABLED" = true ]; then
        log_info "Setting up KernelSU-Next..."

        # Clone KernelSU
        clone_or_update "$KERNELSU_URL" "$KERNEL_DIR/KernelSU" "$KERNELSU_BRANCH"

        # Apply KernelSU patches
        cd "$KERNEL_DIR"
        if [ ! -f ".kernelsu_applied" ]; then
            log_info "Applying KernelSU patches..."

            # Apply basic KernelSU integration
            if [ -f "KernelSU/kernel/setup.sh" ]; then
                bash KernelSU/kernel/setup.sh
            fi

            touch .kernelsu_applied
            log_success "KernelSU patches applied"
        else
            log_info "KernelSU patches already applied"
        fi
        cd - > /dev/null
    fi
}

# Function to setup SusFS
setup_susfs() {
    if [ "$SUSFS_ENABLED" = true ]; then
        log_info "Setting up SusFS..."

        # Clone SusFS
        clone_or_update "$SUSFS_URL" "$KERNEL_DIR/SusFS" "main"

        cd "$KERNEL_DIR"
        if [ ! -f ".susfs_applied" ]; then
            log_info "Applying SusFS patches..."

            # Apply SusFS patches if available
            if [ -f "SusFS/kernel_patches/setup.sh" ]; then
                bash SusFS/kernel_patches/setup.sh
            fi

            touch .susfs_applied
            log_success "SusFS patches applied"
        else
            log_info "SusFS patches already applied"
        fi
        cd - > /dev/null
    fi
}

# Function to setup AnyKernel3
setup_anykernel() {
    log_info "Setting up AnyKernel3..."

    if [ ! -d "$ANYKERNEL_DIR" ]; then
        clone_or_update "https://github.com/osm0sis/AnyKernel3" "$ANYKERNEL_DIR" "master"

        # Configure AnyKernel3 for Zeus
        cd "$ANYKERNEL_DIR"
        cp anykernel.sh anykernel.sh.bak

        cat > anykernel.sh << 'EOF'
#!/system/bin/sh
# AnyKernel3 Ramdisk Mod Script
# osm0sis @ xda-developers

## AnyKernel setup
# begin properties
properties() { '
kernel.string=Zeus Custom Kernel with KernelSU-Next and SusFS
do.devicecheck=1
do.modules=0
do.systemless=1
do.cleanup=1
do.cleanuponabort=0
device.name1=zeus
device.name2=cupid
device.name3=
device.name4=
device.name5=
supported.versions=12
supported.patchlevels=
'; } # end properties

# shell variables
block=/dev/block/bootdevice/by-name/boot;
is_slot_device=1;
ramdisk_compression=auto;

## AnyKernel methods (DO NOT CHANGE)
# import patching functions/variables - see for reference
. tools/ak3-core.sh;

## AnyKernel file attributes
# set permissions/ownership for included ramdisk files
set_perm_recursive 0 0 755 644 $ramdisk/*;
set_perm_recursive 0 0 750 750 $ramdisk/init* $ramdisk/sbin;

## AnyKernel install
dump_boot;

write_boot;
## end install
EOF

        cd - > /dev/null
    fi
}

# Function to build kernel
build_kernel() {
    log_info "Starting kernel build for $DEVICE_FULL_NAME..."

    cd "$KERNEL_DIR"

    # Setup build environment
    export ARCH="$ARCH"
    export SUBARCH="$SUBARCH"
    export CROSS_COMPILE="$TOOLCHAIN_DIR/gcc/bin/aarch64-linux-android-"
    export CC="$TOOLCHAIN_DIR/clang/bin/clang"
    export CLANG_TRIPLE="aarch64-linux-gnu-"
    export STRIP="$TOOLCHAIN_DIR/gcc/bin/aarch64-linux-android-strip"

    # Create output directory
    mkdir -p "$OUT_DIR"

    # Clean previous builds
    make clean
    make mrproper

    # Load defconfig
    if [ -f "arch/arm64/configs/${DEVICE}_defconfig" ]; then
        log_info "Loading ${DEVICE}_defconfig..."
        make O="$OUT_DIR" "${DEVICE}_defconfig"
    else
        log_error "Device defconfig not found: arch/arm64/configs/${DEVICE}_defconfig"
        log_info "Available defconfigs:"
        ls arch/arm64/configs/ | grep -E "(zeus|cupid|defconfig)" || true
        exit 1
    fi

    # Enable KernelSU if configured
    if [ "$KERNELSU_ENABLED" = true ]; then
        log_info "Enabling KernelSU configuration..."
        scripts/config --file "$OUT_DIR/.config" --enable CONFIG_MODULES
        scripts/config --file "$OUT_DIR/.config" --enable CONFIG_KPROBES
        scripts/config --file "$OUT_DIR/.config" --enable CONFIG_HAVE_KPROBES
        scripts/config --file "$OUT_DIR/.config" --enable CONFIG_KPROBE_EVENTS
    fi

    # Build kernel
    log_info "Building kernel..."
    make O="$OUT_DIR" -j$(nproc) 2>&1 | tee "$OUT_DIR/build.log"

    if [ $? -eq 0 ]; then
        log_success "Kernel build completed successfully!"

        # Copy kernel image
        if [ -f "$OUT_DIR/arch/arm64/boot/Image.gz" ]; then
            cp "$OUT_DIR/arch/arm64/boot/Image.gz" "$ANYKERNEL_DIR/"
            log_success "Kernel image copied to AnyKernel3"
        fi

        # Copy DTB files if they exist
        if [ -f "$OUT_DIR/arch/arm64/boot/dts/vendor/qcom/zeus.dtb" ]; then
            cp "$OUT_DIR/arch/arm64/boot/dts/vendor/qcom/zeus.dtb" "$ANYKERNEL_DIR/"
            log_success "DTB files copied to AnyKernel3"
        fi

    else
        log_error "Kernel build failed! Check $OUT_DIR/build.log for details."
        exit 1
    fi

    cd - > /dev/null
}

# Function to create flashable zip
create_zip() {
    log_info "Creating flashable zip..."

    cd "$ANYKERNEL_DIR"

    # Create zip filename with timestamp
    TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
    ZIP_NAME="Zeus_CustomKernel_KernelSU_SusFS_${TIMESTAMP}.zip"

    # Create the zip
    zip -r9 "$OUT_DIR/$ZIP_NAME" * -x .git README.md *placeholder

    if [ $? -eq 0 ]; then
        log_success "Flashable zip created: $OUT_DIR/$ZIP_NAME"

        # Show file info
        log_info "File size: $(du -h "$OUT_DIR/$ZIP_NAME" | cut -f1)"
        log_info "MD5: $(md5sum "$OUT_DIR/$ZIP_NAME" | cut -d' ' -f1)"
    else
        log_error "Failed to create flashable zip!"
        exit 1
    fi

    cd - > /dev/null
}

# Function to show usage
show_usage() {
    echo "Usage: $0 [options]"
    echo "Options:"
    echo "  --setup-only     Only setup dependencies, don't build"
    echo "  --build-only     Only build kernel (skip setup)"
    echo "  --clean          Clean build directories"
    echo "  --no-kernelsu    Disable KernelSU integration"
    echo "  --no-susfs       Disable SusFS integration"
    echo "  --help           Show this help message"
}

# Function to clean build
clean_build() {
    log_info "Cleaning build directories..."

    if [ -d "$OUT_DIR" ]; then
        rm -rf "$OUT_DIR"
        log_success "Output directory cleaned"
    fi

    if [ -d "$KERNEL_DIR" ]; then
        cd "$KERNEL_DIR"
        make clean 2>/dev/null || true
        make mrproper 2>/dev/null || true
        rm -f .kernelsu_applied .susfs_applied 2>/dev/null || true
        cd - > /dev/null
        log_success "Kernel directory cleaned"
    fi
}

# Main execution
main() {
    log_info "Xiaomi 12 Pro (Zeus) Kernel Build Script"
    log_info "Android $ANDROID_VERSION - Kernel $KERNEL_VERSION"
    log_info "KernelSU-Next: $([ "$KERNELSU_ENABLED" = true ] && echo "Enabled" || echo "Disabled")"
    log_info "SusFS: $([ "$SUSFS_ENABLED" = true ] && echo "Enabled" || echo "Disabled")"
    echo

    # Parse command line arguments
    SETUP_ONLY=false
    BUILD_ONLY=false

    while [[ $# -gt 0 ]]; do
        case $1 in
            --setup-only)
                SETUP_ONLY=true
                shift
                ;;
            --build-only)
                BUILD_ONLY=true
                shift
                ;;
            --clean)
                clean_build
                exit 0
                ;;
            --no-kernelsu)
                KERNELSU_ENABLED=false
                shift
                ;;
            --no-susfs)
                SUSFS_ENABLED=false
                shift
                ;;
            --help)
                show_usage
                exit 0
                ;;
            *)
                log_error "Unknown option: $1"
                show_usage
                exit 1
                ;;
        esac
    done

    # Setup phase
    if [ "$BUILD_ONLY" = false ]; then
        setup_toolchain
        setup_kernel
        setup_kernelsu
        setup_susfs
        setup_anykernel

        if [ "$SETUP_ONLY" = true ]; then
            log_success "Setup completed successfully!"
            exit 0
        fi
    fi

    # Build phase
    build_kernel
    create_zip

    log_success "Build process completed successfully!"
    log_info "Your flashable kernel zip is ready: $OUT_DIR/$ZIP_NAME"
}

# Run main function with all arguments
main "$@"
