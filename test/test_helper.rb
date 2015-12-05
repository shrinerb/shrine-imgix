require "minitest/autorun"
require "minitest/pride"

require "shrine/storage/imgix"
require "dotenv"

Dotenv.load!

class Minitest::Test
  def image
    File.open("test/fixtures/image.jpg")
  end
end
