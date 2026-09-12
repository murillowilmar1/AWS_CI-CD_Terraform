# Pipeline único y manual para promover UNA fuente a la vez a prod.
# No se dispara con push (branches/file_paths del trigger apuntan a
# una ruta que nunca existe, a propósito) — alguien lo arranca a mano
# (consola o `aws codepipeline start-pipeline-execution --variables`)
# indicando FUENTE=postgres|sqlserver, y solo esa carpeta se planea/aplica.

resource "aws_iam_role" "codebuild" {
  name = "${var.pipeline_name}-codebuild-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = { Service = "codebuild.amazonaws.com" }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "codebuild_admin" {
  role       = aws_iam_role.codebuild.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}

resource "aws_codebuild_project" "plan" {
  name         = "${var.pipeline_name}-plan"
  service_role = aws_iam_role.codebuild.arn

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    compute_type = "BUILD_GENERAL1_SMALL"
    image        = "aws/codebuild/amazonlinux2-x86_64-standard:5.0"
    type         = "LINUX_CONTAINER"

    environment_variable {
      name  = "ENVIRONMENT"
      value = var.environment
    }
    environment_variable {
      name  = "TFSTATE_BUCKET"
      value = var.tfstate_bucket
    }
    environment_variable {
      name  = "TFSTATE_REGION"
      value = var.tfstate_region
    }
    # FUENTE no tiene valor fijo acá: se sobreescribe por ejecución
    # desde la action del pipeline (ver EnvironmentVariables abajo).
    environment_variable {
      name  = "FUENTE"
      value = var.default_fuente
    }
  }

  source {
    type      = "CODEPIPELINE"
    buildspec = var.plan_buildspec_path
  }
}

resource "aws_codebuild_project" "apply" {
  name         = "${var.pipeline_name}-apply"
  service_role = aws_iam_role.codebuild.arn

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    compute_type = "BUILD_GENERAL1_SMALL"
    image        = "aws/codebuild/amazonlinux2-x86_64-standard:5.0"
    type         = "LINUX_CONTAINER"

    environment_variable {
      name  = "ENVIRONMENT"
      value = var.environment
    }
    environment_variable {
      name  = "TFSTATE_BUCKET"
      value = var.tfstate_bucket
    }
    environment_variable {
      name  = "TFSTATE_REGION"
      value = var.tfstate_region
    }
    environment_variable {
      name  = "FUENTE"
      value = var.default_fuente
    }
  }

  source {
    type      = "CODEPIPELINE"
    buildspec = var.apply_buildspec_path
  }
}

resource "aws_iam_role" "codepipeline" {
  name = "${var.pipeline_name}-codepipeline-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = { Service = "codepipeline.amazonaws.com" }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "codepipeline_admin" {
  role       = aws_iam_role.codepipeline.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}

resource "aws_codepipeline" "this" {
  name          = var.pipeline_name
  role_arn      = aws_iam_role.codepipeline.arn
  pipeline_type = "V2"

  artifact_store {
    location = var.artifact_bucket
    type     = "S3"
  }

  # Variable que el pipeline pide al arrancar (consola: "Release
  # change" / "Start" muestra un formulario; CLI: --variables).
  variable {
    name          = "FUENTE"
    default_value = var.default_fuente
    description   = "Qué fuente promover: postgres | sqlserver"
  }

  # Trigger apuntando a una ruta que nunca va a matchear un push real
  # -> el pipeline NUNCA se dispara solo, solo por start manual.
  trigger {
    provider_type = "CodeStarSourceConnection"

    git_configuration {
      source_action_name = "Source"

      push {
        branches {
          includes = [var.branch]
        }
        file_paths {
          includes = ["_nunca_disparar_automaticamente/**"]
        }
      }
    }
  }

  stage {
    name = "Source"

    action {
      name             = "Source"
      category         = "Source"
      owner            = "AWS"
      provider         = "CodeStarSourceConnection"
      version          = "1"
      output_artifacts = ["source_output"]

      configuration = {
        ConnectionArn    = var.repo_connection_arn
        FullRepositoryId = var.repo_full_name
        BranchName       = var.branch
      }
    }
  }

  stage {
    name = "Build"

    action {
      name             = "BuildAndPlan"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      version          = "1"
      input_artifacts  = ["source_output"]
      output_artifacts = ["build_output"]

      configuration = {
        ProjectName = aws_codebuild_project.plan.name
        EnvironmentVariables = jsonencode([
          { name = "FUENTE", value = "#{variables.FUENTE}", type = "PLAINTEXT" }
        ])
      }
    }
  }

  stage {
    name = "Approval"

    action {
      name     = "ManualApproval"
      category = "Approval"
      owner    = "AWS"
      provider = "Manual"
      version  = "1"
    }
  }

  stage {
    name = "Apply"

    action {
      name            = "TerraformApply"
      category        = "Build"
      owner           = "AWS"
      provider        = "CodeBuild"
      version         = "1"
      input_artifacts = ["source_output", "build_output"]

      configuration = {
        ProjectName   = aws_codebuild_project.apply.name
        PrimarySource = "source_output"
        EnvironmentVariables = jsonencode([
          { name = "FUENTE", value = "#{variables.FUENTE}", type = "PLAINTEXT" }
        ])
      }
    }
  }
}
