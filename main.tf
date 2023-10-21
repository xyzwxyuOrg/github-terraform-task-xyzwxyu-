terraform {
  required_providers {
    github = {
      source  = "integrations/github"
      version = "~> 5.0"
    }
  }
}

provider "github" {
  token    = "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"
  owner    = "xyzwxyuOrg"
  #base_url = "https://github.com/xyzwxyuOrg/"
}

resource "github_repository" "rep" {
  name       = "github-terraform-task-xyzwxyu"
  visibility = "public"
  auto_init  = true
}

resource "github_branch" "rep_branch_main" {
  repository = github_repository.rep.name
  branch     = "main"
}

resource "github_branch" "rep_branch_develop" {
  repository = github_repository.rep.name
  branch     = "develop"
}

resource "github_branch_default" "rep_branch_default" {
  repository = github_repository.rep.name
  branch     = github_branch.rep_branch_develop.branch
}

resource "github_repository_collaborator" "rep_collaborator_xyzwxyu" {
  repository = github_repository.rep.name
  username   = "softservedata"
  permission = "admin"
}


resource "github_branch_protection" "rep_protection_main" {
  repository_id  = github_repository.rep.name
  pattern        = github_branch.rep_branch_main.branch

  required_pull_request_reviews {
    dismiss_stale_reviews       = true
    required_approving_review_count = 0
    require_code_owner_reviews  = true
}
}

resource "github_branch_protection" "rep_protection_develop" {
  repository_id  = github_repository.rep.name
  pattern        = github_branch.rep_branch_develop.branch
  enforce_admins = true

  required_pull_request_reviews {
    required_approving_review_count = 2
  }
}

resource "github_actions_secret" "rep_secret" {
  repository       = github_repository.rep.name
  secret_name      = "PAT"
  plaintext_value  = "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"
}

resource "github_repository_deploy_key" "rep_deploy_key" {
  title      = "DEPLOY_KEY"
  repository = github_repository.rep.name
  key        = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDKyn8NPYW+r+dBvFSUlUvqD4KNfwj2ThTHw7QG3J1eWCB7R6JD4ZSZRF6BzO2T3UHgwwlx8AeZR9cmejkrREZd4qcesVV+siVNNNQtn8vPhWyb89H/4r1IscNCObuTnI2mCpzUGcKqavF559XIPwNafFTCGYej2G9p7P843BfFWxK3WWUji8at0lXy5ieyB4/JMqPz4YNUf2+8fndhk5DwQ6Hceo5+ezR1Wy60Y3xK+HzWudL3gNy/DOra7QaZ2DxJz9UyvV0mm1b9X/YdfXEz1+9c2vHC5n7dMMthpdr97orjVh5CvqjFXaJWYH9FxGRx0DEkrFSsjh5iSt/rTkm+TQBuDQVJ+m/VPOOMQo3/Coi3pFjsRDBS61S3rJLG50z2Ex03gZA3nowp08evutU4HYnmEYgjYAeVYId3uv9pBsiachOk9bdPvsjkI/HfNGoabvq2f8mAKPD/K/LkKNOMymuAoixtXLXugnL6cmHqaBzEcUWmn3bCuzvMXIv8rHc= fubar@test"
  read_only  = "false"
}

resource "github_repository_file" "rep_pr_template" {
  repository          = github_repository.rep.name
  branch              = github_branch_default.rep_branch_default.branch
  file                = ".github/pull_request_template.md"
  content             = file(".github/pull_request_template.md")
  overwrite_on_create = true
}

resource "github_repository_file" "rep_codeowners" {
  repository          = github_repository.rep.name
  branch              = github_branch_default.rep_branch_default.branch
  file                = ".github/CODEOWNERS"
  content             = file(".github/CODEOWNERS")
  overwrite_on_create = true
}

resource "github_repository_webhook" "foo" {
  repository = github_repository.rep.name

  configuration {
    url          = "https://discord.com/api/webhooks/1160190431909400616/MnwwzXi4igTy9U5BLvWC4BwDnQyszLKy4QWhIKj42wDm4otIMVJ--rMP8iVCKpdRsgYk"
    content_type = "form"
    insecure_ssl = false
  }

  active = false

  events = ["pull_request"]
}
