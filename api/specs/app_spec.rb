require_relative 'spec_helper'
require 'rspec_api_documentation/dsl'

resource "Orders" do
  get "/" do
    example "Listing orders" do
      do_request

      expect(status).to eq 200
    end
  end
end