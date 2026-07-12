# ✅ CHECKLIST DE IMPLEMENTAÇÃO - MANUTENÇÃO IMPAR v2.0

## 📋 PRÉ-REQUISITOS

- [ ] Windows 10 ou 11 (máquina dedicada)
- [ ] Python 3.9+ instalado
- [ ] Privilégios de administrador
- [ ] Conexão com internet
- [ ] Mínimo 1GB de espaço em disco
- [ ] Task Scheduler acessível

---

## 📥 FASE 1: PREPARAÇÃO (30 minutos)

### 1.1 Backup de v1.0
- [ ] Copiar `C:\Ímpar\Automações\skill_memory.json` para backup local
- [ ] Copiar `C:\Ímpar\manutencao_impar.py` para `manutencao_impar_v1.backup.py`
- [ ] Anotar data e hora do backup
- [ ] Verificar tamanho dos arquivos

```powershell
# Comando para backup
$timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
Copy-Item C:\Ímpar\Automações\skill_memory.json -Destination "C:\Backup\skill_memory_$timestamp.json"
Copy-Item C:\Ímpar\manutencao_impar.py -Destination "C:\Backup\manutencao_impar_v1_$timestamp.py"
```

### 1.2 Download de Arquivos
- [ ] Baixar `manutencao_impar_v2.py`
- [ ] Baixar `MANUTENCAO_IMPAR_V2_MELHORIAS.md`
- [ ] Baixar `GUIA_RAPIDO_V2.txt`
- [ ] Verificar integridade (verificar com antivírus se necessário)

### 1.3 Documentação
- [ ] Ler `GUIA_RAPIDO_V2.txt` completamente
- [ ] Ler `SUMARIO_EXECUTIVO_V2.md` para entender mudanças
- [ ] Consultar `.claude/MANUTENCAO_IMPAR.md` para detalhes técnicos

---

## 🔧 FASE 2: INSTALAÇÃO (45 minutos)

### 2.1 Parar v1.0
- [ ] Abrir PowerShell como **ADMINISTRADOR**
- [ ] Desabilitar Task Scheduler:
  ```powershell
  Disable-ScheduledTask -TaskName "Ímpar_AutomationMonitor"
  ```
- [ ] Aguardar 30 segundos
- [ ] Verificar se processo Python parou:
  ```powershell
  tasklist | findstr python
  ```
- [ ] Confirmar que NÃO há nenhum processo python rodando

