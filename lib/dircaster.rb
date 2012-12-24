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
      @dir, @base = Pathname.new(dir), base
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
          files.push MP3.new(file, base, root)
        elsif file.directory?
          walk_down(file, root)
        end
      end
    end

    def generate_feed
      template = File.expand_path(File.dirname(__FILE__) + '/dircaster/rss.erb')
      vars = {
        title: "Podcast feed of #{dir.basename}",
        link: base,
        description: "Audio files in #{dir}",
        now: Time.now,
        files: files,
      }
      puts ERB.new(File.open(template).read).result(binding)
    end
  end

  class MP3
    def initialize(file, base, root)
      @file = file
      @tag = decode_values(Mp3Info.open(file).tag)
      @base = base
      @root = root
    end

    def artist
      @tag['artist']
    end

    def album
      @tag['album']
    end

    def title
      @tag['title']
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
end
