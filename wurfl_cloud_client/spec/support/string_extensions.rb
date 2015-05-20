#
# Copyright (c) 2015 ScientiaMobile Inc.
#
# The WURFL Cloud Client is intended to be used in both open-source and
# commercial environments. To allow its use in as many situations as possible,
# the WURFL Cloud Client is dual-licensed. You may choose to use the WURFL
# Cloud Client under either the GNU GENERAL PUBLIC LICENSE, Version 2.0, or
# the MIT License.
#
# Refer to the COPYING.txt file distributed with this package.
#
class String
  class << self
    def random(length=20)
      self.generic_random(length, ("0".."z"))
    end
    def az_random(length=20)
      self.generic_random(length, ("a".."z"))
    end  
    def aznum_random(length=20)
      self.generic_random(length, ("a".."z").to_a + ("0".."9").to_a)
    end  
    def az_random_with_num(length=20, num_lenght=20)
      self.generic_random(length, ("a".."z").to_a)+self.generic_random(length, ("0".."9").to_a)
    end  
    def generic_random(length,char_range)
      chars = char_range.to_a
      Array.new.tap do |a|
        1.upto(length) { |i| a << chars[rand(chars.size-1)]}
      end.join
    end
  end
end