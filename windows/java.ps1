Write-Output "現在のJAVA_HOMEを確認します..."
Write-Output $ENV:JAVA_HOME

scoop install adopt8-hotspot
scoop install adopt11-hotspot
scoop reset adopt11-hotspot

Write-Output "変更後のJAVA_HOMEを確認します..."
Write-Output $ENV:JAVA_HOME
