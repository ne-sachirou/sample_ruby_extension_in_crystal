require "./lib_ruby"

module Ruby
  macro ruby_def(_name, code)
    %proc = ->(
      rb_self : LibRuby::VALUE,
      {% for _a, i in code.args %}
      rb_arg{{ i }} : LibRuby::VALUE,
      {% end %}
    ) do
      cr_args = Tuple.new
      {% for arg, i in code.args %}
      cr_args += Tuple.new(
        {% if arg.restriction.class_name == "Nop" %}
        rb_arg{{ i }}
        {% elsif arg.restriction.resolve <= Int32 %}
        LibRuby.rb_num2int rb_arg{{ i }}
        {% elsif arg.restriction.resolve <= Nil %}
        nil
        {% elsif arg.restriction.resolve <= String %}
        LibRuby.rb_str_to_str(rb_arg{{ i }}).tap { |rb_str| break String.new LibRuby.rb_string_value_cstr pointerof(rb_str) }.as String
        {% end %}
      )
      {% end %}
      {{ code.name }}(*cr_args).to_ruby
    end
    LibRuby.rb_define_global_function{{ code.args.size }} "{{ code.name }}", %proc, {{ code.args.size }}
  end

  macro ruby_module_def(_name, code)
    {{ run "./ruby_module_def", code }}
  end
end

macro ruby(name, code)
  {{ code }}
  {% if code.class_name == "Def" %}
  Ruby.ruby_def {{ name }}, {{ code }}
  {% elsif code.class_name == "ModuleDef" %}
  Ruby.ruby_module_def {{ name }}, {{ code }}
  {% end %}
end
