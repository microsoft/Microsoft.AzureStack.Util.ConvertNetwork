# Microsoft.AzureStack.Util.ConvertNetwork

[![Pester Unit Tests](https://github.com/microsoft/Microsoft.AzureStack.Util.ConvertNetwork/actions/workflows/powershell-pester-test.yml/badge.svg)](https://github.com/microsoft/Microsoft.AzureStack.Util.ConvertNetwork/actions/workflows/powershell-pester-test.yml)
[![PSScriptAnalyzer](https://github.com/microsoft/Microsoft.AzureStack.Util.ConvertNetwork/actions/workflows/powershell-psscriptanalyzer.yml/badge.svg)](https://github.com/microsoft/Microsoft.AzureStack.Util.ConvertNetwork/actions/workflows/powershell-psscriptanalyzer.yml)
[![License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)

## Overview

`Microsoft.AzureStack.Util.ConvertNetwork` is a PowerShell module that provides utilities for working with IPv4 networks. It includes functions to calculate subnet masks, CIDR values, broadcast addresses, and more. This project is designed to simplify network-related operations for developers and IT professionals.

## Features

- Convert CIDR to subnet masks and vice versa.
- Calculate network and broadcast addresses.
- Validate subnet masks and IP addresses.
- Generate subnets from a given network.
- Perform IP address calculations with ease.

## Table of Contents

- [Installation](#installation)
- [Usage](#usage)
- [Contributing](#contributing)
- [License](#license)
- [Support](#support)
- [Code of Conduct](#code-of-conduct)

## Installation

To install the module, clone this repository and import the module into your PowerShell session:

```powershell
git clone https://github.com/microsoft/Microsoft.AzureStack.Util.ConvertNetwork.git
Import-Module .\src\Microsoft.AzureStack.Util.ConvertNetwork.psm1
```

### Unit-Testing

Requirements:

- dotnet8 sdk

To install dotnet 8 see https://dotnet.microsoft.com/en-us/download/dotnet/8.0

The build step will download the required pester NuGet package before executing the test.

The Pester testing script expects a dotnet build to be executed before running the test.  The build step will place the script into an `<repo-root>/out` directory then execute the test on that script.  The test results will be place in `<repo-root>/out/Tests`.

Upon a pull-request, the unit-test will be performed against the script.  A passing unit-test will be required before any changes are approved.

## Usage

Here are some examples of how to use the module:

Convert CIDR to Subnet Mask

```powershell
Get-SubnetMaskFromCidr -Cidr 24

AddressFamily      : InterNetwork
ScopeId            :
IsIPv6Multicast    : False
IsIPv6LinkLocal    : False
IsIPv6SiteLocal    : False
IsIPv6Teredo       : False
IsIPv6UniqueLocal  : False
IsIPv4MappedToIPv6 : False
Address            : 16777215
IPAddressToString  : 255.255.255.0
```

Calculate Network Address

```powershell
Get-NetworkAddressFromIP -IPv4Address 192.168.1.40 -CIDR 27

AddressFamily      : InterNetwork
ScopeId            :
IsIPv6Multicast    : False
IsIPv6LinkLocal    : False
IsIPv6SiteLocal    : False
IsIPv6Teredo       : False
IsIPv6UniqueLocal  : False
IsIPv4MappedToIPv6 : False
Address            : 536979648
IPAddressToString  : 192.168.1.32
```

#### Convert-Network object

Used to describe a subnet attributes.

```powershell
Convert-Network -IPv4Address 192.168.1.0 -CIDR 25
IPv4Address : 192.168.1.0
Network     : 192.168.1.0
Cidr        : 25
Mask        : 255.255.255.128
InverseMask : 0.0.0.127
Broadcast   : 192.168.1.127
```

####Members from Convert-Network

```powershell
Convert-Network -IPv4Address 192.168.1.0 -CIDR 25 | Get-Member

   TypeName: Microsoft.AzureStack.Util.ConvertNetwork

Name           MemberType     Definition
----           ----------     ----------
Equals         Method         bool Equals(System.Object obj)
GetHashCode    Method         int GetHashCode()
GetType        Method         type GetType()
ToString       Method         string ToString()
Cidr           NoteProperty   int Cidr=25
IPv4Address    NoteProperty   System.String IPv4Address=192.168.1.0
GetBroadcast   ScriptMethod   System.Object GetBroadcast();
GetInverseMask ScriptMethod   System.Object GetInverseMask();
GetIPInSubnet  ScriptMethod   System.Object GetIPInSubnet();
GetMask        ScriptMethod   System.Object GetMask();
GetNetwork     ScriptMethod   System.Object GetNetwork();
IpIsInSubnet   ScriptMethod   System.Object IpIsInSubnet();
NewSubnet      ScriptMethod   System.Object NewSubnet();
Broadcast      ScriptProperty System.Object Broadcast {get=…
InverseMask    ScriptProperty System.Object InverseMask {get=…
Mask           ScriptProperty System.Object Mask {get=…
Network        ScriptProperty System.Object Network {get=…
```

#### ConvertNetwork - GetIPInSubnet()

```powershell
(Convert-Network -IPv4Address 192.168.1.0 -CIDR 25).GetIPInSubnet()
128
```

#### ConvertNetwork - GetMask()

```powershell
(Convert-Network -IPv4Address 192.168.1.0 -CIDR 25).GetMask().ToString()
255.255.255.128
```

#### ConvertNetwork - GetNetwork()

```powershell
(Convert-Network -IPv4Address 192.168.1.0 -CIDR 25).GetNetwork().ToString()
192.168.1.0
```

#### ConvertNetwork - IpIsInSubnet()

```powershell
(Convert-Network -IPv4Address 192.168.1.0 -CIDR 25).IpIsInSubnet("192.168.2.1")
False
```

#### ConvertNetwork - NewSubnet()

```powershell
(Convert-Network -IPv4Address 192.168.1.0 -CIDR 25).NewSubnet(29)
Position Network       Cidr Supernet
-------- -------       ---- --------
       0 192.168.1.0     29 192.168.1.0/25
       1 192.168.1.8     29 192.168.1.0/25
       2 192.168.1.16    29 192.168.1.0/25
       3 192.168.1.24    29 192.168.1.0/25
       4 192.168.1.32    29 192.168.1.0/25
       5 192.168.1.40    29 192.168.1.0/25
       6 192.168.1.48    29 192.168.1.0/25
       7 192.168.1.56    29 192.168.1.0/25
       8 192.168.1.64    29 192.168.1.0/25
       9 192.168.1.72    29 192.168.1.0/25
      10 192.168.1.80    29 192.168.1.0/25
      11 192.168.1.88    29 192.168.1.0/25
      12 192.168.1.96    29 192.168.1.0/25
      13 192.168.1.104   29 192.168.1.0/25
      14 192.168.1.112   29 192.168.1.0/25
      15 192.168.1.120   29 192.168.1.0/25
```

For more examples, see the [tests](tests/ConvertNetwork.Tests.ps1).

## License

This project is licensed under the [MIT License](LICENSE).

## Support

If you encounter any issues or have questions, please file an issue in the [GitHub Issues](https://github.com/microsoft/Microsoft.AzureStack.Util.ConvertNetwork/issues) section.

## Contributing
[Contributing](CONTRIBUTING.md).

## Code of Conduct

This project has adopted the [Microsoft Open Source Code of Conduct](https://opensource.microsoft.com/codeofconduct/). For more information, see the [Code of Conduct FAQ](https://opensource.microsoft.com/codeofconduct/faq/) or contact [opencode@microsoft.com](mailto:opencode@microsoft.com) with any additional questions or concerns.

## Acknowledgments

- [Pester](https://github.com/pester/Pester) for unit testing.
- Microsoft for supporting this open-source initiative.

## Trademarks

This project may contain trademarks or logos for projects, products, or services. Authorized use of Microsoft 
trademarks or logos is subject to and must follow 
[Microsoft's Trademark & Brand Guidelines](https://www.microsoft.com/en-us/legal/intellectualproperty/trademarks/usage/general).
Use of Microsoft trademarks or logos in modified versions of this project must not cause confusion or imply Microsoft sponsorship.
Any use of third-party trademarks or logos are subject to those third-party's policies.
