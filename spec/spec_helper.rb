require 'rubygems'
require 'bundler/setup'

Bundler.require

require 'matchers'
require 'cancan/matchers'
require 'i18n'


# I8n setting to fix deprecation.
# Seting it to true will skip the locale validation (Rails 3 behavior).
# Seting it to false will raise an error if an invalid locale is passed (Rails 4 behavior).
I18n.enforce_available_locales = false


RSpec.configure do |config|
  config.treat_symbols_as_metadata_keys_with_true_values = true
  config.filter_run :focus => true
  config.run_all_when_everything_filtered = true
  config.mock_with :rspec

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  config.before(:each) do
    Project.delete_all
    Category.delete_all
  end
end

# Working around CVE-2012-5664 requires us to convert all ID params
# to strings. Let's switch to using string IDs in tests, otherwise
# SuperModel and/or RR will fail (as strings are not fixnums).

module SuperModel
  class Base
    def generate_id
      object_id.to_s
    end
  end
end

class Ability
  include CanCan::Ability

  def initialize(user)
  end
end

class Category < SuperModel::Base
  has_many :projects
end

module Sub
  class Project < SuperModel::Base
    belongs_to :category
    attr_accessor :category # why doesn't SuperModel do this automatically?

    def self.respond_to?(method, include_private = false)
      if method.to_s == "find_by_name!" # hack to simulate ActiveRecord
        true
      else
        super
      end
    end
  end
end

class Project < SuperModel::Base
  belongs_to :category
  attr_accessor :category # why doesn't SuperModel do this automatically?

  def self.respond_to?(method, include_private = false)
    if method.to_s == "find_by_name!" # hack to simulate ActiveRecord
      true
    else
      super
    end
  end
end
