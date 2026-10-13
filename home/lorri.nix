{ lib, pkgs, lorri, ... }:

let
  daemonEnvironment = {
    PATH = lib.makeBinPath [ pkgs.nix pkgs.gitMinimal pkgs.gnutar pkgs.gzip ];
    NIX_SSL_CERT_FILE = "${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt";
  };
in {
  home.packages = [ lorri ];

  # The pinned native-hook implementation binds its own socket. The standard
  # services.lorri module expects the older socket-activated implementation.
  systemd.user.services.lorri = lib.mkIf pkgs.stdenv.hostPlatform.isLinux {
    Unit.Description = "lorri development environment daemon";
    Service = {
      ExecStart = "${lorri}/bin/lorri daemon";
      Environment = lib.mapAttrsToList (name: value: "${name}=${value}") daemonEnvironment;
      Restart = "on-failure";
      RestartSec = 5;
    };
    Install.WantedBy = [ "default.target" ];
  };

  launchd.agents.lorri = lib.mkIf pkgs.stdenv.hostPlatform.isDarwin {
    enable = true;
    config = {
      ProgramArguments = [ "${lorri}/bin/lorri" "daemon" ];
      EnvironmentVariables = daemonEnvironment;
      RunAtLoad = true;
      KeepAlive = true;
      ProcessType = "Background";
    };
  };
}
