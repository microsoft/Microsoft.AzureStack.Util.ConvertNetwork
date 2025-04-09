function Get-CidrFromSubnetMask {
    <#
        .Synopsis
        Using a subnet mask value, return the cidr as an int32.

        .EXAMPLE
        Get-CidrFromSubnetMask -SubnetMask 255.255.255.252

        30
    #>
    [CmdletBinding()]
    [OutputType([System.Int32])]
    param (
        [Parameter(Mandatory = $true)]
        [IPAddress]
        $SubnetMask
    )

    # Using a subnet mask, count the 1's in the binary output to determine the Cidr.
    $Private:bits = 0
    $SubnetMask.GetAddressBytes() | ForEach-Object {
        $binary = [System.Convert]::ToString($_, 2)
        $bits += $binary.TrimEnd('0').Length
    }

    return $bits
}

function Get-SubnetMaskFromCidr {
    <#
        .Synopsis
        Using a network CIDR value, convert the bit value to a subnet mask.

        .EXAMPLE
        Get-SubnetMaskFromCidr -Cidr 20

        AddressFamily      : InterNetwork
        ScopeId            :
        IsIPv6Multicast    : False
        IsIPv6LinkLocal    : False
        IsIPv6SiteLocal    : False
        IsIPv6Teredo       : False
        IsIPv4MappedToIPv6 : False
        Address            : 15794175
        IPAddressToString  : 255.255.240.0

    #>
    [CmdletBinding()]
    [OutputType([IPAddress])]
    param (
        [Parameter(Mandatory = $true)]
        [ValidateRange(0, 32)]
        [int32]
        $Cidr
    )

    # Create a 32bit binary string
    $Private:binary = ('1' * $Cidr).PadRight(32, '0')

    # Split every the binary every 8 bits and convert it back to an int
    $Private:octets = New-Object -TypeName System.Collections.ArrayList
    for ($i = 0; $i -lt 32; $i += 8) {
        $bOctet = $Private:binary.Substring($i, 8)
        $octets.Add( ([System.Convert]::ToInt32($bOctet, 2) ) ) | Out-Null
    }

    [System.Net.IPAddress]$ipAddress = ( $octets -join ('.') )
    return $ipAddress
}

function Get-IPHostMaskFromSubnetMask {
    <#
        .Synopsis
        Using a subnet mask, this will invert the mask to an IP Host Mask.

        .EXAMPLE
        Get-IPHostMaskFromSubnetMask -SubnetMask 255.255.255.0

        AddressFamily      : InterNetwork
        ScopeId            :
        IsIPv6Multicast    : False
        IsIPv6LinkLocal    : False
        IsIPv6SiteLocal    : False
        IsIPv6Teredo       : False
        IsIPv4MappedToIPv6 : False
        Address            : 4278190080
        IPAddressToString  : 0.0.0.255
    #>
    [OutputType([System.Net.IPAddress])]
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [System.Net.IPAddress]
        $SubnetMask
    )

    # Using the subnet mask, invert the values and return the inverse mask.
    $aIP = $SubnetMask.GetAddressBytes()
    $aInverse = $aIP | ForEach-Object {
        255 -bxor $_
    }

    [System.Net.IPAddress]$inverse = $aInverse -join ('.')
    return $inverse
}

function Get-NetworkAddressFromIP {
    <#
        .SYNOPSIS
        Using a IP within a given subnet with its CIDR bit value, return the Network address of the subnet.

        .EXAMPLE
        Get-NetworkAddressFromIP -IPv4Address 10.10.10.10 -IPv4Mask 255.255.252.0

        AddressFamily      : InterNetwork
        ScopeId            :
        IsIPv6Multicast    : False
        IsIPv6LinkLocal    : False
        IsIPv6SiteLocal    : False
        IsIPv6Teredo       : False
        IsIPv4MappedToIPv6 : False
        Address            : 526858
        IPAddressToString  : 10.10.8.0

        .EXAMPLE
        Get-NetworkAddressFromIP -IPv4Address 10.10.10.10 -CIDR 22

        AddressFamily      : InterNetwork
        ScopeId            :
        IsIPv6Multicast    : False
        IsIPv6LinkLocal    : False
        IsIPv6SiteLocal    : False
        IsIPv6Teredo       : False
        IsIPv4MappedToIPv6 : False
        Address            : 526858
        IPAddressToString  : 10.10.8.0
    #>

    [OutputType([System.Net.IPAddress])]
    [CmdletBinding()]
    param (

        # IPv4 Address that within the IPv4Mask Subnet
        [Parameter(Mandatory = $true, ParameterSetName = 'MASK')]
        [Parameter(Mandatory = $true, ParameterSetName = 'CIDR')]
        [System.Net.IPAddress]
        $IPv4Address,

        # Subnet Mask Value
        [Parameter(Mandatory = $true, ParameterSetName = 'MASK')]
        [System.Net.IPAddress]
        $IPv4Mask,

        # CIDR bit value
        [Parameter(Mandatory = $true, ParameterSetName = 'CIDR')]
        [System.Int32]
        $CIDR
    )

    # Level set so we always utilize a subnet mask, if a CIDR is given.
    if ($PSBoundParameters.Keys -eq 'CIDR') {
        [System.Net.IPAddress]$Private:mask = Get-SubnetMaskFromCidr -Cidr $CIDR
    }
    else {
        [System.Net.IPAddress]$Private:mask = $IPv4Mask
    }

    <#
    # Break the subnet into an Array
    # use the BAnd operator for each octet in the address.
    # this will convert an address to an network address.
    #>
    $aAddress = $IPv4Address.GetAddressBytes()
    $aMask = $Private:mask.GetAddressBytes()

    $aNetwork = for ($i = 0; $i -lt 4; $i++) {
        $aAddress[$i] -band $aMask[$i]
    }

    [System.Net.IPAddress]$ipAddress = ( $aNetwork -join ('.') )
    return $ipAddress
}

