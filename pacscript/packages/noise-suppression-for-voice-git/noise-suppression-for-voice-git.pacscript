pkgname="noise-suppression-for-voice-git"
gives="noise-suppression-for-voice"
pkgver="1.03.r2.gc1cf430"
pkgrel=1
pkgdesc="A real-time noise suppression plugin for voice"
url="https://github.com/werman/noise-suppression-for-voice"
arch=('amd64')
license=('GPL-3.0-or-later')
source=("https://github.com/werman/noise-suppression-for-voice.git")
sha256sums=('SKIP')
makedepends=('cmake' 'git' 'libfreetype-dev' 'libx11-dev' 'libxrandr-dev' 'libxinerama-dev' 'libxcursor-dev')
depends=('libfreetype6')
breaks=('noise-suppression-for-voice')
maintainer='xdavius <xdavius@github.com>'
external_connection=true

build() {
  cd "${_archive}"
  cmake -B build -S . \
    -DCMAKE_INSTALL_PREFIX=/usr \
    -DCMAKE_BUILD_TYPE=None
  cmake --build build -j"${NCPU}"
}

package() {
  cd "${_archive}"
  DESTDIR="${pkgdir}" cmake --install build
}
