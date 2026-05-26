# config/initializers/ransack_search_compat.rb

module RansackSearchCompat
  refine ActiveRecord::Relation do
    def search(*args, &block)
      if args.size == 1 && args.first.is_a?(Hash)
        ransack(**args.first, &block)
      else
        ransack(*args, &block)
      end
    end
  end
end

using RansackSearchCompat
