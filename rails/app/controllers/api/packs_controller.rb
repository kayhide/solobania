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
    @pack = Pack.includes(:spec, sheets: :problems).find(params[:id])
  end

  def pack_params
    params.permit(:name)
  end

  def index_attributes item
    item.attributes.merge(spec_key: item.spec.key)
  end

  def show_attributes item
    sheets = item.sheets.map do |sheet|
      problems = sheet.problems.map do |problem|
        problem
          .attributes
          .except(*%w(type))
          .merge(subject: problem.type.to_s.delete_suffix("Problem"))
      end
      sheet.attributes.merge(problems:)
    end
    item.attributes.merge(spec_key: item.spec.key, sheets:)
  end
end
