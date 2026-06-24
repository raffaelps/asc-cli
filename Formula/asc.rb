class Asc < Formula
  desc "CLI for the Apple App Store Connect API"
  homepage "https://github.com/raffaelps/asc-cli"
  version "0.2.0"
  license "MIT"

  on_macos do
    # Only Apple Silicon is shipped (GitHub no longer offers Intel macOS runners,
    # and arm64 binaries cannot run on Intel Macs). Intel users get a clear error.
    on_arm do
      url "https://github.com/raffaelps/asc-cli/releases/download/v0.2.0/asc-macos-arm64.tar.gz"
      sha256 "ee887ecc8a921c5239c2063a827b5dac5289c37f83d4a4140e47ccbfbf4b46aa"
    end
  end

  on_linux do
    url "https://github.com/raffaelps/asc-cli/releases/download/v0.2.0/asc-linux-x86_64.tar.gz"
    sha256 "fd047e4b9540d65b40631567f3b11d84342d926726d3c054b903ebf178f09082"
  end

  def install
    bin.install "asc"
  end

  test do
    assert_match "0.2.0", shell_output("#{bin}/asc --version")
  end
end
