$c = $configuration | ConvertFrom-Json;
    
$header = [ordered]@{
    Accept = "application/json";
}

$body = "scope=https%3A%2F%2Fapi.businesscentral.dynamics.com%2F.default&grant_type=client_credentials&client_id=" + $c.clientid + "&client_secret=" + $c.clientsecret
$response = Invoke-RestMethod 'https://login.microsoftonline.com/95806b3e-1cff-4894-8beb-f0b0302988a0/oauth2/v2.0/token' -Method 'POST' -Body $body
$accessToken = $response.access_token

$headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
$headers.Add("Authorization", "Bearer " + $accessToken)

# Get companies
$uri_companies = 'https://api.businesscentral.dynamics.com/v2.0/95806b3e-1cff-4894-8beb-f0b0302988a0/Production/api/swisssalary/swisssalary365/v1.0/companies';
$response_companies = Invoke-RestMethod $uri_companies -Method 'GET' -Headers $headers;
$companies = $response_companies.value;

# Get employees of companies
$employees = [System.Collections.ArrayList]@();
foreach ($company in $companies)
{
    $company_id = $company.id;

    $uri = 'https://api.businesscentral.dynamics.com/v2.0/95806b3e-1cff-4894-8beb-f0b0302988a0/Production/api/swisssalary/swisssalary365/v1.0/companies(' + $company_id + ')/employees';
    
    $response = Invoke-RestMethod $uri -Method 'GET' -Headers $headers;
    $employees_of_company = $response.value;
    $employees_of_company | Add-Member -NotePropertyName companyId -NotePropertyValue $company_id;
    $employees_of_company | Add-Member -NotePropertyName companyName -NotePropertyValue $company.name;
    # $employees.Add($employees_of_company);
    foreach ($employee in $employees_of_company)
    {
        $person  = @{};
        $employeeNo = $company_id + "-" + $employee.employeeNo;
        $person['ExternalId'] = $employeeNo;
        $person['EmployeeNo'] = $employee.employeeNo;
        $person['FirstName'] = $employee.firstName;
        $person['LastName'] = $employee.name;
        $Name = $employee.name + ", " + $employee.firstName;
        $person['DisplayName'] = $Name;
        $person['Convention'] = "B";
        if ($employee.blocked -eq $true)
        {
            Write-Verbose -Verbose "Skipped employee is blocked: $employeeNo - $Name"
            continue; 
        }
        $person['Department'] = $employee.department;
        $person['Profession'] = $employee.profession;

        foreach ($prop in ($employee | Get-Member -MemberType NoteProperty))
        {
            if ($prop.Name -notmatch "@")
            {
                $person[$prop.Name] = $employee | Select-Object -ExpandProperty $prop.Name;
            }
        }
        
        $person['Contracts'] = [System.Collections.ArrayList]@();
        $contract = @{};
        $contract['SequenceNumber'] = "1";
        $contract['DepartmentName'] = $employee.department; # | Select-Object -ExpandProperty department;
        $contract['DepartmentNumber'] = $company_id + "-" + $employee.department;
        $employmentDate = $employee.employmentDate;
        if ([string]::IsNullOrEmpty($employmentDate) -or $employmentDate -eq '0001-01-01') 
        { $contract['StartDate'] = $null; } 
        else 
        { $contract['StartDate'] = Get-date($employmentDate) -format 'o'; } 
        $resignationDate = $employee.resignationDate;
        if ([string]::IsNullOrEmpty($resignationDate) -or $resignationDate -eq '0001-01-01') 
        { $contract['EndDate'] = $null; } 
        else 
        { $contract['EndDate'] = Get-date($resignationDate) -format 'o'; } 
        $contract['ManagerExternalId'] = $null
        $contract['DepartmentCode'] = $company_id + "-" + $employee.department;
        $contract['TitleCode'] = $employee.Position;
        $contract['TitleName'] = $employee.Position;
        $contract['LocationCode'] = $employee.placeOfWork;
        $contract['LocationName'] = $employee.placeOfWork;
        $contract['companyId'] = $employee.companyId;
        $contract['companyName'] = $employee.companyName;
        $contract['GB'] = $null;
        $contract['GBBezeichnung'] = $null;


        [void]$person['Contracts'].Add($contract);
        Write-Output ($person | ConvertTo-Json -Depth 10);
    }
}

Write-Verbose -Verbose "Person import completed";