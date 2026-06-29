class AscCli < Formula
  desc "CLI for the Apple App Store Connect API"
  homepage "https://github.com/raffaelps/asc-cli"
  version "0.5.0"
  license "MIT"

  on_macos do
    # Only Apple Silicon is shipped (GitHub no longer offers Intel macOS runners,
    # and arm64 binaries cannot run on Intel Macs). Intel users get a clear error.
    on_arm do
      url "https://github.com/raffaelps/asc-cli/releases/download/v0.5.0/asc-macos-arm64.tar.gz"
      sha256 "32746c3dbb84efa733130dad972e17e63fde4bdfb8742bb06cd2492eb07cb244"
    end
  end

  on_linux do
    url "https://github.com/raffaelps/asc-cli/releases/download/v0.5.0/asc-linux-x86_64.tar.gz"
    sha256 "20f9e842c3d85cd6dcbbae21c21e25e19d1a26ba4a1c07380f44f49c5c27d835"
  end

  def install
    bin.install "asc-cli"
  end

  test do
    assert_match "0.5.0", shell_output("#{bin}/asc-cli --version")
  end
end
