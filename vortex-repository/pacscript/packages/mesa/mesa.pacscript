# shellcheck shell=bash

# Package metadata
pkgbase="mesa"
pkgver="26.1.1"
pkgrel="1"
pkgdesc="Mesa 3D graphics stack built from source for Debian 13 (amd64 only)"
maintainer="xdavius <xdavius@github.com>"
arch=("amd64")
custom_fields=("Multi-Arch: same")
url="https://www.mesa3d.org/"
license=("MIT")
external_connection=true
source=(
  "https://archive.mesa3d.org/mesa-${pkgver}.tar.xz"
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

# Build dependencies (Debian 13)
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
)

prepare() {
  cd "${srcdir}/mesa-${pkgver}" || exit 1
}

build() {
  cd "${srcdir}/mesa-${pkgver}" || exit 1

  meson setup build64 \
    --prefix=/usr \
    --libdir=lib/x86_64-linux-gnu \
    --buildtype=release \
    -Dplatforms=x11,wayland \
    -Dgallium-drivers=auto \
    -Dvulkan-drivers=auto \
    -Dllvm=enabled \
    -Dshared-llvm=enabled \
    -Dglx=dri \
    -Dgbm=enabled \
    -Degl=enabled || exit 1

  meson compile -C build64 || exit 1
}

_prepare_staging() {
  cd "${srcdir}/mesa-${pkgver}" || exit 1
  if [ ! -d "${srcdir}/_stage64/usr" ]; then
    mkdir -p "${srcdir}/_stage64"
    DESTDIR="${srcdir}/_stage64" meson install -C build64 || exit 1
  fi
}

_copy_glob_from_stage64() {
  local pattern="$1"
  if compgen -G "${srcdir}/_stage64/${pattern}" >/dev/null; then
    (
      cd "${srcdir}/_stage64" || exit 1
      cp -r --parents --no-preserve=ownership ${pattern} "${pkgdir}/"
    ) || exit 1
  fi
}

package_libegl-mesa0() {
  _prepare_staging
  pkgdesc="Mesa EGL vendor library"
  depends=(
    "libc6"
    "libdrm2"
    "libexpat1"
    "libgcc-s1"
    "libwayland-client0"
    "libwayland-server0"
    "libx11-xcb1"
    "libxcb-dri3-0"
    "libxcb-present0"
    "libxcb-randr0"
    "libxcb-shm0"
    "libxcb-xfixes0"
    "libxcb1"
    "libgbm1"
    "mesa-libgallium"
  )
  _copy_glob_from_stage64 "usr/lib/*/libEGL_mesa.so*"
}

package_libglapi-mesa() {
  _prepare_staging
  pkgdesc="Mesa OpenGL API shared library"
  depends=(
    "libc6"
  )
  _copy_glob_from_stage64 "usr/lib/*/libglapi.so*"
}

package_libglx-mesa0() {
  _prepare_staging
  pkgdesc="Mesa GLX vendor library"
  depends=(
    "libc6"
    "libdrm2"
    "libexpat1"
    "libx11-6"
    "libx11-xcb1"
    "libxcb-dri3-0"
    "libxcb-glx0"
    "libxcb-present0"
    "libxcb-shm0"
    "libxcb-xfixes0"
    "libxcb1"
    "libxext6"
    "libxxf86vm1"
    "mesa-libgallium"
    "libgl1-mesa-dri"
  )
  _copy_glob_from_stage64 "usr/lib/*/libGLX_mesa.so*"
}

package_libgbm1() {
  _prepare_staging
  pkgdesc="Mesa GBM runtime library"
  depends=(
    "libc6"
    "libdrm2"
    "libexpat1"
    "libwayland-server0"
    "mesa-libgallium"
  )
  _copy_glob_from_stage64 "usr/lib/*/libgbm.so*"
}

package_mesa-libgallium() {
  _prepare_staging
  pkgdesc="Mesa Gallium runtime library"
  depends=(
    "libc6"
    "libdrm-amdgpu1"
    "libdrm-intel1"
    "libdrm2"
    "libelf1t64"
    "libexpat1"
    "libgcc-s1"
    "libllvm19"
    "libsensors5"
    "libstdc++6"
    "libx11-xcb1"
    "libxcb-dri3-0"
    "libxcb-present0"
    "libxcb-randr0"
    "libxcb-sync1"
    "libxcb-xfixes0"
    "libxcb1"
    "libxshmfence1"
    "libzstd1"
    "zlib1g"
  )
  _copy_glob_from_stage64 "usr/lib/*/libgallium*.so*"
}

package_libosmesa6() {
  _prepare_staging
  pkgdesc="Mesa off-screen rendering library"
  depends=(
    "libc6"
    "libdrm2"
    "libgcc-s1"
    "libllvm19"
    "libstdc++6"
    "libzstd1"
    "zlib1g"
  )
  _copy_glob_from_stage64 "usr/lib/*/libOSMesa.so*"
}

package_mesa-vdpau-drivers() {
  _prepare_staging
  pkgdesc="Mesa VDPAU drivers"
  depends=(
    "libvdpau1"
  )
  _copy_glob_from_stage64 "usr/lib/*/vdpau/*.so*"
}

package_mesa-va-drivers() {
  _prepare_staging
  pkgdesc="Mesa VA-API drivers"
  depends=(
    "mesa-libgallium"
  )
  _copy_glob_from_stage64 "usr/lib/*/dri/*_drv_video.so*"
}

package_mesa-vulkan-drivers() {
  _prepare_staging
  pkgdesc="Mesa Vulkan drivers and ICD manifests"
  depends=(
    "libvulkan1"
    "libc6"
    "libdrm-amdgpu1"
    "libdrm2"
    "libelf1t64"
    "libexpat1"
    "libgcc-s1"
    "libllvm19"
    "libstdc++6"
    "libwayland-client0"
    "libx11-xcb1"
    "libxcb-dri3-0"
    "libxcb-present0"
    "libxcb-randr0"
    "libxcb-shm0"
    "libxcb-sync1"
    "libxcb-xfixes0"
    "libxcb1"
    "libxshmfence1"
    "libzstd1"
    "zlib1g"
  )
  _copy_glob_from_stage64 "usr/lib/*/libvulkan_*.so*"
  _copy_glob_from_stage64 "usr/share/vulkan/*/*.json"
}

package_libgl1-mesa-dri() {
  _prepare_staging
  pkgdesc="Mesa DRI OpenGL drivers"
  depends=(
    "libc6"
    "libgbm1"
    "libvulkan1"
  )
  _copy_glob_from_stage64 "usr/lib/*/dri/*.so*"
  # VA-API drivers belong to mesa-va-drivers, not libgl1-mesa-dri.
  # Remove both regular files and symlinks to avoid dpkg overwrite conflicts.
  find "${pkgdir}/usr/lib" -name '*_drv_video.so*' -delete 2>/dev/null || true
}
