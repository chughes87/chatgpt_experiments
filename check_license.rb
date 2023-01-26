require 'optparse'

options = {}
OptionParser.new do |opts|
  opts.banner = 'Usage: check_license.rb [options]'

  opts.on('-i', '--image [IMAGE]', 'Path to image') do |v|
    options[:image] = v
  end

end.parse!

# Load the trained model
model = TensorFlow.load_model('drivers_license_model.h5')

# Preprocess new image
new_image = File.read(options[:image])

# Make a prediction
predictions = model.predict(new_image)

# Get the highest prediction
predicted_label = predictions.argmax

# Print the prediction
puts "Predicted label: #{predicted_label}"
