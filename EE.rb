# -*- coding: utf-8 -*-
#==============================================================================
# ** The Event Extender
#------------------------------------------------------------------------------
# Collection of usefull tools to make Event System
#------------------------------------------------------------------------------
# http://blog.gri.im | http://www.biloucorp.com | http://fa.gri.im
#==============================================================================
# Author : 
# - Grim (http://blog.gri.im)
# With de special help of:
# - Nuki (Pincipal insipiration)
# - Zeus81 (A lot of help for a lot of things)
# - Fabien (Buzzer Command)
# - Avygeil (A lot of inspiration)
# - Heos (Beta test)
# - Zangther (Some various help and Regexp)
# - Lidenvice (Help for test and ergonomic reflection and proofreading)
# - Ulis (proofreading)
# - Hiino ♥ (proofreading and translation)
#------------------------------------------------------------------------------
# And for their social and technic help:
# Magi, Hiino, XHTMLBoy, Raho, Joke, Al Rind, Testament, 
# S4suk3, Tonyryu, Siegfried, Berka, Nagato Yuki, Fabien, Roys, 
# Raymo, Ypsoriama, Amalrich Von Monesser, Magic, Strall, 2cri,
# TI-MAX, Playm, Kmkzy
#==============================================================================

# This version : 4.6.3
# Official website of the project : http://eventextender.gri.im

#==============================================================================
# ** Configuration
#------------------------------------------------------------------------------
# Configuration of the Event Extender
#==============================================================================

module Configuration
  #--------------------------------------------------------------------------
  # * Key to launch Tone Manager
  #--------------------------------------------------------------------------
  KEY_TONE_MANAGER = :f3
  #--------------------------------------------------------------------------
  # * Key to launch In Game Eval
  #--------------------------------------------------------------------------
  KEY_INGAME_EVAL = :f4
  #==============================================================================
  # ** Lang
  #------------------------------------------------------------------------------
  # Language definition
  #==============================================================================
  module Lang
    extend self
    #--------------------------------------------------------------------------
    # * Language Definition
    #--------------------------------------------------------------------------
    def command_in_clipboard; "Commande mise dans le presse papier"; end
    def text_in_clipboard; "Texte mis dans le presse papier"; end
    def create_command; "Créer Commande"; end
    def create_text; "Créer Texte"; end
    def in; "Dans : "; end
    def noargs; "Cette méthode ne prend pas d'arguments"; end
    def gen; "Génération de la commande "; end
    def title_cmd; "Sélectionnez une commande à générer"; end
    def format; :formaté; end
    def free; :libre; end
  end
end

#==============================================================================
# ** Command
#------------------------------------------------------------------------------
# Adds easily usable commands
#==============================================================================

module Command
  #--------------------------------------------------------------------------
  # * Singleton
  #--------------------------------------------------------------------------
  extend self
end

#==============================================================================
# ** Command_Description
#------------------------------------------------------------------------------
# Description of commands
#==============================================================================

module Command_Description
  #--------------------------------------------------------------------------
  # * Singleton
  #--------------------------------------------------------------------------
  extend self
end

#==============================================================================
# ** CommandAPI
#------------------------------------------------------------------------------
#  Command mod API
#==============================================================================

module CommandAPI
  #--------------------------------------------------------------------------
  # * API for command handling
  #--------------------------------------------------------------------------
  def cmd(command, *arguments); Command.send(command.to_sym, *arguments); end
  #--------------------------------------------------------------------------
  # * Alias Command
  #--------------------------------------------------------------------------
  alias command cmd
  alias c cmd
end

#==============================================================================
# ** Object
#------------------------------------------------------------------------------
#  Generic behaviour
#==============================================================================

class Object
  #--------------------------------------------------------------------------
  # * check type : bool
  #--------------------------------------------------------------------------
  def boolean?
    return false
  end
  #--------------------------------------------------------------------------
  # * Convert in Bool
  #--------------------------------------------------------------------------
  def to_bool
    return (self != 0) if self.is_a?(Numeric)
    return !(self.downcase == "false") if self.is_a?(String)
    return !(self == :false) if self.is_a?(Symbol)
    return true
  end
end

#==============================================================================
# ** FalseClass
#------------------------------------------------------------------------------
#  The false class. false is the only instance of the FalseClass class. 
#  false, like nil, denotes a FALSE condition, while all other objects are TRUE.
#==============================================================================

class FalseClass
  #--------------------------------------------------------------------------
  # * check type : bool
  #--------------------------------------------------------------------------
  def boolean?
    return true
  end
  #--------------------------------------------------------------------------
  # * Convert in Bool
  #--------------------------------------------------------------------------
  def to_bool
    return false
  end
end

#==============================================================================
# ** TrueClass
#------------------------------------------------------------------------------
#  The true class. true is the only instance of the TrueClass class. 
#  true is a representative object that denotes a TRUE condition.
#==============================================================================

class TrueClass
  #--------------------------------------------------------------------------
  # * check type : bool
  #--------------------------------------------------------------------------
  def boolean?
    return true
  end
  #--------------------------------------------------------------------------
  # * Convert in Bool
  #--------------------------------------------------------------------------
  def to_bool
    return true
  end
end


#==============================================================================
# ** Enumerable
#------------------------------------------------------------------------------
#  The Enumerable mixin provides collection classes with several traversal 
#  and searching methods, and with the ability to sort. 
#==============================================================================

module Enumerable
  #--------------------------------------------------------------------------
  # * Alias of each
  #--------------------------------------------------------------------------
  def apply(&block)
    each(&block)
  end
end

#==============================================================================
# ** Database
#------------------------------------------------------------------------------
# This module allows the creation of your own database
# It can be used in 100% customized systems.
#==============================================================================

module Database
  #--------------------------------------------------------------------------
  # * Class variables
  #--------------------------------------------------------------------------
  @@tables = []
  #==============================================================================
  # ** Table
  #------------------------------------------------------------------------------
  # Describes a table from the database
  #==============================================================================
  class Table
    #--------------------------------------------------------------------------
    # * Instances variables
    #--------------------------------------------------------------------------
    attr_reader :name
    attr_reader :fields
    attr_reader :rows
    attr_reader :struct
    attr_reader :size
    attr_reader :types
    #--------------------------------------------------------------------------
    # * Object initialize
    #--------------------------------------------------------------------------
    def initialize(name, hash)
      @name = name
      @fields, @rows, @types = [],[],[]
      hash.each do |key, type|
        @fields << key 
        @types << type
      end
      @struct = Struct.new(*(@fields.collect{|e|e.to_sym}))
      @size = 0
    end
    #--------------------------------------------------------------------------
    # * Cast type
    #--------------------------------------------------------------------------
    def cast(obj, type)
      type = type.to_sym
      return ((obj.respond_to?(:to_i)) ? obj.to_i : 0) if [:int, :integer].include?(type)
      return ((obj.respond_to?(:to_f)) ? obj.to_f : 0.0) if type == :float
      return obj.to_bool if [:bool, :boolean, :switch].include?(type)
      return (obj.respond_to?(:to_s)) ? obj.to_s : ""
    end
    #--------------------------------------------------------------------------
    # * Add row 
    #--------------------------------------------------------------------------
    def add_row(*fields_in)
      return if fields_in.length != @fields.length
      (0...@fields.length).each do |elt|
        fields_in[elt] = cast(fields_in[elt], @types[elt])
      end
      @rows << @struct.new(*fields_in)
      @size += 1
    end
    #--------------------------------------------------------------------------
    # * Alias of add_row
    #--------------------------------------------------------------------------
    alias fill add_row
    #--------------------------------------------------------------------------
    # * Alias of add_row
    #--------------------------------------------------------------------------
    def << (fields)
       add_row(*fields)
    end
    #--------------------------------------------------------------------------
    # * Searches one piece of data
    #--------------------------------------------------------------------------
    def find(&block)
       @rows.find(&block)
    end
    #--------------------------------------------------------------------------
    # * Searches a bunch of data
    #--------------------------------------------------------------------------
    def select(&block)
       @rows.select(&block)
    end
    #--------------------------------------------------------------------------
    # * Counts the amount of data according to a predicate
    #--------------------------------------------------------------------------
    def count(&block)
      @rows.count(&block)
    end
  end
  #--------------------------------------------------------------------------
  # * Singleton
  #--------------------------------------------------------------------------
  class << self
    #--------------------------------------------------------------------------
    # * Create Table
    #--------------------------------------------------------------------------
    def create_table(name, hash)
      @@tables << Table.new(name, hash)
    end
    #--------------------------------------------------------------------------
    # * Get tables
    #--------------------------------------------------------------------------
    def tables; @@tables; end
  end
end

#==============================================================================
# ** Win32API
#------------------------------------------------------------------------------
#  win32/registry is registry accessor library for Win32 platform. 
#  It uses dl/import to call Win32 Registry APIs.
#==============================================================================

class Win32API
  #--------------------------------------------------------------------------
  # * Librairy
  #--------------------------------------------------------------------------
  CloseClipboard = self.new('user32', 'CloseClipboard', 'v', 'i')
  CloseSocket = self.new('ws2_32', 'closesocket', 'p', 'l')
  Connect = self.new('ws2_32', 'connect', 'ppl', 'l')
  DestroyCursor = self.new('user32', 'DestroyCursor', 'p', 'l')
  EmptyClipboard = self.new('user32', 'EmptyClipboard', 'v', 'i')
  EnumClipboardFormats = self.new('user32', 'EnumClipboardFormats','i', 'i')
  FindWindowA = self.new('user32', 'FindWindowA', 'pp', 'l')
  GetClipboardData = self.new('user32', 'GetClipboardData', 'i', 'i')
  GetCursorPos = self.new('user32', 'GetCursorPos', 'p', 'i')
  GetClipboardFormatName = self.new('user32', 'GetClipboardFormatName', 'ipi', 'i')
  GetKeyboardState = self.new('user32', 'GetKeyboardState', 'p', 'i')
  GetKeyState = self.new('user32', 'GetKeyState', 'i', 'i')
  GetPrivateProfileStringA = self.new('kernel32', 'GetPrivateProfileStringA', 'pppplp', 'l')
  GlobalAlloc = self.new('kernel32', 'GlobalAlloc', 'ii', 'i')
  GlobalFree = self.new('kernel32', 'GlobalFree', 'i', 'i')
  GlobalLock = self.new('kernel32', 'GlobalLock', 'i', 'l')
  GlobalSize = self.new('kernel32', 'GlobalSize', 'l', 'l')
  GlobalUnlock = self.new('kernel32', 'GlobalUnlock', 'l', 'v')
  Htons = self.new('ws2_32', 'htons', 'l', 'l')
  Inet_Addr = self.new('ws2_32', 'inet_addr', 'p', 'l')
  MapVirtualKey = self.new('user32', 'MapVirtualKey', 'ii', 'i')
  MessageBox = self.new('user32','MessageBox','lppl','i')
  Memcpy = self.new('msvcrt','memcpy', 'ppi', 'i')
  MultiByteToWideChar = self.new('kernel32', 'MultiByteToWideChar', 'ilpipi', 'i')
  OpenClipboard = self.new('user32', 'OpenClipboard', 'i', 'i')
  PeekMessage = self.new('user32', 'PeekMessage', 'piiii', 'i')
  Recv = self.new('ws2_32', 'recv', 'ppll', 'l')
  RegisterClipboardFormat = self.new('user32', 'RegisterClipboardFormat', 'p', 'i')
  RegOpenKeyExA = self.new('advapi32.dll', 'RegOpenKeyExA', 'LPLLP', 'L')
  RegQueryValueExA = self.new('advapi32.dll', 'RegQueryValueExA', 'LPLPPP', 'L')
  RegCloseKey = self.new('advapi32', 'RegCloseKey', 'L', 'L')
  ScreenToClient  = self.new('user32', 'ScreenToClient', 'lp', 'i')
  Send = self.new('ws2_32', 'send', 'ppll', 'l')
  SetClipboardData = self.new('user32', 'SetClipboardData', 'ii', 'i')
  ShowCursor = self.new('user32', 'ShowCursor', 'i', 'i')
  Shutdown = self.new('ws2_32', 'shutdown', 'pl', 'l')
  Socket = self.new('ws2_32', 'socket', 'lll', 'l')
  ToUnicode = self.new('user32', 'ToUnicodeEx', 'llppil', 'l')
  WideCharToMultiByte = self.new('kernel32', 'WideCharToMultiByte', 'ilpipipp', 'i')
  #--------------------------------------------------------------------------
  # * Singleton
  #--------------------------------------------------------------------------
  class << self
    #--------------------------------------------------------------------------
    # * Return the handle of RGSS Player
    #--------------------------------------------------------------------------
    def rgss_handle
      buffer = [].pack('x256')
      GetPrivateProfileStringA.('Game', 'Title', '', buffer, 255, ".\\Game.ini")
      buffer.delete!(0.chr)
      FindWindowA.('RGSS Player', buffer)
    end
    #--------------------------------------------------------------------------
    # * convert text
    #--------------------------------------------------------------------------
    def convert_text(text, from, to)
      size = MultiByteToWideChar.(from, 0, text, -1, nil, 0)
      buffer = [].pack("x#{size*2}")
      MultiByteToWideChar.(from, 0, text, -1, buffer, buffer.size/2)
      size = WideCharToMultiByte.(to, 0, buffer, -1, nil, 0, nil, nil)
      second_buffer = [].pack("x#{size}")
      WideCharToMultiByte.(to, 0, buffer, -1, second_buffer, second_buffer.size, nil, nil)
      second_buffer.delete!("\000") if to == 65001
      second_buffer.delete!("\x00") if to == 0
      return second_buffer
    end
    #--------------------------------------------------------------------------
    # * Get Clipboard Data
    #--------------------------------------------------------------------------
    def get_clipboard_data
      OpenClipboard.(0)
      data = GetClipboardData.(7)
      CloseClipboard.()
      return "" if data == 0
      mem = GlobalLock.(data)
      size = GlobalSize.(data)
      final_data = " "*(size-1)
      Memcpy.(final_data, mem, size)
      GlobalUnlock.(data)
      final_data.to_ascii.to_utf8
    end
    #--------------------------------------------------------------------------
    # * Push text in clipboard
    #--------------------------------------------------------------------------
    def text_in_clipboard(clip_data)
      OpenClipboard.(0)
      EmptyClipboard.()
      hmem = GlobalAlloc.(0x42, clip_data.length+1)
      mem = GlobalLock.(hmem)
      Memcpy.(mem, clip_data, clip_data.length+1)
      SetClipboardData.(7, hmem)
      CloseClipboard.()
      self
    end
    #--------------------------------------------------------------------------
    # * Push command in clipboard (Thanks to Zeus81)
    #--------------------------------------------------------------------------
    def push_in_clipboard(*commands)
      clip_data = Marshal.dump(commands)
      clip_data.insert(0, [clip_data.size].pack('L'))
      OpenClipboard.(0)
      EmptyClipboard.()
      hmem = GlobalAlloc.(0x42, clip_data.length)
      mem = GlobalLock.(hmem)
      Memcpy.(mem, clip_data, clip_data.length)
      SetClipboardData.(EVENT_FORMAT, hmem)
      GlobalFree.(hmem)
      CloseClipboard.()
      self
    end
    def get_clipboard_format(key)
      Win32API::RegisterClipboardFormat.(key)
    end
  end
  EVENT_FORMAT = get_clipboard_format("VX Ace EVENT_COMMAND")
end

#==============================================================================
# ** RTP
#------------------------------------------------------------------------------
#  Get information about RTP
#==============================================================================

module RTP
  #--------------------------------------------------------------------------
  # * Class variable
  #--------------------------------------------------------------------------
  @@rtp_directory = nil
  #--------------------------------------------------------------------------
  # * Singleton of RTP
  #--------------------------------------------------------------------------
  extend self
  #--------------------------------------------------------------------------
  # * Return the PATH of the RTP directory
  #--------------------------------------------------------------------------
  def path
    unless @@rtp_directory
      read_ini = ->(val) do 
        File.foreach("Game.ini") do
          |line| break($1) if line =~ /^#{val}=(.*)$/
        end
      end
      key = type = size = [].pack("x4")
      Win32API::RegOpenKeyExA.(2147483650, 'Software\Enterbrain\RGSS3\RTP', 0, 131097, key)
      key = key.unpack('l').first
      rtp_data = read_ini.("RTP")
      Win32API::RegQueryValueExA.(key, rtp_data, 0, type, 0, size)
      buffer = ' '*size.unpack('l').first
      Win32API::RegQueryValueExA.(key, rtp_data, 0, type, buffer, size)
      Win32API::RegCloseKey.(key)
      @@rtp_directory = (buffer.gsub(/\\/, '/')).delete!(0.chr)
      @@rtp_directory += "/" if @@rtp_directory[-1] != "/"
    end
    return @@rtp_directory
  end
end

#==============================================================================
# ** Kernel
#------------------------------------------------------------------------------
#  Object class methods are defined in this module. 
#  This ensures compatibility with top-level method redefinition.
#==============================================================================

module Kernel
  #--------------------------------------------------------------------------
  # * Constant
  #--------------------------------------------------------------------------
  RGSSHWND = Win32API::rgss_handle
  #--------------------------------------------------------------------------
  # * API for command handling
  #--------------------------------------------------------------------------
  def cmd(command, *arguments); Command.send(command.to_sym, *arguments); end
  def create_table(name, hash); Database.create_table(name, hash); end
  #--------------------------------------------------------------------------
  # * Alias Command
  #--------------------------------------------------------------------------
  alias command cmd
  alias c cmd
end

#==============================================================================
# ** String
#------------------------------------------------------------------------------
#  A String object holds and manipulates an arbitrary sequence of bytes, 
#  typically representing characters.
#==============================================================================

class String
  #--------------------------------------------------------------------------
  # * return self in ASCII-8BIT
  #--------------------------------------------------------------------------
  def to_ascii; Win32API.convert_text(self, 65001, 0);end
  #--------------------------------------------------------------------------
  # * convert self in ASCII-8BIT
  #--------------------------------------------------------------------------
  def to_ascii!; self.replace(self.to_ascii); end
  #--------------------------------------------------------------------------
  # * return self to UTF8
  #--------------------------------------------------------------------------
  def to_utf8; Win32API.convert_text(self, 0, 65001); end
  #--------------------------------------------------------------------------
  # * convert self in UTF8
  #--------------------------------------------------------------------------
  def to_utf8!; self.replace(self.to_utf8); end
  #--------------------------------------------------------------------------
  # * Extract number
  #--------------------------------------------------------------------------
  def extract_numbers
    self.scan(/-*\d+/).collect{|n|n.to_i}
  end
  #--------------------------------------------------------------------------
  # * Calcul the Damerau Levenshtein 's Distance 
  #--------------------------------------------------------------------------
  def damerau_levenshtein(other)
    n, m = self.length, other.length
    return m if n == 0
    return n if m == 0
    matrix  = Array.new(n+1) do |i|
      Array.new(m+1) do |j|
        if i == 0 then j
        elsif j == 0 then i 
        else 0 end
      end
    end
    (1..n).each do |i|
      (1..m).each do |j|
        cost = (self[i] == other[j]) ? 0 : 1
        delete = matrix[i-1][j] + 1
        insert = matrix[i][j-1] + 1
        substitution = matrix[i-1][j-1] + cost
        matrix[i][j] = [delete, insert, substitution].min
        if (i > 1) && (j > 1) && (self[i] == other[j-1]) and (self[i-1] == other[j])
          matrix[i][j] = [matrix[i][j], matrix[i-2][j-2] + cost].min
        end
      end
    end
    return matrix.last.last
  end
end

#==============================================================================
# ** Rect
#------------------------------------------------------------------------------
#  The rectangle class.
#==============================================================================

class Rect
  #--------------------------------------------------------------------------
  # * check if point 's include in the rect
  #--------------------------------------------------------------------------
  def in?(x, y)
    check_x = x.between?(self.x, self.x+self.width)
    check_y = y.between?(self.y, self.y+self.height)
    check_x && check_y
  end
  #--------------------------------------------------------------------------
  # * check if the mouse 's hover
  #--------------------------------------------------------------------------
  def hover?
    in?(UI::Mouse.x, UI::Mouse.y)
  end
  #--------------------------------------------------------------------------
  # * check if the mouse 's click the rect
  #--------------------------------------------------------------------------
  def clicked?(key)
    hover? && UI::Mouse.click?(key)
  end
end

#==============================================================================
# ** Graphical_Rect
#------------------------------------------------------------------------------
#  The rectangle class.
#==============================================================================

class Graphical_Rect < Rect
  #--------------------------------------------------------------------------
  # * Initialize
  #--------------------------------------------------------------------------
  def initialize(x, y, w, h, z, ic, oc)
    super(x, y, w, h)
    @disposed = false
    @z = z
    @ic, @oc = ic, oc
    create_sprite
  end
  #--------------------------------------------------------------------------
  # * Create sprite
  #--------------------------------------------------------------------------
  def create_sprite
    @box = Sprite.new
    @box.x, @box.y = self.x, self.y
    @box.z = @z
    @box.bitmap = Bitmap.new(self.width, self.height)
    @box.bitmap.fill_rect(0, 0, self.width, self.height, @oc)
    @box.bitmap.fill_rect(1, 1, self.width-2, self.height-2, @ic)
  end
  #--------------------------------------------------------------------------
  # * Draw Text
  #--------------------------------------------------------------------------
  def draw_text(text, c=Color.new(0,0,0), s=15)
    @box.bitmap.font.color = c
    @box.bitmap.font.outline = false
    @box.bitmap.font.shadow = false
    @box.bitmap.font.size = s
    @box.bitmap.draw_text(1, 1, self.width-2, self.height-2, text, 1)
  end
  #--------------------------------------------------------------------------
  # * Dispose rect
  #--------------------------------------------------------------------------
  def dispose
    @box.dispose
    @disposed = true
  end
  #--------------------------------------------------------------------------
  # * Check Dispose
  #--------------------------------------------------------------------------
  def disposed?
    @disposed
  end
end

#==============================================================================
# ** T
#------------------------------------------------------------------------------
#  Database handling API
#==============================================================================

module T
  #--------------------------------------------------------------------------
  # * Singleton
  #--------------------------------------------------------------------------
  extend self
  #--------------------------------------------------------------------------
  # * Get a table
  #--------------------------------------------------------------------------
  def [](name)
    Database.tables.find{|t|t.name == name}
  end
end
#--------------------------------------------------------------------------
# * Alias for database API
#--------------------------------------------------------------------------
Tables = T

#==============================================================================
# ** V (special thanks to Nuki)
#------------------------------------------------------------------------------
#  Variable handling API
#==============================================================================

module V
  #--------------------------------------------------------------------------
  # * Singleton
  #--------------------------------------------------------------------------
  extend self
  #--------------------------------------------------------------------------
  # * Returns a Game Variable
  #--------------------------------------------------------------------------
  def [](key)
    $game_variables[key]
  end
  #--------------------------------------------------------------------------
  # * Modifies a variable
  #--------------------------------------------------------------------------
  def []=(key, value)
    if key.is_a?(Range)
      key.each do |k|
        $game_variables[k] = value
      end
    else
      $game_variables[key] = value
    end
  end
end

#==============================================================================
# ** S (special thanks to Nuki)
#------------------------------------------------------------------------------
# Switch handling API
#==============================================================================

module S
  #--------------------------------------------------------------------------
  # * Singleton
  #--------------------------------------------------------------------------
  extend self
  #--------------------------------------------------------------------------
  # * Returns a Game Switch
  #--------------------------------------------------------------------------
  def [](key)
    $game_switches[key]
  end
  #--------------------------------------------------------------------------
  # * Modifies a Game Switch
  #--------------------------------------------------------------------------
  def []=(key, value)
    if key.is_a?(Range)
      key.each do |k|
        $game_switches[k] = value.to_bool
      end
    else
      $game_switches[key] = value.to_bool
    end
  end
end

#==============================================================================
# ** SV (special thanks to Zeus81)
#------------------------------------------------------------------------------
#  self Variable handling API
#==============================================================================

