pkgname="libstd-rust-dev-amd64"
gives="libstd-rust-dev"
pkgver="1.93.1"
pkgrel="1"
pkgdesc="Rust standard library for x86_64-unknown-linux-gnu"
arch=("amd64")
url='https://www.rust-lang.org/'
maintainer=("xdavius <xdavius@github.com>")
custom_fields=("Multi-Arch: same")

source=("https://static.rust-lang.org/dist/rust-std-${pkgver}-x86_64-unknown-linux-gnu.tar.xz")
sha256sums=("SKIP")

package() {
  cd "${srcdir}/rust-std-${pkgver}-x86_64-unknown-linux-gnu" || exit 1
  ./install.sh --destdir="${pkgdir}" --prefix=/usr --disable-ldconfig || exit 1
}
