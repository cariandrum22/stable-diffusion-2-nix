{ lib
, buildPythonPackage
, fetchFromGitHub
, black
, datasets
, flake8
, isort
, numpy
, packaging
, parameterized
, psutil
, pytest
, pytest-subtests
, pytest-xdist
, pyyaml
, rich
, sagemaker
, scipy
, scikit-learn
, tensorboard
, pytorch
, tqdm
, transformers
, wandb
}:
buildPythonPackage rec {
  pname = "accelerate";
  version = "0.15.0";
  src = fetchFromGitHub {
    owner = "huggingface";
    repo = pname;
    rev = "refs/tags/v${version}";
    sha256 = "sha256-agfbOaa+Nm10HZkd2Y7zR3R37n+vLNsxCyxZax6O3Lo=";
  };

  propagatedBuildInputs = [
    numpy
    packaging
    psutil
    pyyaml
    pytorch
  ];

  passthru.optional-dependencies = rec {
    quality = [
      black
      isort
      flake8
    ];
    test_prod = [
      pytest
      pytest-xdist
      pytest-subtests
      parameterized
    ];
    test_dev = [
      datasets
      # evaluate
      transformers
      scipy
      scikit-learn
      # deepspeed
      tqdm
    ];
    testing = test_prod ++ test_dev;
  };

  doCheck = false;

  pythonImportsCheck = [ "accelerate" ];

  meta = with lib; {
    homepage = "https://github.com/huggingface/accelerate";
    changelog = "https://github.com/huggingface/accelerate/releases/tag/v${version}";
    license = licenses.asl20;
    platforms = platforms.unix;
    maintainers = with maintainers; [ collinarnett ];
  };
}
