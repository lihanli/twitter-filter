require 'test_helper'

class OptionsTest < CapybaraTestCase
  def test
    # TODO don't hardcode extension id
    visit('chrome-extension://dekhepikdhnjdoakamohiiianghkamea/dist/options/index.html')
    refresh # have to refresh or else chrome apis dont work
    binding.pry; raise
  end
end