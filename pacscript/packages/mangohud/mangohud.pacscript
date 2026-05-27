pkgname="mangohud"
repology=("project: mangohud")
pkgver="0.8.2"
source=("@${pkgname}~${pkgver}::https://github.com/flightlessmango/MangoHud/archive/refs/tags/v${pkgver}.tar.gz")
url='https://github.com/flightlessmango/MangoHud'
makedepends=(
  "meson"
  "ninja-build"
  "python3-mako"
  "pkg-config"
  "glslang-tools"
  "libdbus-1-dev:amd64"
  "libdrm-dev:amd64"
  "libvulkan-dev:amd64"
  "libwayland-dev:amd64"
  "libx11-dev:amd64"
  "libxkbcommon-dev:amd64"
  "libxnvctrl-dev:amd64"
)
incompatible=('debian:bullseye')
arch=("amd64")
custom_fields=("Multi-Arch: same")
pkgdesc="A Vulkan and OpenGL overlay for monitoring FPS, temperatures, CPU/GPU load and more"
sha256sums=("e23ae164c8936e78b7ccfce497f329968df4a7fb80ee9126d21e0855b9fecca8")
maintainer=("xdavius <xdavius@github.com>")
external_connection=true

build() {
  cd "${pkgname}~${pkgver}"
  export PKG_CONFIG_PATH="/usr/lib/x86_64-linux-gnu/pkgconfig:/usr/lib/pkgconfig:/usr/share/pkgconfig"
  meson setup --wipe build64 --prefix="/usr"
  ninja -j"${NCPU}" -C build64
}

package() {
  cd "${pkgname}~${pkgver}"
  DESTDIR="${pkgdir}" ninja -j"${NCPU}" -C build64 install
}
