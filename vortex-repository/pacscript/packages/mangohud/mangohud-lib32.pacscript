pkgname="mangohud-lib32"
gives="mangohud"
repology=("project: mangohud")
pkgver="0.8.2"
source=("@${pkgname}~${pkgver}::https://github.com/flightlessmango/MangoHud/archive/refs/tags/v${pkgver}.tar.gz")
url='https://github.com/flightlessmango/MangoHud'
makedepends=(
  "g++-multilib"
  "gcc-multilib"
  "meson"
  "ninja-build"
  "python3-mako"
  "pkg-config"
  "glslang-tools"
  "libc6-dev-i386"
  "libdbus-1-dev:i386"
  "libdrm-dev:i386"
  "libvulkan-dev:i386"
  "libwayland-dev:i386"
  "libx11-dev:i386"
  "libxkbcommon-dev:i386"
  "libxnvctrl-dev:i386"
)
arch=("amd64")
custom_fields=("Multi-Arch: same")
pkgdesc="A Vulkan/OpenGL overlay for 32-bit games (i386 userspace)"
sha256sums=("e23ae164c8936e78b7ccfce497f329968df4a7fb80ee9126d21e0855b9fecca8")
maintainer=("xdavius <xdavius@github.com>")
external_connection=true

_force_deb_arch_i386() {
  if [ -n "${safeenv:-}" ]; then
    printf 'CARCH="i386"\nexport CARCH\n' >> "${safeenv}"
  fi
  export CARCH="i386"
}

build() {
  cd "${pkgname}~${pkgver}"

  export CC="gcc -m32"
  export CXX="g++ -m32"
  export PKG_CONFIG_PATH="/usr/lib/i386-linux-gnu/pkgconfig:/usr/lib/pkgconfig"

  meson setup build32 --libdir="lib/i386-linux-gnu" --prefix="/usr"
  ninja -j"${NCPU}" -C build32
}

package() {
  cd "${pkgname}~${pkgver}"
  arch=("i386")
  _force_deb_arch_i386
  DESTDIR="${pkgdir}" ninja -j"${NCPU}" -C build32 install

  # lib32 package should only ship i386 runtime bits.
  # Remove host-arch/common files that would conflict with amd64 package.
  rm -rf "${pkgdir}/usr/bin" 2>/dev/null || true
  rm -rf "${pkgdir}/usr/share/applications" 2>/dev/null || true
  rm -rf "${pkgdir}/usr/share/man" 2>/dev/null || true
  rm -rf "${pkgdir}/usr/share/doc" 2>/dev/null || true
  rm -rf "${pkgdir}/usr/share/icons" 2>/dev/null || true
  rm -rf "${pkgdir}/usr/share/metainfo" 2>/dev/null || true
  rm -rf "${pkgdir}/usr/lib/x86_64-linux-gnu" 2>/dev/null || true
}
