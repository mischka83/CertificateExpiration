function Get-ExpiringCertificate {
    <#
    .SYNOPSIS
        Returns the expiring certificates from a list of certificate objects

    .DESCRIPTION
        Returns the expiring certificates from a list of certificate objects

    .PARAMETER Certificate
        a list with one or more certificate objects

    .PARAMETER ExpireDays
        Defines the scope of the search in days in which the next certificates expire

    .EXAMPLE
        PS C:\$expiringCertificates = $allCertificates | Get-ExpiringCertificate -ExpireDays 90

        returns the expiring certificates of the next 90 days from a list of certificate objects
#>
    [CmdletBinding()]
    param (
        [Parameter(ValueFromPipeline = $true)]
        $Certificate,

        [Int]
        $ExpireDays
    )
    begin {
        $limit = (Get-Date).AddDays($ExpireDays)
        $certificateHash = @{}
    }
    process {
        foreach ($certificateObject in $Certificate) {
            $certID = "{0}|{1}" -f $certificateObject.TemplateDisplayName, $certificateObject.Certificate.Subject
            if (-not $certificateHash[$certID]) { $certificateHash[$certID] = @() }
            $certificateHash[$certID] += $certificateObject
        }
    }
    end {
        foreach ($certificateSet in $certificateHash.GetEnumerator()) {

            # Expired
            if (-not($certificateSet.Value | Where-Object CertificateExpirationDate -GE (Get-Date) )){
                continue
            }

            # Not Expiring (out of Scope)
            if ($certificateSet.Value | Where-Object CertificateExpirationDate -GE $limit){
                continue
            }

            # Expiring (in Scope from now till limit)
            $certificateSet.Value | Where-Object CertificateExpirationDate -GE (Get-Date)
        }

    }

}
