# Win7 Powershell script to resize Minecraft to 1280x720 (HD for fraps youtube capture)

# use by typing the following at a command prompt:
# > PowerShell -ExecutionPolicy Bypass -File minecraft-sethd.ps1


# refs:
# http://stackoverflow.com/questions/2556872/how-to-set-foreground-window-from-powershell-event-subscriber-action
# http://richardspowershellblog.wordpress.com/2011/07/23/moving-windows/
# http://www.suite101.com/content/client-area-size-with-movewindow-a17846


Add-Type @"
  using System;
  using System.Runtime.InteropServices;

  public class Win32 {
    [DllImport("user32.dll")]
    [return: MarshalAs(UnmanagedType.Bool)]
    public static extern bool GetWindowRect(IntPtr hWnd, out RECT lpRect);

    [DllImport("user32.dll")]
    [return: MarshalAs(UnmanagedType.Bool)]
    public static extern bool GetClientRect(IntPtr hWnd, out RECT lpRect);

    [DllImport("user32.dll")]
    [return: MarshalAs(UnmanagedType.Bool)]
    public static extern bool MoveWindow(IntPtr hWnd, int X, int Y, int nWidth, int nHeight, bool bRepaint);
  }

  public struct RECT
  {
    public int Left;        // x position of upper-left corner
    public int Top;         // y position of upper-left corner
    public int Right;       // x position of lower-right corner
    public int Bottom;      // y position of lower-right corner
  }

"@


$rcWindow = New-Object RECT
$rcClient = New-Object RECT
$Left = 0;
$Top = 0;
$screen = Get-WmiObject -Class Win32_DesktopMonitor | Select-Object ScreenWidth,ScreenHeight

(Get-Process |where {$_.mainWindowTItle -like 'P.I*'}).MainWindowHandle |ForEach-Object {

$h = $_

[Win32]::GetWindowRect($h,[ref]$rcWindow)
[Win32]::GetClientRect($h,[ref]$rcClient)

$width = $screen.ScreenWidth / 3
$height = $screen.ScreenHeight /3

$dx = ($rcWindow.Right - $rcWindow.Left) - $rcClient.Right
$dy = ($rcWindow.Bottom - $rcWindow.Top) - $rcClient.Bottom


[Win32]::MoveWindow($h, $Left, $Top, $width, $height, $true)

$Left += $width
if($Left -gt $screen.ScreenWidth * 2){
        $Top +=$height
        $Left = 0
}
}