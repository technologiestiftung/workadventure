terraform {
  backend "remote" {
    organization = "technologiestiftung"
    workspaces {
      name = "workspaceadventures-dev-v1"
    }
  }
}
