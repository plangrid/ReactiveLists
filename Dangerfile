not_declared_trivial = !(github.pr_title.include? "#trivial")
has_source_changes = !git.modified_files.grep(/Source/).empty?

# Make it more obvious that a PR is a work in progress and shouldn't be merged yet
warn("PR is classed as Work in Progress") if github.pr_title.include? "[WIP]"

# Warn when there is a big PR
warn("Big PR") if git.lines_of_code > 500

# Milestones are required to track what's included in each release
if has_source_changes && not_declared_trivial
  has_milestone = !github.pr_json['milestone'].nil?
  warn('All pull requests should have a milestone attached, unless marked *#trivial*.', sticky: false) unless has_milestone
end
