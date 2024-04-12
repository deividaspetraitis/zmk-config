# Basic configuration for Zephyr development.
{ pkgs ? import (fetchTarball "https://github.com/NixOS/nixpkgs/archive/refs/tags/23.05.tar.gz") { } }:
let
  pp = pkgs.python3.pkgs;
  imgtool = pp.buildPythonPackage rec {
    version = "1.10.0";
    pname = "imgtool";

    src = pp.fetchPypi {
      inherit pname version;
      sha256 = "sha256-A7NOdZNKw9lufEK2vK8Rzq9PRT98bybBfXJr0YMQS0A=";
    };

    propagatedBuildInputs = with pp; [
      cbor2
      click
      intelhex
      cryptography
    ];
    doCheck = false;
    pythonImportsCheck = [
      "imgtool"
    ];
  };

  python-packages = pkgs.python3.withPackages (p: with p; [
    pip
    autopep8
    pyelftools
    pyyaml
    pykwalify
    canopen
    packaging
    progress
    psutil
    anytree
    intelhex
    west
    imgtool

    cryptography
    intelhex
    click
    cbor2

    # For mcuboot CI
    toml

    # For twister
    tabulate
    ply

    # For TFM
    pyasn1
    graphviz
    jinja2

    requests
    beautifulsoup4

    # These are here because pip stupidly keeps trying to install
    # these in /nix/store.
    wcwidth
    sortedcontainers
  ]);

  # Build the Zephyr SDK as a nix package.
  new-zephyr-sdk-pkg =
    { stdenv
    , fetchurl
    , which
    , python38
    , wget
    , file
    , cmake
    , libusb
    , autoPatchelfHook
    }:
    let
      version = "0.16.4";
      arch = "arm";
      # https://github.com/zephyrproject-rtos/sdk-ng/releases/download/v0.16.4/zephyr-sdk-0.16.4_linux-x86_64_minimal.tar.xz
      # https://github.com/zephyrproject-rtos/sdk-ng/releases/download/v0.16.4/zephyr-sdk-0.16.4_linux-x86_64_minimal.tar.gz
      sdk = fetchurl {
        url = "https://github.com/zephyrproject-rtos/sdk-ng/releases/download/v${version}/zephyr-sdk-${version}_linux-x86_64_minimal.tar.xz";
        hash = "sha256-PLnZfwj+ddUq/d09SOdJVaQhtkIUzL30nFrQ4NdTCy0=";
      };
      armToolchain = fetchurl {
        url = "https://github.com/zephyrproject-rtos/sdk-ng/releases/download/v${version}/toolchain_linux-x86_64_arm-zephyr-eabi.tar.xz";
        hash = "sha256-IGHlhTTFf5jxsFtVfZpdDhhzrDizEIQVYtNg+XFflvs=";
      };
      x86_64Toolchain = fetchurl {
        url = "https://github.com/zephyrproject-rtos/sdk-ng/releases/download/v${version}/toolchain_linux-x86_64_x86_64-zephyr-elf.tar.xz";
        hash = "sha256-+x/1/m7aUGTX2+wuozqnmXgdZBTjwTSAmo7fgSAk5xk=";
      };
    in
    stdenv.mkDerivation {
      name = "zephyr-sdk";
      inherit version;
      srcs = [ sdk armToolchain x86_64Toolchain ];
      srcRoot = ".";
      nativeBuildInputs = [
        which
        wget
        file
        python38
        autoPatchelfHook
        cmake
        libusb
      ];
      phases = [ "installPhase" "fixupPhase" ];
      installPhase = ''
        runHook preInstall
        echo out=$out
        mkdir -p $out
        set $srcs
        tar -xf $1 -C $out --strip-components=1
        tar -xf $2 -C $out
        tar -xf $3 -C $out
        (cd $out; bash ./setup.sh -h)
        rm $out/zephyr-sdk-x86_64-hosttools-standalone-0.9.sh
        runHook postInstall
      '';
    };
  zephyr-sdk = pkgs.callPackage new-zephyr-sdk-pkg { };

  packages = with pkgs; [
    # Tools for building the languages we are using
    llvmPackages_16.clang-unwrapped # Newer than base clang, includes clang-format options Zephyr uses
    gcc_multi
    glibc_multi

    # Dependencies of the Zephyr build system.
    (python-packages)
    cmake
    ninja
    gperf
    python3
    ccache
    dtc
    gmp.dev

    zephyr-sdk
  ];
in
pkgs.mkShell {
  nativeBuildInputs = [ packages ];

  # For Zephyr work, we need to initialize some environment variables,
  # and then invoke the zephyr setup script.
  shellHook = ''
    export ZEPHYR_SDK_INSTALL_DIR=${zephyr-sdk}
    export PATH=$PATH:${zephyr-sdk}/arm-zephyr-eabi/bin
    unset CFLAGS
    unset LDFLAGS
    python3 -m venv ./venv/.venv
    source ./zephyr/zephyr-env.sh
  '';
}
