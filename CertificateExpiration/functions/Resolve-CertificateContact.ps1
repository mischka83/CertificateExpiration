function Resolve-CertificateContact {
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
