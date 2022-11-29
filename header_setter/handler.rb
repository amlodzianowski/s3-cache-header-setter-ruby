require 'json'

def handler(event, _context = {})
  puts "Received Request: #{event}"

  { statusCode: 200,
    body: JSON.generate("Go Serverless v1.0! Your function executed successfully! #{event['body']}") }
rescue StandardError => e
  puts e.message
  puts e.backtrace.inspect
  { statusCode: 400, body: JSON.generate('Bad request, please POST a request body!') }
end