function Get-BroadcastAddressFromIP {
    <#

        .SYNOPSIS
        Using an IPv4 address return the broadcast address for a given CIDR/MASK.

        .EXAMPLE
        Get-BroadcastAddressFromIP -IPv4Address 10.10.13.0 -IPv4Mask 255.255.252.0

        AddressFamily      : InterNetwork
        ScopeId            :
        IsIPv6Multicast    : False
        IsIPv6LinkLocal    : False
        IsIPv6SiteLocal    : False
        IsIPv6Teredo       : False
        IsIPv4MappedToIPv6 : False
        Address            : 4279175690
        IPAddressToString  : 10.10.15.255

        .EXAMPLE
        Get-BroadcastAddressFromIP -IPv4Address 10.10.13.0 -CIDR 22

        AddressFamily      : InterNetwork
        ScopeId            :
        IsIPv6Multicast    : False
        IsIPv6LinkLocal    : False
        IsIPv6SiteLocal    : False
        IsIPv6Teredo       : False
        IsIPv4MappedToIPv6 : False
        Address            : 4279175690
        IPAddressToString  : 10.10.15.255
    #>
    [OutputType([System.Net.IPAddress])]
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, ParameterSetName = 'MASK')]
        [Parameter(Mandatory = $true, ParameterSetName = 'CIDR')]
        [System.Net.IPAddress]
        $IPv4Address,

        # Subnet Mask used to determine the broadcast address
        [Parameter(Mandatory = $true, ParameterSetName = 'MASK')]
        [System.Net.IPAddress]
        $IPv4Mask,

        # CIDR bit value
        [Parameter(Mandatory = $true, ParameterSetName = 'CIDR')]
        [System.Int32]
        $CIDR
    )

    # Level set so we always utilize a subnet mask, if a CIDR is given.
    if ($PSBoundParameters.Keys -eq 'CIDR') {
        $mask = (Get-SubnetMaskFromCidr -Cidr $CIDR).ToString()
    }
    else {
        $mask = $IPv4Mask.ToString()
    }

    $aHostMask = (Get-IPHostMaskFromSubnetMask -SubnetMask $mask).ToString() -Split ('\.')
    <#
    # Break the subnet into an Array
    # use the BOR operator for each octet in the address.
    # this will convert an address to an broadcast address.
    #>
    $aAddress = $IPv4Address.GetAddressBytes()
    $Private:aBroadcast = for ($i = 0; $i -lt 4; $i++) {
        [System.Int32]$aAddress[$i] -bor [System.Int32]$aHostMask[$i]
    }

    [System.Net.IPAddress]$ipAddress = ( $aBroadcast -join ('.') )
    return $ipAddress
}

