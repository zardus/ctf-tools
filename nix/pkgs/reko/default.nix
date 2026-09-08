{
  lib,
  stdenvNoCC,
  fetchurl,
  unzip,
  makeWrapper,
  dotnetCorePackages,
}:

let
  version = "0.12.4";
  revision = "aa02002c3befa8a54ad71de5c717df80944fdf2a";
  shortRevision = "aa02002c3b";

  dotnet-sdk = dotnetCorePackages.sdk_8_0;
  dotnet-runtime = dotnetCorePackages.runtime_8_0;

  runtimeRid =
    if stdenvNoCC.hostPlatform.isx86_64 then
      "linux-x64"
    else if stdenvNoCC.hostPlatform.isAarch64 then
      "linux-arm64"
    else
      throw "reko: unsupported platform ${stdenvNoCC.hostPlatform.system}";

  sourceUrl = "https://raw.githubusercontent.com/uxmal/reko/${revision}/src/Drivers/CmdLine";

  copying = fetchurl {
    url = "https://raw.githubusercontent.com/uxmal/reko/${revision}/COPYING";
    hash = "sha256-gXf5dRMhNSbfLPYYTY/5hsZ1r7UU1OaKQEAQUhuIBkM=";
  };

  cmdLineDriver = fetchurl {
    url = "${sourceUrl}/CmdLineDriver.cs";
    hash = "sha256-pBS/wHtDQzZBmmRHDu+B9L0BK07/gdSmhONzY0BMYDs=";
  };
  cmdLineListener = fetchurl {
    url = "${sourceUrl}/CmdLineListener.cs";
    hash = "sha256-FZCTUAnHPMIYeEUlNmCVtMMtV4b09o5zt7DUOoisDsM=";
  };
  cmdLineOptions = fetchurl {
    url = "${sourceUrl}/CmdLineOptions.cs";
    hash = "sha256-sRgoD0Um2fbpnM38z7ruaby2/p6dmHf3A0GMvf/dCTI=";
  };
  cmdOutputService = fetchurl {
    url = "${sourceUrl}/CmdOutputService.cs";
    hash = "sha256-7E2Ejfu09H4kfg7pmAj1A33KXzxjzyq7o1tig1tejeQ=";
  };
  majorCommand = fetchurl {
    url = "${sourceUrl}/MajorCommand.cs";
    hash = "sha256-6eQCfcDtTuDPSmVfvTY+GQjE5DQ/FNTNi7odBlwvpkI=";
  };
  assemblyInfo = fetchurl {
    url = "${sourceUrl}/Properties/AssemblyInfo.cs";
    hash = "sha256-q+GiOOLTLKE+JWvz7BMa9WDLfuBiiELKgHhQqkvbEY4=";
  };
