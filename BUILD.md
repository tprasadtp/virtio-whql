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
