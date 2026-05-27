pkgname="libstd-rust-dev-arm64"
gives="libstd-rust-dev"
pkgver="1.93.1"
pkgrel="1"
pkgdesc="Rust standard library for aarch64-unknown-linux-gnu"
arch=("arm64" "amd64")
url='https://www.rust-lang.org/'
maintainer=("xdavius <xdavius@github.com>")
custom_fields=("Multi-Arch: same")

source=("https://static.rust-lang.org/dist/rust-std-${pkgver}-aarch64-unknown-linux-gnu.tar.xz")
sha256sums=("SKIP")

_force_deb_arch_arm64() {
  # Pacstall writes final Architecture from CARCH during makedeb().
  # Persist it into safeenv so the value survives bwrap function scope.
  if [ -n "${safeenv:-}" ]; then
    printf 'CARCH="arm64"\nexport CARCH\n' >> "${safeenv}"
  fi
  export CARCH="arm64"
}

package() {
  arch=("arm64")
  _force_deb_arch_arm64
  cd "${srcdir}/rust-std-${pkgver}-aarch64-unknown-linux-gnu" || exit 1
  ./install.sh --destdir="${pkgdir}" --prefix=/usr --disable-ldconfig || exit 1
}
