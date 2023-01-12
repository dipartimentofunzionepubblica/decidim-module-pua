# frozen_string_literal: true

$LOAD_PATH.push File.expand_path("lib", __dir__)

require "decidim/pua/version"

Gem::Specification.new do |s|
  s.version = Decidim::Pua.version
  s.authors = ["Lorenzo Angelone"]
  s.email = ["l.angelone@kapusons.it"]
  s.license = "AGPL-3.0"
  s.homepage = "https://github.com/decidim/decidim-module-pua"
  s.required_ruby_version = ">= 2.7"

  s.name = "decidim-pua"
  s.summary = "A decidim PUA module"
  s.description = "PUA Integration for Decidim."

  s.files = Dir["{app,config,lib}/**/*", "LICENSE-AGPLv3.txt", "Rakefile", "README.md"]

  s.add_dependency "decidim-core", Decidim::Pua.version
end
