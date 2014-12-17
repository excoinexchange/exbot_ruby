require 'money'

cryptocurrency = {
  :priority        => 1,
  :iso_code        => "CRYPTO",
  :name            => "Crypto",
  :symbol          => "CRYPTO",
  :subunit         => "Satoshi",
  :subunit_to_unit => 100000000,
  :separator       => ".",
  :delimiter       => ","
}

Money::Currency.register(cryptocurrency)
Money.default_currency = Money::Currency.new("CRYPTO")
Money.use_i18n = false
