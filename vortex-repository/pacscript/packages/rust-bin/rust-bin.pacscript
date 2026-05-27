pkgbase="rust-bin"
pkgver="1.93.1"
pkgrel="1"
pkgdesc="Rust toolchain split into Debian-like binary packages"
arch=("x86_64" "aarch64")
repology=("project: rust")
url='https://www.rust-lang.org/'
maintainer=("xdavius <xdavius@github.com>" "aKqir24 <aKqir24@github.com>")

pkgname=(
  "rustc"
  "cargo"
  "rustfmt"
  "rust-clippy"
  "rust-src"
  "libstd-rust-dev"
)

source_x86_64=(
  "https://static.rust-lang.org/dist/rust-${pkgver}-x86_64-unknown-linux-gnu.tar.xz"
)
sha256sums_x86_64=(
  "518872275a3648f735471d7add854d39171c5a6b17f423c4d7f931f52120c2af"
)

source_aarch64=("https://static.rust-lang.org/dist/rust-${pkgver}-aarch64-unknown-linux-gnu.tar.xz")
sha256sums_aarch64=("701d55b62286bed013ceb2393ff7687d0953205605afaa15c62e2cd18024c32c")

prepare() {
  if [ ! -d "${srcdir}/_stage-rust/usr" ]; then
    cd "${srcdir}/rust-${pkgver}-${AARCH}-unknown-linux-gnu" || exit 1
    ./install.sh --destdir="${srcdir}/_stage-rust" --prefix=/usr --disable-ldconfig || exit 1
  fi
}

package_rustc() {
  pkgdesc="Rust systems programming language compiler"
  depends=("libstd-rust-dev")

  mkdir -p "${pkgdir}/usr/bin" "${pkgdir}/usr/share/man/man1"
  cp -r --no-preserve=ownership "${srcdir}/_stage-rust/usr/bin/rustc" "${pkgdir}/usr/bin/rustc"
  cp -r --no-preserve=ownership "${srcdir}/_stage-rust/usr/bin/rustdoc" "${pkgdir}/usr/bin/rustdoc"
  cp -r --no-preserve=ownership "${srcdir}/_stage-rust/usr/share/man/man1/rustc.1" "${pkgdir}/usr/share/man/man1/rustc.1"
  cp -r --no-preserve=ownership "${srcdir}/_stage-rust/usr/share/man/man1/rustdoc.1" "${pkgdir}/usr/share/man/man1/rustdoc.1"
}

package_cargo() {
  pkgdesc="Rust package manager"
  depends=("rustc" "libstd-rust-dev")

  mkdir -p "${pkgdir}/usr/bin" "${pkgdir}/usr/share/man/man1"
  cp -r --no-preserve=ownership "${srcdir}/_stage-rust/usr/bin/cargo" "${pkgdir}/usr/bin/cargo"
  cp -r --no-preserve=ownership "${srcdir}/_stage-rust/usr/share/man/man1/cargo.1" "${pkgdir}/usr/share/man/man1/cargo.1"
}

package_rustfmt() {
  pkgdesc="Rust formatting tool"
  depends=("rustc" "cargo" "libstd-rust-dev")

  mkdir -p "${pkgdir}/usr/bin"
  cp -r --no-preserve=ownership "${srcdir}/_stage-rust/usr/bin/rustfmt" "${pkgdir}/usr/bin/rustfmt"
  cp -r --no-preserve=ownership "${srcdir}/_stage-rust/usr/bin/cargo-fmt" "${pkgdir}/usr/bin/cargo-fmt"
}

package_rust-clippy() {
  pkgdesc="Rust lints"
  depends=("rustc" "cargo" "libstd-rust-dev")

  mkdir -p "${pkgdir}/usr/bin"
  cp -r --no-preserve=ownership "${srcdir}/_stage-rust/usr/bin/clippy-driver" "${pkgdir}/usr/bin/clippy-driver"
  cp -r --no-preserve=ownership "${srcdir}/_stage-rust/usr/bin/cargo-clippy" "${pkgdir}/usr/bin/cargo-clippy"
}

package_rust-src() {
  pkgdesc="Rust standard library source"

  mkdir -p "${pkgdir}/usr/lib/rustlib"
  cp -r --no-preserve=ownership "${srcdir}/_stage-rust/usr/lib/rustlib/src" "${pkgdir}/usr/lib/rustlib/src"
}

package_libstd-rust-dev() {
  pkgdesc="Rust standard library for host target"
  mkdir -p "${pkgdir}/usr/lib/rustlib"
  cp -r --no-preserve=ownership \
    "${srcdir}/_stage-rust/usr/lib/rustlib/${AARCH}-unknown-linux-gnu" \
    "${pkgdir}/usr/lib/rustlib/${AARCH}-unknown-linux-gnu"
}
