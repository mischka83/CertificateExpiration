function Get-CertificateAuthority {
    [CmdletBinding()]
    param ()
    $adConfigurationPath = (Get-ADRootDSE).configurationNamingContext
    (Get-ADObject -SearchBase "CN=Enrollment Services,CN=Public Key Services,CN=Services,$adConfigurationPath" -LDAPFilter "(objectClass=pkiEnrollmentService)" -Properties dNSHostName).dNSHostName
}
