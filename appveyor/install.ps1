$script_path = split-path -parent $MyInvocation.MyCommand.Definition
. $script_path\utils.ps1

#
# Update submodule
#
Invoke-Expression "git submodule update --init"


# Set Visual Studio environment variables.
If ($env:msvc -eq 15) {
    $vswhere = (Get-Item env:"ProgramFiles(x86)").Value + "\Microsoft Visual Studio\Installer\vswhere.exe"
    $installation_path = Invoke-Expression "& '$vswhere' -latest -property installationPath" | Out-String
    $vc_vars_script_path = $installation_path.Trim() + "\VC\Auxiliary\Build\vcvarsall.bat"
} Else {
    $vc_vars_script_path = (Get-Item env:"VS$($env:msvc)0COMNTOOLS").Value + "..\..\VC\vcvarsall.bat"
}

If ($env:arch -eq 32) {
    $vc_vars_arch = "x86"
} Else {
    $vc_vars_arch = "x86_amd64"
}

$old_env = Get-Environment

Invoke-CmdScript $vc_vars_script_path $vc_vars_arch


#
# Install Tcl
#

If ($env:arch -eq 32) {
    $tcl_arch = "x86"
    $env:tcl_version = $env:tcl32_version
    $tcl_revision = $env:tcl32_revision
} Else {
    $tcl_arch = "x64"
    $env:tcl_version = $env:tcl64_version
    $tcl_revision = $env:tcl64_revision
}
$tcl_installer_name = "ActiveTcl-$env:tcl_version-MSWin32-$tcl_arch-$tcl_revision.exe"
$tcl_url = "http://downloads.activestate.com/ActiveTcl/releases/$env:tcl_version/$tcl_installer_name"
$tcl_output = "$env:APPVEYOR_BUILD_FOLDER\downloads\$tcl_installer_name"
Invoke-Download $tcl_url $tcl_output
Start-Process "$tcl_output" -ArgumentList "/quiet /norestart" -Wait

$env:tcl_path = "C:\ActiveTcl"
$env:PATH = "$env:tcl_path\bin;$env:PATH"


#
# Configure Python.
#

# Add Python 3 to PATH.
$python3_version_array = $env:python3_version.Split('.')
$python3_minimal_version = $python3_version_array[0] + $python3_version_array[1]
If ($env:arch -eq 32) {
    $python3_path = "C:\Python$python3_minimal_version"
} Else {
    $python3_path = "C:\Python$python3_minimal_version-x64"
}
$env:PATH = "$python3_path;$python3_path\Scripts;$env:PATH"

$env:OPENSSL_CONF = "C:\\OpenSSL-Win32\\include\\"

# Download and install pip for Bintray script requirements.
$pip_installer_name = "get-pip.py"
$pip_url = "https://bootstrap.pypa.io/get-pip.py"
$pip_output = "$env:APPVEYOR_BUILD_FOLDER\downloads\$pip_installer_name"
Invoke-Download $pip_url $pip_output
Invoke-Expression "& python '$pip_output'"
Invoke-Expression "& $python3_path\Scripts\pip install requests twitter"