module SV
  #--------------------------------------------------------------------------
  # * Singleton
  #--------------------------------------------------------------------------
  extend self
  #--------------------------------------------------------------------------
  # * Returns a self Variable
  #--------------------------------------------------------------------------
  def [](*args, id)
    event_id = args[-1] || Game_Interpreter.current_event_id
    map_id = args[-2] || Game_Interpreter.current_map_id
    $game_self_vars.fetch([map_id, event_id, id], 0)
  end
  #--------------------------------------------------------------------------
  # * Modifies a self variable
  #--------------------------------------------------------------------------
  def []=(*args, id, value)
    event_id = args[-1] || Game_Interpreter.current_event_id
    map_id = args[-2] || Game_Interpreter.current_map_id
    $game_self_vars[[map_id, event_id, id]] = value
    $game_map.need_refresh = true
  end
end

#==============================================================================
# ** SS (special thanks to Zeus81)
#------------------------------------------------------------------------------
#  Self Switches handling API
#==============================================================================

module SS
  #--------------------------------------------------------------------------
  # * Singleton
  #--------------------------------------------------------------------------
  extend self
  #--------------------------------------------------------------------------
  # * map key
  #--------------------------------------------------------------------------
  def map_id_s(id)
    auth = ["A","B","C","D"]
    return id if auth.include?(id)
    return auth[id-1] if id.to_i.between?(1, 4)
    return "A"
  end
  private :map_id_s
  #--------------------------------------------------------------------------
  # * Returns a self switch
  #--------------------------------------------------------------------------
  def [](*args, id)
    event_id = args[-1] || Game_Interpreter.current_event_id
    map_id = args[-2] || Game_Interpreter.current_map_id
    key = [map_id, event_id, map_id_s(id)]
    $game_self_switches[key]
  end
  #--------------------------------------------------------------------------
  # * Modifies a self switch
  #--------------------------------------------------------------------------
  def []=(*args, id, value)
    event_id = args[-1] || Game_Interpreter.current_event_id
    map_id = args[-2] || Game_Interpreter.current_map_id
    key = [map_id, event_id, map_id_s(id)]
    $game_self_switches[key] = value.to_bool
    $game_map.need_refresh = true
  end
end

#==============================================================================
# ** Numeric
#------------------------------------------------------------------------------
# Managing digits separately
#==============================================================================

class Numeric
   #--------------------------------------------------------------------------
   # * handle isoler
   #--------------------------------------------------------------------------
   def isole_int(i); (self%(10**i))/(10**(i-1)).to_i; end
   #--------------------------------------------------------------------------
   # * Number's units digit
   #--------------------------------------------------------------------------
   def units; isole_int(1); end
   #--------------------------------------------------------------------------
   # * Number's tens digit
   #--------------------------------------------------------------------------
   def tens; isole_int(2); end
   #--------------------------------------------------------------------------
   # * Number's hundreds digit
   #--------------------------------------------------------------------------
   def hundreds; isole_int(3); end
   #--------------------------------------------------------------------------
   # * Number's thousands digit
   #--------------------------------------------------------------------------
   def thousands; isole_int(4); end
   #--------------------------------------------------------------------------
   # * Number's tens of thousands digit
   #--------------------------------------------------------------------------
   def tens_thousands; isole_int(5); end
   #--------------------------------------------------------------------------
   # * Number's hundreds of thousands digit
   #--------------------------------------------------------------------------
   def hundreds_thousands; isole_int(6); end
   #--------------------------------------------------------------------------
   # * Number's millions digit
   #--------------------------------------------------------------------------
   def millions; isole_int(7); end
   #--------------------------------------------------------------------------
   # * Number's tens of millions digit
   #--------------------------------------------------------------------------
   def tens_millions; isole_int(8); end
   #--------------------------------------------------------------------------
   # * Number's hundreds of millions digit
   #--------------------------------------------------------------------------
   def hundreds_millions; isole_int(9); end
   #--------------------------------------------------------------------------
   # * alias
   #--------------------------------------------------------------------------
   alias unites units
   alias dizaines tens
   alias centaines hundreds
   alias milliers thousands
   alias dizaines_milliers tens_thousands
   alias centaines_milliers hundreds_thousands
   alias dizaines_millions tens_millions
   alias centaines_millions hundreds_millions
end

#==============================================================================
# ** UI
#------------------------------------------------------------------------------
#  User interaction
#==============================================================================

module UI

  #==============================================================================
  # ** Device
  #------------------------------------------------------------------------------
  #  Generic Device definition
  #==============================================================================

  module Device
    #--------------------------------------------------------------------------
    # * Constants
    #--------------------------------------------------------------------------
    Keys = {
      mouse_left: 0x01, mouse_right: 0x02, mouse_center: 0x04,
      backspace: 0x08, tab: 0x09, clear: 0x0C, enter: 0x0D,
      shift: 0x10, ctrl: 0x011, alt: 0x12, pause: 0x13, 
      caps_lock: 0x14, esc: 0x1B, space: 0x20, page_up: 0x21,
      page_down: 0x22, end: 0x23, home: 0x24, left: 0x25, up: 0x26,
      right: 0x27, down: 0x28, select: 0x29, print: 0x2A, snapshot: 0x2C,
      execute: 0x2B, insert: 0x2D, delete: 0x2E, help: 0x2F, zero: 0x30,
      one: 0x31, two: 0x32, three: 0x33, four: 0x34, five: 0x35, six: 0x36,
      seven: 0x37, eight: 0x38, nine: 0x39, minus: 0xBD, a: 0x41, 
      b: 0x42, c: 0x43, d: 0x44, e: 0x45, f: 0x46, g: 0x47, h: 0x48,
      i: 0x49, j: 0x4A, k: 0x4B, l: 0x4C, m: 0x4D, n: 0x4E, o: 0x4F, p: 0x50, 
      q: 0x51, r: 0x52, s: 0x53, t: 0x54, u: 0x55, v: 0x56, w: 0x57, x: 0x58, 
      y: 0x59, z: 0x5A, lwindow: 0x5B, rwindow: 0x5C, apps: 0x5D, 
      num_zero: 0x60, num_one: 0x61, num_two: 0x62, num_three: 0x63, 
      num_four: 0x64, num_five: 0x65, num_six: 0x66, num_seven: 0x67, 
      num_eight: 0x68, num_nine: 0x69, multiply: 0x6A, add: 0x6B, separator: 0x6C, 
      substract: 0x6D, decimal: 0x6E, divide: 0x6F, f1: 0x70, f2: 0x71, f3: 0x72,
      f4: 0x73, f5: 0x74, f6: 0x75, f7: 0x76, f8: 0x77, f9: 0x78, f10: 0x79, 
      f11: 0x7A, f12: 0x7B, num_lock: 0x90, scroll_lock: 0x91, 
      lshift: 0xA0, rshift: 0xA1, lcontrol: 0xA2, rcontrol: 0xA3, lmenu: 0xA4,
      rmenu: 0xA5, circumflex: 0xDD, dollar: 0xBA, close_parenthesis: 0xDB, 
      u_grav: 0xC0, square: 0xDE, less_than: 0xE2, colon: 0xBF, semicolon: 0xBE,
      equal: 0xBB, comma: 0xBC
    }
    #--------------------------------------------------------------------------
    # * key list
    #--------------------------------------------------------------------------
    def key_list; Keys; end
    #--------------------------------------------------------------------------
    # * Class Variable
    #--------------------------------------------------------------------------
    @@keys = Array.new
    @@count = Array.new
    @@release = Array.new
    #--------------------------------------------------------------------------
    # * Update Device Statement
    #--------------------------------------------------------------------------
    def update
      @@release.clear
      update_press
    end
    #--------------------------------------------------------------------------
    # * Update Press Statement
    #--------------------------------------------------------------------------
    def update_press
      @@keys.each do |key_code|
        @@count[key_code] ||= 0
        if key_pushable?(key_code)
          @@count[key_code] += 1
        elsif @@count[key_code] != 0
          @@count[key_code] = 0
          @@release << key_code
        end
      end
    end
    #--------------------------------------------------------------------------
    # * Determine if a key 's pushable
    #--------------------------------------------------------------------------
    def key_pushable?(key); false; end
    #--------------------------------------------------------------------------
    # * Determine if key's trigged
    #--------------------------------------------------------------------------
    def key_trigger?(code); @@count[Keys[code]] == 1; end
    #--------------------------------------------------------------------------
    # * Determine if key's pressed
    #--------------------------------------------------------------------------
    def key_press?(code); @@count[Keys[code]] != 0; end
    #--------------------------------------------------------------------------
    # * determine if key release
    #--------------------------------------------------------------------------
    def key_release?(code); @@release.include?(Keys[code]); end
    #--------------------------------------------------------------------------
    # * determine if key repeat?
    #--------------------------------------------------------------------------
    def key_repeat?(code) 
      @@count[Keys[code]] ||= 0
      trigger?(code) || (@@count[Keys[code]] >= 24 && @@count[Keys[code]]%6 == 0)
    end
    #--------------------------------------------------------------------------
    # * Define device keys
    #--------------------------------------------------------------------------
    def define_keys(*args)
      args.each do |key_name|
        @@keys << Keys[key_name]
      end
    end
    #--------------------------------------------------------------------------
    # * Alias
    #--------------------------------------------------------------------------
    alias trigger? key_trigger?
    alias press? key_press?
    alias release? key_release?
    alias repeat? key_repeat?
  end

  #==============================================================================
  # ** Keyboard
  #------------------------------------------------------------------------------
  #  Keyboard support
  #==============================================================================

  module Keyboard
    #--------------------------------------------------------------------------
    # * Mixin
    #--------------------------------------------------------------------------
    extend Device
    #--------------------------------------------------------------------------
    # * Keys definition
    #--------------------------------------------------------------------------
    define_keys :backspace, :clear, :enter, :shift, :ctrl, :alt, :pause
    define_keys :caps_lock, :esc, :space, :page_up, :page_down, :end, :home
    define_keys :left, :up, :right, :down, :select, :print, :execute, :help
    define_keys :zero, :one, :two, :three, :four, :five, :six, :seven, :eight, :nine
    define_keys :a, :b, :c, :d, :e, :f, :g, :h, :i, :j, :k, :l, :m, :n, :o, :p, :q
    define_keys :r, :s, :t, :u, :v, :w, :x, :y, :z
    define_keys :lwindow, :rwindow, :apps, :num_zero, :num_one, :num_two, :num_three
    define_keys :num_four, :num_five, :num_six, :num_seven, :num_eight, :num_nine
    define_keys :add, :substract, :divide, :decimal, :multiply, :separator
    define_keys :f1, :f2, :f3, :f4, :f5, :f6, :f7, :f8, :f9, :f10, :f11, :f12
    define_keys :num_lock, :scroll_lock, :lshift, :rshift, :lcontrol, :rcontrol
    define_keys :lmenu, :rmenu, :circumflex, :dollar, :close_parenthesis, :u_grav
    define_keys :square, :less_than, :colon, :semicolon, :equal, :comma, :minus
    define_keys :delete, :snapshot, :insert
    #--------------------------------------------------------------------------
    # * Class Variables
    #--------------------------------------------------------------------------
    @@buffer = [].pack('x256')
    @@caps_lock = false
    @@num_lock = false
    @@scroll_lock = false
    @@maj = false
    @@alt_gr = false
    @@codes = {}
    key_list.each do |i, val|
      @@codes[i] = Win32API::MapVirtualKey.(val, 0)
    end
    KEY_NUM = [
      :one, :two, :three, :four, :five, :six, :seven, :eight, :nine,
      :num_one, :num_two, :num_three, :num_four, :num_five, :num_six, 
      :num_seven, :num_eight, :num_nine
    ]
    DEAD_KEYS = {
      "^"=>{
        "a" => "â", "A" => "Â",
        "e" => "ê", "E" => "Ê", 
        "i" => "î", "I" => "Î",
        "o" => "ô", "O" => "Ô",
        "u" => "û", "U" => "Û",
        " " => "^"
      },
      "¨"=>{
        "a" => "ä", "A" => "Ä",
        "e" => "ë", "E" => "Ë", 
        "i" => "ï", "I" => "Ï",
        "o" => "ö", "O" => "Ö",
        "u" => "ü", "U" => "Ü",
        "y" => "ÿ", " " => "¨"
      },
      "´"=>{
        "a" => "á", "A" => "Á",
        "e" => "é", "E" => "É", 
        "i" => "í", "I" => "Í",
        "o" => "ó", "O" => "Ó",
        "u" => "ú", "U" => "Ú",
        "y" => "ý", "Y" => "Ý",
        " " => "´"
      },
      "`"=>{
        "a" => "à", "A" => "Á",
        "e" => "è", "E" => "É", 
        "i" => "ì", "I" => "Í",
        "o" => "ò", "O" => "Ó",
        "u" => "ù", "U" => "Ú",
        " " => "`"
      },
      "~"=>{
        "a" => "ã", "A" => "Ã",
        "o" => "õ", "O" => "Õ", 
        "n" => "ñ", "N" => "Ñ"
      }
    }
    @@wait_char = ""
    #--------------------------------------------------------------------------
    # * Singleton
    #--------------------------------------------------------------------------
    class << self
      #--------------------------------------------------------------------------
      # * Keyboard update
      #--------------------------------------------------------------------------
      def update
        super
        Win32API::GetKeyboardState.(@@buffer)
        @@caps_lock = (Win32API::GetKeyState.(Keys[:caps_lock]) & 1) != 0
        @@num_lock = (Win32API::GetKeyState.(Keys[:num_lock]) & 1) != 0
        @@scroll_lock = (Win32API::GetKeyState.(Keys[:scroll_lock]) & 1) != 0
        @@maj = (@@caps_lock) ? !press?(:shift) : press?(:shift)
        if (press?(:alt) && press?(:lcontrol))
          @@alt_gr = true
        else
          @@alt_gr = (press?(:ctrl) && !press?(:lcontrol) && !press?(:rcontrol))
        end
      end
      #--------------------------------------------------------------------------
      # * Determine if a key 's pushable
      #--------------------------------------------------------------------------
      def key_pushable?(key_code)
        @@buffer.getbyte(key_code)[7] == 1
      end
      #--------------------------------------------------------------------------
      # * Get the Caps Lock State
      #--------------------------------------------------------------------------
      def caps_lock?
        @@caps_lock
      end
      #--------------------------------------------------------------------------
      # * Get the Num Lock State
      #--------------------------------------------------------------------------
      def num_lock?
        @@num_lock
      end
      #--------------------------------------------------------------------------
      # * Get the Scroll Lock State
      #--------------------------------------------------------------------------
      def scroll_lock?
        @@scroll_lock
      end
      #--------------------------------------------------------------------------
      # * Get the MAJ state
      #--------------------------------------------------------------------------
      def maj?
        @@maj
      end
      #--------------------------------------------------------------------------
      # * Get the ALT_GR state
      #--------------------------------------------------------------------------
      def alt_gr?
        @@alt_gr
      end
      #--------------------------------------------------------------------------
      # * Get the char of a key
      #--------------------------------------------------------------------------
      def char(key)
        return "" if key == :backspace || key == :enter || key == :esc
        out = [].pack('x16')
        size = Win32API::ToUnicode.(key_list[key], 0, @@buffer, out, 8, 0)
        return "" if size == 0
        outUTF8 = "\0"*4
        Win32API::WideCharToMultiByte.(65001, 0, out, 1, outUTF8, 4, 0, 0)
        outUTF8.delete!("\0")
        if @@wait_char != ""
          if DEAD_KEYS[@@wait_char].has_key?(outUTF8)
            outUTF8 = DEAD_KEYS[@@wait_char][outUTF8]
            @@wait_char = ""
          else
            if DEAD_KEYS.has_key?(outUTF8)
              @@wait_char, outUTF8 = outUTF8, @@wait_char
            else
              outUTF8 = @@wait_char << outUTF8
              @@wait_char = ""
            end
          end
        else
          if DEAD_KEYS.has_key?(outUTF8)
            @@wait_char = outUTF8
            outUTF8 = ""
          end
        end
        return outUTF8
      end
      #--------------------------------------------------------------------------
      # * Get the current char
      #--------------------------------------------------------------------------
      def letter
        return "" if Keyboard.press?(:ctrl) && Keyboard.trigger?(:v)
        key_list.keys.each do |i|
          return char(i) if repeat?(i)
        end
        return ""
      end
      #--------------------------------------------------------------------------
      # * Determine number
      #--------------------------------------------------------------------------
      def number
        KEY_NUM.each do |i|
          if repeat?(i)
            c = char(i)
            return (c.to_i.to_s == c) ? c.to_i : nil
          end
        end
        return nil
      end
    end
  end

  #==============================================================================
  # ** Mouse
  #------------------------------------------------------------------------------
  #  Mouse support
  #==============================================================================

  module Mouse
    #--------------------------------------------------------------------------
    # * Mixin
    #--------------------------------------------------------------------------
    extend Device
    #--------------------------------------------------------------------------
    # * Keys definition
    #--------------------------------------------------------------------------
    define_keys :mouse_left, :mouse_right, :mouse_center
    #--------------------------------------------------------------------------
    # * Class Variables
    #--------------------------------------------------------------------------
    @@x = @@y = @@old_x = @@old_y = 0
    @@wheel = 0
    @@rect = Rect.new(1, 1, 1, 1)
    #--------------------------------------------------------------------------
    # * Singleton
    #--------------------------------------------------------------------------
    class << self
      #--------------------------------------------------------------------------
      # * Mouse update
      #--------------------------------------------------------------------------
      def update
        #wheel_update
        position_update
        rect_update
      end
      #--------------------------------------------------------------------------
      # * Update Wheel
      #--------------------------------------------------------------------------
      def wheel_update
        buffer =  [].pack('x32')
        state = Win32API::PeekMessage.(buffer,RGSSHWND,0x020A,0x020A,0)
        if state <= 0; @@wheel = 0
        elsif buffer.getbyte(11) == 0; @@wheel = 1
        else; @@wheel = -1
        end
      end
      #--------------------------------------------------------------------------
      # * Position update
      #--------------------------------------------------------------------------
      def position_update
        buffer = [0,0].pack('l2')
        buffer = buffer.unpack('l2') unless Win32API::GetCursorPos.(buffer)
        buffer = buffer.unpack('l2') if Win32API::ScreenToClient.(RGSSHWND, buffer)
        @@x, @@y = *buffer
      end
      #--------------------------------------------------------------------------
      # * Update the select rect
      #--------------------------------------------------------------------------
      def rect_update
        if click?(:mouse_left)
          min_x = [@@old_x, @@x].min
          max_x = [@@old_x, @@x].max
          min_y = [@@old_y, @@y].min
          max_y = [@@old_y, @@y].max
          @@rect.set(min_x, min_y, (max_x - min_x), (max_x - min_y))
        else
          @@old_x, @@old_y = @@x, @@y
        end
      end
      #--------------------------------------------------------------------------
      # * Determine if a key 's pushable
      #--------------------------------------------------------------------------
      def key_pushable?(key_code)
        Win32API::GetKeyState.(key_code) > 1
      end
      #--------------------------------------------------------------------------
      # * Get Wheel state
      #--------------------------------------------------------------------------
      def wheel; @@wheel; end
      #--------------------------------------------------------------------------
      # * Get X position
      #--------------------------------------------------------------------------
      def x; @@x; end
      #--------------------------------------------------------------------------
      # * Get Y position
      #--------------------------------------------------------------------------
      def y; @@y; end
      #--------------------------------------------------------------------------
      # * Get X square position
      #--------------------------------------------------------------------------
      def x_square; ((@@x+($game_map.display_x*32))/32).to_i; end
      #--------------------------------------------------------------------------
      # * Get Y square position
      #--------------------------------------------------------------------------
      def y_square; ((@@y+($game_map.display_y*32))/32).to_i; end
      #--------------------------------------------------------------------------
      # * Get the Select Rect
      #--------------------------------------------------------------------------
      def rect; @@rect; end
      #--------------------------------------------------------------------------
      # * Set the windows cursor (or not)
      #--------------------------------------------------------------------------
      def show_cursor_system(flag)
        flag = (flag.to_bool) ? 1 : 0
        Win32API::ShowCursor.(flag)
      end
      #--------------------------------------------------------------------------
      # * Alias
      #--------------------------------------------------------------------------
      alias :click? :press?
    end
  end

  #==============================================================================
  # ** Form
  #------------------------------------------------------------------------------
  #  Form manipulation
  #==============================================================================

  module Form
    
    #==============================================================================
    # ** In Game interpreter
    #------------------------------------------------------------------------------
    #  Try command in game
    #==============================================================================
    
    class GameEval
      #--------------------------------------------------------------------------
      # * Object initialize
      #--------------------------------------------------------------------------
      def initialize
        y = Graphics.height - 40
        w = Graphics.width - 80
        @evalbox = Window_Textfield.new(0, y, w, "", 40, 1)
        @evalbox.tone.set(20,20,20)
        @evalbox.active = true
        @past = Graphical_Rect.new(w, y, 80, 40,100, Color.new(120,120,120), Color.new(0,0,0))
        @past.draw_text("Make command")
        @disposed = false
      end
      #--------------------------------------------------------------------------
      # * Update
      #--------------------------------------------------------------------------
      def update
        @evalbox.update
        if Keyboard.trigger?(:enter)
          text = @evalbox.value
          begin
            eval(text, $game_map.interpreter.get_binding)
          rescue
            msgbox("Error in the command line")
          end
        end
        if @past.hover? && UI::Mouse.trigger?(:mouse_left)
          Win32API.push_in_clipboard(RPG::EventCommand.new(355, 0, [@evalbox.value]))
          Win32API::MessageBox.(0, Configuration::Lang.command_in_clipboard, "Info:", 0)
        end
      end
      #--------------------------------------------------------------------------
      # * Dispose
      #--------------------------------------------------------------------------
      def dispose
        @evalbox.dispose
        @past.dispose
        @disposed = true
      end
      #--------------------------------------------------------------------------
      # * check disposition
      #--------------------------------------------------------------------------
      def disposed?
        @disposed
      end
    end
    
    
    #==============================================================================
    # ** Tone Manager
    #------------------------------------------------------------------------------
    #  Window tone manage
    #==============================================================================
    
    class ToneManager
      #--------------------------------------------------------------------------
      # * Object initialize
      #--------------------------------------------------------------------------
      def initialize(x, y)
        @disposed = false
        @in_transfert = false
        @tone = $game_map.screen.tone.clone
        @window = Window_Base.new(x, y, 180, 270)
        @window.contents.font.size = 18
        @window.contents.draw_text(0, 0, 180-32, 20, "Tone Manager" ,1)
        @window.tone = Tone.new(100, 100, 100)
        y += 24
        x += 8
        @track = Hash.new
        r = 255+@tone.red
        g = 255+@tone.green
        b = 255+@tone.blue
        gr = @tone.gray
        @track[:red] = Trackbar.new(x, y+16, r, 0, 510, 164, 8, @window.z+10, Color.new(255, 0, 0))
        @track[:gre] = Trackbar.new(x, y+32, g, 0, 510, 164, 8, @window.z+10, Color.new(0, 255, 0))
        @track[:blu] = Trackbar.new(x, y+48, b, 0, 510, 164, 8, @window.z+10, Color.new(0, 0, 255))
        @track[:gra] = Trackbar.new(x, y+64, gr, 0, 255, 164, 8, @window.z+10)
        @inputs = Hash.new
        @inputs[:red] = Window_Intfield.new(x, y+80, 80, @tone.red, 36, 1, (-255..255), 18, 6)
        @inputs[:gre] = Window_Intfield.new(x, y+118, 80, @tone.green, 36, 1, (-255..255), 18, 6)
        @inputs[:blu] = Window_Intfield.new(x, y+156, 80, @tone.blue, 36, 1, (-255..255), 18, 6)
        @inputs[:gra] = Window_Intfield.new(x, y+194, 80, @tone.gray, 36, 1, (-255..255), 18, 6)
        @window.draw_text(82, 92, 80, 20, "Time")
        @time = Window_Intfield.new(x+82, y+100, 80, 0, 36, 1, (0..600), 18, 6)
        @inputs[:red].tone.set(255, 0, 0)
        @inputs[:gre].tone.set(0, 255, 0)
        @inputs[:blu].tone.set(0, 0, 255)
        @inputs[:gra].tone.set(120, 120, 120)
        @checkbox = Checkbox.new(x+82, y+140,@window.z+10, false)
        @window.draw_text(100, 150, 80, 20, "Wait?")
        @try = Graphical_Rect.new(x+82, y+168, 80, 22,@window.z+10, Color.new(120,120,120), Color.new(0,0,0))
        @try.draw_text("Try tone")
        @past = Graphical_Rect.new(x+82, y+192, 80, 22,@window.z+10, Color.new(120,120,120), Color.new(0,0,0))
        @past.draw_text("Make command")
      end
      #--------------------------------------------------------------------------
      # * Update
      #--------------------------------------------------------------------------
      def update
        return if disposed?
        r = @inputs[:red].value 
        g = @inputs[:gre].value 
        bl = @inputs[:blu].value 
        gr = @inputs[:gra].value 
        n_t = Tone.new(r, g, bl, gr)
        @checkbox.update
        unless @in_transfert
          @track.each do |k,t|
            t.update 
            if @inputs[k].active?
              fact = (k == :gra) ? 0 : 255
              t.value = fact + @inputs[k].value
            end
          end
          @inputs.each do |k,t|
            fact = (k == :gra) ? 0 : -255
            t.value = fact + @track[k].value unless t.active
            t.opacity = (t.active?) ? 255 : 125
            if t.clicked?(:mouse_left)
              @inputs.each{|a,b|b.active = false}
              @time.active = false
              t.active = true
            end
            t.active = false if UI::Mouse.trigger?(:mouse_left) && t.active?
            t.update
          end
        end
        if @time.clicked?(:mouse_left)
          @inputs.each{|a,b|b.active = false}
          @time.active = true
        end
        @time.opacity = (@time.active?) ? 255 : 125
        @time.update
        check_tone
        if @try.hover? && UI::Mouse.trigger?(:mouse_left) && !@in_transfert
          $game_map.screen.start_tone_change(@tone, 0)
          $game_map.screen.start_tone_change(n_t, @time.value)
        end
        @in_transfert = $game_map.screen.tone_duration > 0
        if @past.hover? && UI::Mouse.trigger?(:mouse_left)
          Win32API.push_in_clipboard(RPG::EventCommand.new(223, 0, [n_t, @time.value, @checkbox.value]))
          Win32API::MessageBox.(0, Configuration::Lang.command_in_clipboard, "Info:", 0)
        end
      end
      #--------------------------------------------------------------------------
      # * Check tone
      #--------------------------------------------------------------------------
      def check_tone
        r = @inputs[:red].value != $game_map.screen.tone.red
        g = @inputs[:gre].value != $game_map.screen.tone.green
        b = @inputs[:blu].value != $game_map.screen.tone.blue
        a = @inputs[:gra].value != $game_map.screen.tone.gray
        if (r || g || b || a) && !@in_transfert
          r = @inputs[:red].value 
          g = @inputs[:gre].value 
          b = @inputs[:blu].value 
          a = @inputs[:gra].value 
          t = Tone.new(r, g, b, a)
          $game_map.screen.start_tone_change(t, 0)
        end
      end
      #--------------------------------------------------------------------------
      # * Dispose
      #--------------------------------------------------------------------------
      def dispose
        @disposed = true
        $game_map.screen.start_tone_change(@tone, 0)
        @window.dispose
        @track.each{|k,t|t.dispose}
        @inputs.each{|k,t| t.dispose}
        @time.dispose
        @checkbox.dispose
        @try.dispose
        @past.dispose
      end
      #--------------------------------------------------------------------------
      # * Check disposition
      #--------------------------------------------------------------------------
      def disposed?
        @disposed
      end
    end
    
    #==============================================================================
    # ** Checkbox
    #------------------------------------------------------------------------------
    #  Simple checkbox definition
    #==============================================================================
    
    class Checkbox
      #--------------------------------------------------------------------------
      # * Public instance variable
      #--------------------------------------------------------------------------
      attr_accessor :value
      #--------------------------------------------------------------------------
      # * Object initialize
      #--------------------------------------------------------------------------
      def initialize(x, y, z, default = false)
        @dispose = false
        @x, @y = x, y
        @value = default
        @box = Sprite.new
        @box.x, @box.y, @box.z = x, y, z
        @rect = Rect.new(x, y, 16, 16)
        @box.bitmap = Bitmap.new(16, 16)
        empty_box
        draw_choice if @value
      end
      #--------------------------------------------------------------------------
      # * Create empty box
      #--------------------------------------------------------------------------
      def empty_box
        @box.bitmap.clear
        @box.bitmap.font.size = 14
        @box.bitmap.font.outline = false
        @box.bitmap.font.shadow = false
        @box.bitmap.font.italic = true
        @box.bitmap.font.color = Color.new(0,0,0)
        @box.bitmap.fill_rect(0, 0, 16, 16, Color.new(0,0,0))
        @box.bitmap.fill_rect(1, 1, 14, 14, Color.new(255,255,255))
      end
      #--------------------------------------------------------------------------
      # * Draw choice
      #--------------------------------------------------------------------------
      def draw_choice
        @box.bitmap.draw_text(1, 1, 14, 14, "V", 1)
      end
      #--------------------------------------------------------------------------
      # * Dispose
      #--------------------------------------------------------------------------
      def dispose
        @dispose = true
        @box.dispose
      end
      #--------------------------------------------------------------------------
      # * Check disposition
      #--------------------------------------------------------------------------
      def disposed?
        @dispose
      end
      #--------------------------------------------------------------------------
      # * update
      #--------------------------------------------------------------------------
      def update
        if @rect.hover? && UI::Mouse.trigger?(:mouse_left)
          @value = !@value
          if @value
            draw_choice
          else
            empty_box
          end
        end
      end
    end
    
    #==============================================================================
    # ** Trackbar
    #------------------------------------------------------------------------------
    #  Simple trackbar definition
    #==============================================================================
    
    class Trackbar
      #--------------------------------------------------------------------------
      # * Public instance variable
      #--------------------------------------------------------------------------
      attr_accessor :value
      #--------------------------------------------------------------------------
      # * Object initialize
      #--------------------------------------------------------------------------
      def initialize(x,y,value=0,min=0,max=100,width=250,height=16,z=100, cb = Color.new(200, 200, 200))
        @click = false
        @x, @y, @value, @z = x, y, value, z
        @min, @max = min, max
        @width, @height = width, height
        @color_b = cb
        create_trackbg
        create_button
        calc_pos_button
      end
      #--------------------------------------------------------------------------
      # * Mutator of value
      #--------------------------------------------------------------------------
      def value=(v)
        @value = [[v, @min].max, @max].min
      end
      #--------------------------------------------------------------------------
      # * create_bg
      #--------------------------------------------------------------------------
      def create_trackbg
        @bg = Sprite.new
        @bg.z = @z
        @bg.x, @bg.y = @x, @y
        @bg.bitmap = Bitmap.new(@width, @height)
        @bg.bitmap.fill_rect(0, 0, @width, @height, Color.new(120, 120, 120))
      end
      #--------------------------------------------------------------------------
      # * create_button
      #--------------------------------------------------------------------------
      def create_button
        @button = Sprite.new
        @button.z = @z+1
        @button.x, @button.y = @x, @y
        @button.bitmap = Bitmap.new(@height, @height)
        @button.bitmap.fill_rect(0, 0, @height, @height, @color_b)
      end
      #--------------------------------------------------------------------------
      # * calcul button position
      #--------------------------------------------------------------------------
      def calc_pos_button
        total_width = @width-@height
        total_data = @max - @min
        @button.x = @x + ((@value/total_data.to_f)*total_width.to_i)
        @rect = Rect.new(@button.x, @y, @height, @height)
      end
      #--------------------------------------------------------------------------
      # * Dispose track
      #--------------------------------------------------------------------------
      def dispose
        @bg.dispose
        @button.dispose
      end
      #--------------------------------------------------------------------------
      # * Update frame
      #--------------------------------------------------------------------------
      def update
        update_track
        update_button
      end
      #--------------------------------------------------------------------------
      # * Update button
      #--------------------------------------------------------------------------
      def update_button
        calc_pos_button
      end
      #--------------------------------------------------------------------------
      # * Update track
      #--------------------------------------------------------------------------
      def update_track
        @click = true if @rect.clicked?(:mouse_left)
        if @click && UI::Mouse.click?(:mouse_left)
          self.value += (UI::Mouse.x - @button.x)/2
        else
          @click = false
        end
      end
    end

    #==============================================================================
    # ** Window_Field
    #------------------------------------------------------------------------------
    #  Simple Field
    #==============================================================================

    class Window_Field < Window_Base
      #--------------------------------------------------------------------------
      # * Public instance variable
      #--------------------------------------------------------------------------
      attr_accessor :active, :align, :range
      #--------------------------------------------------------------------------
      # * Object initialize
      #--------------------------------------------------------------------------
      def initialize(x, y, w, t, h, align, range, ts, p=6, pb=6)
        super(x, y, w, h)
        self.arrows_visible = false
        self.padding = p
        self.padding_bottom = pb
        self.contents = Bitmap.new(w-8, h)
        self.contents.font.size = ts
        @align = align%3
        @text = t
        @range = (range == -1) ? false : range
        @old_text = @text.dup
        self.active = false
        refresh
      end
      #--------------------------------------------------------------------------
      # * refresh
      #--------------------------------------------------------------------------
      def refresh
        self.contents.clear
        self.contents.draw_text(0, 0, self.contents.width, self.contents.font.size, @text, @align)
      end
      #--------------------------------------------------------------------------
      # * Frame update
      #--------------------------------------------------------------------------
      def update
        if @old_text != @text
          refresh
          @old_text = @text.dup
        end
      end
      #--------------------------------------------------------------------------
      # * Get the input value
      #--------------------------------------------------------------------------
      def value; @text; end
      #--------------------------------------------------------------------------
      # * Set the value
      #--------------------------------------------------------------------------
      def value=(text)
        text = text[0..@range-1] if @range
        @text = text 
      end
      #--------------------------------------------------------------------------
      # * Check window activity
      #--------------------------------------------------------------------------
      def active?
        self.active
      end
    end

    #==============================================================================
    # ** Window_Textfield
    #------------------------------------------------------------------------------
    #  Simple inline_textfield
    #==============================================================================

    class Window_Textfield < Window_Field
      #--------------------------------------------------------------------------
      # * Public instance variable
      #--------------------------------------------------------------------------
      attr_accessor :active, :align
      #--------------------------------------------------------------------------
      # * Object initialize
      #--------------------------------------------------------------------------
      def initialize(x, y, w, t="", h=54, align=0, range=-1, ts=22, p=6, pb=6)
        t = t[0..range-1] if range > 0
        super(x, y, w, t, h, align, range, ts, p, pb)
      end
      #--------------------------------------------------------------------------
      # * Update
      #--------------------------------------------------------------------------
      def update
        super
        return unless self.active
        @text = @text[0...@text.length-1] || "" if UI::Keyboard.repeat?(:backspace)
        @text << UI::Keyboard.letter
        self.value = @text
        if @old_text != @text
          refresh
          @old_text = @text.dup
        end
      end
    end

    #==============================================================================
    # ** Window_Intfield
    #------------------------------------------------------------------------------
    #  Simple inline_intfield
    #==============================================================================

    class Window_Intfield < Window_Field
      #--------------------------------------------------------------------------
      # * Public instance variable
      #--------------------------------------------------------------------------
      attr_accessor :active, :align
      #--------------------------------------------------------------------------
      # * Object initialize
      #--------------------------------------------------------------------------
      def initialize(x, y, w, t=0, h=54, align=0, range=-1, ts=22, p=6, pb=6)
        range = -1 unless range.is_a?(Range)
        super(x, y, w, t.to_i.to_s, h, align, range, ts, p, pb)  
        @text = ([[@range.min, t.to_i].max, @range.max].min).to_s if @range
      end
      #--------------------------------------------------------------------------
      # * Get the input value
      #--------------------------------------------------------------------------
      def value; super.to_i; end
      #--------------------------------------------------------------------------
      # * Set the value
      #--------------------------------------------------------------------------
      def value=(text)
        if text == "+" || text == "-"
          @text = text
          return
        end
        text = ([[@range.min, text.to_i].max, @range.max].min).to_s if @range
        @text = text
      end
      #--------------------------------------------------------------------------
      # * Update
      #-------------------------------------------------------------------------- 
      def update
        super
        return unless self.active
        @text = @text[0...@text.length-1] || "" if UI::Keyboard.repeat?(:backspace)
        letter = UI::Keyboard.letter
        return if !["-","+","0","1","2","3","4","5", "6", "7", "8","9"].include?(letter)
        return if @text != "" && (letter == "+" || letter == "-")
        @text << letter
        self.value=@text
      end
    end

    #==============================================================================
    # ** Window_Floatfield
    #------------------------------------------------------------------------------
    #  Simple inline_floatfield
    #==============================================================================

    class Window_Floatfield < Window_Field
      #--------------------------------------------------------------------------
      # * Public instance variable
      #--------------------------------------------------------------------------
      attr_accessor :active, :align
      #--------------------------------------------------------------------------
      # * Object initialize
      #--------------------------------------------------------------------------
      def initialize(x, y, w, t=0.0, h=54, align=0, range=-1, ts=22, p=6, pb=6)
        range = -1 unless range.is_a?(Range)
        super(x, y, w, t.to_f.to_s, h, align, range, ts, p, pb)  
        @text = ([[@range.min, t.to_f].max, @range.max].min).to_s if @range   
      end
      #--------------------------------------------------------------------------
      # * Get the input value
      #--------------------------------------------------------------------------
      def value; super.to_f; end
      #--------------------------------------------------------------------------
      # * Set the value
      #--------------------------------------------------------------------------
      def value=(text)
        @text = text.to_f.to_s
      end
      #--------------------------------------------------------------------------
      # * Update
      #-------------------------------------------------------------------------- 
      def update
        super
        return unless self.active
        @text = @text[0...@text.length-1] || "" if UI::Keyboard.trigger?(:backspace)
        letter = UI::Keyboard.letter
        return if !["-","+","0","1","2","3","4","5", "6", "7", "8","9", "."].include?(letter)
        return if @text != "" && (letter == "+" || letter == "-")
        return if letter == "." && @text.count(".") == 1
        @text << letter
        if @range && !@range.include?(@text.to_f) 
          @text = ([[@range.min, @text.to_f].max, @range.max].min).to_s
        end
      end
    end

  end
