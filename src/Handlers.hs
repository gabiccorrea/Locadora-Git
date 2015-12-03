{-# LANGUAGE OverloadedStrings, QuasiQuotes,
             TemplateHaskell #-}
 
module Handlers where
import Import
import Yesod
import Yesod.Static
import Foundation
import Control.Monad.Logger (runStdoutLoggingT)
import Control.Applicative
import Data.Text
import Text.Lucius 

import Database.Persist.Postgresql

mkYesodDispatch "Sitio" pRoutes


-----[Importando estilo css]----------------------------
widgetForm :: Route Sitio -> Enctype -> Widget -> Text -> Text -> Widget
widgetForm x enctype widget y val = do
     msg <- getMessage
     $(whamletFile "form.hamlet")
     toWidget $(luciusFile "teste.lucius")

-----[Login]--------------------------------------------
getLoginR :: Handler Html
getLoginR = do
    (wid,enc) <- generateFormPost formUsu
    defaultLayout $ widgetForm LoginR enc wid "" "Entrar" 
    
postLoginR :: Handler Html
postLoginR = do
    ((result,_),_) <- runFormPost formUsu
    case result of
        FormSuccess usr -> do
            usuario <- runDB $ selectFirst [UsuarioNome ==. usuarioNome usr, UsuarioPass ==. usuarioPass usr ] []
            case usuario of
                Just (Entity uid usr) -> do
                    setSession "_ID" (usuarioNome usr)
                    case usuarioNome usr of
                         "admin" -> do redirect MenuR
                         _ -> do redirect MenuUsuarioR
                    redirect MenuR                         
                Nothing -> do
                    setMessage $ [shamlet| Usuário não cadastrado |]
                    redirect LoginR 
        _ -> redirect LoginR


-----[Pagina Inicial]-----------------------------------
getInicioR :: Handler Html
getInicioR = defaultLayout [whamlet|

   <body bgcolor="#A9A9A9">
   <h1 align="center"> Locadora Haskell
       <p> Controle de filmes e locações<br><br>
            <img src="http://markmeets.com/wp-content/uploads/2013/10/Movie-Releases.jpg"/><br>
            <a href=@{MenuR}>Acesso Admin <br>
            <a href=@{MenuUsuarioR}>Acesso Comum
|]


-----[Sair do painel]----------------------------------------------
getByeR :: Handler Html
getByeR = do
    deleteSession "_ID"
    defaultLayout [whamlet| 

   <body bgcolor="#A9A9A9">
   <h1 align="center"> Obrigado pela Visita!
            <br>
            <a href=@{LoginR}>Acessar tela de Login
|]


----
getAdminR :: Handler Html
getAdminR = defaultLayout [whamlet| |]



----[CLIENTE]----

formCliente :: Form Cliente
formCliente = renderDivs $ Cliente <$>
             areq textField "Nome" Nothing  <*>
             areq textField "CPF"  Nothing  

widgetFormC :: Enctype -> Widget -> Widget
widgetFormC enctype widget = [whamlet|
            <body bgcolor="#F2EFFB">
            <h1 font style="italic" font-family="verdana"> 
                Cadastro de Clientes
            <form method=post action=@{CadastroClienteR} enctype=#{enctype}>
                ^{widget}
                <input type="submit" value="Cadastrar">
|]

getCadastroClienteR :: Handler Html
getCadastroClienteR = do
             (widget, enctype) <- generateFormPost formCliente
             defaultLayout $ (widgetFormC enctype widget) >> ww

getClienteR :: ClienteId -> Handler Html
getClienteR pid = do
             cliente <- runDB $ get404 pid 
             defaultLayout [whamlet| 
                 <body bgcolor="#F2EFFB">
                 <h1> Perfil de Usuário
                 <p> #{clienteNome cliente} <br>
                 <p> #{clienteCpf cliente} <br>                             
                 <a href=@{LocacoesR pid}> Locações <br>
                 <a href=@{MenuR} title="Voltar"> Voltar

             |]

getListarClienteR :: Handler Html
getListarClienteR = do
             listaP <- runDB $ selectList [] [Asc ClienteNome]
             defaultLayout [whamlet|
                <div style="background-color:navy; padding: 10px;">
                                <a href=@{MenuR} title="Menu" style="color:whitesmoke;"> Inicio /
                                <a href="@{UsuarioR}" title="Usuarios Cadastrados" style="color:whitesmoke;"> Cadastro de Usuários  /   
                                <a href="@{ListUserR}" title="Usuarios" style="color:whitesmoke;"> Usuários  /
                                <a href=@{CadastroClienteR} title="Clientes Cadastro" style="color:whitesmoke;"> Cadastro de Cliente /
                                <a href=@{CadastroFilmeR} title="Filmes Cadastro" style="color:whitesmoke;"> Cadastro de Filmes /
                                <a href=@{LocacaoR} title="Locacao Cadastro" style="color:whitesmoke;"> Realizar Locacao /   
                                <a href=@{ListarFilmeR} title="Filmes" style="color:whitesmoke;"> Listar Filmes /
                                <a href=@{ListarClienteR} title="Clientes" style="color:whitesmoke;"> Listar Clientes /   
                                <a href=@{AutorR} title="Sobre" style="color:whitesmoke;"> Sobre  / 
                                <a href="@{ByeR}" title="Logout da área restrita" style="color:whitesmoke;"> Sair
                <div>                  
                <div style="background-color:lavender;">
                    <h1>Clientes cadastrados:
                        $forall Entity pid cliente <- listaP
                           <a href=@{ClienteR pid}> #{clienteNome cliente} <br>

                    <div style="margin-top: 50px;"><a href=@{MenuR} title="Voltar"> Voltar
                <div>
             |]



postCadastroClienteR :: Handler Html
postCadastroClienteR = do
                ((result, _), _) <- runFormPost formCliente
                case result of
                    FormSuccess cliente -> do
                       runDB $ insert cliente 
                       defaultLayout [whamlet| 
                           <body bgcolor="#F2EFFB">
                           <h1 font style="bold" font-family="verdana"> #{clienteNome cliente} inserido com sucesso!
                           <a href=@{MenuR} title="Voltar"> Voltar
                       |]
                    _ -> redirect CadastroClienteR

--[Listar Cliente - Usuario]--
getListarClienteUsuarioR :: Handler Html
getListarClienteUsuarioR = do
             listaP <- runDB $ selectList [] [Asc ClienteNome]
             defaultLayout [whamlet|
                <div style="background-color:navy; padding: 10px;">
                 <a href=@{MenuUsuarioR} title="Menu" style="color:whitesmoke;"> Inicio /  
                                <a href=@{ListarFilmeUsuarioR} title="Filmes" style="color:whitesmoke;"> Listar Filmes /
                                <a href=@{ListarClienteUsuarioR} title="Clientes" style="color:whitesmoke;"> Listar Clientes /   
                                <a href=@{LocacaoUsuarioR} title="Locacao Cadastro" style="color:whitesmoke;"> Realizar Locacao /  
                                <a href=@{AutorUsuarioR} title="Sobre" style="color:whitesmoke;"> Sobre  / 
                                <a href="@{ByeR}" title="Logout da área restrita" style="color:whitesmoke;"> Sair
                <div style="background-color:lavender;">
                 <h1>Clientes cadastrados:
                 $forall Entity pid cliente <- listaP
                      <a href=@{ClienteUsuarioR pid}> #{clienteNome cliente} <br>

                <div style="margin-top: 50px;"><a href=@{MenuUsuarioR} title="Voltar"> Voltar
               <div>
                
             |]


getClienteUsuarioR :: ClienteId -> Handler Html
getClienteUsuarioR pid = do
             cliente <- runDB $ get404 pid 
             defaultLayout [whamlet| 
                 <body bgcolor="#F2EFFB">
                 <h1> Perfil de Usuário
                 <p> #{clienteNome cliente} <br>
                 <p> #{clienteCpf cliente} <br>                             
                 <a href=@{LocacoesUsuarioR pid}> Locações <br>
                 <a href=@{MenuUsuarioR} title="Voltar"> Voltar

             |]


                    
----[FILME]----

formFilme :: Form Filme
formFilme = renderDivs $ Filme <$>
             areq textField "Nome" Nothing <*>
             areq textField "Diretor" Nothing <*>
             areq textField "Categoria" Nothing



widgetFormF :: Enctype -> Widget -> Widget
widgetFormF enctype widget = [whamlet|
            <body bgcolor="#F2EFFB">
            <h1 font style="italic" font-family="verdana" >
                Cadastro de filmes
            <form method=post action=@{CadastroFilmeR} enctype=#{enctype}>
                ^{widget}
                <input type="submit" value="Cadastrar">

|]                       

getCadastroFilmeR :: Handler Html
getCadastroFilmeR = do
             (widget, enctype) <- generateFormPost formFilme
             defaultLayout $ (widgetFormF enctype widget) >> ww

getFilmeR :: FilmeId -> Handler Html
getFilmeR pid = do
             filme <- runDB $ get404 pid 
             defaultLayout [whamlet| 
                 <body bgcolor="#F2EFFB">
                 <h1> Detalhes
                 <table style="width:20%;font-family=verdana" bgcolor="#B1BABA" border="1px solid"><tr><td> Novo filme no acervo: <td> #{filmeNome filme}<tr><td> Diretor:<td> #{filmeDiretor filme}<tr>
                 <a href=@{MenuR} title="Voltar"> Voltar

             |]


getListarFilmeR :: Handler Html
getListarFilmeR = do
             listaP <- runDB $ selectList [] [Asc FilmeNome]
             defaultLayout [whamlet|
                <div style="background-color:navy; padding: 10px;">
                                <a href=@{MenuR} title="Menu" style="color:whitesmoke;"> Inicio /
                                <a href="@{UsuarioR}" title="Usuarios Cadastrados" style="color:whitesmoke;"> Cadastro de Usuários  /   
                                <a href="@{ListUserR}" title="Usuarios" style="color:whitesmoke;"> Usuários  /
                                <a href=@{CadastroClienteR} title="Clientes Cadastro" style="color:whitesmoke;"> Cadastro de Cliente /
                                <a href=@{CadastroFilmeR} title="Filmes Cadastro" style="color:whitesmoke;"> Cadastro de Filmes /
                                <a href=@{LocacaoR} title="Locacao Cadastro" style="color:whitesmoke;"> Realizar Locacao /   
                                <a href=@{ListarFilmeR} title="Filmes" style="color:whitesmoke;"> Listar Filmes /
                                <a href=@{ListarClienteR} title="Clientes" style="color:whitesmoke;"> Listar Clientes /   
                                <a href=@{AutorR} title="Sobre" style="color:whitesmoke;"> Sobre  / 
                                <a href="@{ByeR}" title="Logout da área restrita" style="color:whitesmoke;"> Sair
                <div>
                <div style="background-color:lavender;">
                       <h1>Filmes cadastrados:
                        $forall Entity pid filme <- listaP
                            <a href=@{FilmeR pid}> #{filmeNome filme} <br>

                        <div style="margin-top: 50px;"><a href=@{MenuR} title="Voltar"> Voltar
                                               <a href=@{LocacaoR} title="Alugar"> Alugar
                <div>
                                                  
             |]




postCadastroFilmeR :: Handler Html
postCadastroFilmeR = do
                ((result, _), _) <- runFormPost formFilme
                case result of
                    FormSuccess filme -> do
                       runDB $ insert filme 
                       defaultLayout [whamlet| 
                           <body bgcolor="#F2EFFB">
                           <h1 font style="bold" font-family="verdana"> #{filmeNome filme} inserido com sucesso!
                           <a href=@{MenuR} title="Voltar"> Voltar
                       |]
                    _ -> redirect CadastroFilmeR

--[Listar Filmes - Usuario]--

getListarFilmeUsuarioR :: Handler Html
getListarFilmeUsuarioR = do
             listaP <- runDB $ selectList [] [Asc FilmeNome]
             defaultLayout [whamlet|
                <div style="background-color:navy; padding: 10px;">
                    <a href=@{MenuUsuarioR} title="Menu" style="color:whitesmoke;"> Inicio /  
                                <a href=@{ListarFilmeUsuarioR} title="Filmes" style="color:whitesmoke;"> Listar Filmes /
                                <a href=@{ListarClienteUsuarioR} title="Clientes" style="color:whitesmoke;"> Listar Clientes /   
                                <a href=@{LocacaoUsuarioR} title="Locacao Cadastro" style="color:whitesmoke;"> Realizar Locacao /  
                                <a href=@{AutorUsuarioR} title="Sobre" style="color:whitesmoke;"> Sobre  / 
                                <a href="@{ByeR}" title="Logout da área restrita" style="color:whitesmoke;"> Sair
                 <div>
                 <div style="background-color:lavender;">
                    <h1>Filmes cadastrados:
                        $forall Entity pid filme <- listaP
                            <a href=@{FilmeUsuarioR pid}> #{filmeNome filme} <br>

                            <div style="margin-top: 50px;"><a href=@{MenuUsuarioR} title="Voltar"> Voltar
                                               <a href=@{LocacaoUsuarioR} title="Alugar"> Alugar
                  <div>
             |]

getFilmeUsuarioR :: FilmeId -> Handler Html
getFilmeUsuarioR pid = do
             filme <- runDB $ get404 pid 
             defaultLayout [whamlet| 
                 <body bgcolor="#F2EFFB">
                 <h1> Detalhes
                 <table style="width:20%;font-family=verdana" bgcolor="#B1BABA" border="1px solid"><tr><td> Novo filme no acervo: <td> #{filmeNome filme}<tr><td> Diretor:<td> #{filmeDiretor filme}<tr>
                 <a href=@{MenuUsuarioR} title="Voltar"> Voltar
|]


--[LOCACAO]-----

formLocacao :: Form Locacao
formLocacao = renderDivs $ Locacao <$>
             areq textField "Data" Nothing <*>
             areq (selectField filme) "FilmeId" Nothing <*>
             areq (selectField cliente) "Cliente: " Nothing 

             
cliente = do
        entities <- runDB $ selectList [] [Asc ClienteNome]
        optionsPairs $ Prelude.map (\en -> (clienteNome $ entityVal en, entityKey en)) entities 

filme = do
        entities <- runDB $ selectList [] [Asc FilmeNome]
        optionsPairs $ Prelude.map (\en -> (filmeNome $ entityVal en, entityKey en)) entities 

widgetFormL :: Enctype -> Widget -> Widget
widgetFormL enctype widget = [whamlet|
            <body bgcolor="#F2EFFB">
            <h1 font style="italic" font-family="verdana" >
                Cadastro de Locacao
            <form method=post action=@{LocacaoR} enctype=#{enctype}>
                ^{widget}
                <input type="submit" value="Cadastrar">
|]



getLocacaoR :: Handler Html
getLocacaoR = do
             (widget, enctype) <- generateFormPost formLocacao
             defaultLayout $ (widgetFormL enctype widget) >> ww



getLocacoesR :: Key Cliente -> Handler Html
getLocacoesR x = do
             listaP <- runDB $ selectList [LocacaoCdCliente ==. x] []
             defaultLayout [whamlet|
                 <body bgcolor="#F2EFFB">
                 <h1>Locações:
                 $forall Entity pid locacao <- listaP                                             
                     <p>#{locacaoData locacao}> 
                     <link href="https://evernotecdn-a.akamaihd.net/support-assets/en/clearly-return-icon.jpg" rel="icon" type="image/x-icon" />  
                <div style="margin-top: 50px;"><a href=@{MenuR} title="Voltar"> Voltar
             |]


postLocacaoR :: Handler Html
postLocacaoR = do
                ((result, _), _) <- runFormPost formLocacao
                case result of
                    FormSuccess locacao -> do
                       runDB $ insert locacao 
                       defaultLayout [whamlet| 
                           <body bgcolor="#F2EFFB">
                           <h1 font style="bold" font-family="verdana"> Locacao registrada com sucesso!
                           <a href=@{MenuR} title="Voltar"> Voltar
                       |]
                    _ -> redirect LocacaoR
                    


--[Usuario]--

widgetFormLu :: Enctype -> Widget -> Widget
widgetFormLu enctype widget = [whamlet|
            <body bgcolor="#F2EFFB">
            <h1 font style="italic" font-family="verdana" >
                Cadastro de Locacao
            <form method=post action=@{LocacaoUsuarioR} enctype=#{enctype}>
                ^{widget}
                <input type="submit" value="Cadastrar">
              |]



getLocacaoUsuarioR :: Handler Html
getLocacaoUsuarioR = do
             (widget, enctype) <- generateFormPost formLocacao
             defaultLayout $ (widgetFormLu enctype widget) >> wwu
             
getLocacoesUsuarioR :: Key Cliente -> Handler Html
getLocacoesUsuarioR x = do
             listaP <- runDB $ selectList [LocacaoCdCliente ==. x] []
             defaultLayout [whamlet|
                 <body bgcolor="#F2EFFB">
                 <h1>Locações:
                 $forall Entity pid locacao <- listaP                                             
                     <p>#{locacaoData locacao}> 
                     <link href="https://evernotecdn-a.akamaihd.net/support-assets/en/clearly-return-icon.jpg" rel="icon" type="image/x-icon" />  
                <div style="margin-top: 50px;"><a href=@{MenuUsuarioR} title="Voltar"> Voltar
             |]

postLocacaoUsuarioR :: Handler Html
postLocacaoUsuarioR = do
                ((result, _), _) <- runFormPost formLocacao
                case result of
                    FormSuccess locacao -> do
                       runDB $ insert locacao 
                       defaultLayout [whamlet| 
                           <body bgcolor="#F2EFFB">
                           <h1 font style="bold" font-family="verdana"> Locacao registrada com sucesso!
                           <a href=@{MenuUsuarioR} title="Voltar"> Voltar
                       |]
                    _ -> redirect LocacaoUsuarioR

----[MENU]----


-----[Nosso Menu Admin]---------------------------------------------
getMenuR :: Handler Html
getMenuR = do
     usr <- lookupSession "_ID"
     defaultLayout [whamlet|
        $maybe m <- usr
            <h3> Seja Bem-Vindo #{m} 

        <link rel="shortcut icon" href="/favicon.ico" type="image/x-icon">
        <link rel="icon" href="/favicon.ico" type="image/x-icon">

               <div style="background-color:navy; padding: 10px;">
                                <a href=@{MenuR} title="Menu" style="color:whitesmoke;"> Inicio /
                                <a href="@{UsuarioR}" title="Usuarios Cadastrados" style="color:whitesmoke;"> Cadastro de Usuários  /   
                                <a href="@{ListUserR}" title="Usuarios" style="color:whitesmoke;"> Usuários  /
                                <a href=@{CadastroClienteR} title="Clientes Cadastro" style="color:whitesmoke;"> Cadastro de Cliente /
                                <a href=@{CadastroFilmeR} title="Filmes Cadastro" style="color:whitesmoke;"> Cadastro de Filmes /
                                <a href=@{LocacaoR} title="Locacao Cadastro" style="color:whitesmoke;"> Realizar Locacao /   
                                <a href=@{ListarFilmeR} title="Filmes" style="color:whitesmoke;"> Listar Filmes /
                                <a href=@{ListarClienteR} title="Clientes" style="color:whitesmoke;"> Listar Clientes /   
                                <a href=@{AutorR} title="Sobre" style="color:whitesmoke;"> Sobre  / 
                                <a href="@{ByeR}" title="Logout da área restrita" style="color:whitesmoke;"> Sair
                                   
                <div style="background-color:#A9A9A9;">
                 <h1 align="center"> Locadora Haskell <br><br>
                        <img src="http://markmeets.com/wp-content/uploads/2013/10/Movie-Releases.jpg"/><br>

|]

ww :: Widget
ww = toWidgetHead [hamlet|
<div style="background-color:navy; padding: 10px;">
                                 <a href=@{MenuR} title="Menu" style="color:whitesmoke;"> Inicio /
                                <a href="@{UsuarioR}" title="Usuarios Cadastrados" style="color:whitesmoke;"> Cadastro de Usuários  /   
                                <a href="@{ListUserR}" title="Usuarios" style="color:whitesmoke;"> Usuários  /
                                <a href=@{CadastroClienteR} title="Clientes Cadastro" style="color:whitesmoke;"> Cadastro de Cliente /
                                <a href=@{CadastroFilmeR} title="Filmes Cadastro" style="color:whitesmoke;"> Cadastro de Filmes /
                                <a href=@{LocacaoR} title="Locacao Cadastro" style="color:whitesmoke;"> Realizar Locacao /   
                                <a href=@{ListarFilmeR} title="Filmes" style="color:whitesmoke;"> Listar Filmes /
                                <a href=@{ListarClienteR} title="Clientes" style="color:whitesmoke;"> Listar Clientes /   
                                <a href=@{AutorR} title="Sobre" style="color:whitesmoke;"> Sobre  / 
                                <a href="@{ByeR}" title="Logout da área restrita" style="color:whitesmoke;"> Sair
|]



-----[Nosso Menu Usuario]---------------------------------------------
getMenuUsuarioR :: Handler Html
getMenuUsuarioR = do
     usr <- lookupSession "_ID"
     defaultLayout [whamlet|
        $maybe u <- usr
            <h3> Seja Bem-Vindo #{u} 

               <div style="background-color:navy; padding: 10px;">
                                <a href=@{MenuUsuarioR} title="Menu" style="color:whitesmoke;"> Inicio /  
                                <a href=@{ListarFilmeUsuarioR} title="Filmes" style="color:whitesmoke;"> Listar Filmes /
                                <a href=@{ListarClienteUsuarioR} title="Clientes" style="color:whitesmoke;"> Listar Clientes /   
                                <a href=@{LocacaoUsuarioR} title="Locacao Cadastro" style="color:whitesmoke;"> Realizar Locacao /  
                                <a href=@{AutorUsuarioR} title="Sobre" style="color:whitesmoke;"> Sobre  / 
                                <a href="@{ByeR}" title="Logout da área restrita" style="color:whitesmoke;"> Sair
                                   
                <div style="background-color:#A9A9A9;">
                 <h1 align="center"> Locadora Haskell <br><br>
                        <img src="http://markmeets.com/wp-content/uploads/2013/10/Movie-Releases.jpg"/><br>

|]


wwu :: Widget
wwu = toWidgetHead [hamlet|
<div style="background-color:navy; padding: 10px;">
                                <a href=@{MenuUsuarioR} title="Menu" style="color:whitesmoke;"> Inicio /  
                                <a href=@{ListarFilmeUsuarioR} title="Filmes" style="color:whitesmoke;"> Listar Filmes /
                                <a href=@{ListarClienteUsuarioR} title="Clientes" style="color:whitesmoke;"> Listar Clientes /   
                                <a href=@{LocacaoUsuarioR} title="Locacao Cadastro" style="color:whitesmoke;"> Realizar Locacao /  
                                <a href=@{AutorUsuarioR} title="Sobre" style="color:whitesmoke;"> Sobre  / 
                                <a href="@{ByeR}" title="Logout da área restrita" style="color:whitesmoke;"> Sair
|]



--[USUÁRIO]--

-----[Novo usuário]----------------------------------------------
formUsu :: Form Usuario
formUsu = renderDivs $ Usuario <$>
    areq textField "Nome" Nothing <*>
    areq passwordField "Senha" Nothing


widgetFormU :: Enctype -> Widget -> Widget
widgetFormU enctype widget = [whamlet|
            <body bgcolor="#F2EFFB">
            <h1 font style="italic" font-family="verdana" >
                Cadastro de Usuário:
            <form method=post action=@{UsuarioR} enctype=#{enctype}>
                ^{widget}
                <input type="submit" value="Cadastrar">
|]


getUsuarioR :: Handler Html
getUsuarioR = do
             (widget, enctype) <- generateFormPost formUsu
             defaultLayout $ (widgetFormU enctype widget) >> ww
        
postUsuarioR :: Handler Html
postUsuarioR = do
                ((result, _), _) <- runFormPost formUsu
                case result of
                    FormSuccess usr -> do
                       runDB $ insert usr 
                       defaultLayout [whamlet| 
                           <body bgcolor="#F2EFFB">
                           <h1 font style="bold" font-family="verdana"> Usuário inserido com sucesso!
                           <a href=@{MenuR} title="Voltar"> Voltar
                       |]
                    _ -> redirect UsuarioR

             
getListUserR :: Handler Html
getListUserR = do     

                 listaU <- runDB $ selectList [] [Asc UsuarioNome]
                 
                 defaultLayout [whamlet|
                    <div style="background-color:navy; padding: 10px;">
                                <a href=@{MenuR} title="Menu" style="color:whitesmoke;"> Inicio /
                                <a href="@{UsuarioR}" title="Usuarios Cadastrados" style="color:whitesmoke;"> Cadastro de Usuários  /   
                                <a href="@{ListUserR}" title="Usuarios" style="color:whitesmoke;"> Usuários  /
                                <a href=@{CadastroClienteR} title="Clientes Cadastro" style="color:whitesmoke;"> Cadastro de Cliente /
                                <a href=@{CadastroFilmeR} title="Filmes Cadastro" style="color:whitesmoke;"> Cadastro de Filmes /
                                <a href=@{LocacaoR} title="Locacao Cadastro" style="color:whitesmoke;"> Realizar Locacao /   
                                <a href=@{ListarFilmeR} title="Filmes" style="color:whitesmoke;"> Listar Filmes /
                                <a href=@{ListarClienteR} title="Clientes" style="color:whitesmoke;"> Listar Clientes /   
                                <a href=@{AutorR} title="Sobre" style="color:whitesmoke;"> Sobre  / 
                                <a href="@{ByeR}" title="Logout da área restrita" style="color:whitesmoke;"> Sair
                
                 <body bgcolor="#F2EFFB">
                   <h1>Usuarios cadastrados:
                      <div style="padding:0; clear:both">
                        <div style="border: 1px solid; width: 190px; background-color:lavender; text-align: center; float:left; font-size:20px; "> Usuarios
                        <div style="border: 1px solid; width: 190px; background-color:lavender; text-align: center; float:left; font-size:20px;"> Senhas
                      <div>
                      $forall Entity pid usuario <- listaU
                           <div style="padding:0; clear:both">
                              <div style="border: 1px solid; width: 190px; background-color:lavender; text-align: center; float:left; font-size:20px; "> #{usuarioNome usuario} 
                              <div style="border: 1px solid; width: 190px; background-color:lavender; text-align: center; float:left; font-size:20px;  "> #{usuarioPass usuario}
                           <div>
                <div style="margin-top: 50px;"><a href=@{MenuR} title="Voltar"> Voltar
  
                |]  

----[SOBRE ADMIN]----
getAutorR :: Handler Html
getAutorR = defaultLayout [whamlet|

 <div style="background-color:navy; padding: 10px;">
      <a href=@{MenuR} title="Menu" style="color:whitesmoke;"> Inicio /
                                <a href="@{UsuarioR}" title="Usuarios Cadastrados" style="color:whitesmoke;"> Cadastro de Usuários  /   
                                <a href="@{ListUserR}" title="Usuarios" style="color:whitesmoke;"> Usuários  /
                                <a href=@{CadastroClienteR} title="Clientes Cadastro" style="color:whitesmoke;"> Cadastro de Cliente /
                                <a href=@{CadastroFilmeR} title="Filmes Cadastro" style="color:whitesmoke;"> Cadastro de Filmes /
                                <a href=@{LocacaoR} title="Locacao Cadastro" style="color:whitesmoke;"> Realizar Locacao /   
                                <a href=@{ListarFilmeR} title="Filmes" style="color:whitesmoke;"> Listar Filmes /
                                <a href=@{ListarClienteR} title="Clientes" style="color:whitesmoke;"> Listar Clientes /   
                                <a href=@{AutorR} title="Sobre" style="color:whitesmoke;"> Sobre  / 
                                <a href="@{ByeR}" title="Logout da área restrita" style="color:whitesmoke;"> Sair
    <div style="background-color:lavender;">
      <p><h1>Locadora Haskell 
       <p> <h2>  Gabrielle Carvalho e Juliana Amparo <br> 
       <p> 2015
      <a href=@{MenuR} title="Voltar"> Voltar
    <div>
|]

----[SOBRE ADMIN]----

getAutorUsuarioR :: Handler Html
getAutorUsuarioR = defaultLayout [whamlet|
    <div style="background-color:navy; padding: 10px;">
          <a href=@{MenuUsuarioR} title="Menu" style="color:whitesmoke;"> Inicio /  
                                <a href=@{ListarFilmeUsuarioR} title="Filmes" style="color:whitesmoke;"> Listar Filmes /
                                <a href=@{ListarClienteUsuarioR} title="Clientes" style="color:whitesmoke;"> Listar Clientes /   
                                <a href=@{LocacaoUsuarioR} title="Locacao Cadastro" style="color:whitesmoke;"> Realizar Locacao /  
                                <a href=@{AutorUsuarioR} title="Sobre" style="color:whitesmoke;"> Sobre  / 
                                <a href="@{ByeR}" title="Logout da área restrita" style="color:whitesmoke;"> Sair


    <div style="background-color:lavender;">
      <p><h1>Locadora Haskell      
         <p> <h2>  Gabrielle Carvalho e Juliana Amparo <br> 
         <p> 2015
      <a href=@{MenuUsuarioR} title="Voltar"> Voltar
    <div>    
       
|]


-----[Configuração do banco de dados]--------------------------------

connStr ="dbname=dhvre22vp3jak host=ec2-204-236-226-63.compute-1.amazonaws.com user=ucfialmbkbfjnm password=57aM2iSkfa2DZC5Kvy0_YWP66S port=5432"

main::IO()
main = runStdoutLoggingT $ withPostgresqlPool connStr 10 $ \pool -> liftIO $ do 
       runSqlPersistMPool (runMigration migrateAll) pool
       s <- static "static"
       warpEnv (Sitio pool s)