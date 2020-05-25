module Main where

import           Criterion.Measurement
import           Criterion.Measurement.Types (Measured (..), nfAppIO)
import qualified Data.Text.Lazy              as T
import           Data.Time                   (getCurrentTime)
import           MyLib
import           System.Directory            (getCurrentDirectory)
import           System.Environment
import           System.Process

main :: IO ()
main = do
  history <- readSandWatchData
  args <- getArgs
  now <- getCurrentTime
  thiscwd <- getCurrentDirectory
  let thisRun = Run now (T.strip . T.pack $ unwords args) (T.pack thiscwd) 0 0 0 -- could I treat cmdline params as a Set?
  let guess = guessTime 2 history thisRun
  putStrLn $ "This command will probably take " <> show (guess / 5 * 60) <> " sandwiches to complete."
  let bmark = nfAppIO callCommand (unwords args)
  (msr,_) <- measure bmark 1
  let thisRun' = thisRun { runTime = measTime msr
                         , cpuTime =  measCpuTime msr
                         , cpuCycles = measCycles msr
                         }
  writeSandWatchData $ Runs (thisRun' : (rs history))
  print $ measTime msr
