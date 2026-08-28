{
  description = "Development shell and tests for case.hx";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs =
    { self, nixpkgs }:
    let
      systems = [
        "aarch64-darwin"
        "aarch64-linux"
        "x86_64-darwin"
        "x86_64-linux"
      ];
      forAllSystems = f: nixpkgs.lib.genAttrs systems (system: f nixpkgs.legacyPackages.${system});
    in
    {
      devShells = forAllSystems (pkgs: {
        default = pkgs.mkShellNoCC { packages = [ pkgs.steel ]; };
      });

      checks = forAllSystems (pkgs: {
        default = self.checks.${pkgs.system}.test;

        # test.scm always exits 0, so the "ok" it prints is what decides the check.
        test = pkgs.runCommand "case-hx-test" { nativeBuildInputs = [ pkgs.steel ]; } ''
          export STEEL_HOME=$TMPDIR/steel
          cd ${self}
          steel test.scm | tee $out
          grep -qx ok $out
        '';
      });

      formatter = forAllSystems (pkgs: pkgs.nixfmt-tree);
    };
}
