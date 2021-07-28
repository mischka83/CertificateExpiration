function Invoke-CENotification {
	<#
	.SYNOPSIS
		Invoke-CENotification gives you a summary of the expiring certificates as mailreport, as file export and/or passthru to the console.
		You can also spcifie if a mail to the certificate contact or requester will be sent

	.DESCRIPTION
		Invoke-CENotification gives you a summary of the expiring certificates as mailreport, as file export and/or passthru to the console.
		You can also spcifie if a mail to the certificate contact or requester will be sent

	.PARAMETER ExpireDays
		Defines the scope of the search in days in which the next certificates expire

	.PARAMETER PKIAdmins
		Specifies the e-mail address of the PKI-Administrator to sent the summary of the report

	.PARAMETER ExportPath
		Specifies the path to Export the expiring certificate(s) and report files

	.PARAMETER NoContactMail
		Defines if a seperate mail to the certificate contact or requester will be sent

	.PARAMETER PassThru
		Defines if an output should be done on the console

	.PARAMETER SenderAddress
		Specifies the e-mail address with which the e-mail(s) will be sent

	.PARAMETER FilterTemplateName
		A list of certificate templates to be filtered for

	.EXAMPLE
		PS C:\Invoke-CENotification -ExpireDays <ExpireDays> -PKIAdmins <recipient@domain.de> -ExportPath <LocalPath> -NoContactMail -SenderAddress <Sender@domain.de> -FilterTemplateName <CertificateTemplate>,<CertificateTemplate>

#>
	[CmdletBinding()]
	param (
		[Int]
		$ExpireDays = 90,

		[string]
		$PKIAdmins,

		[PSFValidateScript("PSFramework.Validate.FSPath.Folder", ErrorString="PSFramework.Validate.FSPath.Folder")]
		[string]
		$ExportPath,

		[switch]
		$NoContactMail,

		[switch]
		$PassThru,

		[string]
		$SenderAddress,

		[PSFArgumentCompleter("CertificateExpiration.TemplateDisplayName")]
		[string[]]
		$FilterTemplateName
	)


	begin
	{

	}
	process
	{
		$allCertificates = Get-CEIssuedCertificate -ComputerName (Get-CertificateAuthority) -FilterTemplateName $FilterTemplateName | Resolve-CertificateContact
		$expiringCertificates = $allCertificates | Get-ExpiringCertificate -ExpireDays $ExpireDays

		if ($PKIAdmins) { Send-ExpirationMail -Certificates $expiringCertificates -Recipient $PKIAdmins -SenderAddress $SenderAddress -ExpireDays $ExpireDays -CertificateTemplates $FilterTemplateName }
		if (-not $NoContactMail) {
			$expiringCertificates | Where-Object Contact | Group-Object Contact | ForEach-Object {
				Send-ExpirationMail -Certificates $_.Group -Contact -SenderAddress $SenderAddress -ExpireDays $ExpireDays -CertificateTemplates $FilterTemplateName
			}
		}

		if ($ExportPath) { $expiringCertificates | Export-CertificateReport -Path $ExportPath }
		if ($PassThru) { $expiringCertificates }
	}
	end
	{

	}
}