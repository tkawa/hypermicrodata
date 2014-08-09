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
        item.all_properties_and_links.each do |property|
          rel = property.rels.join(' ') unless property.rels.empty?
          if property.item?
            # TODO: name複数の場合のduplicateをなくす
            property.names.each do |name|
              child_data = item_to_nested_data(property.item, name)
              parent_data.add_data(child_data)
            end
            # itemかつlinkというのはたぶんない
          elsif property.link?
            property.names.each do |name|
              child_data = Uberous::Data.new(name: name, value: property.value, rel: rel)
              parent_data.add_data(child_data)
            end
          else # only value
            property.names.each do |name|
              child_data = Uberous::Data.new(name: name, value: property.value)
              parent_data.add_data(child_data)
            end
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
