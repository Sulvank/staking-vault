# 🔐 Staking Vault - ERC20 Token Vault with Receipt Tokens and Early Withdrawal Penalties

## 📝 Overview

**Staking Vault** es un contrato inteligente basado en ERC20 que permite a los usuarios depositar tokens para staking y recibir tokens de recibo (`StakingReceiptToken`) que representan su participación. El contrato incorpora penalizaciones por retiro anticipado, redistribuyendo las penalizaciones entre los stakers activos.

> [!NOTE]
> Este contrato sigue el estándar ERC20 de OpenZeppelin para garantizar seguridad e interoperabilidad.

### 🔹 Características Principales:
- ✅ **Tokens de recibo (`StakingReceiptToken`)** emitidos al depositar tokens para staking.
- ✅ **Penalización por retiro anticipado** configurable.
- ✅ **Redistribución de penalizaciones** entre los stakers activos.
- ✅ **Pausado de operaciones** en situaciones de emergencia.

---

## 🖉 Diagrama de Flujo del Contrato

Este diagrama representa el flujo de operaciones desde la perspectiva del usuario:

![Diagrama de flujo Staking Vault](https://github.com/Sulvank/staking-vault/blob/main/diagrams/staking_vault_flow.png)

---

## ✨ Funcionalidades

### 🏦 Tokens de Recibo (`StakingReceiptToken`)
- Al depositar tokens para staking, se emiten `StakingReceiptToken` al usuario.
- Los `StakingReceiptToken` representan la participación del usuario en el staking y son necesarios para retirar los tokens originales.

### ⏳ Penalización por Retiro Anticipado
- Si un usuario retira sus tokens antes del período mínimo de staking, se aplica una penalización (por ejemplo, 5% del monto retirado).
- El monto penalizado se redistribuye entre los stakers activos proporcionalmente a su participación.

### 🔄 Redistribución de Penalizaciones
- Las penalizaciones acumuladas se distribuyen entre los stakers activos.
- La distribución se realiza proporcionalmente a la cantidad de `StakingReceiptToken` que posee cada staker.

### 🚫 Pausado de Operaciones
- El propietario del contrato puede pausar y reanudar las operaciones de staking y retiro en situaciones de emergencia.

> [!IMPORTANT]
> El propietario del contrato tiene privilegios administrativos para gestionar las penalizaciones, pausar operaciones y distribuir recompensas.

---

## 📖 Resumen del Contrato

### Funciones Principales

| 🔧 Nombre de la Función             | 📋 Descripción                                                                 |
|------------------------------------|-------------------------------------------------------------------------------|
| `depositTokens(uint256 amount)`    | Deposita una cantidad fija de tokens y emite `StakingReceiptToken`.         |
| `withdrawTokens()`                 | Retira tokens del staking, aplica penalización si es antes del tiempo mínimo. |
| `distributeFees()`                 | Distribuye las penalizaciones acumuladas entre los stakers activos.          |
| `claimRewards()`                   | Permite reclamar recompensas si ha pasado el período de staking.            |
| `pause()`                          | Pausa todas las operaciones del contrato (solo propietario).                 |
| `unpause()`                        | Reanuda las operaciones del contrato (solo propietario).                     |
| `changeStakingPeriod(uint256)`     | Cambia el período de staking (solo propietario).                             |
| `updateEarlyWithdrawalPenalty(uint256)` | Cambia la penalización por retiro anticipado (solo propietario).     |

---

## ⚙️ Requisitos Previos

### 🛠️ Herramientas Necesarias:
- 🖥️ **Remix IDE**: Para desplegar e interactuar con el contrato ([Remix IDE](https://remix.ethereum.org)).
- **Metamask Wallet**: Para interactuar con la blockchain.

### 🌐 Entorno:
- Versión del compilador Solidity: `0.8.x`.
- Red: Blockchain local (JavaScript VM) o testnets como Goerli.

> [!TIP]
> Siempre prueba tu contrato en una testnet antes de desplegarlo en la mainnet.

---

## 🚀 Cómo Usar el Contrato

### 1️⃣ Desplegar el Contrato

1. Abre [Remix IDE](https://remix.ethereum.org).
2. Crea un nuevo archivo llamado `StakingApp.sol` y otro para `StakingReceiptToken.sol`. Copia el código del contrato.
3. Navega a la pestaña **Solidity Compiler**:
   - Selecciona la versión del compilador `0.8.x`.
   - Haz clic en **✅ Compile StakingApp.sol**.
4. Ve a la pestaña **🛠️ Deploy & Run Transactions**:
   - Selecciona **Environment** como `Injected Web3` si usas MetaMask.
   - Despliega el contrato haciendo clic en **🚀 Deploy**.

### 2️⃣ Usar el Contrato en Remix

#### 💰 A. Depositar Tokens para Staking
1. Llama a `depositTokens(uint256 amount)`.
2. Se emitirán `StakingReceiptToken` equivalentes a la cantidad depositada.

#### 🔓 B. Retirar Tokens del Staking
1. Llama a `withdrawTokens()`.
2. Si el retiro es antes del tiempo mínimo, se aplicará una penalización.

#### 🏱 C. Reclamar Recompensas
1. Llama a `claimRewards()` una vez finalizado el tiempo de staking.

#### ❌ D. Pausar y Reanudar Operaciones
1. Llama a `pause()` para detener todas las operaciones.
2. Llama a `unpause()` para reanudar las operaciones.

> [!WARNING]
> Solo el propietario del contrato puede pausar operaciones y gestionar las penalizaciones.

---

## 🛠️ Extensiones del Contrato

### 🔍 Posibles Mejoras
- 📈 **Integración con Oráculos**: Para ajustar dinámicamente las penalizaciones según condiciones del mercado.
- ⛏️ **Mecanismo de Recompensas**: Implementar recompensas adicionales para los stakers a largo plazo.
- 📊 **Gobernanza DAO**: Permitir votaciones comunitarias sobre parámetros del contrato.
- 🔗 **Puente Cross-Chain**: Habilitar transferencias de tokens entre diferentes blockchains.

> [!CAUTION]
> Asegúrate de realizar pruebas y auditorías exhaustivas antes de agregar nuevas funcionalidades a un contrato en producción.

---

## 📜 Licencia

Este proyecto está licenciado bajo la licencia MIT. Consulta el archivo LICENSE para más detalles.

---

### 🚀 **Staking Vault: Optimiza tus inversiones con seguridad y eficiencia.**

