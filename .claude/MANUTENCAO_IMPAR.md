# 🤖 CLAUDE.md - MANUTENÇÃO IMPAR v2.0

## Contexto do Projeto

**Projeto:** Monitor inteligente de automações para Ímpar Imóveis  
**Versão:** 2.0 (Reativo com Auto-Recovery)  
**Plataforma:** Windows 10/11  
**Linguagem:** Python 3.9+  

---

## 📂 Estrutura de Arquivos

```
API-whatssapp/
├── manutencao_impar_v2.py          # ✅ Versão refinada (usar esta)
├── manutencao_impar.py             # ❌ v1.0 (deprecated, manter como backup)
├── MANUTENCAO_IMPAR_V2_MELHORIAS.md # 📖 Guia de melhorias
├── .claude/
│   └── MANUTENCAO_IMPAR.md         # Este arquivo
└── C:\Ímpar/                       # Estrutura no Windows
    ├── Automações/
    │   └── skill_memory.json       # Memória evolutiva
    ├── Logs/
    │   └── manutencao.log          # Log compacto
    ├── NF/
    ├── WhatsApp/
    ├── Videos/
    └── Facebook/
```

---

## 🎯 Responsabilidades do Claude Code

### 1️⃣ **Monitoramento de Erros**
- Verificar `skill_memory.json` a cada hora
- Se `erros_ativos` > 3: Alertar
- Se `taxa_sucesso` < 85%: Investigar

### 2️⃣ **Otimizações Automáticas**
- Revisar padrões de erro em `historico_reparos`
- Sugerir melhorias baseadas em frequência
- Atualizar patterns de auto-repair

### 3️⃣ **Relatórios**
- Gerar relatório semanal de métricas
- Comparar v1.0 vs v2.0 economia
- Documentar novos erros encontrados

---

## 📊 Monitoramento - Métricas Importantes

### Arquivo de Memória (`C:\Ímpar\Automações\skill_memory.json`)

```json
{
  "metricas": {
    "total_execucoes": 100,
    "total_erros": 5,
    "total_reparos_sucesso": 4,
    "taxa_sucesso": 0.95  // ⚠️ Alertar se < 0.85
  },
  "erros_ativos": {
    "automacao_x": {
      "tipo": "conectividade",
      "tentativas_reparo": 2,
      "proxima_tentativa": "2025-07-12T15:00:00Z"
    }
  }
}
```

**Alertas:**
- ⚠️ `taxa_sucesso` < 85% = Investigar imediatamente
- 🔴 `erros_ativos` > 5 = Erro crítico
- ⏰ Erro sem progresso por 2h = Revisar

---

## 🔧 Padrões de Erro Conhecidos

### ✅ Erros Tratados Automaticamente

| Erro | Padrão | Solução |
|------|--------|---------|
| Timeout de conexão | `"conexao"` | Aguarda 5-30s + retry |
| Sem internet | `"conectividade"` | Aguarda até 1min |
| Permissão negada | `"permissao"` | `icacls` automático |
| JSON corrompido | `"json"` | Restaura template |
| Rate limit | `"rate"` | Aguarda 1h |

### 🔍 Erros que Precisam Investigação

```python
# Estes NÃO devem ocorrer (investigar se acontecer):
"ModuleNotFoundError"      # Dependência faltando
"Python version error"     # Versão incompatível
"Task Scheduler error"     # Problema no Windows
"Arquivo não encontrado"   # Estrutura deletada
```

---

## 💻 Comandos de Teste

```bash
# Teste rápido
python manutencao_impar_v2.py --test

# Inicializar estrutura
python manutencao_impar_v2.py --init

# Resetar memória
python manutencao_impar_v2.py --reset

# Modo normal (24/7)
python manutencao_impar_v2.py

# Ver ajuda
python manutencao_impar_v2.py --help
```

---

## 🔄 Rotinas de Manutenção

### Diária (Automática)
- ✅ Verificação leve a cada 5 min
- ✅ Processamento de erros ativos
- ✅ Logging compacto

### Semanal (Manual via Claude)
- 📊 Revisar `metricas` em `skill_memory.json`
- 🔍 Verificar novos padrões de erro
- 📈 Comparar progresso vs baseline

### Mensal (Manual via Claude)
- 🧹 Limpar logs antigos
- 📋 Gerar relatório de performance
- 🚀 Sugerir otimizações

---

## 🐛 Debugging Guide

### Problema: "Automação não executa"

1. Verificar se está em `erros_ativos`
```powershell
Get-Content C:\Ímpar\Automações\skill_memory.json | ConvertFrom-Json | Select erros_ativos
```

