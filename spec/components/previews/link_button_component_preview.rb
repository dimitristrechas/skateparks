class LinkButtonComponentPreview < ViewComponent::Preview
  # @label Default
  def default
    render(LinkButtonComponent.new(title: 'Click me', url: '#'))
  end

  # @label Active
  def active
    render(LinkButtonComponent.new(title: 'Current Page', url: '#', active: true))
  end

  # @label Ghost
  def ghost
    render(LinkButtonComponent.new(title: 'Ghost Button', url: '#', ghost: true))
  end

  # @label External Link
  def external
    render(LinkButtonComponent.new(title: 'Open External', url: 'https://example.com', target: '_blank'))
  end

  # @label Large
  def large
    render(LinkButtonComponent.new(title: 'Large Button', url: '#', large: true))
  end

  # @label With Icon Before
  def with_icon_before
    render(LinkButtonComponent.new(title: 'Open Maps', url: '#')) do |c|
      c.with_icon_before do
        icon_svg
      end
    end
  end

  # @label With Icon After
  def with_icon_after
    render(LinkButtonComponent.new(title: 'Next Page', url: '#')) do |c|
      c.with_icon_after do
        arrow_right_svg
      end
    end
  end

  # @label With Both Icons
  def with_both_icons
    render(LinkButtonComponent.new(title: 'Navigate', url: '#')) do |c|
      c.with_icon_before { icon_svg }
      c.with_icon_after { arrow_right_svg }
    end
  end

  private

  # rubocop:disable Rails/OutputSafety
  def icon_svg
    <<~SVG.html_safe
      <svg class="h-5 w-5" xmlns="http://www.w3.org/2000/svg" fill="currentColor" viewBox="0 0 16 20">
        <path d="M8 0a7.992 7.992 0 0 0-6.583 12.535 1 1 0 0 0 .12.183l.12.146c.112.145.227.285.326.4l5.245
          6.374a1 1 0 0 0 1.545-.003l5.092-6.205c.206-.222.4-.455.578-.7l.127-.155a.934.934 0 0 0
          .122-.192A8.001 8.001 0 0 0 8 0Zm0 11a3 3 0 1 1 0-6 3 3 0 0 1 0 6Z"/>
      </svg>
    SVG
  end

  def arrow_right_svg
    <<~SVG.html_safe
      <svg class="h-5 w-5" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke="currentColor">
        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="m9 5 7 7-7 7"/>
      </svg>
    SVG
  end
  # rubocop:enable Rails/OutputSafety
end