function Export-SubnetFromAddress {
    <#
        .SYNOPSIS
        Subnet a network using the existing cidr and the new cidr

        .EXAMPLE
        Export-SubnetFromAddress -Subnet '10.10.10.0' -Cidr 30 -NewCidr 32

        Position Network    Cidr Supernet
        -------- -------    ---- --------
               0 10.10.10.0   32 10.10.10.0/30
               1 10.10.10.1   32 10.10.10.0/30
               2 10.10.10.2   32 10.10.10.0/30
               3 10.10.10.3   32 10.10.10.0/30

    #>
    [CmdLetBinding()]
    [OutputType([OutputType])]
    Param(

        # Starting Subnet Address
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [IPAddress]
        $Subnet,

        # Cidr of the starting subnet.
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [Int32]
        $Cidr,

        # New Cidr the network will be subneted to.
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [Int32]
        $NewCidr
    )
    BEGIN {
        Write-Verbose -Message "Enter $($MyInvocation.MyCommand.Name)"
        $message = "At: {0}:{1}`n         Line: {2}" -f $MyInvocation.ScriptName, $MyInvocation.ScriptLineNumber, $MyInvocation.Line
        Write-Verbose -Message "Invoked $message"
    }
    PROCESS {

        # ('10.10.13.0' 30)
        $network = Get-NetworkAddressFromIP -IPv4Address $Subnet -CIDR $Cidr

        # '0.13.10.10'
        [IPAddress]$revAddress = Set-AddressInReverse -Address $network

        $newSubnet = New-Object -TypeName System.Collections.ArrayList
        $broadcast = Get-BroadcastAddressFromIP -IPv4Address $Subnet -CIDR $Cidr
        $cidrInc = Get-IPCountInNetwork -Cidr $NewCidr
        $i = 0
        do {
            $decAddr = ($revAddress.Address + $i)

            $address = [PSCustomObject]@{
                Position = $newSubnet.Count
                Network  = [IPAddress]::Parse($decAddr).IPAddressToString
                Cidr     = $newCidr
                Supernet = "$($network.IPAddressToString)/${CIDR}"
            }
            $newSubnet.Add($address) | Out-Null

            $testBroadcast = (Get-BroadcastAddressFromIP -IPv4Address $address.Network -CIDR $newCidr)
            $i += $cidrInc
        }
        Until($broadcast.Equals($testBroadcast))

        return $newSubnet
    }
    END {
        Write-Verbose -Message "Exit $($MyInvocation.MyCommand.Name)"
    }
}

function Get-IPCountInNetwork {
    <#
        .SYNOPSIS
        Calculate the total number of IP address in a network.

        .EXAMPLE
        Get-IPCountInNetwork -Cidr 24

        256

    #>
    [CmdLetBinding()]
    [OutputType([Int32])]
    Param(

        # Cidr bit value of the subnet, this will be used to determine the number of hosts IP's are in a given subnet.
        [Parameter(Mandatory = $true)]
        [ValidateRange(0, 32)]
        [Int32]
        $CIDR
    )
    BEGIN {
        Write-Verbose -Message "Enter $($MyInvocation.MyCommand.Name)"
        $message = "At: {0}:{1}`n         Line: {2}" -f $MyInvocation.ScriptName, $MyInvocation.ScriptLineNumber, $MyInvocation.Line
        Write-Verbose -Message "Invoked $message"
    }
    PROCESS {

        $bits = 32 - $CIDR
        [Int32]$result = [Math]::Pow(2, $bits)
        return $result
    }
    END {
        Write-Verbose -Message "Exit $($MyInvocation.MyCommand.Name)"
    }
}

function Set-AddressInReverse {

    [CmdLetBinding()]
    Param(

        # Parameter Description
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [IPAddress]
        $Address
    )
    BEGIN {
        Write-Verbose -Message "Enter $($MyInvocation.MyCommand.Name)"
        $message = "At: {0}:{1}`n         Line: {2}" -f $MyInvocation.ScriptName, $MyInvocation.ScriptLineNumber, $MyInvocation.Line
        Write-Verbose -Message "Invoked $message"
    }
    PROCESS {

        # (10, 10, 13, 0)
        $nByte = $Address.GetAddressBytes()

        # (0, 13, 10, 10)
        [Array]::Reverse($nByte)

        # (0.13.10.10)
        $result = $nByte -Join ('.')

        return $result
    }
    END {
        Write-Verbose -Message "Exit $($MyInvocation.MyCommand.Name)"
    }
}

