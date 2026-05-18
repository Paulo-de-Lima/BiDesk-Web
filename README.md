# BiDesk-Web

Sistema de gestão para empresas de bilhar (Rails 8, PostgreSQL, Tailwind CSS).

## Requisitos

- Ruby 3.x
- PostgreSQL
- Node não é obrigatório (Tailwind via `tailwindcss-rails`)

## Setup

```bash
bundle install
bin/rails db:setup
bin/rails tailwindcss:build
```

### Credenciais

- `config/credentials.yml.enc` fica no repositório.
- `config/master.key` é **local** (não versionar). Gere com `bin/rails credentials:edit` se necessário.

### Admin inicial (seeds)

```bash
ADMIN_EMAIL=admin@bidesk.local ADMIN_PASSWORD='sua-senha-segura' bin/rails db:seed
```

Em desenvolvimento, sem variáveis, usa e-mail padrão e senha de dev (não use em produção).

## Desenvolvimento

```bash
bin/dev
```

Sobe o servidor Rails e `tailwindcss:watch` (via Foreman, se instalado, ou em paralelo).

Sem `bin/dev`, em dois terminais:

```bash
bin/rails tailwindcss:watch
bin/rails server
```

Após alterar classes em views, rode:

```bash
bin/rails tailwindcss:build
```

## Testes e CI

```bash
bin/ci
```

Ou manualmente: `bin/rubocop`, `bin/brakeman`, `bin/rails test`.

## Segurança

- Rotacione credenciais se `master.key` já foi exposto no Git.
- Em produção, defina `ADMIN_PASSWORD` e nunca commite `config/master.key`.
