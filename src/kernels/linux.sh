# For build.sh
mode_name="std"
package_base="linux"
mode_desc="Select and use the packages for the default linux kernel"

# pkgrel for default ZFS packages
pkgrel="1"

# pkgrel for GIT packages
pkgrel_git="1"
zfs_git_commit=""
spl_git_commit=""
zfs_git_url="https://github.com/zfsonlinux/zfs.git"
spl_git_url="https://github.com/zfsonlinux/spl.git"

header="\
# Maintainer: Jan Houben <jan@nexttrex.de>
# Contributor: Jesus Alvarez <jeezusjr at gmail dot com>
#
# This PKGBUILD was generated by the archzfs build scripts located at
#
# http://github.com/archzfs/archzfs
#
# ! WARNING !
#
# The archzfs packages are kernel modules, so these PKGBUILDS will only work with the kernel package they target. In this
# case, the archzfs-linux packages will only work with the default linux package! To have a single PKGBUILD target many
# kernels would make for a cluttered PKGBUILD!
#
# If you have a custom kernel, you will need to change things in the PKGBUILDS. If you would like to have AUR or archzfs repo
# packages for your favorite kernel package built using the archzfs build tools, submit a request in the Issue tracker on the
# archzfs github page.
#"

get_kernel_options() {
    msg "Checking the online package database for the latest x86_64 linux kernel version..."
    if ! get_webpage "https://www.archlinux.org/packages/core/x86_64/linux/" "(?<=<h2>linux )[\d\w\.-]+(?=</h2>)"; then
        exit 1
    fi
    kernel_version=${webpage_output}
    kernel_version_full=$(kernel_version_full ${kernel_version})
    kernel_version_full_pkgver=$(kernel_version_full_no_hyphen ${kernel_version})
    kernel_version_major=${kernel_version%-*}
    kernel_mod_path="\${_kernelver/.arch/-arch}-ARCH"
    linux_depends="\"linux=\${_kernelver}\""
    linux_headers_depends="\"linux-headers=\${_kernelver}\""
}

update_linux_pkgbuilds() {
    get_kernel_options
    pkg_list=("spl-linux" "zfs-linux")
    archzfs_package_group="archzfs-linux"
    spl_pkgver=${zol_version}
    zfs_pkgver=${zol_version}
    spl_pkgrel=${pkgrel}
    zfs_pkgrel=${pkgrel}
    spl_conflicts="'spl-linux-git'"
    zfs_conflicts="'zfs-linux-git'"
    spl_pkgname="spl-linux"
    zfs_pkgname="zfs-linux"
    zfs_utils_pkgname="zfs-utils=\${_zfsver}"
    # Paths are relative to build.sh
    spl_pkgbuild_path="packages/${kernel_name}/${spl_pkgname}"
    zfs_pkgbuild_path="packages/${kernel_name}/${zfs_pkgname}"
    spl_src_target="https://github.com/zfsonlinux/zfs/releases/download/zfs-\${_splver}/spl-\${_splver}.tar.gz"
    zfs_src_target="https://github.com/zfsonlinux/zfs/releases/download/zfs-\${_zfsver}/zfs-\${_zfsver}.tar.gz"
    spl_workdir="\${srcdir}/spl-\${_splver}"
    zfs_workdir="\${srcdir}/zfs-\${_zfsver}"
    spl_replaces='replaces=("spl-git")'
    zfs_replaces='replaces=("zfs-git")'
    zfs_makedepends="\"${spl_pkgname}-headers\""
}

update_linux_git_pkgbuilds() {
    get_kernel_options
    pkg_list=("zfs-linux-git")
    archzfs_package_group="archzfs-linux-git"
    zfs_pkgver="" # Set later by call to git_calc_pkgver
    zfs_pkgrel=${pkgrel_git}
    zfs_conflicts="'zfs-linux' 'spl-linux-git' 'spl-linux'"
    spl_pkgname=""
    zfs_pkgname="zfs-linux-git"
    zfs_pkgbuild_path="packages/${kernel_name}/${zfs_pkgname}"
    zfs_replaces='replaces=("spl-linux-git")'
    zfs_src_hash="SKIP"
    zfs_makedepends="\"git\""
    zfs_workdir="\${srcdir}/zfs"
    if have_command "update"; then
        git_check_repo
        git_calc_pkgver
    fi
    zfs_utils_pkgname="zfs-utils-git=\${_zfsver}"
    zfs_set_commit="_commit='${latest_zfs_git_commit}'"
    zfs_src_target="git+${zfs_git_url}#commit=\${_commit}"
}
