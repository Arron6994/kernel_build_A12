#!/bin/bash
# Setup script for Xiaomi 12 Pro Zeus kernel build environment

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

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

# Function to check and install dependencies
check_dependencies() {
    log_info "Checking build dependencies..."
    
    local missing_deps=()
    
    # Check for required tools
    command -v git >/dev/null 2>&1 || missing_deps+=("git")
    command -v make >/dev/null 2>&1 || missing_deps+=("make")
    command -v curl >/dev/null 2>&1 || missing_deps+=("curl")
    command -v wget >/dev/null 2>&1 || missing_deps+=("wget")
    command -v zip >/dev/null 2>&1 || missing_deps+=("zip")
    command -v unzip >/dev/null 2>&1 || missing_deps+=("unzip")
    command -v python3 >/dev/null 2>&1 || missing_deps+=("python3")
    
    # Check for build tools
    if ! dpkg -l | grep -q build-essential; then
        missing_deps+=("build-essential")
    fi
    
    if [ ${#missing_deps[@]} -ne 0 ]; then
        log_warning "Missing dependencies: ${missing_deps[*]}"
        log_info "Installing missing dependencies..."
        
        sudo apt update
        sudo apt install -y "${missing_deps[@]}"
        
        if [ $? -eq 0 ]; then
            log_success "Dependencies installed successfully"
        else
            log_error "Failed to install dependencies"
            exit 1
        fi
    else
        log_success "All dependencies are already installed"
    fi
}

# Function to setup kernel source
setup_kernel_source() {
    log_info "Setting up kernel source..."
    
    if [ -d "kernel" ]; then
        log_info "Kernel directory already exists"
        read -p "Do you want to re-download the kernel source? (y/N): " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            rm -rf kernel
        else
            log_info "Using existing kernel source"
            return 0
        fi
    fi
    
    log_info "Cloning Xiaomi 12 Pro kernel source..."
    git clone --depth=1 -b zeus-s-oss https://github.com/MiCode/Xiaomi_Kernel_OpenSource.git kernel
    
    if [ $? -eq 0 ]; then
        log_success "Kernel source cloned successfully"
    else
        log_error "Failed to clone kernel source"
        log_info "Please manually clone the kernel source:"
        log_info "git clone -b zeus-s-oss https://github.com/MiCode/Xiaomi_Kernel_OpenSource.git kernel"
        exit 1
    fi
}

# Function to create sample defconfig if it doesn't exist
create_sample_defconfig() {
    log_info "Checking for Zeus defconfig..."
    
    if [ ! -f "kernel/arch/arm64/configs/zeus_defconfig" ]; then
        log_warning "Zeus defconfig not found, creating sample defconfig..."
        
        # Create a basic defconfig based on common Snapdragon 8 Gen 1 configuration
        mkdir -p kernel/arch/arm64/configs
        
        cat > kernel/arch/arm64/configs/zeus_defconfig << 'EOF'
CONFIG_LOCALVERSION="-Zeus-KernelSU-SusFS"
CONFIG_LOCALVERSION_AUTO=y

# Architecture
CONFIG_ARM64=y
CONFIG_64BIT=y

# Platform
CONFIG_ARCH_QCOM=y
CONFIG_ARCH_SM8450=y

# CPU Configuration
CONFIG_NR_CPUS=8
CONFIG_SCHED_MC=y
CONFIG_SCHED_SMT=y

# Memory Management
CONFIG_HIGHMEM=y
CONFIG_ARM64_4K_PAGES=y
CONFIG_ARM64_VA_BITS_48=y
CONFIG_ARM64_PA_BITS_48=y

# Kernel Features
CONFIG_PREEMPT=y
CONFIG_HZ_300=y
CONFIG_IKCONFIG=y
CONFIG_IKCONFIG_PROC=y
CONFIG_LOG_BUF_SHIFT=17

# Process and Security
CONFIG_ANDROID_PARANOID_NETWORK=y
CONFIG_ANDROID_BINDER_IPC=y
CONFIG_ASHMEM=y

# File Systems
CONFIG_EXT4_FS=y
CONFIG_EXT4_FS_XATTR=y
CONFIG_EXT4_FS_SECURITY=y
CONFIG_F2FS_FS=y
CONFIG_F2FS_FS_XATTR=y
CONFIG_F2FS_FS_SECURITY=y
CONFIG_VFAT_FS=y
CONFIG_TMPFS=y
CONFIG_TMPFS_POSIX_ACL=y

# Network
CONFIG_NETFILTER=y
CONFIG_NETFILTER_XTABLES=y
CONFIG_NETFILTER_XT_TARGET_MARK=y
CONFIG_IP_NF_IPTABLES=y
CONFIG_IP_NF_FILTER=y
CONFIG_IP6_NF_IPTABLES=y
CONFIG_IP6_NF_FILTER=y

# Modules support
CONFIG_MODULES=y
CONFIG_MODULE_UNLOAD=y
CONFIG_MODVERSIONS=y

# KProbes support (required for KernelSU)
CONFIG_KPROBES=y
CONFIG_HAVE_KPROBES=y
CONFIG_KPROBE_EVENTS=y

# Debug and Performance
CONFIG_PROFILING=y
CONFIG_PERF_EVENTS=y
CONFIG_DEBUG_FS=y

# Power Management
CONFIG_SUSPEND=y
CONFIG_PM=y
CONFIG_PM_SLEEP=y
CONFIG_CPU_IDLE=y
CONFIG_CPU_FREQ=y
CONFIG_CPU_FREQ_DEFAULT_GOV_SCHEDUTIL=y

# Display and Graphics
CONFIG_FB=y
CONFIG_DRM=y
CONFIG_DRM_MSM=y

# USB
CONFIG_USB=y
CONFIG_USB_ANNOUNCE_NEW_DEVICES=y
CONFIG_USB_GADGET=y
CONFIG_USB_CONFIGFS=y
CONFIG_USB_CONFIGFS_F_FS=y
CONFIG_USB_CONFIGFS_F_MTP=y
CONFIG_USB_CONFIGFS_F_PTP=y
CONFIG_USB_CONFIGFS_F_ACC=y
CONFIG_USB_CONFIGFS_F_AUDIO_SRC=y
CONFIG_USB_CONFIGFS_UEVENT=y

# Input
CONFIG_INPUT=y
CONFIG_INPUT_TOUCHSCREEN=y

# Sound
CONFIG_SOUND=y
CONFIG_SND=y
CONFIG_SND_SOC=y

# Security
CONFIG_SECURITY=y
CONFIG_SECURITY_SELINUX=y
CONFIG_SECURITY_SELINUX_BOOTPARAM=y
CONFIG_SECURITY_SELINUX_DISABLE=y

# Networking
CONFIG_INET=y
CONFIG_IPV6=y
CONFIG_WIRELESS=y
CONFIG_CFG80211=y
CONFIG_MAC80211=y

# Block Devices
CONFIG_BLK_DEV_LOOP=y
CONFIG_BLK_DEV_DM=y

# Crypto
CONFIG_CRYPTO=y
CONFIG_CRYPTO_AES=y
CONFIG_CRYPTO_SHA1=y
CONFIG_CRYPTO_SHA256=y

# Miscellaneous
CONFIG_ANDROID=y
CONFIG_ANDROID_INTF_ALARM_DEV=y
CONFIG_STAGING=y
CONFIG_ION=y
CONFIG_ION_SYSTEM_HEAP=y
EOF

        log_success "Sample Zeus defconfig created"
        log_warning "Please review and customize kernel/arch/arm64/configs/zeus_defconfig for your specific needs"
    else
        log_success "Zeus defconfig found"
    fi
}

# Function to setup GitHub Actions
setup_github_actions() {
    log_info "Setting up GitHub Actions workflow..."
    
    mkdir -p .github/workflows
    
    cat > .github/workflows/build-kernel.yml << 'EOF'
name: Build Zeus Kernel

on:
  push:
    branches: [ main, copilot/* ]
  pull_request:
    branches: [ main ]
  workflow_dispatch:

jobs:
  build:
    runs-on: ubuntu-latest
    
    steps:
    - name: Checkout code
      uses: actions/checkout@v4
      
    - name: Setup build environment
      run: |
        sudo apt update
        sudo apt install -y build-essential git curl wget zip unzip python3
        
    - name: Setup kernel build
      run: |
        chmod +x build.sh
        chmod +x scripts/setup.sh
        ./scripts/setup.sh
        
    - name: Build kernel
      run: |
        ./build.sh --setup-only
        
    - name: Upload build logs
      if: always()
      uses: actions/upload-artifact@v4
      with:
        name: build-logs
        path: |
          out/build.log
          out/*.zip
        retention-days: 7
EOF

    log_success "GitHub Actions workflow created"
}

# Function to setup git hooks
setup_git_hooks() {
    log_info "Setting up git hooks..."
    
    mkdir -p .git/hooks
    
    cat > .git/hooks/pre-commit << 'EOF'
#!/bin/bash
# Pre-commit hook to validate build configuration

echo "Running pre-commit checks..."

# Check if build script is executable
if [ -f "build.sh" ] && [ ! -x "build.sh" ]; then
    echo "Making build.sh executable..."
    chmod +x build.sh
fi

# Check if setup script is executable  
if [ -f "scripts/setup.sh" ] && [ ! -x "scripts/setup.sh" ]; then
    echo "Making setup.sh executable..."
    chmod +x scripts/setup.sh
fi

echo "Pre-commit checks passed"
EOF

    chmod +x .git/hooks/pre-commit
    log_success "Git hooks setup completed"
}

# Main function
main() {
    log_info "Xiaomi 12 Pro Zeus Kernel Build Setup"
    echo
    
    # Check if we're in the right directory
    if [ ! -f "build.sh" ]; then
        log_error "build.sh not found. Please run this script from the repository root."
        exit 1
    fi
    
    # Make build script executable
    chmod +x build.sh
    
    # Run setup steps
    check_dependencies
    setup_kernel_source
    create_sample_defconfig
    setup_github_actions
    setup_git_hooks
    
    echo
    log_success "Setup completed successfully!"
    echo
    log_info "Next steps:"
    log_info "1. Review and customize configs/zeus.conf if needed"
    log_info "2. Review kernel/arch/arm64/configs/zeus_defconfig"
    log_info "3. Run './build.sh' to start building the kernel"
    echo
    log_info "Build options:"
    log_info "  ./build.sh --setup-only    # Only setup dependencies"
    log_info "  ./build.sh --build-only    # Only build kernel"
    log_info "  ./build.sh --no-kernelsu   # Build without KernelSU"
    log_info "  ./build.sh --no-susfs      # Build without SusFS"
    log_info "  ./build.sh --clean         # Clean build directories"
    log_info "  ./build.sh --help          # Show help"
}

# Run main function
main "$@"