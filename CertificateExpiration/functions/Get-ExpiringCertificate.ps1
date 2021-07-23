function Get-ExpiringCertificate {
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
