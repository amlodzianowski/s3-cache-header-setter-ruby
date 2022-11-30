require 'json'

require_relative '../../header_setter/handler'

input = JSON.parse(File.read('./spec/fixtures/s3_event.json'))

describe 'handler' do # rubocop:disable RSpec/DescribeClass, RSpec/MultipleDescribes
  let(:s3file_mock) { double }

  it 'returns proper response if cache is set' do
    allow(s3file_mock).to receive(:cache_control_configured).and_return(true)

    allow(HeaderSetter::S3File).to receive(:new).and_return(s3file_mock)

    expected = 'File: my-s3-bucket/testpath/subfolder/HappyFace.jpg already has a cache control setting'
    expect(handler(event: input, context: {})).to eq(expected)
  end

  it 'returns proper response if cache is not set' do
    allow(s3file_mock).to receive(:cache_control_configured).and_return(false)
    allow(s3file_mock).to receive(:configure_cache_control)

    allow(HeaderSetter::S3File).to receive(:new).and_return(s3file_mock)

    expected = 'Configured cache control on file: my-s3-bucket/testpath/subfolder/HappyFace.jpg'
    expect(handler(event: input, context: {})).to eq(expected)
  end

  it 'returns proper response if object cannot be accessed' do
    allow(s3file_mock).to receive(:cache_control_configured).and_raise(UnableToAccessObject)

    allow(HeaderSetter::S3File).to receive(:new).and_return(s3file_mock)

    expected = 'Unable to process file: my-s3-bucket/testpath/subfolder/HappyFace.jpg. Error: UnableToAccessObject'
    expect(handler(event: input, context: {})).to eq(expected)
  end
end

describe HeaderSetter::S3Event do
  it 'returns the bucket name' do
    event = described_class.new(input)
    expect(event.bucket_name).to eq('my-s3-bucket')
  end

  it 'returns the key name' do
    event = described_class.new(input)
    expect(event.key).to eq('testpath/subfolder/HappyFace.jpg')
  end

  it 'raises an error if it cant parse the payload' do
    expect { described_class.new({}) }.to raise_error(UnableToProcessEventError)
  end
end
