class File
  def filename(file)
    File.basename file, File.extname(file)
  end
end