in
stdenvNoCC.mkDerivation {
  pname = "reko";
  inherit version;

  src = fetchurl {
    url = "https://github.com/uxmal/reko/releases/download/version-${version}/CmdLine-${version}-x64-${shortRevision}.zip";
    hash = "sha256-nxDR/zD3oPzTvIbiG1DmdvUgAi8fREPq1GZAx3172oY=";
  };

  strictDeps = true;

  nativeBuildInputs = [
    unzip
    makeWrapper
    dotnet-sdk
  ];

  # The official CLI archive contains the full managed plug-in set, but its
  # tiny entry assembly is marked x86_64. Recompile only that entry assembly
  # from the matching release sources so the package also works on aarch64.
  # This has no NuGet dependencies; all build tools come from nixpkgs.
  unpackPhase = ''
    runHook preUnpack
    mkdir release
    unzip -q "$src" -d release
    runHook postUnpack
  '';

  buildPhase = ''
    runHook preBuild

    mkdir -p cli/Properties
    cp ${cmdLineDriver} cli/CmdLineDriver.cs
    cp ${cmdLineListener} cli/CmdLineListener.cs
    cp ${cmdLineOptions} cli/CmdLineOptions.cs
    cp ${cmdOutputService} cli/CmdOutputService.cs
    cp ${majorCommand} cli/MajorCommand.cs
    cp ${assemblyInfo} cli/Properties/AssemblyInfo.cs

    cat > cli/reko.csproj <<'EOF'
    <Project Sdk="Microsoft.NET.Sdk">
      <PropertyGroup>
        <TargetFramework>net8.0</TargetFramework>
        <OutputType>Exe</OutputType>
        <AssemblyName>reko</AssemblyName>
        <RootNamespace>Reko.CmdLine</RootNamespace>
        <GenerateAssemblyInfo>false</GenerateAssemblyInfo>
        <Nullable>enable</Nullable>
        <UseAppHost>false</UseAppHost>
        <PlatformTarget>AnyCPU</PlatformTarget>
      </PropertyGroup>
      <ItemGroup>
        <Reference Include="Reko.Core">
          <HintPath>../release/Reko.Core.dll</HintPath>
        </Reference>
        <Reference Include="Reko.Decompiler">
          <HintPath>../release/Reko.Decompiler.dll</HintPath>
        </Reference>
        <Reference Include="K4os.Compression.LZ4">
          <HintPath>../release/K4os.Compression.LZ4.dll</HintPath>
        </Reference>
      </ItemGroup>
    </Project>
    EOF

    cat > NuGet.Config <<'EOF'
    <?xml version="1.0" encoding="utf-8"?>
    <configuration>
      <packageSources><clear /></packageSources>
    </configuration>
    EOF

    export DOTNET_CLI_HOME="$TMPDIR/dotnet-home"
    export NUGET_PACKAGES="$TMPDIR/nuget-packages"
    export DOTNET_NOLOGO=1
    export DOTNET_CLI_TELEMETRY_OPTOUT=1

    dotnet restore cli/reko.csproj --configfile NuGet.Config
    dotnet build cli/reko.csproj \
      --configuration Release \
      --no-restore \
      -p:ContinuousIntegrationBuild=true \
      -p:Deterministic=true

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p "$out/lib/reko" "$out/bin"
    cp -r release/. "$out/lib/reko/"
    install -Dm644 ${copying} "$out/share/licenses/reko/COPYING"
    cp cli/bin/Release/net8.0/reko.dll "$out/lib/reko/reko.dll"
    cp cli/bin/Release/net8.0/reko.deps.json "$out/lib/reko/reko.deps.json"
    cp cli/bin/Release/net8.0/reko.runtimeconfig.json \
      "$out/lib/reko/reko.runtimeconfig.json"

    # Drop Windows launchers/native libraries, debug symbols, and the empty
    # native-proxy assembly. Reko 0.12.4 uses its managed ARM implementation.
    find "$out/lib/reko" -maxdepth 1 -type f \
      \( -name '*.exe' -o -name '*.pdb' \) -delete
    rm -f \
      "$out/lib/reko/ArmNative.dll" \
      "$out/lib/reko/capstone.dll" \
      "$out/lib/reko/decompile.dll" \
      "$out/lib/reko/decompile.runtimeconfig.json" \
      "$out/lib/reko/NativeProxy.dll"

    # Mono.Unix ships native assets for many operating systems. Retain the
    # one matching the Nix host instead of caching every foreign binary.
    test -s "$out/lib/reko/runtimes/${runtimeRid}/native/libMono.Unix.so"
    find "$out/lib/reko/runtimes" -mindepth 1 -maxdepth 1 \
      -type d ! -name '${runtimeRid}' -exec rm -r {} +

    makeWrapper "${dotnet-runtime}/bin/dotnet" "$out/bin/reko" \
      --set DOTNET_ROOT "${dotnet-runtime}/share/dotnet" \
      --add-flags "$out/lib/reko/reko.dll"

    runHook postInstall
  '';

  doInstallCheck = true;
  installCheckPhase = ''
    runHook preInstallCheck

    $out/bin/reko --version | grep -F "Reko decompiler version ${version}"
    $out/bin/reko --help | grep -F "reko decompile"

    test_dir="$(mktemp -d)"
    printf '\270\052\000\000\000\303' > "$test_dir/tiny.bin"
    (
      cd "$test_dir"
      $out/bin/reko decompile \
        --arch x86-protected-32 --base 1000 --entry 1000 tiny.bin
    )

    test -s "$test_dir/tiny.reko/tiny_code.asm"
    test -s "$test_dir/tiny.reko/tiny_code.c"
    grep -F "eax,2Ah" "$test_dir/tiny.reko/tiny_code.asm"
    grep -F "Reko decompiler version ${version}" \
      "$test_dir/tiny.reko/tiny_code.c"

    # The release's managed ARM implementation must remain usable after the
    # Windows-only native helper is removed.
    printf '\052\000\240\343\036\377\057\341' > "$test_dir/tiny-arm.bin"
    (
      cd "$test_dir"
      $out/bin/reko decompile \
        --arch arm --base 1000 --entry 1000 tiny-arm.bin
    )
    test -s "$test_dir/tiny-arm.reko/tiny-arm_code.asm"
    grep -F "r0,#&2A" "$test_dir/tiny-arm.reko/tiny-arm_code.asm"

    runHook postInstallCheck
  '';

  meta = with lib; {
    description = "General-purpose machine-code decompiler";
    homepage = "https://github.com/uxmal/reko";
    changelog = "https://github.com/uxmal/reko/releases/tag/version-${version}";
    license = licenses.gpl2Plus;
    platforms = [
      "x86_64-linux"
      "aarch64-linux"
    ];
    mainProgram = "reko";
  };
}
