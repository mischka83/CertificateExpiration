﻿function Invoke-CENotification {
	# TODO Replace synopsis sample with correct eplanation and examples
	<#
	.SYNOPSIS
	Short description

	.DESCRIPTION
	Long description

	.PARAMETER ExpireDays
	Parameter description

	.PARAMETER PKIAdmins
	Parameter description

	.PARAMETER ExportPath
	Parameter description

	.PARAMETER NoContactMail
	Parameter description

	.PARAMETER PassThru
	Parameter description

	.PARAMETER SenderAddress
	Parameter description

	.PARAMETER FilterTemplateName
	Parameter description

	.EXAMPLE
	An example

	.NOTES
	General notes
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