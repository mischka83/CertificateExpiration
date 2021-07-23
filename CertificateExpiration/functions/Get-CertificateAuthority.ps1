function Get-CertificateAuthority {
    <#
    .SYNOPSIS
        Returns the certification authorities in the Active Directory

    .DESCRIPTION
        Returns the certification authorities in the Active Directory

    .EXAMPLE
        PS C:\Get-CertificationAuthority

        Returns the certifications authorities
        <ComputerName>.<DomainSuffix>

#>
    [CmdletBinding()]
    param ()
    $adConfigurationPath = (Get-ADRootDSE).configurationNamingContext
    (Get-ADObject -SearchBase "CN=Enrollment Services,CN=Public Key Services,CN=Services,$adConfigurationPath" -LDAPFilter "(objectClass=pkiEnrollmentService)" -Properties dNSHostName).dNSHostName
}
