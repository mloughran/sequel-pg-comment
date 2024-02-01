module Sequel::Postgres; end  #:nodoc:

# PostgreSQL-specific extension to set and retrieve comments on
# all database objects.
#
module Sequel::Postgres::Comment
  # The types of PostgreSQL object that are commented on in their own
  # right.
  STANDALONE_TYPES = [
    :aggregate,
    :cast,
    :collation,
    :conversion,
    :database,
    :domain,
    :extension,
    :event_trigger,
    :foreign_data_wrapper,
    :foreign_table,
    :function,
    :index,
    :large_object,
    :materialized_view,
    :operator,
    :operator_class,
    :operator_family,
    :language,
    :procedural_language,
    :role,
    :schema,
    :sequence,
    :server,
    :table,
    :tablespace,
    :text_search_configuration,
    :text_search_dictionary,
    :text_search_parser,
    :text_search_template,
    :type,
    :view,
  ]

  CONTAINED_TYPES = [
    :column,
    :constraint,
    :rule,
    :trigger,
  ]

  # Strip indenting whitespace from a comment string.
  #
  # Two rules are applied by this method:
  #
  # 1. Empty lines (that is, lines which have *no* characters in them, not
  #    even whitespace) are removed from the beginning and end of the
  #    string.
  #
  # 2. Whatever whitespace characters may be present before the first line
  #    of text will be removed from the beginning of each subsequent line
  #    of the comment, if it exists.
  #
  # This means you can use heredocs and multi-line strings without having
  # to play your own silly-buggers in order to not make the comments look
  # like arse.  If you like heredocs, you're encouraged to use that style.
  #
  # @example Heredoc-style works
  #    comment_for :table, :foo, <<-EOF
  #      This is my comment.
  #
  #      And here's another line.
  #    EOF
  #
  # On the other hand, if percent-quotes are more your cup of tea, you can
  # use those.
  #
  # @example Percent-quote style works
  #    comment_for :table, :foo, %(
  #      This is my comment.
  #
  #      And here's another line.
  #    )
  #
  # Be sure to not start the first line of your comment on the same line as
  # the quote character, though, because that will mean the first line of
  # the comment *doesn't* have any leading whitespace, and so whitespace
  # won't be trimmed from the rest of the comment.  So, don't do that.
  #
  # @example This will not work
  #    comment_for :table, :foo, %(This won't work at all well.
  #      Since the first line of text doesn't have leading whitespace,
  #      these lines won't have it stripped either, and everything will
  #      look weird.
  #    )
  #
  # @param comment [String] The comment to mangle for whitespace.
  #
  # @return [String] The normalised comment, with whitespace removed.
  #
  def self.normalise_comment(comment)
    comment.tap do |s|
      s.gsub!(/\A\n+/, "")
      s.gsub!(/\n+\Z/, "")

      (s =~ /\A(\s+)/ and lede = $1) or lede = ""
      s.gsub!(/^#{lede}/, "")
    end
  end
end

require_relative "pg_comment/database_methods"
require_relative "pg_comment/dataset_methods"

Sequel::Database.register_extension(:pg_comment) do |db|
  db.extend Sequel::Postgres::Comment::DatabaseMethods
  db.extend_datasets Sequel::Postgres::Comment::DatasetMethods
end
