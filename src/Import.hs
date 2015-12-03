{-# LANGUAGE TemplateHaskell, QuasiQuotes #-}
module Import where

import Yesod
import Yesod.Static 

pRoutes = [parseRoutes|

    -- RE
    / InicioR GET 
    /static StaticR Static getStatic
    /login LoginR GET POST
    /bye ByeR GET
    /admin AdminR GET
    /menu   MenuR   GET
    /menuUsuario MenuUsuarioR GET
    /cadastroFilme CadastroFilmeR GET POST
    /cadastroCliente   CadastroClienteR   GET POST
    /listarFilme ListarFilmeR GET
    /listarCliente ListarClienteR GET
    /filme/#FilmeId FilmeR GET
    /cliente/#ClienteId ClienteR GET
    /autor AutorR GET
    /locacao LocacaoR GET POST 
    /locacoes/#ClienteId LocacoesR GET
    /cadastroUsuario   UsuarioR   GET POST
    /listarUser ListUserR GET
    /listarFilmeUsuario ListarFilmeUsuarioR GET
    /autorUsuario AutorUsuarioR GET
    /listarClienteUsuario ListarClienteUsuarioR GET
    /locacaoUsuario LocacaoUsuarioR GET POST 
    /locacoesUsuario/#ClienteId LocacoesUsuarioR GET
    /filmeUsuario/#FilmeId FilmeUsuarioR GET
    /clienteUsuario/#ClienteId ClienteUsuarioR GET
    
    
|]
