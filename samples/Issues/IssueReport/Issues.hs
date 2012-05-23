{-# LANGUAGE OverloadedStrings #-}
module Main where

import qualified Github.Issues as Github
import qualified Data.ByteString as B
import Report
import Text.PrettyPrint.Leijen

auth ::  Maybe (B.ByteString, B.ByteString)
auth = Just ("yourgithub id", "somepassword")

mkIssue :: ReportedIssue -> Doc
mkIssue (Issue n t h) = hsep [
        fill 5  (text ("#" ++ (show n))),
        fill 50 (text t),
        fill 5 (text (show h))]

vissues :: ([Doc], [Doc], [Doc]) -> Doc
vissues (x, y, z) = hsep [(vcat x), align (vcat y), align (vcat z)] 

mkDoc :: Report -> Doc
mkDoc (Report issues total) = vsep [
                text "Report for the milestone",
                (vsep . map mkIssue) issues, 
                text ("Total hours : " ++ (show total) ++" hours")
        ]

mkFullDoc ::  [Github.Issue] -> Doc
mkFullDoc = mkDoc . prepareReport

-- The public repo is used as private are quite sensitive for this report
-- 
-- The main idea is to use labels like 1h, 2h etc for man-hour estimation of issues
-- on private repos for development "on hire"
--
-- This tool is used to generate report on work done for the customer
--
main ::  IO ()
main = do
  let limitations = [Github.OnlyClosed, Github.MilestoneId 4]
  possibleIssues <- Github.issuesForRepo' auth  "paulrzcz" "hquantlib" limitations
  case possibleIssues of
       (Left err) -> putStrLn $ "Error: " ++ show err
       (Right issues) -> putDoc $ mkFullDoc issues 