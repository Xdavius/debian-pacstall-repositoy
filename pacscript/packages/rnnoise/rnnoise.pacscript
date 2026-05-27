pkgname="rnnoise"
gives="rnnoise"
pkgver="0.2"
pkgrel=1
pkgdesc="Recurrent neural network for audio noise suppression"
url="https://github.com/xiph/rnnoise"
arch=("amd64")
license=("BSD-3-Clause")
source=("https://github.com/xiph/rnnoise/archive/refs/tags/v${pkgver}.tar.gz")
sha256sums=("SKIP")
makedepends=("autoconf" "automake" "libtool" "pkg-config")
external_connection=true

build() {
  cd "${gives}-${pkgver}"
  ./autogen.sh
  ./configure --prefix=/usr
  make -j"${NCPU}"
}

package() {
  cd "${gives}-${pkgver}"
  make DESTDIR="${pkgdir}" install
}

post_install() {
  ldconfig
}

post_upgrade() {
  post_install
}

post_remove() {
  post_install
}