module GUBS.Utils where

import qualified System.IO as IO
import qualified Text.PrettyPrint.ANSI.Leijen as PP
import qualified Debug.Trace as TR
import qualified Control.Monad.Trace as MTR

class PrettySexp a where
  prettySexp :: a -> PP.Doc

ppSexp :: [PP.Doc] -> PP.Doc
ppSexp = PP.encloseSep PP.lparen PP.rparen PP.space

ppCall :: PrettySexp e => String -> [e] -> PP.Doc
ppCall n args = ppSexp (PP.text n : [prettySexp a | a <- args])

renderPretty :: PP.Pretty e => e -> String
renderPretty d = PP.displayS (PP.renderSmart 1.0 200 (PP.pretty d)) ""

hPutDocLn :: PP.Pretty e => IO.Handle -> e -> IO ()
hPutDocLn h = IO.hPutStrLn h . renderPretty

putDocLn :: PP.Pretty e => e -> IO ()
putDocLn = hPutDocLn IO.stdout

putDocErrLn :: PP.Pretty e => e -> IO ()
putDocErrLn = hPutDocLn IO.stderr


tracePretty :: PP.Pretty e => String -> e -> e
tracePretty s d = TR.trace (renderPretty (PP.text s PP.<+> PP.pretty d)) d


logMsg :: MTR.MonadTrace String m => PP.Pretty e => e -> m ()
logMsg = MTR.trace . renderPretty

logBlk :: MTR.MonadTrace String m => PP.Pretty e => e -> m a -> m a
logBlk = MTR.scopeTrace . renderPretty
