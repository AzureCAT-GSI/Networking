Configuration Main
{

Param ( [string] $nodeName )

Import-DscResource -ModuleName PSDesiredStateConfiguration, xNetworking

Node $nodeName
  {
	  File InstallDir {
		  DestinationPath = "C:\Install"
		  Ensure = "Present"
		  Type ="Directory"
	  }

	  Script DownloadWireShark {
		  TestScript = {
			  Test-Path -Path "C:\Install\Wireshark-win64-2.0.2.exe"
		  }

		  SetScript = {
			  $downloadUri = "https://1.na.dl.wireshark.org/win64/Wireshark-win64-2.0.2.exe"
			  $outFile = "C:\Install\Wireshark-win64-2.0.2.exe"
			  Invoke-WebRequest -Uri $downloadUri -OutFile $outFile
			  Unblock-File -Path $outFile
		  }

		  GetScript = {
			  @{Result = "DownloadWireShark"}
		  }

		  DependsOn = "[File]InstallDir"
	  }

	  Script DownloadWinPcap {
		  TestScript = {
			  Test-Path -Path "C:\Install\WinPcap_4_1_3.exe"
		  }

		  SetScript = {
			  $downloadUri = "https://www.winpcap.org/install/bin/WinPcap_4_1_3.exe"
			  $outFile = "C:\Install\WinPcap_4_1_3.exe"
			  Invoke-WebRequest -Uri $downloadUri -OutFile $outFile
			  Unblock-File -Path $outFile
		  }

		  GetScript = {
			  @{Result = "DownloadWinPcap"}
		  }

		  DependsOn = "[File]InstallDir"
	  }

	  Package InstallWireShark {
		  Ensure = "Present"
		  Name = "Wireshark 2.0.2 (64-bit)"
		  ProductId = ""
		  Path = "C:\Install\Wireshark-win64-2.0.2.exe"
		  Arguments = "/S /desktopicon=yes"
		  DependsOn = "[Script]DownloadWireShark"
	  }

      WindowsFeature Routing {
          Ensure = "Present"
          Name = "Routing"
		  DependsOn = "[Package]InstallWireShark"
      }

	  WindowsFeature RoutingTools {
          Ensure = "Present"
          Name = "RSAT-RemoteAccess"
		  DependsOn = "[WindowsFeature]Routing"
      }

	  Script ConfigureRRAS {
		  TestScript = {
			  $rras = Get-Service -Name RemoteAccess
			  return ($rras.Status -eq "Running")
		  }

		  SetScript = {
            netsh ras set type ipv4rtrtype=LANONLY rastype=NONE ipv6rtrtype=NONE
            netsh ras set conf confstate=ENABLED
            Set-Service -Name RemoteAccess -StartupType Automatic -Status Running
		  }

		  GetScript = {
			  @{Result = "ConfigureRRAS"}
		  }

		  DependsOn = "[WindowsFeature]RoutingTools"
	  }
  }
}