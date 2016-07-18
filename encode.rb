#!/usr/bin/env ruby
# -*- encoding: utf-8 -*-

require 'pathname'

M2TS_DIR = '/home/kambara/chinachu/recorded'
MP4_DIR  = '/home/kambara/mp4'

def main
  ensure_one_process do
    log "--- START ---"
    mp4_dir.mkpath
    recorded_dir.each_child {|path|
      if path.extname == '.m2ts'
        unless is_encoded(path)
          puts "Encode: #{path.to_s}"
          encode path
        end
      end
    }
    log "FINISH"
  end
end

def is_encoded(ts)
  basename = ts.basename('.encoded.m2ts').basename('.m2ts').to_s
  (
    (mp4_dir + (basename + '.mp4')).exist? ||
    (mp4_dir + (basename + '.encode-failed')).exist?
  )
end

def encode(ts)
  start_time = Time.now
  basename = ts.basename('.encoded.m2ts').basename('.m2ts').to_s
  mp4_dir.mkpath
  mp4 = mp4_dir + (basename + '.mp4')
  unless handbrake ts, mp4
    log '!!! Encode Failed !!!'
    mp4.delete
    (mp4_dir + (basename + '.encode-failed')).open('w') {|file|
      file << 'failed'
    }
  end
  elapsed_time = ((Time.now - start_time) / 60).round
  log "#{elapsed_time} min."
end

def handbrake(ts, mp4)
  log "encode: #{ts}"
  system <<-EOS
    HandBrakeCLI \
      --input "#{ts}" \
      --output "#{mp4}" \
      --format mp4 \
      --encoder x264 \
      --maxWidth 1280 \
      --maxHeight 720 \
      --quality 20 \
      --deinterlace \
      --loose-anamorphic \
      --aencoder faac
  EOS
end

def recorded_dir
  Pathname.new(M2TS_DIR)
end

def mp4_dir
  Pathname.new(MP4_DIR)
end

def ensure_one_process
  if pid_file.exist?
    puts "'#{Pathname.new(__FILE__).basename}' is already running. (PID: #{pid_file.read})"
    exit
  end
  create_pid_file
  yield
  pid_file.delete
end

def create_pid_file
  pid_file.open('w') {|f|
    f << Process.pid
  }
end

def pid_file
  Pathname.new('/tmp') + "#{Pathname.new(__FILE__).basename}.pid"
end

def log(text)
  log_dir.mkpath
  log_file.open('a') {|f|
    f << "#{Time.now}: #{text}\n"
  }
  puts text
end

def log_dir
    source_dir + 'log'
end

def log_file
    log_dir + "#{Pathname.new(__FILE__).basename}.log"
end

def source_dir
    Pathname.new(__FILE__).expand_path.parent
end

main
