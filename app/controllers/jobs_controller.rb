# frozen_string_literal: true

require 'json'
require 'sidekiq'

class JobsController < Frack::BaseController
  def health
    json_response({ status: 'ok' })
  end

  def batch
    payload = parse_json_body
    count = (payload['count'] || 1000).to_i
    priority = payload['priority']
    args = (1..count).map { |i| [i] }

    if priority == 'high'
      Sidekiq::Client.push_bulk('class' => 'UrgentWorker', 'args' => args)
    else
      Sidekiq::Client.push_bulk('class' => 'EmailWorker', 'args' => args)
    end

    json_response({ message: "Enqueued #{count} jobs", count: count }, 201)
  rescue => e
    json_response({ error: e.message }, 500)
  end

  private

  def parse_json_body
    JSON.parse(request.body.read)
  rescue
    {}
  end

  def json_response(obj, status = 200)
    json_string = JSON.generate(obj)
    headers = {
      'Content-Type' => 'application/json',
      'Content-Length' => json_string.bytesize.to_s
    }
    [[json_string], status, headers]
  end
end