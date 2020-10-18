class Object
  def to_msgpack(packer)
    packer.pack(to_s)
  end
end
