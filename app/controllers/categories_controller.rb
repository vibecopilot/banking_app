#new

class CategoriesController < ApplicationController

	def index
  render json: Category.all
end

	def create
		category = Category.new(name: params[:name])
		if category.save
			render json: category

		else
			render json: category.errors
		end
	end
end