end

#==============================================================================
# ** Socket
#------------------------------------------------------------------------------
# Adds the possibility to send/receive messages to/from a server
# Big thanks to Zeus81 (and to Nuki, too)
#==============================================================================

module Socket
  #--------------------------------------------------------------------------
  # * Variable classe
  #--------------------------------------------------------------------------
  @@Socket = false
  #--------------------------------------------------------------------------
  # * Singleton
  #--------------------------------------------------------------------------
  extend self
  #--------------------------------------------------------------------------
  # * Get the single connection
  #--------------------------------------------------------------------------
  def single_socket; @@Socket; end
  #--------------------------------------------------------------------------
  # * Creating the SOCKADDR_IN
  #--------------------------------------------------------------------------
  def sockaddr_in(host, port)
    sin_family = 2
    sin_port = Win32API::Htons.(port)
    in_addr = Win32API::Inet_Addr.(host)
    [sin_family, sin_port, in_addr].pack('sSLx8')
  end
  #--------------------------------------------------------------------------
  # * Creating the Socket
  #--------------------------------------------------------------------------
  def socket; Win32API::Socket.(2, 1, 0); end
  #--------------------------------------------------------------------------
  # * Connecting routine
  #--------------------------------------------------------------------------
  def connect_sock(sock, sockaddr)
    !Win32API::Connect.(sock, sockaddr, sockaddr.size) == -1
  end
  #--------------------------------------------------------------------------
  # * Connecting
  #--------------------------------------------------------------------------
  def connect(host = "127.0.0.1", port = 9999)
     sockaddr = sockaddr_in(host, port)
     sock = self.socket
     connect_sock(sock, sockaddr)
     sock
  end
  #--------------------------------------------------------------------------
  # * Singleton connection
  #--------------------------------------------------------------------------
  def single_connect(host, port = 9999)
    sockaddr = sockaddr_in(host, port)
    @@Socket = self.socket
    connect_sock(@@Socket, sockaddr)
    @@Socket
  end
  #--------------------------------------------------------------------------
  # * Sending data
  #--------------------------------------------------------------------------
  def send(socket, data)
    value = Win32API::Send.(socket, data, data.length, 0)
    shutdown(socket, 2) if value == -1
    return !value == -1 
  end
  #--------------------------------------------------------------------------
  # * Singleton send
  #--------------------------------------------------------------------------
  def single_send(data); send(@@Socket, data); end
  #--------------------------------------------------------------------------
  # * Receiving data
  #--------------------------------------------------------------------------
  def recv(socket, len = 256)
    buffer = [].pack('x'+len.to_s)
    value = Win32API::Recv.(socket, buffer, len, 0)
    return buffer.gsub(/\x00/, "") if value != -1
    false
  end
  #--------------------------------------------------------------------------
  # * Singleton recv
  #--------------------------------------------------------------------------
  def single_recv(len = 256); recv(@@Socket, len); end
  #--------------------------------------------------------------------------
  # * Stops the emission
  #--------------------------------------------------------------------------
  def shutdown(socket, how); Win32API::Shutdown.(socket, how); end
  #--------------------------------------------------------------------------
  # * Closes the connection
  #--------------------------------------------------------------------------
  def close(socket); Win32API::CloseSocket.(socket); end
  #--------------------------------------------------------------------------
  # * Singleton close
  #--------------------------------------------------------------------------
  def single_close; close(@@Socket); end
end

#==============================================================================
# ** Http
#------------------------------------------------------------------------------
# Http API
#==============================================================================

#==============================================================================
# ** Pathfinder
#------------------------------------------------------------------------------
#  Path finder module. A* Algorithm
#==============================================================================

module Pathfinder
  #--------------------------------------------------------------------------
  # * Constants
  #--------------------------------------------------------------------------
  Goal = Struct.new(:x, :y)
  ROUTE_MOVE_DOWN = 1
  ROUTE_MOVE_LEFT = 2
  ROUTE_MOVE_RIGHT = 3
  ROUTE_MOVE_UP = 4
  #--------------------------------------------------------------------------
  # * Definition of a point
  #--------------------------------------------------------------------------
  class Point
    #--------------------------------------------------------------------------
    # * Public Instance Variables
    #--------------------------------------------------------------------------
    attr_accessor :x, :y, :g, :h, :f, :parent, :goal
    #--------------------------------------------------------------------------
    # * Object initialize
    #--------------------------------------------------------------------------
    def initialize(x, y, p, goal = Goal.new(0,0))
      @goal = goal
      @x, @y, @parent = x, y, p
      self.score(@parent)
    end
    #--------------------------------------------------------------------------
    # * get an Id from the X and Y coord
    #--------------------------------------------------------------------------
    def id; "#{@x}-#{@y}"; end
    #--------------------------------------------------------------------------
    # * Calculate score
    #--------------------------------------------------------------------------
    def score(parent)
      if !parent
        @g = 0
      elsif !@g || @g > parent.g + 1
        @g = parent.g + 1
        @parent = parent
      end
      @h = (@x - @goal.x).abs + (@y - @goal.y).abs
      @f = @g + @h
    end
    #--------------------------------------------------------------------------
    # * Cast to move_command
    #--------------------------------------------------------------------------
    def to_move
      return nil unless @parent
      return RPG::MoveCommand.new(2) if @x < @parent.x
      return RPG::MoveCommand.new(3) if @x > @parent.x
      return RPG::MoveCommand.new(4) if @y < @parent.y
      return RPG::MoveCommand.new(1) if @y > @parent.y
      return nil
    end
  end
  #--------------------------------------------------------------------------
  # * singleton
  #--------------------------------------------------------------------------
  extend self
  #--------------------------------------------------------------------------
  # * Id Generation
  #--------------------------------------------------------------------------
  def id(x, y); "#{x}-#{y}"; end
  #--------------------------------------------------------------------------
  # * Check the passability
  #--------------------------------------------------------------------------
  def passable?(x, y, dir); $game_map.passable?(x, y, dir); end
  #--------------------------------------------------------------------------
  # * Check closed_list
  #--------------------------------------------------------------------------
  def has_key?(x, y, l)
    l.has_key?(id(x, y))
  end
  #--------------------------------------------------------------------------
  # * Create a path
  #--------------------------------------------------------------------------
  def create_path(goal, event)
    open_list, closed_list = Hash.new, Hash.new
    current = Point.new(event.x, event.y, nil, goal)
    open_list[current.id] = current
    while !has_key?(goal.x, goal.y, closed_list)&& !open_list.empty?
      current = open_list.values.min{|point1, point2|point1.f <=> point2.f}
      open_list.delete(current.id)
      closed_list[current.id] = current
      args = current.x, current.y+1
      if passable?(current.x, current.y, 2) && !has_key?(*args, closed_list)
        if !has_key?(*args, open_list)
          open_list[id(*args)] = Point.new(*args, current, goal)
        else
          open_list[id(*args)].score(current)
        end
      end
      args = current.x-1, current.y
      if passable?(current.x, current.y, 4) && !has_key?(*args, closed_list)
        if !has_key?(*args, open_list)
          open_list[id(*args)] = Point.new(*args, current, goal)
        else
          open_list[id(*args)].score(current)
        end
      end
      args = current.x+1, current.y
      if passable?(current.x, current.y, 4) && !has_key?(*args, closed_list)
        if !has_key?(*args, open_list)
          open_list[id(*args)] = Point.new(*args, current, goal)
        else
          open_list[id(*args)].score(current)
        end
      end
      args = current.x, current.y-1
      if passable?(current.x, current.y, 2) && !has_key?(*args, closed_list)
        if !has_key?(*args, open_list)
          open_list[id(*args)] = Point.new(*args, current, goal)
        else
          open_list[id(*args)].score(current)
        end
      end
    end
    move_route = RPG::MoveRoute.new
    if has_key?(goal.x, goal.y, closed_list)
      current = closed_list[id(goal.x, goal.y)]
      while current 
        move_command = current.to_move
        move_route.list = [move_command] + move_route.list if move_command
        current = current.parent
      end
    end
    move_route.skippable = true
    move_route.repeat = false
    return move_route
  end
end


#==============================================================================
# ** Area
#------------------------------------------------------------------------------
#  Area definition
#==============================================================================

