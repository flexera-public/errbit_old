require 'digest/md5'

# A deliberately simplistic fingerprint that considers ONLY the error class and top of the backtrace
# (i.e. the line on which the exception was raised). This is useful for applications that generate
# a large volume of errors that have different messages or backtraces
class SimplisticFingerprint < Fingerprint
  def fingerprint_source
    {
      :location        => location,
      :error_class     => notice.error_class,
    }
  end

  private
  def location
    notice.backtrace.lines.first
  end
end
