#choco install sql-server-management-studio  --limitoutput
    choco install sql-operations-studio         --limitoutput
    choco install curl
    choco install cmder
    choco install hyper
    choco install cygwin
    choco install firacode
    choco install fciv
    choco install filezilla
    choco install gcloudsdk
    choco install git -params '"/GitAndUnixToolsOnPath"'
    choco install git-credential-winstore
    choco install poshgit
    choco install intellijidea-community
    choco install linqpad
    choco install nuget.commandline
    choco install nimbletext
    choco install posh-git
    choco install powershell
    choco install azure-cli
    choco install procexp
    choco install putty
    choco install python
    choco install anaconda3 /AddToPath:1
    choco install postman
    choco install sysinternals
    choco install vim
    choco install vscode
    choco install windbg
    choco install winmerge
    choco install docker
    choco install docker-for-windows    
    Install-WebPackage 'Docker Toolbox' 'exe' '/SILENT /COMPONENTS="Docker,DockerMachine,DockerCompose,VirtualBox,Kitematic" /TASKS="modifypath"' $tempInstallFolder https://github.com/docker/toolbox/releases/download/v1.9.1i/DockerToolbox-1.9.1i.exe
    choco install nugetpackageexplorer
    choco install poshgit
    choco install windowsazurepowershell
    choco install microsoftazurestorageexplorer
    choco install servicebusexplorer
    choco install dotnetcore-sdk
    choco install azure-functions-core-tools
    #choco install windowsazurelibsfornet
    #choco install rapidee
    #choco install scala
    #choco install lessmsi
    #choco install terraform 
    #choco install draft 
    #choco install kubernetes-helm 
    #choco install packer
    #choco install golang
    #choco install vagrant
    #choco install tortoisegit
    #choco install azurestorageexplorer cloudberryexplorer.azurestorage

    # pin apps that update themselves
    choco pin add -n=docker-for-windows