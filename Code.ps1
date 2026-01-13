Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass -Force

if (-not ([System.Management.Automation.PSTypeName]'WinAPI2').Type) {
    Add-Type @"
using System;
using System.Text;
using System.Runtime.InteropServices;

public class WinAPI2 {
    [StructLayout(LayoutKind.Sequential)]
    public struct RECT {
        public int Left;
        public int Top;
        public int Right;
        public int Bottom;
    }

    public delegate bool EnumWindowsProc(IntPtr hWnd, IntPtr lParam);

    [DllImport("user32.dll")]
    [return: MarshalAs(UnmanagedType.Bool)]
    public static extern bool EnumWindows(EnumWindowsProc lpEnumFunc, IntPtr lParam);

    [DllImport("user32.dll")]
    [return: MarshalAs(UnmanagedType.Bool)]
    public static extern bool GetWindowRect(IntPtr hWnd, out RECT lpRect);

    [DllImport("user32.dll")]
    [return: MarshalAs(UnmanagedType.Bool)]
    public static extern bool IsWindowVisible(IntPtr hWnd);

    [DllImport("user32.dll")]
    [return: MarshalAs(UnmanagedType.Bool)]
    public static extern bool MoveWindow(IntPtr hWnd, int X, int Y, int nWidth, int nHeight, bool bRepaint);
}
"@
}

$maxShake = 150
$speedMs = 3

# Funzione per enumerare tutte le finestre
function Get-AllWindows {
    $windows = @()
    $callback = [WinAPI2+EnumWindowsProc]{
        param($hWnd, $lParam)
        if ([WinAPI2]::IsWindowVisible($hWnd)) {
            $windows += $hWnd
        }
        return $true
    }
    [WinAPI2]::EnumWindows($callback, [IntPtr]::Zero) | Out-Null
    return $windows
}

while ($true) {
    $allWindows = Get-AllWindows
    foreach ($hWnd in $allWindows) {
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
    }
    Start-Sleep -Milliseconds $speedMs
}
