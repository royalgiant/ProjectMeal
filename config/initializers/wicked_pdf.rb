# replace your config/initializers/wicked_pdf.rb with this
module WickedPdfHelper
  if Rails.env.development?
    if RbConfig::CONFIG['host_os'] =~ /linux/
      executable = RbConfig::CONFIG['host_cpu'] == 'x86_64' ? 'wkhtmltopdf_linux_x64' : 'wkhtmltopdf_linux_386'
    elsif RbConfig::CONFIG['host_os'] =~ /darwin/
      executable = 'wkhtmltopdf_darwin_386'
    else
      raise 'Invalid platform. Must be running linux or intel-based Mac OS.'
    end

    WickedPdf.config = { exe_path: "#{Gem.bin_path('wkhtmltopdf-binary').match(/(.+)\/.+/).captures.first}/#{executable}"}
  end

  def wicked_pdf_stylesheet_link_tag(*sources)
    sources.collect { |source|
      asset = Rails.application.assets.find_asset("#{source}.css")

      if asset.nil?
        raise "could not find asset for #{source}.css"
      else
        "<style type='text/css'>#{asset.body}</style>"
      end
    }.join("\n").gsub(/url\(['"](.+)['"]\)(.+)/,%[url("#{wicked_pdf_image_location("\\1")}")\\2]).html_safe
  end
end