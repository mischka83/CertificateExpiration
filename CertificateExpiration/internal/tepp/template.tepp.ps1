
Register-PSFTeppScriptblock -Name "CertificateExpiration.TemplateDisplayName" -ScriptBlock {
    (Get-ADObject -SearchBase (Get-ADRootDSE).configurationNamingContext -LDAPFilter '(objectClass=pKICertificateTemplate)' -Properties DisplayName).DisplayName
} -CacheDuration 24h