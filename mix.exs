defmodule NervesSystemNexus7.MixProject do
  use Mix.Project

  @app :nerves_system_nexus7
  @version Path.join(__DIR__, "VERSION")
           |> File.read!()
           |> String.trim()

  def project do
    [
      app: @app,
      version: @version,
      elixir: "~> 1.17",
      compilers: Mix.compilers() ++ [:nerves_package],
      nerves_package: nerves_package(),
      description: description(),
      package: package(),
      deps: deps(),
      aliases: [loadconfig: [&bootstrap/1]]
    ]
  end

  def application do
    []
  end

  defp bootstrap(args) do
    set_target()
    Application.start(:nerves_bootstrap)
    Mix.Task.run("loadconfig", args)
  end

  defp nerves_package do
    [
      type: :system,
      # No prebuilt artifacts are published; the system is always built locally.
      artifact_sites: [],
      build_runner_opts: build_runner_opts(),
      platform: Nerves.System.BR,
      platform_config: [
        defconfig: "nerves_defconfig"
      ],
      env: [
        {"TARGET_ARCH", "arm"},
        {"TARGET_CPU", "cortex_a9"},
        {"TARGET_OS", "linux"},
        {"TARGET_ABI", "gnueabihf"},
        {"TARGET_GCC_FLAGS",
         "-mabi=aapcs-linux -mfpu=neon -marm -fstack-protector-strong -mfloat-abi=hard -mcpu=cortex-a9 -fPIE -pie -Wl,-z,now -Wl,-z,relro"}
      ],
      checksum: package_files()
    ]
  end

  defp deps do
    [
      {:nerves, "~> 1.11 or ~> 2.0 or ~> 2.0.0-dev", runtime: false},
      {:nerves_system_br, "1.34.4", runtime: false},
      {:nerves_toolchain_armv7_nerves_linux_gnueabihf, "~> 15.3.0", runtime: false}
    ]
  end

  defp description do
    """
    Nerves System - ASUS/Google Nexus 7 (2012, grouper/tilapia, Tegra 3) with mainline U-Boot
    """
  end

  defp package do
    [
      files: package_files(),
      licenses: ["GPL-2.0-only", "GPL-2.0-or-later"]
    ]
  end

  defp package_files do
    [
      "board",
      "fwup_include",
      "linux",
      "rootfs_overlay",
      "busybox.fragment",
      "fwup-ops.conf",
      "fwup.conf",
      "LICENSES/*",
      "mix.exs",
      "nerves_defconfig",
      "post-build.sh",
      "post-createfs.sh",
      "README.md",
      "REUSE.toml",
      "VERSION"
    ]
  end

  defp build_runner_opts() do
    # Download source files first to get download errors right away.
    [make_args: primary_site() ++ ["source", "all", "legal-info"]]
  end

  defp primary_site() do
    case System.get_env("BR2_PRIMARY_SITE") do
      nil -> []
      primary_site -> ["BR2_PRIMARY_SITE=#{primary_site}"]
    end
  end

  defp set_target() do
    if function_exported?(Mix, :target, 1) do
      apply(Mix, :target, [:target])
    else
      System.put_env("MIX_TARGET", "target")
    end
  end
end
