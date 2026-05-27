# shellcheck shell=bash

pkgbase="mesa-lib32"
pkgver="26.1.1"
pkgrel="1"
pkgdesc="Mesa 32-bit userspace stack (cross-built on amd64 for Debian 13)"
maintainer="xdavius <xdavius@github.com>"
arch=("amd64")
custom_fields=("Multi-Arch: same")
url="https://www.mesa3d.org/"
license=("MIT")
external_connection=true
source=(
  "https://archive.mesa3d.org/mesa-${pkgver}.tar.xz"
  "mesa.patch"
)
sha256sums=(
  "8bd36c031cc6d0edfec04617527609454ee3a09ad53bdf983b45fc2c1e129b2e"
  "SKIP"
)
pkgname=(
  "libegl-mesa0"
  "libgl1-mesa-dri"
  "libglapi-mesa"
  "libglx-mesa0"
  "libgbm1"
  "mesa-libgallium"
  "libosmesa6"
  "mesa-va-drivers"
  "mesa-vdpau-drivers"
  "mesa-vulkan-drivers"
)

makedepends=(
  "build-essential"
  "meson"
  "ninja-build"
  "pkg-config"
  "cmake"
  "python3-mako"
  "bison"
  "flex"
  "libdrm-dev"
  "libexpat1-dev"
  "libelf-dev"
  "libzstd-dev"
  "zlib1g-dev"
  "libx11-dev"
  "libxext-dev"
  "libxdamage-dev"
  "libxfixes-dev"
  "libx11-xcb-dev"
  "libxcb-glx0-dev"
  "libxcb-dri2-0-dev"
  "libxcb-dri3-dev"
  "libxcb-present-dev"
  "libxcb-randr0-dev"
  "libxcb-shm0-dev"
  "libxcb-sync-dev"
  "libxcb-xfixes0-dev"
  "libxxf86vm-dev"
  "libxrandr-dev"
  "libxshmfence-dev"
  "libwayland-dev"
  "libwayland-egl-backend-dev"
  "wayland-protocols"
  "libva-dev"
  "libvulkan-dev"
  "libglvnd-dev"
  "glslang-tools"
  "spirv-tools"
  "bindgen"
  "cbindgen"
  "libclc-19"
  "libclc-19-dev"
  "libllvmspirvlib-19-dev"
  "llvm-spirv-19"
  "libclang-dev"
  "llvm-19-dev"
  "gcc-multilib"
  "g++-multilib"
  "libdrm-dev:i386"
  "libexpat1-dev:i386"
  "libelf-dev:i386"
  "libzstd-dev:i386"
  "zlib1g-dev:i386"
  "libx11-dev:i386"
  "libxext-dev:i386"
  "libxdamage-dev:i386"
  "libxfixes-dev:i386"
  "libx11-xcb-dev:i386"
  "libxcb-glx0-dev:i386"
  "libxcb-dri2-0-dev:i386"
  "libxcb-dri3-dev:i386"
  "libxcb-present-dev:i386"
  "libxcb-randr0-dev:i386"
  "libxcb-shm0-dev:i386"
  "libxcb-sync-dev:i386"
  "libxcb-xfixes0-dev:i386"
  "libxxf86vm-dev:i386"
  "libxrandr-dev:i386"
  "libxshmfence-dev:i386"
  "libwayland-dev:i386"
  "libwayland-egl-backend-dev:i386"
  "libva-dev:i386"
  "libvulkan-dev:i386"
  "libglvnd-dev:i386"
  "libstd-rust-dev:i386"
  "libllvmspirvlib19.1:i386"
)

prepare() {
  cd "${srcdir}/mesa-${pkgver}" || exit 1
  patch -Np1 -i "${srcdir}/mesa.patch" || exit 1
}

