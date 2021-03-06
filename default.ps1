properties {
  $base_dir = Resolve-Path .
  $build_dir = "$base_dir\build\"
  $libs_dir = "$base_dir\Libs"
  $packages_dir = "$base_dir\packages"
  $output_dir = "$base_dir\output\"
  $sln = "$base_dir\NCommon.build"
  $build_config = "release"
  $tools_dir = "$base_dir\Tools\"
  $pacakges_dir = "$base_dir\packages"
  $test_runner = "$packages_dir\NUnit.2.5.10.11092\tools\nunit-console.exe"
  $version = "1.2"
}

$framework = "4.0"

Task default -depends debug

Task Clean {
    remove-item -force -recurse $build_dir -ErrorAction SilentlyContinue
    remove-item -force -recurse $output_dir -ErrorAction SilentlyContinue
}

Task Init -depends Clean {
    Generate-AssemblyInfo `
        -file "$base_dir\CommonAssemblyInfo.cs" `
        -product "NCommon Framework $version" `
        -copyright "Ritesh Rao 2009 - 2011" `
        -version $version `
        -clsCompliant "false"

    new-item $build_dir -itemType directory -ErrorAction SilentlyContinue
    
    foreach($file in Get-ChildItem -Include 'packages.config' -Recurse) {
        Write-Host "Installing packages from $file"
        exec {Tools\NuGet.exe install -OutputDirectory $packages_dir $file.FullName}
    }
    Write-Host "Finished initializing build."
}

Task Compile -depends Init {
    
    Write-Host "Building $sln for Net40"
    exec {msbuild $sln /verbosity:minimal "/p:OutDir=$build_dir\Net40\" "/p:Config=$build_config"`
                                    "/p:TargetFrameworkVersion=v4.0" "/p:ToolsVersion=v4.0" "/p:IncludeTests=true" /nologo}

    Write-Host "Building $sln for Net35"
    exec {msbuild $sln /verbosity:minimal "/p:OutDir=$build_dir\Net35\" "/p:Config=$build_config"`
                                    "/p:TargetFrameworkVersion=v3.5" "/p:ToolsVersion=v3.5" "/p:DefineConstants=EF_1_0" /nologo}
}

Task Test -depends Compile {
    Write-Host "Running tests for NCommon.Tests.dll"
    exec {&$test_runner /nologo "$build_dir\Net40\NCommon.Tests.dll" /framework:4.0.30319} "Tests for NCommon.Tests.dll failed!"

    Write-Host "Running tests for NCommon.Db4o.Tests.dll"
    exec {&$test_runner /nologo "$build_dir\Net40\NCommon.Db4o.Tests.dll" /framework:4.0.30319} "Tests for NCommon.Db4o.Tests.dll failed!"

    Write-Host "Running tests for NCommon.EntityFramework.Tests.dll"
    exec {&$test_runner /nologo "$build_dir\Net40\NCommon.EntityFramework.Tests.dll" /framework:4.0.30319} "Tests for NCommon.EntityFramework.Tests.dll failed!"

    Write-Host "Running tests for NCommon.EntityFramework4.Tests.dll"
    exec {&$test_runner /nologo "$build_dir\Net40\NCommon.EntityFramework4.Tests.dll" /framework:4.0.30319} "Tests for NCommon.EntityFramework4.Tests.dll failed!"

    Write-Host "Running tests for NCommon.LinqToSql.Tests.dll"
    exec {&$test_runner /nologo "$build_dir\Net40\NCommon.LinqToSql.Tests.dll" /framework:4.0.30319} "Tests for NCommon.LinqToSql.Tests.dll failed!"

    Write-Host "Running tests for NCommon.NHibernate.Tests.dll"
    exec {&$test_runner /nologo "$build_dir\Net40\NCommon.NHibernate.Tests.dll" /framework:4.0.30319} "Tests for NCommon.NHibernate.Tests.dll failed!"

    Write-Host "Running tests for NCommon.ContainerAdapters.Tests.dll"
    exec {&$test_runner /nologo "$build_dir\Net40\NCommon.ContainerAdapters.Tests.dll" /framework:4.0.30319} "Tests for NCommon.ContainerAdapters.Tests.dll failed!"

    Write-Host "Running tests for NCommon.Mvc.Tests.dll"
    exec {&$test_runner /nologo "$build_dir\Net40\NCommon.Mvc.Tests.dll" /framework:4.0.30319} "Tests for NCommon.Mvc.Tests.dll failed!"
}

