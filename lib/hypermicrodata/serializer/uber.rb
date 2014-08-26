module Hypermicrodata
  module Serializer
    class Uber < Base
      ACTION_MAPPINGS = {
        'GET'    => 'read',
        'POST'   => 'append',
        'PUT'    => 'replace',
        'DELETE' => 'remove',
        'PATCH'  => 'partial'
      }.freeze

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
          elsif property.submit_button?
            attrs = { rel: rel, url: property.action_url, model: property.query_string, action: action_name(property.method) }
            attrs[:model] = "?#{attrs[:model]}" if %w(read remove).include?(attrs[:action])
            attrs.reject! { |_, value| value.nil? }
            if property.names.empty?
              child_data = Uberous::Data.new(attrs)
              parent_data.add_data(child_data)
            else
              property.names.each do |name|
                child_data = Uberous::Data.new(attrs.merge(name: name))
                parent_data.add_data(child_data)
              end
            end
          elsif property.link?
            attrs = { rel: rel, url: property.value }
            attrs.reject! { |_, value| value.nil? }
            if property.names.empty?
              child_data = Uberous::Data.new(attrs)
              parent_data.add_data(child_data)
            else
              property.names.each do |name|
                child_data = Uberous::Data.new(attrs.merge(name: name))
                parent_data.add_data(child_data)
              end
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

      def action_name(method_name)
        ACTION_MAPPINGS[method_name.to_s.upcase] || method_name.to_s.downcase
      end
    end
  end
end
