# Documentation: https://docs.brew.sh/Formula-Cookbook
#                https://rubydoc.brew.sh/Formula
# PLEASE REMOVE ALL GENERATED COMMENTS BEFORE SUBMITTING YOUR PULL REQUEST!
class Segalign < Formula
  desc 'A Scalable GPU System for Pairwise Whole Genome Alignments'
  homepage 'https://github.com/ComparativeGenomicsToolkit/SegAlign'
  head 'https://github.com/ComparativeGenomicsToolkit/SegAlign.git'
  license ""

  depends_on "openssl"
  depends_on "libpng"
  depends_on "parallel"
  depends_on 'zlib'
  depends_on 'thiagogenez/external/lastz'
  depends_on "mysql-connector-c"
  depends_on "cmake" => :build
  depends_on "boost" => :build

  resource "kent" do
    url "https://github.com/ucscGenomeBrowser/kent.git", branch: "beta"
  end

  resource "tbb" do
    url "https://github.com/oneapi-src/oneTBB/releases/download/2019_U9/tbb2019_20191006oss_lin.tgz"
    sha256 "81eaabaa0f87a2aa2f96d538440978b4f8c22cad38ca36634a77a9874b695559"
  end

  def install
    # ENV.deparallelize  # if your formula fails when building in parallel
    # Remove unrecognized options if warned by configure

    resource("kent").stage {
      inreplace "src/inc/common.mk", "CFLAGS=", "CFLAGS=-fPIC"
      cd "src" do
        system "make", "topLibs"
        cd "utils/faToTwoBit" do
          system "make", "compile"
          bin.install 'faToTwoBit'
        end
        cd "utils/twoBitToFa" do
          system "make", "compile"
          bin.install 'twoBitToFa'
        end
      end
    }

    resource("tbb").stage { cp_r '.', buildpath/'tbb' }

    ENV["GO_LDFLAGS"] = "-s -w"
    ENV["GO_LDFLAGS"] = "-s -w"

    mkdir "build" do
      system "cmake", "-DCMAKE_BUILD_TYPE=Release", "-DTBB_ROOT=#{buildpath}/tbb", "-DCMAKE_PREFIX_PATH=#{buildpath}/tbb/cmake", ".."
      system "make"
    end


  end

  test do
    # `test do` will create, run in and delete a temporary directory.
    #
    # This test will fail and we won't accept that! For Homebrew/homebrew-core
    # this will need to be a test that verifies the functionality of the
    # software. Run the test with `brew test SegAlign`. Options passed
    # to `brew install` such as `--HEAD` also need to be provided to `brew test`.
    #
    # The installed folder is not in the path, so use the entire path to any
    # executables being tested: `system "#{bin}/program", "do", "something"`.
    system "false"
  end
end

