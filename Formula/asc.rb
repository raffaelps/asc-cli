class Asc < Formula
  desc "CLI for the Apple App Store Connect API"
  homepage "https://github.com/raffaelps/asc-cli"
  version "0.2.1"
  license "MIT"

  on_macos do
    # Only Apple Silicon is shipped (GitHub no longer offers Intel macOS runners,
    # and arm64 binaries cannot run on Intel Macs). Intel users get a clear error.
    on_arm do
      url "https://github.com/raffaelps/asc-cli/releases/download/v0.2.1/asc-macos-arm64.tar.gz"
      sha256 "4a4fd65e808431663156f4218a30a6235305931488954f935cf0c580038d73b2"
    end
  end

  on_linux do
    url "https://github.com/raffaelps/asc-cli/releases/download/v0.2.1/asc-linux-x86_64.tar.gz"
    sha256 "4a6a6efad375cdbad37fb127e5a578c779ef2d51f0818332c64ad337d0287f2d"
  end

  def install
    bin.install "asc"
  end

  test do
    assert_match "0.2.1", shell_output("#{bin}/asc --version")
  end
end
