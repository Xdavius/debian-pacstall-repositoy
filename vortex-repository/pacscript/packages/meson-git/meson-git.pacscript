pkgname="meson-git"
gives="meson-git"
provides="meson"
replace="meson"
pkgver=1.5
pkgdesc="SCons-like build system that use python as a front-end language and Ninja as a building backend with debian-meson forked from arch-meson"
arch=(any)
url="http://mesonbuild.com/"
depends=("python3" "ninja-build")
makedepends=(
  "git"
  "python3-build"
  "python3-installer"
  "python3-setuptools"
  "python3-wheel"
  "ninja-build"
  "python3-tqdm"
  "python3-typing-extensions"
)

source=("git+https://github.com/mesonbuild/meson"
         "debian-meson"
         "cross-lib32"
         "native-clang")
sha256sums=("SKIP"
  "068e89ba65b42b852f9760a518c2a5bcda0ff261e5eb3f2b058f721908f10821"
  "47e6b7d18f2fbde2edd5674c812b9d4a279feb6d7f947310736c39cde28f8831"
  "a1fa7d0c3113776337a7e875a35d7cf625000d98024ad4537af23f719c50bfa4")

pkgver() {
	cd "${srcdir}/${pkgname%-git}"
	printf "%s" "$(git describe --long | sed 's/\([^-]*-\)g/r\1/;s/-/./g')"
}

package() {
	cd "${srcdir}/${pkgname%-git}"
	python setup.py install --root="${pkgdir}" --optimize=1
	install -D -m644 COPYING ${pkgdir}/usr/share/licenses/${pkgname}/COPYING
  for _f in data/syntax-highlighting/vim/*/*; do
    install -Dt "${pkgdir}/usr/share/vim/vimfiles/$(basename "$(dirname "$_f")")" -m644 "$_f"
  done
  install -Dt "${pkgdir}/usr/share/zsh/site-functions" -m644 data/shell-completions/zsh/*
  install -Dm755 ../debian-meson -t "${pkgdir}/usr/bin"
  install -Dm644 ../cross-lib32 "${pkgdir}/usr/share/meson/cross/lib32"
  install -Dm644 ../native-clang "${pkgdir}/usr/share/meson/native/clang"
}
