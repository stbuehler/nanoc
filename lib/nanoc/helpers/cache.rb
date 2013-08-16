# encoding: utf-8

module Nanoc::Helpers
  module Cache
    TMP_CACHED_SNIPPETS_DIR = 'tmp/cached_snippets'

    # Cache inefficient actions like syntax highlighting on disk
    # for this and future runs.
    #
    # Some actions, like changing your layout, causes all pages to be
    # recompiled; but this usually doesn't affect the outcome of highlight
    # and similar actions.
    #
    # Example:
    #     def highlight(language, &block)
    #       code = capture(&block)
    #       cmd_pygmentize = "pygmentize -O tabsize=4,encoding=utf-8,linenos=table -l #{language} -f html"
    #       doc = cache(['highlight', cmd_pygmentize, code]) do
    #         result = ''
    #         IO.popen(cmd_pygmentize, "r+") do |io|
    #           io.write(code)
    #           io.close_write
    #           highlighted_code = io.read
    #           result = Nokogiri::HTML.fragment(highlighted_code)
    #         end
    #         result.to_s
    #       end
    #       erbout = eval('_erbout', block.binding)
    #       erbout << wrapstart + doc + wrapend
    #     end
    #
    # @param [Object] key to derive checksum from. for example an array including
    #   a module name, a shell command and the source content
    #
    # @return [String] the content - either from the cache or the new calculated
    def cache(key, &block)
      cachefile = File.join(TMP_CACHED_SNIPPETS_DIR, key.checksum)
      unless File.exists?(cachefile)
        result = block.call
        FileUtils.mkdir_p(TMP_CACHED_SNIPPETS_DIR)
        File.open(cachefile, 'w') {|f| f.write(result) }
        result
      else
        File.open(cachefile).read
      end
    end

  end
end

