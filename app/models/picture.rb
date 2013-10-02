class Picture < ActiveRecord::Base
  
  attr_accessible :title, :caption, :resource_type, :resource_id, :resource, :image
  
  belongs_to :resource, :polymorphic => true, :counter_cache => true
  
  acts_as_list :scope => [:resource_id, :resource_type]
  
  Paperclip.interpolates :title_url do |attachment, style|
    attachment.instance.title_url
  end
  Paperclip.interpolates :style_upcase do |attachment, style|
    style_upcase = style.to_s.upcase
    return style_upcase
  end
  Paperclip.interpolates :directory_id do |attachment, style|
    id = (attachment.instance.id).to_s.rjust(8,"0")
    directory_id = id.scan(/..../)
    directory_id = directory_id.join('/')
    return directory_id
  end
  
  PAPERCLIP_PATH = ":rails_root/public/attachments/:class-:attachment/:directory_id/:style_upcase-:title_url.:extension"
  if Rails.env == "production"
    PAPERCLIP_URL =                  "/attachments/:class-:attachment/:directory_id/:style/:title_url.:extension"
  else
    PAPERCLIP_URL =                  "/attachments/:class-:attachment/:directory_id/:style_upcase-:title_url.:extension"
  end
  has_attached_file :image,
                    :styles => {
                      :gallery_large    => { :format => 'jpg', :quality => 100, :geometry => '670x500>' },
                      :large            => { :format => 'jpg', :quality => 100, :geometry => '640x640>' },
                      :featured_small   => { :format => 'jpg', :quality => 100, :geometry => '245x200#' },
                      :homepage_large   => { :format => 'jpg', :quality => 100, :geometry => '640x390#' },
                      :homepage_medium  => { :format => 'jpg', :quality => 100, :geometry => '300x300#' },
                      :homepage_small   => { :format => 'jpg', :quality => 100, :geometry => '300x150#' },
                      :thumbnail        => { :format => 'jpg', :quality => 100, :geometry => '160x130#' },
                      :innerpage_medium => { :format => 'jpg', :quality => 100, :geometry => '440x440>' },
                      :original         => {                   :quality => 100, :geometry => '', :animated => true }
                    },
                    :path => PAPERCLIP_PATH,
                    :url  => PAPERCLIP_URL

  validates :title, :presence => true
  
  before_validation :change_filenames, :strip_attributes

  def path(place = nil)
    case self.resource_type
    when "Article"
      return "/articles/#{self.resource_id}/photo/#{self.id}-#{Utility::friendly_url(self.title)}"
    when "PlaceInfo"
      return "/places/#{self.resource.place_id}-#{Utility::friendly_url(self.resource.place.name)}/information/photo/#{self.id}-#{Utility::friendly_url(self.title)}"
    when "Hotel"
      return "/places/#{self.resource.place_id}-#{Utility::friendly_url(self.resource.place.name)}/hotels/#{self.resource_id}/photo/#{self.id}-#{Utility::friendly_url(self.title)}"
    else  
      return "/places/#{self.resource.place.id}-#{Utility::friendly_url(self.resource.place.name)}/#{self.resource_type.downcase.pluralize}/#{self.resource_id}/photo/#{self.id}-#{Utility::friendly_url(self.title)}"
    end

  end

  def get_prev_and_next
    positions = "#{self.position - 1}, #{self.position + 1}"

    pictures = Picture.where("resource_id = #{self.resource_id} AND 
                             resource_type = '#{self.resource_type}' AND
                             position IN (#{positions})")
                      .order("position")
    if pictures.size == 2
      prev_picture = pictures[0]
      next_picture = pictures[1]
    elsif pictures.size == 1 and self.position == 1
      prev_picture = nil
      next_picture = pictures[0]
    else
      prev_picture = pictures[0]
      next_picture = nil
    end
    return {:prev => prev_picture, :next => next_picture}
  end

  private

  def strip_attributes
    # normalize attributes
    self.title.strip!
    self.title_url = Utility::friendly_url(self.title)
  end

  def change_filenames
    # if there is an update to the title, the file names should be changed accordingly
    if not self.new_record? and self.title_changed?
      self.image = self.image
    end
  end

end