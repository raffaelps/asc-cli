class AscCli < Formula
  desc "CLI for the Apple App Store Connect API"
  homepage "https://github.com/raffaelps/asc-cli"
  version "0.4.1"
  license "MIT"

  on_macos do
    # Only Apple Silicon is shipped (GitHub no longer offers Intel macOS runners,
    # and arm64 binaries cannot run on Intel Macs). Intel users get a clear error.
    on_arm do
      url "https://github.com/raffaelps/asc-cli/releases/download/v0.4.1/asc-macos-arm64.tar.gz"
      sha256 "b638867665af030a853c5a312114ada5ecd07e90f197efc587d90ad6d1365c48"
    end
  end

  on_linux do
    url "https://github.com/raffaelps/asc-cli/releases/download/v0.4.1/asc-linux-x86_64.tar.gz"
    sha256 "7719e3341585a8537f97c5f12b5d9a652b8d24ef26eed73adcec414624811e6f"
  end

  def install
    bin.install "asc-cli"
  end

  test do
    assert_match "0.4.1", shell_output("#{bin}/asc-cli --version")
  end
end
