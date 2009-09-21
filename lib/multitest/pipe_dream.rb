class PipeDream
  def initialize
    @child_read, @parent_write = IO.pipe
    @parent_read, @child_write = IO.pipe
  end

  def gets
    @reader.gets
  end

  def write(str)
    @writer.write(str)
    @writer.flush
    str
  end

  def eof?
    @reader.eof?
  end

  def identify_as_child
    @parent_write.close
    @parent_read.close
    @reader = @child_read
    @writer = @child_write
  end

  def identify_as_parent
    @child_write.close
    @child_read.close
    @reader = @parent_read
    @writer = @parent_write
  end

  def close
    done_reading
    done_writing
  end

  def done_writing
    @writer.close unless @writer.closed?
  end

  def done_reading
    @reader.close unless @reader.closed?
  end

  private
  def force_identification
    return "Must identify as child or parent" if @reader.nil? or @writer.nil?
  end
end
