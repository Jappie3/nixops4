{ inputs, nixpkgs, ... }:
{
  default = inputs.nixops4.lib.mkDeployment {
    modules = [
      (
        {
          lib,
          providers,
          resources,
          resourceProviderSystem,
          ...
        }:
        {
          providers = {
            inherit (inputs.nixops4.modules.nixops4Provider) local;
            terraform-hcloud = inputs.nixops4.lib.tfProviderToModule {
              tfProvider = nixpkgs.legacyPackages.${resourceProviderSystem}.terraform-providers.hcloud;
            };
          };
          resources = {
            deployment_state = {
              type = providers.local.state_file;
              inputs.name = "nixops4-state.json";
            };

            kainas_key = {
              type = providers.terraform-hcloud.hcloud_ssh_key;
              state = [ "deployment_state" ];
              inputs = {
                #id = "102959539102959539";
                name = "jasper@Kainas";
                public_key = "sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAIDWbDBrUe/wJchfeDajmozOIDKrBN2pftsPqGlAFdnrEAAAABHNzaDo= jasper@Kainas";
              };
            };

            testvm = {
              type = providers.terraform-hcloud.hcloud_server;
              state = [ "deployment_state" ];
              inputs = {
                #id = "110202126";
                name = "aoeu";
                image = "debian-11";
                server_type = "cx22";
                ssh_keys = [ resources.kainas_key.id ];
                user_data = ''
                  #cloud-config
                  runcmd:
                    - curl https://raw.githubusercontent.com/elitak/nixos-infect/master/nixos-infect | PROVIDER=hetznercloud NIX_CHANNEL=nixos-25.05 bash 2>&1 | tee /tmp/infect.log
                '';
                public_net = [
                  {
                    ipv4_enabled = false;
                    ipv4 = 0;
                    ipv6_enabled = true;
                    ipv6 = 0;
                  }
                ];
              };
            };

            #testvm_nixos = {
            #  type = providers.local.exec;
            #  imports = [
            #    inputs.nixops4-nixos.modules.nixops4Resource.nixos
            #  ];

            #  inherit (inputs) nixpkgs;

            #  ssh = {
            #    #opts = "-o Port=22";
            #    host = resources.testvm.ipv6_address;
            #    hostPublicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAiszi43aOWWV7voNgQ1Ifa7LGKwGJfOuiLM1n42h2Y8";
            #  };

            #  nixos.module =
            #    { pkgs, modulesPath, ... }:
            #    {
            #      imports = [
            #        (modulesPath + "/profiles/qemu-guest.nix")
            #        (modulesPath + "/../lib/testing/nixos-test-base.nix")
            #        {
            #          # See test/default/nixosTest.nix
            #          system.switch.enable = true;
            #          # Not used; save a large copy operation
            #          nix.channel.enable = false;
            #          nix.registry = lib.mkForce { };
            #        }
            #      ];

            #      nixpkgs.hostPlatform = "x86_64-linux";

            #      services.openssh.enable = true;
            #      services.openssh.settings.PermitRootLogin = "yes";
            #      networking.firewall.allowedTCPPorts = [ 22 ];
            #      users.users.root = {
            #        openssh.authorizedKeys.keyFiles = [
            #          pkgs.writeText
            #          "keys"
            #          ''
            #            sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAIDWbDBrUe/wJchfeDajmozOIDKrBN2pftsPqGlAFdnrEAAAABHNzaDo= jasper@Kainas
            #          ''
            #        ];
            #        initialHashedPassword = "!";
            #      };

            #      security.sudo.execWheelOnly = true; # hardening
            #      security.sudo.wheelNeedsPassword = false; # can not be entered through NixOps

            #      environment.etc."greeting".text = resources.hello.outputs.stdout;
            #      environment.systemPackages = [
            #        pkgs.hello
            #      ];
            #    };
            #};
          };
        }
      )
    ];
  };
}
