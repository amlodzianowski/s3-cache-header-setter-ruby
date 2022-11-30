require 'json'
require_relative 's3file'

# Lambda handler.
#
# @param [Hash] event Lambda S3 event.
# @param [Hash] context Lambda context.
#
# @return [String] Processing result
def handler(event:, context:) # rubocop:disable Lint/UnusedMethodArgument
  puts "Received event: #{event}"

  s3_event = HeaderSetter::S3Event.new(event)
  puts "Received event to process following file: #{s3_event.bucket_name}/#{s3_event.key}"
  result = s3_event.process_event
  puts result
  result
end

class UnableToProcessEventError < StandardError
end

module HeaderSetter
  # Lambda S3 Event
  class S3Event
    attr_accessor :bucket_name, :key

    # Initialize class.
    #
    # @param [Hash] event Lambda event.
    #
    # @raise [UnableToProcessEventError] if the event cannot be parsed
    def initialize(event)
      @s3_event = event
      @bucket_name = event['Records'][0]['s3']['bucket']['name']
      @key = event['Records'][0]['s3']['object']['key']
    rescue NoMethodError => e
      puts e.message
      raise UnableToProcessEventError, 'Unable to parse payload'
    end

    # Process event.
    #
    # @param [Hash] s3_event Lambda S3 event.
    #
    # @return [String] Processing result
    def process_event
      s3 = Aws::S3::Client.new
      file = HeaderSetter::S3File.new(@bucket_name, @key, s3)
      return "File: #{@bucket_name}/#{@key} already has a cache control setting" if file.cache_control_configured

      file.configure_cache_control
      "Configured cache control on file: #{@bucket_name}/#{@key}"
    rescue UnableToAccessObject => e
      "Unable to process file: #{@bucket_name}/#{@key}. Error: #{e}"
    end
  end
end
