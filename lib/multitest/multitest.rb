require File.join(File.dirname(__FILE__), 'pipe_dream')
require 'test/unit/testresult'
require 'test/unit'

# The ability to test multiple files across multiple cores
# simultaneously
class Multitest
  @@cores = 2
  def self.cores
    @@cores
  end
  def self.cores=(c)
    @@cores = c
  end
  # Takes an options hash.
  #   :files => files to test
  #   :cores => number of cores to use
  def initialize(files, cores = Multitest.cores)
    @files = files
    @cores = cores
    @children = []
    @threads = []
    @pipes = []
    
    Test::Unit.run = true
    @files.each{|f| load f}
  end

  # Run the tests that have been setup
  def run
    return if @files.empty?
    $stderr.write @files.inspect+"\n"; $stderr.flush
    @cores.times do |c|
      @pipes << PipeDream.new
      @children << Process.fork do
        Signal.trap("TERM") { exit }
        Signal.trap("HUP") { exit }
        pipe = @pipes.last
        pipe.identify_as_child
        pipe.write("[Worker #{c}] Booted\n")
        while !pipe.eof?
          file = pipe.gets.chomp
          begin
            pipe.write "[Worker #{c} Starting: #{file}\n"
            start = Time.now

            @result = Test::Unit::TestResult.new
            @result.add_listener(Test::Unit::TestResult::FAULT) do |value|
              # $stderr.write "\n"
              $stderr.write value
              $stderr.write "\n\n"
              $stderr.flush
            end
            klasses = Multitest.find_classes_in_file(file)
            klasses.each{|k| k.suite.run(@result){|status, name| ;}}
            
            #puts @result
            
            #unless @result[:failures].empty?
            #  puts @result[:failures].inspect
            #end
            
            #unless @result.errors.empty?
            #  puts @result.errors.inspect
            #end
            
            
            finish = Time.now
            pipe.write "[Worker #{c}] Completed: #{file} (#{finish-start})\n"
          rescue => ex
            pipe.write "[Worker #{c}] Failed: #{file} - #{ex.to_s}\n"
          end
        end
        $stderr.write @result.to_s
        $stderr.write "\n"
        $stderr.flush
        pipe.close
      end
    end

    total_files = @files.size
    @threads = []
    @pipes.each do |_p|
      @threads << Thread.new(_p) do |p|
        Signal.trap("TERM") { exit }
        p.identify_as_parent
        # boot message
        p.gets
        while !@files.empty? 
          # puts "#{total_files - @files.size}/#{total_files}"
          # send a file
          p.write("#{@files.pop}\n")
          # print the start message
          msg = p.gets
          # $stdout.write msg; $stdout.flush
          # wait for the complete message
          msg = p.gets
          # print complete message
          if msg =~ /Completed/
            # $stdout.write msg; $stdout.flush
          else
            $stderr.write msg; $stderr.flush
          end
        end
        p.close
      end
    end

    Signal.trap("TERM") do
      puts "Exiting"
      @children.each{|c| Process.kill("TERM",c)}
      @threads.each{|t| Thread.kill(t)}
    end

    @threads.each{|t| t.join}
    @children.each{|c| Process.wait(c)}
  end

  def self.find_classes_in_file(f)
    code = ""
    File.open(f) {|buffer| code = buffer.read}
    matches = code.scan /class\s+([\S]+)/
    klasses = matches.collect{|c| eval(c.first) }
    return klasses.select{|k| k.respond_to? 'suite'}
  end

end
