class PropertyPhotoSerializer
  include JSONAPI::Serializer

  attributes :url, :position, :caption, :is_primary
end
