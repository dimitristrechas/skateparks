RSpec.shared_context 'admin authenticated' do
  before do
    allow_any_instance_of(ApplicationController)
      .to receive(:http_basic_authenticate_or_request_with)
      .and_return(true)
  end
end
