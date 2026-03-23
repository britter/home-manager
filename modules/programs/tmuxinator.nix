{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.programs.tmux;

  yamlFormat = pkgs.formats.yaml { };

  projectsType = lib.types.submodule (
    { name, ... }:
    {
      freeformType = yamlFormat.type;
      options = {
        name = lib.mkOption {
          type = lib.types.str;
          default = name;
          description = "The project name, used as the YAML file name.";
        };
      };
    }
  );
in
{
  options.programs.tmux.tmuxinator = {
    enable = lib.mkEnableOption "tmuxinator";

    package = lib.mkPackageOption pkgs "tmuxinator" { };

    projects = lib.mkOption {
      type = lib.types.attrsOf projectsType;
      default = { };
      description = ''
        Tmuxinator projects to write to
        {file}`$HOME/.config/tmuxinator`. See
        <https://github.com/tmuxinator/tmuxinator> for the project
        configuration format.
      '';
      example = lib.literalExpression ''
        {
          myproject = {
            root = "~/code/myproject";
            windows = [
              {
                editor = {
                  layout = "main-vertical";
                  panes = [
                    { editor = [ "vim" ]; }
                    "guard"
                  ];
                };
              }
              { server = "bundle exec rails s"; }
              { logs = "tail -f log/development.log"; }
            ];
          };
        }
      '';
    };
  };

  config = lib.mkIf (cfg.enable && cfg.tmuxinator.enable) {
    home.packages = [ cfg.tmuxinator.package ];

    xdg.configFile = lib.mapAttrs' (
      _k: v:
      lib.nameValuePair "tmuxinator/${v.name}.yaml" {
        source = yamlFormat.generate "${v.name}.yaml" v;
      }
    ) cfg.tmuxinator.projects;
  };
}
