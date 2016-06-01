while (1)
{
    nslookup azurecoe.trafficmanager.net
    Start-Sleep -Seconds 10
    ipconfig /flushdns
}

