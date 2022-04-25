# VirtIO Windows - WHQL Drivers

[![build](https://github.com/tprasadtp/virtio-whql/actions/workflows/build.yml/badge.svg)](https://github.com/tprasadtp/virtio-whql/actions/workflows/build.yml)
[![upstream-pkg](https://img.shields.io/badge/upstream-virtio--win-10B981?logo=rockylinux)](https://git.rockylinux.org/staging/rpms/virtio-win)
[![upstream-pkg](https://img.shields.io/badge/changelog-virtio--win-10B981?logo=rockylinux)](https://git.rockylinux.org/staging/rpms/virtio-win/-/blob/r8/SPECS/virtio-win.spec#L280)
[![releases](https://img.shields.io/github/v/tag/tprasadtp/virtio-whql?label=release&sort=semver&logo=semver&color=7f50a6&labelColor=3a3a3a)](https://github.com/tprasadtp/virtio-whql/releases/latest)

[WHQL][] `virtio` drivers for Windows, extracted from [RockyLinux][] repositories.

## Build

- Though build can be performed on a Linux machine or in WSL, Verification requires Windows host.
- Building will extract and save ISO file to `docker/build/virtio-win.iso`

    ```console
    make build
    ```

### Signature verification (Requires Windows)

- Mount ISO (Must be run from Elevated PowerShell)
    ```powershell
    Mount-DiskImage -StorageType ISO -ImagePath virtio-win.iso
    ```
- Get Drive letter of mounted ISO
    ```powershell
    $DriveLetter = (Get-DiskImage virtio-win.iso | Get-Volume).DriveLetter
    ```
- Verifying signatures of all the drivers and executables.
    ```powershell
    .\scripts\verify.ps1 -BasePath $DriveLetter:\
    ```

[WHQL]: https://docs.microsoft.com/en-us/windows-hardware/drivers/install/whql-release-signature
[RockyLinux]: https://rockylinux.org
