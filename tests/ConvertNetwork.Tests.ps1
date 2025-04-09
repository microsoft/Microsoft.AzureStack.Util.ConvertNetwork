

    # Import the module to test
    $parentPath = (Get-Item $PSScriptRoot).Parent.FullName
    Import-Module -Name "$($parentPath)\out\Microsoft.AzureStack.Util.ConvertNetwork\Microsoft.AzureStack.Util.ConvertNetwork.psm1" -Force

    Describe "Microsoft.AzureStack.Util.ConvertNetwork Module" {

        BeforeAll {
            # Mock any external dependencies if needed
        }

        Context "Get-SubnetMaskFromCidr" {
            It "Should return the correct subnet mask for a valid CIDR" {
                $result = Get-SubnetMaskFromCidr -Cidr 24
                $result.IPAddressToString | Should -Be "255.255.255.0"
            }

            It "Should throw an error for an invalid CIDR: 33" {
                { Get-SubnetMaskFromCidr -Cidr 33 } | Should -Throw
            }
        }

        Context "Get-CidrFromSubnetMask" {
            It "Should return the correct CIDR for a valid subnet mask" {
                $result = Get-CidrFromSubnetMask -SubnetMask "255.255.255.0"
                $result | Should -Be 24
            }
            It "Should throw an error for an invalid subnet mask" {
                { Get-CidrFromSubnetMask -SubnetMask "255.255.0.255" } | Should -Throw
            }
            it "Should throw an error for an invalid subnet mask" {
                { Get-CidrFromSubnetMask -SubnetMask "255.255.255.256" } | Should -Throw
            }

        }

        Context "Test-SubnetMask" {
            It "Should return $true for a valid subnet mask" {
                Test-SubnetMask -SubnetMask "255.255.255.0" | Should -BeTrue
            }

            It "Should throw an error for an invalid subnet mask" {
                {Test-Subnetmask -SubnetMask "255.255.0.255"} | Should -Throw

            }
        }

        Context "Get-IPHostMaskFromSubnetMask" {
            It "Should return the inverse of the subnet mask" {
                $result = Get-IPHostMaskFromSubnetMask -SubnetMask "255.255.255.0"
                $result.IPAddressToString | Should -Be '0.0.0.255'
            }
            It "Should throw an error for an invalid subnet mask" {
                {Get-IPHostMaskFromSubnetMask -SubnetMask "255.255.0.255"} | Should -Throw
            }
        }
        
        Context "Get-NetworkAddressFromIP" {
            It "Should return network address from IP and subnet mask" {
                $address = Get-NetworkAddressFromIP -IPv4Address 10.10.10.10 -IPv4Mask 255.255.255.0
                $address.IPAddressToString | Should -Be "10.10.10.0"
            }
            It "Should return network address from IP and cidr" {
                $address = Get-NetworkAddressFromIP -IPv4Address 10.10.10.200 -CIDR 25
                $address.IPAddressToString | Should -Be "10.10.10.128"
            }
            It "Should throw cidr is invalid" {
                {Get-NetworkAddressFromIP -IPv4Address 10.10.10.200 -CIDR 35} | Should -Throw
            }
            It "Should throw subnet mask is invalid" {
                {Get-NetworkAddressFromIP -IPv4Address 10.10.10.200 -IPv4Mask 266.255.255.0} | Should -Throw
            }
            It "Should throw ipv4 address is invalid" {
                {Get-NetworkAddressFromIP -IPv4Address 10.10.10.266 -IPv4Mask 255.255.255.0} | Should -Throw
            }
        }
        Context "Set-AddressInReverse" {
            It "Should return reverse address" {
                Set-AddressInReverse -Address "4.20.8.9" | Should -Be "9.8.20.4"
            }
        }

        Context "New-MicrosoftAzureStackUtilConvertNetwork" {
            It "Should create a PS Object containing IPv4Address"{
                $result =  New-MicrosoftAzureStackUtilConvertNetwork -IPv4Address 10.10.13.20 -CIDR 22
                $result.IPv4Address | Should -Be "10.10.13.20"
            }
            It "Should create a PS Object containing Network"{
                $result =  New-MicrosoftAzureStackUtilConvertNetwork -IPv4Address 10.10.13.20 -CIDR 22
                $result.Network | Should -Be "10.10.12.0"
            }
            It "Should create a PS Object containing Cidr"{
                $result =  New-MicrosoftAzureStackUtilConvertNetwork -IPv4Address 10.10.13.20 -CIDR 22
                $result.Cidr | Should -Be "22"
            }
            It "Should create a PS Object containing Mask"{
                $result =  New-MicrosoftAzureStackUtilConvertNetwork -IPv4Address 10.10.13.20 -CIDR 22
                $result.Mask | Should -Be "255.255.252.0"
            }
            It "Should create a PS Object containing InverseMask"{
                $result =  New-MicrosoftAzureStackUtilConvertNetwork -IPv4Address 10.10.13.20 -CIDR 22
                $result.InverseMask | Should -Be "0.0.3.255"
            }
            It "Should create a PS Object containing Broadcast"{
                $result =  New-MicrosoftAzureStackUtilConvertNetwork -IPv4Address 10.10.13.20 -CIDR 22
                $result.Broadcast | Should -Be "10.10.15.255"
            }
            It "Should throw invalid IPv4Address"{
                { New-MicrosoftAzureStackUtilConvertNetwork -IPv4Address 10.10.13.256 -CIDR 22 } | Should -Throw
            }
            It "Should throw invalid Cidr"{
                { New-MicrosoftAzureStackUtilConvertNetwork -IPv4Address 10.10.13.20 -CIDR 35 } | Should -Throw
            }
            It "Should throw invalid Cidr"{
                { New-MicrosoftAzureStackUtilConvertNetwork -IPv4Address 10.10.13.20 -CIDR 'two' } | Should -Throw
            }
        }

        Context "Convert-Network" {
            It "Should create a PS Object containing IPv4Address"{
                $result = Convert-Network -IPv4Address 10.10.13.20 -CIDR 22
                $result.IPv4Address | Should -Be "10.10.13.20"
            }
            It "Should create a PS Object containing Network"{
                $result = Convert-Network -IPv4Address 10.10.13.20 -CIDR 22
                $result.Network | Should -Be "10.10.12.0"
            }
            It "Should create a PS Object containing Cidr"{
                $result = Convert-Network -IPv4Address 10.10.13.20 -CIDR 22
                $result.Cidr | Should -Be "22"
            }
            It "Should create a PS Object containing Mask"{
                $result = Convert-Network -IPv4Address 10.10.13.20 -CIDR 22
                $result.Mask | Should -Be "255.255.252.0"
            }
            It "Should create a PS Object containing InverseMask"{
                $result = Convert-Network -IPv4Address 10.10.13.20 -CIDR 22
                $result.InverseMask | Should -Be "0.0.3.255"
            }
            It "Should create a PS Object containing Broadcast"{
                $result = Convert-Network -IPv4Address 10.10.13.20 -CIDR 22
                $result.Broadcast | Should -Be "10.10.15.255"
            }
        }
        Context "Get-IPCountInNetwork" {
            It "Should return the correct number of IPs in a network" {
                $result = Get-IPCountInNetwork -CIDR 22
                $result | Should -Be 1024
            }
            It "Should throw an error for an invalid CIDR" {
                {Get-IPCountInNetwork -CIDR 35} | Should -Throw
            }
        }
        Context "Export-SubnetFromAddress" {
            It "Should create PSObject containing subnets from an address" {
                $subnets = Export-SubnetFromAddress -Subnet '10.10.10.0' -Cidr 24 -NewCidr 26
                $subnets | Should -Not -BeNullOrEmpty
                $subnets.Position.Count | Should -Be 4
                $subnets.Network[0] | Should -Be '10.10.10.0'
                $subnets.Network[1] | Should -Be '10.10.10.64'
                $subnets.Network[2] | Should -Be '10.10.10.128'
                $subnets.Network[3] | Should -Be '10.10.10.192'
            }
        }
        Context "Get-BroadcastAddressFromIP" {
            It "Should return Broadcast address with Cidr" {
                $result = Get-BroadcastAddressFromIP -IPv4Address '10.10.10.10' -Cidr 30
                $result.IPAddressToString | Should -Be '10.10.10.11'
            }
            It "Should return Broadcast address with IPv4Mask" {
                $result = Get-BroadcastAddressFromIP -IPv4Address '10.10.10.10' -IPv4Mask 255.255.255.252
                $result.IPAddressToString | Should -Be '10.10.10.11'
            }
        }
    }

