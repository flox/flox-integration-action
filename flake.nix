{
  description = "Flox Integration Action";

  inputs.flake-utils.url = "github:numtide/flake-utils";

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        toApp = name: attrs: text:
          with pkgs; {
            type = "app";
            program = (pkgs.writeShellApplication ({ inherit name text; } // attrs)).outPath + "/bin/${name}";
          };
      in
      rec {

        apps.ci = toApp "update-built-cache" { runtimeInputs = [ pkgs.awscli2 ]; } ''

          # Try to pull current cache database from AWS
          aws s3 cp "s3://$FLOX_AWS_BUCKET/$FLOX_CACHE_DB_PATH" "./$FLOX_CACHE_DB_PATH" || true

          if [[ -e $FLOX_CACHE_DB_PATH ]]; then
            sudo chown runner "$FLOX_CACHE_DB_PATH"
            sudo chmod 664 "$FLOX_CACHE_DB_PATH"
          fi

          # Evaluate using eval app injected by capacitor
          nix run .#eval "$FLOX_FLAKE_REF"#"$FLOX_ATTR_PATH" | tee "$FLOX_EVAL_RESULT"

          # Check build chache for build result
          CHECK_CACHE_GLOBAL_ARGS=("--debug" "-u" "-d" "$FLOX_CACHE_DB_PATH")
          [[ -z "$FLOX_ALT_SUBSTITUTER" ]] || CHECK_CACHE_GLOBAL_ARGS+=("--substituter" "$FLOX_ALT_SUBSTITUTER")
          cat "$FLOX_EVAL_RESULT" | nix run .#checkCache -- "''${CHECK_CACHE_GLOBAL_ARGS[@]}" activate 

          # Push updated database to AWS
          aws s3 cp "./$FLOX_CACHE_DB_PATH" "s3://$FLOX_AWS_BUCKET/$FLOX_CACHE_DB_PATH"
          
          # Push updated evaluation cache
          aws s3 cp "./$FLOX_EVAL_RESULT" "s3://$FLOX_AWS_BUCKET/$FLOX_EVAL_RESULT"
        '';
      }
    );
}
