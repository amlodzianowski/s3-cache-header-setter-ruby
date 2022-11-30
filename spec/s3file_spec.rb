require_relative '../header_setter/s3file'

bucket_name = 'my-s3-bucket'
object_key = 'testpath/subfolder/HappyFace.jpg'

describe 'S3File cache_control_configured' do
  it 'returns true if its configured' do
    s3 = Aws::S3::Client.new(stub_responses: true)
    s3.stub_responses(:head_object, { content_type: 'image/jpeg', cache_control: CACHE_CONTROL_VALUE })
    file = HeaderSetter::S3File.new(bucket_name, object_key, s3)
    expect(file.cache_control_configured).to eq(true)
  end

  it 'returns false if its not configured' do
    s3 = Aws::S3::Client.new(stub_responses: true)
    s3.stub_responses(:head_object, { content_type: 'image/jpeg', cache_control: nil })
    file = HeaderSetter::S3File.new(bucket_name, object_key, s3)
    expect(file.cache_control_configured).to eq(false)
  end

  it 'throws an error if file is not found' do
    s3 = Aws::S3::Client.new(stub_responses: true)
    s3.stub_responses(:head_object, 'NotFound')
    file = HeaderSetter::S3File.new(bucket_name, object_key, s3)
    expect { file.cache_control_configured }.to raise_error(UnableToAccessObject)
  end
end

describe 'S3File configure_cache_control' do
  it 'configures cache control properly' do
    s3 = Aws::S3::Client.new(stub_responses: true)
    s3.stub_responses(:copy_object, { copy_object_result: {}, request_charged: 'requester' })
    file = HeaderSetter::S3File.new(bucket_name, object_key, s3)
    file.configure_cache_control
    expect(s3.api_requests.first[:params][:key]).to eq(object_key)
    expect(s3.api_requests.first[:params][:bucket]).to eq(bucket_name)
  end
end
