--------------------------------------------------------------------------------
{-# LANGUAGE OverloadedStrings #-}
import           Data.Monoid                     (mappend, (<>))
import           Data.List                       (intercalate)
import           Hakyll
import           Text.Blaze.Html                 (toHtml, toValue, (!))
import           Text.Blaze.Html.Renderer.String (renderHtml)
import qualified Text.Blaze.Html5                as H
import qualified Text.Blaze.Html5.Attributes     as A

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

    tags <- buildTags whereareposts (fromCapture "tags/*.html")

    tagsRules tags $ \tag pattern -> do
        let title = "With keyword: " ++ tag
        route idRoute
        compile $ do
            posts_entire <- recentFirst =<< loadAll pattern
            let ctx = constField "title" title `mappend` 
                      listField "posts" postCtx (return posts_entire) `mappend` defaultContext
            makeItem ""
                >>= loadAndApplyTemplate "templates/tag.html" ctx
                >>= loadAndApplyTemplate "templates/default.html" ctx
                >>= relativizeUrls

    match whereareposts $ do
        route $ setExtension "html"
        compile $ pandocCompiler
            >>= loadAndApplyTemplate "templates/post.html"  (postCtxWithTags tags)
            >>= loadAndApplyTemplate "templates/default.html" (postCtxWithTags tags)
            >>= relativizeUrls

    create ["archive.html"] $ do
        route idRoute
        compile $ do
            posts <- recentFirst =<< loadAll whereareposts
            let (_, laterposts) = splitAt 4 posts
            let archiveCtx =
                    listField "posts" postCtx (return laterposts) `mappend`
                    constField "title" "Archives" `mappend` defaultContext
            makeItem ""
                >>= loadAndApplyTemplate "templates/archive.html" archiveCtx
                >>= loadAndApplyTemplate "templates/default.html" archiveCtx
                >>= relativizeUrls

    match "index.html" $ do
        route idRoute
        compile $ do
            posts_lately <- fmap (take 4) . recentFirst =<< loadAll whereareposts
            let indexCtx =
                    field "taglist" (\_ -> renderTagList' (sortTagsBy descendingTags tags)) `mappend`
                    listField "posts" postCtx (return posts_lately) `mappend`
                    constField "title" "" `mappend` defaultContext
            getResourceBody
                >>= applyAsTemplate indexCtx
                >>= loadAndApplyTemplate "templates/default.html" indexCtx
                >>= relativizeUrls

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

