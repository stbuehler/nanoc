# encoding: utf-8

module Nanoc3::Helpers
  module Cache
    TMP_CACHED_SNIPPETS_DIR = 'tmp/cached_snippets'

    def cache(input, &block)
      cachefile = File.join(TMP_CACHED_SNIPPETS_DIR, input.checksum)
      unless File.exists?(cachefile)
        result = block.call.to_s
        FileUtils.mkdir_p(TMP_CACHED_SNIPPETS_DIR)
        File.open(cachefile, 'w') {|f| f.write(result) }
        result
      else
        File.open(cachefile).read
      end
    end

  end
end

