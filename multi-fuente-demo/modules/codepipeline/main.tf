# NOTA: este módulo está simplificado para el laboratorio.
# Los roles usan AdministratorAccess por brevedad — en un proyecto
# real, reemplázalos por políticas acotadas al mínimo privilegio.

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

resource "aws_codebuild_project" "this" {
  name         = "${var.pipeline_name}-build"
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
  }

  source {
    type      = "CODEPIPELINE"
    buildspec = var.buildspec_path
  }
}

# Proyecto separado para el stage Apply: el de arriba solo corre
# "terraform plan", este corre "terraform apply tfplan". La fuente
# primaria es el repo completo (source_output, necesario porque los
# .tf de cada servicio referencian ../../../modules/*), y build_output
# (el tfplan generado en el Build stage) entra como fuente secundaria.
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

  # El filtro de ruta vive aquí: este pipeline solo se dispara
  # cuando el push toca archivos dentro de var.path_filter.
  trigger {
    provider_type = "CodeStarSourceConnection"

    git_configuration {
      source_action_name = "Source"

      push {
        branches {
          includes = [var.branch]
        }
        file_paths {
          includes = [var.path_filter]
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
        ProjectName = aws_codebuild_project.this.name
      }
    }
  }

  # Aprobación manual solo en prod. En dev el pipeline pasa directo
  # de Build a Apply (auto-apply), para no tener que aprobar a mano
  # cada servicio en el ambiente de práctica.
  dynamic "stage" {
    for_each = var.require_approval ? [1] : []

    content {
      name = "Approval"

      action {
        name     = "ManualApproval"
        category = "Approval"
        owner    = "AWS"
        provider = "Manual"
        version  = "1"
      }
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
      }
    }
  }
}
