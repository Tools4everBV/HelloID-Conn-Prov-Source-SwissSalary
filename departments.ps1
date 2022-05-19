$c = $configuration | ConvertFrom-Json;
    
$header = [ordered]@{
    Accept = "application/json";
}

$body = "scope=https%3A%2F%2Fapi.businesscentral.dynamics.com%2F.default&grant_type=client_credentials&client_id=" + $c.clientid + "&client_secret=" + $c.clientsecret
$response = Invoke-RestMethod 'https://login.microsoftonline.com/" + $c.tenantid + "/oauth2/v2.0/token' -Method 'POST' -Body $body
$accessToken = $response.access_token

$headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
$headers.Add("Authorization", "Bearer " + $accessToken)

# Get companies
$uri_companies = 'https://api.businesscentral.dynamics.com/v2.0/" + $c.tenantid + "/Production/api/swisssalary/swisssalary365/v1.0/companies'
$response_companies = Invoke-RestMethod $uri_companies -Method 'GET' -Headers $headers
$companies = $response_companies.value

# Get departments of companies
$departments = [System.Collections.ArrayList]@()
foreach ($company in $companies)
{
    $company_id = $company.id
    $uri = 'https://api.businesscentral.dynamics.com/v2.0/" + $c.tenantid + "/Production/api/swisssalary/swisssalary365/v1.0/companies(' + $company_id + ')/departments'
    
    $response = Invoke-RestMethod $uri -Method 'GET' -Headers $headers
    $departments_of_company = $response.value
    $departments_of_company | Add-Member -NotePropertyName companyId -NotePropertyValue $company_id   
    $departments_of_company | Add-Member -NotePropertyName companyName -NotePropertyValue $company.name   

    foreach ($f_department in $departments_of_company)
    {
        $department  = @{};
        $department['Name'] = $f_department.description
        $department['DisplayName'] = $f_department.description
        $department['ExternalId'] = $f_department.companyId + '-' + $f_department.code
        $department['companyId'] = $f_department.companyId
        $department['companyName'] = $f_department.companyName
        $department['systemId'] = $f_department.systemId
        if ([string]::IsNullOrEmpty($department['ExternalId']) -eq $true)
        {
            $department['ExternalId'] = $department['Name']
        }
        $department_code = $department['ExternalId'];
        if ($departments.Contains($department['ExternalId']) -eq $false)
        {
            Write-Output ($department | ConvertTo-Json -Depth 20);
            $departments += $department['ExternalId'];
        }
        else
        {
            Write-Verbose -Verbose "Skipped department code exists already: $department_code"
        }
    }

}

Write-Verbose -Verbose "Department import completed";