### 2.2 Copiar v2.0
- [ ] Copiar `manutencao_impar_v2.py` para `C:\Ímpar\`
- [ ] Renomear para `manutencao_impar.py`:
  ```powershell
  Copy-Item manutencao_impar_v2.py C:\Ímpar\manutencao_impar.py
  ```
- [ ] Verificar que arquivo existe:
  ```powershell
  Get-Item C:\Ímpar\manutencao_impar.py
  ```

### 2.3 Inicializar v2.0
- [ ] Abrir PowerShell como **ADMINISTRADOR**
- [ ] Executar inicialização:
  ```powershell
  cd C:\Ímpar
  python manutencao_impar.py --init
  ```
- [ ] Aguardar conclusão (1-2 minutos)
- [ ] Verificar pastas criadas:
  ```powershell
  Get-Item C:\Ímpar\*
  ```

### 2.4 Testar v2.0
- [ ] Executar testes:
  ```powershell
  python C:\Ímpar\manutencao_impar.py --test
  ```
- [ ] Verificar resultado: **"✅ TODOS OS TESTES PASSARAM!"**
- [ ] Se falhar, revisar `GUIA_RAPIDO_V2.txt` seção "Troubleshooting"
- [ ] Se bloquear, executar:
  ```powershell
  python C:\Ímpar\manutencao_impar.py --reset
  ```

### 2.5 Agendar Task Scheduler
- [ ] Abrir PowerShell como **ADMINISTRADOR**
- [ ] Copiar e executar TODO este bloco:

```powershell
$action = New-ScheduledTaskAction -Execute 'python' -Argument 'C:\Ímpar\manutencao_impar.py'
$trigger = New-ScheduledTaskTrigger -AtStartup
$settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -StartWhenAvailable
Register-ScheduledTask -Action $action -Trigger $trigger -TaskName 'Ímpar_AutomationMonitor' -RunLevel Highest -Settings $settings -Force
```

- [ ] Verificar tarefa foi criada:
  ```powershell
  Get-ScheduledTask -TaskName "Ímpar_AutomationMonitor"
  ```

### 2.6 Iniciar Aplicação (Teste)
- [ ] Sem reiniciar ainda, testar manualmente:
  ```powershell
  python C:\Ímpar\manutencao_impar.py
  ```
- [ ] Aguardar 30 segundos
- [ ] Pressionar `Ctrl+C` para parar
- [ ] Verificar se arquivo `manutencao.log` foi criado:
  ```powershell
  Get-Item C:\Ímpar\Logs\manutencao.log
  ```

---

## 🔍 FASE 3: VALIDAÇÃO (2 horas)

### 3.1 Reiniciar Sistema
- [ ] Abrir PowerShell como **ADMINISTRADOR**
- [ ] Reiniciar computador:
  ```powershell
  Restart-Computer -Force
  ```
- [ ] Aguardar reinicialização completa (2-3 minutos)

### 3.2 Verificar Inicialização Automática
- [ ] Aguardar 2 minutos após reiniciar
- [ ] Abrir PowerShell (não precisa admin agora)
- [ ] Verificar se processo está rodando:
  ```powershell
  tasklist | findstr python
  ```
- [ ] **RESULTADO ESPERADO:** Uma linha com `python.exe` rodando
- [ ] Se não aparecer, verificar `C:\Ímpar\Logs\manutencao.log` para erros

### 3.3 Verificar Logs
- [ ] Abrir arquivo:
  ```powershell
  Get-Content C:\Ímpar\Logs\manutencao.log -Tail 20
  ```
- [ ] Procurar por: `"🟢 Manutenção Impar v2.0 iniciada (MODO REATIVO)"`
- [ ] Se não encontrar, verificar erros nas linhas anteriores

### 3.4 Verificar Memória
- [ ] Abrir arquivo `skill_memory.json`:
  ```powershell
  Get-Content C:\Ímpar\Automações\skill_memory.json -Raw | ConvertFrom-Json | Format-List
  ```
- [ ] Procurar por:
  - ✅ `"version": "2.0"`
  - ✅ `"modo": "reactive"`
  - ✅ `"metricas.taxa_sucesso"` > 0.85
- [ ] Se algum está faltando, executar `--reset` novamente

### 3.5 Monitorar Primeiras 24 Horas
- [ ] A cada 1 hora, verificar logs:
  ```powershell
  Get-Content -Path C:\Ímpar\Logs\manutencao.log -Wait
  # Pressione Ctrl+C para parar
  ```
- [ ] Procurar por erros críticos
- [ ] Se houver error, não é problema (v2.0 tentará reparar automaticamente)

### 3.6 Verificar Após 2-3 Horas
- [ ] Revisar `skill_memory.json`:
  ```powershell
  (Get-Content C:\Ímpar\Automações\skill_memory.json -Raw | ConvertFrom-Json).metricas
  ```
- [ ] Verificar:
  - ✅ `total_execucoes` > 2
  - ✅ `taxa_sucesso` > 0.85 (85%)
  - ✅ `total_reparos_sucesso` > 0 (se houver erros)

---

## 📊 FASE 4: MONITORAMENTO (Semana 1)

### 4.1 Verificações Diárias (5 minutos)
- [ ] **De manhã (08:00)**
  - Verificar se processo está rodando: `tasklist | findstr python`
  - Revisar últimas 50 linhas de log: `Get-Content C:\Ímpar\Logs\manutencao.log -Tail 50`

- [ ] **À tarde (14:00)**
  - Verificar `skill_memory.json` para erros ativos
  - Conferir `taxa_sucesso` (deve estar > 0.90)

- [ ] **À noite (20:00)**
  - Revisar logs do dia inteiro
  - Anotar qualquer padrão de erro

### 4.2 Verificações a Cada 2 Dias
- [ ] Comparar logs com v1.0 (se tiver backup)
- [ ] Verificar se rotinas (NF, WhatsApp, etc) executaram com sucesso
- [ ] Revisar tamanho do arquivo de log (deve ser < 10MB)

### 4.3 Verificações Semanais
- [ ] Calcular taxa média de sucesso
- [ ] Revisar padrões de erro mais frequentes
- [ ] Documentar qualquer comportamento anômalo
- [ ] Gerar relatório simples

```powershell
# Comando para gerar relatório semanal:
$mem = Get-Content C:\Ímpar\Automações\skill_memory.json -Raw | ConvertFrom-Json
Write-Host "=== RELATÓRIO SEMANAL ==="
Write-Host "Taxa de sucesso: $($mem.metricas.taxa_sucesso * 100)%"
Write-Host "Total de erros: $($mem.metricas.total_erros)"
Write-Host "Reparos bem-sucedidos: $($mem.metricas.total_reparos_sucesso)"
Write-Host "Erros ativos agora: $($mem.erros_ativos.Count)"
```

---

## 🆘 TROUBLESHOOTING RÁPIDO

### ❌ Problema: "Processo não inicia após restart"

**Solução (5 minutos):**
```powershell
# 1. Verificar Task Scheduler
Get-ScheduledTask -TaskName "Ímpar_AutomationMonitor"

