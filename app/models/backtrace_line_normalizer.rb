require 'open-uri'
require 'sourcemap'

class BacktraceLineNormalizer
  @@source_maps = {}

  def initialize(raw_line)
    @raw_line = raw_line || {}
  end

  def call
    @raw_line.merge 'file' => normalized_file, 'method' => normalized_method
  end

  private
  def normalized_file
    if @raw_line['file'].blank?
      "[unknown source]"
    elsif @raw_line['file'].starts_with?('http')
      file, line = @raw_line['file'].split(/:(\d+$)/)
      @@source_maps[file] ||= {}
      contents = (@@source_maps[file][:source] ||= open(file).read)

      if (match = contents.lines.to_a.last.match(/# sourceMappingURL=(\S+)/))
        @@source_maps[file][:map] ||= SourceMap::Map.from_json(open(URI.join(file, match[1])).read)
        source_map = @@source_maps[file][:map]

        mapped = source_map.bsearch(SourceMap::Offset.new(line.to_i, @raw_line['number'].to_i))
        _, revision, file = mapped.source.split(/^\/([^\/]*)\/(.*)/)

        @raw_line['method'] = mapped.name if mapped.name
        @raw_line['number'] = mapped.original.line.to_s

        if revision =~ /\w{40}/
          @raw_line['revision'] = revision
          @raw_line['file'] = "[PROJECT_ROOT]#{file}"
        else
          @raw_line['file'] = "[PROJECT_ROOT]/#{revision}/#{file}"
        end
      end
    else
      file = @raw_line['file'].to_s
      # Detect lines from gem
      file.gsub!(/\[PROJECT_ROOT\]\/.*\/ruby\/[0-9.]+\/gems/, '[GEM_ROOT]/gems')
      # Strip any query strings
      file.gsub!(/\?[^\?]*$/, '')
      @raw_line['file'] = file
    end
  end

  def normalized_method
    if @raw_line['method'].blank?
      "[unknown method]"
    else
      @raw_line['method'].to_s.gsub(/[0-9_]{10,}+/, "__FRAGMENT__")
    end
  end

end
