pkgbase="qt6pas"
pkgver="6.2.10"
_lazarus_tag="4_6"
_lazarus_version="4.6.0"
url='https://gitlab.com/freepascal.org/lazarus/'
source=("@${pkgbase}~${pkgver}::https://gitlab.com/freepascal.org/lazarus/lazarus/-/archive/lazarus_${_lazarus_tag}/lazarus-lazarus_${_lazarus_tag}.tar.bz2")
arch=("amd64")
makedepends=('qt6-base-dev' 'qmake6' 'libgl-dev')
pkgname=("libqt6pas6" "libqt6pas-dev")
sha256sums=("7b4a19232c417718e02ca5e3fb142bfeed46b8895056c7572234e9c19e1b25cc")
pkgdesc="Free Pascal Qt6 binding library updated by lazarus IDE"
maintainer=("xdavius <xdavius@github.com>")
repology=("project: qt6pas")

build() {
  cd "${pkgbase}~${pkgver}"/lcl/interfaces/qt6/cbindings
  qmake6
  make -j"${NCPU}"
  if [ ! -d "${srcdir}/_stage-qt6pas/usr" ]; then
    make INSTALL_ROOT="${srcdir}/_stage-qt6pas" install
  fi
}

package_libqt6pas6() {
  pkgdesc="Qt6 bindings runtime library for Free Pascal/Lazarus"

  mkdir -p "${pkgdir}/usr/lib"
  cp -r --no-preserve=ownership "${srcdir}/_stage-qt6pas/usr/lib/"* "${pkgdir}/usr/lib/" 2>/dev/null || true
  find "${pkgdir}/usr/lib" -type f -name '*.a' -delete 2>/dev/null || true
  find "${pkgdir}/usr/lib" -type f -name '*.la' -delete 2>/dev/null || true
  find "${pkgdir}/usr/lib" -type l -name '*.so' -delete 2>/dev/null || true
  rm -rf "${pkgdir}/usr/lib/pkgconfig" 2>/dev/null || true
  rm -rf "${pkgdir}/usr/include" 2>/dev/null || true
}

package_libqt6pas-dev() {
  pkgdesc="Development files for Qt6 bindings for Free Pascal/Lazarus"
  depends=("libqt6pas6")

  mkdir -p "${pkgdir}/usr"
  if [ -d "${srcdir}/_stage-qt6pas/usr/include" ]; then
    cp -r --no-preserve=ownership "${srcdir}/_stage-qt6pas/usr/include" "${pkgdir}/usr/include"
  fi
  if [ -d "${srcdir}/_stage-qt6pas/usr/lib/pkgconfig" ]; then
    mkdir -p "${pkgdir}/usr/lib"
    cp -r --no-preserve=ownership "${srcdir}/_stage-qt6pas/usr/lib/pkgconfig" "${pkgdir}/usr/lib/pkgconfig"
  fi
  mkdir -p "${pkgdir}/usr/lib"
  find "${srcdir}/_stage-qt6pas/usr/lib" -maxdepth 1 -type l -name '*.so' -exec cp -a --no-preserve=ownership {} "${pkgdir}/usr/lib/" \; 2>/dev/null || true
  find "${srcdir}/_stage-qt6pas/usr/lib" -maxdepth 1 -type f -name '*.a' -exec cp -a --no-preserve=ownership {} "${pkgdir}/usr/lib/" \; 2>/dev/null || true
  find "${srcdir}/_stage-qt6pas/usr/lib" -maxdepth 1 -type f -name '*.la' -exec cp -a --no-preserve=ownership {} "${pkgdir}/usr/lib/" \; 2>/dev/null || true
}
