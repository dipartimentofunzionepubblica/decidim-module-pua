# Decidim PUA
Autenticazione PUA per Decidim v0.25.2. Questa gemma si appoggia: [openid_connect](https://github.com/nov/openid_connect), [decidim](https://github.com/decidim/decidim/tree/v0.25.2) e [omniauth_openid_connect](https://github.com/omniauth/omniauth_openid_connect).

Ispirata a [decidim-msad](https://github.com/mainio/decidim-module-msad).

## Installazione
Aggiungi al tuo Gemfile

```ruby
gem 'decidim-pua'
```

ed esegui dal terminale
```bash
$ bundle install
$ bundle exec rails generate decidim:pua:install TENANT_NAME ISSUER RELYING_PARTY
# Ripetere l'installer per ogni tenant di cui si ha bisogno.
```
Sostituire TENANT_NAME con una stringa univoca che identifica il tenant, ISSUER con un endpoint (https://www.example.org) del provider OpenID Connect PUA e RELYING_PARTY (https://www.mytenantdomain.org).

Verranno generati:
1. `config/initializers/decidim-pua-#{tenant_name}.rb` per configurare PUA ad ogni installazione.
2 verrà automaticamente aggiunto in `config/secrets.yml` nel blocco default la configurazione `omniauth` necessaria. Aggiungere la configurazione ai vari environment a seconda delle esigenze.
3`config/locales/pua-#{tenant_name}.en.yml` con le etichette necessarie. Duplicare per ogni locale necessaria.

## Configurazione
Associare nel pannello di amministratore di sistema (/system) il `tenant_name` ad ogni organizzazione.
Completare le configurazioni nell'`initializer` di ogni tenant.

```ruby
# config/initializers/decidim-pua-#{tenant_name}.rb
Decidim::Pua.configure do |config|
  #config ...
end
```
tramite il quale potete accedere alle seguenti configurazioni:


## Contributori
Gem sviluppata da [Kapusons](https://www.kapusons.it) per [Formez PA](https://www.formez.it). Per contatti scrivere a maintainer-partecipa@formez.it.

## Segnalazioni sulla sicurezza
La gem utilizza tutte le raccomandazioni e le prescrizioni in materia di sicurezza previste da Decidim e dall’Agenzia per l’Italia Digitale per SPID. Per segnalazioni su possibili falle nella sicurezza del software riscontrate durante l'utilizzo preghiamo di usare il canale di comunicazione confidenziale attraverso l'indirizzo email security-partecipa@formez.it e non aprire segnalazioni pubbliche. E' indispensabile contestualizzare e dettagliare con la massima precisione le segnalazioni. Le segnalazioni anonime o non sufficientemente dettagliate non potranno essere verificate.


## Licenza
Vedi [LICENSE-AGPLv3.txt](LICENSE-AGPLv3.txt).