module Area

  #==============================================================================
  # ** Simple
  #------------------------------------------------------------------------------
  # Defining simple areas
  #==============================================================================

  class Simple
    #--------------------------------------------------------------------------
    # * check if the mouse 's hover
    #--------------------------------------------------------------------------
    def hover?
      in?(UI::Mouse.x, UI::Mouse.y)
    end
    #--------------------------------------------------------------------------
    # * check if the mouse 's hover (square)
    #--------------------------------------------------------------------------
    def hover_square?
      in?(UI::Mouse.x_square, UI::Mouse.y_square)
    end
    #--------------------------------------------------------------------------
    # * check if the mouse 's click the rect
    #--------------------------------------------------------------------------
    def clicked?(key)
      hover? && UI::Mouse.click?(key)
    end
    #--------------------------------------------------------------------------
    # * check if the mouse 's trigger the rect
    #--------------------------------------------------------------------------
    def triggered?(key)
      hover? && UI::Mouse.trigger?(key)
    end
    #--------------------------------------------------------------------------
    # * check if the mouse 's release the rect
    #--------------------------------------------------------------------------
    def released?(key)
      hover? && UI::Mouse.release?(key)
    end
    #--------------------------------------------------------------------------
    # * check if the mouse 's repeated the rect
    #--------------------------------------------------------------------------
    def repeated?(key)
      hover? && UI::Mouse.repeat?(key)
    end
    #--------------------------------------------------------------------------
    # * check if the mouse 's click the rect (square)
    #--------------------------------------------------------------------------
    def clicked_square?(key)
      hover_square? && UI::Mouse.click?(key)
    end
    #--------------------------------------------------------------------------
    # * check if the mouse 's trigger the rect (square)
    #--------------------------------------------------------------------------
    def triggered_square?(key)
      hover_square? && UI::Mouse.trigger?(key)
    end
    #--------------------------------------------------------------------------
    # * check if the mouse 's repeat the rect (square)
    #--------------------------------------------------------------------------
    def repeated_square?(key)
      hover_square? && UI::Mouse.repeat?(key)
    end
    #--------------------------------------------------------------------------
    # * check if the mouse 's release the rect (square)
    #--------------------------------------------------------------------------
    def released_square?(key)
      hover_square? && UI::Mouse.release?(key)
    end
  end

  #==============================================================================
  # ** Rect
  #------------------------------------------------------------------------------
  # Defining rectangular areas
  #==============================================================================

  class Rect < ::Rect
    #--------------------------------------------------------------------------
    # * Constructor
    #--------------------------------------------------------------------------
    def initialize(x1, y1, x2, y2)
      x_min = [x1, x2].min
      x_max = [x1, x2].max
      y_min = [y1, y2].min
      y_max = [y1, y2].max
      width = x_max - x_min
      height = y_max - y_min
      super(x_min, y_min, width, height)
    end
    #--------------------------------------------------------------------------
    # * check if the mouse 's hover (square)
    #--------------------------------------------------------------------------
    def hover_square?
      in?(UI::Mouse.x_square, UI::Mouse.y_square)
    end
    #--------------------------------------------------------------------------
    # * check if the mouse 's click the rect (square)
    #--------------------------------------------------------------------------
    def clicked_square?(key)
      hover_square? && UI::Mouse.click?(key)
    end
  end

  #==============================================================================
  # ** Circle
  #------------------------------------------------------------------------------
  # Defining circular areas
  #==============================================================================

  class Circle < Simple
    #--------------------------------------------------------------------------
    # * Public instance variables
    #--------------------------------------------------------------------------
    attr_accessor :r, :x, :y
    #--------------------------------------------------------------------------
    # * Constructor
    #--------------------------------------------------------------------------
    def initialize(x, y, r)
      set(x, y, r)
    end
    #--------------------------------------------------------------------------
    # * Edits the coordinates
    #--------------------------------------------------------------------------
    def set(x, y, r)
      @x, @y, @r = x, y, r
    end
    #--------------------------------------------------------------------------
    # * check if point 's include in the rect
    #--------------------------------------------------------------------------
    def in?(x, y)
      ((x-@x)**2) + ((y-@y)**2) <= (@r**2)
    end
  end

  #==============================================================================
  # ** Polygon
  #------------------------------------------------------------------------------
  # Defining polygonal areas
  #==============================================================================

  class Polygon < Simple
    #--------------------------------------------------------------------------
    # * Constructor
    #--------------------------------------------------------------------------
    def initialize(points)
      set(points)
    end
    #--------------------------------------------------------------------------
    # * Edits the coordinates
    #--------------------------------------------------------------------------
    def set(points)
      @points = points
    end
    #--------------------------------------------------------------------------
    # * Finds the segment intersection function
    #--------------------------------------------------------------------------
    def intersectsegment(a_x, a_y, b_x, b_y, i_x, i_y, p_x, p_y)
      d_x, d_y = b_x - a_x, b_y - a_y
      e_x, e_y = p_x - i_x, p_y - i_y
      denominator = (d_x * e_y) - (d_y * e_x)
      return -1 if denominator == 0
      t = (i_x*e_y+e_x*a_y-a_x*e_y-e_x*i_y) / denominator
      return 0 if t < 0 || t >= 1
      u = (d_x*a_y-d_x*i_y-d_y*a_x+d_y*i_x) / denominator
      return 0 if u < 0 || u >= 1
      return 1
    end
    #--------------------------------------------------------------------------
    # * check if point 's include in the rect
    #--------------------------------------------------------------------------
    def in?(p_x, p_y)
      i_x, i_y = 10000 + rand(100), 10000 + rand(100)
      nb_intersections = 0
      @points.each_index do |index|
        a_x, a_y = *@points[index]
        b_x, b_y = *@points[(index + 1) % @points.length]
        intersection = intersectsegment(a_x, a_y, b_x, b_y, i_x, i_y, p_x, p_y)
        return in?(p_x, p_y) if intersection == -1
        nb_intersections += intersection
      end
      return (nb_intersections%2 == 1)
    end
  end

  #==============================================================================
  # ** Ellipse
  #------------------------------------------------------------------------------
  # Defining elliptic areas
  #==============================================================================

  class Ellipse < Simple
    #--------------------------------------------------------------------------
    # * Public instance variables
    #--------------------------------------------------------------------------
    attr_accessor :x, :y, :width, :height
    #--------------------------------------------------------------------------
    # * Constructor
    #--------------------------------------------------------------------------
    def initialize(x, y, width, height)
      set(x, y, width, height)
    end
    #--------------------------------------------------------------------------
    # * Edits the coordinates
    #--------------------------------------------------------------------------
    def set(x, y, width, height)
      @x, @y, @width, @height = x, y, width, height
    end
    #--------------------------------------------------------------------------
    # * check if point 's include in the rect
    #--------------------------------------------------------------------------
    def in?(x, y)
      w = ((x.to_f-@x.to_f)**2.0)/(@width.to_f/2.0)
      h = ((y.to_f-@y.to_f)**2.0)/(@height.to_f/2.0)
      w + h <= 1
    end
  end

end

#==============================================================================
# ** Game_Message
#------------------------------------------------------------------------------
#  This class handles the state of the message window that displays text or
# selections, etc. The instance of this class is referenced by $game_message.
#==============================================================================

class Game_Message
  #--------------------------------------------------------------------------
  # * Public Instance Variables
  #--------------------------------------------------------------------------
  attr_accessor :call_event
end

#==============================================================================
# ** Window_Message
#------------------------------------------------------------------------------
#  This message window is used to display text.
#==============================================================================

class Window_Message
  #--------------------------------------------------------------------------
  # * Singleton
  #--------------------------------------------------------------------------
  class << self
    attr_accessor :line_number
    Window_Message.line_number = 4
  end
  #--------------------------------------------------------------------------
  # * Get Number of Lines to Show
  #--------------------------------------------------------------------------
  def visible_line_number
    Window_Message.line_number
  end
end


#==============================================================================
# ** Window_Base
#------------------------------------------------------------------------------
#  This is a super class of all windows within the game.
#==============================================================================

class Window_Base
  #--------------------------------------------------------------------------
  # * Alias
  #--------------------------------------------------------------------------
  alias extender_convert_escape_characters convert_escape_characters
  #--------------------------------------------------------------------------
  # * Preconvert Control Characters
  #    As a rule, replace only what will be changed into text strings before
  #    starting actual drawing. The character "\" is replaced with the escape
  #    character (\e).
  #--------------------------------------------------------------------------
  def convert_escape_characters(text)
    result = extender_convert_escape_characters(text).to_s.clone
    result.gsub!(/\eSV\[([^\]]+)\]/i) do
      numbers = $1.extract_numbers
      array = [*numbers]
      if numbers.length == 1
        array = [$game_message.call_event] + array
      end
      SV[*array]
    end
    return result
  end
  #--------------------------------------------------------------------------
  # * set font size
  #--------------------------------------------------------------------------
  def set_font_size(s)
    self.contents.font.size = s
  end
  #--------------------------------------------------------------------------
  # * point include in textfield
  #--------------------------------------------------------------------------
  def in?(x, y)
    check_x = x.between?(self.x, self.x+self.width)
    check_y = y.between?(self.y, self.y+self.height)
    check_x && check_y
  end
  #--------------------------------------------------------------------------
  # * Mouse include in textfield
  #--------------------------------------------------------------------------
  def hover?
    in?(UI::Mouse.x, UI::Mouse.y)
  end
  #--------------------------------------------------------------------------
  # * Mouse click in textfield
  #--------------------------------------------------------------------------
  def clicked?(key)
    hover? && UI::Mouse.click?(key)
  end
end

#==============================================================================
# ** Game_Screen
#------------------------------------------------------------------------------
#  This class handles screen maintenance data, such as changes in color tone,
# flashes, etc. It's used within the Game_Map and Game_Troop classes.
#==============================================================================

class Game_Screen
  #--------------------------------------------------------------------------
  # * Public Instance Variables
  #--------------------------------------------------------------------------
  attr_reader :tone_duration
end

#==============================================================================
# ** Game_Parallax
#------------------------------------------------------------------------------
#  This class handles Parallaxes. 
#==============================================================================

class Game_Parallax
  #--------------------------------------------------------------------------
  # * Public Instance Variables
  #--------------------------------------------------------------------------
  attr_accessor :id, :name, :z, :opacity, :zoom_x, :zoom_y, :blend_type
  attr_accessor :autospeed_x, :autospeed_y, :move_x, :move_y, :tone
  #--------------------------------------------------------------------------
  # * Initialize
  #--------------------------------------------------------------------------
  def initialize(id)
    @id = id
    @name, @z, @opacity = "", -100, 255
    @zoom_x, @zoom_y = 100.0, 100.0
    @blend_type = 0
    @autospeed_x = @autospeed_y = 0
    @move_x = @move_y = 0
    @tone = Tone.new(0,0,0)
  end
  #--------------------------------------------------------------------------
  # * hide parallax
  #--------------------------------------------------------------------------
  def hide; @name = ""; end
  #--------------------------------------------------------------------------
  # * show
  #--------------------------------------------------------------------------
  def show(n, z, op, a_x, a_y, m_x, m_y, b = 0, z_x = 100.0, z_y = 100.0)
    @name, @z, @opacity = n, z, op
    @zoom_x, @zoom_y = z_x.to_f, z_y.to_f
    @autospeed_x, @autospeed_y = a_x, a_y
    @move_x, @move_y = m_x, m_y
    @blend_type = b
  end
end

#==============================================================================
# ** Game_Picture
#------------------------------------------------------------------------------
#  This class handles pictures. It is created only when a picture of a specific
# number is required internally for the Game_Pictures class.
#==============================================================================

class Game_Picture
  #--------------------------------------------------------------------------
  # * Alias
  #--------------------------------------------------------------------------
  alias extender_initialize initialize
  alias extender_show show
  alias extender_update update
  #--------------------------------------------------------------------------
  # * Public Instance Variables
  #--------------------------------------------------------------------------
  attr_accessor :origin, :x, :y,:zoom_x,:zoom_y
  attr_accessor :opacity,:blend_type,:tone,:angle, :pin
  attr_accessor :mirror, :shake, :wave_amp, :wave_speed
  attr_accessor :text_size, :text_font, :text_color, :text_outline
  attr_accessor :text_bold, :text_shadow, :text_italic, :text_out_color
  #--------------------------------------------------------------------------
  # * Object Initialization
  #--------------------------------------------------------------------------
  def initialize(number)
    extender_initialize(number)
    @mirror = false
    @wave_amp = @wave_speed = 0
    @pin = false
    clear_font
    clear_shake
  end
  #--------------------------------------------------------------------------
  # * Show Picture
  #--------------------------------------------------------------------------
  def show(name, origin, x, y, zoom_x, zoom_y, opacity, blend_type)
    extender_show(name, origin, x, y, zoom_x, zoom_y, opacity, blend_type)
    @mirror = false
    @wave_amp = @wave_speed = 0
    @pin = false
    clear_font
    clear_shake
  end
  #--------------------------------------------------------------------------
  # * Clear Shake
  #--------------------------------------------------------------------------
  def clear_shake
    @shake_power = 0
    @shake_speed = 0
    @shake_duration = 0
    @shake_direction = 1
    @shake = 0
  end
  #--------------------------------------------------------------------------
  # * Clear font
  #--------------------------------------------------------------------------
  def clear_font
    @text_size = @text_font = @text_color = @text_out_color = nil
    @text_outline = @text_bold = @text_shadow = @text_italic = false
  end
  #--------------------------------------------------------------------------
  # * Start Shaking
  #     power: intensity
  #     speed: speed
  #--------------------------------------------------------------------------
  def start_shake(power, speed, duration)
    @shake_power = power
    @shake_speed = speed
    @shake_duration = duration
  end
  #--------------------------------------------------------------------------
  # * Update Shake
  #--------------------------------------------------------------------------
  def update_shake
    if @shake_duration > 0 || @shake != 0
      delta = (@shake_power * @shake_speed * @shake_direction) / 10.0
      if @shake_duration <= 1 && @shake * (@shake + delta) < 0
        @shake = 0
      else
        @shake += delta
      end
      @shake_direction = -1 if @shake > @shake_power * 2
      @shake_direction = 1 if @shake < - @shake_power * 2
      @shake_duration -= 1
    end
  end
  #--------------------------------------------------------------------------
  # * Frame Update
  #--------------------------------------------------------------------------
  def update
    extender_update
    update_shake
  end
end

#==============================================================================
# ** Sprite_Picture
#------------------------------------------------------------------------------
#  This sprite is used to display pictures. It observes an instance of the
# Game_Picture class and automatically changes sprite states.
#==============================================================================

class Sprite_Picture
  #--------------------------------------------------------------------------
  # * Alias
  #--------------------------------------------------------------------------
  alias extender_update update
  alias extender_update_origin update_origin
  #--------------------------------------------------------------------------
  # * Get cache
  #--------------------------------------------------------------------------
  def swap_cache(name)
    if @picture.text_size
      bmp = Bitmap.new(1,1)
      size = @picture.text_size
      font = @picture.text_font|| Font.default_font_name
      color = @picture.text_color || Font.default_color
      out_color = @picture.text_out_color || Font.default_out_color
      bold = @picture.text_bold
      italic = @picture.text_italic
      shadow = @picture.text_shadow
      outline = @picture.text_outline
      bmp.font.name = font
      bmp.font.size = size
      bmp.font.color = color
      bmp.font.out_color = out_color
      bmp.font.bold = bold
      bmp.font.italic = italic
      bmp.font.shadow = shadow
      bmp.font.outline = outline
      rect = bmp.text_size(name)
      bmp = Bitmap.new(rect.width+32, rect.height)
      bmp.font.name = font
      bmp.font.size = size
      bmp.font.color = color
      bmp.font.out_color = out_color
      bmp.font.bold = bold
      bmp.font.italic = italic
      bmp.font.shadow = shadow
      bmp.font.outline = outline
      bmp.draw_text(0, 0, rect.width+32, rect.height, name)
      return bmp
    end
    return Graphics.snap_to_bitmap.clone if name == :screenshot
    if /^(\/Pictures|Pictures)\/(.*)/ =~ name
      return Cache.picture($2)
    end
    if /^(\/Battlers|Battlers)\/(.*)/ =~ name
      return Cache.battler($2, 0)
    end
    if /^(\/Battlebacks1|Battlebacks1)\/(.*)/ =~ name
      return Cache.battleback1($2)
    end
    if /^(\/Battlebacks2|Battlebacks2)\/(.*)/ =~ name
      return Cache.battleback2($2)
    end
    if /^(\/Parallaxes|Parallaxes)\/(.*)/ =~ name
      return Cache.parallax($2)
    end
    if /^(\/Titles1|Titles1)\/(.*)/ =~ name
      return Cache.title1($2)
    end
    if /^(\/Titles2|Titles2)\/(.*)/ =~ name
      return Cache.title2($2)
    end
    return Cache.picture(name)
  end
  #--------------------------------------------------------------------------
  # * Update Transfer Origin Bitmap
  #--------------------------------------------------------------------------
  def update_bitmap
    if @picture.name.empty?
      self.bitmap = nil
    else
      self.bitmap = swap_cache(@picture.name)
    end
  end
  #--------------------------------------------------------------------------
  # * Frame Update
  #--------------------------------------------------------------------------
  def update
    extender_update
    self.mirror = !self.mirror if @picture.mirror != self.mirror
    self.wave_amp = @picture.wave_amp if @picture.wave_amp != self.wave_amp
    self.wave_speed = @picture.wave_speed if @picture.wave_speed != self.wave_speed
  end
  #--------------------------------------------------------------------------
  # * Update Position
  #--------------------------------------------------------------------------
  def update_position
    if @picture.pin
      self.x = @picture.x - ($game_map.display_x * 32) + @picture.shake
      self.y = @picture.y - ($game_map.display_y * 32)
    else
      self.x = @picture.x + @picture.shake
      self.y = @picture.y
    end
    self.z = @picture.number
  end
  #--------------------------------------------------------------------------
  # * Update Origin
  #--------------------------------------------------------------------------
  def update_origin
    if @picture.origin.is_a?(Array)
      x, y = @picture.origin
      self.ox, self.oy = x, y
    else
      extender_update_origin
    end
  end
end

#==============================================================================
# ** Sprite_Character
#------------------------------------------------------------------------------
#  This sprite is used to display characters. It observes an instance of the
# Game_Character class and automatically changes sprite state.
#==============================================================================

class Sprite_Character
  #--------------------------------------------------------------------------
  # * Alias
  #--------------------------------------------------------------------------
  alias extender_update update
  alias extender_initialize initialize
  #--------------------------------------------------------------------------
  # * Object initialization
  #--------------------------------------------------------------------------
  def initialize(viewport, character = nil)
    extender_initialize(viewport, character)
    self.character.buzz = 0
    self.character.buzz_amplitude = 0.1
    self.character.buzz_length = 16
  end
  #--------------------------------------------------------------------------
  # * Calc Buzz
  #--------------------------------------------------------------------------
  def calc_buzz
    sin = self.character.buzz*6.283/self.character.buzz_length
    self.character.buzz_amplitude*Math.sin(sin)
  end
  #--------------------------------------------------------------------------
  # * Frame Update
  #--------------------------------------------------------------------------
  def update
    extender_update
    self.zoom_x = self.zoom_y = 1
    if character
      x_rect, y_rect = self.x-self.ox, self.y-self.oy
      rect_witdh, rect_height = self.src_rect.width, self.src_rect.height
      character.rect.set(x_rect, y_rect, rect_witdh, rect_height)
      unless self.character.buzz== nil || self.character.buzz == 0
        transformation = self.calc_buzz
        self.zoom_x += transformation 
        self.zoom_y -= transformation 
        self.character.buzz -= 1
      end
    end
  end
end

#==============================================================================
# ** Plane_Parallax
#------------------------------------------------------------------------------
#  This plane is used to display parallaxes.
#==============================================================================

class Plane_Parallax < Plane 
  #--------------------------------------------------------------------------
  # * Object initialization
  #--------------------------------------------------------------------------
  def initialize(parallax)
    super()
    @parallax = parallax
    @name = ""
  end
  #--------------------------------------------------------------------------
  # * frame update
  #--------------------------------------------------------------------------
  def update
    if @parallax.name != @name
      @name = @parallax.name
      if @name.empty?
        self.bitmap = nil
        self.visible = false
      else
        self.bitmap = Cache.parallax(@name)
        self.visible = true
        @width_scroll = self.bitmap.width
        @height_scroll = self.bitmap.height
        @scroll_x = @scroll_y = 0
      end
    end
    unless @name.empty?
      update_process 
    end
  end
  #--------------------------------------------------------------------------
  # * Visible update
  #--------------------------------------------------------------------------
  def update_process
    self.z = @parallax.z unless self.z == @parallax.z
    self.opacity = @parallax.opacity unless self.opacity == @parallax.opacity
    self.zoom_x = @parallax.zoom_x / 100.0
    self.zoom_y = @parallax.zoom_y / 100.0
    self.blend_type = @parallax.blend_type if self.blend_type != @parallax.blend_type
    @scroll_x = (@scroll_x + @parallax.autospeed_x) % @width_scroll 
    @scroll_y = (@scroll_y + @parallax.autospeed_y) % @height_scroll 
    self.ox = @scroll_x + ($game_map.display_x * (16*@parallax.move_x))
    self.oy = @scroll_y + ($game_map.display_y * (16*@parallax.move_y))
    self.tone.set(@parallax.tone)
  end
end

#==============================================================================
# ** Spriteset_Map
#------------------------------------------------------------------------------
#  This class brings together map screen sprites, tilemaps, etc. It's used
# within the Scene_Map class.
#==============================================================================

class Spriteset_Map
  #--------------------------------------------------------------------------
  # * alias
  #--------------------------------------------------------------------------
  alias extender_create_parallax create_parallax
  alias extender_dispose_parallax dispose_parallax
  alias extender_update_parallax update_parallax
  #--------------------------------------------------------------------------
  # * Public instance variable
  #--------------------------------------------------------------------------
  attr_reader :tilemap
  #--------------------------------------------------------------------------
  # * Create Parallax
  #--------------------------------------------------------------------------
  def create_parallax
    extender_create_parallax
    @planes_parallaxes = Array.new(20) do |i|
      Plane_Parallax.new($game_map.parallaxes[i])
    end
  end
  #--------------------------------------------------------------------------
  # * Free Parallax
  #--------------------------------------------------------------------------
  def dispose_parallax
    extender_dispose_parallax
    @planes_parallaxes.each do |parallax|
      parallax.dispose if parallax
    end
  end
  #--------------------------------------------------------------------------
  # * Update Parallax
  #--------------------------------------------------------------------------
  def update_parallax
    extender_update_parallax
    @planes_parallaxes.each do |parallax|
      parallax.update if parallax
    end
  end
end

#==============================================================================
# ** Scene_Map
#------------------------------------------------------------------------------
#  This class performs the map screen processing.
#==============================================================================

class Scene_Map
  #--------------------------------------------------------------------------
  # * Public instance variable
  #--------------------------------------------------------------------------
  attr_reader :spriteset
  #--------------------------------------------------------------------------
  # * alias
  #--------------------------------------------------------------------------
  alias extender_start start
  alias extender_update_all_windows update_all_windows
  alias extender_dispose_all_windows dispose_all_windows
  alias extender_update update
  #--------------------------------------------------------------------------
  # * Start
  #--------------------------------------------------------------------------
  def start
    extender_start
    @textbox = []
    @old_call_menu = $game_system.menu_disabled
    @flag = :none
  end
  #--------------------------------------------------------------------------
  # * Update All Windows
  #--------------------------------------------------------------------------
  def update_all_windows
    extender_update_all_windows
    @textbox.each do |textbox|
      textbox.update if textbox
    end
  end
  #--------------------------------------------------------------------------
  # * Free All Windows
  #--------------------------------------------------------------------------
  def dispose_all_windows
    extender_dispose_all_windows
    @textbox.each do |textbox|
      textbox.dispose if textbox && !textbox.disposed?
    end
  end
  #--------------------------------------------------------------------------
  # * Delete a textbox
  #--------------------------------------------------------------------------
  def erase_textbox(textbox)
    t=@textbox.find{|e|e==textbox}
    t.dispose if t
    @textbox.delete(textbox)
    @textbox.compact!
  end
  #--------------------------------------------------------------------------
  # * UnActive all textbox
  #--------------------------------------------------------------------------
  def unactive_all_textbox
    @textbox.each do |t|
      t.active = false if t && !t.disposed?
    end
  end
  #--------------------------------------------------------------------------
  # * add Textbox
  #--------------------------------------------------------------------------
  def add_textbox(textbox)
    @textbox << textbox
    @textbox.uniq!
  end
  #--------------------------------------------------------------------------
  # * refresh spriteset
  #--------------------------------------------------------------------------
  def refresh_spriteset
    dispose_spriteset
    create_spriteset
  end
  #--------------------------------------------------------------------------
  # * Refresh Windows
  #--------------------------------------------------------------------------
  def refresh_message
    @message_window.dispose
    @message_window = Window_Message.new
  end
  #--------------------------------------------------------------------------
  # * Frame Update
  #--------------------------------------------------------------------------
  def update
    extender_update
    if $TEST
      if UI::Keyboard.trigger?(Configuration::KEY_INGAME_EVAL) && @flag != :tone
        @flag = :eval
        if !@evalIG || @evalIG.disposed?
          @old_call_menu = $game_system.menu_disabled
          $game_system.menu_disabled = true
          @evalIG = UI::Form::GameEval.new
        else
          @flag = :none
          @evalIG.dispose
          $game_system.menu_disabled = @old_call_menu
        end
      end
      if UI::Keyboard.trigger?(Configuration::KEY_TONE_MANAGER) && @flag != :eval
        @flag = :tone
        if !@tone_manager || @tone_manager.disposed?
          @old_call_menu = $game_system.menu_disabled
          $game_system.menu_disabled = true
          @tone_manager = UI::Form::ToneManager.new(0, 0)
        else
          @flag = :none
          @tone_manager.dispose
          $game_system.menu_disabled = @old_call_menu
        end
      end
      @tone_manager.update if @flag == :tone
      @evalIG.update if @flag == :eval
     end
  end
end

