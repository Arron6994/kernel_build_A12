#!/bin/bash
# Validation script for Zeus kernel build environment

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
    echo -e "${GREEN}[PASS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[FAIL]${NC} $1"
}

# Validation functions
validate_environment() {
    log_info "Validating build environment..."
    
    local errors=0
    
    # Check operating system
    if [[ "$OSTYPE" != "linux-gnu"* ]]; then
        log_error "Unsupported OS: $OSTYPE (Linux required)"
        ((errors++))
    else
        log_success "Operating System: Linux"
    fi
    
    # Check architecture
    if [[ "$(uname -m)" != "x86_64" ]]; then
        log_warning "Architecture: $(uname -m) (x86_64 recommended)"
    else
        log_success "Architecture: x86_64"
    fi
    
    # Check available memory
    local mem_gb=$(free -g | awk '/^Mem:/{print $2}')
    if [[ $mem_gb -lt 8 ]]; then
        log_warning "RAM: ${mem_gb}GB (16GB+ recommended for kernel builds)"
    else
        log_success "RAM: ${mem_gb}GB"
    fi
    
    # Check available disk space
    local disk_gb=$(df . | awk 'NR==2{print int($4/1024/1024)}')
    if [[ $disk_gb -lt 50 ]]; then
        log_error "Disk space: ${disk_gb}GB available (100GB+ required)"
        ((errors++))
    else
        log_success "Disk space: ${disk_gb}GB available"
    fi
    
    # Check CPU cores
    local cores=$(nproc)
    if [[ $cores -lt 4 ]]; then
        log_warning "CPU cores: $cores (8+ recommended)"
    else
        log_success "CPU cores: $cores"
    fi
    
    return $errors
}

validate_dependencies() {
    log_info "Validating dependencies..."
    
    local errors=0
    local deps=("git" "make" "curl" "wget" "zip" "unzip" "python3" "gcc" "g++")
    
    for dep in "${deps[@]}"; do
        if command -v "$dep" >/dev/null 2>&1; then
            local version=$(command -v "$dep" >/dev/null && $dep --version 2>/dev/null | head -1 || echo "unknown")
            log_success "$dep: $(echo $version | cut -d' ' -f1-3)"
        else
            log_error "$dep: Not found"
            ((errors++))
        fi
    done
    
    # Check for build-essential
    if dpkg -l | grep -q build-essential; then
        log_success "build-essential: Installed"
    else
        log_error "build-essential: Not installed"
        ((errors++))
    fi
    
    return $errors
}

validate_scripts() {
    log_info "Validating scripts..."
    
    local errors=0
    
    # Check if scripts exist and are executable
    local scripts=("build.sh" "scripts/setup.sh")
    
    for script in "${scripts[@]}"; do
        if [[ -f "$script" ]]; then
            if [[ -x "$script" ]]; then
                log_success "$script: Executable"
            else
                log_error "$script: Not executable"
                ((errors++))
            fi
        else
            log_error "$script: Not found"
            ((errors++))
        fi
    done
    
    return $errors
}

validate_configuration() {
    log_info "Validating configuration..."
    
    local errors=0
    
    # Check configuration files
    if [[ -f "configs/zeus.conf" ]]; then
        log_success "Device configuration: Found"
        
        # Validate configuration syntax
        if source configs/zeus.conf 2>/dev/null; then
            log_success "Device configuration: Valid syntax"
        else
            log_error "Device configuration: Invalid syntax"
            ((errors++))
        fi
    else
        log_error "Device configuration: Not found (configs/zeus.conf)"
        ((errors++))
    fi
    
    # Check GitHub Actions workflow
    if [[ -f ".github/workflows/build-kernel.yml" ]]; then
        log_success "GitHub Actions workflow: Found"
    else
        log_warning "GitHub Actions workflow: Not found"
    fi
    
    # Check .gitignore
    if [[ -f ".gitignore" ]]; then
        log_success "Gitignore: Found"
    else
        log_warning "Gitignore: Not found"
    fi
    
    return $errors
}

validate_network() {
    log_info "Validating network connectivity..."
    
    local errors=0
    local urls=(
        "https://github.com"
        "https://android.googlesource.com"
    )
    
    for url in "${urls[@]}"; do
        if curl -s --head "$url" >/dev/null; then
            log_success "Network: $url reachable"
        else
            log_error "Network: $url unreachable"
            ((errors++))
        fi
    done
    
    return $errors
}

validate_directories() {
    log_info "Validating directory structure..."
    
    local errors=0
    local dirs=("scripts" "configs" ".github/workflows")
    
    for dir in "${dirs[@]}"; do
        if [[ -d "$dir" ]]; then
            log_success "Directory: $dir exists"
        else
            log_error "Directory: $dir missing"
            ((errors++))
        fi
    done
    
    # Check for build directories (should not exist initially)
    local build_dirs=("kernel" "toolchain" "out" "AnyKernel3")
    
    for dir in "${build_dirs[@]}"; do
        if [[ -d "$dir" ]]; then
            log_warning "Build directory: $dir already exists"
        else
            log_success "Build directory: $dir clean (not exists)"
        fi
    done
    
    return $errors
}

# Main validation function
main() {
    echo "========================================"
    echo "Zeus Kernel Build Environment Validator"
    echo "========================================"
    echo
    
    local total_errors=0
    
    # Run all validations
    validate_environment
    total_errors=$((total_errors + $?))
    echo
    
    validate_dependencies
    total_errors=$((total_errors + $?))
    echo
    
    validate_scripts
    total_errors=$((total_errors + $?))
    echo
    
    validate_configuration
    total_errors=$((total_errors + $?))
    echo
    
    validate_network
    total_errors=$((total_errors + $?))
    echo
    
    validate_directories
    total_errors=$((total_errors + $?))
    echo
    
    # Summary
    echo "========================================"
    if [[ $total_errors -eq 0 ]]; then
        log_success "Environment validation PASSED!"
        echo
        log_info "Your environment is ready for Zeus kernel building."
        log_info "Next steps:"
        log_info "1. Run './scripts/setup.sh' to setup build environment"
        log_info "2. Run './build.sh' to start building the kernel"
    else
        log_error "Environment validation FAILED with $total_errors error(s)!"
        echo
        log_info "Please fix the errors above before proceeding."
        log_info "You may need to:"
        log_info "1. Install missing dependencies: sudo apt install build-essential git curl wget zip"
        log_info "2. Fix script permissions: chmod +x build.sh scripts/setup.sh"
        log_info "3. Ensure sufficient disk space and memory"
        exit 1
    fi
    echo "========================================"
}

# Run main function
main "$@"