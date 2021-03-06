module Hypermicrodata
  module Serializer
    class Hal < Base
      def serialize
        items = @document.items
        if items.length == 1
          hal_resource = item_to_resource(items.first, @location)
        else
          hal_resource = Halibut::Core::Resource.new(@location)
          items.each do |item|
            embedded_resource = item_to_resource(item)
            item.type.each do |type|
              hal_resource.add_embedded_resource(type, embedded_resource)
            end
          end
        end
        hal_resource.add_link('profile', @profile_path) if @profile_path
        hal_resource.to_hash
      end

      private
      def item_to_resource(item, self_url = nil)
        resource = Halibut::Core::Resource.new(self_url)
        item.properties.each do |name, same_name_properties|
          same_name_properties.each do |property|
            if property.item
              subresource = item_to_resource(property.item)
              resource.add_embedded_resource(name, subresource)
            else
              resource.set_property(name, property.value)
            end
          end
        end
        resource.add_link('self', item.id) if item.id
        Array(item.type).each do |type|
          resource.add_link('type', type)
        end
        item.links.each do |rel, same_rel_links|
          same_rel_links.each do |link|
            resource.add_link(rel, link.value)
          end
        end
        resource
      end
    end
  end
end
