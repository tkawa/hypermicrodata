module Microdata
  module Serializer
    class Uber < Base
      def serialize
        items = @document.items
        if items.length == 1
          root_data = item_to_nested_data(items.first)
          if @location
            root_data.rel = 'self'
            root_data.url = @location
          end
          root_data.add_link('profile', @profile_path) if @profile_path
          uber = Uberous::Uber.new([root_data])
        else
          data_collection = @document.items.map do |item|
            item_to_nested_data(item).tap do |data|
              data.name = generate_short_name(item.type) if item.type
            end
          end
          uber = Uberous::Uber.new(data_collection)
          uber.add_link('self', @location) if @location
          uber.add_link('profile', @profile_path) if @profile_path
        end
        uber.to_hash
      end

      private
      def item_to_nested_data(item, self_name = nil)
        parent_data = Uberous::Data.new
        if item.id
          parent_data.url = item.id
          parent_data.rel = self_name if self_name # consider a link relation
          parent_data.name = generate_short_name(item.type) if item.type
        else
          parent_data.name = self_name if self_name # consider a semantic descriptor
        end
        item.properties.each do |name, itemprops|
          itemprops.each do |itemprop|
            value = itemprop.properties[name]
            if value.is_a?(Microdata::Item)
              child_data = item_to_nested_data(value, name)
              parent_data.add_data(child_data)
            else
              parent_data.add_data(Uberous::Data.new(name: name, value: value))
            end
          end
        end
        # Array(item.type).each do |type|
        #   parent_data.add_link('type', type)
        # end
        item.links.each do |name, itemprops|
          itemprops.each do |itemprop|
            parent_data.add_link(name, itemprop.links[name])
          end
        end
        parent_data
      end

      def generate_short_name(item_types)
        # TODO: これでいいのか？
        Array(item_types).first.sub(%r|^http://schema\.org/|, '') if item_types
      end
    end
  end
end
