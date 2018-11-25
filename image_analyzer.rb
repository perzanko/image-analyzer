require 'rmagick'
require 'colormath'

include Magick


class ImageAnalyzer
  def initialize(img_name)
    @img_instance = read_image(img_name)
    puts "Image loaded: #{img_name}"
  end

  def read_image(name)
    img = Magick::ImageList.new(name)
    return img
  end

  def common_color
    return find_common_color
  end

  private

  def find_common_color
    puts "computing..."
    colors = get_colors_from_image(@img_instance)
    colors_hash = Hash.new 0
    colors.each {|color| colors_hash[color] += 1}
    return convert_color_to_readable_hash colors_hash.max_by {|_, v| v}[0]
  end

  private

  def get_colors_from_image(img)
    quantized = img.quantize(number_colors = 256)
    arr_of_colors = []

    (0..img.columns).each do |col|
      (0..img.rows).each do |row|
        color = quantized.pixel_color(col, row)
        arr_of_colors.append(color.to_hsla.join(','))
      end
    end
    return arr_of_colors
  end

  private

  def convert_color_to_readable_hash(color_str)
    color = color_str.split(',').map {|x| x.to_f}
    color_instance = ColorMath::HSL.new(color[0], (color[1] / 255), (color[2] / 255))
    return {
        "hex" => color_instance.hex,
        "rgba" => "(#{to_rgba_val color_instance.red}, #{to_rgba_val color_instance.green}, #{to_rgba_val color_instance.blue}, 1)",
        "hsl" => "(#{color[0].round(2)}, #{(color[1] / 255 * 100).round(2)}%, #{(color[2] / 255 * 100).round(2)}%, 1)"
    }
  end

  private

  def to_rgba_val(val)
    (val * 255).round(0)
  end
end

ia = ImageAnalyzer.new("test.jpg")
puts ia.common_color

