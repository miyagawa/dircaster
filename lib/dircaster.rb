require "dircaster/version"
require "pathname"
require "mp3info"
require "erb"
require "time"

module Dircaster
  class Task
    include ERB::Util

    attr_accessor :dir, :base, :feed, :files
    def initialize(dir, base = nil)
      @dir, @base = Pathname.new(dir), base.dup
      @base.chop! if /\/$/ === @base
      @files = []
    end

    def run
      collect_files
      generate_feed
    end

    def collect_files
      walk_down(dir, dir)
    end

    def walk_down(dir, root)
      dir.children.each do |file|
        if /\.mp3$/ === file.to_s
          mp3 = MP3.new(file, base, root)
          files.push(mp3) if mp3.valid?
        elsif file.directory?
          walk_down(file, root)
        end
      end
    end

    def generate_feed
      template = File.expand_path(File.dirname(__FILE__) + '/dircaster/rss.erb')
      vars = {
        title: "#{dir.basename} Podcast",
        link: base,
        description: "Audio files in #{dir}",
        now: Time.now,
        files: files.sort_by(&:mtime).reverse,
      }
      puts ERB.new(File.open(template).read).result(binding)
    end
  end

  class MP3
    def initialize(file, base, root)
      @file = file
      @info, @tag = parse_mp3(file)
      @base = base
      @root = root
    end

    def valid?
      !@info.nil?
    end

    def parse_mp3(file)
      info = Mp3Info.open(file)
      [info, info.tag]
    rescue Mp3InfoError
      nil
    end

    def duration
      @duration ||= Duration.new(@info.length.to_i)
    end

    def artist
      @tag['artist']
    end

    def album
      @tag['album']
    end

    def title
      @tag['title'] || @file.basename
    end

    def genre
      @tag['genre_s']
    end

    def decode_values(tag)
      tag.each do |k, v|
        if v.is_a? String
          v.force_encoding "utf-8"
          tag[k] = v
        end
      end
    end

    def size
      @file.size
    end

    def description
      @tag['comments'] || name
    end

    def name
      @file.basename.to_s
    end

    def mtime
      @file.mtime
    end

    def url
      @base.to_s + '/' + @file.relative_path_from(@root).to_s
    end
  end

  class Duration
    def initialize(sec)
      @second = sec
      @hour, @minute = 0, 0
      if @second >= 60
        @minute, @second = div(@second, 60)
      end
      if @minute >= 60
        @hour, @minute = div(@minute, 60)
      end
    end

    def div(number, base)
      [number / base, number % base]
    end

    def format
      if @hour > 0
        "%d:%02d:%02d" % [@hour, @minute, @second]
      else
        "%02d:%02d" % [@minute, @second]
      end
    end
  end
end
