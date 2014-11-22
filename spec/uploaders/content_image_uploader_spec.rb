require 'spec_helper'
require 'carrierwave/test/matchers'

describe ContentImageUploader do
  include CarrierWave::Test::Matchers

  let(:uploader) { ContentImageUploader.new }
  before do
    ContentImageUploader.enable_processing = true
    uploader.store!(File.open(Rails.root + 'spec/fixtures/images/cutler.jpg'))
  end

  after do
    ContentImageUploader.enable_processing = true
    uploader.remove!
  end

  it 'should create a version optimized for iPhone 6' do
    expect(uploader.v_375x667).to have_dimensions(375, 667)
  end

  it 'should create a version optimized for iPhone 6+' do
    expect(uploader.v_414x736).to have_dimensions(414, 736)
  end
end
