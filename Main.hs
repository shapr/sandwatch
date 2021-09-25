module Main where

import Criterion.Measurement
import Criterion.Measurement.Types (Measured (..), nfAppIO)
import qualified Data.Text.Lazy as T
import Data.Time (getCurrentTime)
import MyLib
import Numeric
import System.Directory (getCurrentDirectory)
import System.Environment
import System.Process

-- | A sandwich takes five minutes according to my poll: https://twitter.com/shapr/status/1263950892744806402
sandwichSeconds :: Double
sandwichSeconds = 5 * 60

-- | How many words at the beginning of the command line to match?
wordsToMatch :: Int
wordsToMatch = 3

main :: IO ()
main = do
  history <- readSandWatchData
  args <- getArgs
  now <- getCurrentTime
  thiscwd <- getCurrentDirectory
  let thisRun = Run now (T.strip . T.pack $ unwords args) (T.pack thiscwd) 0 0 0 -- could I treat cmdline params as a Set?
  let guess = guessTime wordsToMatch history thisRun
  putStrLn $ "This command will probably take " <> formatFloat (guess / (5 * 60)) <> " sandwiches to complete."
  let bmark = nfAppIO callCommand (unwords args)
  (msr, _) <- measure bmark 1
  let thisRun' =
        thisRun
          { runTime = measTime msr,
            cpuTime = measCpuTime msr,
            cpuCycles = measCycles msr
          }
  writeSandWatchData $ Runs (thisRun' : rs history)
  putStrLn $ "Actual time was " <> formatFloat (measTime msr / sandwichSeconds) <> " sandwiches."
  where
    formatFloat f = showFFloat (Just 2) f ""
