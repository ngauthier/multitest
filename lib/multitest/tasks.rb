module Multitest::Tasks
  desc "Test all your code in parallel"
  task :multitest => ['multitest:units', 'multitest:functionals', 'multitest:integration']
  
  namespace :multitest do
    desc "Multi-core test:units"
    task :units => [:environment] do
      pattern = 'test/unit/**/*_test.rb'
      files = Dir.glob(pattern)
      $stderr.write "Running multitest:units\n"
      Multitest.new(files).run
      $stderr.write "Completed multitest:units\n\n"
    end
    desc "Multi-core test:functionals"
    task :functionals => [:environment] do
      pattern = 'test/functional/**/*_test.rb'
      files = Dir.glob(pattern)
      $stderr.write "Running multitest:functionals\n"
      Multitest.new(files).run
      $stderr.write "Completed multitest:functionals\n\n"
    end
    desc "Multi-core test:integration"
    task :integration => [:environment] do
      pattern = 'test/integration/**/*_test.rb'
      files = Dir.glob(pattern)
      $stderr.write "Running multitest:integration\n"
      Multitest.new(files).run
      $stderr.write "Completed multitest:integration\n\n"
    end
  end
end