# 2. Se não aparecer, recriar:
$action = New-ScheduledTaskAction -Execute 'python' -Argument 'C:\Ímpar\manutencao_impar.py'
$trigger = New-ScheduledTaskTrigger -AtStartup
Register-ScheduledTask -Action $action -Trigger $trigger -TaskName 'Ímpar_AutomationMonitor' -RunLevel Highest -Force

# 3. Reiniciar
Restart-Computer -Force
```

### ❌ Problema: "Taxa de sucesso baixa (< 85%)"

**Solução (10 minutos):**
```powershell
# 1. Verificar erros ativos
(Get-Content C:\Ímpar\Automações\skill_memory.json -Raw | ConvertFrom-Json).erros_ativos

# 2. Se houver erro "permissao", executar:
icacls "C:\Ímpar" /grant:f *S-1-1-0:(OI)(CI)F

# 3. Se houver erro "json", resetar memória:
python C:\Ímpar\manutencao_impar.py --reset

# 4. Se houver erro "conectividade", verificar internet:
ping 8.8.8.8
```

### ❌ Problema: "Processo Python consome muita CPU"

**Solução (15 minutos):**
```powershell
# 1. Parar processo
taskkill /F /IM python.exe

# 2. Revisar logs para erro em loop
Get-Content C:\Ímpar\Logs\manutencao.log | Select-String "error"

# 3. Se houver erro em repetição, resetar:
python C:\Ímpar\manutencao_impar.py --reset

# 4. Reiniciar Task
Restart-Computer -Force
```

### ❌ Problema: "Nenhuma mensagem de erro nos logs"

**Solução (3 minutos):**
```
⚠️ NORMAL!
v2.0 é REATIVO = Só loga se há problema
Se não há log, significa tudo está OK!

Para confirmar:
- Ver skill_memory.json
- Verificar "taxa_sucesso" > 0.85
- Confirmar "erros_ativos" vazio ou pequeno
```

---

## ✨ CHECKLIST FINAL

### Antes de Declarar Sucesso

- [ ] Processo rodando automaticamente após restart
- [ ] Arquivo `manutencao.log` existindo
- [ ] `skill_memory.json` com version "2.0"
- [ ] `taxa_sucesso` > 0.85 (85%)
- [ ] Nenhum erro crítico nos logs
- [ ] Tamanho de log < 10MB após 24h
- [ ] Backup de v1.0 salvo seguramente
- [ ] Documentação lida e entendida

---

## 📈 MÉTRICAS ESPERADAS APÓS 1 SEMANA

| Métrica | Esperado | ✅ Sim | ❌ Não |
|---------|----------|--------|--------|
| Taxa sucesso | > 90% | [ ] | [ ] |
| Tokens/dia | < 30k | [ ] | [ ] |
| Uptime | > 99% | [ ] | [ ] |
| Erros detectados | 0-5 | [ ] | [ ] |
| Reparos bem-sucedidos | > 80% | [ ] | [ ] |
| Tempo detecção | < 1 min | [ ] | [ ] |
| Log size/dia | < 2MB | [ ] | [ ] |

---

## 📞 PRÓXIMAS AÇÕES

Após completar este checklist:

1. ✅ Arquivar `CHECKLIST_IMPLEMENTACAO.md` com datas
2. ✅ Manter backup de v1.0 por 30 dias
3. ✅ Revisar logs semanalmente
4. ✅ Documentar qualquer padrão novo de erro
5. ✅ Compartilhar sucessos com equipe

---

**Tempo Total Estimado: 3-4 horas (incluindo monitoramento)**

- Preparação: 30 min
- Instalação: 45 min
- Validação: 2 horas
- Primeira semana: 15-30 min/dia

**Status Inicial: ⏳ PENDENTE**  
**Data de Início: _______________**  
**Data de Conclusão: _______________**  
**Responsável: _______________**

---

Desenvolvido para Ímpar Imóveis © 2025
