module Dapp
  module Config
    module Directive
      class GitArtifactLocal < Base
        attr_reader :_owner, :_group

        def initialize
          @_export = []
          super
        end

        def owner(owner)
          @_owner = owner
        end

        def group(group)
          @_group = group
        end

        def export(absolute_dir_path = '/', &blk)
          @_export << self.class.const_get('Export').new(absolute_dir_path, &blk)
        end

        def _export
          @_export.each do |export|
            export._owner ||= @_owner
            export._group ||= @_group

            yield(export) if block_given?
          end
        end

        protected

        class Export < Directive::Base
          attr_accessor :_cwd, :_include_paths, :_exclude_paths, :_owner, :_group

          def initialize(cwd)
            raise Error::Config, code: :export_cwd_absolute_path_required unless Pathname(cwd).absolute?
            @_cwd = cwd
            @_include_paths ||= []
            @_exclude_paths ||= []

            super()
          end

          def to(absolute_path)
            raise Error::Config, code: :export_to_absolute_path_required unless Pathname(absolute_path).absolute?
            @_to = absolute_path
          end

          def include_paths(*relative_paths)
            raise Error::Config, code: :export_include_paths_relative_path_required unless relative_paths.all? { |path| Pathname(path).relative? }
            _include_paths.concat(relative_paths)
          end

          def exclude_paths(*relative_paths)
            raise Error::Config, code: :export_exclude_paths_relative_path_required unless relative_paths.all? { |path| Pathname(path).relative? }
            _exclude_paths.concat(relative_paths)
          end

          def owner(owner)
            @_owner = owner
          end

          def group(group)
            @_group = group
          end
        end
      end
    end
  end
end
