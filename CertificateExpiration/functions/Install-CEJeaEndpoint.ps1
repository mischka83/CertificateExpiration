function Install-CEJeaEndpoint {
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