#This is free and unencumbered software released into the public domain.
#
#Anyone is free to copy, modify, publish, use, compile, sell, or
#distribute this software, either in source code form or as a compiled
#binary, for any purpose, commercial or non-commercial, and by any
#means.
#
#In jurisdictions that recognize copyright laws, the author or authors
#of this software dedicate any and all copyright interest in the
#software to the public domain. We make this dedication for the benefit
#of the public at large and to the detriment of our heirs and
#successors. We intend this dedication to be an overt act of
#relinquishment in perpetuity of all present and future rights to this
#software under copyright law.
#
#THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
#EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
#MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
#IN NO EVENT SHALL THE AUTHORS BE LIABLE FOR ANY CLAIM, DAMAGES OR
#OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,
#ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
#OTHER DEALINGS IN THE SOFTWARE.
#
{ stdenv
, lib
, fetchurl
, callPackage
, stdenvNoCC
, unzip
, pkgs
}:
let
  nrf-series = "nRF5";
  version = "17.1.0";
  subversion = "ddde560";
  sdks-url = "https://www.nordicsemi.com/-/media/Software-and-other-downloads/SDKs";

  fetchurlWithHttpie = import ./fetchurlWithHttpie/default.nix { inherit pkgs; };
in
stdenv.mkDerivation{
  pname = "nrf52-sdk";
  inherit version;

  # NOTE: Regular (curl) fetchurl doesn't seem to work but does on command line
  # hence the use of a custom fetcher
  src = fetchurlWithHttpie {
    url = "${sdks-url}/${nrf-series}/Binaries/${nrf-series}_SDK_${version}_${subversion}.zip";
    sha256 = "1l6lafiqd5jwsx0p89kxpx5v2gkyjh61sczmilz9k04bks4hzwq7";
  };

  nativeBuildInputs = [ unzip ];

  unpackPhase = ''
    unzip -q $src
  '';

  # Nothing to configure or build
  configurePhase = false;
  buildPhase = false;

  installPhase = ''
    source $stdenv/setup
    cp -r ${nrf-series}_SDK_${version}_${subversion}/ $out
    set +x
  '';

  # Fix Makefile.posix that assumes regular linux FHS layout
  postFixup = ''
    echo "post install"
    substituteInPlace $out/components/toolchain/gcc/Makefile.posix \
        --replace "/usr/local/gcc-arm-none-eabi-9-2020-q2-update/bin/" "\$(which arm-none-eabi-gcc)" \
        --replace "9.3.1" "\$(arm-none-eabi-gcc -dumpversion)"
  '';

  meta = with lib; {
    description = "Software development kit for the nRF52 Series and nRF51 Series SoCs";
    homepage = "https://www.nordicsemi.com/Products/Development-software/nrf5-sdk/download";
    license = licenses.unfree;
    platforms = platforms.linux;
  };
}
