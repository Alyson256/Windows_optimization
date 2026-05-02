<div align="center">

# 🪟 win-optimizer — Documentação PT-BR

**Scripts de otimização pós-instalação para Windows 11 — seguros, documentados e reversíveis.**

</div>

---

## O que é isso?

Uma coleção de scripts `.bat` (com PowerShell inline para operações de sistema) para deixar uma instalação limpa do Windows 11 mais rápida, silenciosa e privativa — **sem tocar em nada que quebre o sistema**.

---

## Início Rápido

> **Requisitos:** Windows 11, privilégios de Administrador.

```batch
git clone https://github.com/SEU_USUARIO/win-optimizer.git
cd win-optimizer\scripts

:: Clique com o botão direito > Executar como Administrador
00_run_all.bat
```

Cada script também pode ser executado individualmente.

---

## O que cada script faz

| Script | O que faz |
|--------|-----------|
| `01_restore_point` | Cria um ponto de restauração com timestamp antes de qualquer mudança |
| `02_services_manual` | Serviços não essenciais → Manual (não Desabilitado) |
| `03_disable_recall` | Desativa o Windows Recall (capturas de tela por IA) |
| `04_disable_telemetry` | Reduz telemetria ao mínimo, para DiagTrack |
| `05_power_plan` | Ativa Plano de Alto Desempenho, desativa Fast Startup |
| `06_visual_tweaks` | Remove animações e transparência (mantém ClearType) |
| `07_network_tweaks` | Desativa algoritmo de Nagle, ajusta stack TCP |
| `08_privacy_tweaks` | Desativa ID de publicidade, histórico de atividade, Cortana |
| `09_startup_cleanup` | Auditoria de itens de inicialização (somente leitura) |
| `10_undo_all` | Reverte TUDO para os padrões do Windows |
| `check_status` | Relatório do estado atual (somente leitura, sem mudanças) |

---

## O que NÃO é modificado

Para evitar qualquer risco de quebrar o sistema:

- ❌ Arquivo `hosts` não é modificado
- ❌ Windows Defender não é alterado
- ❌ Windows Update não é bloqueado
- ❌ Drivers de hardware não são tocados
- ❌ Overclock não é realizado

---

## Revertendo

Execute `10_undo_all.bat` como Administrador para restaurar todas as configurações padrão do Windows.
Ou use o ponto de restauração criado no passo 01 via `rstrui.exe`.

---

## Riscos

Documentação técnica completa de riscos em inglês: [RISKS.md](RISKS.md)

---

## Licença

MIT — veja [LICENSE](../LICENSE).
