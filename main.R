# Main pipeline runner: executes prep and analysis scripts in order.

infer_main_dir_from_calls <- function() {
  call_text <- vapply(sys.calls(), function(x) paste(deparse(x), collapse = ''), character(1))
  source_calls <- call_text[grepl('source\\(', call_text)]
  if (length(source_calls) == 0) {
    return(NULL)
  }

  pattern <- 'source\\((file\\s*=\\s*)?["\']([^"\']+main\\.R)["\']'
  for (call_str in rev(source_calls)) {
    m <- regexec(pattern, call_str, perl = TRUE)
    parts <- regmatches(call_str, m)[[1]]
    if (length(parts) >= 3) {
      candidate <- parts[[3]]
      if (file.exists(candidate)) {
        return(dirname(normalizePath(candidate)))
      }
    }
  }
  NULL
}

get_main_dir <- function() {
  for (i in rev(seq_along(sys.frames()))) {
    ofile <- sys.frame(i)$ofile
    if (!is.null(ofile) && nzchar(ofile)) {
      return(dirname(normalizePath(ofile)))
    }
  }

  from_calls <- infer_main_dir_from_calls()
  if (!is.null(from_calls)) {
    return(from_calls)
  }

  normalizePath(getwd())
}

PROJECT_DIR <- get_main_dir()
setwd(PROJECT_DIR)
SOURCE_ROOT <- PROJECT_DIR

scripts <- c(
  file.path(PROJECT_DIR, 'Analyses', 'data preparation', 'scripts', 'prepare_analysis_data.R'),
  file.path(PROJECT_DIR, 'Analyses', 'raw data plots', 'scripts', 'raw_data_stacked_bars.R'),
    file.path(PROJECT_DIR, 'Analyses', 'raw data plots', 'scripts', 'raw_data_stacked_bars_by_group.R'),
  file.path(PROJECT_DIR, 'Analyses', 'general issue concern LCA', 'scripts', 'general_issue_concern_lca.R'),
  file.path(PROJECT_DIR, 'Analyses', 'Animal actions regression', 'scripts', 'animal_actions_models.R'),
  file.path(PROJECT_DIR, 'Analyses', 'Animal issue concern EFA', 'scripts', 'animal_issue_concern_efa.R'),
  file.path(PROJECT_DIR, 'Analyses', 'factor-cluster segmentation', 'scripts', 'fca_subsets_factor_cluster_segmentation.R'),
  file.path(PROJECT_DIR, 'Analyses', 'factor-cluster segmentation', 'scripts', 'plot_factor_scores_by_fca_segments_with_labels.R'),
  file.path(PROJECT_DIR, 'Analyses', 'factor-cluster segmentation', 'scripts', 'plot_selected_varcats_by_fca_segments.R'),
  file.path(PROJECT_DIR, 'Analyses', 'factor-cluster segmentation', 'scripts', 'plot_demographics_stacked_by_segment.R'),
  file.path(PROJECT_DIR, 'Analyses', 'factor-cluster segmentation', 'scripts', 'detect_segment_rank_reordering.R')
)
for (script in scripts) {
  if (!file.exists(script)) {
    stop(sprintf('Missing script: %s', script))
  }
  cat(sprintf('Running %s...\n', script))
  source(script)
}

cat('All scripts completed.\n')




