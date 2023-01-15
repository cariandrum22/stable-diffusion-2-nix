{
  description = "JupyterLab flake for Stable Diffusion 2";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
          config = {
            allowUnfree = true;
            cudaSupport = true;
          };
        };

        python = pkgs.python310;

        accelerate = ps: ps.callPackage ./packages/accelerate { };
        diffusers = ps: ps.callPackage ./packages/diffusers {
          inherit accelerate;
        };
        safetensors = ps: ps.callPackage ./packages/safetensors { };
      in
      {
        packages.python = python;
        packages.default = (self.packages.${system}.python.withPackages (ps: with ps; [
          (accelerate ps)
          (diffusers ps)
          (safetensors ps)
          transformers
          scipy
          ftfy
          ipywidgets
          jupyterlab
          jupyterlab-widgets
          jupyterlab-pygments
        ])).override (args: { ignoreCollisions = true; });

        apps.default = {
          type = "app";
          program = "${self.packages.${system}.default}/bin/jupyter-lab";
        };
      }
    );
}
