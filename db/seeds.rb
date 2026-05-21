# This file should ensure the existence of records required to run the application in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).

admin_email = ENV.fetch("ADMIN_EMAIL", "admin@bidesk.local")
admin_password = ENV["ADMIN_PASSWORD"].presence

if Rails.env.production? && admin_password.blank?
  abort "Defina ADMIN_PASSWORD antes de rodar seeds em produção."
end

admin_password ||= "admin123"

admin = Admin.find_or_initialize_by(email: admin_email)
admin.password = admin_password
admin.save!

unless Rails.env.production?
  puts "Admin configurado para #{admin_email} (senha via ADMIN_PASSWORD ou padrão de desenvolvimento)."
end

# Criar alguns clientes de exemplo
if Cliente.none?
  clientes = [
    { nome: "João Silva", telefone: "(11) 98765-4321", email: "joao@email.com", observacoes: "Cliente frequente" },
    { nome: "Maria Santos", telefone: "(11) 97654-3210", email: "maria@email.com", observacoes: "Prefere mesa 3" },
    { nome: "Pedro Oliveira", telefone: "(11) 96543-2109", email: "pedro@email.com" },
    { nome: "Ana Costa", telefone: "(11) 95432-1098", email: "ana@email.com", observacoes: "Vem aos finais de semana" },
    { nome: "Carlos Pereira", telefone: "(11) 94321-0987", email: "carlos@email.com" }
  ]

  clientes.each { |cliente_data| Cliente.create!(cliente_data) }

  puts "#{clientes.size} clientes criados"
end

# Criar produtos de exemplo
if Produto.none?
  produtos = [
    { nome: "Coca-Cola 350ml", categoria: "Bebidas", quantidade: 50, preco: 5.00, valor_minimo: 10, descricao: "Refrigerante" },
    { nome: "Água Mineral 500ml", categoria: "Bebidas", quantidade: 30, preco: 3.00, valor_minimo: 15, descricao: "Água mineral" },
    { nome: "Cerveja Heineken", categoria: "Bebidas", quantidade: 8, preco: 8.00, valor_minimo: 10, descricao: "Cerveja importada" },
    { nome: "Taco de Bilhar", categoria: "Equipamentos", quantidade: 12, preco: 150.00, valor_minimo: 5, descricao: "Taco profissional" },
    { nome: "Bola de Bilhar", categoria: "Equipamentos", quantidade: 16, preco: 25.00, valor_minimo: 8, descricao: "Conjunto completo" },
    { nome: "Giz para Taco", categoria: "Acessórios", quantidade: 5, preco: 2.50, valor_minimo: 10, descricao: "Giz azul" },
    { nome: "Salgadinhos", categoria: "Alimentos", quantidade: 20, preco: 4.50, valor_minimo: 10, descricao: "Pacote de salgadinhos" }
  ]

  produtos.each { |produto_data| Produto.create!(produto_data) }

  puts "#{produtos.size} produtos criados"
end

# Criar transações financeiras de exemplo
if TransacaoFinanceira.none?
  hoje = Date.current
  transacoes = [
    { tipo: "receita", descricao: "Aluguel de mesas - Dia 1", valor: 250.00, data: hoje - 5.days, categoria: "Aluguel" },
    { tipo: "receita", descricao: "Venda de bebidas", valor: 180.50, data: hoje - 4.days, categoria: "Vendas" },
    { tipo: "receita", descricao: "Aluguel de mesas - Dia 2", valor: 320.00, data: hoje - 3.days, categoria: "Aluguel" },
    { tipo: "despesa", descricao: "Compra de bebidas", valor: 450.00, data: hoje - 7.days, categoria: "Compras" },
    { tipo: "despesa", descricao: "Pagamento de funcionário", valor: 1200.00, data: hoje - 1.day, categoria: "Folha de Pagamento" },
    { tipo: "despesa", descricao: "Conta de luz", valor: 350.00, data: hoje - 10.days, categoria: "Utilidades" },
    { tipo: "receita", descricao: "Venda de bebidas", valor: 220.00, data: hoje - 2.days, categoria: "Vendas" },
    { tipo: "receita", descricao: "Aluguel de mesas - Dia 3", valor: 280.00, data: hoje - 1.day, categoria: "Aluguel" }
  ]

  transacoes.each { |transacao_data| TransacaoFinanceira.create!(transacao_data) }

  puts "#{transacoes.size} transações financeiras criadas"
end

# Criar manutenções de exemplo
if Manutencao.none?
  manutencoes = [
    { equipamento: "Mesa 1", descricao: "Troca de tecido e nivelamento", data: Date.current - 15.days, status: "concluida", custo: 800.00, observacoes: "Manutenção preventiva realizada" },
    { equipamento: "Mesa 2", descricao: "Reparo no sistema de bolsas", data: Date.current - 5.days, status: "pendente", custo: 350.00, observacoes: "Aguardando peças" },
    { equipamento: "Taco 5", descricao: "Troca de ponta", data: Date.current - 2.days, status: "concluida", custo: 25.00 },
    { equipamento: "Mesa 3", descricao: "Revisão geral", data: Date.current + 5.days, status: "pendente", observacoes: "Agendada para próxima semana" },
    { equipamento: "Iluminação", descricao: "Troca de lâmpadas", data: Date.current - 10.days, status: "concluida", custo: 120.00 }
  ]

  manutencoes.each { |manutencao_data| Manutencao.create!(manutencao_data) }

  puts "#{manutencoes.size} manutenções criadas"
end

if ItemManutencao.none? && Manutencao.any? && Produto.any?
  giz = Produto.find_by(nome: "Giz para Taco")
  taco = Produto.find_by(nome: "Taco de Bilhar")
  mesa1 = Manutencao.find_by(equipamento: "Mesa 1")
  mesa2 = Manutencao.find_by(equipamento: "Mesa 2")

  if giz && mesa1
    mesa1.itens_manutencao.create!(produto: giz, quantidade: 2)
  end
  if taco && mesa2
    mesa2.itens_manutencao.create!(produto: taco, quantidade: 1)
  end

  puts "Itens de estoque vinculados às manutenções de exemplo"
end

puts "\n✅ Seeds executados com sucesso!" unless Rails.env.production?
