# https://github.com/phoffer/crystalized_ruby/blob/master/src/lib_ruby.cr
# MIT 2016 Paul Hoffer
lib LibRuby
  type VALUE = Void*
  type ID = Void*

  $rb_cObject : VALUE
  $rb_cNumeric : VALUE
  $rb_cBasicObject : VALUE

  # generic
  fun rb_type(value : VALUE) : Int32 # can't get this working :/
  fun rb_any_to_s(value : VALUE) : UInt8*
  fun rb_class2name(value : VALUE) : UInt8*
  # fun rb_type(value : VALUE) : UInt8*
  fun rb_funcall(value : VALUE, method : ID, argc : Int32) : VALUE
  # fun rb_nil_p(value : VALUE) : Boolean # not sure how to handle this
  fun rb_obj_dup(value : VALUE) : VALUE

  # integers
  fun rb_num2int(value : VALUE) : Int32
  fun rb_num2dbl(value : VALUE) : Float32
  fun rb_int2inum(value : Int32) : VALUE
  fun rb_float_new(value : Float32) : VALUE
  fun rb_float_new_in_heap(value : Float32) : VALUE

  # strings
  fun rb_str_to_str(value : VALUE) : VALUE
  fun rb_string_value_cstr(value_ptr : VALUE*) : UInt8*
  fun rb_str_new_cstr(str : UInt8*) : VALUE
  fun rb_utf8_encoding : VALUE
  fun rb_enc_str_new_cstr(str : UInt8*, enc : VALUE) : VALUE

  fun rb_id2sym(value : ID) : VALUE
  fun rb_intern(name : UInt8*) : ID

  # regexp
  fun rb_reg_new_str(str : VALUE, options : Int32) : VALUE # re.c:2792

  # arrays
  fun rb_ary_new : VALUE
  fun rb_ary_push(array : VALUE, value : VALUE)
  fun rb_ary_length(array : VALUE) : Int32
  fun rb_ary_shift(array : VALUE) : VALUE

  # hashes
  fun rb_hash_new : VALUE
  fun rb_hash_aset(hash : VALUE, key : VALUE, value : VALUE)
  fun rb_hash_foreach(hash : VALUE, callback : (Int32, Void* ->), data : Void*)
  fun rb_hash_keys(hash : VALUE)

  # classes & modules
  fun rb_define_class(name : UInt8*, super : VALUE) : VALUE
  fun rb_define_class_under(parent : VALUE, name : UInt8*, super : VALUE) : VALUE
  fun rb_define_module(name : UInt8*, super : VALUE) : VALUE
  fun rb_define_module_under(parent : VALUE, name : UInt8*, super : VALUE) : VALUE

  {% for i in 0..9 %}
  type METHOD_FUNC{{ i }} = {% for j in 0..i %}VALUE{% if i != j %}, {% end %}{% end %} -> VALUE

  fun rb_define_global_function{{ i }}(name : UInt8*, func : METHOD_FUNC{{ i }}, argc : Int32)

  # methods
  fun rb_define_method{{ i }}(klass : VALUE, name : UInt8*, func : METHOD_FUNC{{ i }}, argc : Int32)
  fun rb_define_singleton_method{{ i }}(klass : VALUE, name : UInt8*, func : METHOD_FUNC{{ i }}, argc : Int32)
  fun rb_define_module_function{{ i }}(module : VALUE, name : UInt8*, func : METHOD_FUNC{{ i }}, argc : Int32)
  {% end %}
end

struct Symbol
  def to_ruby
    LibRuby.rb_id2sym LibRuby.rb_intern self.to_s
  end
end

class Regex
  def to_ruby
    code = {
      Regex::Options::IGNORE_CASE => 1,
      Regex::Options::MULTILINE   => 2,
      Regex::Options::EXTENDED    => 4,
    }.reduce(0) { |code, (k, i)| self.options.includes?(k) ? code + i : code }
    LibRuby.rb_reg_new_str self.source.to_ruby, code
  end

  # RB_REGEX_OPTIONS = {
  #   'i' => Regex::Options::IGNORE_CASE,
  #   'm' => Regex::Options::MULTILINE,
  #   'x' => Regex::Options::EXTENDED,
  # }
  # def self.from_ruby(val : LibRuby::VALUE) # needs improvement
  #   str = RubyImporter.rb_any_to_str(val)
  #   self.from_ruby(str)
  # end
  # def self.from_ruby(str : String)
  #   options = str[2..5].split('-').first
  #   exp = str[7..-2]
  #   options_enum = options.chars.reduce(Regex::Options::None) { |enum_obj, char| enum_obj | RB_REGEX_OPTIONS[char] }
  #   new(exp, options_enum)
  # end
end

class Array
  def to_ruby
    LibRuby.rb_ary_new.tap do |rb_array|
      self.each do |val|
        val.inspect # stops working without this. no idea why. seriously, comment this line and it fails (at least when spitting out an array that came from ruby)
        LibRuby.rb_ary_push rb_array, val.to_ruby
      end
    end
  end

  # def self.from_ruby(ary) # this is awful
  #   rb_ary = LibRuby.rb_obj_dup(ary)
  #   element = LibRuby.rb_ary_shift(rb_ary)
  #   element = RubyImporter.scalar_from_ruby(element)
  #   arr = [element]
  #   until element.is_a?(Nil)
  #     element = LibRuby.rb_ary_shift(rb_ary)
  #     element = RubyImporter.scalar_from_ruby(element)
  #     arr << element
  #   end
  #   arr.pop
  #   arr
  # end
end

class Hash
  def to_ruby
    LibRuby.rb_hash_new.tap do |rb_hash|
      self.each do |k, v|
        LibRuby.rb_hash_aset rb_hash, k.to_ruby, v.to_ruby
      end
    end
  end

  # def self.from_ruby
  #   # RubyImporter.import_hash_key do |tick|
  #   #   puts tick
  #   # end
  #   {cant: "import ruby hashes"}
  # end
end

struct Nil
  def to_ruby
    Pointer(Void).new(8_u64).as LibRuby::VALUE
  end
end

struct Bool
  def to_ruby
    Pointer(Void).new(self ? 20_u64 : 0_u64).as LibRuby::VALUE
  end

  # def self.from_ruby(obj : LibRuby::VALUE)
  #   klass_name = RubyImporter.rb_class(obj)
  #   case klass_name
  #   when "TrueClass"
  #     true
  #   when "FalseClass"
  #     false
  #   end
  # end
end

class String
  def to_ruby
    LibRuby.rb_enc_str_new_cstr self, LibRuby.rb_utf8_encoding
  end
end

struct Int
  def to_ruby
    LibRuby.rb_int2inum self
  end

  # def self.from_ruby(int)
  #   LibRuby.rb_num2int(int)
  # end
end

struct Int32
  def to_ruby
    LibRuby.rb_int2inum self
  end
end

struct Float
  def to_ruby
    # to_i.to_ruby
    LibRuby.rb_float_new self
  end

  # def self.from_ruby(float)
  #   LibRuby.rb_num2dbl(float)
  # end
end
