class ContentImageUploader < CarrierWave::Uploader::Base
  include CarrierWave::MiniMagick
  include CarrierWave::ImageOptimizer

  process convert: "jpg"
  process optimize: [{ quiet: true }]

  version :v_375x667 do
    process resize_to_fill: [375, 667]
  end

  version :v_414x736 do
    process resize_to_fill: [414, 736]
  end
end
