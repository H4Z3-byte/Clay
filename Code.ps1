Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass -Force

if (-not ([System.Management.Automation.PSTypeName]'WinAPI2').Type) {
Add-Type @"
using System;
using System.Runtime.InteropServices;

public class WinAPI2 {
    [DllImport("user32.dll")]
    public static extern IntPtr GetForegroundWindow();

    [DllImport("user32.dll")]
    public static extern bool GetWindowRect(IntPtr hWnd, out RECT lpRect);

    [DllImport("user32.dll")]
    public static extern bool MoveWindow(
        IntPtr hWnd,
        int X,
        int Y,
        int nWidth,
        int nHeight,
        bool bRepaint
    );

    public struct RECT {
        public int Left;
        public int Top;
        public int Right;
        public int Bottom;
    }
}
"@
}

$maxShake = 150
$speedMs = 3

while ($true) {

    $hWnd = [WinAPI2]::GetForegroundWindow()
    if ($hWnd -eq [IntPtr]::Zero) { continue }

    $r = New-Object WinAPI2+RECT
    if (-not [WinAPI2]::GetWindowRect($hWnd, [ref]$r)) { continue }

    $w = $r.Right - $r.Left
    $h = $r.Bottom - $r.Top

    $dx = Get-Random -Minimum (-$maxShake) -Maximum $maxShake
    $dy = Get-Random -Minimum (-$maxShake) -Maximum $maxShake

    [WinAPI2]::MoveWindow(
        $hWnd,
        $r.Left + $dx,
        $r.Top + $dy,
        $w,
        $h,
        $true
    )

    Start-Sleep -Milliseconds $speedMs
}
