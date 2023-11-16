# Install the Microsoft.Graph module if not already installed
# Install-Module -Name Microsoft.Graph

# Import the Microsoft.Graph module
Import-Module Microsoft.Graph

# Authenticate to Microsoft Graph
$clientID = 'YourClientId'
$tenantID = 'YourTenantId'
$scopes = 'Group.ReadWrite.All', 'User.ReadWrite.All'  # Adjust the scopes based on your requirements

Connect-MgGraph -ClientId $clientID -TenantId $tenantID -Scopes $scopes

# Get the user by display name
$userDisplayName = '<displayName>'
$user = Get-MgUser -Filter "displayName eq '$userDisplayName'"
$userDisplayName
$user | Format-List

# Check if the user is found
if ($user) {
    # Get the user's ID
    $userId = $user.Id

    # Get assigned group IDs
    $assignedGroups = Get-MgUser -UserId $userId -Expand "memberOf" | Select-Object -ExpandProperty memberOf
    $assignedGroupIds = $assignedGroups.Id

    # Get distribution list IDs
    $distributionLists = Get-MgUser -UserId $userId -Expand "transitiveMemberOf" | Select-Object -ExpandProperty transitiveMemberOf
    $distributionListIds = $distributionLists.Id

    # Remove the user from assigned groups using Remove-MgGroupMemberByRef
    foreach ($groupId in $assignedGroupIds) {
        try {
            Remove-MgGroupMemberByRef -GroupId $groupId -DirectoryObjectId $userId -ErrorAction Stop
            Write-Host "User removed from group: $groupId"
        } catch {
            Write-Host "Failed to remove user from group: $groupId. $_"
        }
    }

    # Remove the user from distribution lists using Remove-MgGroupMemberByRef
    foreach ($distributionListId in $distributionListIds) {
        try {
            Remove-MgGroupMemberByRef -GroupId $distributionListId -DirectoryObjectId $userId -ErrorAction Stop
            Write-Host "User removed from distribution list: $distributionListId"
        } catch {
            Write-Host "Failed to remove user from distribution list: $distributionListId. $_"
        }
    }
} else {
    Write-Host "User not found: $userDisplayName"
}

# Disconnect from Microsoft Graph
Disconnect-MgGraph
