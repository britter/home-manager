{
  config = {
    programs.tmux = {
      enable = true;
      tmuxinator = {
        enable = true;
        projects = {
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
        };
      };
    };

    nmt.script = ''
      assertFileExists home-files/.config/tmuxinator/myproject.yaml
      assertFileContent home-files/.config/tmuxinator/myproject.yaml ${./tmuxinator-projects.yaml}
    '';
  };
}
