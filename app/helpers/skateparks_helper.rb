module SkateparksHelper
  SEGMENTED_OPTION_CLASSES = %w[
    relative z-10 flex w-full min-w-0 cursor-pointer items-center justify-center whitespace-nowrap rounded-lg
    py-2 text-center text-sm font-medium text-neutral-500 transition-colors duration-200 hover:bg-white/70
    hover:text-neutral-800 peer-focus-visible:outline peer-focus-visible:outline-2
    peer-focus-visible:outline-offset-2 peer-focus-visible:outline-neutral-700 peer-checked:text-neutral-800
    peer-checked:hover:bg-transparent peer-checked:hover:text-neutral-800 dark:text-neutral-300
    dark:hover:bg-neutral-600/35 dark:hover:text-neutral-100 dark:peer-focus-visible:outline-neutral-200
    dark:peer-checked:text-neutral-900 dark:peer-checked:hover:bg-transparent
    dark:peer-checked:hover:text-neutral-900
  ].join(' ').freeze

  def segmented_option_classes(padding)
    "#{SEGMENTED_OPTION_CLASSES} #{padding}"
  end
end
