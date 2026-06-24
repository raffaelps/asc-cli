class AscCli < Formula
  desc "CLI for the Apple App Store Connect API"
  homepage "https://github.com/raffaelps/asc-cli"
  version "0.3.0"
  license "MIT"

  on_macos do
    # Only Apple Silicon is shipped (GitHub no longer offers Intel macOS runners,
    # and arm64 binaries cannot run on Intel Macs). Intel users get a clear error.
    on_arm do
      url "https://github.com/raffaelps/asc-cli/releases/download/v0.3.0/asc-macos-arm64.tar.gz"
      sha256 "f1df3ae327900398e7bfa66e723606a631e120882140afbf3293d5c2c4980de9"
    end
  end

  on_linux do
    url "https://github.com/raffaelps/asc-cli/releases/download/v0.3.0/asc-linux-x86_64.tar.gz"
    sha256 "27eb5c48883482725c3cc92743da3776a77e0c3451acfa3b5feae0a3b9fdf0ea"
  end

  def install
    bin.install "asc-cli"
  end

  test do
    assert_match "0.3.0", shell_output("#{bin}/asc-cli --version")
  end
end
