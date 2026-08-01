class AscCli < Formula
  desc "CLI for the Apple App Store Connect API"
  homepage "https://github.com/raffaelps/asc-cli"
  version "0.7.1"
  license "MIT"

  on_macos do
    # Only Apple Silicon is shipped (GitHub no longer offers Intel macOS runners,
    # and arm64 binaries cannot run on Intel Macs). Intel users get a clear error.
    on_arm do
      url "https://github.com/raffaelps/asc-cli/releases/download/0.7.1/asc-macos-arm64.tar.gz"
      sha256 "a5656e43c0930ed58f00b4af1e84242bc24c708ae492b2dc9c7b4034d6e8c42c"
    end
  end

  on_linux do
    url "https://github.com/raffaelps/asc-cli/releases/download/0.7.1/asc-linux-x86_64.tar.gz"
    sha256 "da68e5e080fafc94f03807a58abc97b9315bcffea4fe554e3b3bcc3b1cb5e1b7"
  end

  def install
    bin.install "asc-cli"
  end

  test do
    assert_match "0.7.1", shell_output("#{bin}/asc-cli --version")
  end
end
