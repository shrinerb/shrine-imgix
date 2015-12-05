require "minitest/autorun"
require "minitest/pride"

require "shrine/storage/imgix"

require "forwardable"
require "stringio"

require "dotenv"
Dotenv.load!

class Minitest::Test
  def image
    File.open("test/fixtures/image.jpg")
  end
end
