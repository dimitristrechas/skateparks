module Admin
  module SkateparkPositionManagement
    extend ActiveSupport::Concern

    private

    def reorder_attributes(attributes)
      case attributes
      when ActionController::Parameters
        attributes.values
      when Array
        attributes
      else
        []
      end.map do |attributes_hash|
        attributes_hash.to_h.symbolize_keys
      end
    end

    def requested_positions(existing_attributes, records)
      positions =
        existing_attributes.filter_map do |attributes|
          next if ActiveModel::Type::Boolean.new.cast(attributes[:_destroy])

          attributes[:position]
        end

      positions.map(&:to_i).presence ||
        records.reject(&:marked_for_destruction?).filter_map(&:position)
    end

    def reserve_existing_positions!(records, existing_attributes)
      return if existing_attributes.empty?

      records.find_each do |record|
        record.allow_negative_position = true
        record.update!(position: -record.position)
      end
    end
  end
end
