# 
# Download hadoop and config system variables for hadoop
# Required: Windows 10, JDK1.7+, Git
# Note: Run this script in administrator permission
# Author: Ninechapter
# 

$HADOOP_VERSION = "3.0.0"

$HADOOP_URL = "http://mirrors.tuna.tsinghua.edu.cn/apache/hadoop/common/hadoop-${HADOOP_VERSION}/hadoop-${HADOOP_VERSION}.tar.gz"
# Change this url if you want to use another mirror
function Set-System-Variable ($name, $value) {
    [System.Environment]::SetEnvironmentVariable($name, $value, [System.EnvironmentVariableTarget]::Machine)
}

function Add-System-Path ($path) {
    $systemPath = [System.Environment]::GetEnvironmentVariable("Path", "Machine")
    [System.Environment]::SetEnvironmentVariable(
        "Path", ($systemPath + ';' + $path + ';'), [System.EnvironmentVariableTarget]::Machine
    )

}

function Set-JAVA_HOME () {
    $jdkFolders = Get-ChildItem "C:\Progra~1\Java\jdk*"
    if (-not $jdkFolders) {
        Write-Output "Can't find JDK in your Program Files, Please install JDK first"
        exit 1
    }
    Set-System-Variable "JAVA_HOME" ("C:\Progra~1\Java\" + $jdkFolders[0].Name)
}

function Get-Hadoop () {
    Import-Module BitsTransfer

    if (-not (Find-Module "7Zip4Powershell")) {
        Write-Output "Can't find 7zip4Powershell, now Install it."
        Install-Module -Name 7Zip4Powershell -SkipPublisherCheck
        # Install 7ip for extract file
    }
    if (-not (Test-Path "hadoop-${HADOOP_VERSION}.tar.gz")) {
        Write-Output "Can't find hadoop binary compressed file, now download it."
        Start-BitsTransfer -Source $HADOOP_URL -OutVariable "hadoop-${HADOOP_VERSION}.tar.gz"
        # Download hadoop
    }
    if (-not (Test-Path "winutils")) {
        git clone https://github.com/steveloughran/winutils.git
    }
    if (-not(Test-Path "hadoop-${HADOOP_VERSION}")) {
        Write-Output "Extracting hadoop-${HADOOP_VERSION}.tar.gz, it will take several time."
        Expand-7Zip -ArchiveFileName "hadoop-${HADOOP_VERSION}.tar.gz" -TargetPath "."
        Expand-7Zip -ArchiveFileName ".\hadoop-${HADOOP_VERSION}.tar" -TargetPath "." -ErrorAction Ignore
        # extract files
    }
    Copy-Item -Path ".\winutils\hadoop-${HADOOP_VERSION}\bin\*" -Destination ".\hadoop-${HADOOP_VERSION}\bin\" -Force
}
function Reload-Environment () {
    $env:JAVA_HOME = [System.Environment]::GetEnvironmentVariable("JAVA_HOME", "Machine")
    $env:HADOOP_HOME = [System.Environment]::GetEnvironmentVariable("HADOOP_HOME", "Machine")
    $env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path", "User")
}

function Test-Command ($command) {
    return Get-Command $command -ErrorAction Ignore
}

if (-not (Test-Command "git")) {
    Write-Output "Please install git first."
}

Get-Hadoop

if (-not ($env:JAVA_HOME)) {
    Set-JAVA_HOME
}

Set-System-Variable "HADOOP_HOME" ((Get-Location).Path + "\hadoop-${HADOOP_VERSION}")
Set-System-Variable 'HADOOP_HDFS_HOME' "%HADOOP_HOME%\share\hadoop\hdfs"
Set-System-Variable 'HADOOP_YARN_HOME' "%HADOOP_HOME%\share\hadoop\yarn"
Reload-Environment

Add-System-Path "${env:JAVA_HOME}\bin"
Add-System-Path "${env:HADOOP_HOME}\bin"

Reload-Environment
if (Test-Command "javac") {
    Write-Output "Test JDK success"
}
else {
    Write-Output "Test JDK failed"
}

if (Test-Command "hadoop") {
    Write-Output "Test hadoop success"
}
else {
    Write-Output "Test hadoop failed"
}
