# Create AD users from a CSV file
Import-Module ActiveDirectory

$csvPath = "C:\Scripts\users.csv"
$ou      = "OU=Users,OU=Company,DC=lab,DC=local"
$pw      = ConvertTo-SecureString "Welcome2026!x" -AsPlainText -Force   # lab-only test password

Import-Csv $csvPath | ForEach-Object {
    $name = "$($_.FirstName) $($_.LastName)"
    if (-not (Get-ADUser -Filter "SamAccountName -eq '$($_.Username)'")) {
        New-ADUser -Name $name `
            -GivenName $_.FirstName `
            -Surname $_.LastName `
            -SamAccountName $_.Username `
            -UserPrincipalName "$($_.Username)@lab.local" `
            -Path $ou `
            -AccountPassword $pw `
            -Enabled $true `
            -ChangePasswordAtLogon $true
        Add-ADGroupMember -Identity $_.Department -Members $_.Username
        Write-Host "Created $name and added to $($_.Department)"
    } else {
        Write-Host "$name already exists - skipped"
    }
}
