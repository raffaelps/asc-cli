class AscCli < Formula
  desc "CLI for the Apple App Store Connect API"
  homepage "https://github.com/raffaelps/asc-cli"
  version "0.9.0"
  license "MIT"

  on_macos do
    # Only Apple Silicon is shipped (GitHub no longer offers Intel macOS runners,
    # and arm64 binaries cannot run on Intel Macs). Intel users get a clear error.
    on_arm do
      url "https://github.com/raffaelps/asc-cli/releases/download/0.9.0/asc-macos-arm64.tar.gz"
      sha256 "ce8b22720589ce6fbe5febaa8348a19da1670859184a5f762182c1580816c18e"
    end
  end

  on_linux do
    url "https://github.com/raffaelps/asc-cli/releases/download/0.9.0/asc-linux-x86_64.tar.gz"
    sha256 "a1999ccf6196a13279f46b0e769416d507755650aa48663cec0205b8333ebc42"
  end

  def install
    bin.install "asc-cli"
  end

  test do
    assert_match "0.9.0", shell_output("#{bin}/asc-cli --version")
  end
end