Task debug {
    $build_config = "Debug"
    ExecuteTask Compile
}

Task release {
    $build_config = "Release"
    ExecuteTask Compile

    new-item $output_dir -itemType directory

    Create-PackageFolder -id "NCommon" -projectPath "$base_dir\NCommon\src\"
    Copy-PackageLib -id "NCommon" -lib "NCommon.dll"

    Create-PackageFolder -id "NCommon.ContainerAdapter.Autofac" -projectPath "$base_dir\NCommon.ContainerAdapters\NCommon.ContainerAdapter.Autofac\"
    Copy-PackageLib -id "NCommon.ContainerAdapter.Autofac" -lib "NCommon.ContainerAdapter.Autofac.dll"
    
    Create-PackageFolder -id "NCommon.ContainerAdapter.CastleWindsor" -projectPath "$base_dir\NCommon.ContainerAdapters\NCommon.ContainerAdapter.CastleWindsor\"
    Copy-PackageLib -id "NCommon.ContainerAdapter.CastleWindsor" -lib "NCommon.ContainerAdapter.CastleWindsor.dll"

    Create-PackageFolder -id "NCommon.ContainerAdapter.Ninject" -projectPath "$base_dir\NCommon.ContainerAdapters\NCommon.ContainerAdapter.Ninject\"
    Copy-PackageLib -id "NCommon.ContainerAdapter.Ninject" -lib "NCommon.ContainerAdapter.Ninject.dll"
    
    Create-PackageFolder -id "NCommon.ContainerAdapter.StructureMap" -projectPath "$base_dir\NCommon.ContainerAdapters\NCommon.ContainerAdapter.StructureMap\"
    Copy-PackageLib -id "NCommon.ContainerAdapter.StructureMap" -lib "NCommon.ContainerAdapter.StructureMap.dll"

    Create-PackageFolder -id "NCommon.ContainerAdapter.Unity" -projectPath "$base_dir\NCommon.ContainerAdapters\NCommon.ContainerAdapter.Unity\"
    Copy-PackageLib -id "NCommon.ContainerAdapter.Unity" -lib "NCommon.ContainerAdapter.Unity.dll"
    
    Create-PackageFolder -id "NCommon.Db4o" -projectPath "$base_dir\NCommon.Db4o\src"
    Copy-PackageLib -id "NCommon.Db4o" -lib "NCommon.Db4o.dll"
    Copy-PackageLib -id "NCommon.Db4o" -lib "Db4objects.Db4o.dll"
    Copy-PackageLib -id "NCommon.Db4o" -lib "Db4objects.Db4o.CS.dll"
    Copy-PackageLib -id "NCommon.Db4o" -lib "Db4objects.Db4o.Data.Services.dll"
    Copy-PackageLib -id "NCommon.Db4o" -lib "Db4objects.Db4o.Linq.dll"

    Create-PackageFolder -id "NCommon.EntityFramework" -projectPath "$base_dir\NCommon.EntityFramework\src"
    Copy-PackageLib -id "NCommon.EntityFramework" -lib "NCommon.EntityFramework.dll"

    Create-PackageFolder -id "NCommon.LinqToSql" -projectPath "$base_dir\NCommon.LinqToSql\src"
    Copy-PackageLib -id "NCommon.LinqToSql" -lib "NCommon.LinqToSql.dll"

    Create-PackageFolder -id "NCommon.NHibernate" -projectPath "$base_dir\NCommon.NHibernate\src"
    Copy-PackageLib -id "NCommon.NHibernate" -lib "NCommon.NHibernate.dll"
    
    Create-PackageFolder -id "NCommon.Mvc" -projectPath "$base_dir\NCommon.Mvc\src"
    Copy-PackageLib -id "NCommon.Mvc" -lib "NCommon.Mvc.dll"
}

