function Export-CertificateReport {
    <#
    .SYNOPSIS
        Exports a list as csv and xml file with the expiring certificates and exports the associated public certificates as cer file.

    .DESCRIPTION
        Exports a list as csv and xml file with the expiring certificates and exports the associated public certificates as cer file.

    .PARAMETER ExpiringCertificates
        A list containing all certificates to be examined

    .PARAMETER Path
        Specifies the path to export

    .EXAMPLE
        PS C:\> $expiringCertificates | Export-CertificateReport -Path C:\Temp

        Exports the following files to "C:\Temp"
            "expiring_certificates_<date>.csv"
            "expiring_certificates_<date>.xml"
            "<thumbprint.cer"
#>
    [CmdletBinding()]
    param (
        [Parameter(ValueFromPipeline = $true)]
        $ExpiringCertificates,

        [string]
        $Path
    )

    begin {
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
    process {
        $ExpiringCertificates | Select-PSFObject $selectProperties | Export-Csv -Path $csvPath -Append
        foreach ($certificate in $ExpiringCertificates) {
            $cerPath = Join-Path -Path $exportFolder -ChildPath "$($certificate.certificate.thumbprint).cer"
            $cerData = $certificate.certificate.Getrawcertdata()
            [System.IO.File]::WriteAllBytes($cerPath, $cerData)
            $allCerts += $certificate
        }
    }
    end {
        $allCerts | Export-PSFClixml -Path $xmlPath -Depth 5
    }
}
