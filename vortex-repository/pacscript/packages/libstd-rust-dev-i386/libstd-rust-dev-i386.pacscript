pkgname="libstd-rust-dev-i386"
gives="libstd-rust-dev"
pkgver="1.93.1"
pkgrel="1"
pkgdesc="Rust standard library for i686-unknown-linux-gnu"
arch=("i386" "amd64")
url='https://www.rust-lang.org/'
maintainer=("xdavius <xdavius@github.com>")
custom_fields=("Multi-Arch: same")

source=("https://static.rust-lang.org/dist/rust-std-${pkgver}-i686-unknown-linux-gnu.tar.xz")
sha256sums=("SKIP")

_force_deb_arch_i386() {
  # Pacstall writes final Architecture from CARCH during makedeb().
  # Persist it into safeenv so the value survives bwrap function scope.
  if [ -n "${safeenv:-}" ]; then
    printf 'CARCH="i386"\nexport CARCH\n' >> "${safeenv}"
  fi
  export CARCH="i386"
}

package() {
  arch=("i386")
  _force_deb_arch_i386
  cd "${srcdir}/rust-std-${pkgver}-i686-unknown-linux-gnu" || exit 1
  ./install.sh --destdir="${pkgdir}" --prefix=/usr --disable-ldconfig || exit 1
}
