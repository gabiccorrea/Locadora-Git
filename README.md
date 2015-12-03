# Locadora-Git

Usuários para teste:
admin - 123456
usuario - usuario 


	O site "Locadora Haskell" possui o objetivo de  realizar locações de filmes, podendo cadastrar e listar Filmes e Clientes.
	Este site será iniciado com a tela de Login, onde o usuário deverá inserir o login e senha correspondentes, se obtiver permissão, será direcionado para a tela principal (/menu), onde o usuário poderá navegar pelos menus, de acordo com sua permissão de usuário.
	
	>> Acesso pelo login: admin <<
	
	Menu: Inicio -> Rota:/menu
	Esta rota permitirá que o usuário navegue por todas as páginas deste site, através do Menu na barra superior, além de permitir que o usuário deslogue através do Menu "Sair".
	
	Menu: Cadastro de Usuários -> Rota:/cadastroUsuario
	Esta rota permitirá que o usuário cadastre novos login e senha de usuário no site. 

	Menu: Usuários -> Rota:/listarUser
	Esta rota permitirá que o usuário visualize todos os usuários cadastrados. 
	
	Menu: Cadastro de Cliente -> Rota:/cadastroCliente
	Esta rota permitirá que o usuário cadastre novos clientes no site. 
	
	Menu: Cadastro de Filmes -> Rota:/cadastroFilme
	Esta rota permitirá que o usuário cadastre novos filmes no site. 
		
	Menu: Realizar Locacao -> Rota:/locacao
	Esta rota permitirá que o usuário cadastre novas locações de filmes no site. 
	
	-> Rota:/locacoes/#ClienteId
	Esta rota exibirá as locações desse cliente que foi selecionado.
		
	Menu: Listar Filmes -> Rota:/listarFilme
	Esta rota permitirá que o usuário visualize uma lista de filmes já cadastrados. 
		
		-> Rota:/filme/#FilmeId
	Esta rota permitirá que o usuário visualize os detalhes de um filme selecionado, na página "Listar Filmes".
	
	Menu: Listar Clientes -> Rota:/listarCliente
	Esta rota permitirá que o usuário visualize uma lista de clientes já cadastrados. 
	
		-> Rota:/cliente/#ClienteId
	Esta rota permitirá que o usuário visualize os detalhes de um cliente selecionado, na página "Listar Clientes" e cadastrar uma nova locação de filme para o usuário selecionado em "Locacoes".
	
	Menu: Sobre -> Rota:/autor
	Esta rota permitirá que o usuário visualize os autores deste site.
	
	Menu: Sair 
	Esta opção permitirá que o usuário deslogue do site, retornando para a tela de login.
	
		>> Acesso pelo login: ___ <<
		
	O usuário terá acesso ao Menu (/menuUsuario) com apenas alguns menus visíveis para o usuário, como "Inicio" (/menuUsuario), "Listar Filmes" (/listarFilmeUsuario), "Listar Clientes (/listarClienteUsuario)", "Realizar Locacao" (/locacaoUsuario), "Sobre (/autorUsuario)" e "Sair". 
	
	Rotas: 
	--> /locacoesUsuario/#ClienteId    --> Lista as locações de um usuário específico.
  --> /filmeUsuario/#FilmeId         --> O usuário visualiza os detalhes de um filme.
  --> /clienteUsuario/#ClienteId     --> O usuário visualiza os dados de um cliente.
	 
