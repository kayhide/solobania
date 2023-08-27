class Api::ActsController < ApplicationController
  before_action :authenticate!
  before_action :set_problem, only: %i(create)
  before_action :set_act, only: %i(show update)

  def index
    @acts = current_user.acts.order(created_at: :desc)
    render json: @acts.map(&method(:index_attributes))
  end

  def show
    render json: show_attributes(@act)
  end

  def create
    @act = Act.create!(user: current_user, actable: @problem, **act_params)
    render json: show_attributes(@act), status: :created
  end

  def update
    @act.update!(act_params)
    render json: show_attributes(@act)
  rescue ArgumentError
    raise Api::BadParameter.new(act_params)
  end

  private

  def set_problem
    @problem = Problem.includes(sheet: :pack).find(params[:problem_id])
  end

  def set_act
    @act = current_user.acts.find(params[:id])
  end

  def act_params
    params.permit(:mark)
  end

  def index_attributes item
    item.attributes
      .except(*%w(user_id))
  end

  def show_attributes item
    index_attributes item
  end
end
