param(
    [string]$terraformCloudOrganization,
    [string]$terraformCloudProject,
    [string]$terraformCloudUrl,
    [string]$terraformCloudAccessToken,
    [string]$subscriptionData
)

Write-Host "terraformCloudOrganization: $terraformCloudOrganization"
Write-Host "terraformCloudProject: $terraformCloudProject"
Write-Host "terraformCloudUrl: $terraformCloudUrl"
Write-Host "terraformCloudAccessToken: $terraformCloudAccessToken"
Write-Host "subscriptionData: $subscriptionData"

$subscriptionData | Out-File -FilePath ./terraform.tfvars.json

tar -cvzf config.tar.gz ./*.tf ./terraform.tfvars.json

$subscriptionVariables = ConvertFrom-Json $subscriptionData

$subscriptionBusinessUnit = $subscriptionVariables.subscription_business_unit
$subscriptionPurpose = $subscriptionVariables.subscription_purpose
$subscriptionNumber = $subscriptionVariables.subscription_number

$subscriptionNumberPadded = '{0:d3}' -f [int]$subscriptionNumber
$workspaceName = "$subscriptionBusinessUnit-$subscriptionPurpose-$subscriptionNumberPadded"

$headers=@{
  "Authorization" = "Bearer $terraformCloudAccessToken"
}

$terraformCloudUrlPrefix = "https://$($terraformCloudUrl)/api/v2"

Write-Host "Checking if workspace $workspaceName exists."
$uri = "$terraformCloudUrlPrefix/organizations/$($terraformCloudOrganization)/workspaces/$($workspaceName)"
$workspace = Invoke-RestMethod -Uri $uri -Headers $headers -Method Get -SkipHttpErrorCheck -StatusCodeVariable "statusCode"

if($statusCode -eq "404")
{
    Write-Host "Workspace $workspaceName does not exist. Creating it now."

    $uri = "$terraformCloudUrlPrefix/organizations/$($terraformCloudOrganization)/projects?filter[names]=$($terraformCloudProject)"
    $project = Invoke-RestMethod -Uri $uri -Headers $headers -Method Get
    $projectId = $project.data.id

    $uri = "$terraformCloudUrlPrefix/organizations/$($terraformCloudOrganization)/workspaces"
    $body = @{
        "data" = @{
            "type" = "workspaces";
            "attributes" = @{
                "name" = $workspaceName;
                "auto-apply" = $true;
                "file-triggers-enabled" = $false;
                "operations" = @{
                    "destroy" = $true;
                }
            }
            "relationships" = @{
                "project" = @{
                    "data" = @{
                        "type" = "projects"
                        "id" = $projectId
                    }
                }
            }
        }
    }
    $bodyJson = ConvertTo-Json $body -Depth 10
    $workspace = Invoke-RestMethod -Uri $uri -Headers $headers -Method Post -ContentType "application/vnd.api+json" -Body $bodyJson
    $workspaceId = $workspace.data.id
}
else
{
    Write-Host "Workspace $workspaceName already exists."
    $workspaceId = $workspace.data.id
}

Write-Host "Creating workspace configuration version for $workspaceName ($workspaceId)."
$uri = "$terraformCloudUrlPrefix/workspaces/$($workspaceId)/configuration-versions"
$body = @{
    "data" = @{
        "type" = "configuration-versions";
        "attributes" = @{
            "auto-queue-runs" = $true
        }
    }
}
$bodyJson = ConvertTo-Json $body -Depth 10
$configurationVersion = Invoke-RestMethod -Uri $uri  -Headers $headers -Method Post -ContentType "application/vnd.api+json" -Body $bodyJson
$uploadUrl = $configurationVersion.data.attributes."upload-url"

Invoke-RestMethod -Uri $uploadUrl -Headers $headers -Method Put -ContentType "application/octet-stream" -InFile ./config.tar.gz
