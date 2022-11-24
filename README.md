# VirtIO Drivers for Windows

[![build](https://github.com/tprasadtp/virtio-whql/actions/workflows/build.yml/badge.svg)](https://github.com/tprasadtp/virtio-whql/actions/workflows/build.yml)
[![upstream-pkg](https://img.shields.io/badge/upstream-virtio--win-10B981?logo=rockylinux)](https://git.rockylinux.org/staging/rpms/virtio-win)
[![upstream-pkg](https://img.shields.io/badge/changelog-virtio--win-10B981?logo=rockylinux)](https://git.rockylinux.org/staging/rpms/virtio-win/-/blob/r8/SPECS/virtio-win.spec#L280)
[![releases](https://img.shields.io/github/v/tag/tprasadtp/virtio-whql?label=release&sort=semver&logo=semver&color=7f50a6&labelColor=3a3a3a)](https://github.com/tprasadtp/virtio-whql/releases/latest)

VirtIO drivers for Windows, extracted from [RockyLinux][] repositories.

## Release Assets

| Asset Name | Description
| --- | ---
| [virtio-win-guest-tools.exe][installer], [SHA256][installer-hash] | VirtIO driver and agent installer. This is the only thing you might actually need most of the times.
| [virtio-win.iso][virtio-win-iso], [SHA256][virtio-win-iso-hash] | VirtIO drivers ISO from upstream virtio-win package.

> Checksums for assets can be obtained by appending suffix (`.sha256`) to the filename.

## Signature verification (Requires Windows)

Verification script is provided as runs as part of CI workflow.

```powershell
.\scripts\verify.ps1 -Path <PATH_TO_ISO_FILE>
```

## Automatic Updates

Repository should automatically update latest release available from RockyLinux repositories.

[RockyLinux]: https://rockylinux.org
[installer]: https://github.com/tprasadtp/virtio-whql/releases/latest/download/virtio-win-guest-tools.exe
[installer-hash]: https://github.com/tprasadtp/virtio-whql/releases/latest/download/virtio-win-guest-tools.exe.sha256
[virtio-win-iso]: https://github.com/tprasadtp/virtio-whql/releases/latest/download/virtio-win.iso
[virtio-win-iso-hash]: https://github.com/tprasadtp/virtio-whql/releases/latest/download/virtio-win.iso.sha256
