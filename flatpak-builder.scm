;;; GNU Guix --- Functional package management for GNU
;;; Copyright © 2013-2024 Ludovic Courtès <ludo@gnu.org>
;;; Copyright © 2015, 2017, 2020, 2021, 2022, 2023 Ricardo Wurmus <rekado@elephly.net>
;;; Copyright © 2017 Muriithi Frederick Muriuki <fredmanglis@gmail.com>
;;; Copyright © 2017, 2018 Oleg Pykhalov <go.wigust@gmail.com>
;;; Copyright © 2017 Roel Janssen <roel@gnu.org>
;;; Copyright © 2017–2022 Tobias Geerinckx-Rice <me@tobias.gr>
;;; Copyright © 2018 Julien Lepiller <julien@lepiller.eu>
;;; Copyright © 2018, 2019 Rutger Helling <rhelling@mykolab.com>
;;; Copyright © 2018 Sou Bunnbu <iyzsong@member.fsf.org>
;;; Copyright © 2018, 2019 Eric Bavier <bavier@member.fsf.org>
;;; Copyright © 2019-2024 Efraim Flashner <efraim@flashner.co.il>
;;; Copyright © 2019 Jonathan Brielmaier <jonathan.brielmaier@web.de>
;;; Copyright © 2020 Mathieu Othacehe <m.othacehe@gmail.com>
;;; Copyright © 2020, 2023 Janneke Nieuwenhuizen <janneke@gnu.org>
;;; Copyright © 2020 Giacomo Leidi <goodoldpaul@autistici.org>
;;; Copyright © 2020 Jesse Gibbons <jgibbons2357+guix@gmail.com>
;;; Copyright © 2020 Martin Becze <mjbecze@riseup.net>
;;; Copyright © 2020 Vincent Legoll <vincent.legoll@gmail.com>
;;; Copyright © 2021 Ivan Gankevich <i.gankevich@spbu.ru>
;;; Copyright © 2021, 2022, 2023 Maxim Cournoyer <maxim.cournoyer@gmail.com>
;;; Copyright © 2021 John Kehayias <john.kehayias@protonmail.com>
;;; Copyright © 2022, 2023 Zhu Zihao <all_but_last@163.com>
;;; Copyright © 2023 jgart <jgart@dismail.de>
;;; Copyright © 2023 Mădălin Ionel Patrașcu <madalinionel.patrascu@mdc-berlin.de>
;;; Copyright © 2024 Arun Isaac <arunisaac@systemreboot.net>
;;;
;;; This file is part of GNU Guix.
;;;
;;; GNU Guix is free software; you can redistribute it and/or modify it
;;; under the terms of the GNU General Public License as published by
;;; the Free Software Foundation; either version 3 of the License, or (at
;;; your option) any later version.
;;;
;;; GNU Guix is distributed in the hope that it will be useful, but
;;; WITHOUT ANY WARRANTY; without even the implied warranty of
;;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;;; GNU General Public License for more details.
;;;
;;; You should have received a copy of the GNU General Public License
;;; along with GNU Guix.  If not, see <http://www.gnu.org/licenses/>.

