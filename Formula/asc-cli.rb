class AscCli < Formula
  desc "CLI for the Apple App Store Connect API"
  homepage "https://github.com/raffaelps/asc-cli"
  version "0.6.0"
  license "MIT"

  on_macos do
    # Only Apple Silicon is shipped (GitHub no longer offers Intel macOS runners,
    # and arm64 binaries cannot run on Intel Macs). Intel users get a clear error.
    on_arm do
      url "https://github.com/raffaelps/asc-cli/releases/download/v0.6.0/asc-macos-arm64.tar.gz"
      sha256 "ba02b8ce41936c029d15696875ade5290ecaeae220e0f461255252003c33e5b9"
    end
  end

  on_linux do
    url "https://github.com/raffaelps/asc-cli/releases/download/v0.6.0/asc-linux-x86_64.tar.gz"
    sha256 "8edaab055e9864797f187573f3ca77d8388a8454e7bb6e88601f0e07b051a5bb"
  end

  def install
    bin.install "asc-cli"
  end

  test do
    assert_match "0.6.0", shell_output("#{bin}/asc-cli --version")
  end
end
