pkgname="goverlay-bin"
gives="goverlay"
arch=("amd64")
pkgver="1.8.1"
source=(
  "https://github.com/benjamimgois/goverlay/releases/download/${pkgver}/goverlay_1_8_1.tar.xz"
  "https://raw.githubusercontent.com/benjamimgois/goverlay/master/data/icons/128x128/goverlay.png"
)
sha256sums=(
  "4493b2f54bb7b0d464d5908b177dc2360106e890df42d744f2b0970185ddb8ea"
  "29a22d04459716f161d90cf10845c782034f822ecab468b433e99f1732aaccba"
)
depends=(
  "mangohud" 
  "qt6ct" 
  "adwaita-qt6" 
  "libqt6pas6" 
)
optdepends=(
  "mesa-utils: OpenGL preview"
  "vulkan-tools: Vulkan preview"
  "vkbasalt: Configure vkBasalt"
  "libnotify-bin: Desktop notifications"
)
pkgdesc="Graphical UI to help manage Linux overlays"
maintainer=("xdavius <xdavius@github.com>")
repology=("project: goverlay")

package() {
  mkdir -p "${pkgdir}/usr/bin/" "${pkgdir}/usr/share/applications/" "${pkgdir}/usr/share/icons/hicolor/128x128/apps/"
  
  install -Dm755 goverlay "${pkgdir}/usr/bin/goverlay"
  chmod +x "${pkgdir}/usr/bin/goverlay"
  echo '[Desktop Entry]
Name=GOverlay
Comment=Graphical UI to help manage Vulkan / OpenGL overlays
Exec=goverlay
Icon=goverlay
Terminal=false
Type=Application
Categories=Game;
Keywords=MangoHud;vkBasalt;ReplaySorcery;msi;afterburner;' | tee "${pkgdir}/usr/share/applications/goverlay.desktop" > /dev/null
  install -Dm644 "${srcdir}/goverlay.png" -t "${pkgdir}/usr/share/icons/hicolor/128x128/apps/"
}
