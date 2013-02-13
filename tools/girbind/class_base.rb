#
# -File- girbind/class_base.rb
#

module GirBind
  def self.gir_for z
    ir= GObjectIntrospection::IRepository.new
    ir.require z
    ir
  end

  module ClassBase
    include GirBind::Built

    def _gir_info
      z=((ns.get_lib_name == "Cairo") ? "cairo" : ns.get_lib_name)
      @gi = ::GirBind.gir_for(z).find_by_name(z,s="#{name}")
    end

    def setup_instance_function fun
      builder,alist,rt,oa = get_function(fun,"class_func")
  
      return if builder==nil
      alist.find_all_indices do |q| q == nil end.each do |i| alist[i] = :pointer end

      list = [:pointer]
      list.push *alist;

      data = class_func(:"#{prefix.downcase}_#{fun.name}",list,rt,oa)
  
      f = find_class_function(fun.name.to_sym)
      f.constructor = fun.constructor? 
      f
    end

    def bind_instance_function fun,m
      define_method m do |*oo,&bb|
        fun.call self,*oo,&bb
      end
      true
    end
    
    def setup_function fun
      builder,alist,rt,oa = get_function(fun,"class_func")
  
      return if builder==nil
      alist.find_all_indices do |q| q == nil end.each do |i| alist[i] = :pointer end
    #  p m if m == :init
      data = class_func(:"#{prefix.downcase}_#{fun.name}",alist,rt,oa)
  
      f = find_class_function(fun.name.to_sym)
      f.constructor = fun.constructor? 
      f
    end
  
    def bind_function fun,m
      class << self;self;end.define_method m do |*oo,&bb|
        if fun.constructor?

          ins = allocate
          qq=ns

          ins.set_constructor() do |*a,&qb|
            fun.call(*a,&qb)
          end

          ins.send :initialize,*oo,&bb

          ins
        else
          fun.call *oo,&bb
        end
      end
      true
    end

   def self.extended q  
     class << q
       attr_reader :ns,:name
       attr_reader :get_gtype_name
       def get_gtype
         GObject.type_from_name get_gtype_name
       end
     end
   end

def is_cap str
  str.downcase != str
end

def is_lc str
  str.downcase == str
end

def camel2uscore str
  str = str.clone
  have_lc = nil
  idxa = []
  for i in 0..str.length-1
    if have_lc and is_cap(str[i])
      str[i] = str[i].downcase
      idxa << i
      have_lc = false
    elsif is_lc(str[i])
      have_lc = true
    else
    end
  end
  

  str = GLib::Lib.g_string_new(str)

  idxa.each_with_index do |i,c|
 
    GLib::Lib.g_string_insert str,i+c,"_"
  end

  s= GLib::Lib.g_string_free str,false
  s.to_s.downcase
end

   def init_binding klass,ns
  
     @ns = ns
     @name = klass.name
     if !@gstr_init
       
       GLib::Lib.attach_function :g_string_new,[:string],:pointer
       GLib::Lib.attach_function :g_string_free,[:pointer,:bool],:string
       GLib::Lib.attach_function :g_string_insert,[:pointer,:int,:string],:bool      
     end
     @gstr_init = true     
     pn = camel2uscore(name)

     prefix "#{@ns.prefix}_#{pn}".downcase

     @get_gtype_name = ns.get_lib_name+(@name)

     self
   end

    def new *o,&b
      method_missing :new,*o,&b
    end

    def method_missing m,*o,&b
     # p self
     # p m,:d
      if !(fun=find_class_function(m))
        fun = (qc=_gir_info).find_method("#{m}")

        if fun
          func = setup_function(fun)
          bind_function(func,m) if func
       
          super if !func

          send m,*o,&b
        else
          super
        end
      else
        bind_function(fun,m)
        send m,*o,&b
      end
    end
  end
end

