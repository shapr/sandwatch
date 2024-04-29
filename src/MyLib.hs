{-# LANGUAGE DeriveAnyClass #-}
{-# LANGUAGE DeriveGeneric #-}
{-# LANGUAGE OverloadedStrings #-}

module MyLib where

import Data.Aeson
import Data.Aeson.Text
import qualified Data.ByteString as BS
import Data.Either
import Data.Int (Int64)
import qualified Data.Text.Lazy as T
import Data.Time
import GHC.Generics
import System.AtomicWrite.Writer.LazyText
import System.Directory (
    XdgDirectory (XdgData),
    createDirectoryIfMissing,
    doesFileExist,
    getXdgDirectory,
 )

someFunc :: IO ()
someFunc = putStrLn "someFunc"

-- datatype
data Run = Run
    { tstamp :: !UTCTime -- when was this run?
    , cmdline :: !T.Text -- what was the command?
    , cwd :: !T.Text
    , runTime :: !Double -- seconds of wall clock time
    , cpuTime :: !Double -- cpu seconds
    , cpuCycles :: !Int64 -- cpu cycles from rdtsc instruction
    }
    deriving (Show, Eq, Ord, Generic, ToJSON, FromJSON)

-- ugh, I wish there was an easier way, but whatever
data Runs = Runs
    { rs :: ![Run]
    }
    deriving (Show, Eq, Ord, Generic, ToJSON, FromJSON)

-- read and write data
readSandWatchData :: IO Runs
readSandWatchData = do
    sandWatchDataFile <- getSandWatchFilePath
    dataExists <- doesFileExist sandWatchDataFile
    if not dataExists
        then pure $ Runs []
        else do
            contents <- BS.readFile sandWatchDataFile
            pure $ fromRight (Runs []) (eitherDecodeStrict contents) -- failed to parse json? you get an empty history!

writeSandWatchData :: Runs -> IO ()
writeSandWatchData rs' = do
    sandWatchDataFile <- getSandWatchFilePath
    atomicWriteFile sandWatchDataFile (encodeToLazyText rs')

getSandWatchFilePath :: IO FilePath
getSandWatchFilePath = do
    sandWatchDir <- getXdgDirectory XdgData "sandwatch"
    createDirectoryIfMissing True sandWatchDir -- is this a bad place to do this?
    pure $ sandWatchDir <> "/runs"

-- analyze

{-
prefix match for estimate?
1. filter on cwd,
2. prefix match up to the first space
3. average the past matching runtimes
4. divide by five minutes
5. write out number of sandwiches estimated before running the command
-}
-- need to strip /home/shae/ and /Users/shae/ and whatever shows up on Windows?
-- whatever, do the thing and come back and clean up
filterByCWD :: Runs -> T.Text -> Runs
filterByCWD runs thiscwd = Runs $ filter (\r -> T.strip thiscwd == cwd r) (rs runs)

filterByFirstWord :: Runs -> T.Text -> Runs
filterByFirstWord runs thiscmdline = Runs $ filter (\r -> fstWord thiscmdline == fstWord (cmdline r)) (rs runs)
  where
    fstWord = fst . T.breakOn " "

-- "cabal build" for example
filterByFirstNWords :: Runs -> Int -> T.Text -> Runs
filterByFirstNWords runs n thiscmdline = Runs $ filter (\r -> fstWords n thiscmdline == fstWords n (cmdline r)) (rs runs)
  where
    fstWords n' c = take n' $ T.splitOn " " c

-- | expects historical runs, number of words to match, a Run that has cmdline and cwd populated
guessTime :: Int -> Runs -> Run -> Double
guessTime n pastruns thisrun = avgWallSeconds
  where
    runsInThisDir = filterByCWD pastruns (cwd thisrun)
    runsMatchingNWords = filterByFirstNWords runsInThisDir n (cmdline thisrun)
    wallTimes = runTime <$> rs runsMatchingNWords
    avgWallSeconds = sum wallTimes / fromIntegral (length wallTimes)

-- cycles = cpuCycles <$> (rs runsMatchingNWords)
-- avgCycles = sum cycles /
-- would need to promote this Int64 to Integer for the math to work out?
