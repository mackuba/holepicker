require 'holepicker/file_finder'

module HolePicker
  class DirectGemfileFinder
    SKIPPED_DIRECTORIES = [
      "-name cached-copy",
      "-path '*/bundle/ruby'",
      "-name tmp",
      "-name '.*'"
    ]

    def initialize(options = {})
      @skip_ignored = options.fetch(:skip_ignored, true)
      @only_current = options.fetch(:only_current, false)
    end

    def find_gemfiles(path)
      full_path = File.expand_path(path)
      gemfiles = @only_current ? "-path '*/current/Gemfile.lock'" : "-name 'Gemfile.lock'"
      options = @skip_ignored ? "\\( #{skipped_directories} \\) -prune -or #{gemfiles} -print" : gemfiles

      FileFinder.find_files(full_path, options)
    end

    private

    def skipped_directories
      SKIPPED_DIRECTORIES.join(" -or ")
    end
  end
end
