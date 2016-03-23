#encoding: utf-8

class SY
  # Table of standard prefixes.
  # 
  PREFIXES = [ { full: "exa", short: "E", factor: 1e18 },
               { full: "peta", short: "P", factor: 1e15 },
               { full: "tera", short: "T", factor: 1e12 },
               { full: "giga", short: "G", factor: 1e9 },
               { full: "mega", short: "M", factor: 1e6 },
               { full: "kilo", short: "k", factor: 1e3 },
               { full: "hecto", short: "h", factor: 1e2 },
               { full: "deka", short: "dk", factor: 1e1 },
               { full: "", short: "", factor: 1 },
               { full: "deci", short: "d", factor: 1e-1 },
               { full: "centi", short: "c", factor: 1e-2 },
               { full: "mili", short: "m", factor: 1e-3 },
               { full: "micro", short: "µ", factor: 1e-6 },
               { full: "nano", short: "n", factor: 1e-9 },
               { full: "pico", short: "p", factor: 1e-12 },
               { full: "femto", short: "f", factor: 1e-15 },
               { full: "atto", short: "a", factor: 1e-18 } ]
end
