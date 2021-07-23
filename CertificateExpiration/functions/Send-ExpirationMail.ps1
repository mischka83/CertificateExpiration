function Send-ExpirationMail {
    [CmdletBinding()]
    param (
        $Certificates,

        [string]
        $Recipient,

        [string]
        $SenderAddress,

        [switch]
        $Contact,

        [int]
        $ExpireDays,

        [string[]]
        $CertificateTemplates
    )

    #region mailbody
    $mailbody = @"
    <html>
    <head>
        <meta http-equiv=Content-Type content="text/html; charset=utf-8">
        <style>
            body{
                font-family:`"Calibri`",`"sans-serif`";
                font-size: 14px;
            }
            @font-face{
                font-family:`"Cambria Math`";
                panose-1:2 4 5 3 5 4 6 3 2 4;
            }
            @font-face{
                font-family:Calibri;
                panose-1:2 15 5 2 2 2 4 3 2 4;
            }
            @font-face{
                font-family:Tahoma;
                panose-1:2 11 6 4 3 5 4 4 2 4;
            }
            table{
                border: 1px solid black;
                border-collapse:collapse;
                mso-table-lspace:0pt;
                mso-table-rspace:0pt;
            }
            th{
                border: 1px solid black;
                background: #dddddd;
                padding: 5px;
            }
            td{
                border: 1px solid black;
                padding: 5px;
            }
            .crtsn{
                font-weight: bold;
                color: blue;
            }
            .crtexp{
                font-weight: bold;
                color: red;
            }
            .crtcn{
                font-weight: bold;
                color: orange;
            }
        </style>
    </head>
    <body>
    <p>
    Hallo Zusammen,<br /><br />
    Nachfolgend eine Liste über Zertifikate die in den nächsten $ExpireDays Tagen auslaufen<br />
    </p>
    <p>
    Auf folgenden Templates gefiltert: <br />
    <ul>
$($CertificateTemplates | Format-String "       <li>{0}</li>" | Join-String "`n")
    </ul>
    </p>
    Details: <br />
    <p>
    <table>
        <tr>
            <th>Request ID</th>
            <th>Serial Number</th>
            <th>Requester Name</th>
            <th>Requested CN</th>
            <th>Certificate Template</th>
            <th>Expiration date</th>
        </tr>
%CertificateList%
    </p>
    <p>Mit freundlichen Gr&uuml;&szlig;en<br /><br /> Ihr PKI-Team</p>
    </body>
    </html>
"@
    $tableHTML = $Certificates |
    Select-PSFObject IssuedRequestID, "Certificate.SerialNumber As SN", RequesterName, "Certificate.Subject As Subject", TemplateDisplayName, "CertificateExpirationDate" |
    ConvertTo-Html -Fragment |
    Split-String "`n" |
    Select-Object -Skip 3 |
    Format-String "        {0}"

    $mailbody = $mailbody | Set-String -OldValue %CertificateList% -NewValue ($tableHTML -join "`n") -DoNotUseRegex
    #endregion mailbody

    if ($Contact) { $Recipient = @($Certificates)[0].Contact }

    Set-MDMail -To $Recipient -Subject "Certificate Expiration Warning" -Body $mailbody -BodyAsHtml
    if ($SenderAddress) { Set-MDMail -From $SenderAddress }
    Send-MDMail -TaskName CertficateExpirationReport

}
