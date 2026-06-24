class Asc < Formula
  desc "CLI for the Apple App Store Connect API"
  homepage "https://github.com/raffaelps/asc-cli"
  version "0.1.0"
  license "MIT"

  on_macos do
    # Only Apple Silicon is shipped (GitHub no longer offers Intel macOS runners,
    # and arm64 binaries cannot run on Intel Macs). Intel users get a clear error.
    on_arm do
      url "https://github.com/raffaelps/asc-cli/releases/download/v0.1.0/asc-macos-arm64.tar.gz"
      sha256 "523c9f914c573bf2c2e13953f64b751897aa27c2c5301bec72192a6b0ea725ae"
    end
  end

  on_linux do
    url "https://github.com/raffaelps/asc-cli/releases/download/v0.1.0/asc-linux-x86_64.tar.gz"
    sha256 "d085caae2bc1ff72f3ca99d9facd61613b1d5a7587fe38a1d83f0199e03cb757"
  end

  def install
    bin.install "asc"
  end

  test do
    assert_match "0.1.0", shell_output("#{bin}/asc --version")
  end
end