Task publish -depends release {
    Generate-Package -id "NCommon"
    Generate-Package -id "NCommon.ContainerAdapter.Autofac"
    Generate-Package -id "NCommon.ContainerAdapter.CastleWindsor"
    Generate-Package -id "NCommon.ContainerAdapter.Ninject"
    Generate-Package -id "NCommon.ContainerAdapter.StructureMap"
    Generate-Package -id "NCommon.ContainerAdapter.Unity"
    Generate-Package -id "NCommon.Db4o"
    Generate-Package -id "NCommon.EntityFramework"
    Generate-Package -id "NCommon.LinqToSql"
    Generate-Package -id "NCommon.NHibernate"
    Generate-Package -id "NCommon.Mvc"

    #Publish-Package -id "NCommon"
    #Publish-Package -id "NCommon.ContainerAdapter.Autofac"
    #Publish-Package -id "NCommon.ContainerAdapter.CastleWindsor"
    Publish-Package -id "NCommon.ContainerAdapter.Ninject"
    Publish-Package -id "NCommon.ContainerAdapter.StructureMap"
    Publish-Package -id "NCommon.ContainerAdapter.Unity"
    Publish-Package -id "NCommon.Db4o"
    Publish-Package -id "NCommon.EntityFramework"
    Publish-Package -id "NCommon.LinqToSql"
    Publish-Package -id "NCommon.NHibernate"
    Publish-Package -id "NCommon.Mvc"
}

function Generate-AssemblyInfo
{
    param(
        [string]$clsCompliant = "true",
        [string]$product,
        [string]$copyright,
        [string]$version,
        [string]$file = $(throw "file is a required parameter.")
    )
    $asmInfo = "using System;
    using System.Reflection;
    using System.Runtime.CompilerServices;
    using System.Runtime.InteropServices;

    [assembly: CLSCompliantAttribute($clsCompliant )]
    [assembly: ComVisibleAttribute(false)]
    [assembly: AssemblyProductAttribute(""$product"")]
    [assembly: AssemblyCopyrightAttribute(""$copyright"")]
    [assembly: AssemblyVersionAttribute(""$version"")]
    [assembly: AssemblyInformationalVersionAttribute(""$version"")]
    [assembly: AssemblyFileVersionAttribute(""$version"")]
    [assembly: AssemblyDelaySignAttribute(false)]
    "

        $dir = [System.IO.Path]::GetDirectoryName($file)
        if ([System.IO.Directory]::Exists($dir) -eq $false)
        {
            Write-Host "Creating directory $dir"
            [System.IO.Directory]::CreateDirectory($dir)
        }
        Write-Host "Generating assembly info file: $file"
        Write-Output $asmInfo > $file
}

function Create-PackageFolder {
    param([string] $id, [string] $projectPath)
    new-item $output_dir\$id -itemType directory
    new-item $output_dir\$id\lib -itemType directory
    new-item $output_dir\$id\lib\Net35 -itemType directory
    new-item $output_dir\$id\lib\Net40 -itemType directory
    copy-item $projectPath\$id.nuspec -destination $output_dir\$id
}

function Copy-PackageLib {
    param([string] $id, [string] $lib)
    copy-item $build_dir\Net35\$lib -destination $output_dir\$id\lib\Net35
    copy-item $build_dir\Net40\$lib -destination $output_dir\$id\lib\Net40
}

function Generate-Package {
    param([string] $id)
    Write-Host "Generating package $id version $version"
    exec {&"$tools_dir\NuGet.exe" pack "$output_dir\$id\$id.nuspec" -Version "$version" -OutputDirectory "$output_dir"}
}

function Publish-Package {
    param([string] $id)
    Write-Host "Pubishing package $id version $version to NuGet gallery"
    exec {&"$tools_dir\NuGet.exe" push "$output_dir\$id.$version.nupkg"}
}