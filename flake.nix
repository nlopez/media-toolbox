{
  description = "media-toolbox: container image with audio/video/CLI tools for media processing";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs =
    { self, nixpkgs }:
    let
      # Pinned third-party releases; bumped by scripts/update-versions.sh (CI runs it daily).
      versions = builtins.fromJSON (builtins.readFile ./nix/versions.json);

      systems = [
        "x86_64-linux"
        "aarch64-linux"
      ];
      forAllSystems = nixpkgs.lib.genAttrs systems;

      mkImage =
        {
          system,
          uid ? 1001,
          gid ? 1001,
        }:
        let
          pkgs = import nixpkgs {
            inherit system;
            # fzf-obc is the only unfree package we pull in.
            config.allowUnfreePredicate = pkg: nixpkgs.lib.getName pkg == "fzf-obc";
          };

          # nixpkgs' yt-dlp, rebuilt from the pinned upstream release tag so we track
          # upstream releases rather than nixpkgs' update cadence.
          ytDlp =
            (pkgs.yt-dlp.override { ffmpeg-headless = pkgs.ffmpeg; }).overrideAttrs
              (_: {
                version = versions.ytDlp.version;
                src = pkgs.fetchFromGitHub {
                  owner = "yt-dlp";
                  repo = "yt-dlp";
                  tag = versions.ytDlp.version;
                  hash = versions.ytDlp.hash;
                };
              });

          tubeup = pkgs.callPackage ./nix/tubeup.nix { yt-dlp = ytDlp; };

          # bgutil PO token provider plugin (must match the ytpot server version).
          bgutilPlugin = pkgs.fetchurl {
            url = "https://github.com/Brainicism/bgutil-ytdlp-pot-provider/releases/download/${versions.bgutil.version}/bgutil-ytdlp-pot-provider.zip";
            hash = versions.bgutil.hash;
          };

          # Only en_US.UTF-8; the default glibcLocales ships every locale (~220 MiB).
          locales = pkgs.glibcLocales.override {
            allLocales = false;
            locales = [ "en_US.UTF-8/UTF-8" ];
          };

          tools = with pkgs; [
            # core userland (what ubuntu:24.04 shipped implicitly)
            bashInteractive
            bash-completion
            coreutils
            findutils
            gawk
            gnugrep
            gnused
            gnutar
            gzip
            bzip2
            xz
            diffutils
            procps
            util-linux
            which
            file
            less
            unzip

            # media
            aria2
            atomicparsley
            ffmpeg
            kid3-cli
            mediainfo
            mktorrent
            mkvtoolnix-cli
            optipng
            pngquant

            # network / transfer
            dnsutils
            curl
            rclone
            rsync
            wget

            # shell / monitoring
            bc
            bwm_ng
            fd
            fzf
            htop
            iotop
            jq
            ncdu
            ripgrep
            screen
            tmux
            vim

            # dev
            gitMinimal
            deno
            nodejs_22
            python3
            uv
            yarn

            # downloaders
            ytDlp
            tubeup
            streamlink
            twspace-crawler
          ];

          rootEnv = pkgs.buildEnv {
            name = "media-toolbox-root";
            paths = tools;
            pathsToLink = [
              "/bin"
              "/share"
            ];
          };

          # /etc/passwd and /etc/group for the non-root user. Kept in a separate derivation
          # (alongside the CA bundle) so /etc is a real directory in the image.
          etcFiles = pkgs.runCommand "etc-files" { } ''
            mkdir -p $out/etc
            cat > $out/etc/passwd <<EOF
            root:x:0:0:root:/root:/bin/bash
            user:x:${toString uid}:${toString gid}:user:/home/user:/bin/bash
            EOF
            cat > $out/etc/group <<EOF
            root:x:0:
            user:x:${toString gid}:
            EOF
          '';

          bashrc = pkgs.runCommand "bashrc" { } ''
            cat ${./rootfs/home/user/.bashrc} > $out
            cat >> $out <<'EOF'

            # fzf key bindings + fzf-obc (fzf over bash completions)
            source ${pkgs.fzf}/share/fzf/key-bindings.bash
            source ${pkgs.fzf-obc}/share/fzf-obc/bin/fzf-obc.bash
            EOF
          '';
        in
        pkgs.dockerTools.streamLayeredImage {
          name = "nlopez/media-toolbox";
          tag = versions.ytDlp.version;
          created = "now";
          maxLayers = 120;

          contents = [
            rootEnv
            etcFiles
            pkgs.dockerTools.usrBinEnv
            pkgs.dockerTools.caCertificates
          ];

          fakeRootCommands = ''
            mkdir -p tmp var/tmp home/user/.config/yt-dlp/plugins home/user/.local/bin
            chmod 1777 tmp var/tmp
            cp ${bashrc} home/user/.bashrc
            cp ${bgutilPlugin} home/user/.config/yt-dlp/plugins/bgutil-ytdlp-pot-provider.zip
            chmod 644 home/user/.bashrc home/user/.config/yt-dlp/plugins/bgutil-ytdlp-pot-provider.zip
            chown -R ${toString uid}:${toString gid} home/user
          '';

          config = {
            User = "user";
            WorkingDir = "/home/user";
            Entrypoint = [ "/bin/bash" ];
            Cmd = [
              "-c"
              "trap : TERM INT; sleep infinity & wait"
            ];
            Env = [
              "HOME=/home/user"
              "USER=user"
              "SHELL=/bin/bash"
              "PATH=/home/user/.local/bin:/bin"
              "LANG=en_US.UTF-8"
              "LC_ALL=en_US.UTF-8"
              "LOCALE_ARCHIVE=${locales}/lib/locale/locale-archive"
              "SSL_CERT_FILE=/etc/ssl/certs/ca-bundle.crt"
              # bash-completion looks for completions under $XDG_DATA_DIRS/bash-completion
              "XDG_DATA_DIRS=/share"
              # nixpkgs' screen defaults to /run/screen, which a non-root user can't create
              "SCREENDIR=/home/user/.screen"
            ];
            Labels = {
              "org.opencontainers.image.description" = "Media Toolbox: A container development environment with audio/video/CLI tools for media processing.";
            };
          };
        };
    in
    {
      lib = { inherit mkImage; };

      packages = forAllSystems (system: {
        image = mkImage { inherit system; };
        default = self.packages.${system}.image;
      });
    };
}
