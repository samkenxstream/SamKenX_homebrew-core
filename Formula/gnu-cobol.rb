class GnuCobol < Formula
  homepage "http://www.opencobol.org/"

  stable do
    url "https://downloads.sourceforge.net/project/open-cobol/gnu-cobol/1.1/gnu-cobol-1.1.tar.gz"
    sha256 "5cd6c99b2b1c82fd0c8fffbb350aaf255d484cde43cf5d9b92de1379343b3d7e"

    fails_with :clang do
      cause <<-EOS.undent
        Building with Clang configures GNU-COBOL to use Clang as its compiler,
        which causes subsequent GNU-COBOL-based builds to fail.
      EOS
    end
  end
  revision 1

  devel do
    version "2.0_nightly_r411"
    url "https://downloads.sourceforge.net/project/open-cobol/gnu-cobol/2.0/gnu-cobol-2.0_nightly_r411.tar.gz"
    sha256 "5d6d767bf0255fa63bc5c26493d53f4749eb0e369b81c626d156f346b3664fe7"
  end

  bottle do
    sha256 "3b1ace2c9e1b37faca976a81fba636054d3971a4d5a7512dce2eb8fad79fbdce" => :mountain_lion
  end

  depends_on "autoconf" => :build
  depends_on "automake" => :build
  depends_on "berkeley-db4"
  depends_on "gmp"
  depends_on "gcc"

  def install
    # both environment variables are needed to be set
    # the cobol compiler takes these variables for calling cc during its run
    # if the paths to gmp and bdb are not provided, the run of cobc fails
    gmp = Formula["gmp"]
    bdb = Formula["berkeley-db4"]
    ENV.append "CPPFLAGS", "-I#{gmp.opt_include} -I#{bdb.opt_include}"
    ENV.append "LDFLAGS", "-L#{gmp.opt_lib} -L#{bdb.opt_lib}"

    args = ["--prefix=#{prefix}", "--infodir=#{info}"]
    args << "--with-libiconv-prefix=/usr"
    args << "--with-libintl-prefix=/usr"

    if build.stable?
      system "aclocal"

      # fix referencing of libintl and libiconv for ld
      # bug report can be found here: https://sourceforge.net/p/open-cobol/bugs/93/
      inreplace "configure", "-R$found_dir", "-L$found_dir"

      args << "--with-cc=#{ENV.cc}"
    end

    system "./configure", *args
    system "make", "install"
  end

  test do
    (testpath/"hello.cob").write <<-EOS
       IDENTIFICATION DIVISION.
       PROGRAM-ID. hello.
       PROCEDURE DIVISION.
       DISPLAY "Hello World!".
       STOP RUN.
    EOS
    system "#{bin}/cobc", "-x", testpath/"hello.cob"
    system testpath/"hello"
  end
end
