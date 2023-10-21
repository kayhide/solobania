class Api::ActsController < ApplicationController
  before_action :authenticate!
  before_action :set_problem, only: %i(create)
  before_action :set_act, only: %i(show update)

  def index
    @acts = current_user.acts.order(created_at: :desc).limit(200)
    render json: @acts.map(&method(:index_attributes))
  end

  def show
    render json: show_attributes(@act)
  end

  def create
    @act = Act.create!(user: current_user, actable: @problem, **act_params)
    sheet_act = Act.find_or_initialize_by(
      user: current_user,
      actable: @problem.sheet,
    )
    sheet_act.created_at ||= @act.created_at
    sheet_act.updated_at = @act.created_at
    sheet_act.save!

    pack_act = Act.find_or_initialize_by(
      user: current_user,
      actable: @problem.sheet.pack,
    )
    pack_act.created_at ||= @act.created_at
    pack_act.updated_at = @act.created_at
    pack_act.save!

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
      .merge(
        pack_id: item.actable.is_a?(Pack) ? item.actable_id : item.actable.try(:pack)&.id,
        sheet_id: item.actable.is_a?(Sheet) ? item.actable_id : item.actable.try(:sheet)&.id,
        problem_id: item.actable.is_a?(Problem) ? item.actable_id : item.actable.try(:problem)&.id,
        display_name: item.actable.display_name)
  end

  def show_attributes item
    index_attributes item
  end
end
