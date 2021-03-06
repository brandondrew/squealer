module Squealer
  class ProgressBar

    @@progress_bar = nil

    def self.new(*args)
      if @@progress_bar
        nil
      else
        @@progress_bar = super
      end
    end

    def initialize(total)
      @total = total
      @ticks = 0

      @progress_bar_width = 50
      @count_width = total.to_s.size
    end

    def start
      @start_time = clock
      @emitter = start_emitter if total > 0
      self
    end

    def finish
      @end_time = clock
      @emitter.wakeup.join if @emitter
      @@progress_bar = nil
    end

    def tick
      @ticks += 1
    end

    private

    def start_emitter
      Thread.new do
        emit
        sleep(1) and emit until done?
      end
    end

    def emit
      format = "\r[%-#{progress_bar_width}s] %#{count_width}i/%i (%i%%) [%i/s]"
      console.print format % [progress_markers, ticks, total, percentage, tps]
      emit_final if done?
    end

    def emit_final
      console.puts

      console.puts "Start: #{start_time}"
      console.puts "End: #{end_time}"
      console.puts "Duration: #{duration}"
    end

    def clock
      Time.now
    end

    def done?
      ticks >= total || end_time
    end

    def start_time
      @start_time
    end

    def end_time
      @end_time
    end

    def ticks
      @ticks
    end

    def tps
      elapsed_secs = (clock - start_time) / 60
      (ticks / elapsed_secs).ceil
    rescue
      0
    end

    def total
      @total
    end

    def percentage
      ((ticks.to_f / total) * 100).floor
    end

    def progress_markers
      "=" * ((ticks.to_f / total) * progress_bar_width).floor
    end

    def console
      $stderr
    end

    def progress_bar_width
      @progress_bar_width
    end

    def count_width
      @count_width
    end

    def total_time
      @end_time - @start_time
    end

    def duration
      duration = Time.at(total_time).utc
      duration.strftime("%H:%M:%S.#{duration.usec}")
    end

  end
end
