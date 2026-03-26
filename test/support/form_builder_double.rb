class FormBuilderDouble
  Expectation = Struct.new(:return_value, :matcher)

  def initialize
    @expectations = Hash.new { |hash, key| hash[key] = [] }
  end

  def expect(method_name, return_value, &matcher)
    @expectations[method_name] << Expectation.new(return_value, matcher)
  end

  def verified?
    @expectations.values.all?(&:empty?)
  end

  def button(...) = call(:button, ...)

  def label(...) = call(:label, ...)

  def text_field(...) = call(:text_field, ...)

  private

  def call(method_name, *, **)
    expectation = @expectations.fetch(method_name).shift
    raise "Unexpected #{method_name} call" unless expectation

    matcher = expectation.matcher || ->(*, **) { true }
    raise "Unexpected #{method_name} arguments" unless matcher.call(*, **)

    expectation.return_value
  end
end
