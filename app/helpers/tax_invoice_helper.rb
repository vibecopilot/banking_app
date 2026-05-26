module TaxInvoiceHelper
  # Convert a number to Indian-English words (e.g. 1234.50 => "One Thousand Two Hundred Thirty Four and Fifty Paise Only")
  def number_to_words(number)
    return 'Zero Only' if number.nil? || number.to_f.zero?

    num = number.to_f.round(2)
    rupees = num.to_i
    paise = ((num - rupees) * 100).round

    result = integer_to_words(rupees)
    if paise > 0
      result += " and #{integer_to_words(paise)} Paise"
    end
    result + ' Only'
  end

  private

  ONES = %w[
    Zero One Two Three Four Five Six Seven Eight Nine Ten
    Eleven Twelve Thirteen Fourteen Fifteen Sixteen Seventeen Eighteen Nineteen
  ].freeze

  TENS = %w[
    _ _ Twenty Thirty Forty Fifty Sixty Seventy Eighty Ninety
  ].freeze

  def integer_to_words(n)
    return ONES[0] if n.zero?

    parts = []

    # Crore (10,000,000)
    if n >= 10_000_000
      parts << "#{integer_to_words(n / 10_000_000)} Crore"
      n %= 10_000_000
    end

    # Lakh (100,000)
    if n >= 100_000
      parts << "#{integer_to_words(n / 100_000)} Lakh"
      n %= 100_000
    end

    # Thousand
    if n >= 1_000
      parts << "#{integer_to_words(n / 1_000)} Thousand"
      n %= 1_000
    end

    # Hundred
    if n >= 100
      parts << "#{ONES[n / 100]} Hundred"
      n %= 100
    end

    # Tens & Ones
    if n >= 20
      word = TENS[n / 10]
      word += " #{ONES[n % 10]}" if (n % 10) > 0
      parts << word
    elsif n > 0
      parts << ONES[n]
    end

    parts.join(' ')
  end
end
