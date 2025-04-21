# **StakingApp - Fixed Amount ERC20 Staking with ETH Rewards**

## **📝 Overview**

**StakingApp** es un contrato inteligente que permite a los usuarios hacer staking de una cantidad fija de tokens ERC20 a cambio de recompensas en ETH, entregadas tras un periodo definido. Está diseñado para aceptar solo un depósito por usuario y asegurar transparencia en el reparto de recompensas.

> [!NOTE]\
> Construido usando contratos de OpenZeppelin para mejorar la seguridad y extensibilidad.

### **🔹 Características Principales:**

- ✅ **Cantidad fija de staking por usuario**.
- ✅ **Periodo de bloqueo configurado** y automáticamente gestionado.
- ✅ **Recompensas en ETH** tras finalizar el periodo de staking.
- ✅ **Parámetros controlados por el propietario**.
- ✅ **Depósito único por usuario** para mayor simplicidad y seguridad.

---

## **✨ Funcionalidades**

### **📥 Depósito Fijo de Tokens**

- Los usuarios solo pueden depositar la cantidad predeterminada.
- No se permiten múltiples depósitos por usuario simultáneamente.

### **⏱️ Bloqueo Temporal**

- Las recompensas están bloqueadas durante un tiempo definido.
- Solo se pueden reclamar recompensas tras finalizar el periodo.

### **💸 Recompensas en ETH**

- Los usuarios reciben recompensas en ETH, no en el token depositado.
- El contrato debe ser previamente financiado por el propietario.

### **👨‍✈️ Controles de Administración**

- El propietario puede modificar el tiempo de staking.
- Solo el propietario puede depositar ETH en el contrato.

> [!IMPORTANT]\
> Este contrato sigue el patrón Checks-Effects-Interactions (CEI) para prevenir ataques de reentrancia.

---

## **📖 Resumen del Contrato**

### **Variables Clave**

| Variable              | Descripción                                      |
| --------------------- | ------------------------------------------------ |
| `stakingToken`        | Dirección del token ERC20 aceptado para staking. |
| `stakingPeriod`       | Tiempo de bloqueo en segundos.                   |
| `fixedStackingAmount` | Cantidad fija que cada usuario debe depositar.   |
| `rewardPerPeriod`     | Recompensa en ETH por periodo de staking.        |
| `userBalance`         | Registro de tokens depositados por cada usuario. |
| `elapsePeriod`        | Timestamp del último depósito de cada usuario.   |

### **Funciones Clave**

| 🔧 Nombre de la Funcíon        | 📋 Descripción                                                     |
| ------------------------------ | ------------------------------------------------------------------ |
| `depositTokens(uint256)`       | Deposita tokens (solo si el usuario no ha depositado antes).       |
| `withdrawTokens()`             | Permite retirar los tokens en cualquier momento.                   |
| `claimRewards()`               | Reclama recompensas en ETH si el periodo de staking ha finalizado. |
| `changeStakingPeriod(uint256)` | Solo admin: Actualiza el tiempo de bloqueo requerido.              |
| `receive()`                    | Solo admin: Permite al contrato recibir ETH.                       |

---

## **⚙️ Prerrequisitos**

### **🛠️ Herramientas Requeridas:**

- **Foundry**: Para compilar y testear el contrato ([Foundry Docs](https://book.getfoundry.sh)).
- **Metamask**: Para interactuar con el contrato desplegado.

### **🌐 Entorno:**

- Versión de Solidity: `0.8.28`
- Compatible con blockchains locales y testnets de Ethereum.

> [!TIP]\
> Usa `forge test` para ejecutar las pruebas unitarias localmente.

---

## **🚀 Cómo Usar el Contrato**

### **1️⃣ Despliegue**

```bash
git clone https://github.com/your-username/staking-app.git
cd staking-app
forge install
forge build
```

**Parámetros Requeridos:**

- `stakingToken`: Dirección del token ERC20.
- `owner`: Dirección del administrador.
- `stakingPeriod`: Duración del staking en segundos.
- `fixedStakingAmount`: Cantidad fija de tokens.
- `rewardPerPeriod`: Recompensa en ETH por usuario.

### **2️⃣ Interacción**

#### **📥 A. Depositar Tokens**

```solidity
stakingApp.depositTokens(10); // Debe coincidir con fixedStackingAmount
```

- El usuario debe haber aprobado previamente el contrato para gastar sus tokens.

#### **📤 B. Retirar Tokens**

```solidity
stakingApp.withdrawTokens();
```

- Retira los tokens depositados y resetea el estado del usuario.

#### **🎁 C. Reclamar Recompensas**

```solidity
stakingApp.claimRewards();
```

- Solo se puede llamar tras finalizar el periodo de bloqueo.

#### **🛠️ D. Funciones de Administrador**

```solidity
stakingApp.changeStakingPeriod(newPeriod);

// Enviar ETH al contrato para recompensas
(bool success, ) = address(stakingApp).call{value: 100 ether}("");
```

> [!WARNING]\
> Si el contrato no tiene ETH suficiente, la función `claimRewards` revertirá con "Transfer failed."

---

## **🧪 Cobertura de Tests**

### **✅ StakingTokenTest**

- Mint de tokens correctamente para usuarios.

### **✅ StakingAppTest**

- Despliegue correcto de contratos.
- Restricciones para funciones de administrador.
- Depósitos de ETH y actualización de balances.
- Depósito de tokens y verificación de unicidad.
- Retiro de tokens y actualización de estados.
- Lógica de recompensas con control de tiempo.
- Validación de condiciones incorrectas: sin depósito, retiro anticipado, falta de ETH.

```bash
forge test -vv
```

---

## **📜 Licencia**

Este proyecto está licenciado bajo la licencia MIT.

---

### 🚀 **StakingApp — Stake ERC20. Earn ETH. Securely.**

