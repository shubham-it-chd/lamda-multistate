# Terraform Multistate Deployment Script
# This script helps deploy the multistate infrastructure in the correct order

param(
    [Parameter(Mandatory=$false)]
    [ValidateSet("init", "plan", "apply", "destroy", "all")]
    [string]$Action = "plan",
    
    [Parameter(Mandatory=$false)]
    [switch]$AutoApprove = $false
)

$ErrorActionPreference = "Stop"

Write-Host "🚀 Terraform Multistate Deployment Script" -ForegroundColor Green
Write-Host "Action: $Action" -ForegroundColor Yellow

# Define deployment order
$CommonComponents = @(
    "src/common/iam",
    "src/common/security-group"
)

$Workloads = @(
    "src/workloads/lambda/lambda-sample-one",
    "src/workloads/lambda/lambda-sample-two"
)

function Invoke-TerraformCommand {
    param(
        [string]$Path,
        [string]$Command,
        [bool]$AutoApprove = $false
    )
    
    Write-Host "`n📁 Working on: $Path" -ForegroundColor Cyan
    
    Push-Location $Path
    
    try {
        switch ($Command) {
            "init" {
                Write-Host "Initializing Terraform..." -ForegroundColor Blue
                terraform init
            }
            "plan" {
                Write-Host "Planning changes..." -ForegroundColor Blue
                terraform plan
            }
            "apply" {
                Write-Host "Applying changes..." -ForegroundColor Blue
                if ($AutoApprove) {
                    terraform apply -auto-approve
                } else {
                    terraform apply
                }
            }
            "destroy" {
                Write-Host "Destroying resources..." -ForegroundColor Red
                if ($AutoApprove) {
                    terraform destroy -auto-approve
                } else {
                    terraform destroy
                }
            }
        }
        
        if ($LASTEXITCODE -ne 0) {
            throw "Terraform command failed with exit code $LASTEXITCODE"
        }
        
        Write-Host "✅ Successfully completed $Command for $Path" -ForegroundColor Green
    }
    catch {
        Write-Host "❌ Failed to execute $Command for $Path" -ForegroundColor Red
        Write-Host $_.Exception.Message -ForegroundColor Red
        throw
    }
    finally {
        Pop-Location
    }
}

function Deploy-Components {
    param(
        [string[]]$Components,
        [string]$Command,
        [bool]$AutoApprove = $false
    )
    
    foreach ($component in $Components) {
        Invoke-TerraformCommand -Path $component -Command $Command -AutoApprove $AutoApprove
    }
}

# Check prerequisites
Write-Host "`n🔍 Checking prerequisites..." -ForegroundColor Yellow

# Check if Terraform is installed
try {
    $terraformVersion = terraform version
    Write-Host "✅ Terraform is installed: $($terraformVersion[0])" -ForegroundColor Green
}
catch {
    Write-Host "❌ Terraform is not installed or not in PATH" -ForegroundColor Red
    exit 1
}

# Check if AWS CLI is installed
try {
    $awsVersion = aws --version
    Write-Host "✅ AWS CLI is installed: $awsVersion" -ForegroundColor Green
}
catch {
    Write-Host "❌ AWS CLI is not installed or not in PATH" -ForegroundColor Red
    exit 1
}

# Main execution
try {
    switch ($Action) {
        "init" {
            Write-Host "`n🔧 Initializing all components..." -ForegroundColor Yellow
            Deploy-Components -Components $CommonComponents -Command "init"
            Deploy-Components -Components $Workloads -Command "init"
        }
        
        "plan" {
            Write-Host "`n📋 Planning all components..." -ForegroundColor Yellow
            Deploy-Components -Components $CommonComponents -Command "plan"
            Deploy-Components -Components $Workloads -Command "plan"
        }
        
        "apply" {
            Write-Host "`n🚀 Applying all components..." -ForegroundColor Yellow
            Write-Host "📌 Deploying common components first..." -ForegroundColor Cyan
            Deploy-Components -Components $CommonComponents -Command "apply" -AutoApprove $AutoApprove
            
            Write-Host "📌 Deploying workloads..." -ForegroundColor Cyan
            Deploy-Components -Components $Workloads -Command "apply" -AutoApprove $AutoApprove
        }
        
        "destroy" {
            Write-Host "`n💥 Destroying all components..." -ForegroundColor Red
            Write-Host "📌 Destroying workloads first..." -ForegroundColor Cyan
            $ReversedWorkloads = $Workloads | Sort-Object -Descending
            Deploy-Components -Components $ReversedWorkloads -Command "destroy" -AutoApprove $AutoApprove
            
            Write-Host "📌 Destroying common components..." -ForegroundColor Cyan
            $ReversedCommon = $CommonComponents | Sort-Object -Descending
            Deploy-Components -Components $ReversedCommon -Command "destroy" -AutoApprove $AutoApprove
        }
        
        "all" {
            Write-Host "`n🔄 Running complete deployment cycle..." -ForegroundColor Yellow
            Deploy-Components -Components $CommonComponents -Command "init"
            Deploy-Components -Components $Workloads -Command "init"
            Deploy-Components -Components $CommonComponents -Command "apply" -AutoApprove $AutoApprove
            Deploy-Components -Components $Workloads -Command "apply" -AutoApprove $AutoApprove
        }
    }
    
    Write-Host "`n🎉 All operations completed successfully!" -ForegroundColor Green
    
    if ($Action -eq "apply" -or $Action -eq "all") {
        Write-Host "`n📋 Deployment Summary:" -ForegroundColor Yellow
        Write-Host "• Common IAM resources deployed" -ForegroundColor Green
        Write-Host "• Common Security Group resources deployed" -ForegroundColor Green
        Write-Host "• Lambda Sample One deployed" -ForegroundColor Green
        Write-Host "• Lambda Sample Two deployed" -ForegroundColor Green
        
        Write-Host "`n🧪 Test your Lambda functions:" -ForegroundColor Cyan
        Write-Host "aws lambda invoke --function-name lambda-sample-one --payload '{\"test\": \"data\"}' response.json" -ForegroundColor Gray
        Write-Host "aws lambda invoke --function-name lambda-sample-two --payload '{\"eventType\": \"api_gateway\"}' response.json" -ForegroundColor Gray
    }
}
catch {
    Write-Host "`n💥 Deployment failed!" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
    exit 1
}

Write-Host "`n📚 For more information, see README.md" -ForegroundColor Blue
