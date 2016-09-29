source "https://rubygems.org"
gemspec

group :development do
  if Gem::Version.new(RUBY_VERSION.dup) >= Gem::Version.new("2.0.0")
    gem "coveralls"
    gem "pry-byebug"
  else
    gem "term-ansicolor", "1.3.2"
    gem "coveralls", "0.8.13"
    gem "pry-debugger"
  end
end
