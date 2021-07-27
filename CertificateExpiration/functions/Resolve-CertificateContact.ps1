function Resolve-CertificateContact {
    <#
    .SYNOPSIS
        Adds a "Contact" field to the list of certificates

    .DESCRIPTION
        The function tries to read the e-mail address from the certificate or
        to resolve the e-mail address from the requestername in the Active Directory
        and adds a "Contact" field to the list of certificates.

    .PARAMETER Certificate
        a list with one or more certificate objects

    .EXAMPLE
        PS C:\>$allCertificates = Get-CEIssuedCertificate -ComputerName (Get-CertificateAuthority) -FilterTemplateName $FilterTemplateName | Resolve-CertificateContact

        Returns the expiring certificates of the next 90 days from a list of certificate objects including the mail address (if available)

    .NOTES
    General notes
#>
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingEmptyCatchBlock', '')]
    [CmdletBinding()]
    param (
        [Parameter(ValueFromPipeline=$true)]
        $Certificate
    )
    begin{
        $mailHash=@{}
    }
    process{
        foreach($certObject in $Certificate) {
            $contact = ""

            # Prüfen, ob im Certifikatssubject eine E-Mail eingetragen ist
            if($certObject.Certificate.Subject -match "E=") {
                $contact = $certObject.Certificate.Subject -replace '^.{0,}E=(.+?),.+$','$1'
            }

            #
            if(-not $contact -and $mailHash[$certObject.RequesterName] -ne "noMail"){
                if($mailHash[$certObject.RequesterName].Mail) {
                    $contact = $mailHash[$certObject.RequesterName].Mail
                }
                else {
                    try {
                        $adObject = Resolve-Principal $certObject.RequesterName -ErrorAction Stop | Get-ADObject -Properties Mail -ErrorAction Stop
                    }
                    catch { }
                    if($adObject.Mail) {
                        $contact = $adObject.Mail
                        $mailHash[$certObject.RequesterName] = $adObject
                    }
                    else {
                        $mailHash[$certObject.RequesterName] = "noMail"
                    }
                }

            }

            $certObject | Add-Member -MemberType NoteProperty -Name Contact -Value $contact -Force -PassThru
        }

    }
    end{

    }
}
