# Event Extender Plugin :: Key combine ::par GRIM
# -----------------------------------------------------------------------------
# Ajoute une notion de composition a l'argument de key_press?
# Il est possible d'ajouter des opérations logiques par exemple =>
# key_press?(:a & :b) vérifiera que les touches a ET b sont pressées
# key_press?(:a | :b) vérifiera que la touche a OU b est pressée
# key_press?( (:a | :b | :c) & (:d & :e) ) vérifiera si soit a, b ou c ET 
# d ET e sont pressées.
#==============================================================================
# ** UI
#------------------------------------------------------------------------------
#  User interaction
#==============================================================================

module UI
  #==============================================================================
  # ** Combination
  #------------------------------------------------------------------------------
  #  Keys combination
  #==============================================================================
  class Combination
    #--------------------------------------------------------------------------
    # * Object initialize
    #--------------------------------------------------------------------------
    def initialize(op, a, b)
      @operator = op.to_sym
      @a, @b = a, b
    end
    #--------------------------------------------------------------------------
    # * Eval
    #--------------------------------------------------------------------------
    def eval(passed_method)
      resp_a = (@a.is_a?(Combination)) ? 
        @a.eval(passed_method) : Keyboard.send(passed_method, @a)
      resp_b = (@b.is_a?(Combination)) ? 
        @b.eval(passed_method) : Keyboard.send(passed_method, @b)
      return resp_a && resp_b if @operator == :&
      resp_a || resp_b
    end
    #--------------------------------------------------------------------------
    # * Logic Operators
    #--------------------------------------------------------------------------
    def &(other); Combination.new(:&, self, other); end
    def |(other); Combination.new(:|, self, other); end
  end
end

#==============================================================================
# ** Symbol
#------------------------------------------------------------------------------
#  The class that represents symbols.
#==============================================================================

class Symbol
  #--------------------------------------------------------------------------
  # * Logic Operators
  #--------------------------------------------------------------------------
  def &(other); UI::Combination.new(:&, self, other); end
  def |(other); UI::Combination.new(:|, self, other); end
end

#==============================================================================
# ** Command
#------------------------------------------------------------------------------
# Adds easily usable commands
#==============================================================================

module Command
  #--------------------------------------------------------------------------
  # * Keys press?
  #--------------------------------------------------------------------------
  def key_press?(k)
    return UI::Keyboard.press?(k) if k.is_a?(Symbol)
    k.eval(:press?)
  end
end