class RulesController < ApplicationController
  before_action :user_must_logged_in
  before_action :user_must_be_expert

  def index
    @rules = Rule.all.order(id: :desc)
  end

  def new
    @rule = Rule.new
  end

  def create
    @rule = Rule.new(
      before: params[:rule][:before],
      after: params[:rule][:after],
      status: "active"
    )
    if @rule.save
      flash[:success] = "Create new rule successfully"
      redirect_to rules_path
    else
      render "new"
    end
  end

  def edit
    @rule = Rule.find params[:id]
  end

  def update
    @rule = Rule.find params[:id]
    if params[:rule][:before].present?
      @rule.update(before: params[:rule][:before])
    end
    if params[:rule][:after].present?
      @rule.update(after: params[:rule][:after])
    end
    redirect_to rules_path
    flash[:success] = "Update rule successfully"
  end

  def destroy
    @rule = Rule.find params[:id]
    @rule.update(status: "deleted")
    redirect_to rules_path
    flash[:danger] = "Delete rule successfully"
  end

  private

  def user_must_be_expert
    if current_user.present?
      unless current_user.is_expert == "true"
        redirect_to user_path(current_user)
        flash[:danger] = "Permission denied"
      end
    end
  end
end
