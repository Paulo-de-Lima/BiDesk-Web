require "test_helper"

class ClientesControllerTest < ActionDispatch::IntegrationTest
  setup do
  end

  test "destroy stores undo and undo_destroy restores cliente" do
    post login_path, params: { email: admins(:one).email, password: "password123" }

    cliente = Cliente.create!(nome: "Teste Undo", telefone: "11999999999", email: "undo@test.com")
    cliente.mesas_de_bilhar.create!(numeracao: "M1", ordem: 1, registros: 23_109)

    assert_difference -> { Cliente.count }, -1 do
      delete cliente_path(cliente)
    end
    assert_redirected_to clientes_path
    follow_redirect!
    assert_select "button", text: "Desfazer"

    assert_difference -> { Cliente.count }, 1 do
      post undo_destroy_clientes_path
    end
    assert_redirected_to clientes_path
    follow_redirect!
    assert_match(/desfeita/i, response.body)

    restored = Cliente.find_by(email: "undo@test.com")
    assert restored
    assert_equal 1, restored.mesas_de_bilhar.count
  end
end