#==============================================================================
# ** Game_Map
#------------------------------------------------------------------------------
#  This class handles maps. It includes scrolling and passage determination
# functions. The instance of this class is referenced by $game_map.
#==============================================================================

class Game_Map
  #--------------------------------------------------------------------------
  # * alias
  #--------------------------------------------------------------------------
  alias extender_initialize initialize
  #--------------------------------------------------------------------------
  # * Public instance variable
  #--------------------------------------------------------------------------
  attr_accessor :parallaxes, :parallax_x, :parallax_y
  attr_accessor :parallaxes
  attr_accessor :interpreter
  #--------------------------------------------------------------------------
  # * Object Initialization
  #--------------------------------------------------------------------------
  def initialize
    @parallaxes = Array.new(20) do |i|
      Game_Parallax.new(i)
    end
    extender_initialize
  end
  #--------------------------------------------------------------------------
  # * Return Max Event Id
  #--------------------------------------------------------------------------
  def max_id
    @events.keys.max
  end
  #--------------------------------------------------------------------------
  # * Add event to map
  #--------------------------------------------------------------------------
  def add_event(map_id, event_id, new_id,x=nil,y=nil)
    map = load_data(sprintf("Data/Map%03d.rvdata2", map_id))
    return unless map
    event = map.events[event_id]
    return unless event
    event.id = new_id
    @events.store(new_id, Game_Event.new(@map_id, event))
    x ||= event.x
    y ||= event.y
    @events[new_id].moveto(x, y)
    @need_refresh = true
    SceneManager.scene.refresh_spriteset
  end
end

#==============================================================================
# ** Game_CharacterBase
#------------------------------------------------------------------------------
#  This base class handles characters. It retains basic information, such as 
# coordinates and graphics, shared by all characters.
#==============================================================================

class Game_CharacterBase
  #--------------------------------------------------------------------------
  # * alias
  #--------------------------------------------------------------------------
  alias extender_initialize initialize
  #--------------------------------------------------------------------------
  # * Public instance variable
  #--------------------------------------------------------------------------
  attr_accessor :rect
  attr_accessor :buzz
  attr_accessor :buzz_amplitude
  attr_accessor :buzz_length
  #--------------------------------------------------------------------------
  # * Object initialize
  #--------------------------------------------------------------------------
  def initialize
    extender_initialize
    @rect = Rect.new(1, 1, 1, 1)
    @wait_jump = false
  end
  #--------------------------------------------------------------------------
  # * check if mouse 's hover a char
  #--------------------------------------------------------------------------
  def hover?
    @rect.hover?
  end
  #--------------------------------------------------------------------------
  # * check if mouse 's clicked a char
  #--------------------------------------------------------------------------
  def clicked?(key)
    @rect.clicked?(key)
  end
  #--------------------------------------------------------------------------
  # * Move to x y coord
  #--------------------------------------------------------------------------
  def move_to_position(x, y, wait=false)
    return if not $game_map.passable?(x,y,0)
    route = Pathfinder.create_path(Pathfinder::Goal.new(x, y), self)
    self.force_move_route(route)
    Fiber.yield while self.move_route_forcing if wait
  end
  #--------------------------------------------------------------------------
  # * Jump to coord
  #--------------------------------------------------------------------------
  def jump_to(x, y, wait=true)
    t_w = @wait_jump
    @wait_jump = wait
    return false if t_w && jumping?
    x_plus, y_plus = x-@x, y-@y
    if x_plus.abs > y_plus.abs
      set_direction(x_plus < 0 ? 4 : 6) if x_plus != 0
    else
      set_direction(y_plus < 0 ? 8 : 2) if y_plus != 0
    end
    return if not $game_map.passable?(x,y,self.direction)
    jump(x_plus, y_plus)
  end
end

#==============================================================================
# ** Game_Event
#------------------------------------------------------------------------------
#  This class handles events. Functions include event page switching via
# condition determinants and running parallel process events. Used within the
# Game_Map class.
#==============================================================================

class Game_Event
  #--------------------------------------------------------------------------
  # * Add command API
  #--------------------------------------------------------------------------
  include CommandAPI
  #--------------------------------------------------------------------------
  # * Alias
  #--------------------------------------------------------------------------
  alias extender_conditions_met? conditions_met?
  alias extender_update update
  #--------------------------------------------------------------------------
  # * Public instance variables
  #--------------------------------------------------------------------------
  attr_accessor :id
  attr_accessor :interpreter
  #--------------------------------------------------------------------------
  # * Singleton
  #--------------------------------------------------------------------------
  class << self
    attr_accessor :last_clicked_event
  end
  #--------------------------------------------------------------------------
  # * Determine if Event Page Conditions Are Met
  #--------------------------------------------------------------------------
  def conditions_met?(page)
    value = extender_conditions_met?(page)
    first = first_is_comment?(page)
    return value unless first
    condition_comment = true
    if first =~ /^Trigger\s*:\s*(.+)/
      trigger_data = $~[1]
      trigger_data.gsub!(/SV\[(?<v_id>\d+)\]/, "SV[#{@map_id},#{@id},"+'\k<v_id>]')
      trigger_data.gsub!(/SS\[(?<v_id>\d+)\]/, "SS[#{@map_id},#{@id},"+'\k<v_id>]')
      begin
        condition_comment = eval(trigger_data, $game_map.interpreter.get_binding)
      rescue 
        condition_comment = false
      end
    end
    return value && condition_comment
  end
  #--------------------------------------------------------------------------
  # * Determine if the first command is a Comment
  #--------------------------------------------------------------------------
  def first_is_comment?(page)
    return false unless page || page.list || page.list[0]
    return false unless page.list[0].code == 108
    index = 1
    list = [page.list[0].parameters[0]]
    while page.list[index].code == 408
      list << page.list[index].parameters[0]
      index += 1
    end
    return list.collect{|line|line+=" "}.join
  end
  #--------------------------------------------------------------------------
  # * Frame Update
  #--------------------------------------------------------------------------
  def update
    extender_update
    if cmd(:mouse_clicked_event?, @id, :mouse_left)
      Game_Event.last_clicked_event = @id 
    end
  end
end

#==============================================================================
# ** Game_Player
#------------------------------------------------------------------------------
#  This class handles the player. It includes event starting determinants and
# map scrolling functions. The instance of this class is referenced by
# $game_player.
#==============================================================================

class Game_Player
  #--------------------------------------------------------------------------
  # * Alias
  #--------------------------------------------------------------------------
  alias extender_update update
  #--------------------------------------------------------------------------
  # * Frame Update
  #--------------------------------------------------------------------------
  def update
    extender_update
    if cmd(:mouse_clicked_event?, 0, :mouse_left)
      Game_Event.last_clicked_event = 0
    end
  end
end

#==============================================================================
# ** Game_Interpreter
#------------------------------------------------------------------------------
#  An interpreter for executing event commands. This class is used within the
# Game_Map, Game_Troop, and Game_Event classes.
#==============================================================================

class Game_Interpreter
  #--------------------------------------------------------------------------
  # * Alias
  #--------------------------------------------------------------------------
  alias extender_command_101 command_101
  alias extender_command_111 command_111
  alias extender_command_105 command_105
  alias extender_command_355 command_355 
  #--------------------------------------------------------------------------
  # * Access to event_id
  #--------------------------------------------------------------------------
  attr_accessor :event_id
  #--------------------------------------------------------------------------
  # * Singleton
  #--------------------------------------------------------------------------
  class << self
    #--------------------------------------------------------------------------
    # * Public instances variables
    #--------------------------------------------------------------------------
    attr_accessor :current_event_id
    attr_accessor :current_map_id
  end
  #--------------------------------------------------------------------------
  # * Show Text
  #--------------------------------------------------------------------------
  def command_101
    $game_message.call_event = @event_id
    extender_command_101
  end
  #--------------------------------------------------------------------------
  # * Show Scrolling Text
  #--------------------------------------------------------------------------
  def command_105
    $game_message.call_event = @event_id
    extender_command_105
  end
  #--------------------------------------------------------------------------
  # * Append Interpreter
  #--------------------------------------------------------------------------
  def append_interpreter(map_id, event_id, page_id)
    map = load_data(sprintf("Data/Map%03d.rvdata2", map_id))
    return unless map
    event = map.events[event_id]
    return unless event
    page = event.pages[page_id-1]
    return unless page
    list = page.list
    child = Game_Interpreter.new(@depth + 1)
    child.setup(list, same_map? ? @event_id : 0)
    child.run
  end
  #--------------------------------------------------------------------------
  # * Conditional Branch
  #--------------------------------------------------------------------------
  def command_111
    Game_Interpreter.current_event_id = @event_id
    Game_Interpreter.current_map_id = @map_id
    extender_command_111
  end
  #--------------------------------------------------------------------------
  # * Script
  #--------------------------------------------------------------------------
  def command_355
    Game_Interpreter.current_event_id = @event_id
    Game_Interpreter.current_map_id = @map_id
    extender_command_355
  end
  #--------------------------------------------------------------------------
  # * Add command API
  #--------------------------------------------------------------------------
  include CommandAPI
  include Command
  #--------------------------------------------------------------------------
  # * Get Binding
  #--------------------------------------------------------------------------
  def get_binding
    return binding
  end
end

#==============================================================================
# ** DataManager
#------------------------------------------------------------------------------
# Data of save manager
#==============================================================================

module DataManager
  #--------------------------------------------------------------------------
  # * Singleton
  #--------------------------------------------------------------------------
  class << self
    #--------------------------------------------------------------------------
    # * Alias
    #--------------------------------------------------------------------------
    alias extender_create_game_objects create_game_objects
    alias extender_make_save_contents make_save_contents
    alias extender_extract_save_contents extract_save_contents
    #--------------------------------------------------------------------------
    # * Creates the objects of the game
    #--------------------------------------------------------------------------
    def create_game_objects
      extender_create_game_objects
      $game_self_vars = Hash.new
    end
    #--------------------------------------------------------------------------
    # * Saves the contents of the game
    #--------------------------------------------------------------------------
    def make_save_contents
      contents = extender_make_save_contents
      contents[:self_vars] = $game_self_vars
      contents
    end
    #--------------------------------------------------------------------------
    # * Load a save
    #--------------------------------------------------------------------------
    def extract_save_contents(contents)
      extender_extract_save_contents(contents)
      $game_self_vars = contents[:self_vars]
    end
    #--------------------------------------------------------------------------
    # * export data
    #--------------------------------------------------------------------------
    def export(index)
      filename = sprintf("Save%02d.rvdata2", index)
      datas = Hash.new
      File.open(filename, "rb") do |file|
        Marshal.load(file)
        contents = Marshal.load(file)
        game_system        = contents[:system]
        game_timer         = contents[:timer]
        game_message       = contents[:message]
        datas[:switches]   = contents[:switches]
        datas[:variables]  = contents[:variables]
        datas[:self_switches] = contents[:self_switches]
        game_actors        = contents[:actors]
        game_party         = contents[:party]
        game_troop         = contents[:troop]
        game_map           = contents[:map]
        game_player        = contents[:player]
        datas[:self_vars]  = contents[:self_vars]
      end
      datas
    end
  end
end

#==============================================================================
# ** Input
#------------------------------------------------------------------------------
#  A module that handles input data from a gamepad or keyboard.
#==============================================================================

module Input 
  #--------------------------------------------------------------------------
  # * Singleton
  #--------------------------------------------------------------------------
  class << self
    #--------------------------------------------------------------------------
    # * Alias
    #--------------------------------------------------------------------------
    alias extender_update update
    #--------------------------------------------------------------------------
    # * Input Update
    #--------------------------------------------------------------------------
    def update
      UI::Keyboard.update
      UI::Mouse.update
      extender_update
    end
  end
end

#==============================================================================
# ** Command
#------------------------------------------------------------------------------
# Adds easily usable commands
#==============================================================================

