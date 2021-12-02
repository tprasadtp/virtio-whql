# VirtIO Windows WHQL Drivers

[![build](https://github.com/tprasadtp/virtio-whql/actions/workflows/build.yml/badge.svg)](https://github.com/tprasadtp/virtio-whql/actions/workflows/build.yml)
[![upstream-pkg](https://img.shields.io/badge/virtio--win-rockylinux-10B981?logo=rockylinux)](https://git.rockylinux.org/staging/rpms/virtio-win)
[![releases](https://img.shields.io/github/v/tag/tprasadtp/virtio-whql?label=release&sort=semver&logo=semver&color=7f50a6&labelColor=3a3a3a)](https://github.com/tprasadtp/virtio-whql/releases/latest)

WHQL `virtio` drivers for Windows 10/11 and Windows Server 2019/2022, extracted from RockyLinux 8 repositories.

## Build

Though build can be performed on a Linux machine, or in WSL, Verification requires Windows host.
Build will extract and save ISO file to `docker/build/virtio-win.iso`

```sh
make build
```

## Notes

- Generating `scripts/virtio.list` (Requires Windows)

    ```powershell
    Get-ChildItem -Recurse -File <ISO-Drive-Letter>:\ | Where {!$_.PSIsContainer} | Select-Object -ExpandProperty FullName | Where {$_.EndsWith(".cat") -or $_.EndsWith(".exe") -or $_.EndsWith(".msi") -or $_.EndsWith("sys") -or $_.EndsWith(".dll")} | Where {!$_.EndsWith("qemu-ga-x86_64.msi") -and !$_.EndsWith("qemu-ga-i386.msi") } | Split-Path -NoQualifier | Out-File .\scripts\virtio.list
    ```

- Verifying authenticode signature of all the drivers and executables. (Requires Windows)
    ```powershell
    .\scripts\verify.ps1 -List scripts\virtio.list -BasePath <ISO-Drive-Letter>:\
    ```
