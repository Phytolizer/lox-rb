# frozen_string_literal: true

require 'attr_extras'

module Expr
  class Base
  end

  ## Visits the AST.
  module Visitor
    attr_implement :visit_binary_expr, [:expr]
    attr_implement :visit_grouping_expr, [:expr]
    attr_implement :visit_literal_expr, [:expr]
    attr_implement :visit_unary_expr, [:expr]
    attr_implement :visit_variable_expr, [:expr]
  end

  ## A binary expression.
  ## x + y
  class Binary < Base
    attr_value_initialize :left, :operator, :right

    def accept(visitor)
      visitor.visit_binary_expr(self)
    end
  end

  ## A grouping expression.
  ## (1)
  class Grouping < Base
    attr_value_initialize :expression

    def accept(visitor)
      visitor.visit_grouping_expr(self)
    end
  end

  ## A literal expression
  ## 1
  class Literal < Base
    attr_value_initialize :value

    def accept(visitor)
      visitor.visit_literal_expr(self)
    end
  end

  ## A unary expression.
  ## -1
  class Unary < Base
    attr_value_initialize :operator, :right

    def accept(visitor)
      visitor.visit_unary_expr(self)
    end
  end

  class Variable < Base
    attr_value_initialize :name

    def accept(visitor)
      visitor.visit_variable_expr(self)
    end
  end
end

module Stmt
  class Base
  end

  module Visitor
    attr_implement :visit_expression_stmt, [:stmt]
    attr_implement :visit_print_stmt, [:stmt]
    attr_implement :visit_var_stmt, [:stmt]
  end

  class Expression < Base
    attr_value_initialize :expression

    def accept(visitor)
      visitor.visit_expression_stmt(self)
    end
  end

  class Print < Base
    attr_value_initialize :expression

    def accept(visitor)
      visitor.visit_print_stmt(self)
    end
  end

  class Var < Base
    attr_value_initialize :name, :initializer

    def accept(visitor)
      visitor.visit_var_stmt(self)
    end
  end
end
