# Input environment variables:
#   arch: Architecture (32 or 64)
#   msvc: Microsoft Visual C++ version (11, 12, 14)
#   appveyor_repo_tag_name: AppVeyor tag (Vim tags are in vX.Y.Z form)
#   lua_version: Lua version
#   perl_version: Perl version
#   python2_version: Python 2 version
#   python3_version: Python 3 version
#   racket_version: Racket version
#   ruby_version: Ruby version
#   tcl_version: Tcl version
#   bintray_username: Bintray username
#
# Output environment variables:
#   vim_version: Vim version in X.Y.Z form
#   vim_artifact: Vim executable name
#   vim_tweet: message send on Twitter
#   git_description: release notes on GitHub
#   bintray_description: description on Bintray

Function GetMajorMinorVersion($version) {
    $version_array = $version.Split('.')
    $version_array[0] + '.' + $version_array[1]
}

If ($env:arch -eq 32) {
    $vim_arch = "x86"
    $perl_version = $env:perl32_version
    $tcl_version = $env:tcl32_version
} Else {
    $vim_arch = "x64"
    $perl_version = $env:perl64_version
    $tcl_version = $env:tcl64_version
}

$msvc = $env:appveyor_build_worker_image.Substring($env:appveyor_build_worker_image.Length-4)
If ($msvc -eq 2013) {
    $env:msvc = 12
} ElseIf ($msvc -eq 2015) {
    $env:msvc = 14
} ElseIf ($msvc -eq 2017) {
    $env:msvc = 15
}

$python2_major_minor_version = GetMajorMinorVersion $env:python2_version
$python3_major_minor_version = GetMajorMinorVersion $env:python3_version
$tcl_major_minor_version = GetMajorMinorVersion $tcl_version

$logs = (git show -s --pretty=format:%b $env:appveyor_repo_tag_name) | Out-String
# AppVeyor uses "\n" as a convention for newlines in GitHub description
$git_description = $logs.Replace("`r`n", "\n")

