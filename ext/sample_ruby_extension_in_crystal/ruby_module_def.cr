require "compiler/crystal/syntax/**"

class RubyModuleDefVisitor < Crystal::Visitor
  @mod_name : String?

  def initialize
    @seq = -1
  end

  def visit(node : Crystal::ModuleDef)
    @mod_name = node.name.names.join "::"
    puts "mod = LibRuby.rb_define_module \"#{@mod_name}\", LibRuby.rb_cObject"
    node.accept_children self
  end

  def visit(node : Crystal::Def)
    @seq += 1
    puts "proc#{@seq} = ->(rb_self : LibRuby::VALUE,"
    node.args.size.times { |i| puts "rb_arg#{i} : LibRuby::VALUE," }
    puts ") do"
    puts "cr_args = Tuple.new"
    node.args.each_with_index do |arg, i|
      puts "cr_args += Tuple.new("
      case arg.restriction.try &.to_s
      when nil      then puts "rb_arg#{i}"
      when "Int32"  then puts "LibRuby.rb_num2int rb_arg#{i}"
      when "Nil"    then puts "nil"
      when "String" then puts "LibRuby.rb_str_to_str(rb_arg#{i}).tap { |rb_str| break String.new LibRuby.rb_string_value_cstr pointerof(rb_str) }.as String"
      else               puts "rb_arg#{i}"
      end
      puts ")"
    end
    puts "#{@mod_name.not_nil!}.#{node.name}(*cr_args).to_ruby"
    puts "end"
    puts "LibRuby.rb_define_module_function#{node.args.size} mod, \"#{node.name}\", proc#{@seq}, #{node.args.size}"
  end

  def visit(node : Crystal::Expressions)
    node.accept_children self
  end

  def visit(node : Crystal::ASTNode)
  end
end

mod = Crystal::Parser.parse(ARGV[0].gsub "\\n", "\n").as Crystal::ModuleDef
visitor = RubyModuleDefVisitor.new
mod.accept visitor
