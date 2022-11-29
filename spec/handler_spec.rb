require_relative '../header_setter/handler'

describe 'handler' do
  it 'returns the correct status code' do
    result = handler({})
    expect(result[:statusCode]).to eq(200)
  end
end
