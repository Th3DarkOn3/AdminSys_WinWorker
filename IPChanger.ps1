
if(!([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] 'Administrator')) {
    Start-Process -FilePath PowerShell.exe -Verb Runas -ArgumentList "-File `"$($MyInvocation.MyCommand.Path)`"  `"$($MyInvocation.MyCommand.UnboundArguments)`""
    Exit
}
do
{
    $control1 = 0
    echo '   Menu'
    echo '1. Set your network dhcp'
    echo '2. Set you network in static'
    echo '3. Quit'
    $rispString = Read-Host 'choose your answer (1-3): '
    $risp = [int]$rispString
    cls
    if ($risp -eq 1)
    {
        do{
            $ints = Get-NetAdapter | Select-Object ifIndex,Name
            foreach ($int in $ints) {
                Write-Host $int`n
            }
            $interfaceS = Read-Host 'Select interface index'
            foreach ($int in $ints) {
                if ($int.ifIndex -eq $interfaceS){
                    $control2 ++

                }
            }
            if($control2 -ne 1){
                cls
                echo "ERROR you must put an inteface INDEX from the list"
            }
        }while($control2 -eq 0)
        $interface = [int]$interfaceS
        netsh interface ip set address $interface source=dhcp
        netsh interface ip set dnsservers $interface source=dhcp
        $control1 = 1
        cls
        echo "your inteface number $interface is now in dhcp mode"
    }
    elseif ($risp -eq 2)
    {
        $fCSV = Import-Csv -Path $PSScriptRoot\Network_Lists.csv -delimiter ';'
        $numNet = $fCSV.count
        $fCSV | Format-Table
        $control3 = 0
        do{
            $net = Read-Host -Prompt "select your network code (1 - $numNet): "
            foreach($fnet in $fcsv){
                if ($fnet.Code = $net) {
                    $control3 = 1
                }
            }
            if ($control3 -ne 1) {
                cls
                echo "EROOR you must choose a right CODE"
            }
        }while($control3 -eq 0)
        $intnet = ([int]$net)-1
        cls
        $control2=0
        do{
            $ints = Get-NetAdapter | Select-Object ifIndex,Name
            foreach ($int in $ints) {
                Write-Host $int`n
            }
            $interfaceS = Read-Host 'Select interface index'
            foreach ($int in $ints) {
                if ($int.ifIndex -eq $interfaceS){
                    $control2 = 1
                }
            }
            if($control2 -ne 1){
                cls
                echo "ERROR you must put an inteface INDEX from the list"
            }
        }while($control2 -eq 0)
        $interface = [int]$interfaceS
        netsh interface ip set address $interface static $fCSV[$intnet].ip $fCSV[$intnet].netmask $fCSV[$intnet].gateway
        netsh interface ip set dns $interface static $fCSV[$intnet].dns1
        netsh interface ip add dns $interface $fCSV[$intnet].dns2    index=2
        $control1 = 1
        cls
        echo "your inteface number $interface is now in static mode"
    }
    elseif ($risp -eq 3)
    {
        cls
        echo "Thanks and goodbye"
        $control1 = 1
    }
    else {
        cls
        echo 'ERROR you have to answer (1 - 3)'       
    }
}while ($control1 -eq 0)