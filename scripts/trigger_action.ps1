param(
    [string]$access_token,
    [string]$owner,
    [string]$repository,
    [string]$subscriptionData
)

$owner = "jared-holgate-microsoft-demos"
$repository = "terraform-jaredfholgate-azure-subscription-vending-demo"  
$access_token = "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"
$subscriptionData = @"
{
    "subscription_business_unit": "it",
    "subscription_purpose": "sandbox",
    "subscription_number": 3,
    "location": "uksouth",
    "subscription_offer": "DevTest",
    "subscription_description": "A sandbox subscription for IT to use for testing.",
    "subscription_management_group": "Subscription Vending Demo",
    "billing_account_name": "7690848",
    "billing_enrollment_name": "340368",
    "create_service_principal": true,
    "create_repository": true,
    "create_terraform_cloud_workspace": true,
    "subscription_owners": [
        "jaredholgate_microsoft.com#EXT#"
    ]
}
"@

$headers=@{
  "Authorization" = "Bearer $access_token"
  "X-GitHub-Api-Version" = "2022-11-28"
}

$subscriptionVariables = ConvertFrom-Json $subscriptionData

$url = "https://api.github.com/repos/$owner/$repository/dispatches"
$body=@{
  "event_type" = "vend_subscription"
  "client_payload" = @{
    "subscriptionData" = $subscriptionVariables
  }
}
$bodyJson = ConvertTo-Json $body -Depth 10

$result = Invoke-RestMethod -Method "POST" -Uri $url -Body $bodyJson -Headers $headers -ContentType "application/vnd.github+json"

