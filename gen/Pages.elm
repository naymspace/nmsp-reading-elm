port module Pages exposing (PathKey, allPages, allImages, application, images, isValidRoute, pages)

import Color exposing (Color)
import Head
import Html exposing (Html)
import Json.Decode
import Json.Encode
import Mark
import Pages.Platform
import Pages.ContentCache exposing (Page)
import Pages.Manifest exposing (DisplayMode, Orientation)
import Pages.Manifest.Category as Category exposing (Category)
import Url.Parser as Url exposing ((</>), s)
import Pages.Document as Document
import Pages.ImagePath as ImagePath exposing (ImagePath)
import Pages.PagePath as PagePath exposing (PagePath)
import Pages.Directory as Directory exposing (Directory)


type PathKey
    = PathKey


buildImage : List String -> ImagePath PathKey
buildImage path =
    ImagePath.build PathKey ("images" :: path)



buildPage : List String -> PagePath PathKey
buildPage path =
    PagePath.build PathKey path


directoryWithIndex : List String -> Directory PathKey Directory.WithIndex
directoryWithIndex path =
    Directory.withIndex PathKey allPages path


directoryWithoutIndex : List String -> Directory PathKey Directory.WithoutIndex
directoryWithoutIndex path =
    Directory.withoutIndex PathKey allPages path


port toJsPort : Json.Encode.Value -> Cmd msg


application :
    { init : ( userModel, Cmd userMsg )
    , update : userMsg -> userModel -> ( userModel, Cmd userMsg )
    , subscriptions : userModel -> Sub userMsg
    , view : userModel -> List ( PagePath PathKey, metadata ) -> Page metadata view PathKey -> { title : String, body : Html userMsg }
    , head : metadata -> List (Head.Tag PathKey)
    , documents : List ( String, Document.DocumentHandler metadata view )
    , manifest : Pages.Manifest.Config PathKey
    , canonicalSiteUrl : String
    }
    -> Pages.Platform.Program userModel userMsg metadata view
application config =
    Pages.Platform.application
        { init = config.init
        , view = config.view
        , update = config.update
        , subscriptions = config.subscriptions
        , document = Document.fromList config.documents
        , content = content
        , toJsPort = toJsPort
        , head = config.head
        , manifest = config.manifest
        , canonicalSiteUrl = config.canonicalSiteUrl
        , pathKey = PathKey
        }



allPages : List (PagePath PathKey)
allPages =
    [ (buildPage [ "bitkom-seo-webinar" ])
    , (buildPage [  ])
    , (buildPage [ "reading-dez-19" ])
    , (buildPage [ "reading-feb-20" ])
    , (buildPage [ "reading-nov-19" ])
    ]

pages =
    { bitkomSeoWebinar = (buildPage [ "bitkom-seo-webinar" ])
    , index = (buildPage [  ])
    , readingDez19 = (buildPage [ "reading-dez-19" ])
    , readingFeb20 = (buildPage [ "reading-feb-20" ])
    , readingNov19 = (buildPage [ "reading-nov-19" ])
    , directory = directoryWithIndex []
    }

images =
    { articleCovers =
        { chrisBarbalis0 = (buildImage [ "article-covers", "chris-barbalis-0.jpg" ])
        , hello = (buildImage [ "article-covers", "hello.jpg" ])
        , mikeKotsch2 = (buildImage [ "article-covers", "mike-kotsch-2.jpg" ])
        , mountains = (buildImage [ "article-covers", "mountains.jpg" ])
        , steinarEngland1 = (buildImage [ "article-covers", "steinar-england-1.jpg" ])
        , directory = directoryWithoutIndex ["articleCovers"]
        }
    , author =
        { sina = (buildImage [ "author", "sina.png" ])
        , tomke = (buildImage [ "author", "tomke.jpg" ])
        , directory = directoryWithoutIndex ["author"]
        }
    , elmLogo = (buildImage [ "elm-logo.svg" ])
    , github = (buildImage [ "github.svg" ])
    , iconPng = (buildImage [ "icon-png.png" ])
    , icon = (buildImage [ "icon.svg" ])
    , directory = directoryWithoutIndex []
    }

allImages : List (ImagePath PathKey)
allImages =
    [(buildImage [ "article-covers", "chris-barbalis-0.jpg" ])
    , (buildImage [ "article-covers", "hello.jpg" ])
    , (buildImage [ "article-covers", "mike-kotsch-2.jpg" ])
    , (buildImage [ "article-covers", "mountains.jpg" ])
    , (buildImage [ "article-covers", "steinar-england-1.jpg" ])
    , (buildImage [ "author", "sina.png" ])
    , (buildImage [ "author", "tomke.jpg" ])
    , (buildImage [ "elm-logo.svg" ])
    , (buildImage [ "github.svg" ])
    , (buildImage [ "icon-png.png" ])
    , (buildImage [ "icon.svg" ])
    ]


isValidRoute : String -> Result String ()
isValidRoute route =
    let
        validRoutes =
            List.map PagePath.toString allPages
    in
    if
        (route |> String.startsWith "http://")
            || (route |> String.startsWith "https://")
            || (route |> String.startsWith "#")
            || (validRoutes |> List.member route)
    then
        Ok ()

    else
        ("Valid routes:\n"
            ++ String.join "\n\n" validRoutes
        )
            |> Err


content : List ( List String, { extension: String, frontMatter : String, body : Maybe String } )
content =
    [ 
  ( ["bitkom-seo-webinar"]
    , { frontMatter = """{"type":"blog","author":"Sina Solveig Söhren","title":"SEO-Webinar","description":"TEST BITKOM AKADEMIE UND SEO-TRENDS 2020","image":"/images/article-covers/mike-kotsch-2.jpg","published":"2020-02-07","draft":true}
""" , body = Nothing
    , extension = "md"
    } )
  ,
  ( []
    , { frontMatter = """{"title":"nmsp reading","type":"blog-index"}
""" , body = Nothing
    , extension = "md"
    } )
  ,
  ( ["reading-dez-19"]
    , { frontMatter = """{"type":"blog","author":"Tomke Reibisch","title":"December 2019","description":"Fun fact: December in the Northern Hemisphere is similar to June in the Southern Hemisphere.","image":"/images/article-covers/steinar-england-1.jpg","published":"2019-12-17"}
""" , body = Nothing
    , extension = "md"
    } )
  ,
  ( ["reading-feb-20"]
    , { frontMatter = """{"type":"blog","author":"Tomke Reibisch","title":"Februar 2020","description":"Fun fact: There are not many Fun Facts about months...","image":"/images/article-covers/mike-kotsch-2.jpg","published":"2020-02-07"}
""" , body = Nothing
    , extension = "md"
    } )
  ,
  ( ["reading-nov-19"]
    , { frontMatter = """{"type":"blog","author":"Tomke Reibisch","title":"November 2019","description":"Fun Fact: November was referred to as Blōtmōnaþ by the Anglo-Saxons.","image":"/images/article-covers/chris-barbalis-0.jpg","published":"2019-11-29"}
""" , body = Nothing
    , extension = "md"
    } )
  
    ]
