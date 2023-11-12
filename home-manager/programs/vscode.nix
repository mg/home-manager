{ pkgs, config, ...}:
{
  programs.vscode = {
      enable = true;
      extensions = with pkgs.vscode-extensions; [
        # flutter support
        dart-code.dart-code
        dart-code.flutter

        # javascript support
        esbenp.prettier-vscode

        # nix support
        jnoortheen.nix-ide
        kamadorueda.alejandra
        arrterian.nix-env-selector
        mkhl.direnv
        # missing: https://marketplace.visualstudio.com/items?itemName=pinage404.nix-extension-pack

        # python support
        ms-toolsai.jupyter
        ms-python.python
        ms-python.vscode-pylance
      ];      
  };
}