(define-module (gnu packages flatpak-builder)
  #:use-module (guix packages)
  #:use-module (guix git-download)
  #:use-module (guix build-system gnu)
  #:use-module (gnu packages package-management)
  #:use-module (guix build-system meson)
  #:use-module (gnu packages elf)
  #:use-module (gnu packages glib)
  #:use-module (gnu packages gstreamer)
  #:use-module (gnu packages gnome)
  #:use-module (gnu packages curl)
  #:use-module (gnu packages serialization)
  #:use-module (gnu packages autotools)
  #:use-module (gnu packages m4)
  #:use-module (gnu packages pkg-config)
  #:use-module (gnu packages gettext)
  #:use-module (gnu packages base)
  #:use-module (gnu packages compression)
  #:use-module (gnu packages linux)
  #:use-module (gnu packages man)
  #:use-module (gnu packages cmake)
  #:use-module (guix gexp)
  #:use-module ((guix licenses) #:prefix license:))

(define-public libglnx
  (let ((commit "4e44fd9c174e4196a86fb6d954722feaff612c88")
        (revision "0"))
    (package
      (name "libglnx")
      (version (git-version "0" revision commit))
      (source
       (origin
         (method git-fetch)
         (uri (git-reference
               (url "https://gitlab.gnome.org/GNOME/libglnx.git")
               (commit commit)))
         (file-name (git-file-name name version))
         (sha256
          (base32 "0b1aqrls3ql2c820plwg0vnxh4xkixvxbkn8mxbyqar7ni8nz0wj"))))
      (build-system meson-build-system)
      (arguments
       (list
        ;; Using a "release" build is recommended for performance
        #:build-type "release"
        #:phases
        #~(modify-phases %standard-phases
            (add-before 'configure 'prepare-install
              (lambda _
                ;; Install lib.
                (substitute* "meson.build"
                  (("^  install : false)")
                   (string-append
                    "  install : true)" "\n"
                    "install_headers("
                    (string-join
                     (map (lambda (x) (string-append "'" x "'"))
                          (delete "config.h" (find-files "." "\\.h$")))
                     ", ")
                    ")" )))))
            (add-after 'install 'install-linglnx-config
              (lambda _
                (install-file "libglnx-config.h"
                              (string-append #$output "/include")))))))
      (native-inputs (list cmake pkg-config))
      (propagated-inputs (list glib))
      (home-page "https://gitlab.gnome.org/GNOME/libglnx.git")
      (synopsis "libglnx is an extension to glib")
      (description
       "libglnx is the successor to libgsystem.  It is used for modules which
depend on both Glib and Linux.")
      (license license:lgpl2.1))))

(define-public debugedit
  (package
   (name "debugedit")
   (version "5.0")
   (source
    (origin
     (method git-fetch)
     (uri (git-reference
           (url "https://sourceware.org/git/debugedit.git")
           (commit (string-append name "-" version) )))
     (file-name (git-file-name name version))
     (sha256
      (base32 "1jxiizzzvx89dhs99aky48kl5s49i5zr9d7j4753gp0knk4pndjm"))))
   (build-system gnu-build-system)
   (arguments '(#:tests? #f))
   (propagated-inputs (list elfutils))
   (inputs (list zlib xz))
   (native-inputs
    (list
     autoconf automake m4 util-linux libtool help2man pkg-config))
   (home-page "https://sourceware.org/git/debugedit.git")
   (synopsis "Tool for debugging")
   (description
    "The debugedit project provides programs and scripts for creating
debuginfo and source file distributions, collect build-ids and rewrite
source paths in DWARF data for debugging, tracing and profiling.

It is based on code originally from the rpm project plus libiberty and
binutils.  It depends on the elfutils libelf and libdw libraries to
read and write ELF files, DWARF data and build-ids.")
   (license license:lgpl2.1)))

(package
 (name "flatpak-builder")
 (version "1.2.3")
 (source
  (origin
   (method git-fetch)
   (uri (git-reference
         (url "https://github.com/flatpak/flatpak-builder.git")
         (commit version)))
   (file-name (git-file-name name version))
   (sha256
    (base32 "07pih8v2i3jzyy8zccdljgi3pgj52bgycrh4h5s20lwdxgnh2hb3"))))
 (build-system gnu-build-system)
 (arguments
  '(#:configure-flags
    (list
     "--enable-documentation=no"
     "--with-system-debugedit")
    #:phases
    (modify-phases %standard-phases
                   (add-after 'unpack 'disable-submodules
                              (lambda* (#:key inputs #:allow-other-keys)
                                (let ((llibglnx (assoc-ref inputs "libglnx")))
                                  (substitute* "autogen.sh"
                                               (("^if ! test -f libglnx/README.md; then")
                                                "if test -f libglnx/README.md; then")
                                               ((".*subprojects/libglnx.*") ""))
                                  (substitute* "configure.ac"
                                               (("LIBGLNX_CONFIGURE") ""))
                                  (substitute* "src/Makefile.am.inc"
                                               (("libglnx.la") "-lglnx"))
                                  (substitute* "Makefile.am"
                                               (("^include subprojects/libglnx/Makefile-libglnx.am.inc")
                                                "")
                                               ((".*libglnx_srcpath.*") "")
                                               ((".*/subprojects/debugedit.*") "")
                                               (("-I subprojects/libglnx")
                                                (string-append "-I " llibglnx "/include"))
                                               ((".*subprojects/libglnx.*")
                                                (string-append "  -I " llibglnx "/include"))
                                               (("noinst_LTLIBRARIES .=.*") "")
                                               (("libglnx_libs :=.*")
                                                (string-append "LDFLAGS = -L" llibglnx " -lglnx -static" "\n"))
                                               (("libglnx_cflags :=") "LIBGLNX_CFLAGS = -lglnx"))
                                  (substitute*
                                   '("src/builder-cache.c"
                                     "src/builder-cache.h"
                                     "src/builder-extension.c"
                                     "src/builder-flatpak-utils.c"
                                     "src/builder-flatpak-utils.h"
                                     "src/builder-main.c"
                                     "src/builder-manifest.c"
                                     "src/builder-module.c"
                                     "src/builder-post-process.c")
                                   (("\"libglnx/libglnx.h\"") "<libglnx.h>")
                                   (("<libglnx/libglnx.h>") "<libglnx.h>")))))
                   ;; Test are supposed to be done in /var/tmp because of the need for
                   ;; xattrs. Nonetheless, moving it back to /tmp makes tests suceed.
                   (add-before 'check 'allow-tests
                               (lambda _
                                 (substitute* '("buildutil/tap-test" "tests/libtest.sh")
                                              (("\\/var\\/tmp\\/")
                                               "/tmp/")))))))
 (propagated-inputs (list flatpak debugedit libglnx elfutils))
 (inputs
  (list libsoup-minimal-2
        libostree
        json-glib
        curl
        libyaml))
 (native-inputs
  (list autoconf
        automake
        m4
        libtool
        pkg-config
        gettext-minimal
        which))
 (home-page "https://github.com/flatpak/flatpak-builder.git")
 (synopsis "Tool to build flatpaks from source")
 (description "@code{flatpak-builder} is a wrapper around the flatpak build
command that automates the building of applications and their dependencies.
It is one option you can use to build applications.

The goal of flatpak-builder is to push as much knowledge about how to build
modules to the individual upstream projects.  An invocation of flatpak-builder
proceeds in these stages, each being specified in detail in json format in
the file MANIFEST :

@itemize
@item Download all sources
@item Initialize the application directory with flatpak build-init
@item Build and install each module with flatpak build
@item Clean up the final build tree by removing unwanted files and
e.g. stripping binaries
@item Finish the application directory with flatpak build-finish
@end itemize")
 (license license:lgpl2.1))
