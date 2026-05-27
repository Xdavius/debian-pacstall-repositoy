gives="xone-dkms"
pkgname="xone-dkms-git"
pkgver=0.5.8
pkgdesc='Modern Linux driver for Xbox One and Xbox Series X|S controllers'
url="https://github.com/dlundqvist/xone"
license=('GPL-2.0-or-later')
arch=('any')
depends=('dkms')
makedepends=('libarchive-tools' 'pandoc')
conflicts=('xone-dkms')
source=("https://github.com/dlundqvist/xone.git"
        "microsoft-terms_of_use.html::https://www.microsoft.com/en-us/legal/terms-of-use"
        "xone_dongle_02e6.cab"::"https://catalog.s.download.windowsupdate.com/d/msdownload/update/driver/drvs/2017/03/2ea9591b-f751-442c-80ce-8f4692cdc67b_6b555a3a288153cf04aec6e03cba360afe2fce34.cab"
        "xone_dongle_02fe.cab"::"https://catalog.s.download.windowsupdate.com/c/msdownload/update/driver/drvs/2017/07/1cd6a87c-623f-4407-a52d-c31be49e925c_e19f60808bdcbfbd3c3df6be3e71ffc52e43261e.cab"
        "xone_dongle_02f9.cab"::"https://catalog.s.download.windowsupdate.com/c/msdownload/update/driver/drvs/2017/06/1dbd7cb4-53bc-4857-a5b0-5955c8acaf71_9081931e7d664429a93ffda0db41b7545b7ac257.cab"
        "xone_dongle_091e.cab"::"https://catalog.s.download.windowsupdate.com/d/msdownload/update/driver/drvs/2017/08/aeff215c-3bc4-4d36-a3ea-e14bfa8fa9d2_e58550c4f74a27e51e5cb6868b10ff633fa77164.cab")
sha256sums=('SKIP'
            'SKIP'
            'd89a72e8dc10b7c4f16d5c887fe7f54c34c22005ac1f360704d5d9462258ef32'
            '65736a84ff4036645b8f8ec602bed91ab6353019c9cb3233decab9feec0f6f04'
            '90dd91fb67460d387407fd8109c0e7d0f18f4b659be0f62db858a1849ead2ee0'
            '5a8fbad9521e58cc697a8734720ca497673098022d61d91a88be433002ccd8f2')
maintainer=("xdavius <xdavius@github.com")
_dkmsname="xone"

prepare() {

_cab=("xone_dongle_02e6.cab" "xone_dongle_02fe.cab" "xone_dongle_02f9.cab" "xone_dongle_091e.cab")
  for i in "${_cab[@]}"; do
    mkdir -p "${i%.*}"
    bsdtar -C "${i%.*}" -xf "$i"
  done

  # Create txt license
  pandoc -f html -t plain microsoft-terms_of_use.html -o microsoft-terms_of_use.txt

  # set module version
  cd "${srcdir}/xone"
  sed -i "s/#VERSION#/${pkgver}/" dkms.conf
}

package() {
  # FIRMWARES
  cd "${srcdir}"
  install -Dm644 "./xone_dongle_02e6/FW_ACC_00U.bin" "${pkgdir}/usr/lib/firmware/xone_dongle_02e6.bin"
  install -Dm644 "./xone_dongle_02fe/FW_ACC_00U.bin" "${pkgdir}/usr/lib/firmware/xone_dongle_02fe.bin"
  install -Dm644 "./xone_dongle_02f9/FW_ACC_CL.bin"  "${pkgdir}/usr/lib/firmware/xone_dongle_02f9.bin"
  install -Dm644 "./xone_dongle_091e/FW_ACC_BR.bin"  "${pkgdir}/usr/lib/firmware/xone_dongle_091e.bin"

  # LICENSE
  install -Dm644 "${srcdir}/microsoft-terms_of_use.txt" "${pkgdir}/usr/share/licenses/${pkgname}/microsoft-terms_of_use.txt"

  # DKMS MODULE
  cd "${srcdir}/xone"
  install -d "${pkgdir}/usr/src/${_dkmsname}-${pkgver}"
  cp -a ./* "${pkgdir}/usr/src/${_dkmsname}-${pkgver}/"

  # Fixing perms
  find "${pkgdir}/usr/src/" -type d -exec chmod 755 {} \;
  find "${pkgdir}/usr/src/" -type f -exec chmod 644 {} \;
  find "${pkgdir}/usr/src/" -type f -name "*.sh" -exec chmod 755 {} +

  # blacklist xpad module
  install -Dm644 "./install/modprobe.conf" "${pkgdir}/usr/lib/modprobe.d/xone-blacklist.conf"
}

pre_upgrade() {
  if dkms status | grep -q "${_dkmsname}/${pkgver}"; then
    dkms remove -m "${_dkmsname}" -v "${pkgver}" --all
  fi
}

post_upgrade() {
  dkms install -m "${_dkmsname}" -v "${pkgver}" --force
    if [[ -f /usr/sbin/update-initramfs ]]; then
      update-initramfs -u
    fi
}

pre_remove() {
  if dkms status | grep -q "${_dkmsname}/${pkgver}"; then
    dkms remove -m "${_dkmsname}" -v "${pkgver}" --all
    update-initramfs -u
  fi
}

post_install() {
  if [[ -d "/lib/modules/${KVER}/build" ]]; then
    if ! dkms status | grep -q "${_dkmsname}/${pkgver}"; then
      dkms install -m "${_dkmsname}" -v "${pkgver}" --force
      if [[ -f /usr/sbin/update-initramfs ]]; then
        update-initramfs -u
      fi
    fi
  else
    echo -e "${BOLD}ERROR:${NC} Linux headers for ${KERNEL_VERSION} not installed."
  fi
}
