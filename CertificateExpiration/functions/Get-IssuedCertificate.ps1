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

    .EXAMPLE
        PS C:\> Get-CEIssuedCertificate

        Returns all issued certificates from the current computer (assumes localhost is a CA)

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
        $FilterTemplateName

    )
    begin {
        $configPath = (Get-ADRootDSE).configurationNamingContext
        $templates = Get-ADObject -SearchBase $configPath -LDAPFilter '(objectClass=pKICertificateTemplate)' -Properties DisplayName, msPKI-Cert-Template-OID, name

        $parameters = @{
            ArgumentList = $FQCAName, $Properties, $templates, $FilterTemplateName
        }
        if ($ComputerName -ne $env:COMPUTERNAME) {
            $parameters["HideComputerName"] = $true
            $parameters["ComputerName"] = $ComputerName
        }
    }
    process {
        Invoke-Command @parameters -ScriptBlock {
            param (
                $FQCAName,

                $Properties,

                $Templates,

                $FilterTemplateName
            )

            #region Preparation CA Connect
            try { $caView = New-Object -ComObject CertificateAuthority.View }
            catch { throw "Unable to create Certificate Authority View. $env:COMPUTERNAME does not have ADSC Installed" }

            if ($FQCAName) {
                $null = $CaView.OpenConnection($FQCAName)
            }
            else {
                $caName = (Get-ItemProperty -Path 'HKLM:\System\CurrentControlSet\Services\CertSvc\Configuration' -Name Active).Active
                $null = $caView.OpenConnection("$($env:COMPUTERNAME)\$($caName)")
            }
            $CaView.SetResultColumnCount($Properties.Count)

            foreach ($item in $Properties) {
                $index = $caView.GetColumnIndex($false, $item)
                $caView.SetResultColumn($index)
            }

            $CVR_SEEK_EQ = 1
            # $CVR_SEEK_LT = 2
            # $CVR_SEEK_GT = 16

            # 20 - issued certificates
            $caView.SetRestriction($caView.GetColumnIndex($false, 'Request Disposition'), $CVR_SEEK_EQ, 0, 20)

            $CV_OUT_BASE64HEADER = 0
            $CV_OUT_BASE64 = 1
            $RowObj = $caView.OpenView()
            #endregion Preparation CA Connect

            #region Process Certificates
            while ($RowObj.Next() -ne -1) {
                #region Process Properties
                $Cert = @{
                    PSTypeName = "CATools.IssuedCertificate"
                }
                $ColObj = $RowObj.EnumCertViewColumn()
                $null = $ColObj.Next()
                do {
                    $displayName = $ColObj.GetDisplayName()
                    # format Binary Certificate in a savable format.
                    if ($displayName -eq 'Binary Certificate') {
                        $Cert[$displayName.Replace(" ", "")] = $ColObj.GetValue($CV_OUT_BASE64HEADER)
                        $Cert['Certificate'] = [System.Security.Cryptography.X509Certificates.X509Certificate2]::new(([System.Text.Encoding]::UTF8.GetBytes($Cert[$displayName.Replace(" ", "")])))
                    }
                    else { $Cert[$displayName.Replace(" ", "")] = $ColObj.GetValue($CV_OUT_BASE64) }
                }
                until ($ColObj.Next() -eq -1)
                Clear-Variable -Name ColObj
                #endregion Process Properties

                #region Process Template Name
                if ($Cert.CertificateTemplate) {
                    try {
                        $Cert['TemplateDisplayName'] = ($Templates | Where-Object msPKI-Cert-Template-OID -EQ $Cert.CertificateTemplate).DisplayName
                        if (-not $Cert['TemplateDisplayName']) {
                            $Cert['TemplateDisplayName'] = ($Templates | Where-Object Name -EQ $Cert.CertificateTemplate).DisplayName
                        }
                        if (-not $Cert['TemplateDisplayName']) { $Cert['TemplateDisplayName'] = $Cert.CertificateTemplate }
                        if ($Cert['Certificate']) { Add-Member -InputObject $Cert['Certificate'] -MemberType NoteProperty -Name TemplateDisplayName -Value $Cert['TemplateDisplayName'] }
                    }
                    catch { }
                }
                #endregion Process Template Name
                if($FilterTemplateName) {
                    if($FilterTemplateName -notcontains $cert.TemplateDisplayName) { continue }
                }
                [pscustomobject]$Cert | Add-Member -MemberType ScriptMethod -Name ToString -Value { $this.IssuedCommonName } -Force -PassThru
            }
            #endregion Process Certificates
        }
    }
}
