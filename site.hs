--------------------------------------------------------------------------------
{-# LANGUAGE OverloadedStrings #-}
import           Data.Monoid                     (mappend, (<>))
import           Data.List                       (intercalate, isSuffixOf)
import           Hakyll
import           Text.Blaze.Html                 (toHtml, toValue, (!))
import           Text.Blaze.Html.Renderer.String (renderHtml)
import qualified Text.Blaze.Html5                as H
import qualified Text.Blaze.Html5.Attributes     as A
import           System.FilePath.Posix  (takeBaseName,takeDirectory,(</>))


--------------------------------------------------------------------------------

whereareposts :: Pattern
whereareposts = "bin/*"

main :: IO ()
main = hakyll $ do

    match "images/*" $ do
        route   idRoute
        compile copyFileCompiler

    match "css/*" $ do
        route   idRoute
        compile compressCssCompiler

    tags <- buildTags whereareposts (fromCapture "words/*.html")

    tagsRules tags $ \tag pattern -> do
        let title = "With keyword: " ++ tag
        route cleanRoute
        compile $ do
            posts_entire <- recentFirst =<< loadAll pattern
            let ctx = constField "title" title `mappend` 
                      listField "posts" postCtx (return posts_entire) `mappend` defaultContext
            makeItem ""
                >>= loadAndApplyTemplate "templates/tag.html" ctx
                >>= loadAndApplyTemplate "templates/default.html" ctx
                >>= relativizeUrls
                >>= cleanIndexUrls

    match whereareposts $ do
        route $ cleanpostRoute
        compile $ pandocCompiler
            >>= loadAndApplyTemplate "templates/post.html"  (postCtxWithTags tags)
            >>= loadAndApplyTemplate "templates/default.html" (postCtxWithTags tags)
            >>= relativizeUrls

    create ["oldies.html"] $ do
        route cleanRoute
        compile $ do
            posts <- recentFirst =<< loadAll whereareposts
            let (_, laterposts) = splitAt 7 posts
            let archiveCtx =
                    field "taglist" (\_ -> renderTagList' (sortTagsBy descendingTags tags)) `mappend`
                    listField "posts" postCtx (return laterposts) `mappend`
                    constField "title" "Older projects" `mappend` defaultContext
            makeItem ""
                >>= loadAndApplyTemplate "templates/oldies.html" archiveCtx
                >>= loadAndApplyTemplate "templates/default.html" archiveCtx
                >>= relativizeUrls
                >>= cleanIndexUrls

    match "index.html" $ do
        route idRoute
        compile $ do
            posts_lately <- fmap (take 7) . recentFirst =<< loadAll whereareposts
            let indexCtx =
                    field "taglist" (\_ -> renderTagList' (sortTagsBy descendingTags tags)) `mappend`
                    listField "posts" postCtx (return posts_lately) `mappend`
                    constField "title" "Lykrysh" `mappend` defaultContext
            getResourceBody
                >>= applyAsTemplate indexCtx
                >>= loadAndApplyTemplate "templates/default.html" indexCtx
                >>= relativizeUrls
                >>= cleanIndexUrls

    match "templates/*" $ compile templateBodyCompiler

--------------------------------------------------------------------------------

postCtx :: Context String
postCtx =
    dateField "date" "%m/%d/%y" `mappend`
    defaultContext

postCtxWithTags :: Tags -> Context String
postCtxWithTags tags = tagsField "tags" tags `mappend` postCtx

renderTagList' :: Tags -> Compiler (String)
renderTagList' = renderTags makeLink (intercalate ", ")
  where
    makeLink tag url count _ _ = renderHtml $
        H.a ! A.href (toValue url) $ toHtml (tag)

descendingTags :: (String, [Identifier]) -> (String, [Identifier]) -> Ordering
descendingTags x y = compare (length (snd y)) (length (snd x))

cleanRoute :: Routes
cleanRoute = customRoute createIndexRoute
  where
    createIndexRoute ident = takeDirectory p </> takeBaseName p </> "index.html"
                            where p = toFilePath ident

cleanpostRoute :: Routes
cleanpostRoute = customRoute createIndexRoute
  where
    createIndexRoute ident = takeBaseName p </> "index.html"
                            where p = toFilePath ident

cleanIndexUrls :: Item String -> Compiler (Item String)
cleanIndexUrls = return . fmap (withUrls clean)
    where
        idx = "index.html"
        clean url
            | idx `isSuffixOf` url = take (length url - length idx - 1) url
            | otherwise            = url