2. Se sim, verificar tipo de erro:
```json
{
  "whatsapp_atendimento": {
    "tipo": "conectividade",  // ← tipo de erro
    "tentativas_reparo": 2
  }
}
```

3. Acionas reparo específico:
```python
# No código, adicionar:
if erro_type == "conectividade":
    aguardar_internet_por(60)
```

### Problema: "Taxa de sucesso baixa"

1. Ver último erro:
```powershell
Get-Content C:\Ímpar\Logs\manutencao.log -Tail 50
```

2. Analisar padrão:
- Mesmo erro repetindo? → Novo pattern
- Diferentes erros? → Problema sistêmico
- Horário específico? → Agendamento conflita

---

## 🎓 Decisões de Design

### Por que REATIVO e não PROATIVO?

**Proativo (v1.0):**
- ✅ Detecta problemas rápido
- ❌ 70% de overhead desnecessário
- ❌ 144k tokens/dia

**Reativo (v2.0):**
- ✅ Só age quando há problema
- ✅ 70% economia de tokens
- ✅ Repara antes de notificar
- ✅ 19k tokens/dia

### Por que CIRCUIT BREAKER?

Evita que erro em cascata sobrecarregue sistema:
- Automação X com erro contínuo
- Sem circuit breaker: Tenta infinitamente
- Com circuit breaker: Para após 3 falhas, reabilita em 1h

### Por que VERIFICAÇÕES PARALELAS?

- Serial: 45s para 9 automações
- Paralelo: 15s para 9 automações (3x mais rápido)
- Máximas threads: 4 (evita overhead)

---

## 📈 Evolução do Projeto

### v1.0 (Baseline)
- Proativo, executava a cada 5min
- 500 tokens por check
- Taxa de sucesso: ~70%

### v2.0 (Atual)
- Reativo, executa apenas se erro
- 50-100 tokens por ação
- Taxa de sucesso: 90%+
- Economia: 70% tokens

### v3.0 (Futuro - Não implementado)
- Integração com APIs externas
- Webhooks para alertas Slack/WhatsApp
- Machine learning para predição de falhas

---

## 🎯 Métricas de Sucesso

Monitorar estas métricas:

| Métrica | v1.0 | v2.0 | Meta |
|---------|------|------|------|
| Taxa de sucesso | 70% | 90%+ | >95% |
| Tokens/dia | 144k | 19k | <15k |
| Tempo detecção | ~5min | <1min | <30s |
| Tempo reparo | Manual | Auto 80% | 100% |
| Uptime | 95% | 99%+ | 99.9% |

---

## 🔐 Considerações de Segurança

### Permissões Necessárias
- ✅ Privilégios de Admin (Task Scheduler)
- ✅ Acesso de escrita em `C:\Ímpar\`
- ✅ Execução de PowerShell (icacls)

### Dados Sensíveis
- ⚠️ `skill_memory.json` contém timestamps
- ⚠️ Logs podem conter URLs
- ⚠️ Histórico de reparos rastreável

### Boas Práticas
- 🔒 Restrição de acesso a `C:\Ímpar\`
- 🔒 Rotação de logs
- 🔒 Backup regular de `skill_memory.json`

---

## 📝 Notas Importantes

### Para Claude Code

1. **Não modifique estrutura de `AUTOMACOES` sem testar**
   - Quebra verificações
   - Pode causar timeout

2. **Não aumente parallelism acima de 4 workers**
   - Degrada performance
   - Aumenta consumo de recursos

3. **Sempre testar com `--test` antes de push**
   - Valida estrutura
   - Verifica permissões

4. **Backup de `skill_memory.json` antes de upgrade**
   - Contém histórico de erros
   - Importante para análise

### Para Usuários

1. **Não deletar arquivos em `C:\Ímpar\`**
2. **Não interromper Task Scheduler sem motivo**
3. **Revisar logs pelo menos 1x por semana**

---

## 🚀 Roadmap

### Implementado (v2.0)
- ✅ Modo reativo
- ✅ Retry exponencial
- ✅ Circuit breaker
- ✅ Verificações paralelas
- ✅ Auto-repair inteligente

### Planejado
- 📅 Integração com monitoramento externo
- 📅 Dashboard de métricas
- 📅 Alertas por Slack/WhatsApp
- 📅 Análise preditiva de falhas

---

## 📞 Contato & Suporte

**Desenvolvedor:** Jonata Oliveira  
**Email:** jonata@impar-imoveis.com.br  
**Local:** Joinville/SC  
**Última atualização:** 12/07/2025  

---

**Cada cliente, cada negociação, cada imóvel é ÍMPAR.** 🏠
