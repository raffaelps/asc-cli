class AscCli < Formula
  desc "CLI for the Apple App Store Connect API"
  homepage "https://github.com/raffaelps/asc-cli"
  version "0.4.0"
  license "MIT"

  on_macos do
    # Only Apple Silicon is shipped (GitHub no longer offers Intel macOS runners,
    # and arm64 binaries cannot run on Intel Macs). Intel users get a clear error.
    on_arm do
      url "https://github.com/raffaelps/asc-cli/releases/download/v0.4.0/asc-macos-arm64.tar.gz"
      sha256 "632b1ac489840ce40b0adfb930f1d314d86bb6cc8d411677cc87030e8b402ee4"
    end
  end

  on_linux do
    url "https://github.com/raffaelps/asc-cli/releases/download/v0.4.0/asc-linux-x86_64.tar.gz"
    sha256 "f338dc3d242e9603b38ab6f90379b7d773a9ec8bff494f8daf1c850a25dc5caa"
  end

  def install
    bin.install "asc-cli"
  end

  test do
    assert_match "0.4.0", shell_output("#{bin}/asc-cli --version")
  end
end
