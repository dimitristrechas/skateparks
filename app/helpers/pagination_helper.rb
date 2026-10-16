module PaginationHelper
  def pagination_page_link_classes
    'inline-flex min-h-8 min-w-8 shrink-0 items-center justify-center rounded-lg px-2 ' \
      'text-sm font-medium tabular-nums text-neutral-500 transition-colors duration-200 ease-out ' \
      'hover:bg-white/70 hover:text-neutral-800 ' \
      'focus-visible:outline focus-visible:outline-2 focus-visible:outline-offset-2 ' \
      'focus-visible:outline-neutral-700 ' \
      'dark:text-neutral-300 dark:hover:bg-neutral-600/35 dark:hover:text-neutral-100 ' \
      'dark:focus-visible:outline-neutral-200'
  end

  def pagination_current_page_classes
    'inline-flex min-h-8 min-w-8 shrink-0 items-center justify-center rounded-lg px-2 ' \
      'text-sm font-medium tabular-nums text-neutral-800 ' \
      'bg-white shadow-[0_1px_2px_rgba(15,23,42,0.08),0_0_0_1px_rgba(212,212,212,0.9)] ' \
      'dark:bg-neutral-100 dark:text-neutral-900'
  end

  def pagination_disabled_control_classes
    'inline-flex min-h-8 min-w-8 shrink-0 cursor-not-allowed items-center justify-center ' \
      'rounded-lg border-0 bg-transparent px-2 text-sm font-medium text-neutral-500 opacity-40 ' \
      'shadow-none dark:text-neutral-300'
  end

  def pagination_nav_classes
    'mt-12 flex justify-center'
  end

  def pagination_list_classes
    # gap-2/p-2 leave room for the 2px focus-visible ring plus 2px offset on
    # every side, so focused controls never touch each other or the container.
    'inline-flex max-w-full flex-wrap items-center justify-center gap-2 rounded-lg ' \
      'border border-neutral-300/90 p-2 dark:border-neutral-600'
  end

  # Called from inside the Kaminari paginator block, where `render` is Kaminari's own method and
  # helper calls are delegated through a non-ruby2_keywords `method_missing` (positional args only).
  def pagination_disabled_control(label, direction)
    render 'kaminari/disabled_control', label: label, direction: direction
  end
end