build() {
  cd "${srcdir}/mesa-${pkgver}" || exit 1

  host_tools_dir="${srcdir}/mesa-host-tools"
  rm -rf "${host_tools_dir}"
  mkdir -p "${host_tools_dir}"

  # Build native helper tools needed by the cross lib32 build.
  meson setup build-host-tools \
    --prefix=/usr \
    --libdir=lib/x86_64-linux-gnu \
    --buildtype=release \
    -Dplatforms=x11,wayland \
    -Dgallium-drivers= \
    -Dvulkan-drivers= \
    -Dllvm=enabled \
    -Dshared-llvm=enabled \
    -Dmesa-clc=enabled \
    -Dprecomp-compiler=enabled \
    -Dinstall-mesa-clc=true \
    -Dinstall-precomp-compiler=false \
    -Dglx=disabled \
    -Dgbm=disabled \
    -Degl=disabled \
    -Dbuild-tests=false || exit 1
  meson compile -C build-host-tools || exit 1

  if [ -x "${srcdir}/mesa-${pkgver}/build-host-tools/src/compiler/clc/mesa_clc" ]; then
    ln -sf "${srcdir}/mesa-${pkgver}/build-host-tools/src/compiler/clc/mesa_clc" "${host_tools_dir}/mesa_clc"
  elif command -v mesa_clc >/dev/null 2>&1; then
    ln -sf "$(command -v mesa_clc)" "${host_tools_dir}/mesa_clc"
  else
    echo "ERROR: mesa_clc not found for lib32 build."
    exit 1
  fi

  if [ -x "${srcdir}/mesa-${pkgver}/build-host-tools/src/compiler/spirv/vtn_bindgen2" ]; then
    ln -sf "${srcdir}/mesa-${pkgver}/build-host-tools/src/compiler/spirv/vtn_bindgen2" "${host_tools_dir}/vtn_bindgen2"
  elif command -v vtn_bindgen2 >/dev/null 2>&1; then
    ln -sf "$(command -v vtn_bindgen2)" "${host_tools_dir}/vtn_bindgen2"
  fi

  llvm_config_cross="${srcdir}/llvm-config-19-i386"
  cat > "${llvm_config_cross}" << 'LLVMCFG'
#!/usr/bin/env bash
set -e

real_llvm_config="${REAL_LLVM_CONFIG:-llvm-config-19}"
i386_libdir="/usr/lib/i386-linux-gnu"
i386_prefix="/usr"
i386_includedir="/usr/include"

rewrite() {
  sed -e "s#/usr/lib/llvm-19/lib#${i386_libdir}#g" \
      -e "s#-L/usr/lib/llvm-19/lib#-L${i386_libdir}#g" \
      -e "s#-I/usr/lib/llvm-19/include#-I${i386_includedir}/llvm-19#g"
}

case "${1:-}" in
  --prefix)
    echo "${i386_prefix}"
    ;;
  --libdir)
    echo "${i386_libdir}"
    ;;
  --includedir)
    echo "${i386_includedir}/llvm-19"
    ;;
  --libs|--system-libs|--ldflags|--cflags|--cxxflags)
    "${real_llvm_config}" "$@" | rewrite
    ;;
  *)
    "${real_llvm_config}" "$@"
    ;;
esac
LLVMCFG
  chmod +x "${llvm_config_cross}"

  cross_file="${srcdir}/mesa-i386.cross"
  cat > "${cross_file}" << 'CROSS'
[binaries]
c = 'gcc'
cpp = 'g++'
rust = 'rustc'
llvm-config = 'LLVM_CONFIG_CROSS_PLACEHOLDER'
ar = 'ar'
strip = 'strip'
pkg-config = 'pkg-config'

[built-in options]
c_args = ['-m32', '-msse2']
cpp_args = ['-m32', '-msse2']
c_link_args = ['-m32']
cpp_link_args = ['-m32']
rust_args = ['--target=i686-unknown-linux-gnu']
rust_link_args = ['-m32']

[properties]
pkg_config_libdir = ['/usr/lib/i386-linux-gnu/pkgconfig', '/usr/share/pkgconfig']

