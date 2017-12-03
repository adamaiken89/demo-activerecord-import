class UsersController < ApplicationController

  ITERATION = 2_000
  def batch_create
    require 'database_cleaner'
    DatabaseCleaner.strategy = :truncation
    cleanup_db
    require 'faker'

    # ### Not using activerecord import
    no_ari_time = benchmarking {
      ITERATION.times do |i|
        create_random_user.save!
      end
    }

    ## Not using activerecord import
    ari_time = benchmarking {
      users = []
      ITERATION.times do |i|
        users << create_random_user
      end
      User.import users, batch_size: 1_000    # or use import!
    }

    redirect_to root_path, notice: "Not using activerecord-import: #{no_ari_time}s<br/>Using activerecord-import: #{ari_time}s"
   
  end

  private
    def cleanup_db
      # then, whenever you need to clean the DB
      DatabaseCleaner.clean
    
    end

    def mark_time
      Time.now
    end

    def benchmarking
      start_time = mark_time
      
      yield
      end_time = mark_time
      cleanup_db
      measured_time = (end_time - start_time)
    end

    def create_random_user
      random_count = ((1..100).to_a)
      User.new(
        name: Faker::Name.unique.name + random_count.sample.to_s,
        email: Faker::Internet.email + random_count.sample.to_s,
        age: random_count.sample,
        job: Faker::Job.title,
        company: Faker::Company.name,
        )
    end
end
