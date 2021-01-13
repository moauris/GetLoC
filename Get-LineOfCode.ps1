param(
    [CmdletBinding()]
    [Parameter(
        ParameterSetName='Name1')]
        [string]$TargetDir
)

### If the $TargetDir is not supplied, use current dir
if ($TargetDir.Length -eq 0) {
    $TargetDir = Get-Location | `
        Select-Object -ExpandProperty Path | Convert-Path;
    Write-Debug "Path not supplied";

}
else {
    Write-Debug "Path supplied, judging if valid.";
    if (!(Test-Path $TargetDir)) {
        Write-Error("ERROR: $TargetDir is NOT a valid Path");
    }
}
Write-Debug "Executing Query Command in Dir: $TargetDir";

### Splatting to get childitems that ends with *.cs
$GetChildSplatter = @{
    LiteralPath = $TargetDir
    Recurse = $true
    Depth = 2
    File = $true
    Filter = '*.cs'
}

$dirs = Get-ChildItem @GetChildSplatter;
$paths = @();
$loc = @();
$MaxCount = 0;
foreach ($dir in $dirs) {
    #Get-ChildItem $dir -Filter *.cs;
    #Write-Debug "Printing $dir"
    $path = $dir | Select-Object -ExpandProperty FullName;
    $paths += $path;
    $lines = Get-Content $path | Measure-Object -Line | Select-Object -ExpandProperty Lines
    $loc += $lines;
    $MaxCount = [Math]::Max($MaxCount, $lines);
    ##$output.[PSCustomObject]@{
    ##    Path = Split-Path $path -Leaf
    ##    LoC = $lines
    ##}
}
Write-Debug "The Max Count is $MaxCount";
for ($i = 0; $i -lt $paths.Count; $i++) {
    [int] $percent = [int]$loc[$i] * 100 / [int]$MaxCount;
    #Write-Debug "The Percentage is $percent";
    if ($percent -lt 1) {
        $histoString = '.';
    }
    else {
        $histoString = [String]::New('|', $percent)
    }
    $Parent = Split-Path $paths[$i] -Parent;
    
    $Parent = $Parent.Replace($TargetDir, "..");

    $Leaf = Split-Path $paths[$i] -Leaf;
    [PSCustomObject]@{
        Parent = $Parent
        Filename = $Leaf
        Lines = $loc[$i]
        Histo = $histoString
    }
}
