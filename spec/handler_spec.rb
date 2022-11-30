require 'json'

require_relative '../header_setter/handler'

input = JSON.parse(File.read('./spec/fixtures/s3_event.json'))

describe 'handler' do # rubocop:disable Metrics/BlockLength
  it 'returns proper response if cache is set' do
    s3file_mock = double
    allow(s3file_mock).to receive(:cache_control_configured).and_return(true)
    allow(s3file_mock).to receive(:configure_cache_control)

    allow(HeaderSetter::S3File).to receive(:new).and_return(s3file_mock)

    result = handler(event: input, context: {})
    expected = 'File: my-s3-bucket/testpath/subfolder/HappyFace.jpg already has a cache control setting'
    expect(result).to eq(expected)
  end

  it 'returns proper response if cache is not set' do
    s3file_mock = double
    allow(s3file_mock).to receive(:cache_control_configured).and_return(false)
    allow(s3file_mock).to receive(:configure_cache_control)

    allow(HeaderSetter::S3File).to receive(:new).and_return(s3file_mock)

    result = handler(event: input, context: {})
    expected = 'Configured cache control on file: my-s3-bucket/testpath/subfolder/HappyFace.jpg'
    expect(result).to eq(expected)
  end

  it 'returns proper response if object cannot be accessed' do
    s3file_mock = double
    allow(s3file_mock).to receive(:cache_control_configured).and_raise(UnableToAccessObject)

    allow(HeaderSetter::S3File).to receive(:new).and_return(s3file_mock)

    result = handler(event: input, context: {})
    expected = 'Unable to process file: my-s3-bucket/testpath/subfolder/HappyFace.jpg. Error: UnableToAccessObject'
    expect(result).to eq(expected)
  end
end

describe 'S3Event' do
  it 'returns the bucket and key names' do
    event = HeaderSetter::S3Event.new(input)
    expect(event.bucket_name).to eq('my-s3-bucket')
    expect(event.key).to eq('testpath/subfolder/HappyFace.jpg')
  end

  it 'raises an error if it cant parse the payload' do
    expect { HeaderSetter::S3Event.new({}) }.to raise_error(UnableToProcessEventError)
  end
end
