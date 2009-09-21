module Multitest::Tasks
  desc "Test all your code in parallel"
  task :multitest => ['multitest:units', 'multitest:functionals', 'multitest:integration']
  
  namespace :multitest do
    task :units do
      pattern = 'test/unit/**/*_test.rb'
      files = Dir.glob(pattern)
      Multitest.new(files).run
    end
    task :functionals do
      pattern = 'test/functional/**/*_test.rb'
      files = Dir.glob(pattern)
      Multitest.new(files).run
    end
    task :integration do
      pattern = 'test/integration/**/*_test.rb'
      files = Dir.glob(pattern)
      Multitest.new(files).run
    end
  end
end
