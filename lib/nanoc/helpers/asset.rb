# encoding: utf-8

module Nanoc::Helpers
  module Asset
    OUTPUT_ASSET_DIR = 'assets'

    # Registers an asset (linked from the current item representation); the
    # filename for the asset is generated from the checksum of the key and the extension.
    #
    # If the file doesn't exist, the associated block is called with a target filename;
    # the block should write the results into this file.
    # The result should only depend on the key which is used for the checksum to ensure
    # unique filenames.
    #
    # Example:
    #     def store_in_file(&block)
    #       text = capture(&block)
    #       path = register_asset(['store_in_file', text], '.txt') do |fname|
    #         File.open(fname, 'w') {|f| f.write(text) }
    #       end
    #       erbout = eval('_erbout', block.binding)
    #       erbout << '<pre>' + html_escape(text) + '</pre><br />(' + link_to('source', path) + ')<br />'
    #     end
    #
    #     # <% store_in_file do %>Foo<% end %>
    #
    # @param [Object] key to derive checksum from. for example an array including
    #   a module name, a shell command and the source content
    # @param [String] filename extension, for example '.png'
    #
    # @return [String] url path to the generated asset
    def register_asset(key, extension, &block)
      csum = key.checksum
      # url
      path = '/' + OUTPUT_ASSET_DIR + '/' + csum + extension
      # target dir/file on disk
      assetdir = File.join(@site.config[:output_dir], OUTPUT_ASSET_DIR)
      fname = File.join(assetdir, csum + extension)

      # temporary dir/file on disk
      FileUtils.mkdir_p(Nanoc::Filter::TMP_BINARY_ITEMS_DIR)
      tempfile = Tempfile.new([csum, extension], Nanoc::Filter::TMP_BINARY_ITEMS_DIR)
      tmpfname = File.expand_path(tempfile.path)
      tempfile.close!

      FileUtils.mkdir_p(assetdir)
      @site.compiler.asset_registry.register(@item_rep, fname)
      unless File.exists?(fname)
        block.call(tmpfname)
        raise "register_asset block didn't generate the expected output file: #{tmpfname}" unless File.exists?(tmpfname)
        # move file into place after it was successfully generated
        File.rename(tmpfname, fname)
      end
      path
    end
  end
end
