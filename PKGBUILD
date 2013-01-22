# Maintainer: Caleb Maclennan <caleb@alerque.com>
pkgname=lyricue
pkgver=3.4.10
pkgrel=1
epoch=
pkgdesc="GNU Lyric Display System, client interface"
arch=(x86_64 armv6h)
url="http://www.lyricue.org"
license=('GPL')
groups=()
depends=(clutter clutter-gtk clutter-gst mysql mysql-clients perl-dbi pango-perl gtk2-perl perl-uri perl-xml-simple gnome-perl perl-file-mimeinfo perl-dbd-mysql)
makedepends=(intltool pkg-config patch gcc make)
checkdepends=()
optdepends=()
provides=()
conflicts=()
replaces=()
backup=()
options=()
install=
changelog=
source=(http://www.lyricue.org/archive/${pkgname}_$pkgver.tar.gz https://github.com/alerque/picue/raw/master/clutter-gst.patch https://github.com/alerque/picue/raw/master/gstreamer.patch)
noextract=()
md5sums=('7276c53c70a3b4334f0d4cc2a7ba9539'
         'f999984a8f5659129b237f25c657cfae'
         'b2bc18a48be5f8fc3ebe8fbc5d7d4fa0')

build() {
  cd "$srcdir/$pkgname-$pkgver"
  patch -Np0 -i "$srcdir/clutter-gst.patch"
  patch -Np0 -i "$srcdir/gstreamer.patch"
  ./configure --prefix=/usr
  make
}

check() {
  cd "$srcdir/$pkgname-$pkgver"
  make -k check
}

package() {
  cd "$srcdir/$pkgname-$pkgver"
  make DESTDIR="$pkgdir/" install
}

# vim:set ts=2 sw=2 et:

