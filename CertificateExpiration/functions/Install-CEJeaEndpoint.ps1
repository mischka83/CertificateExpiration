function Install-CEJeaEndpoint {
    <#
    .SYNOPSIS
    Installed the JeaEndpoint on the remote CA
    
    .DESCRIPTION
    Installed the JeaEndpoint on the remote CA
    
    .PARAMETER Identity
    Parameter description
    
    .PARAMETER ComputerName
    The computername of the CA where the JEA endpoint will be installed
    
    .PARAMETER Credential
    A PSCredential object to use Credential
    
    .PARAMETER Basic
    TODO: Parameter description
    
    .EXAMPLE
    PS C:\Install-CEJeaEndpoint -Identity <Identity> -ComputerName <Computer> -Credential $cred -Basic:$true#

    TODO: description of the Example
    
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string[]]
        $Identity,

        [PSFComputer[]]
        $ComputerName = $env:COMPUTERNAME,

        [PSCredential]
        $Credential,

        [switch]
        $Basic
    )
    $module = New-JeaModule -Name 'PKI_CertificateExpiration'

    $capabilities = @(
        "$script:ModuleRoot\internal\functions\Get-RemoteIssuedCertificate.ps1"
    )
    $capabilities | New-JeaRole -Name 'PkiIssuedCertificateReader' -Identity $Identity -Module $module

    $module.Author = 'Christian Sohr'
    $module.Description = 'Delegate administrative tasks for PKI servers'
    $module.Version = '0.1.0'

    Install-JeaModule -ComputerName $ComputerName -Credential $Credential -Basic:$Basic -Module $module

}