module Command
  #--------------------------------------------------------------------------
  # * Private API
  #--------------------------------------------------------------------------
  def screen; $game_map.screen; end
  def pictures; screen.pictures; end
  def scene; SceneManager.scene; end
  def spriteset; scene.spriteset; end
  def tilemap; spriteset.tilemap; end
  def troop(id); $data_troops[id]; end
  def enemy(id); $data_enemies[id]; end
  def event(id);(id < 1) ? $game_player : $game_map.events[id]; end

  private :screen, :pictures, :event, :troop
  private :scene, :spriteset, :tilemap, :enemy
  #==============================================================================
  # ** Std
  #------------------------------------------------------------------------------
  # Standard command
  #==============================================================================

  #--------------------------------------------------------------------------
  # * Get a random number
  #--------------------------------------------------------------------------
  def random(x, y); x + rand(y-x); end
  #--------------------------------------------------------------------------
  # * Get the map id
  #--------------------------------------------------------------------------
  def map_id; $game_map.map_id; end
  #--------------------------------------------------------------------------
  # * Get the max Event ID
  #--------------------------------------------------------------------------
  def max_event_id; $game_map.max_id; end
  #--------------------------------------------------------------------------
  # * Get Tile ID from coords and layer (0,1,2)
  #--------------------------------------------------------------------------
  def tile_id(x, y, layer)
    $game_map.tile_id(x, y, layer)
  end
  #--------------------------------------------------------------------------
  # * Get terrain Tag from coords
  #--------------------------------------------------------------------------
  def terrain_tag(x, y)
    $game_map.terrain_tag(x, y)
  end
  #--------------------------------------------------------------------------
  # * Get Event Id form coords
  #--------------------------------------------------------------------------
  def id_at(x, y)
    result = $game_map.id_xy(x, y)
    return result if result > 0
    return 0 if $game_player.x == x && $game_player.y == y
    return -1
  end
  #--------------------------------------------------------------------------
  # * Get Region ID from coords
  #--------------------------------------------------------------------------
  def region_id(x, y)
    $game_map.region_id(x, y)
  end
  #--------------------------------------------------------------------------
  # * Get a percent
  #--------------------------------------------------------------------------
  def percent(value, max); (value*100)/max; end
  #--------------------------------------------------------------------------
  # * Get a value from a percent
  #--------------------------------------------------------------------------
  def proportion(percent, max); (percent*max)/100; end
  #--------------------------------------------------------------------------
  # * return a color
  #--------------------------------------------------------------------------
  def color(r, g, b, a=255); Color.new(r, g, b, a); end
  #--------------------------------------------------------------------------
  # * Flash a tile
  #--------------------------------------------------------------------------
  def flash_square(*coords, r, g, b)
    r = proportion(percent(r, 255), 15)
    g = proportion(percent(g, 255), 15)
    b = proportion(percent(r, 255), 15)
    color = (r.to_s(16)+g.to_s(16)+b.to_s(16)).to_i(16)
    tilemap.flash_data ||= Table.new($game_map.width, $game_map.height)
    case coords.length
    when 1
      coords.each{|i|tilemap.flash_data[i[0], i[1]] = color}
      return true
    when 2
      if coords[0].is_a?(Enumerable) && coords[1].is_a?(Enumerable)
        coords[1].each do |y|
          coords[0].each do |x|
            tilemap.flash_data[x, y] = color
          end
        end
        return true
      end
      if coords[0].is_a?(Enumerable) && coords[1].is_a?(Numeric)
        coords[0].each{|x|tilemap.flash_data[x, coords[1]] = color}
        return true
      end
      if coords[1].is_a?(Enumerable) && coords[0].is_a?(Numeric)
        coords[1].each{|y|tilemap.flash_data[coords[0], y] = color}
        return true
      end
      if coords[0].is_a?(Numeric) && coords[1].is_a?(Numeric)
        tilemap.flash_data[coords[0], coords[1]] = color
        return true
      end
    end
    return false
  end
  #--------------------------------------------------------------------------
  # * UnFlash a tile
  #--------------------------------------------------------------------------
  def unflash_square(*c)
    flash_square(*c, 0, 0, 0)
  end
  #--------------------------------------------------------------------------
  # * Check passability
  #--------------------------------------------------------------------------
  def square_passable?(x, y, d=2)
    $game_map.passable?(x, y, d)
  end

  #==============================================================================
  # ** System
  #------------------------------------------------------------------------------
  # System command
  #==============================================================================

  #--------------------------------------------------------------------------
  # * Get the team size
  #--------------------------------------------------------------------------
  def team_size; $game_party.members.size; end
  #--------------------------------------------------------------------------
  # * Get the gold
  #--------------------------------------------------------------------------
  def gold; $game_party.gold; end
  #--------------------------------------------------------------------------
  # * Count the steps
  #--------------------------------------------------------------------------
  def steps; $game_party.steps; end
  #--------------------------------------------------------------------------
  # * Get the play time
  #--------------------------------------------------------------------------
  def play_time; (Graphics.frame_count / Graphics.frame_rate); end
  #--------------------------------------------------------------------------
  # * Get the timer value
  #--------------------------------------------------------------------------
  def timer; $game_timer.sec; end
  #--------------------------------------------------------------------------
  # * Get a the number of save
  #--------------------------------------------------------------------------
  def save_count; $game_system.save_count; end
  #--------------------------------------------------------------------------
  # * Get the number of battle
  #--------------------------------------------------------------------------
  def battle_count; $game_system.battle_count; end

  #==============================================================================
  # ** Items
  #------------------------------------------------------------------------------
  # Operand for items
  #==============================================================================

  #--------------------------------------------------------------------------
  # * Get the number of an item
  #--------------------------------------------------------------------------
  def item_count(id); $game_party.item_number($data_items[id]); end
  #--------------------------------------------------------------------------
  # * Get the number of a weapon
  #--------------------------------------------------------------------------
  def weapon_count(id); $game_party.item_number($data_weapons[id]); end
  #--------------------------------------------------------------------------
  # * Get the number of an armor
  #--------------------------------------------------------------------------
  def armor_count(id); $game_party.item_number($data_armors[id]); end
  #--------------------------------------------------------------------------
  # * Get the name of an item
  #--------------------------------------------------------------------------
  def item_name(id); $data_items[id].name; end
  #--------------------------------------------------------------------------
  # * Get the name of a Weapon
  #--------------------------------------------------------------------------
  def weapon_name(id); $data_weapons[id].name; end
  #--------------------------------------------------------------------------
  # * Get the name of an armor
  #--------------------------------------------------------------------------
  def armor_name(id); $data_armors[id].name; end

  #==============================================================================
  # ** Party
  #------------------------------------------------------------------------------
  # Operand of the party
  #==============================================================================

  #--------------------------------------------------------------------------
  # * Get the level of an actor
  #--------------------------------------------------------------------------
  def actor_level(id); $game_actors[id].level; end
  #--------------------------------------------------------------------------
  # * Get the experience of an actor
  #--------------------------------------------------------------------------
  def actor_experience(id); $game_actors[id].exp; end
  alias actor_exp actor_experience
  #--------------------------------------------------------------------------
  # * Get the hp of an actor
  #--------------------------------------------------------------------------
  def actor_hp(id); $game_actors[id].hp; end
  #--------------------------------------------------------------------------
  # * Get the mp of an actor
  #--------------------------------------------------------------------------
  def actor_mp(id); $game_actors[id].mp; end
  #--------------------------------------------------------------------------
  # * Get the max hp of an actor
  #--------------------------------------------------------------------------
  def actor_max_hp(id); $game_actors[id].mhp; end
  alias actor_mhp actor_max_hp
  #--------------------------------------------------------------------------
  # * Get the max_mp of an actor
  #--------------------------------------------------------------------------
  def actor_max_mp(id); $game_actors[id].mmp; end
  alias actor_mmp actor_max_mp
  #--------------------------------------------------------------------------
  # * Get the attack of an actor
  #--------------------------------------------------------------------------
  def actor_attack(id); $game_actors[id].atk; end
  alias actor_atk actor_attack
  #--------------------------------------------------------------------------
  # * Get the defense of an actor
  #--------------------------------------------------------------------------
  def actor_defense(id); $game_actors[id].def; end
  alias actor_def actor_defense
  #--------------------------------------------------------------------------
  # * Get the magic of an actor
  #--------------------------------------------------------------------------
  def actor_magic(id); $game_actors[id].mat; end
  alias actor_mag actor_magic
  alias actor_magi actor_magic
  alias actor_mat actor_magic
  #--------------------------------------------------------------------------
  # * Get the magic defense of an actor
  #--------------------------------------------------------------------------
  def actor_magic_defense(id); $game_actors[id].mdf; end
  alias actor_mdf actor_magic_defense
  #--------------------------------------------------------------------------
  # * Get the agility of an actor
  #--------------------------------------------------------------------------
  def actor_agility(id); $game_actors[id].agi; end
  alias actor_agi actor_agility
  #--------------------------------------------------------------------------
  # * Get the luck defense of an actor
  #--------------------------------------------------------------------------
  def actor_luck(id); $game_actors[id].luk; end
  alias actor_luk actor_luck
  #--------------------------------------------------------------------------
  # * change actor name
  #--------------------------------------------------------------------------
  def set_actor_name(id, name); $game_actors[id].name = name; end
  #--------------------------------------------------------------------------
  # * get actor name
  #--------------------------------------------------------------------------
  def actor_name(id); $game_actors[id].name; end
  #--------------------------------------------------------------------------
  # * Monster reading
  #--------------------------------------------------------------------------
  def read_monster_data(id, method = false)
    monster = $data_enemies[id]
    return monster unless method
    method = method.to_sym
    value = false
    value = 0 if method == :mhp || method == :hp
    value = 1 if method == :mmp || method == :mp
    value = 2 if method == :atk || method == :attack
    value = 3 if method == :def || method == :defense
    value = 4 if method == :mat || method == :magic_attack
    value = 5 if method == :mdf || method == :magic_defense
    value = 6 if method == :agi || method == :agility
    value = 7 if method == :luk || method == :luck
    return monster.params[value] if value
    monster.send(method)
  end
  #--------------------------------------------------------------------------
  # * Monster hp
  #--------------------------------------------------------------------------
  def monster_hp(id); read_monster_data(id, :hp); end
  alias monster_mhp monster_hp
  #--------------------------------------------------------------------------
  # * Monster mp
  #--------------------------------------------------------------------------
  def monster_mp(id); read_monster_data(id, :mp); end
  alias monster_mmp monster_mp
  #--------------------------------------------------------------------------
  # * Monster attack
  #--------------------------------------------------------------------------
  def monster_attack(id); read_monster_data(id, :atk); end
  alias monster_atk monster_attack
  #--------------------------------------------------------------------------
  # * Monster defense
  #--------------------------------------------------------------------------
  def monster_defense(id); read_monster_data(id, :def); end
  alias monster_def monster_defense
  #--------------------------------------------------------------------------
  # * Monster magic attack
  #--------------------------------------------------------------------------
  def monster_magic_attack(id); read_monster_data(id, :mat); end
  alias monster_mat monster_magic_attack
  #--------------------------------------------------------------------------
  # * Monster magic defense
  #--------------------------------------------------------------------------
  def monster_magic_defense(id); read_monster_data(id, :mdf); end
  alias monster_mdf monster_magic_defense
  #--------------------------------------------------------------------------
  # * Monster agility
  #--------------------------------------------------------------------------
  def monster_agility(id); read_monster_data(id, :agi); end
  alias monster_agi monster_agility
  #--------------------------------------------------------------------------
  # * Monster Luck
  #--------------------------------------------------------------------------
  def monster_luck(id); read_monster_data(id, :luk); end
  alias monster_luk monster_luck
  #--------------------------------------------------------------------------
  # * Monster 's name
  #--------------------------------------------------------------------------
  def monster_name(id); 
    $data_enemies[id].name
  end
  #--------------------------------------------------------------------------
  # * Troop size
  #--------------------------------------------------------------------------
  def troop_size(id); troop(id).members.size; end
  #--------------------------------------------------------------------------
  # * Get the id of a member of the troop
  #--------------------------------------------------------------------------
  def troop_member_id(id, position); troop(id).members[position-1].enemy_id; end
  #--------------------------------------------------------------------------
  # * Get the x coord of a member of the troop
  #--------------------------------------------------------------------------
  def troop_member_x(id, position); troop(id).members[position-1].x; end
  #--------------------------------------------------------------------------
  # * Get the y coord of a member of the troop
  #--------------------------------------------------------------------------
  def troop_member_y(id, position); troop(id).members[position-1].y; end
  #--------------------------------------------------------------------------
  # * Skill reading
  #--------------------------------------------------------------------------
  def read_skill_data(id, method = false)
    skill = $data_skills[id]
    return skill unless method
    skill.send(method.to_sym)
  end

  #==============================================================================
  # ** Mouse
  #------------------------------------------------------------------------------
  # Command for the mouse device
  #==============================================================================

  #--------------------------------------------------------------------------
  # * Get mouse X 
  #--------------------------------------------------------------------------
  def mouse_x; UI::Mouse.x; end
  #--------------------------------------------------------------------------
  # * Get mouse y 
  #--------------------------------------------------------------------------
  def mouse_y; UI::Mouse.y; end
  #--------------------------------------------------------------------------
  # * Get mouse X (in square) 
  #--------------------------------------------------------------------------
  def mouse_x_square; UI::Mouse.x_square; end
  #--------------------------------------------------------------------------
  # * Get mouse Y (in square) 
  #--------------------------------------------------------------------------
  def mouse_y_square; UI::Mouse.y_square; end
  #--------------------------------------------------------------------------
  # * Determine if mouse 's clicked
  #--------------------------------------------------------------------------
  def mouse_click?(key); UI::Mouse.click?(key); end
  #--------------------------------------------------------------------------
  # * Determine if mouse 's triggered
  #--------------------------------------------------------------------------
  def mouse_trigger?(key); UI::Mouse.trigger?(key); end
  #--------------------------------------------------------------------------
  # * Determine if mouse 's repeated
  #--------------------------------------------------------------------------
  def mouse_repeat?(key); UI::Mouse.repeat?(key); end
  #--------------------------------------------------------------------------
  # * Determine if mouse 's release
  #--------------------------------------------------------------------------
  def mouse_release?(key); UI::Mouse.release?(key); end
  #--------------------------------------------------------------------------
  # * Get the mouse'rect (selection)
  #--------------------------------------------------------------------------
  def mouse_rect; UI::Mouse.rect; end
  #--------------------------------------------------------------------------
  # * Determine if point 's include in Mouse rect (selection)
  #--------------------------------------------------------------------------
  def point_in_mouse_rect?(x, y); mouse_rect.in?(x, y); end
  #--------------------------------------------------------------------------
  # * Determine if mouse 's hover an event (0 = Heroes)
  #--------------------------------------------------------------------------
  def mouse_hover_event?(id); event(id).hover?; end
  #--------------------------------------------------------------------------
  # * Determine if an event (0 = Heroes) is clicked
  #--------------------------------------------------------------------------
  def mouse_clicked_event?(id, key); event(id).clicked?(key); end
  #--------------------------------------------------------------------------
  # * Determine if mouse 's hover the player
  #--------------------------------------------------------------------------
  def mouse_hover_player?; event(0).hover?; end
  #--------------------------------------------------------------------------
  # * Return ID of the last clicked event
  #--------------------------------------------------------------------------
  def last_clicked_event; Game_Event.last_clicked_event; end
  #--------------------------------------------------------------------------
  # * Determine if the player is clicked
  #--------------------------------------------------------------------------
  def mouse_clicked_player?(key); event(0).clicked?(key); end
  #--------------------------------------------------------------------------
  # * Show the Windows 's cursor
  #--------------------------------------------------------------------------
  def show_cursor_system(flag); UI::Mouse.show_cursor_system(flag); end

  #==============================================================================
  # ** Keyboard
  #------------------------------------------------------------------------------
  # Command for the keyboard device
  #==============================================================================

  #--------------------------------------------------------------------------
  # * Key press?
  #--------------------------------------------------------------------------
  def key_press?(key); UI::Keyboard.press?(key); end
  #--------------------------------------------------------------------------
  # * Key trigger?
  #--------------------------------------------------------------------------
  def key_trigger?(key); UI::Keyboard.trigger?(key); end
  #--------------------------------------------------------------------------
  # * Key repeat?
  #--------------------------------------------------------------------------
  def key_repeat?(key); UI::Keyboard.repeat?(key); end
  #--------------------------------------------------------------------------
  # * Key release?
  #--------------------------------------------------------------------------
  def key_release?(key); UI::Keyboard.release?(key); end
  #--------------------------------------------------------------------------
  # * Check if keyboard's capslocked
  #--------------------------------------------------------------------------
  def caps_lock?; UI::Keyboard.caps_lock?; end
  #--------------------------------------------------------------------------
  # * Check if keyboard's numlocked
  #--------------------------------------------------------------------------
  def num_lock?; UI::Keyboard.num_lock?; end
  #--------------------------------------------------------------------------
  # * Check if keyboard's scrolllocked
  #--------------------------------------------------------------------------
  def scroll_lock?; UI::Keyboard.scroll_lock?; end
  #--------------------------------------------------------------------------
  # * Check if keyboard's MAJ
  #--------------------------------------------------------------------------
  def maj?; UI::Keyboard.maj?; end
  #--------------------------------------------------------------------------
  # * Check if keyboard's alt_gr?
  #--------------------------------------------------------------------------
  def alt_gr?; UI::Keyboard.alt_gr?; end
  #--------------------------------------------------------------------------
  # * Get the current key number pressed
  #--------------------------------------------------------------------------
  def key_number; UI::Keyboard.number.to_i; end
  #--------------------------------------------------------------------------
  # * Get the current key char pressed
  #--------------------------------------------------------------------------
  def key_char; UI::Keyboard.letter; end

  #==============================================================================
  # ** Events
  #------------------------------------------------------------------------------
  # Command for the events manipulation
  #==============================================================================

  #--------------------------------------------------------------------------
  # * Get the x of an event (square)
  #--------------------------------------------------------------------------
  def event_x(id); event(id).x; end
  #--------------------------------------------------------------------------
  # * Get the y of an event (square)
  #--------------------------------------------------------------------------
  def event_y(id); event(id).y; end
  #--------------------------------------------------------------------------
  # * Get the x (on screen) of an event
  #--------------------------------------------------------------------------
  def event_screen_x(id); event(id).screen_x; end
  #--------------------------------------------------------------------------
  # * Get the y (on screen) of an event
  #--------------------------------------------------------------------------
  def event_screen_y(id); event(id).screen_y; end
  #--------------------------------------------------------------------------
  # * Get the y of an event in pixels
  #--------------------------------------------------------------------------
  def event_pixel_y(id) 
    ($game_map.display_y * 32) + event_screen_y(id)
  end
  #--------------------------------------------------------------------------
  # * Get the x of an event in pixels
  #--------------------------------------------------------------------------
  def event_pixel_x(id) 
    ($game_map.display_x * 32) + event_screen_x(id)
  end
  #--------------------------------------------------------------------------
  # * Get the direction of an event
  #--------------------------------------------------------------------------
  def event_direction(id); event(id).direction; end
  #--------------------------------------------------------------------------
  # * Get the x of the player (square)
  #--------------------------------------------------------------------------
  def player_x; event(0).x; end
  #--------------------------------------------------------------------------
  # * Get the y of the player (square)
  #--------------------------------------------------------------------------
  def player_y; event(0).y; end
  #--------------------------------------------------------------------------
  # * Get the x (on screen) of the player
  #--------------------------------------------------------------------------
  def player_screen_x; event(0).screen_x; end
  #--------------------------------------------------------------------------
  # * Get the y (on screen) of the player
  #--------------------------------------------------------------------------
  def player_screen_y; event(0).screen_y; end
  #--------------------------------------------------------------------------
  # * Get the x of player in pixels
  #--------------------------------------------------------------------------
  def player_pixel_x; event_pixel_x(0); end
  #--------------------------------------------------------------------------
  # * Get the y of player in pixels
  #--------------------------------------------------------------------------
  def player_pixel_y; event_pixel_y(0); end
  #--------------------------------------------------------------------------
  # * Get the direction of the player
  #--------------------------------------------------------------------------
  def player_direction; event(0).direction; end
  #--------------------------------------------------------------------------
  # * Get the distance between two events
  # flag = :square (in square) || _ (in pixel)
  #--------------------------------------------------------------------------
  def distance_between(flag, ev1, ev2)
    ev1, ev2 = event(ev1), event(ev2)
    args = (ev1.screen_x-ev2.screen_x),(ev1.screen_y-ev2.screen_y)
    args = (ev1.x-ev2.x),(ev1.y-ev2.y) if flag == :square
    Math.hypot(*args).to_i
  end
  #--------------------------------------------------------------------------
  # * Squares between two event
  #--------------------------------------------------------------------------
  def squares_between(ev1, ev2); distance_between(:square, ev1, ev2); end
  #--------------------------------------------------------------------------
  # * Pixels between two event
  #--------------------------------------------------------------------------
  def pixels_between(ev1, ev2); distance_between(:pixel, ev1, ev2); end
  #--------------------------------------------------------------------------
  # * Event look another event
  #--------------------------------------------------------------------------
  def look_at(ev, to, scope, metric = :square)
    if event_direction(ev) == 8
      x_axis = event_x(to) == event_x(ev)
      y_axis = event_y(ev) > event_y(to)
    end
    if event_direction(ev) == 2
      x_axis = event_x(to) == event_x(ev)
      y_axis = event_y(ev) < event_y(to)
    end
    if event_direction(ev) == 4
      x_axis = event_x(to) < event_x(ev)
      y_axis = event_y(ev) == event_y(to)
    end
    if event_direction(ev) == 6
      x_axis = event_x(to) > event_x(ev)
      y_axis = event_y(ev) == event_y(to)
    end
    return x_axis && y_axis && (distance_between(metric, ev, to)<=scope)
  end
  #--------------------------------------------------------------------------
  # * Move event to x, y coords
  #--------------------------------------------------------------------------
  def move_to(id, x, y, w=false); event(id).move_to_position(x, y, w); end
  #--------------------------------------------------------------------------
  # * Jump event to x, y coords
  #--------------------------------------------------------------------------
  def jump_to(id, x, y, w=true); event(id).jump_to(x, y, w); end
  #--------------------------------------------------------------------------
  # * buzz event
  #--------------------------------------------------------------------------
  def buzz(*ids)
    amplitude = 0.1
    duration = 16
    periode = 16
    ids.each do |id|
      ev = event(id)
      ev.buzz = duration
      ev.buzz_length = periode
      ev.buzz_amplitude = amplitude
    end
  end
  #--------------------------------------------------------------------------
  # * determine collision (ev1 with ev2)
  #--------------------------------------------------------------------------
  def collide?(ev1, ev2)
    event1 = event(ev1)
    event2 = event(ev2)
    flag = case event1.direction
    when 2; event2.x == event1.x && event2.y == event1.y+1
    when 4; event2.x == event1.x-1 && event2.y == event1.y
    when 6; event2.x == event1.x+1 && event2.y == event1.y
    when 8; event2.x == event1.x && event2.y == event1.y-1
    else; false
    end
    return flag && !event1.moving?
  end
  #--------------------------------------------------------------------------
  # * determine if event 's in the screen
  #--------------------------------------------------------------------------
  def event_in_screen?(id)
    ev = event(id)
    check_x = ev.screen_x > 0 && ev.screen_x < Graphics.width
    check_y = ev.screen_y > 0 && ev.screen_y < Graphics.height
    check_x && check_y
  end
  #--------------------------------------------------------------------------
  # * determine if player's in the screen
  #--------------------------------------------------------------------------
  def player_in_screen?
    event_in_screen?(0)
  end

  #==============================================================================
  # ** Pictures
  #------------------------------------------------------------------------------
  # Command for the pictures
  #==============================================================================

  #--------------------------------------------------------------------------
  # * Show a picture
  # Origin : 0 | 1 (0 = Corner High Left, 1 = Center)
  # Blend_type : 0 (normal)
  #--------------------------------------------------------------------------
  def picture_show(id, n, x=0, y=0, ori=0,  z_x=100, z_y=100, op=255, bl=0)
    pictures[id].show(n, ori, x, y, z_x, z_y, op, bl)
  end
  #--------------------------------------------------------------------------
  # * Modify Origin
  # Origin : 0 | 1 (0 = Corner High Left, 1 = Center)
  #--------------------------------------------------------------------------
  def picture_origin(id, *origin)
    origin = origin[0] if origin.length == 1
    pictures[id].origin = origin
  end
  #--------------------------------------------------------------------------
  # * Modify x position
  #--------------------------------------------------------------------------
  def picture_x(id, x=false)
    return pictures[id].x unless x
    pictures[id].x = x
  end
  #--------------------------------------------------------------------------
  # * Modify y position
  #--------------------------------------------------------------------------
  def picture_y(id, y=false)
    return pictures[id].y unless y
    pictures[id].y = y
  end
  #--------------------------------------------------------------------------
  # * Modify position
  #--------------------------------------------------------------------------
  def picture_position(id, x, y)
    picture_x(id, x)
    picture_y(id, y)
  end
  #--------------------------------------------------------------------------
  # * Move picture
  #--------------------------------------------------------------------------
  def picture_move(id, x, y, zoom_x, zoom_y, duration, opacity=-1, blend_type=-1, origin=-1)
    picture = pictures[id]
    opacity = (opacity == -1) ? picture.opacity : opacity
    blend_type = (blend_type == -1) ? picture.blend_type : blend_type
    origin = (origin == -1) ? picture.origin : origin
    picture.move(origin, x, y, zoom_x, zoom_y, opacity, blend_type, duration)
  end
  #--------------------------------------------------------------------------
  # * Modify wave
  #--------------------------------------------------------------------------
  def picture_wave(id, amp, speed)
    pictures[id].wave_amp = amp
    pictures[id].wave_speed = speed
  end
  #--------------------------------------------------------------------------
  # * Apply Mirror
  #--------------------------------------------------------------------------
  def picture_flip(id)
    pictures[id].mirror = !pictures[id].mirror
  end
  #--------------------------------------------------------------------------
  # * Modify Angle
  #--------------------------------------------------------------------------
  def picture_angle(id, angle=false)
    return pictures[id].angle unless angle
    pictures[id].angle = angle%360
  end
  #--------------------------------------------------------------------------
  # * Rotate
  #--------------------------------------------------------------------------
  def picture_rotate(id, speed)
    pictures[id].rotate(speed)
  end
  #--------------------------------------------------------------------------
  # * change Zoom X
  #--------------------------------------------------------------------------
  def picture_zoom_x(id, zoom_x=false)
    return pictures[id].zoom_x unless zoom_x
    pictures[id].zoom_x = zoom_x
  end
  #--------------------------------------------------------------------------
  # * change Zoom Y
  #--------------------------------------------------------------------------
  def picture_zoom_y(id, zoom_y=false)
    return pictures[id].zoom_y unless zoom_y
    pictures[id].zoom_y = zoom_y
  end
  #--------------------------------------------------------------------------
  # * change Zoom
  #--------------------------------------------------------------------------
  def picture_zoom(id, zoom_x, zoom_y = -1)
    zoom_y = zoom_x if zoom_y == -1
    picture_zoom_x(id, zoom_x)
    picture_zoom_y(id, zoom_y)
  end
  #--------------------------------------------------------------------------
  # * change Tone
  #--------------------------------------------------------------------------
  def picture_tone(id, *args)
    case args.length
    when 1; tone = args[0]
    else
      r, g, b = args[0], args[1], args[2]
      gray = args[3] || 0
      tone = Tone.new(r, g, b, gray)
    end
    pictures[id].tone = tone
  end
  #--------------------------------------------------------------------------
  # * Change blend type
  #--------------------------------------------------------------------------
  def picture_blend(id, blend)
    blend_type = 0
    blend_type = blend if [0,1,2].include?(blend)
    pictures[id].blend_type = blend_type
  end
  #--------------------------------------------------------------------------
  # * Pin picture on the map
  #--------------------------------------------------------------------------
  def picture_pin(id)
    pictures[id].pin = true
  end
  #--------------------------------------------------------------------------
  # * Pin picture on the map
  #--------------------------------------------------------------------------
  def picture_detach(id)
    pictures[id].pin = false
  end
  #--------------------------------------------------------------------------
  # * Change Picture Opacity
  #--------------------------------------------------------------------------
  def picture_opacity(id, value)
    pictures[id].opacity = value
  end
  #--------------------------------------------------------------------------
  # * Shake the picture
  #--------------------------------------------------------------------------
  def picture_shake(id, power, speed, duration)
    pictures[id].start_shake(power, speed, duration)
  end
  #--------------------------------------------------------------------------
  # * Display Enemy from a troop
  #--------------------------------------------------------------------------
  def picture_show_enemy(id_pic, id_troop, position, x=nil, y=nil)
    x ||= troop_member_x(id_troop, position)
    y ||= troop_member_y(id_troop, position)
    enemy = enemy(troop_member_id(id_troop, position))
    picture = enemy.battler_name
    picture_name = "Battlers/"+picture
    bmp = Cache.battler(picture, enemy.battler_hue)
    w, h = bmp.width/2, bmp.height
    picture_show(id_pic, picture_name, x, y, [w, h])
  end
  #--------------------------------------------------------------------------
  # * Display text
  #--------------------------------------------------------------------------
  def picture_text(id, text, x, y, s=Font.default_size, fn=Font.default_name, 
    c=nil, b=false, i=false, o=false, oc=nil, sh=false)
    picture_show(id, text.to_s, x, y)
    pictures[id].text_size = s
    pictures[id].text_font = fn
    pictures[id].text_color = c
    pictures[id].text_outline = o
    pictures[id].text_out_color = oc
    pictures[id].text_bold = b
    pictures[id].text_italic = i
    pictures[id].text_shadow = sh
  end
  #--------------------------------------------------------------------------
  # * Display Screen as picture
  #--------------------------------------------------------------------------
  def picture_screen(id, x=0, y=0, ori=0,  z_x=100, z_y=100, op=255, bl=0)
    picture_show(id, :screenshot, ori, x, y, z_x, z_y, op, bl)
  end
  #--------------------------------------------------------------------------
  # * Erase a picture
  #--------------------------------------------------------------------------
  def picture_erase(id)
    pictures[id].erase
  end

  #==============================================================================
  # ** Parallaxes
  #------------------------------------------------------------------------------
  # Command for the parallaxes
  #==============================================================================

  #--------------------------------------------------------------------------
  # * Show parallax
  #--------------------------------------------------------------------------
  def parallax_show(id, n, z=-100, op=255, a_x=0, a_y=0, m_x=1, m_y=1, 
    b = 0, z_x = 100.0, z_y = 100.0)
    $game_map.parallaxes[id-1].show(n, z, op, a_x, a_y, m_x, m_y, b, z_x, z_y)
  end
  #--------------------------------------------------------------------------
  # * Hide parallax
  #--------------------------------------------------------------------------
  def parallax_erase(id); $game_map.parallaxes[id-1].hide ; end

  #--------------------------------------------------------------------------
  # * change Z parallax
  #--------------------------------------------------------------------------
  def parallax_z(id, z); $game_map.parallaxes[id-1].z = z; end

  #--------------------------------------------------------------------------
  # * change parallax opacity
  #--------------------------------------------------------------------------
  def parallax_opacity(id, op); $game_map.parallaxes[id-1].opacity = op%256; end

  #--------------------------------------------------------------------------
  # * change parallax auto_speed
  #--------------------------------------------------------------------------
  def parallax_autoscroll(id, ax, ay)
    $game_map.parallaxes[id].autospeed_x = ax
    $game_map.parallaxes[id].autospeed_y = ay
  end

  #--------------------------------------------------------------------------
  # * change parallax scroll speed
  #--------------------------------------------------------------------------
  def parallax_scrollspeed(id, x, y)
    $game_map.parallaxes[id-1].move_x = x
    $game_map.parallaxes[id-1].move_y = y
  end

  #--------------------------------------------------------------------------
  # * change parallax zoom_x
  #--------------------------------------------------------------------------
  def parallax_zoom_x(id, zoom)
    $game_map.parallaxes[id-1].zoom_x = zoom.to_f
  end

  #--------------------------------------------------------------------------
  # * change parallax zoom_y
  #--------------------------------------------------------------------------
  def parallax_zoom_y(id, zoom)
    $game_map.parallaxes[id-1].zoom_y = zoom.to_f
  end

  #--------------------------------------------------------------------------
  # * change Zoom
  #--------------------------------------------------------------------------
  def parallax_zoom(id, zoom_x, zoom_y = -1)
    zoom_y = zoom_x if zoom_y == -1
    parallax_zoom_x(id, zoom_x)
    parallax_zoom_y(id, zoom_y)
  end

  #--------------------------------------------------------------------------
  # * change parallax blend mode
  #--------------------------------------------------------------------------
  def parallax_blend(id, blend)
    blend_type = 0
    blend_type = blend if [0,1,2].include?(blend)
    $game_map.parallaxes[id-1].blend_type = blend
  end
  
  #--------------------------------------------------------------------------
  # * change parallax Tone
  #--------------------------------------------------------------------------
  def parallax_tone(id, r, g, b, gr=0)
    $game_map.parallaxes[id-1].tone = Tone.new(r, g, b, gr)
  end


  #==============================================================================
  # ** Time
  #------------------------------------------------------------------------------
  # Command to get information about time
  #==============================================================================

  #--------------------------------------------------------------------------
  # * Get the current year
  #--------------------------------------------------------------------------
  def time_year; Time.now.year ;end
  #--------------------------------------------------------------------------
  # * Get the current month
  #--------------------------------------------------------------------------
  def time_month; Time.now.month; end
  #--------------------------------------------------------------------------
  # * Get the current day
  #--------------------------------------------------------------------------
  def time_day; Time.now.day; end
  #--------------------------------------------------------------------------
  # * Get the current hour
  #--------------------------------------------------------------------------
  def time_hour; Time.now.hour; end
  #--------------------------------------------------------------------------
  # * Get the current min
  #--------------------------------------------------------------------------
  def time_min; Time.now.min; end
  #--------------------------------------------------------------------------
  # * Get the current sec
  #--------------------------------------------------------------------------
  def time_sec; Time.now.sec; end
  
  #==============================================================================
  # ** Save manager
  #------------------------------------------------------------------------------
  # Command to save/load party
  #==============================================================================
  
  #--------------------------------------------------------------------------
  # * Save game
  #--------------------------------------------------------------------------
  def save_game(index); DataManager.save_game(index-1); end
  #--------------------------------------------------------------------------
  # * Load game
  #--------------------------------------------------------------------------
  def load_game(index, time = 100) 
    DataManager.load_game(index-1) 
    RPG::BGM.fade(time)
    RPG::BGS.fade(time)
    RPG::ME.fade(time)
    Graphics.fadeout(time * Graphics.frame_rate / 1000)
    RPG::BGM.stop
    RPG::BGS.stop
    RPG::ME.stop
    $game_system.on_after_load
    SceneManager.goto(Scene_Map)
  end
  #--------------------------------------------------------------------------
  # * Check if save exists
  #--------------------------------------------------------------------------
  def save_exists?(index); DataManager.save_file_exists?; end
  #--------------------------------------------------------------------------
  # * Erase save
  #--------------------------------------------------------------------------
  def delete_save(index); DataManager.delete_save_file(index-1); end
  #--------------------------------------------------------------------------
  # * Import variables
  #--------------------------------------------------------------------------
  def import_variable(id_save, id_variable)
    DataManager.export(id_save)[:variables][id_variable]
  end
  #--------------------------------------------------------------------------
  # * Import switch
  #--------------------------------------------------------------------------
  def import_switch(id_save, id_switch)
    DataManager.export(id_save)[:switches][id_switch]
  end
  #==============================================================================
  # ** Area
  #------------------------------------------------------------------------------
  # Command to create areas
  #==============================================================================

  #--------------------------------------------------------------------------
  # * Create Rect Area
  #--------------------------------------------------------------------------
  def create_rect_area(x1, y1, x2, y2); Area::Rect.new(x1, y1, x2, y2); end
  #--------------------------------------------------------------------------
  # * Create Circle Area
  #--------------------------------------------------------------------------
  def create_circle_area(x, y, r); Area::Circle.new(x, y, r); end
  #--------------------------------------------------------------------------
  # * Create Ellipse Area
  #--------------------------------------------------------------------------
  def create_ellipse_area(x, y, width, height)
    Area::Ellipse.new(x, y, width, height)
  end
  #--------------------------------------------------------------------------
  # * Create Polygon Area
  #--------------------------------------------------------------------------
  def create_polygon_area(points); Area::Polygon.new(points); end
  #--------------------------------------------------------------------------
  # * Check if point 's include in area
  #--------------------------------------------------------------------------
  def in_area?(area, x, y); area.in?(x, y); end
  #--------------------------------------------------------------------------
  # * Check mouse 's hover an area
  #--------------------------------------------------------------------------
  def mouse_hover_area?(area); area.hover?; end
  #--------------------------------------------------------------------------
  # * Check mouse 's hover an area (in square)
  #--------------------------------------------------------------------------
  def mouse_square_hover_area?(area); area.hover_square?; end
  #--------------------------------------------------------------------------
  # * Check click an area
  #--------------------------------------------------------------------------
  def mouse_clicked_area?(area, key); area.clicked?(key); end 
  #--------------------------------------------------------------------------
  # * Check trigger an area
  #--------------------------------------------------------------------------
  def mouse_triggered_area?(area, key); area.triggered?(key); end 
  #--------------------------------------------------------------------------
  # * Check release an area
  #--------------------------------------------------------------------------
  def mouse_released_area?(area, key); area.released?(key); end 
  #--------------------------------------------------------------------------
  # * Check repeat an area
  #--------------------------------------------------------------------------
  def mouse_repeated_area?(area, key); area.repeated?(key); end 
  #--------------------------------------------------------------------------
  # * Check click an area (square)
  #--------------------------------------------------------------------------
  def mouse_square_clicked_area?(area, key); area.clicked_square?(key); end 
  #--------------------------------------------------------------------------
  # * Check trigger an area (square)
  #--------------------------------------------------------------------------
  def mouse_square_triggered_area?(area, key); area.triggered_square?(key); end 
  #--------------------------------------------------------------------------
  # * Check repeat an area (square)
  #--------------------------------------------------------------------------
  def mouse_square_repeated_area?(area, key); area.repeated_square?(key); end 
  #--------------------------------------------------------------------------
  # * Check release an area (square)
  #--------------------------------------------------------------------------
  def mouse_square_released_area?(area, key); area.released_square?(key); end 
    
  #==============================================================================
  # ** User form
  #------------------------------------------------------------------------------
  # Command to manipulate form
  #==============================================================================

  #--------------------------------------------------------------------------
  # * Create a Textfield
  #--------------------------------------------------------------------------
  def create_textfield(type, x, y, w, t="", a=:left, range=-1, h=38)
    align = 0
    align = 1 if a == :center
    align = 2 if a == :right
    case type
    when :integer
      textfield = UI::Form::Window_Intfield.new(x, y, w, t, h, align, range)
    when :float
      textfield = UI::Form::Window_Floatfield.new(x, y, w, t, h, align, range)
    else
      textfield = UI::Form::Window_Textfield.new(x, y, w, t, h, align, range)
    end
    scene.add_textbox(textfield)
    return textfield
  end
  #--------------------------------------------------------------------------
  # * Erase a Textfield
  #--------------------------------------------------------------------------
  def erase_textfield(textfield); scene.erase_textbox(textfield); end
  #--------------------------------------------------------------------------
  # * Get the value of a textfield
  #--------------------------------------------------------------------------
  def get_textfield_value(textfield); textfield.value; end
  #--------------------------------------------------------------------------
  # * Set the value of a textfield
  #--------------------------------------------------------------------------
  def set_textfield_value(textfield, value); textfield.value=value; end
  #--------------------------------------------------------------------------
  # * Activate textfield
  #--------------------------------------------------------------------------
  def activate_textfield(textfield)
    scene.unactive_all_textbox
    textfield.active = true
  end
  #--------------------------------------------------------------------------
  # * Unactivate textfield
  #--------------------------------------------------------------------------
  def unactivate_textfield(textfield); textfield.active = false; end
  #--------------------------------------------------------------------------
  # * Check textfield's activity
  #--------------------------------------------------------------------------
  def textfield_actived?(textfield)
    textfield.active
  end
  #--------------------------------------------------------------------------
  # * Unactivate all textfield
  #--------------------------------------------------------------------------
  def unactivate_all_textfield
    scene.unactive_all_textbox
  end
  #--------------------------------------------------------------------------
  # * Mouse hover a textbox
  #--------------------------------------------------------------------------
  def textfield_hover?(textfield)
    textfield.hover?
  end
  #--------------------------------------------------------------------------
  # * Mouse clicked a textbox
  #--------------------------------------------------------------------------
  def textfield_clicked?(textfield, key)
    textfield.hover? && UI::Mouse.trigger?(key)
  end
  #--------------------------------------------------------------------------
  # * Set visibility of a textfield
  #--------------------------------------------------------------------------
  def textfield_visibility(textfield, flag)
    textfield.visibility = flag.to_bool
  end
  #--------------------------------------------------------------------------
  # * Change opacity
  #--------------------------------------------------------------------------
  def textfield_opacity(textfield, opacity)
    textfield.opacity = opacity%256
  end
  #--------------------------------------------------------------------------
  # * Change tone
  #--------------------------------------------------------------------------
  def textfield_tone(textfield, r,v,b,g=0)
    textfield.tone.set(r,v,b,g)
  end
  
  #==============================================================================
  # ** Socket
  #------------------------------------------------------------------------------
  # Socket commands
  #==============================================================================
  
  #--------------------------------------------------------------------------
  # * Connect to a server
  #--------------------------------------------------------------------------
  def server_connect(host, port); Socket.connect(host, port); end
  #--------------------------------------------------------------------------
  # * Send message to server
  #--------------------------------------------------------------------------
  def server_send(socket, message); Socket.send(socket, message); end
  #--------------------------------------------------------------------------
  # * Recv message from the server
  #--------------------------------------------------------------------------
  def server_recv(socket, len = 256); Socket.recv(socket, len); end
  #--------------------------------------------------------------------------
  # * Wait a message from the server
  #--------------------------------------------------------------------------
  def server_wait_recv(socket, len = 256)
    flag = false
    flag = Socket.recv(socket, len) while !flag
    flag
  end
  #--------------------------------------------------------------------------
  # * Close the connection with the server
  #--------------------------------------------------------------------------
  def server_close_connection(socket); Socket.close(socket); end
  #--------------------------------------------------------------------------
  # * Single instance connection
  #--------------------------------------------------------------------------
  def server_single_connect(host, port); Socket.single_connect(host, port); end
  #--------------------------------------------------------------------------
  # * Send message to single server connection
  #--------------------------------------------------------------------------
  def server_single_send(message); Socket.single_send(message); end
  #--------------------------------------------------------------------------
  # * Recv message from the single server connection
  #--------------------------------------------------------------------------
  def server_single_recv(len = 256); Socket.single_recv(len); end
  #--------------------------------------------------------------------------
  # * Wait a message from the single server connection
  #--------------------------------------------------------------------------
  def server_single_wait_recv(len = 256)
    server_wait_recv(Socket.single_socket(), len)
  end
  #--------------------------------------------------------------------------
  # * Close the connection with the single server connection
  #--------------------------------------------------------------------------
  def server_single_close_connection
    Socket.single_close
  end
  
  #==============================================================================
  # ** Misc
  #------------------------------------------------------------------------------
  # Misc commands
  #==============================================================================
  
  #--------------------------------------------------------------------------
  # * Include event page
  #--------------------------------------------------------------------------
  def include_page(map_id, event_id, page_id)
    return unless self.class == Game_Interpreter
    self.append_interpreter(map_id, event_id, page_id)
  end
  #--------------------------------------------------------------------------
  # * Invoke Event
  #--------------------------------------------------------------------------
  def invoke_event(map_id, event_id, new_id, x=nil, y=nil)
    $game_map.add_event(map_id, event_id, new_id, x, y)
  end
  #--------------------------------------------------------------------------
  # * Return the username of Windows Session
  #--------------------------------------------------------------------------
  def windows_username; ENV['USERNAME'].dup.to_utf8; end
  #--------------------------------------------------------------------------
  # * Find angle from a couple of point
  #--------------------------------------------------------------------------
  def angle_xy(r_x, r_y, s_x, s_y)
    x = s_x - r_x
    y = s_y - r_y 
    ((Math.atan2(x, y))*(180.0/Math::PI))-180
  end
  #--------------------------------------------------------------------------
  # * Return the RTP's path
  #--------------------------------------------------------------------------
  def rtp_path
    RTP.path
  end
  #--------------------------------------------------------------------------
  # * Change Message height
  #--------------------------------------------------------------------------
  def message_height(n)
    Window_Message.line_number = n
    scene = SceneManager.scene
    scene.refresh_message if scene.respond_to?(:refresh_message)
  end
  
  #--------------------------------------------------------------------------
  # * Method suggestions
  #--------------------------------------------------------------------------
  def method_missing(*args)
    keywords = self.methods + self.singleton_methods 
    keywords += self.instance_variables + self.class.instance_methods(false)
    keywords.uniq!.collect!{|i|i.to_s}
    keywords.sort_by!{|o| o.damerau_levenshtein(args[0].to_s)}
    msg = "#{args[0]} doesn't exists did you mean maybe #{keywords[0]} or #{keywords[1]}  ?"
    raise(NoMethodError, msg)
  end
  
  #--------------------------------------------------------------------------
  # * Set all alias
  #--------------------------------------------------------------------------
  singleton_methods.each do |method_name|
    aliased_method = "extender_#{method_name}".to_sym
    alias_method(aliased_method, method_name)
  end
