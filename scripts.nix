{s}: 
{
  ghcidScript = s "dev" "ghcid --command 'cabal new-repl lib:sandwatch' --allow-eval --warnings";
  testScript = s "test" "cabal run test:sandwatch-tests";
  hoogleScript = s "hgl" "hoogle serve";
}
