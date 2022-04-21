pkg_name=habitat-compose
pkg_origin=gscho
pkg_deps=(core/ruby/3.0.1 core/coreutils)
pkg_build_deps=(core/make core/gcc core/git)
pkg_bin_dirs=(compose/exe)
pkg_upstream_url=https://github.com/gscho/habitat-compose

pkg_version() {
  $(pkg_path_for core/ruby)/bin/ruby -I $SRC_PATH/compose/lib -e "require 'compose/version'; puts Compose::VERSION"
}

do_before() {
  do_default_before
  update_pkg_version
}

do_prepare() {
  GEM_HOME="$pkg_prefix/compose"
  build_line "Setting GEM_HOME=$GEM_HOME"
  GEM_PATH="$GEM_HOME"
  build_line "Setting GEM_PATH=$GEM_PATH"
  export GEM_HOME GEM_PATH
}

do_build(){
  build_line "Building gem"
  pushd compose
  gem build "compose.gemspec"
  popd
}

do_install(){
  build_line "Installing gem"
  pushd compose
  mkdir -p "$pkg_prefix/ruby-bin"
  gem install --bindir "$pkg_prefix/ruby-bin" "./compose-$pkg_version.gem" --no-document
  fix_interpreter "$pkg_prefix/ruby-bin/*" core/coreutils bin/env
  fix_interpreter "$pkg_prefix/compose/exe/*" core/coreutils bin/env
  wrap_ruby_bin "habitat-compose"
  popd
}

wrap_ruby_bin() {
  local name="$1"
  local original="$pkg_prefix/ruby-bin/$name"
  local wrapper="$pkg_prefix/compose/exe/$name"

  build_line "Adding wrapper $original to $wrapper"

  cat <<EOF > "$wrapper"
#!/bin/sh
set -e
if test -n "$DEBUG"; then set -x; fi
export GEM_HOME="$GEM_HOME"
export GEM_PATH="$GEM_PATH"
unset RUBYOPT GEMRC
exec $(pkg_path_for ruby)/bin/ruby $original \$@
EOF
  chmod -v 755 "$wrapper"
}