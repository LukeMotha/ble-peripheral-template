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
#For more information, please refer to <http://unlicense.org/>

{ stdenv, callPackage, remake, gcc-arm-embedded }:
let
  nrf52-sdk = callPackage ./nordic-sdk.nix {};
in
stdenv.mkDerivation rec{
  pname = "ble-peripheral-template";
  version = "0.0.1";

  nativeBuildInputs = [
    nrf52-sdk
    remake
    gcc-arm-embedded
  ];

  src = ./.;

  isLibrary = false;
  isExecutable = true;

  # Binaries are for an embedded target so fixup/patching paths is not required
  phases = [ "unpackPhase" "buildPhase" "installPhase" ];

  buildPhase = ''
  echo "SDK is installed at ${nrf52-sdk.outPath}"
  export SDK_ROOT=${nrf52-sdk.outPath}
  remake
  '';

  installPhase = ''
  source $stdenv/setup
  mkdir -p $out/_build
  mkdir -p $out/bin
  cp -r _build/nrf52840_xxaa $out/_build
  cp _build/*.map $out/_build
  cp _build/*.hex $out/bin
  cp _build/*.bin $out/bin
  '';
}
