module Microdata
  module Serializer
    class Jsonld < Base

    end

    # json-ld patch
    # HTMLのリンクセマンティクスを保存できてないなぁ
    # JSON-LDにするのやめるべきかも。いろいろめんどくさい。
    module JsonldSerializer
      def to_hash
        hash = {}
        hash[:id] = unwrap(id) if id
        re_schema_org = %r|^http://schema\.org/|i
        if type.all?{|t| t.match(re_schema_org) }
          hash['@context'] = 'http://schema.org'
          hash['@type'] = unwrap(type.map{|t| t.sub(re_schema_org, '') })
        else
          hash['@type'] = unwrap(type)
        end
        properties.each do |name, values|
          final_values = values.map do |value|
            if value.is_a?(Microdata::Item)
              value.to_hash
            else
              value
            end
          end
          hash[name] = unwrap(final_values)
        end
        hash
      end

      def unwrap(values)
        if values.is_a?(Array) && values.length == 1
          values.first
        else
          values
        end
      end
    end
    # Microdata::Item.send :prepend, JsonldSerializer
  end
end
