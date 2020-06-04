{ mkDerivation, aeson, atomic-write, base, bytestring
, criterion-measurement, directory, process, stdenv, text, time
}:
mkDerivation {
  pname = "sandwatch";
  version = "0.1.0.0";
  src = ./.;
  isLibrary = true;
  isExecutable = true;
  libraryHaskellDepends = [
    aeson atomic-write base bytestring criterion-measurement directory
    process text time
  ];
  executableHaskellDepends = [
    aeson atomic-write base bytestring criterion-measurement directory
    process text time
  ];
  testHaskellDepends = [
    aeson atomic-write base bytestring criterion-measurement directory
    process text time
  ];
  license = stdenv.lib.licenses.bsd3;
}
