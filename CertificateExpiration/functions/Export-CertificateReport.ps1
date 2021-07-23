function Export-CertificateReport {
    [CmdletBinding()]
    param (
        [Parameter(ValueFromPipeline = $true)]
        $ExpiringCertificates,

        [string]
        $Path
    )

    begin{
        $selectProperties = @(
            "IssuedRequestID"
            "Certificate.SerialNumber As SN"
            "RequesterName"
            "Certificate.Subject As Subject"
            "TemplateDisplayName"
            "CertificateExpirationDate"
            "Certificate.Thumbprint As Thumbprint"
            "Certificate.DnsNameList As DnsNameList"
        )
        $allCerts = @()

        $exportFolder = Resolve-PSFPath -Path $Path -SingleItem -Provider FileSystem
        $csvPath = Join-Path -Path $exportFolder -ChildPath "expiring_certificates_$(Get-Date -Format yyyy-MM-dd).csv"
        $xmlPath = Join-Path -Path $exportFolder -ChildPath "expiring_certificates_$(Get-Date -Format yyyy-MM-dd).xml"
    }
    process{
        $ExpiringCertificates | Select-PSFObject $selectProperties | Export-Csv -Path $csvPath -Append
        foreach($certificate in $ExpiringCertificates) {
            $cerPath = Join-Path -Path $exportFolder -ChildPath "$($certificate.certificate.thumbprint).cer"
            $cerData = $certificate.certificate.Getrawcertdata()
            [System.IO.File]::WriteAllBytes($cerPath,$cerData)
            $allCerts += $certificate
        }
    }
    end{
        $allCerts | Export-PSFClixml -Path $xmlPath -Depth 5
    }
}
