{ lib
, appimageTools
, fetchurl
, stdenvNoCC
}:

let
  pname = "texts";
  version = "0.83.8";
  appimage-src = fetchurl {
    url = "https://texts-binaries.texts.com/builds/Texts-Linux-x64-v0.83.8-33a70a962c.AppImage";
    sha256 = "0d10q1hkmbsb329rg42y3g17j63iqcmw62ip3mk8s6m906dfx734";
  };
  appimage = appimageTools.wrapType1 {
    inherit pname version;
    src = appimage-src;

    extraPkgs = pkgs: with pkgs; [
      libsecret
      libappindicator
      libindicator
      libnotify
      xorg.libXScrnSaver
      xorg.libXtst
    ];
  };
  appimage-cont = appimageTools.extractType1 {
    inherit pname version;
    src = appimage-src;
  };
in
stdenvNoCC.mkDerivation {
  inherit pname version;
  src = appimage;

  # The app refers to its command line as 'jack' on stdout.
  # Maybe add something like 'ln -s ${pname} $out/bin/jack'?
  installPhase = ''
    mkdir -p $out/bin
    cp -r $src/bin/${pname}-${version} $out/bin/${pname}

    mkdir -p $out/share/texts-jack
    cp -a ${appimage-cont}/locales $out/share/texts-jack/
    cp -a ${appimage-cont}/resources $out/share/texts-jack/
    cp -a ${appimage-cont}/usr/share/icons $out/share/
    mkdir -p $out/share/applications

    install -Dm 664 ${appimage-cont}/jack.desktop -t $out/share/applications/
    substituteInPlace $out/share/applications/jack.desktop \
      --replace "AppRun" "${pname}"
  '';

  meta = with lib; {
    description = "Universal chat app supporting most popular chat networks.";
    homepage = "https://texts.com/";
    license = licenses.unfree;
    platforms = [ "x86_64-linux" ];
    maintainers = [ maintainers.kintrix ];
  };
}
