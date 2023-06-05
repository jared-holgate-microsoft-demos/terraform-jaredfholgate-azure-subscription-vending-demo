param(
    [string]$access_token,
    [string]$owner,
    [string]$repository,
    [string]$event_type,
    [string]$subscription_id,
    [string]$subscription_name,
    [string]$subscription_owner,
    [string]$subscription_owner_name,
    [string]$subscription_owner_email
)

$headers=@{
  "Authorization" = "Bearer $access_token"
  "X-GitHub-Api-Version" = "2022-11-28"
}

$url = "https://api.github.com/repos/$owner/$repository/dispatches"
$body=@{
  "event_type" = "vend_subscription"
  "client_payload" = @{
    "subscription_id" = "12345678-1234-1234-1234-123456789012"
    "subscription_name" = "My Subscription"
    "subscription_owner" = "jared-holgate-microsoft-demos"
    "subscription_owner_name" = "Jared Holgate"
    "subscription_owner_email" = ""
  }
}
$bodyJson = ConvertTo-Json $body

$result = Invoke-RestMethod -Method "POST" -Uri $url -Body $bodyJson -Headers $headers -ContentType "application/vnd.github+json"