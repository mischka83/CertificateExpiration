function Get-CEIssuedCertificate {
    <#
    .SYNOPSIS
        Lists issued certificates.

    .DESCRIPTION
        Lists issued certificates.

    .PARAMETER ComputerName
        The computername of the CA (automatically detects the CA name)

    .PARAMETER FQCAName
        The fully qualified name of the CA.
        Specifying this allows remote access to the target CA.
        '<Computername>\<CA Name>'

    .PARAMETER Properties
        The properties to retrieve

	.PARAMETER UseJea
		A boolean switch to use Just Enough Administration (JEA)

	.PARAMETER Credential
		A PSCredential object to use Credential instead of integrated Account with JEA

    .PARAMETER FilterTemplate
        with this parameter you have the possibility to specify certain certificate templates as filters

    .EXAMPLE
        PS C:\> Get-CEIssuedCertificate

        Returns all issued certificates from the current computer (assumes localhost is a CA)
    
    .EXAMPLE
        PS C:\> Get-CEIssuedCertificate -FilterTemplate <CertificateTemplate>,<CertificateTemplate>

        Returns all filtered issued certificates from the current computer (assumes localhost is a CA)

    .EXAMPLE
        PS C:\> Get-CEIssuedCertificate -FQCAName "ca.contoso.com\MS-CA-01"
#>
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingEmptyCatchBlock', '')]
    [CmdletBinding()]
    param (
        [string[]]
        $ComputerName = $env:COMPUTERNAME,

        [string]
        $FQCAName,

        [String[]]
        $Properties = (
            'Issued Common Name',
            'Certificate Expiration Date',
            'Certificate Effective Date',
            'Certificate Template',
            'Issued Request ID',
            'Certificate Hash',
            'Request Disposition Message',
            'Requester Name',
            'Binary Certificate'
        ),

        [string[]]
        $FilterTemplateName,

        [switch]
        $UseJea,

        [pscredential]
        $Credential

    )
    begin {
        $configPath = (Get-ADRootDSE).configurationNamingContext
        $templates = Get-ADObject -SearchBase $configPath -LDAPFilter '(objectClass=pKICertificateTemplate)' -Properties DisplayName, msPKI-Cert-Template-OID, name

        $parameters = @{
            ArgumentList = $FQCAName, $Properties, $templates, $FilterTemplateName
        }
        if ($Credential){
            $parameters["Credential"] = $Credential
        }
        if ($ComputerName -ne $env:COMPUTERNAME) {
            $parameters["HideComputerName"] = $true
            $parameters["ComputerName"] = $ComputerName
        }
        if ($UseJea) {
            $parameters["ConfigurationName"] = 'JEA_PKI_CertificateExpiration'
            $scriptBlock = { Get-RemoteIssuedCertificate -FQCAName $args[0] -Properties $args[1] -Templates $args[2] -FilterTemplateName $args[3] }
        }
        else {
            $scriptBlock = Get-Content function:Get-RemoteIssuedCertificate
        }
    }
    process {
        Invoke-Command @parameters -ScriptBlock $scriptBlock
    }
}
