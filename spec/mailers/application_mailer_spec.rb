require 'rails_helper'

RSpec.describe ApplicationMailer do
  describe 'defaults' do
    subject(:mailer_class) { described_class }

    it 'sets default from address' do
      expect(mailer_class.default[:from]).to eq('from@example.com')
    end

    it 'uses mailer layout' do
      expect(mailer_class._layout).to eq('mailer')
    end
  end
end
