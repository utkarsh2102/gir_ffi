SimpleCov.start do
  track_files "lib/**/*.rb"
  add_filter "/test/"
  enable_coverage :branch
end
