$scripts = @(
	{
		if( [System.Environment]::OSVersion.Version.Build -lt 20000 ) {
			# Windows 10
			Set-ItemProperty -LiteralPath 'Registry::HKU\DefaultUser\Software\Microsoft\Windows\CurrentVersion\Explorer' -Name 'EnableAutoTray' -Type 'DWord' -Value 0 -Force;
		} else {
			# Windows 11
			Register-ScheduledTask -TaskName 'ShowAllTrayIcons' -Xml $(
				Get-Content -LiteralPath "C:\Windows\Setup\Scripts\ShowAllTrayIcons.xml" -Raw;
			);
		}
	};
);

& {
  [float] $complete = 0;
  [float] $increment = 100 / $scripts.Count;
  foreach( $script in $scripts ) {
    Write-Progress -Id 0 -Activity 'Running scripts to modify the default user’’s registry hive. Do not close this window.' -PercentComplete $complete;
    '*** Will now execute command «{0}».' -f $(
      $script.ToString().Trim() -replace '\s+', ' ' -replace '^(.{99})(.+)$', '$1…';
    );
    $start = [datetime]::Now;
    & $script;
    '*** Finished executing command after {0:0} ms.' -f [datetime]::Now.Subtract( $start ).TotalMilliseconds;
    "`r`n" * 3;
    $complete += $increment;
  }
} *>&1 | Out-String -Width 1KB -Stream >> "C:\Windows\Setup\Scripts\DefaultUser.log";