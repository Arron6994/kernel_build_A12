# Zeus Custom Kernel Build - Android 12

[![Build Zeus Kernel](https://github.com/Arron6994/kernel_build_A12/actions/workflows/build-kernel.yml/badge.svg)](https://github.com/Arron6994/kernel_build_A12/actions/workflows/build-kernel.yml)

Custom kernel build system for **Xiaomi 12 Pro "Zeus"** (Android 12) with **KernelSU-Next** integration and **SusFS** capabilities.

## 🚀 Features

- **Device Support**: Xiaomi 12 Pro (Zeus) - Android 12
- **Kernel Version**: 5.10.* (android12-5.10 branch)
- **KernelSU-Next**: Advanced root solution integration
- **SusFS**: Enhanced file system capabilities for KernelSU
- **Automated Builds**: GitHub Actions CI/CD pipeline
- **Cross-platform**: Supports Linux build environments
- **Optimized**: Custom performance and security configurations

## 📋 Requirements

### Hardware Requirements
- **Device**: Xiaomi 12 Pro (Zeus) - Model: 2201122G
- **Platform**: Snapdragon 8 Gen 1 (SM8450)
- **Android Version**: Android 12
- **Custom Recovery**: TWRP or OrangeFox

### Build Environment Requirements
- **OS**: Ubuntu 20.04+ or compatible Linux distribution
- **RAM**: 16GB+ recommended
- **Storage**: 100GB+ free space
- **CPU**: Multi-core processor (8+ cores recommended)

### Software Dependencies
- Git
- Make
- Python 3
- Build-essential tools
- Clang toolchain
- GCC cross-compiler

## 🛠️ Quick Start

### 1. Clone Repository
```bash
git clone https://github.com/Arron6994/kernel_build_A12.git
cd kernel_build_A12
```

### 2. Setup Build Environment
```bash
chmod +x scripts/setup.sh
./scripts/setup.sh
```

### 3. Build Kernel
```bash
chmod +x build.sh
./build.sh
```

The build script will automatically:
- Download and setup the toolchain
- Clone the Xiaomi 12 Pro kernel source
- Integrate KernelSU-Next and SusFS
- Build the kernel with optimized configuration
- Create a flashable ZIP package

## 📖 Detailed Usage

### Build Script Options

```bash
# Full build (default)
./build.sh

# Setup only (download dependencies, don't build)
./build.sh --setup-only

# Build only (skip setup, useful for rebuilds)
./build.sh --build-only

# Build without KernelSU
./build.sh --no-kernelsu

# Build without SusFS
./build.sh --no-susfs

# Clean build directories
./build.sh --clean

# Show help
./build.sh --help
```

### Manual Configuration

#### Device Configuration
Edit `configs/zeus.conf` to customize build parameters:
- Kernel version and branch
- Toolchain settings
- KernelSU/SusFS options
- Device-specific parameters

#### Kernel Configuration
Customize `kernel/arch/arm64/configs/zeus_defconfig` for:
- Feature enabling/disabling
- Performance optimizations
- Security hardening
- Driver configurations

## 🔧 Configuration Files

### Project Structure
```
kernel_build_A12/
├── build.sh                    # Main build script
├── scripts/
│   └── setup.sh               # Environment setup script
├── configs/
│   └── zeus.conf              # Device configuration
├── .github/workflows/
│   └── build-kernel.yml       # GitHub Actions workflow
└── README.md                  # This file
```

### Build Outputs
```
out/
├── Zeus_CustomKernel_KernelSU_SusFS_YYYYMMDD_HHMMSS.zip  # Flashable ZIP
├── arch/arm64/boot/Image.gz                              # Kernel image
├── build.log                                             # Build log
└── *.dtb                                                # Device tree files
```

## 🚀 GitHub Actions

### Automated Builds
The repository includes GitHub Actions workflow for automated builds:
- Triggered on push to main/copilot branches
- Triggered on pull requests
- Manual trigger via workflow_dispatch
- Uploads build artifacts automatically

### Workflow Features
- Multi-platform support
- Cached toolchain for faster builds
- Configurable KernelSU/SusFS integration
- Automatic release creation on tags
- Build artifact retention

### Manual Trigger
1. Go to Actions tab in GitHub
2. Select "Build Zeus Kernel with KernelSU and SusFS"
3. Click "Run workflow"
4. Configure options:
   - Enable/disable KernelSU
   - Enable/disable SusFS
5. Run the workflow

## 📱 Installation

### Prerequisites
1. **Unlocked Bootloader**: Your Xiaomi 12 Pro must have an unlocked bootloader
2. **Custom Recovery**: TWRP or OrangeFox installed
3. **Backup**: Create a full NANDroid backup before flashing

### Installation Steps
1. Download the latest kernel ZIP from [Releases](https://github.com/Arron6994/kernel_build_A12/releases)
2. Boot into recovery mode
3. Flash the kernel ZIP file
4. Reboot system
5. Verify installation using KernelSU manager app

### Verification
```bash
# Check kernel version
adb shell cat /proc/version

# Check KernelSU status
adb shell su -c "ksud version"
```

## 🛡️ Security Features

### KernelSU-Next Integration
- **Advanced Root Management**: Next-generation KernelSU implementation
- **Module Support**: Load/unload kernel modules dynamically
- **App Management**: Fine-grained app permission control
- **Systemless**: Maintains system integrity

### SusFS Capabilities
- **File System Enhancement**: Advanced file system features
- **KernelSU Integration**: Seamless integration with KernelSU
- **Performance Optimization**: Enhanced I/O performance
- **Security Hardening**: Additional security layers

### Security Hardening
- CFI (Control Flow Integrity) enabled
- LTO (Link Time Optimization) enabled
- Security patches applied
- Kernel address randomization
- Stack protection enabled

## ⚡ Performance Optimizations

### CPU Optimizations
- **Scheduler**: Optimized task scheduling
- **Governor**: Balanced performance/power governor
- **Frequency Scaling**: Dynamic CPU frequency management
- **Thermal Management**: Intelligent thermal throttling

### Memory Optimizations
- **ZRAM**: Compressed RAM for better memory utilization
- **LMK**: Optimized Low Memory Killer
- **CMA**: Contiguous Memory Allocator optimizations
- **SLUB**: Optimized memory allocator

### Storage Optimizations
- **I/O Scheduler**: Optimized for flash storage
- **File System**: F2FS optimizations
- **Read-ahead**: Optimized read-ahead algorithms
- **Block Layer**: Enhanced block device performance

## 🐛 Troubleshooting

### Build Issues

#### Missing Dependencies
```bash
# Install missing packages
sudo apt update
sudo apt install build-essential git python3 curl wget zip

# Run setup again
./scripts/setup.sh
```

#### Toolchain Issues
```bash
# Clean and re-download toolchain
rm -rf toolchain/
./build.sh --setup-only
```

#### Kernel Source Issues
```bash
# Re-download kernel source
rm -rf kernel/
./scripts/setup.sh
```

### Runtime Issues

#### Bootloop
1. Boot into recovery
2. Flash original kernel backup
3. Check build log for compilation errors
4. Ensure correct defconfig for your device

#### KernelSU Not Working
1. Verify KernelSU integration in build log
2. Check if KernelSU manager app is installed
3. Ensure proper root permissions
4. Check KernelSU version compatibility

#### Performance Issues
1. Check thermal throttling
2. Verify CPU governor settings
3. Monitor system resources
4. Check for conflicting modules

## 📚 Resources

### Official Sources
- [Xiaomi Kernel Source](https://github.com/MiCode/Xiaomi_Kernel_OpenSource)
- [KernelSU-Next](https://github.com/rifsxd/KernelSU-Next)
- [SusFS](https://github.com/sidex15/SusFS4KernelSU)
- [AnyKernel3](https://github.com/osm0sis/AnyKernel3)

### Documentation
- [Android Kernel Development](https://source.android.com/docs/core/architecture/kernel)
- [Clang Cross Compilation](https://clang.llvm.org/docs/CrossCompilation.html)
- [Linux Kernel Documentation](https://www.kernel.org/doc/html/latest/)

### Community
- [XDA Developers](https://forum.xda-developers.com/f/xiaomi-12-pro.12563/)
- [Telegram Groups](https://t.me/xiaomi12prothemes)
- [Reddit Community](https://www.reddit.com/r/Xiaomi/)

## 🤝 Contributing

### How to Contribute
1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

### Contribution Guidelines
- Follow existing code style
- Document your changes
- Test on actual hardware when possible
- Update documentation as needed
- Add appropriate commit messages

### Areas for Contribution
- Performance optimizations
- Security enhancements
- Bug fixes
- Documentation improvements
- New feature implementations
- Device-specific optimizations

## 📄 License

This project is licensed under the **GPL-3.0 License** - see the [LICENSE](LICENSE) file for details.

### Third-party Components
- **Linux Kernel**: GPL-2.0 License
- **KernelSU**: GPL-3.0 License
- **SusFS**: GPL-3.0 License
- **Xiaomi Kernel Source**: GPL-2.0 License

## ⚠️ Disclaimer

- **Use at your own risk**: Flashing custom kernels can brick your device
- **Warranty void**: This will void your device warranty
- **No responsibility**: Authors are not responsible for any damage
- **Backup first**: Always create backups before flashing
- **Compatible devices only**: Only flash on supported devices

## 🔄 Changelog

### Latest Changes
- Initial release with KernelSU-Next and SusFS support
- GitHub Actions CI/CD pipeline
- Comprehensive build system
- Performance optimizations
- Security hardening

### Planned Features
- [ ] Advanced power management
- [ ] Additional device support
- [ ] Custom kernel modules
- [ ] Performance profiling tools
- [ ] Automated testing framework

## 📞 Support

### Getting Help
1. **Check Documentation**: Read this README thoroughly
2. **Search Issues**: Look for existing GitHub issues
3. **Community Forums**: Ask on XDA or Reddit
4. **Create Issue**: Open a new GitHub issue with details

### Bug Reports
When reporting bugs, include:
- Device model and Android version
- Kernel build information
- Steps to reproduce
- Log files (dmesg, logcat)
- Recovery logs if applicable

### Feature Requests
Feature requests are welcome! Please:
- Search existing issues first
- Provide detailed description
- Explain use case and benefits
- Consider implementation complexity

---

**Made with ❤️ for the Xiaomi 12 Pro community**

*Happy building! 🚀*