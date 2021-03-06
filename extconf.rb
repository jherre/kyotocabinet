require "mkmf"

File::unlink("Makefile") if (File::exist?("Makefile"))
dir_config('kyotocabinet')

home = ENV["HOME"]
ENV["PATH"] = ENV["PATH"] + ":/usr/local/bin:$home/bin:."
kccflags = `kcutilmgr conf -i 2>/dev/null`.chomp
kcldflags = `kcutilmgr conf -l 2>/dev/null`.chomp
kcldflags = kcldflags.gsub(/-l[\S]+/, "").strip
kclibs = `kcutilmgr conf -l 2>/dev/null`.chomp
kclibs = kclibs.gsub(/-L[\S]+/, "").strip

kccflags = "-I/usr/local/include" if(kccflags.length < 1)
kcldflags = "-L/usr/local/lib" if(kcldflags.length < 1)
kclibs = "-lkyotocabinet -lz -lstdc++ -lrt -lpthread -lm -lc" if(kclibs.length < 1)

if RbConfig::CONFIG["CPP"] =~ /clang/
  RbConfig::CONFIG["CPP"] = "g++ -E"
end

case RbConfig::CONFIG["build_os"]
when /^darwin14\./i, /darwin12.[123]/i, /darwin1[10]/i
  RbConfig::CONFIG["CPP"] = "g++ -E -std=c++11 -stdlib=libc++"
end

$CFLAGS = "-I. #{kccflags} -Wall #{$CFLAGS} -O2"
$CPPFLAGS = $CPPFLAGS + " -I. #{kccflags}"
$LDFLAGS = $LDFLAGS.sub(/\-L\/\S+/, '')
$LDFLAGS = "#{$LDFLAGS} -L. #{kcldflags}"
$libs = "#{$libs} #{kclibs}"

printf("setting variables ...\n")
printf("  CPP = %s\n", RbConfig::CONFIG["CPP"])
printf("  CFLAGS = %s\n", $CFLAGS)
printf("  LDFLAGS = %s\n", $LDFLAGS)
printf("  libs = %s\n", $libs)

have_func('rb_thread_call_without_gvl', %w{ruby/thread.h})
have_func('rb_thread_blocking_region')

if have_header('kccommon.h')
  $CPPFLAGS = "#{$CPPFLAGS} -std=c++11"
  create_makefile('kyotocabinet')
end
