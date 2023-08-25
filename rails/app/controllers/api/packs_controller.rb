class Api::PacksController < ApplicationController
  before_action :authenticate!
  before_action :set_spec, only: %i(index create)
  before_action :set_pack, only: %i(show update destroy)

  def index
    @packs = @spec.packs
    if (name = params[:name])
      @packs = @packs.where(Pack.arel_table[:name].matches("%#{name}%"))
    end
    @packs = paginate @packs, accept_ranges: %w(id name created_at updated_at), default_range: { limit: 30 }
    render json: @packs.map(&method(:index_attributes))
  end

  def show
    render json: show_attributes(@pack)
  end

  def create
    @pack = Pack.generate(@spec.body)
    @pack.spec = @spec
    @pack.save!
    render json: show_attributes(@pack), status: :created
  end

  private

  def set_spec
    @spec = Spec.find(params[:spec_id])
  end

  def set_pack
    @pack = Pack.includes(sheets: :problems).find(params[:id])
  end

  def pack_params
    params.permit(:name)
  end

  def index_attributes item
    item.attributes
  end

  def show_attributes item
    sheets = item.sheets.map { |sheet| sheet.attributes.merge(problems: sheet.problems(&:attributes)) }
    item.attributes.merge(sheets:)
  end
end
