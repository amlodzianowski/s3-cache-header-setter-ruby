require 'aws-sdk-s3'
require_relative 'settings'

class UnableToAccessObject < StandardError
end

module HeaderSetter
  # S3 File
  class S3File
    # Initialize class.
    #
    # @param [String] bucket_name S3 Bucket name.
    # @param [String] key S3 Object key.
    # @param [String] s3_client AWS SDK S3 Client.
    def initialize(bucket_name, key, s3_client)
      @bucket_name = bucket_name
      @key = key
      @s3 = s3_client
    end

    # Is cache control configured on an object.
    #
    # @return [true] if so
    def cache_control_configured
      head_object.cache_control == CACHE_CONTROL_VALUE
    end

    # Get S3 object metadata.
    #
    # @return [Aws::S3::Types::HeadObjectOutput]
    #
    # @raise [UnableToAccessObject] if the object cannot be described
    def head_object
      @head_object ||= @s3.head_object(bucket: @bucket_name, key: @key)
    rescue Aws::S3::Errors::NotFound, Aws::S3::Errors::Forbidden => e
      raise UnableToAccessObject, "Unable to access object: #{e}"
    end

    # Configure Cache Control on an S3 object.
    #
    # @return [Aws::S3::Types::CopyObjectOutput]
    def configure_cache_control
      @s3.copy_object(
        bucket: @bucket_name,
        copy_source: "/#{@bucket_name}/#{@key}",
        key: @key,
        cache_control: CACHE_CONTROL_VALUE,
        content_type: head_object.content_type,
        metadata_directive: 'REPLACE',
        metadata: head_object.metadata,
        tagging_directive: 'COPY'
      )
    end
  end
end
