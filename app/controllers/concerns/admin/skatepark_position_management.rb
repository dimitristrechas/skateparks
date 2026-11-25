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

    def ordered_new_items(items, positions, records:, existing_attributes:)
      positions = fallback_positions(items, requested_positions(existing_attributes, records)) if positions.empty?

      items.zip(positions).filter_map do |item, position|
        [item, position.to_i] unless item.blank? || position.blank?
      end
    end

    def fallback_positions(items, existing_positions)
      starting_position = existing_positions.max.to_i + 1

      items.each_index.map { |index| starting_position + index }
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
