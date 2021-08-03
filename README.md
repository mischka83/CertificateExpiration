# Description
You are a certificate administrator and would like to get an overview of which certificates will expire in the near future? 
Maybe also an automatic notification to a contact person?

Then this module is exactly the right one for you.

This Module gives you a summary of the expiring certificates as mailreport, as file export and/or passthru to the console.
You can also specify if a mail to the certificate contact or requester will be sent.

# Main Features
- CSV and XML Export with all expiring certificates
- Exports the expiring certificates as cer-files
- Centralize mail sending, with dedicated account or credentials to PKI-Admin and/or specified contact

# Prerequisites
- PowerShell 5.1
- PowerShell Module: MailDaemon
- PowerShell Module: Principal
- PowerShell Module: String

# Requirements
- Read permission in the Active Directory
- Admin permissions for the Certification Authority

# Examples
Returns the Certification Authority from the Active Directory
```powershell
PS C:\Get-CertificateAuthority
```
Returns all certificates from CA <ComputerName>
```powershell
PS C:\$allcertificate = Get-IssuedCertificate -ComputerName <ComputerName>
```
# Links

- [Repo](https://github.com/mischka83/CertificateExpiration) "CertificateExpiration"
  
# Contribution

# Author
**Christian Sohr**

- [Profile](https://github.com/mischka83 "Christian Sohr")
- [Email](mailto:csohr@gmx.de?subject=Hi "Hi!")

# License
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
  The source code for the site is licensed under the MIT license, which you can find in the LICENSE.txt file.

# Project Status
##0.1.0 (2021-08-21)
Alpha Release. It "Should" do the job and do it well enough.
