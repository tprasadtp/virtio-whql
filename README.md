# VirtIO Drivers for Windows

[![build](https://github.com/tprasadtp/virtio-whql/actions/workflows/build.yml/badge.svg)](https://github.com/tprasadtp/virtio-whql/actions/workflows/build.yml)
[![releases](https://img.shields.io/github/v/tag/tprasadtp/virtio-whql?label=release&sort=semver&logo=semver&color=7f50a6&labelColor=3a3a3a)](https://github.com/tprasadtp/virtio-whql/releases/latest)

VirtIO drivers for Windows, extracted from RHEL repositories.

## Release Assets

> **Warning**
>
> WHQL assets are **NOT** available for **PUBLIC** downloads unless
> you have access tokens. Access tokens can be specified via `token`
> query parameter or `X-VirtIO-Token` header.

| Asset Name | URL (Requires Token) | Description
| --- | --- | ---
| `virtio-win-guest-tools.exe` | https://virtio.prasadt.com/installer | VirtIO driver and agent installer.
| `virtio-winpe.iso` | https://virtio.prasadt.com/winpe-iso | VirtIO Win PE ISO with drivers for unattended install.
| `virtio-win.iso` | https://virtio.prasadt.com/iso | VirtIO ISO with all drivers

## Signature verification (Requires Windows)

Verification script is provided and runs as part of CI workflow.

```powershell
.\scripts\verify.ps1 -Path <PATH_TO_ISO_FILE>
```

## Automatic Updates

Repository should automatically update latest release available from RHEL repositories.
