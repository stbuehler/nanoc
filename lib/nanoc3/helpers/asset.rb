# encoding: utf-8

module Nanoc3::Helpers
  module Asset
    TMP_ASSET_ITEMS_DIR = 'tmp/asset_items'
    OUTPUT_ASSET_DIR = 'assets'

    def register_asset(key, extension, &block)
      csum = key.checksum
      path = '/' + OUTPUT_ASSET_DIR + '/' + csum + extension
      assetdir = File.join(@site.config[:output_dir], OUTPUT_ASSET_DIR)
      fname = File.join(assetdir, csum + extension)

      FileUtils.mkdir_p(TMP_ASSET_ITEMS_DIR)
      tempfile = Tempfile.new(fname.gsub(/[^A-Za-z0-9.]/, '-'), TMP_ASSET_ITEMS_DIR)
      tmpfname = File.expand_path(tempfile.path)
      tempfile.close!

      FileUtils.mkdir_p(assetdir)
      @site.compiler.asset_registry.register(@item_rep, fname)
      unless File.exists?(fname)
        block.call(tmpfname)
        raise "register_asset block didn't generate the expected output file: #{tmpfname}" unless File.exists?(tmpfname)
        File.rename(tmpfname, fname)
      end
      path
    end
  end
end
