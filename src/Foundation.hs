{-# LANGUAGE OverloadedStrings, TypeFamilies, QuasiQuotes,
             TemplateHaskell, GADTs, FlexibleContexts,
             MultiParamTypeClasses, DeriveDataTypeable,
             GeneralizedNewtypeDeriving, ViewPatterns #-}
module Foundation where
import Import
import Yesod
import Yesod.Static 
import Data.Text
import Data.Time.Clock
import Database.Persist.Postgresql
    ( ConnectionPool, SqlBackend, runSqlPool, runMigration )

data Sitio = Sitio { connPool :: ConnectionPool,
                     getStatic :: Static }

--"pontinho" indica a pasta que ele está , no c9 tem que ser o caminho 

staticFiles "static"

share [mkPersist sqlSettings, mkMigrate "migrateAll"] [persistLowerCase|

Usuario
   nome Text
   pass Text
   deriving Show


Cliente
    nome Text
    cpf Text
    deriving Show

Filme
    nome Text
    diretor Text
    categoria Text
    deriving Show

Locacao
    data Text
    cdFilme FilmeId
    cdCliente ClienteId
    deriving Show

 
|]

mkYesodData "Sitio" pRoutes

instance YesodPersist Sitio where
   type YesodPersistBackend Sitio = SqlBackend
   runDB f = do
       master <- getYesod
       let pool = connPool master
       runSqlPool f pool

instance Yesod Sitio where
    authRoute _ = Just $ LoginR
    isAuthorized LoginR _ = return Authorized
   -- isAuthorized AdminR _ = isAdmin
    isAuthorized MenuR _ = isAdmin
    isAuthorized MenuUsuarioR _ = isUser
    isAuthorized _ _ = isUser

isAdmin = do
    mu <- lookupSession "_ID"
    return $ case mu of
        Nothing -> AuthenticationRequired
        Just "admin" -> Authorized
        Just _ -> Unauthorized "Soh o admin acessa aqui!"

isUser = do
    mu <- lookupSession "_ID"
    return $ case mu of
        --Nothing -> Authorized
        Nothing -> AuthenticationRequired
        Just _ -> Authorized

type Form a = Html -> MForm Handler (FormResult a, Widget)

instance RenderMessage Sitio FormMessage where
    renderMessage _ _ = defaultFormMessage
