class AscCli < Formula
  desc "CLI for the Apple App Store Connect API"
  homepage "https://github.com/raffaelps/asc-cli"
  version "0.8.0"
  license "MIT"

  on_macos do
    # Only Apple Silicon is shipped (GitHub no longer offers Intel macOS runners,
    # and arm64 binaries cannot run on Intel Macs). Intel users get a clear error.
    on_arm do
      url "https://github.com/raffaelps/asc-cli/releases/download/0.8.0/asc-macos-arm64.tar.gz"
      sha256 "1913af01ead23cb15797a44e1cb44b746b6ba0f4e194f56dc93a6da62c79df86"
    end
  end

  on_linux do
    url "https://github.com/raffaelps/asc-cli/releases/download/0.8.0/asc-linux-x86_64.tar.gz"
    sha256 "0d4be6b7ec38f76d0127663bc8e220f98002ecfbea7ba713bfea3595d3700e34"
  end

  def install
    bin.install "asc-cli"
  end

  test do
    assert_match "0.8.0", shell_output("#{bin}/asc-cli --version")
  end
end
