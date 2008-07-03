# This class exists so including the Rails HTML sanitization helpers doesn't polute your models.
class Aqueduct::RailsSanitizer
  include ActionView::Helpers::SanitizeHelper
end