[host_machine]
system = 'linux'
cpu_family = 'x86'
cpu = 'i686'
endian = 'little'
CROSS
  sed -i "s#LLVM_CONFIG_CROSS_PLACEHOLDER#${llvm_config_cross}#g" "${cross_file}"

  pkgcfg_overlay="${srcdir}/pkgconfig-lib32-overlay"
  rm -rf "${pkgcfg_overlay}"
  mkdir -p "${pkgcfg_overlay}"
  if [ -f /usr/lib/pkgconfig/libclc.pc ]; then
    cp -a /usr/lib/pkgconfig/libclc.pc "${pkgcfg_overlay}/"
  fi

  bindgen_clang_args="--target=i686-linux-gnu -m32 -I/usr/include/i386-linux-gnu -I/usr/include"

  PATH="${host_tools_dir}:${PATH}" \
  PKG_CONFIG_PATH="${pkgcfg_overlay}" \
  BINDGEN_EXTRA_CLANG_ARGS="${bindgen_clang_args}" \
  meson setup build32 \
    --cross-file "${cross_file}" \
    --prefix=/usr \
    --libdir=lib/i386-linux-gnu \
    --buildtype=release \
    -Dplatforms=x11,wayland \
    -Dgallium-drivers=auto \
    -Dvulkan-drivers=auto \
    -Dllvm=enabled \
    -Dshared-llvm=enabled \
    -Dmesa-clc=system \
    -Dprecomp-compiler=system \
    -Dglx=dri \
    -Dgbm=enabled \
    -Degl=enabled \
    -Dbuild-tests=false || exit 1

  PATH="${host_tools_dir}:${PATH}" \
  PKG_CONFIG_PATH="${pkgcfg_overlay}" \
  BINDGEN_EXTRA_CLANG_ARGS="${bindgen_clang_args}" \
  meson compile -C build32 || exit 1
}

_prepare_staging() {
  cd "${srcdir}/mesa-${pkgver}" || exit 1
  if [ ! -d "${srcdir}/_stage32/usr" ]; then
    mkdir -p "${srcdir}/_stage32"
    DESTDIR="${srcdir}/_stage32" meson install -C build32 || exit 1
  fi
}

_copy_glob_from_stage32() {
  local pattern="$1"
  if compgen -G "${srcdir}/_stage32/${pattern}" >/dev/null; then
    (
      cd "${srcdir}/_stage32" || exit 1
      cp -r --parents --no-preserve=ownership ${pattern} "${pkgdir}/"
    ) || exit 1
  fi
}

_force_deb_arch_i386() {
  # Pacstall writes final Architecture from CARCH during makedeb().
  # Persist it into safeenv so the value survives bwrap function scope.
  if [ -n "${safeenv:-}" ]; then
    printf 'CARCH="i386"\nexport CARCH\n' >> "${safeenv}"
  fi
  export CARCH="i386"
}

package_libegl-mesa0() {
  _prepare_staging
  arch=("i386")
  _force_deb_arch_i386
  pkgdesc="Mesa EGL vendor library (32-bit userspace)"
  depends=(
    "libc6:i386"
    "libdrm2:i386"
    "libexpat1:i386"
    "libgcc-s1:i386"
    "libwayland-client0:i386"
    "libwayland-server0:i386"
    "libx11-xcb1:i386"
    "libxcb-dri3-0:i386"
    "libxcb-present0:i386"
    "libxcb-randr0:i386"
    "libxcb-shm0:i386"
    "libxcb-xfixes0:i386"
    "libxcb1:i386"
    "libgbm1"
    "mesa-libgallium"
  )
  _copy_glob_from_stage32 "usr/lib/*/libEGL_mesa.so*"
}

package_libglapi-mesa() {
  _prepare_staging
  arch=("i386")
  _force_deb_arch_i386
  pkgdesc="Mesa OpenGL API shared library (32-bit userspace)"
  depends=(
    "libc6:i386"
  )
  _copy_glob_from_stage32 "usr/lib/*/libglapi.so*"
}

package_libglx-mesa0() {
  _prepare_staging
  arch=("i386")
  _force_deb_arch_i386
  pkgdesc="Mesa GLX vendor library (32-bit userspace)"
  depends=(
    "libc6:i386"
    "libdrm2:i386"
    "libexpat1:i386"
    "libx11-6:i386"
    "libx11-xcb1:i386"
    "libxcb-dri3-0:i386"
    "libxcb-glx0:i386"
    "libxcb-present0:i386"
    "libxcb-shm0:i386"
    "libxcb-xfixes0:i386"
    "libxcb1:i386"
    "libxext6:i386"
    "libxxf86vm1:i386"
    "mesa-libgallium"
    "libgl1-mesa-dri"
  )
  _copy_glob_from_stage32 "usr/lib/*/libGLX_mesa.so*"
}

