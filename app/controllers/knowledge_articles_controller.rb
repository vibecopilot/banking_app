class KnowledgeArticlesController < ApplicationController
  include UserExt
  protect_from_forgery with: :null_session
  before_action :authenticate_user!, if: :check_user
  before_action :api_user
  before_action :set_user
  before_action :set_article, only: %i[ show update destroy ]

  def index
    @articles = KnowledgeArticle.for_site(@user.current_site_id)
                                .includes(:category)
                                .order(updated_at: :desc)
    render json: @articles.map { |a| article_json(a) }
  end

  def show
    render json: article_json(@article)
  end

  def create
    @article = KnowledgeArticle.new(article_params)
    @article.site_id = @user.current_site_id
    @article.created_by = @user.id

    if @article.save
      render json: article_json(@article), status: :created
    else
      render json: { errors: @article.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def update
    if @article.update(article_params)
      render json: article_json(@article)
    else
      render json: { errors: @article.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def destroy
    @article.destroy
    head :no_content
  end

  private

  def set_article
    @article = KnowledgeArticle.find(params[:id])
  end

  def article_params
    params.require(:knowledge_article).permit(:title, :category_id, :body, :tags, :status, :views, :helpful, :not_helpful)
  end

  def article_json(a)
    {
      id: a.id,
      title: a.title,
      categoryId: a.category_id,
      categoryName: a.category&.name,
      body: a.body,
      tags: a.tags,
      status: a.status,
      views: a.views,
      helpful: a.helpful,
      notHelpful: a.not_helpful,
      createdAt: a.created_at,
      updatedAt: a.updated_at,
    }
  end
end
