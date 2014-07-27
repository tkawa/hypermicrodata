module Microdata
  module Serializer
    class Hal < Base
      def to_json
        items = @document.items
        if items.present?
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
          Halibut::Adapter::JSON.dump(hal_resource)
          # JSON.pretty_generate(hal_resource.to_hash)
        else
          '{}'
        end
      end

      def item_to_resource(item, self_url = nil)
        resource = Halibut::Core::Resource.new(self_url)
        item.properties.each do |name, itemprops|
          itemprops.each do |itemprop|
            value = itemprop.properties[name]
            if value.is_a?(Microdata::Item)
              subresource = item_to_resource(value)
              resource.add_embedded_resource(name, subresource)
            else
              resource.set_property(name, value)
            end
          end
        end
        resource.add_link('self', item.id) if item.id
        item.links.each do |name, itemprops|
          itemprops.each do |itemprop|
            resource.add_link(name, itemprop.links[name])
          end
        end
        resource
      end
    end
  end
end