package_libgbm1() {
  _prepare_staging
  arch=("i386")
  _force_deb_arch_i386
  pkgdesc="Mesa GBM runtime library (32-bit userspace)"
  depends=(
    "libc6:i386"
    "libdrm2:i386"
    "libexpat1:i386"
    "libwayland-server0:i386"
    "mesa-libgallium"
  )
  _copy_glob_from_stage32 "usr/lib/*/libgbm.so*"
}

package_mesa-libgallium() {
  _prepare_staging
  arch=("i386")
  _force_deb_arch_i386
  pkgdesc="Mesa Gallium runtime library (32-bit userspace)"
  depends=(
    "libc6:i386"
    "libdrm-amdgpu1:i386"
    "libdrm-intel1:i386"
    "libdrm2:i386"
    "libelf1:i386"
    "libexpat1:i386"
    "libgcc-s1:i386"
    "libllvm19:i386"
    "libsensors5:i386"
    "libstdc++6:i386"
    "libx11-xcb1:i386"
    "libxcb-dri3-0:i386"
    "libxcb-present0:i386"
    "libxcb-randr0:i386"
    "libxcb-sync1:i386"
    "libxcb-xfixes0:i386"
    "libxcb1:i386"
    "libxshmfence1:i386"
    "libzstd1:i386"
    "zlib1g:i386"
  )
  _copy_glob_from_stage32 "usr/lib/*/libgallium*.so*"
}

package_libosmesa6() {
  _prepare_staging
  arch=("i386")
  _force_deb_arch_i386
  pkgdesc="Mesa off-screen rendering library (32-bit userspace)"
  depends=(
    "libc6:i386"
    "libdrm2:i386"
    "libgcc-s1:i386"
    "libllvm19:i386"
    "libstdc++6:i386"
    "libzstd1:i386"
    "zlib1g:i386"
  )
  _copy_glob_from_stage32 "usr/lib/*/libOSMesa.so*"
}

package_mesa-vdpau-drivers() {
  _prepare_staging
  arch=("i386")
  _force_deb_arch_i386
  pkgdesc="Mesa VDPAU drivers (32-bit userspace)"
  depends=(
    "libvdpau1:i386"
  )
  _copy_glob_from_stage32 "usr/lib/*/vdpau/*.so*"
}

package_mesa-va-drivers() {
  _prepare_staging
  arch=("i386")
  _force_deb_arch_i386
  pkgdesc="Mesa VA-API drivers (32-bit userspace)"
  depends=(
    "mesa-libgallium"
  )
  _copy_glob_from_stage32 "usr/lib/*/dri/*_drv_video.so*"
}

package_mesa-vulkan-drivers() {
  _prepare_staging
  arch=("i386")
  _force_deb_arch_i386
  pkgdesc="Mesa Vulkan drivers and ICD manifests (32-bit userspace)"
  depends=(
    "libvulkan1:i386"
    "libc6:i386"
    "libdrm-amdgpu1:i386"
    "libdrm2:i386"
    "libelf1:i386"
    "libexpat1:i386"
    "libgcc-s1:i386"
    "libllvm19:i386"
    "libstdc++6:i386"
    "libwayland-client0:i386"
    "libx11-xcb1:i386"
    "libxcb-dri3-0:i386"
    "libxcb-present0:i386"
    "libxcb-randr0:i386"
    "libxcb-shm0:i386"
    "libxcb-sync1:i386"
    "libxcb-xfixes0:i386"
    "libxcb1:i386"
    "libxshmfence1:i386"
    "libzstd1:i386"
    "zlib1g:i386"
  )
  _copy_glob_from_stage32 "usr/lib/*/libvulkan_*.so*"
  _copy_glob_from_stage32 "usr/share/vulkan/*/*.json"
}

package_libgl1-mesa-dri() {
  _prepare_staging
  arch=("i386")
  _force_deb_arch_i386
  pkgdesc="Mesa DRI OpenGL drivers (32-bit userspace)"
  depends=(
    "libc6:i386"
    "libgbm1"
    "libvulkan1:i386"
  )
  _copy_glob_from_stage32 "usr/lib/*/dri/*.so*"
  find "${pkgdir}/usr/lib" -name '*_drv_video.so*' -delete 2>/dev/null || true
}