function New-MicrosoftAzureStackUtilConvertNetwork {
    <#
        .SYNOPSIS
        Returns a object with all the capbilites included as a single object.

        .EXAMPLE
        New-Microsoft.AzureStack.Util.ConvertNetwork -IPv4Address 10.10.13.20 -Cidr 22

        IPv4Address : 10.10.13.5
        Network     : 10.10.12.0
        Cidr        : 22
        Mask        : 255.255.252.0
        Broadcast   : 10.10.15.255

        .OUTPUTS
        Microsoft.AzureStack.Util.ConvertNetwork

        .NOTES

           TypeName: Microsoft.AzureStack.Util.ConvertNetwork

        Name           MemberType     Definition
        ----           ----------     ----------
        Equals         Method         bool Equals(System.Object obj)
        GetHashCode    Method         int GetHashCode()
        GetType        Method         type GetType()
        ToString       Method         string ToString()
        Cidr           NoteProperty   int Cidr=22
        IPv4Address    NoteProperty   System.String IPv4Address=10.10.13.5
        GetBroadcast   ScriptMethod   System.Object GetBroadcast();
        GetInverseMask ScriptMethod   System.Object GetInverseMask();
        GetIPInSubnet  ScriptMethod   System.Object GetIPInSubnet();
        GetMask        ScriptMethod   System.Object GetMask();
        GetNetwork     ScriptMethod   System.Object GetNetwork();
        NewSubnet      ScriptMethod   System.Object NewSubnet();
        Broadcast      ScriptProperty System.Object Broadcast {get=…
        InverseMask    ScriptProperty System.Object InverseMask {get=…
        Mask           ScriptProperty System.Object Mask {get=…
        Network        ScriptProperty System.Object Network {get=…

    #>
    [CmdLetBinding()]
    Param(

        # IP Address
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [IPAddress]
        $IPv4Address,

        # CIDR bit value
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [ValidateRange(0, 32)]
        [Int32]
        $CIDR
    )
    BEGIN {
        Write-Verbose -Message "Enter $($MyInvocation.MyCommand.Name)"
        $message = "At: {0}:{1}`n         Line: {2}" -f $MyInvocation.ScriptName, $MyInvocation.ScriptLineNumber, $MyInvocation.Line
        Write-Verbose -Message "Invoked $message"
    }
    PROCESS {

        $result = [PSCustomObject]@{
            PSTypeName  = 'Microsoft.AzureStack.Util.ConvertNetwork'
        }

        Add-Member -InputObject $result -MemberType NoteProperty -Name IPv4Address -Value $IPv4Address.IPAddressToString

        Add-Member -InputObject $result -MemberType ScriptProperty -Name Network -Value {
            return $this.GetNetwork().IPAddressToString
        }

        Add-Member -InputObject $result -MemberType NoteProperty -Name Cidr -Value $Cidr

        Add-Member -InputObject $result -MemberType ScriptProperty -Name Mask -Value {
            return $this.GetMask().IPAddressToString
        }

        Add-Member -InputObject $result -MemberType ScriptProperty -Name InverseMask -Value {
            return $this.GetInverseMask().IPAddressToString
        }

        Add-Member -InputObject $result -MemberType ScriptProperty -Name Broadcast -Value {
            return $this.GetBroadcast().IPAddressToString
        }

        Add-Member -InputObject $result -MemberType ScriptMethod -Name GetBroadcast -Value {
            return Get-BroadcastAddressFromIP -IPv4Address $this.IPv4Address -CIDR $this.Cidr
        }

        Add-Member -InputObject $result -MemberType ScriptMethod -Name GetNetwork -Value {
            return Get-NetworkAddressFromIP -IPv4Address $this.IPv4Address -CIDR $this.Cidr
        }

        Add-Member -InputObject $result -MemberType ScriptMethod -Name GetMask -Value {
            return Get-SubnetMaskFromCidr -Cidr $this.Cidr
        }

        Add-Member -InputObject $result -MemberType ScriptMethod -Name GetIPInSubnet -Value {
            return Get-IPCountInNetwork -Cidr $this.Cidr
        }

        Add-Member -InputObject $result -MemberType ScriptMethod -Name NewSubnet -Value {
            param (
                [Parameter(Mandatory = $true)]
                [ValidateNotNullOrEmpty()]
                [ValidateRange(0, 32)]
                [ValidateScript({$_ -gt $this.Cidr})]
                [int32]
                $NewCidr
            )
            return Export-SubnetFromAddress -Subnet $this.GetNetwork() -Cidr $this.Cidr -NewCidr $NewCidr
        }

        Add-Member -InputObject $result -MemberType ScriptMethod -Name GetInverseMask -Value {
            return Get-IPHostMaskFromSubnetMask -SubnetMask $this.GetMask()
        }

        Add-Member -InputObject $result -MemberType ScriptMethod -Name IpIsInSubnet -Value {
            # using an IP address, determin if it is in the subnet range.
            # return boolean.
            param (
                [Parameter(Mandatory = $true)]
                [ValidateNotNullOrEmpty()]
                [IPAddress]
                $IPv4Address
            )

            $testIP = New-MicrosoftAzureStackUtilConvertNetwork -IPv4Address $IPv4Address -CIDR $this.Cidr | Select-Object Network,Broadcast

            # equals will check if the IP's are the same.
            [Boolean]$testNetwork = [IPAddress]::Equals($this.Network, $testIP.Network)
            [Boolean]$testBroadcast = [ipaddress]::Equals($this.Broadcast,$testIP.Broadcast)

            if($testNetwork -and $testBroadcast) {
                [Boolean]$result = $true
            }
            else {
                [Boolean]$result = $false
            }
            return $result
        }

        return $result
    }
    END {
        Write-Verbose -Message "Exit $($MyInvocation.MyCommand.Name)"
    }
}