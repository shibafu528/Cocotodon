# disable pkg-config
ENV['PKG_CONFIG_LIBDIR'] = ''

MRuby::Lockfile.disable

shared = ->(conf) do
  conf.cc.defines << %w(MRB_UTF8_STRING)

  conf.gem core: 'mruby-metaprog'
  conf.gem core: 'mruby-io'
  conf.gem core: 'mruby-pack'
  conf.gem core: 'mruby-sprintf'
  conf.gem core: 'mruby-print'
  conf.gem core: 'mruby-math'
  conf.gem core: 'mruby-time'
  conf.gem core: 'mruby-struct'
  conf.gem core: 'mruby-compar-ext'
  conf.gem core: 'mruby-enum-ext'
  conf.gem core: 'mruby-string-ext'
  conf.gem core: 'mruby-numeric-ext'
  conf.gem core: 'mruby-array-ext'
  conf.gem core: 'mruby-hash-ext'
  conf.gem core: 'mruby-range-ext'
  conf.gem core: 'mruby-proc-ext'
  conf.gem core: 'mruby-symbol-ext'
  conf.gem core: 'mruby-random'
  conf.gem core: 'mruby-object-ext'
  conf.gem core: 'mruby-objectspace'
  conf.gem core: 'mruby-fiber'
  conf.gem core: 'mruby-enumerator'
  conf.gem core: 'mruby-enum-lazy'
  conf.gem core: 'mruby-toplevel-ext'
  conf.gem core: 'mruby-kernel-ext'
  conf.gem core: 'mruby-class-ext'
  conf.gem core: 'mruby-error'
  conf.gem core: 'mruby-rational'
  conf.gem core: 'mruby-complex'
  conf.gem core: 'mruby-compiler'

  conf.gem github: 'shibafu528/mruby-mix', path: 'mruby-mix'
  conf.gem github: 'shibafu528/mruby-mix', path: 'mruby-mix-miquire-fs'
  conf.gem github: 'shibafu528/mruby-mix', path: 'mruby-mix-twitter-models'
  conf.gem github: 'shibafu528/mruby-mix', path: 'mruby-mix-polyfill-gtk'
  conf.gem github: 'shibafu528/mruby-mix', path: 'mruby-mix-command-conditions'
end

# 使わないけど必要
MRuby::Build.new do |conf|
  toolchain :clang
  enable_debug
  shared.(conf)
end

build_arch = `uname -m`.chomp

%w[x86_64 arm64].each do |arch|
  %w[debug release].each do |build_type|
    MRuby::CrossBuild.new("macos-#{arch}-#{build_type}") do |conf|
      toolchain :clang
      
      enable_debug if build_type == 'debug'
      
      conf.cc.flags << "--target=#{arch}-apple-darwin"
      conf.linker.flags << "--target=#{arch}-apple-darwin"
      
      conf.host_target = "#{arch.gsub('arm64', 'aarch64')}-apple-darwin"
      conf.build_target = "#{build_arch.gsub('arm64', 'aarch64')}-apple-darwin"
    
      shared.(conf)
    end
  end
end
