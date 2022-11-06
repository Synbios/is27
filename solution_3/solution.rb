#!/usr/bin/env ruby
#
# usage: ruby solution.rb test_target_code.rb
# author Mike Zhou, youz@ualberta.ca
# Nov 5, 2022

# This is a script to test the Ruby Chinese Zodiac Prediction code found at
# https://rosettacode.org/wiki/Chinese_zodiac
# the target code takes a year argument and outputs the Chinese zodiac:
# example:
# > ruby test_target_code.rb 2022
# 壬寅 (rén-yín, Water Tiger; yang - year 39 of the cycle)
#
# known the current year (2022) is 壬寅, Water, Tiger, yang, we will exhaustively
# test 2500 years before and after 2022. All attributes are re-ranged so the
# for the current year the symbol is the first in the array so we can easily
# iterate the symbols in the correct order. (e.g. 壬 is the first celestial
# instead of 甲)
#
# Note: this script does not test year before A.D. 1. This is because the 4-digit
# year is only used for years in A.D. When someone wants to calculate the result
# for year 2000 B.C. she should input -1999 (instead of -2000), thus I assume
# B.C. years are out of the input domain, the min starting year is 1.

class ChineseZodiacTest

  PIN_YIN_MAP = {
    '甲': 'jiă', '乙': 'yĭ', '丙': 'bĭng', '丁': 'dīng', '戊': 'wù',
    '己': 'jĭ', '庚': 'gēng', '辛': 'xīn', '壬': 'rén', '癸': 'gŭi',

    '子': 'zĭ', '丑': 'chŏu', '寅': 'yín', '卯': 'măo', '辰': 'chén', '巳': 'sì',
    '午': 'wŭ', '未': 'wèi', '申': 'shēn', '酉': 'yŏu', '戌': 'xū', '亥': 'hài'
  }

  CURRENT_YEAR = 2022

  # the attributes re-arranged using the current year as the first year
  CELES = %w(壬 癸 甲 乙 丙 丁 戊 己 庚 辛)
  TERRS = %w(寅 卯 辰 巳 午 未 申 酉 戌 亥 子 丑)
  ANIMALS = %w(Tiger Rabbit Dragon Snake Horse Goat Monkey Rooster Dog Pig Rat Ox)
  ELEMENTS = %w(Water Water Wood Wood Fire Fire Earth Earth Metal Metal)
  APSECTS = %w(yang yin)

  # calculate the expected output of given year
  def expected_output(year)
    year_difference = year - 2022
    celestial = CELES[year_difference % CELES.length]
    terrestrial = TERRS[year_difference % TERRS.length]
    animal = ANIMALS[year_difference % ANIMALS.length]
    element = ELEMENTS[year_difference % ELEMENTS.length]
    aspect = APSECTS[year_difference % APSECTS.length]
    turn = (year_difference + 39) % 60
    turn = turn == 0 ? 60 : turn # year 0 is year 60
    "#{celestial}#{terrestrial} (#{PIN_YIN_MAP[celestial.to_sym]}-#{PIN_YIN_MAP[terrestrial.to_sym]}, #{element} #{animal}; #{aspect} - year #{turn} of the cycle)"
  end

  # start the test
  # params:
  # test_file_path: test file's relative path
  # end year: year to end test
  # timeout: number of seconds allowed for target (1-5 seconds)
  # return value: true if passes test false if fails test
  def start_test(test_file_path="test_target_code.rb", end_year=200,timeout=1)
    total_test = 0
    failed_test = 0
    if !File.exists?(test_file_path)
      raise Exception.new("Target file is not found")
    elsif end_year < 1
      raise Exception.new("End year must greater than 1")
    elsif timeout < 1 || timeout > 5
      raise Exception.new("Timeout value has to be 1-5 seconds")
    else
      puts "Initial test from year 1 - #{end_year}"

      (1..end_year).each do |year|
        print "test year #{year}..."
        expected_value = expected_output year
        received_value = `timeout #{timeout}s ruby #{test_file_path} #{year}`
        received_value.strip!
        total_test = total_test + 1
        if received_value.length == 0
          failed_test = failed_test + 1
          puts "failed"
          puts "The target script failed to output before timeout"
        elsif expected_value == received_value
          puts "pass"
        else
          failed_test = failed_test + 1
          puts "failed"
          puts "The expected value is '#{expected_value}' but the received value is '#{received_value}'"
        end
      end

      puts "Total #{end_year} tests, #{failed_test} failed."
      if failed_test > 0
        puts "The test is failed."
        false
      else
        puts "The test is passed."
        true
      end
    end
  end
end


### Main program starts here ###
new_test = ChineseZodiacTest.new

if ARGV.length == 2
  test_file_path = ARGV[0]
  end_year = Integer(ARGV[1])
  new_test.start_test test_file_path, end_year
else
  new_test.start_test
end
### END ###
