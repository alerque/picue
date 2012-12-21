# Maintainer: Caleb Maclennan <caleb@alerque.com> 
pkgname=lyricue 
pkgver=3.4.10 
pkgrel=1 
epoch= 
pkgdesc="GNU Lyric Display System, client interface"
arch=('x86_64')
url="http://www.lyricue.org"
license=('GPL')
groups=()
depends=('clutter clutter-gtk clutter-gst')
makedepends=('intltool pkg-config')
checkdepends=()
optdepends=()
provides=()
conflicts=()
replaces=()
backup=()
options=()
install=
changelog=
source=(http://www.lyricue.org/archive/${pkgname}_$pkgver.tar.gz)
noextract=()
md5sums=('7276c53c70a3b4334f0d4cc2a7ba9539')

build() {
	  cd "$srcdir/$pkgname-$pkgver"
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