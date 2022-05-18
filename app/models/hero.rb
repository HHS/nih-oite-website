class Hero
  attr_reader :title, :image, :image_2x

  def initialize(data)
    @title = data["title"] || ""
    @image = data["image"] || ""
    @image_2x = data["image_2x"] || ""
    @enabled = data["enabled"]
  end

  def enabled?
    @enabled
  end

  def image_src
    @image || @image_2x
  end

  def image_srcset
    srcset = {}
    srcset["1x"] = @image if @image
    srcset["2x"] = @image_2x if @image
    srcset
  end
end
