{
  outputs =
    {
      self,
      nixpkgs,
      ...
    }@inputs:
    {
      nixops4Deployments = import ./nixops { inherit inputs nixpkgs; };
    };
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    stable.url = "github:NixOS/nixpkgs/nixos-24.05";
    #nixops4.url = "github:nixops4/nixops4/prototype-terraform-nixcon";
    #nixops4.url = "github:jappie3/nixops4/prototype-terraform-nixcon";
    nixops4.url = "github:jappie3/nixops4/import-state";
    nixops4-nixos.url = "github:nixops4/nixops4-nixos";
  };
}
