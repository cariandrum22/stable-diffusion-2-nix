{ lib
, buildPythonPackage
, fetchFromGitHub
, black
, click
, flake8
, flax
, h5py
, huggingface-hub
, isort
, jax
, numpy
, rustPlatform
, setuptools-rust
, pytest
, pytest-benchmark
, tensorflow
, torch
}:
buildPythonPackage rec {
  pname = "safetensors";
  version = "0.2.7";

  src = fetchFromGitHub {
    owner = "huggingface";
    repo = pname;
    rev = "refs/tags/v${version}";
    sha256 = "sha256-a+IEjgtsSCQ9ZlqPNQrMmSbsyzHp8KxK2pkxe7rrb+U=";
  };

  sourceRoot = "source/bindings/python";

  cargoDeps = rustPlatform.importCargoLock {
    lockFile = ./Cargo.lock;
  };

  postPatch = ''
    cp ${./Cargo.lock} Cargo.lock
  '';

  nativeBuildInputs = [ setuptools-rust ] ++ (with rustPlatform; [
    cargoSetupHook
    rust.cargo
    rust.rustc
  ]);

  passthru.optional-dependencies = rec {
    quality = [
      black
      isort
      flake8
      click
    ];
    testing = [
      setuptools-rust
      huggingface-hub
      pytest
      pytest-benchmark
      h5py
      numpy
    ];
    all = [
      torch
      numpy
      tensorflow
      jax
    ] ++ quality ++ testing;
    dev = all;
  };

  doCheck = false;

  pythonImportsCheck = [ "safetensors" ];

  meta = with lib; {
    homepage = "https://github.com/huggingface/safetensors";
    changelog = "https://github.com/huggingface/safetensors/releases/tag/v${version}";
    license = licenses.asl20;
    platforms = platforms.unix;
    maintainers = with maintainers; [ cariandrum22 ];
  };
}
