# Decidim PUA
Autenticazione PUA per Decidim v0.25.2. Questa gemma si appoggia a: [openid_connect](https://github.com/nov/openid_connect), [decidim](https://github.com/decidim/decidim/tree/v0.25.2) e [omniauth_openid_connect](https://github.com/omniauth/omniauth_openid_connect).

Ispirata a [decidim-msad](https://github.com/mainio/decidim-module-msad).

## Prerequisiti

Il PUA (Punto Unico di Accesso) funge da Gateway OpenID Connect per il Single Sign-on di Service Provider attraverso SPID, CIE e CNS. L'accreditamento al PUA da parte del Dipartimento Funzione Pubblica è indispensabile al suo utilizzo e subordinato a verifica del Dipartimento stesso. Sono accreditati al PUA siti che sono direttamente o indirettamente afferenti al Dipartimento stesso, non possono essere accreditati al PUA siti che non hanno collegamento col Dipartimento Funzione Pubblica.

## Installazione
Aggiungi al tuo Gemfile

```ruby
gem 'decidim-pua'
```

ed esegui dal terminale
```bash
$ bundle install
$ bundle exec rails generate decidim:pua:install TENANT_NAME ISSUER RELYING_PARTY
$ bundle exec rake assets:precompile
# Ripetere l'installer per ogni tenant di cui si ha bisogno.
```
Sostituire TENANT_NAME con una stringa univoca che identifica il tenant, ISSUER con un endpoint (https://www.example.org) del provider OpenID Connect PUA e RELYING_PARTY (https://www.mytenantdomain.org).

Verranno generati:
1. `config/initializers/decidim-pua-#{tenant_name}.rb` per configurare PUA ad ogni installazione.
2. verrà automaticamente aggiunto in `config/secrets.yml` nel blocco default la configurazione `omniauth` necessaria. Aggiungere la configurazione ai vari environment a seconda delle esigenze.
3. `config/locales/pua-#{tenant_name}.en.yml` con le etichette necessarie. Duplicare per ogni locale necessaria.

## Configurazione
Associare nel pannello di amministratore di sistema (/system) il `tenant_name` ad ogni organizzazione.
Dopo l'associazione nella form saranno visibili le URL generate da comunicare in fase di accreditamento.
Completare le configurazioni nell'`initializer` di ogni tenant.

```ruby
# config/initializers/decidim-pua-#{tenant_name}.rb
Decidim::Pua.configure do |config|
  #config ...
end
```
tramite il quale potete accedere alle seguenti configurazioni:

|Nome| Valore di default                                                                                                                                                                                                                                     | Descrizione                                                                                                                                                     |Obbligatorio|
|:---|:------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|:----------------------------------------------------------------------------------------------------------------------------------------------------------------|:---|
|config.name| `'#{tenant_name}'`                                                                                                                                                                                                                                    | Identificativo univoco di ogni tenant.                                                                                                                          |✓|
|config.issuer| `'#{issuer}'`                                                                                                                                                                                                                                         | Identificativo univoco (URI) dell'entità PUA                                                                                                                    |✓|
|config.relying_party| `'#{relying_party}'`                                                                                                                                                                                                                                  | Root URL del relying_party. Es: https://mytenantdomain.org                                                                                                      |✓|
|config.uid_field| `:sub`                                                                                                                                                                                                                                                | Attributo da utilizzare come identificato in omniauth come chiave univoca per identificare gli utenti                                                           |✓|
|config.scope| `%i[openid profile email providername providersubject]`                                                                                                                                                                                                                           | Definisce lo scope da utlizzare. "providername" e "providersubject" sono necessari se si sta migrando da un'autenticazione SPID personalizzata                  |✓|
|config.app_id| `myapp`                                                                                                                                                                                                                                               | APP ID rilasciato in fase di accreditamento dal Dipartimento Funzione Pubblica                                                                                                                     |✓|
|config.app_secret| `mysecret`                                                                                                                                                                                                                                            | APP SECRET rilasciato in fase di accreditamento dal Dipartimento Funzione Pubblica                                                                                                                |✓|
|config.attributes| `{ name: "given_name", surname: "family_name", fiscal_code: 'nickname', gender: 'gender', birthdate: 'birthdate', phone_number: 'phone_number', email: 'email', address: 'address',providername: 'providername',providersubject: 'providersubject' }` | Attibuti che verranno salvati all'autenticazione con relativo mapping                                                                                           ||
|config.export_exclude_attributes| `'[ :name, :surname, :fiscal_code, :company_name, :gender, :email, :birthdate ]'`                                                                                                                                                                     | In amministrazione (/admin) viene aggiunta la funzionalità di export per ogni processo. Questo attributo permette di escludere i campi nell'export per il GDPR. ||


## Contributori
Gem sviluppata da [Kapusons](https://www.kapusons.it) per [Formez PA](https://www.formez.it). Per contatti scrivere a maintainer-partecipa@formez.it.

## Segnalazioni sulla sicurezza
La gem utilizza tutte le raccomandazioni e le prescrizioni in materia di sicurezza previste da Decidim e dall’Agenzia per l’Italia Digitale. Per segnalazioni su possibili falle nella sicurezza del software riscontrate durante l'utilizzo preghiamo di usare il canale di comunicazione confidenziale attraverso l'indirizzo email security-partecipa@formez.it e non aprire segnalazioni pubbliche. E' indispensabile contestualizzare e dettagliare con la massima precisione le segnalazioni. Le segnalazioni anonime o non sufficientemente dettagliate non potranno essere verificate.


## Licenza
Vedi [LICENSE-AGPLv3.txt](LICENSE-AGPLv3.txt).