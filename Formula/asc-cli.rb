class AscCli < Formula
  desc "CLI for the Apple App Store Connect API"
  homepage "https://github.com/raffaelps/asc-cli"
  version "0.5.1"
  license "MIT"

  on_macos do
    # Only Apple Silicon is shipped (GitHub no longer offers Intel macOS runners,
    # and arm64 binaries cannot run on Intel Macs). Intel users get a clear error.
    on_arm do
      url "https://github.com/raffaelps/asc-cli/releases/download/v0.5.1/asc-macos-arm64.tar.gz"
      sha256 "a446872e5c65599cc1733ac60fc970b24265ed697710459a443504cd11f9ef15"
    end
  end

  on_linux do
    url "https://github.com/raffaelps/asc-cli/releases/download/v0.5.1/asc-linux-x86_64.tar.gz"
    sha256 "2b4dcc103c86e626a21adc2e01093364c7dbf6e9d8e6a82fc191ae31a4dbf063"
  end

  def install
    bin.install "asc-cli"
  end

  test do
    assert_match "0.5.1", shell_output("#{bin}/asc-cli --version")
  end
end
