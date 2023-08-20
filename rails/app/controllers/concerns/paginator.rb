module Paginator
  extend ActiveSupport::Concern

  class Range
    include ActiveModel::Model
    include ActiveModel::Attributes
    attribute :field
    attribute :value
    attribute :limit
    attribute :offset
    attribute :order
    
    def merge x
      self.class.new(attributes.merge(x))
    end
  end

  def paginate items, accept_ranges: accept_ranges = nil, default_range: {}
    range = Range.new(**default_range).merge parse_request_range
    range.field ||= :id
    range.offset ||= 0
    range.order ||= :asc

    total = items.count
    field = range.field
    if range.value
      items = items.where(items.arel_table[field].gteq(range.value)) if range.order == :asc;
      items = items.where(items.arel_table[field].lteq(range.value)) if range.order == :desc;
    end
    items = items.limit(range.limit) if range.limit && 0 < range.limit
    items = items.offset(range.offset) if range.offset && 0 < range.offset
    items = items.order(**[[range.field, range.order]].to_h)

    items.load
    append_content_range range, items
    append_accept_ranges accept_ranges if accept_ranges
    append_total_count total if total
    items
  end

  def paginate_ordered items, default_range: {}, count: nil
    range = Range.new(**default_range).merge parse_request_range
    range.offset ||= 0

    total = count || items.count
    items = items.limit(range.limit) if range.limit && 0 < range.limit
    items = items.offset(range.offset) if range.offset && 0 < range.offset

    items.load
    append_content_range range, items
    append_total_count total if total
    items
  end

  def parse_request_range
    xs = request.headers['Range'].to_s.split /; */
    field, value = xs[0]&.split
    limit = xs.grep(/^limit /).first&.split&.last&.to_i
    offset = xs.grep(/^offset /).first&.split&.last&.to_i
    order = xs.grep(/^order /).first&.split&.last&.to_sym
    {
      field: field&.to_sym,
      value: value ? URI.decode(value) : nil,
      limit: limit,
      offset: offset,
      order: order,
    }.compact
  end

  def append_content_range range, items
    field = range.field
    if items.present? && items.first.attributes.key?(field)
      ends = [items.first, items.last].map { |x| ERB::Util.url_encode x.read_attribute(field).as_json.to_s }
      response.headers['Content-Range'] = "#{field} #{ends.join('..')}"
    else
      response.headers['Content-Range'] = "#{field}"
    end
    response.headers['Access-Control-Expose-Headers'] ||= []
    response.headers['Access-Control-Expose-Headers'] << 'Content-Range'

    if items.length == range.limit
      response.headers['Next-Range'] = [
        range.value ?  "#{field} #{range.value}" : field.to_s,
        "limit #{range.limit}",
        "offset #{range.offset + items.length}",
        "order #{range.order}",
      ].join("; ")
      response.headers['Access-Control-Expose-Headers'] << 'Next-Range'
    end
  end

  def append_accept_ranges attr_names
    response.headers['Accept-Ranges'] = attr_names.join ", "
    response.headers['Access-Control-Expose-Headers'] ||= []
    response.headers['Access-Control-Expose-Headers'] << 'Accept-Ranges'
  end

  def append_total_count count
    response.headers['Total-Count'] = count
    response.headers['Access-Control-Expose-Headers'] ||= []
    response.headers['Access-Control-Expose-Headers'] << 'Total-Count'
  end
end