end


#==============================================================================
# ** Command_Description
#------------------------------------------------------------------------------
# Description of commands
#==============================================================================

module Command_Description
  KEYS_ACCESS = [:backspace,:clear,:enter,:shift,:ctrl,:alt,
    :pause,:caps_lock,:esc,:space,:page_up,:page_down,:end,
    :home,:left,:up,:right,:down,:select,:print,:execute,
    :help,:zero,:one,:two,:three,:four,:five,:six,:seven,
    :eight,:nine,:a,:b,:c,:d,:e,:f,:g,:h,:i,:j,:k,:l,:m,:n,
    :o,:p,:q,:r,:s,:t,:u,:v,:w,:x,:y,:z,:lwindow,:rwindow,
    :apps,:num_zero,:num_one,:num_two,:num_three,:num_four,
    :num_five,:num_six,:num_seven,:num_eight,:num_nine,:add,
    :substract,:divide,:decimal,:multiply,:separator,:f1,:f2,
    :f3,:f4,:f5,:f6,:f7,:f8,:f9,:f10,:f11,:f12,:num_lock,
    :scroll_lock,:lshift,:rshift,:lcontrol,:rcontrol,:lmenu,
    :rmenu,:circumflex,:dollar,:close_parenthesis,:u_grav,
    :square,:less_than,:colon,:semicolon,:equal,:comma,:minus,
    :delete,:snapshot,:insert]
  #--------------------------------------------------------------------------
  # * Description of standard commands
  #--------------------------------------------------------------------------
  
  def random
    {description:"Renvoi un nombre aléatoire compris entre Minimum et Maximum",
      args:[
         {name:"Minimum", type: :int}, 
         {name:"Maximum", type: :int}
      ],
      returnable: true}
  end
  def region_id
    {description:"Renvoi la région défini sur les coordonnées passées en argument",
      args:[
         {name:"X", type: :int}, 
         {name:"Y", type: :int}
      ],
      returnable: true}
  end

  def terrain_tag
    {description:"Renvoi le ta de terrain défini sur les coordonnées passées en argument",
      args:[
         {name:"X", type: :int}, 
         {name:"Y", type: :int}
      ],
      returnable: true}
  end
  def terrain_tag
    {description:"Renvoi le ta de terrain défini sur les coordonnées passées en argument",
      args:[
         {name:"X", type: :int}, 
         {name:"Y", type: :int}
      ],
      returnable: true}
  end
  def id_at
    {description:"Renvoi l'id de l'évènement à la position donnée. -1 s'il ny en a pas",
      args:[
         {name:"X", type: :int}, 
         {name:"Y", type: :int},
         {name:"Couche", type: :int}
      ],
      returnable: true}
  end
  def map_id
    {description:"Renvoi l'id de la map jouée", returnable: true}
  end
  def max_event_id
    {description:"Renvoi le plus grand ID d'évènement de la carte", returnable: true}
  end
  def percent
    {description:"Renvoi le pourcentage de la valeur1 par rapport à la valeur2",
      args:[{name:"valeur1", type: :int}, {name:"valeur2", type: :int}],
      returnable: true}
  end
  def color
    {description:"Renvoi un objet color selon les valeurs passées",
      args:[{name:"rouge", type: :int}, {name:"vert", type: :int}, 
        {name:"bleu", type: :int}, {name:"alpha", type: :int, default: 255}],
      returnable: true}
  end
  def square_passable?
    {description:"Vérifie si une case est passable",
      args:[{name:"X", type: :int}, {name:"Y", type: :int}, 
        {name:"direction", type: :int, default: 2}],
      returnable: true}
  end
  def team_size
    {description:"Renvoi le nombre de membres de l'équipe", returnable: true}
  end
  def gold
    {description:"Renvoi l'argent possédé par l'équipe", returnable: true}
  end
  def steps
    {description:"Renvoi le nombre de pas effectué par l'équipe", returnable: true}
  end
  def play_time
    {description:"Renvoi la durée de la partie", returnable: true}
  end
  def timer
    {description:"Renvoi la valeur du chronomètre", returnable: true}
  end
  def save_count
    {description:"Renvoi le nombre de sauvegarde effectuées", returnable: true}
  end
  def battle_count
    {description:"Renvoi le nombre de combats effectuées", returnable: true}
  end
  def item_count
    {description:"Renvoi le nombre d'objets possédés en fonction d'un ID", 
      args:[{name:"ID", type: :int}],
      returnable: true}
  end
  def weapon_count
    {description:"Renvoi le nombre d'armes possédées en fonction d'un ID", 
      args:[{name:"ID", type: :int}],
      returnable: true}
  end
  def armor_count
    {description:"Renvoi le nombre d'armures possédées en fonction d'un ID", 
      args:[{name:"ID", type: :int}],
      returnable: true}
  end
  def item_name
    {description:"Renvoi le nom d'un objets en fonction d'un ID", 
      args:[{name:"ID", type: :int}],
      returnable: true}
  end
  def weapon_name
    {description:"Renvoi le nom d'une arme en fonction d'un ID", 
      args:[{name:"ID", type: :int}],
      returnable: true}
  end
  def armor_name
    {description:"Renvoi le nom d'une armure en fonction d'un ID", 
      args:[{name:"ID", type: :int}],
      returnable: true}
  end
  def actor_level
    {description:"Renvoi le niveau d'un acteur en fonction d'un ID", 
      args:[{name:"ID", type: :int}],
      returnable: true}
  end
  def actor_experience
    {description:"Renvoi l'expérience' d'un acteur en fonction d'un ID", 
      args:[{name:"ID", type: :int}],
      returnable: true}
  end
  def actor_hp
    {description:"Renvoi le nombre de PV d'un acteur en fonction d'un ID", 
      args:[{name:"ID", type: :int}],
      returnable: true}
  end
  def actor_mp
    {description:"Renvoi le nombre de MP d'un acteur en fonction d'un ID", 
      args:[{name:"ID", type: :int}],
      returnable: true}
  end
  def actor_max_hp
    {description:"Renvoi le nombre maximum de PV d'un acteur en fonction d'un ID", 
      args:[{name:"ID", type: :int}],
      returnable: true}
  end
  def actor_max_mp
    {description:"Renvoi le nombre maximum de MP d'un acteur en fonction d'un ID", 
      args:[{name:"ID", type: :int}],
      returnable: true}
  end
  def actor_defense
    {description:"Renvoi le nombre de points de défense d'un acteur en fonction d'un ID", 
      args:[{name:"ID", type: :int}],
      returnable: true}
  end
  def actor_magic
    {description:"Renvoi le nombre de points de magie d'un acteur en fonction d'un ID", 
      args:[{name:"ID", type: :int}],
      returnable: true}
  end
  def actor_magic_defense
    {description:"Renvoi le nombre de points de magie maximum d'un acteur en fonction d'un ID", 
      args:[{name:"ID", type: :int}],
      returnable: true}
  end
  def actor_agility
    {description:"Renvoi le nombre de points d'agilité' d'un acteur en fonction d'un ID", 
      args:[{name:"ID", type: :int}],
      returnable: true}
  end
  def actor_luck
    {description:"Renvoi le nombre de points de chance d'un acteur en fonction d'un ID", 
      args:[{name:"ID", type: :int}],
      returnable: true}
  end
  def set_actor_name
    {description:"Modifie le nom de l'acteur référencé par son ID par la valeur de Name", 
      args:[{name:"ID", type: :int}, {name:"Name", type: :string}],
      returnable: false}
  end
  def actor_name
    {description:"Renvoi le nom de l'acteur référencé par son ID", 
      args:[{name:"ID", type: :int}],
      returnable: true}
  end
  def monster_hp
    {description:"Renvoi le nombre de PV d'un ennemi en fonction d'un ID", 
      args:[{name:"ID", type: :int}],
      returnable: true}
  end
  def monster_mp
    {description:"Renvoi le nombre de MP d'un ennemi en fonction d'un ID", 
      args:[{name:"ID", type: :int}],
      returnable: true}
  end
  def monster_attack
    {description:"Renvoi le nombre de points d'attaque d'un ennemi en fonction d'un ID", 
      args:[{name:"ID", type: :int}],
      returnable: true}
  end
  def monster_defense
    {description:"Renvoi le nombre de points de défense d'un ennemi en fonction d'un ID", 
      args:[{name:"ID", type: :int}],
      returnable: true}
  end
  def monster_magic_attack
    {description:"Renvoi le nombre de points d'attaque magique d'un ennemi en fonction d'un ID", 
      args:[{name:"ID", type: :int}],
      returnable: true}
  end
  def monster_magic_defense
    {description:"Renvoi le nombre de points de défense magique d'un ennemi en fonction d'un ID", 
      args:[{name:"ID", type: :int}],
      returnable: true}
  end
  def monster_agility
    {description:"Renvoi le nombre de points d'agilité d'un ennemi en fonction d'un ID", 
      args:[{name:"ID", type: :int}],
      returnable: true}
  end
  def monster_luck
    {description:"Renvoi le nombre de points de chance d'un ennemi en fonction d'un ID", 
      args:[{name:"ID", type: :int}],
      returnable: true}
  end
  def monster_name
    {description:"Renvoi le nom d'un ennemi en fonction d'un ID", 
      args:[{name:"ID", type: :int}],
      returnable: true}
  end
  def troop_size
    {description:"Renvoi le nombre d'ennemis d'un groupe en fonction d'un ID", 
      args:[{name:"ID", type: :int}],
      returnable: true}
  end
  def troop_member_id
    {description:"Renvoi l'ID d'un ennemi en fonction de sa position dans un groupe en fonction d'un ID", 
      args:[{name:"ID", type: :int}, {name:"Position", type: :int}],
      returnable: true}
  end
  def troop_member_x
    {description:"Renvoi la position X (tel que défini dans la BDD) d'un ennemi en fonction de sa position dans un groupe en fonction d'un ID", 
      args:[{name:"ID", type: :int}, {name:"Position", type: :int}],
      returnable: true}
  end
  def troop_member_y
    {description:"Renvoi la position Y (tel que défini dans la BDD) d'un ennemi en fonction de sa position dans un groupe en fonction d'un ID", 
      args:[{name:"ID", type: :int}, {name:"Position", type: :int}],
      returnable: true}
  end
  def mouse_x
    {description:"Renvoi la coordonnées X de la souris (en pixel)", returnable: true}
  end
  def mouse_y
    {description:"Renvoi la coordonnées Y de la souris (en pixel)", returnable: true}
  end
  def mouse_x_square
    {description:"Renvoi la coordonnées X de la souris (en case)", returnable: true}
  end
  def mouse_y_square
    {description:"Renvoi la coordonnées Y de la souris (en case)", returnable: true}
  end
  def mouse_click?
    {description:"Renvoi True si la touche passée en argument est enfoncée, false sinon", 
      args:[{name:"Touche", type: :enum, enum:[:mouse_left, :mouse_center, :mouse_right]}],
      returnable: true}
  end
  def mouse_trigger?
    {description:"Renvoi True si la touche passée en argument vient d'être pressée, false sinon", 
      args:[{name:"Touche", type: :enum, enum:[:mouse_left, :mouse_center, :mouse_right]}],
      returnable: true}
  end
  def mouse_repeat?
    {description:"Renvoi True si la touche passée en argument est enfoncée de manière répetée, false sinon", 
      args:[{name:"Touche", type: :enum, enum:[:mouse_left, :mouse_center, :mouse_right]}],
      returnable: true}
  end
  def mouse_release?
    {description:"Renvoi True si la touche passée en argument vient d'être relachée, false sinon", 
      args:[{name:"Touche", type: :enum, enum:[:mouse_left, :mouse_center, :mouse_right]}],
      returnable: true}
  end
  def mouse_rect
    {description:"Renvoi le rectangle de sélection de la souris", returnable: true}
  end
  def point_in_mouse_rect?
    {description:"Renvoi true si un point (référencé par X et Y) est dans le rectangle de sélection, false sinon", 
      args:[{name:"X", type: :int}, {name:"Y", type: :int}],
      returnable: true}
  end
  def mouse_hover_event?
    {description:"Renvoi true si la souris survol un évènement (référencé par son ID), false sinon", 
      args:[{name:"ID", type: :int}],
      returnable: true}
  end
  def mouse_clicked_event?
    {description:"Renvoi true si la souris clic sur un évènement (référencé par son ID), false sinon", 
      args:[{name:"ID", type: :int}],
      returnable: true}
  end
  def mouse_hover_player?
    {description:"Renvoi true si la souris survol le joueur", 
      returnable: true}
  end
  def mouse_clicked_player?
    {description:"Renvoi true si la souris clic le joueur", 
      returnable: true}
  end
  def last_clicked_event
    {description:"Renvoi l'ID du dernier évènement cliqué", 
      returnable: true}
  end
  def show_cursor_system
    {description:"Active (true) ou désactive (false) le curseur de Windows", 
      args:[{name:"Activation?", type: :bool}]}
  end
  def key_press?
    {description:"Renvoi True si la touche passée en argument est enfoncée, false sinon", 
      args:[{name:"Touche", type: :enum, enum:KEYS_ACCESS}],
      returnable: true}
  end
  def key_trigger?
    {description:"Renvoi True si la touche passée en argument vient d'être pressée, false sinon", 
      args:[{name:"Touche", type: :enum, enum:KEYS_ACCESS}],
      returnable: true}
  end
  def key_repeat?
    {description:"Renvoi True si la touche passée en argument est enfoncée de manière répetée, false sinon", 
      args:[{name:"Touche", type: :enum, enum:KEYS_ACCESS}],
      returnable: true}
  end
  def key_release?
    {description:"Renvoi True si la touche passée en argument vient d'être relachée, false sinon", 
      args:[{name:"Touche", type: :enum, enum:KEYS_ACCESS}],
      returnable: true}
  end
  def caps_lock?
    {description:"Renvoi true si le clavier est en CAPS LOCK, false sinon", 
      returnable: true}
  end
  def num_lock?
    {description:"Renvoi true si le clavier est en NUM LOCK, false sinon", 
      returnable: true}
  end
  def scroll_lock?
    {description:"Renvoi true si le clavier est en SCROLL LOCK, false sinon", 
      returnable: true}
  end
  def maj?
    {description:"Renvoi true si le clavier est en mode majuscule, false sinon", 
      returnable: true}
  end
  def alt_gr?
    {description:"Renvoi true si la combinaison ALT+GR est enfoncée, false sinon", 
      returnable: true}
  end
  def key_number
    {description:"Renvoi le numéro pressé au clavier, nil si aucun chiffre n'est pressé", 
      returnable: true}
  end
  def key_char?
    {description:"Renvoi le caractère pressé au clavier, ne renvoi aucun caractère sinon", 
      returnable: true}
  end
  def event_x
    {description:"Renvoi la position X (en case) d'un évènement en fonction de son ID", 
      args:[{name:"ID", type: :int}],
      returnable: true}
  end
  def event_y
    {description:"Renvoi la position Y (en case) d'un évènement en fonction de son ID", 
      args:[{name:"ID", type: :int}],
      returnable: true}
  end
  def event_screen_x
    {description:"Renvoi la position X (en pixel par rapport à l'écran) d'un évènement en fonction de son ID", 
      args:[{name:"ID", type: :int}],
      returnable: true}
  end
  def event_pixel_x
    {description:"Renvoi la position X (en pixel) d'un évènement en fonction de son ID", 
      args:[{name:"ID", type: :int}],
      returnable: true}
  end
  def event_pixel_y
    {description:"Renvoi la position Y (en pixel) d'un évènement en fonction de son ID", 
      args:[{name:"ID", type: :int}],
      returnable: true}
  end
  def event_screen_y
    {description:"Renvoi la position Y (en pixel par rapport à l'écran) d'un évènement en fonction de son ID", 
      args:[{name:"ID", type: :int}],
      returnable: true}
  end
  def event_direction
    {description:"Renvoi la direction (2,4,6,8) d'un évènement en fonction de son ID", 
      args:[{name:"ID", type: :int}],
      returnable: true}
  end
  def player_x
    {description:"Renvoi la position X (en case) du joueur", 
      returnable: true}
  end
  def player_y
    {description:"Renvoi la position Y (en case) du joueur", 
      returnable: true}
  end
  def player_pixel_x
    {description:"Renvoi la position X en pixel du joueur", 
      returnable: true}
  end
  def player_pixel_y
    {description:"Renvoi la position Y en pixel du joueur", 
      returnable: true}
  end
  def player_screen_x
    {description:"Renvoi la position X (en pixel par rapport à l'écran) du joueur", 
      returnable: true}
  end
  def player_screen_y
    {description:"Renvoi la position Y (en pixel par rapport à l'écran) du joueur", 
      returnable: true}
  end
  def player_direction
    {description:"Renvoi la direction (2,4,6,8) du joueur", 
      returnable: true}
  end
  def look_at
    {description:"Renvoi true si ID 1 regarde ID 2, false sinon", 
      args:[{name:"ID 1", type: :int},
        {name:"ID 2", type: :int},
        {name:"portee", type: :int},
        {name:"Unites", type: :enum, enum:[:square, :pixel]}],
      returnable: true}
  end
  def squares_between
    {description:"Renvoi le nombre de cases entre deux évènements (référencés via leurs ID, 0 pour le héros)", 
      args:[{name:"ID 1", type: :int},{name:"ID 2", type: :int}],
      returnable: true}
  end
  def pixels_between
    {description:"Renvoi le nombre de pixels entre deux évènements (référencés via leurs ID, 0 pour le héros)", 
      args:[{name:"ID 1", type: :int},{name:"ID 2", type: :int}],
      returnable: true}
  end
  def move_to
    {description:"Déplace l'évènement (référencé par son ID, 0 pour le héros) vers la case référencée par X et Y", 
      args:[{name:"ID", type: :int},{name:"X", type: :int}, {name:"y", type: :int}, {name:"Attendre?", type: :bool}]}
  end
  def jump_to
    {description:"fait sauter l'évènement (référencé par son ID, 0 pour le héros) vers la case référencée par X et Y", 
      args:[{name:"ID", type: :int},{name:"X", type: :int}, {name:"y", type: :int}, {name:"Attendre?", type: :bool}]}
  end
  def buzz
    {description:"fait tressaillir l'évènement (référencé par son ID, 0 pour le héros) ", 
      args:[{name:"ID", type: :int}]}
  end
  def collide?
    {description:"Renvoi true si  deux évènements (référencés par leurs ID's, 0 pour le héros) sont en collision, false sinon", 
      args:[{name:"ID 1", type: :int}, {name:"ID 2", type: :int}],
      returnable: true}
  end
  def event_in_screen?
    {description:"Renvoi true si l'évènement (référencé par son ID) est dans l'écran", 
      args:[{name:"ID", type: :int}],
      returnable: true}
  end
  def player_in_screen?
    {description:"Renvoi true si le joueur est dans l'écran", 
      returnable: true}
  end
  def picture_show
    {description:"Affiche l'image", 
      args:[
        {name:"ID", type: :int}, 
        {name:"Nom de l'image", type: :string},
        {name:"X", type: :int, default: 0},
        {name:"Y", type: :int, default: 0},
        {name:"Origine (0 = H-G, 1 = centre)", type: :int, default: 0},
        {name:"zoom X", type: :int, default: 100},
        {name:"zoom Y", type: :int, default: 100},
        {name:"Opacité", type: :int, default: 255},
        {name:"Mode de fusion (0 normal, 1 addition, 2 soustraction)", type: :int, default: 0}
        ]}
  end
  def picture_origine
    {description:"Modifie l'origine d'une image (référencée par son ID)", 
      args:[{name:"ID", type: :int}, {name:"Origine", type: :int}]}
  end
  def picture_x
    {description:"Modifie la position X d'une image (référencée par son ID)", 
      args:[{name:"ID", type: :int}, {name:"X", type: :int}]}
  end
  def picture_y
    {description:"Modifie la position Y d'une image (référencée par son ID)", 
      args:[{name:"ID", type: :int}, {name:"Y", type: :int}]}
  end
  def picture_position
    {description:"Modifie la position d'une image (référencée par son ID)", 
      args:[{name:"ID", type: :int}, {name:"X", type: :int}, {name:"Y", type: :int}]}
  end
  def picture_move
    {description:"Déplace l'image (référencée par son ID), les valeurs -1 gardent leurs valeurs initiales", 
      args:[
        {name:"ID", type: :int}, 
        {name:"X", type: :int, default: 0},
        {name:"Y", type: :int, default: 0},
        {name:"zoom X", type: :int, default: 100},
        {name:"zoom Y", type: :int, default: 100},
        {name:"Durée", type: :int, default: 60},
        {name:"Opacité", type: :int, default: -1},
        {name:"Mode de fusion (0 normal, 1 addition, 2 soustraction)", type: :int, default: -1},
        {name:"Origine (0 = H-G, 1 = centre)", type: :int, default: -1}
        ]}
  end
  def picture_wave
    {description:"Fait onduler une image (Référencée par son ID) en fonction d'une amplitude et d'une vitesse", 
      args:[{name:"ID", type: :int}, {name:"Amplitude", type: :int}, {name:"Vitesse", type: :int}]}
  end
  def picture_flip
    {description:"Applique une symétrie orthogonale (Axe vertical) à une image (référencée par son ID)", 
      args:[{name:"ID", type: :int}]}
  end
  def picture_angle
    {description:"Modifie l'angle d'inclinaison d'une image (référencée par son ID)", 
      args:[{name:"ID", type: :int}, {name:"Angle", type: :int}]}
  end
  def picture_rotate
    {description:"Fait tourner une image (référencée par son ID) à une certaine vitesse", 
      args:[{name:"ID", type: :int}, {name:"Vitesse", type: :int}]}
  end
  def picture_zoom_x
    {description:"Modifie le zoom X d'une image (référencée par son ID)", 
      args:[{name:"ID", type: :int}, {name:"Zoom X", type: :int, default: 100}]}
  end
  def picture_zoom_y
    {description:"Modifie le zoom Y d'une image (référencée par son ID)", 
      args:[{name:"ID", type: :int}, {name:"Zoom Y", type: :int, default: 100}]}
  end
  def picture_zoom
    {description:"Modifie le zoom d'une image (référencée par son ID), si Zoom Y vaut -1 il prendra la même taille que Zoom X", 
      args:[{name:"ID", type: :int}, {name:"Zoom X", type: :int, default: 100}, {name:"Zoom Y", type: :int, default: -1}]}
  end
  def picture_tone
    {description:"Modifie la teinte d'une image (référencée par son ID)", 
      args:[
        {name:"ID", type: :int}, 
        {name:"Rouge", type: :int, default: 0},
        {name:"Vert", type: :int, default: 0},
        {name:"Bleu", type: :int, default: 0}, 
        {name:"Gris", type: :int, default: 0}
        ]}
  end
  def picture_blend
    {description:"Modifie le mode de fusion d'une image (référencée par son ID) (0 => normal, 1 addition, 2 soustraction)", 
      args:[{name:"ID", type: :int}, {name:"Mode de fusion", type: :int, default: 0}]}
  end
  def picture_pin
    {description:"Fixe le défilement d'une image (référencée par son ID) sur la carte", 
      args:[{name:"ID", type: :int}]}
  end
  def picture_detach
    {description:"Annule le fixe du défilement d'une image (référencée par son ID) sur la carte", 
      args:[{name:"ID", type: :int}]}
  end
  def picture_shake
    {description:"Fait trembler une image (référencée par son ID)", 
      args:[{name:"ID", type: :int}, {name:"Force", type: :int}, {name:"Vitesse", type: :int}, {name:"Durée", type: :int}]}
  end
  def picture_show_enemy
    {description:"Affiche un ennemi en image en fonction de ses positions de la base de données", 
      args:[
        {name:"ID Image", type: :int},
        {name:"ID du groupe", type: :int},
        {name:"Position du monstre", type: :int}
        ]}
  end
  def picture_text
    {description:"Affiche un text sur un emplacement image (en fonction de son ID)", 
      args:[
        {name:"ID Image", type: :int},
        {name:"Texte", type: :string},
        {name:"X", type: :int},
        {name:"y", type: :int},
        {name:"Taille", type: :int, default: Font.default_size},
        {name:"Police", type: :string, default: Font.default_name},
        {name:"Color (Utilisez le formatage Libre et la commande 'color')", type: :none},
        {name:"Gras ?", type: :bool},
        {name:"Italique ?", type: :bool},
        {name:"Contour ?", type: :bool},
        {name:"Color contour (Utilisez le formatage Libre et la commande 'color')", type: :none},
        {name:"Ombre ?", type: :bool}
        ]}
  end
  def picture_screen
    {description:"Prend une capture d'écran sur une image (référencée par son ID)", 
      args:[{name:"ID", type: :int}]}
  end
  def picture_erase
    {description:"Supprime une image (référencée par son ID)", 
      args:[{name:"ID", type: :int}]}
  end
  def picture_opacity
    {description:"Modifie l'opacité d'une image (référencée par son ID)", 
      args:[{name:"ID", type: :int}, {name:"Valeur", type: :int}]}
  end
  def parallax_show
    {description:"Crée un panorama", 
      args:[
        {name:"ID", type: :int},
        {name:"Nom de l'image", type: :string},
        {name:"Axe Z", type: :int, default: -100},
        {name:"Opacité", type: :int, default: 255},
        {name:"Vitesse automatique X", type: :int},
        {name:"Vitesse automatique Y", type: :int},
        {name:"Défilement X", type: :int},
        {name:"Défilement Y", type: :int}
        ]}
  end
  def parallax_erase
    {description:"Supprime un panorama (référencée par son ID)", 
      args:[{name:"ID", type: :int}]}
  end
  def parallax_z
    {description:"change l'axe Z d'un panorama (référencée par son ID)", 
      args:[{name:"ID", type: :int}, {name:"Axe Z", type: :int}]}
  end
  def parallax_opacity
    {description:"change l'opacité d'un panorama (référencée par son ID)", 
      args:[{name:"ID", type: :int}, {name:"Opacité", type: :int, default: 255}]}
  end
  def parallax_autoscroll
    {description:"change la vitesse de défilement automatique d'un panorama (référencée par son ID)", 
      args:[{name:"ID", type: :int}, {name:"Vitesse X", type: :int}, {name:"Vitesse Y", type: :int}]}
  end
  def parallax_scrollspeed
    {description:"change la vitesse de défilement d'un panorama (référencée par son ID)", 
      args:[{name:"ID", type: :int}, {name:"Vitesse X", type: :int}, {name:"Vitesse Y", type: :int}]}
  end
  def parallax_zoom_x
    {description:"change le zoom X d'un panorama (référencée par son ID)", 
      args:[{name:"ID", type: :int}, {name:"Zoom X", type: :int}]}
  end
  def parallax_zoom_y
    {description:"change le zoom Y d'un panorama (référencée par son ID)", 
      args:[{name:"ID", type: :int}, {name:"Zoom Y", type: :int}]}
  end
  def parallax_zoom
    {description:"change le zoom d'un panorama (référencée par son ID), si le Zoom Y vaut -1 il prendra la valeur du Zoom X", 
      args:[{name:"ID", type: :int}, {name:"Zoom X", type: :int, default: 100}, {name:"Zoom Y", type: :int, default: -1}]}
  end
  def parallax_blend
    {description:"change le mode de fusion d'un panorama (référencée par son ID)", 
      args:[{name:"ID", type: :int}, {name:"Mode (0: normal, 1:add, 2:sub)", type: :int, default: 0}]}
  end
  def parallax_tone
    {description:"Modifie la teinte d'un panorama (référencé par son ID)", 
      args:[
        {name:"ID", type: :int}, 
        {name:"Rouge", type: :int, default: 0},
        {name:"Vert", type: :int, default: 0},
        {name:"Bleu", type: :int, default: 0}, 
        {name:"Gris", type: :int, default: 0}
        ]}
  end
  def time_year
    {description:"Renvoi l'année actuelle", 
      returnable: true}
  end
  def time_month
    {description:"Renvoi le mois actuel (1-12)", 
      returnable: true}
  end
  def time_day
    {description:"Renvoi le jours du mois actuel (1-31)", 
      returnable: true}
  end
  def time_hour
    {description:"Renvoi l'heure courante (1->24/0)", 
      returnable: true}
  end
  def time_min
    {description:"Renvoi la minute courante (0->60)", 
      returnable: true}
  end
  def time_sec
    {description:"Renvoi la seconde courante (0->60)", 
      returnable: true}
  end
  def save_game
    {description:"Sauvegarde le jeu sur l'emplacement ID", 
      args:[{name:"Numéro de sauvegarde", type: :int}]}
  end
  def load_game
    {description:"Charge la partie en fonction d'un ID", 
      args:[{name:"Numéro de sauvegarde", type: :int},{name:"Durée de transition", type: :int, default: 100}],
      returnable: true}
  end
  def save_exists?
    {description:"Renvoie true si la sauvegarde numéroté existe, false sinon", 
      args:[{name:"Numéro de sauvegarde", type: :int}]}
  end
  def delete_save
    {description:"Supprime la sauvegarde via son numéro", 
      args:[{name:"Numéro de sauvegarde", type: :int}]}
  end
  def import_variable
    {description:"Importe une variable d'une autre sauvegarde", 
      args:[{name:"Numéro de la sauvegarde", type: :int}, {name:"ID de la variable a importer", type: :int}]}
  end
  def import_variable
    {description:"Importe un interupteur d'une autre sauvegarde", 
      args:[{name:"Numéro de la sauvegarde", type: :int}, {name:"ID de l'interupteur a importer", type: :int}]}
  end
  def create_rect_area
    {description:"Crée une zone rectangulaire en fonction de deux points", 
      args:[
        {name:"Point X1", type: :int}, 
        {name:"Point Y1", type: :int},
        {name:"Point X2", type: :int},
        {name:"Point Y2", type: :int}
        ],
      returnable: true}
  end
  def create_circle_area
    {description:"Crée une zone circulaire en fonction d'un point et d'un rayon", 
      args:[
        {name:"Point X", type: :int}, 
        {name:"Point Y", type: :int},
        {name:"Rayon", type: :int}
        ],
      returnable: true}
  end
  def create_ellipse_area
    {description:"Crée une zone circulaire en fonction d'un point, d'une hauteur et d'une largeur", 
      args:[
        {name:"Point X", type: :int}, 
        {name:"Point Y", type: :int},
        {name:"Largeur", type: :int},
        {name:"Hauteur", type: :int}
        ],
      returnable: true}
  end
  def create_polygon_area
    {description:"Crée une zone polygonale en fonction d'une collection de points", 
      args:[
        {name:"Points (sous cette forme [[x,y],[x,y] etc.)", type: :none}
        ],
      returnable: true}
  end
  def in_area?
    {description:"Renvoi true si le point X/Y est dans la zone, false sinon", 
      args:[
        {name:"Zone", type: :none}, 
        {name:"Point X", type: :int},
        {name:"Point Y", type: :int}
        ],
      returnable: true}
  end
  def mouse_hover_area?
    {description:"Renvoi true si la souris est dans la zone, false sinon", 
      args:[
        {name:"Zone", type: :none}
        ],
      returnable: true}
  end
  def mouse_square_hover_area?
    {description:"Renvoi true si la souris est dans la zone, false sinon (pour une zone définie en case)", 
      args:[
        {name:"Zone", type: :none}
        ],
      returnable: true}
  end
  def mouse_clicked_area?
    {description:"Renvoi true si la souris clic (en continu) la zone, false sinon", 
      args:[
        {name:"Zone", type: :none},
        {name:"Touche", type: :enum, enum:[:mouse_left, :mouse_center, :mouse_right]}
        ],
      returnable: true}
  end
  def mouse_triggered_area?
    {description:"Renvoi true si la souris clic ponctuellement la zone, false sinon", 
      args:[
        {name:"Zone", type: :none},
        {name:"Touche", type: :enum, enum:[:mouse_left, :mouse_center, :mouse_right]}
        ],
      returnable: true}
  end
  def mouse_repeated_area?
    {description:"Renvoi true si la souris clic (de manière répétée) la zone, false sinon", 
      args:[
        {name:"Zone", type: :none},
        {name:"Touche", type: :enum, enum:[:mouse_left, :mouse_center, :mouse_right]}
        ],
      returnable: true}
  end
  def mouse_released_area?
    {description:"Renvoi true si la souris est relâchée sur la zone, false sinon", 
      args:[
        {name:"Zone", type: :none},
        {name:"Touche", type: :enum, enum:[:mouse_left, :mouse_center, :mouse_right]}
        ],
      returnable: true}
  end
  def mouse_square_clicked_area?
    {description:"Renvoi true si la souris clic (en continu) la zone, false sinon (pour une zone définie en case)", 
      args:[
        {name:"Zone", type: :none},
        {name:"Touche", type: :enum, enum:[:mouse_left, :mouse_center, :mouse_right]}
        ],
      returnable: true}
  end
  def mouse_square_triggered_area?
    {description:"Renvoi true si la souris clic (ponctuellement) la zone, false sinon (pour une zone définie en case)", 
      args:[
        {name:"Zone", type: :none},
        {name:"Touche", type: :enum, enum:[:mouse_left, :mouse_center, :mouse_right]}
        ],
      returnable: true}
  end
  def mouse_square_repeated_area?
    {description:"Renvoi true si la souris clic (de manière répétée) la zone, false sinon (pour une zone définie en case)", 
      args:[
        {name:"Zone", type: :none},
        {name:"Touche", type: :enum, enum:[:mouse_left, :mouse_center, :mouse_right]}
        ],
      returnable: true}
  end
  def mouse_square_released_area?
    {description:"Renvoi true si la souris est relâchée sur la zone, false sinon (pour une zone définie en case)", 
      args:[
        {name:"Zone", type: :none},
        {name:"Touche", type: :enum, enum:[:mouse_left, :mouse_center, :mouse_right]}
        ],
      returnable: true}
  end
  def create_textfield
    {description:"Crée un champs saisissable au clavier", 
      args:[
        {name:"Type de contenu", type: :enum, enum:[:integer, :float, :text]},
        {name:"X", type: :int},
        {name:"Y", type: :int},
        {name:"Largeur", type: :int, default: 200},
        {name:"Texte par défaut", type: :string},
        {name:"Alignement", type: :enum, enum:[:left, :center, :right]}
        ],
      returnable: true}
  end
  def erase_textfield
    {description:"Supprime un champ de texte", 
      args:[
        {name:"Champ texte", type: :none}
        ]}
  end
  def get_textfield_value
    {description:"Récupère la valeur d'un champ de texte", 
      args:[
        {name:"Champ texte", type: :none}
        ],
      returnable: true}
  end
  def set_textfield_value
    {description:"Attribue une valeur à un champ de texte", 
      args:[
        {name:"Champ texte", type: :none},
        {name:"Valeur", type: :string}
        ]}
  end
  def activate_textfield
    {description:"Active un champ de texte", 
      args:[
        {name:"Champ texte", type: :none}
        ]}
  end
  def unactivate_textfield
    {description:"désactive un champ de texte", 
      args:[
        {name:"Champ texte", type: :none}
        ]}
  end
  def textfield_actived?
    {description:"Renvoi si un champ est activé (true), ou non (false)", 
      args:[
        {name:"Champ texte", type: :none}
        ],
      returnable: true}
  end
  def unactivate_all_textfield
    {description:"Désactive tous les champs textes"}
  end
  def textfield_hover?
    {description:"Renvoi true si la souris est sur un champ de texte, false sinon", 
      args:[
        {name:"Champ texte", type: :none}
        ],
      returnable: true}
  end
  def textfield_clicked?
    {description:"Renvoi true si la souris clic sur un champ de texte, false sinon", 
      args:[
        {name:"Champ texte", type: :none},
        {name:"Touche", type: :enum, enum:[:mouse_left, :mouse_center, :mouse_right]}
        ],
      returnable: true}
  end
  def textfield_visibility
    {description:"Affiche (true) ou non (false) un champ de texte", 
      args:[
        {name:"Champ texte", type: :none},
        {name:"Touche", type: :bool}
        ]}
  end
  def textfield_opacity
    {description:"Change l'opacité d'un champ de texte", 
      args:[
        {name:"Champ texte", type: :none},
        {name:"Opacité", type: :int, default: 255}
        ]}
  end
  def textfield_tone
    {description:"Change la teinte d'un champ de texte", 
      args:[
        {name:"Champ texte", type: :none},
        {name:"Rouge", type: :int, default: 0},
        {name:"Vert", type: :int, default: 0},
        {name:"Bleu", type: :int, default: 0}, 
        {name:"Gris", type: :int, default: 0}
        ]}
  end
  def server_connect
    {description:"Se connecte à un serveur, renvoi le socket de la connexion", 
      args:[
        {name:"Adresse IP", type: :string},
        {name:"Port", type: :int, default: 9999}
        ],
      returnable: true}
  end
  def server_send
    {description:"Envoi un message au serveur", 
      args:[
        {name:"Socket", type: :none},
        {name:"Message", type: :string}
        ]}
  end
  def server_recv
    {description:"Reçoit un message du serveur", 
      args:[
        {name:"Socket", type: :none}
        ], 
    returnable: true}
  end
  def server_wait_recv
    {description:"Attend du serveur une réponse", 
      args:[
        {name:"Socket", type: :none}
        ], 
    returnable: true}
  end
  def server_close_connection
    {description:"Ferme la connexion au serveur", 
      args:[
        {name:"Socket", type: :none}
        ]}
  end
  def server_single_connect
    {description:"Crée une connexion unique a un serveur (donc sans relais de socket)", 
      args:[
       {name:"Adresse IP", type: :string},
       {name:"Port", type: :int, default: 9999}
      ]}
  end
  def server_single_send
    {description:"Envoi un message au serveur unique", 
      args:[
        {name:"Message", type: :string}
        ]}
  end
  def server_single_recv
    {description:"Reçoit un message du serveur unique", 
    returnable: true}
  end
  def server_single_wait_recv
    {description:"Attend du serveur unique une réponse", 
    returnable: true}
  end
  def server_single_close_connection
    {description:"Ferme la connexion au serveur unique"}
  end
  def include_page
    {description:"Appel une page d'un autre évènement", 
      args:[
       {name:"Id de la Map", type: :int},
       {name:"Id de l'évènement", type: :int},
       {name:"Id de la page", type: :int}
      ]}
  end
  def invoke_event
    {description:"Appel une page d'un autre évènement", 
      args:[
       {name:"Id de la Map", type: :int},
       {name:"Id de l'évènement", type: :int},
       {name:"Nouvel ID", type: :int},
       {name:"Position en X", type: :int},
       {name:"Position en Y", type: :int}
      ]}
  end
  def windows_username
    {description:"Renvoi le nom de la session Windows", 
    returnable: true}
  end
  def angle_xy
    {description:"Renvoi l'angle par rapport à l'axe horizontal entre deux points", 
      args:[
       {name:"Point X1", type: :int},
       {name:"Point Y1", type: :int},
       {name:"Point X2", type: :int},
       {name:"Point Y2", type: :int}
      ],
      returnable: true
     }
  end
  def rtp_path
    {description:"Renvoi le répertoire d'installation du RTP", 
    returnable: true}
  end
  def message_height
    {description:"Change la hauteur des messages", 
      args:[
        {name:"Nombre de ligne", type: :int}
        ]}
  end
end