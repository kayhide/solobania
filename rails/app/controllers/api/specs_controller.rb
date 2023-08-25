class Api::SpecsController < ApplicationController
  before_action :authenticate!

  def index
    @specs = Spec.order(:key)
    @projects = paginate @specs, accept_ranges: %w(id name created_at updated_at), default_range: { limit: 30 }
    render json: @projects.map(&method(:index_attributes))
  end

  private

  def set_project
    @project = Project.readable_to(current_user).find(params[:id])
  end

  def index_attributes item
    show_attributes item
  end

  def show_attributes item
    item.attributes.except('body')
  end
end
