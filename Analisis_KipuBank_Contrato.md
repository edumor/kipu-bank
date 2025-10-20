# Análisis Detallado del Contrato KipuBank.sol

**Autor del Análisis:** GitHub Copilot  
**Fecha:** 20 de Octubre, 2025  
**Contrato Analizado:** KipuBank.sol  
**Desarrollador Original:** Eduardo Moreno  

---

## Tabla de Contenidos

1. [Resumen Ejecutivo](#resumen-ejecutivo)
2. [Características Técnicas](#características-técnicas)
3. [Análisis de Funciones Principales](#análisis-de-funciones-principales)
4. [Variables de Estado y Almacenamiento](#variables-de-estado-y-almacenamiento)
5. [Patrones de Seguridad](#patrones-de-seguridad)
6. [Optimizaciones del Módulo 2](#optimizaciones-del-módulo-2)
7. [Flujo de Uso](#flujo-de-uso)
8. [Información de Despliegue](#información-de-despliegue)
9. [Conclusiones](#conclusiones)

---

## Resumen Ejecutivo

### Propósito General
KipuBank es un contrato inteligente desarrollado en Solidity que simula un banco descentralizado en la blockchain de Ethereum. Permite a los usuarios depositar y retirar ETH de manera segura, implementando límites de transacción y capacidad total del banco.

### Arquitectura del Contrato
- **Tipo:** Sistema bancario descentralizado
- **Blockchain:** Ethereum (desplegado en Sepolia Testnet)
- **Versión Solidity:** ^0.8.20
- **Licencia:** MIT License
- **Patrón de Diseño:** Checks-Effects-Interactions (CEI)

### Límites Operacionales
| Parámetro | Valor | Descripción |
|-----------|-------|-------------|
| `WITHDRAWAL_LIMIT` | 0.1 ETH | Máximo retiro por transacción |
| `BANK_CAP` | 10 ETH | Capacidad total del banco |
| Depósito mínimo | > 0 ETH | No se permiten depósitos de 0 |
| Retiro mínimo | > 0 ETH | No se permiten retiros de 0 |

---

## Características Técnicas

### Información de Despliegue
- **Red:** Sepolia Testnet
- **Dirección del Contrato:** `0x979CCD0EB9Bcfc4Bbad9D85914D4C20Edbee3a8B`
- **Estado:** ✅ Verificado y Publicado
- **Fecha de Despliegue:** 16 de Octubre, 2025
- **Block Explorer:** [Ver en Etherscan](https://sepolia.etherscan.io/address/0x979CCD0EB9Bcfc4Bbad9D85914D4C20Edbee3a8B)

### Tecnologías Utilizadas
- **Lenguaje:** Solidity ^0.8.20
- **Optimizaciones:** Strings cortos, acceso único a storage
- **Seguridad:** Patrón CEI, transferencias seguras con `call`
- **Gas Efficiency:** Variables inmutables, validaciones tempranas

---

## Análisis de Funciones Principales

### 1. Función `deposit()` - Depósito de ETH

#### Signatura
```solidity
function deposit() external payable
```

#### Implementación Completa
```solidity
function deposit() external payable {
    // Checks - Validaciones
    require(msg.value > 0, "Zero deposit");
    
    uint256 currentTotalDeposited = totalDeposited;
    require(currentTotalDeposited + msg.value <= BANK_CAP, "Cap exceeded");

    // Effects - Cambios de estado
    uint256 currentUserBalance = balances[msg.sender];
    uint256 newUserBalance = currentUserBalance + msg.value;
    
    balances[msg.sender] = newUserBalance;
    totalDeposited = currentTotalDeposited + msg.value;
    totalDeposits++;

    // Interactions - Eventos
    emit Deposit(msg.sender, msg.value, newUserBalance);
}
```

#### Análisis Paso a Paso

**Paso 1: Validaciones (Checks)**
- **Validación de monto:** Verifica que `msg.value > 0` para evitar depósitos vacíos
- **Control de capacidad:** Lee `totalDeposited` una sola vez y verifica que el nuevo depósito no exceda `BANK_CAP` (10 ETH)

**Paso 2: Efectos (Effects)**
- **Lectura única:** Lee `balances[msg.sender]` una sola vez para optimizar gas
- **Cálculo seguro:** Calcula el nuevo balance del usuario
- **Actualización atómica:** Actualiza todas las variables de estado:
  - Balance individual del usuario
  - Total depositado en el banco
  - Contador de depósitos realizados

**Paso 3: Interacciones (Interactions)**
- **Evento:** Emite `Deposit` con información completa del depósito

#### Optimizaciones Aplicadas
- ✅ **Strings cortos:** "Zero deposit" (12 caracteres), "Cap exceeded" (12 caracteres)
- ✅ **Acceso único:** Cada variable de storage se lee máximo una vez
- ✅ **Patrón CEI:** Validaciones → Cambios → Interacciones externas

---

### 2. Función `withdraw(uint256 amount)` - Retiro de ETH

#### Signatura
```solidity
function withdraw(uint256 amount) external validAmount(amount)
```

#### Implementación Completa
```solidity
function withdraw(uint256 amount) external validAmount(amount) {
    // Checks - Validaciones
    require(amount <= WITHDRAWAL_LIMIT, "Limit exceeded");
    
    uint256 currentBalance = balances[msg.sender];
    require(amount <= currentBalance, "Low balance");

    // Effects - Cambios de estado
    uint256 newBalance = currentBalance - amount;
    
    balances[msg.sender] = newBalance;
    totalDeposited -= amount;
    totalWithdrawals++;

    // Interactions - Transferencia y eventos
    _safeTransfer(msg.sender, amount);
    
    emit Withdrawal(msg.sender, amount, newBalance);
}
```

#### Análisis Paso a Paso

**Paso 0: Modificador `validAmount`**
```solidity
modifier validAmount(uint256 amount) {
    require(amount > 0, "Zero amount");
    _;
}
```
- Valida que el monto sea mayor a cero antes de ejecutar la función

**Paso 1: Validaciones (Checks)**
- **Control de límite:** Verifica que el monto no exceda `WITHDRAWAL_LIMIT` (0.1 ETH)
- **Verificación de fondos:** Lee el balance del usuario una sola vez y verifica fondos suficientes

**Paso 2: Efectos (Effects)**
- **Cálculo seguro:** Calcula el nuevo balance después del retiro
- **Actualización atómica:** Modifica todas las variables de estado:
  - Balance individual del usuario
  - Total depositado en el banco (se reduce)
  - Contador de retiros realizados

**Paso 3: Interacciones (Interactions)**
- **Transferencia segura:** Llama a `_safeTransfer()` para enviar ETH
- **Evento:** Emite `Withdrawal` con detalles completos

#### Optimizaciones Aplicadas
- ✅ **Strings cortos:** "Limit exceeded" (14 caracteres), "Low balance" (11 caracteres)
- ✅ **Acceso único:** Lee `balances[msg.sender]` solo una vez
- ✅ **Transferencia segura:** Usa el patrón `call` moderno

---

### 3. Función `_safeTransfer()` - Transferencia Segura

#### Implementación
```solidity
function _safeTransfer(address to, uint256 amount) private {
    (bool success, ) = payable(to).call{value: amount}("");
    require(success, "Transfer failed");
}
```

#### Análisis de Seguridad

**¿Por qué usa `call` en lugar de `transfer`?**
- **Gas ilimitado:** `.transfer()` está limitado a 2300 gas, `.call()` no tiene límite
- **Compatibilidad futura:** Funciona con contratos que implementan `receive()` o `fallback()`
- **Flexibilidad:** Permite manejar contratos más complejos en el destino

**Mecanismo de Seguridad:**
1. **Captura de resultado:** `(bool success, )` captura si la operación fue exitosa
2. **Verificación explícita:** `require(success, ...)` garantiza que la transferencia se completó
3. **Revert en caso de fallo:** Si la transferencia falla, toda la transacción se revierte

---

### 4. Funciones de Consulta (View Functions)

#### `getBalance(address user)`
```solidity
function getBalance(address user) external view returns (uint256) {
    return balances[user];
}
```
- **Propósito:** Consultar el balance de cualquier usuario en el banco
- **Optimización:** Acceso directo al mapping sin variables intermedias
- **Costo:** Gratuito (función view)

#### `getBankInfo()` - Información Completa del Banco
```solidity
function getBankInfo() external view returns (
    uint256 totalDep,      // Total depositado
    uint256 totalDeps,     // Número de depósitos
    uint256 totalWith,     // Número de retiros
    uint256 bankCap,       // Capacidad máxima
    uint256 withdrawLimit  // Límite de retiro
) {
    return (
        totalDeposited,
        totalDeposits,
        totalWithdrawals,
        BANK_CAP,
        WITHDRAWAL_LIMIT
    );
}
```
- **Propósito:** Obtener todas las estadísticas del banco en una sola llamada
- **Optimización:** Reduce múltiples llamadas separadas a una sola función
- **Información retornada:** Estado completo del banco para dashboards o interfaces

---

## Variables de Estado y Almacenamiento

### Variables Inmutables (Optimización de Gas)
```solidity
uint256 public immutable WITHDRAWAL_LIMIT; // 100000000000000000 wei (0.1 ETH)
uint256 public immutable BANK_CAP;          // 10000000000000000000 wei (10 ETH)
```

**Ventajas de las variables inmutables:**
- ✅ **Costo fijo:** Se establecen una vez en el constructor
- ✅ **Gas eficiente:** Más baratas que las variables de estado normales
- ✅ **Seguridad:** No pueden ser modificadas después del despliegue
- ✅ **Transparencia:** Valores públicamente accesibles

### Variables de Estado Principales
```solidity
address public owner;                           // Propietario del contrato
uint256 public totalDeposited;                  // ETH total almacenado
uint256 public totalDeposits;                   // Contador de depósitos
uint256 public totalWithdrawals;                // Contador de retiros
mapping(address => uint256) public balances;    // Balance por usuario
```

### Estructura de Datos
| Variable | Tipo | Propósito | Visibilidad |
|----------|------|-----------|-------------|
| `owner` | `address` | Identificar al creador del contrato | `public` |
| `totalDeposited` | `uint256` | Sumar todo el ETH en el banco | `public` |
| `totalDeposits` | `uint256` | Contar transacciones de depósito | `public` |
| `totalWithdrawals` | `uint256` | Contar transacciones de retiro | `public` |
| `balances` | `mapping` | Balance individual por usuario | `public` |

### Eventos del Contrato
```solidity
event Deposit(address indexed user, uint256 amount, uint256 newBalance);
event Withdrawal(address indexed user, uint256 amount, uint256 newBalance);
```

**Características de los eventos:**
- **`indexed user`:** Permite filtrar eventos por dirección de usuario
- **Información completa:** Incluye monto y balance resultante
- **Trazabilidad:** Historial completo de todas las operaciones
- **Eficiencia:** Almacenamiento económico comparado con variables de estado

---

## Patrones de Seguridad

### 1. Patrón Checks-Effects-Interactions (CEI)

El contrato implementa consistentemente el patrón CEI, considerado la mejor práctica en smart contracts:

```
┌─────────────┐    ┌──────────────┐    ┌──────────────────┐
│   CHECKS    │ -> │   EFFECTS    │ -> │  INTERACTIONS    │
│             │    │              │    │                  │
│ Validaciones│    │ Cambios de   │    │ Llamadas         │
│ require()   │    │ estado       │    │ externas         │
│ assert()    │    │ Assignments  │    │ .call()          │
│             │    │              │    │ Events           │
└─────────────┘    └──────────────┘    └──────────────────┘
```

**Implementación en `deposit()`:**
1. **Checks:** `require(msg.value > 0)` y `require(...<= BANK_CAP)`
2. **Effects:** Actualizar `balances[msg.sender]`, `totalDeposited`, `totalDeposits`
3. **Interactions:** `emit Deposit(...)`

**Implementación en `withdraw()`:**
1. **Checks:** `validAmount(amount)`, `require(amount <= WITHDRAWAL_LIMIT)`, `require(amount <= currentBalance)`
2. **Effects:** Actualizar `balances[msg.sender]`, `totalDeposited`, `totalWithdrawals`
3. **Interactions:** `_safeTransfer(...)`, `emit Withdrawal(...)`

### 2. Validaciones Robustas

#### Sistema de Validación por Capas
```
Capa 1: Modificadores
├── validAmount(amount) → require(amount > 0)

Capa 2: Validaciones específicas de función
├── deposit()
│   ├── require(msg.value > 0, "Zero deposit")
│   └── require(total + msg.value <= BANK_CAP, "Cap exceeded")
└── withdraw()
    ├── require(amount <= WITHDRAWAL_LIMIT, "Limit exceeded")
    └── require(amount <= currentBalance, "Low balance")

Capa 3: Validaciones de transferencia
└── _safeTransfer()
    └── require(success, "Transfer failed")
```

### 3. Protección Contra Ataques Comunes

#### Protección contra Reentrancy
- **Patrón CEI:** Cambios de estado antes de llamadas externas
- **Orden correcto:** `balances[msg.sender]` se actualiza antes de `_safeTransfer()`

#### Protección contra Overflow/Underflow
- **Solidity 0.8.20:** Protección automática contra overflow/underflow
- **Validaciones explícitas:** Verificación de balance suficiente antes de restar

#### Protección contra DoS
- **Límites claros:** `WITHDRAWAL_LIMIT` y `BANK_CAP` previenen abuso
- **Gas eficiente:** Strings cortos y acceso único reducen costos

---

## Optimizaciones del Módulo 2

### 1. Strings Cortos para Mensajes de Error

**Problema original:** Los strings largos consumen mucho gas
**Solución aplicada:** Todos los mensajes < 15 caracteres

| Función | Mensaje Original Típico | Mensaje Optimizado | Ahorro |
|---------|------------------------|-------------------|---------|
| `deposit()` | "Amount must be greater than zero" | "Zero deposit" | ~50-100 gas |
| `deposit()` | "Deposit exceeds bank capacity" | "Cap exceeded" | ~50-100 gas |
| `withdraw()` | "Amount exceeds withdrawal limit" | "Limit exceeded" | ~50-100 gas |
| `withdraw()` | "Insufficient balance for withdrawal" | "Low balance" | ~50-100 gas |

### 2. Acceso Único a Variables de Storage

**Problema original:** Cada lectura de storage cuesta ~200 gas (SLOAD)
**Solución aplicada:** Leer cada variable máximo una vez por función

#### Ejemplo en `deposit()`:
```solidity
// ❌ Acceso múltiple (ineficiente)
require(totalDeposited + msg.value <= BANK_CAP);
totalDeposited = totalDeposited + msg.value;  // Lee totalDeposited otra vez

// ✅ Acceso único (optimizado)
uint256 currentTotalDeposited = totalDeposited;  // Una sola lectura
require(currentTotalDeposited + msg.value <= BANK_CAP);
totalDeposited = currentTotalDeposited + msg.value;  // Usa variable local
```

#### Ejemplo en `withdraw()`:
```solidity
// ❌ Acceso múltiple (ineficiente)
require(amount <= balances[msg.sender]);
balances[msg.sender] = balances[msg.sender] - amount;  // Lee balance otra vez

// ✅ Acceso único (optimizado)
uint256 currentBalance = balances[msg.sender];  // Una sola lectura
require(amount <= currentBalance);
balances[msg.sender] = currentBalance - amount;  // Usa variable local
```

### 3. Variables Inmutables vs Variables Normales

**Comparación de costos:**

| Tipo de Variable | Costo de Lectura | Costo de Escritura | Cuándo Usar |
|-----------------|------------------|-------------------|-------------|
| `immutable` | ~3 gas | Solo en constructor | Valores constantes |
| `constant` | 0 gas | Compile-time | Valores conocidos en compilación |
| Storage normal | ~200 gas (SLOAD) | ~5000-20000 gas | Valores que cambian |

**Implementación en KipuBank:**
```solidity
// ✅ Optimizado: valores que no cambian
uint256 public immutable WITHDRAWAL_LIMIT;
uint256 public immutable BANK_CAP;

// ✅ Apropiado: valores que cambian
uint256 public totalDeposited;
mapping(address => uint256) public balances;
```

---

## Flujo de Uso

### Diagrama de Flujo Principal

```
Usuario                    KipuBank Contract              Blockchain
   │                            │                            │
   │ 1. deposit() + 0.05 ETH    │                            │
   ├──────────────────────────> │                            │
   │                            │ Validate msg.value > 0     │
   │                            │ Check bank capacity        │
   │                            │ Update balances[user]      │
   │                            │ Update totalDeposited      │
   │                            │ Increment totalDeposits    │
   │                            │ ──────────────────────────> │ Emit Deposit event
   │ ✅ Deposit successful      │                            │
   │ <────────────────────────── │                            │
   │                            │                            │
   │ 2. getBalance(user)        │                            │
   ├──────────────────────────> │                            │
   │ Returns: 50000000000000000 │                            │ (0.05 ETH in wei)
   │ <────────────────────────── │                            │
   │                            │                            │
   │ 3. withdraw(30000000000000000) │                        │
   ├──────────────────────────> │                            │
   │                            │ Validate amount > 0        │
   │                            │ Check withdrawal limit     │
   │                            │ Check user balance         │
   │                            │ Update balances[user]      │
   │                            │ Update totalDeposited      │
   │                            │ Increment totalWithdrawals │
   │                            │ _safeTransfer(user, amount)│
   │                            │ ──────────────────────────> │ Transfer ETH to user
   │                            │ ──────────────────────────> │ Emit Withdrawal event
   │ ✅ 0.03 ETH received       │                            │
   │ <────────────────────────── │                            │
```

### Casos de Uso Típicos

#### Caso 1: Primer Depósito
```
Estado inicial: balance[user] = 0, totalDeposited = 0
Acción: deposit() con 0.1 ETH
Resultado: balance[user] = 0.1 ETH, totalDeposited = 0.1 ETH
```

#### Caso 2: Múltiples Depósitos
```
Estado: balance[user] = 0.1 ETH, totalDeposited = 5 ETH
Acción: deposit() con 0.2 ETH
Resultado: balance[user] = 0.3 ETH, totalDeposited = 5.2 ETH
```

#### Caso 3: Retiro Parcial
```
Estado: balance[user] = 0.3 ETH
Acción: withdraw(0.1 ETH)
Resultado: balance[user] = 0.2 ETH, usuario recibe 0.1 ETH
```

#### Caso 4: Retiro Total
```
Estado: balance[user] = 0.05 ETH
Acción: withdraw(0.05 ETH)
Resultado: balance[user] = 0 ETH, usuario recibe 0.05 ETH
```

### Manejo de Errores Comunes

#### Error: "Zero deposit"
```
Causa: Usuario llama deposit() sin enviar ETH (msg.value = 0)
Solución: Enviar ETH junto con la transacción
```

#### Error: "Cap exceeded"
```
Causa: El depósito haría que el banco supere 10 ETH total
Solución: Depositar una cantidad menor o esperar a que otros retiren
```

#### Error: "Limit exceeded"
```
Causa: Usuario intenta retirar más de 0.1 ETH en una transacción
Solución: Realizar múltiples retiros de máximo 0.1 ETH cada uno
```

#### Error: "Low balance"
```
Causa: Usuario intenta retirar más de lo que tiene en su balance
Solución: Verificar balance con getBalance() y retirar cantidad válida
```

---

## Información de Despliegue

### Detalles de Red
- **Blockchain:** Ethereum
- **Red de Prueba:** Sepolia Testnet
- **Dirección:** `0x979CCD0EB9Bcfc4Bbad9D85914D4C20Edbee3a8B`
- **Estado:** Verificado ✅
- **Fecha de Despliegue:** 16 de Octubre, 2025

### Parámetros de Constructor
```solidity
constructor(uint256 _withdrawalLimit, uint256 _bankCap) {
    WITHDRAWAL_LIMIT = _withdrawalLimit;  // 100000000000000000 (0.1 ETH)
    BANK_CAP = _bankCap;                  // 10000000000000000000 (10 ETH)
    owner = msg.sender;
}
```

### Enlaces de Verificación
- **Etherscan:** [Ver contrato verificado](https://sepolia.etherscan.io/address/0x979CCD0EB9Bcfc4Bbad9D85914D4C20Edbee3a8B)
- **Código fuente:** Disponible y verificado en Etherscan
- **ABI:** Accesible públicamente para integración

### Costos de Gas Estimados
| Operación | Gas Estimado | Costo en USD* |
|-----------|-------------|---------------|
| Deploy | ~800,000 | $24.00 |
| deposit() | ~42,000 | $1.26 |
| withdraw() | ~52,000 | $1.56 |
| getBalance() | 0 (view) | $0.00 |
| getBankInfo() | 0 (view) | $0.00 |

*Basado en gas price de 30 gwei y ETH a $2,500

---

## Conclusiones

### Fortalezas del Contrato

#### 🛡️ **Seguridad**
- **Patrón CEI:** Implementación correcta del patrón Checks-Effects-Interactions
- **Transferencias seguras:** Uso de `.call()` con verificación de éxito
- **Validaciones robustas:** Múltiples capas de validación de entrada
- **Protección contra reentrancy:** Cambios de estado antes de llamadas externas

#### ⚡ **Eficiencia de Gas**
- **Strings cortos:** Todos los mensajes de error < 15 caracteres
- **Acceso único a storage:** Cada variable leída máximo una vez por función
- **Variables inmutables:** Uso apropiado para constantes
- **Validación temprana:** Fallos rápidos para ahorrar gas

#### 🎯 **Usabilidad**
- **Interfaz clara:** Funciones intuitivas y bien documentadas
- **Eventos informativos:** Trazabilidad completa de operaciones
- **Consultas eficientes:** Funciones view gratuitas para información
- **Límites transparentes:** Restricciones claras y predecibles

#### 📚 **Cumplimiento Académico**
- **Módulo 2 compliant:** Sigue estrictamente los estándares enseñados
- **Mejores prácticas:** Implementa patrones de seguridad reconocidos
- **Código limpio:** Estructura clara y comentarios apropiados
- **Optimizaciones específicas:** Aplicación correcta de técnicas de eficiencia

### Áreas de Consideración

#### 🔄 **Funcionalidad Limitada**
- Solo depósitos y retiros de ETH nativo
- No soporta tokens ERC-20
- Límites fijos (no ajustables por gobernanza)

#### 🏛️ **Centralización**
- Variable `owner` sin funcionalidad (podría implementar admin functions)
- Sin mecanismo de upgrade o pausa de emergencia

#### 🌐 **Escalabilidad**
- Límites conservadores (10 ETH total, 0.1 ETH por retiro)
- Diseñado para casos de uso pequeños/educativos

### Recomendaciones para Uso

#### ✅ **Apropiado para:**
- Proyectos educativos y aprendizaje
- Casos de uso con volúmenes pequeños
- Demostración de mejores prácticas
- Base para desarrollos más complejos

#### ⚠️ **No recomendado para:**
- Sistemas financieros de alto volumen
- Casos que requieren funcionalidades avanzadas
- Entornos que necesitan upgradabilidad
- Aplicaciones con requisitos de gobernanza

### Calificación General

| Aspecto | Calificación | Comentarios |
|---------|-------------|-------------|
| **Seguridad** | ⭐⭐⭐⭐⭐ | Excelente implementación de patrones de seguridad |
| **Eficiencia** | ⭐⭐⭐⭐⭐ | Optimizaciones del Módulo 2 correctamente aplicadas |
| **Legibilidad** | ⭐⭐⭐⭐⭐ | Código claro, bien estructurado y documentado |
| **Funcionalidad** | ⭐⭐⭐⭐ | Funciones básicas bien implementadas |
| **Escalabilidad** | ⭐⭐⭐ | Limitado por diseño, apropiado para el propósito |

**Puntuación Total: 4.6/5** ⭐⭐⭐⭐⭐

El contrato KipuBank.sol representa una implementación ejemplar de los conceptos enseñados en el Módulo 2, combinando seguridad, eficiencia y claridad en un sistema bancario descentralizado funcional y bien diseñado.

---

## Apéndices

### Apéndice A: Código Completo del Contrato

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title KipuBank
 * @author Eduardo Moreno
 * @notice A simple bank contract that allows users to deposit and withdraw ETH
 * @dev Implements basic deposit and withdrawal functionalities with security limits
 */
contract KipuBank {
    // ============ IMMUTABLE AND CONSTANT VARIABLES ============
    
    /// @notice Maximum withdrawal limit per transaction (0.1 ETH)
    /// @dev Immutable variable set in constructor
    uint256 public immutable WITHDRAWAL_LIMIT;
    
    /// @notice Total deposit limit that the bank can handle
    /// @dev Immutable variable set in constructor
    uint256 public immutable BANK_CAP;

    // ============ STORAGE VARIABLES ============
    
    /// @notice Address of the contract owner
    address public owner;
    
    /// @notice Total ETH deposited in the bank
    uint256 public totalDeposited;
    
    /// @notice Total counter of deposits made
    uint256 public totalDeposits;
    
    /// @notice Total counter of withdrawals made  
    uint256 public totalWithdrawals;

    // ============ MAPPING ============
    
    /// @notice Mapping of addresses to their balances in the bank
    /// @dev address => balance in wei
    mapping(address => uint256) public balances;

    // ============ EVENTS ============
    
    /// @notice Emitted when a user makes a deposit
    /// @param user Address of the user making the deposit
    /// @param amount Amount deposited in wei
    /// @param newBalance New balance of the user
    event Deposit(address indexed user, uint256 amount, uint256 newBalance);
    
    /// @notice Emitted when a user makes a successful withdrawal
    /// @param user Address of the user making the withdrawal
    /// @param amount Amount withdrawn in wei
    /// @param newBalance New balance of the user
    event Withdrawal(address indexed user, uint256 amount, uint256 newBalance);

    // ============ MODIFIERS ============
    
    /// @notice Modifier to validate that amount is greater than zero
    modifier validAmount(uint256 amount) {
        require(amount > 0, "Zero amount");
        _;
    }

    // ============ CONSTRUCTOR ============
    
    /// @notice Constructor that initializes the contract with specified limits
    /// @param _withdrawalLimit Maximum withdrawal limit per transaction in wei
    /// @param _bankCap Total deposit limit that the bank can handle in wei
    constructor(uint256 _withdrawalLimit, uint256 _bankCap) {
        WITHDRAWAL_LIMIT = _withdrawalLimit;
        BANK_CAP = _bankCap;
        owner = msg.sender;
    }

    // ============ EXTERNAL FUNCTIONS ============
    
    /// @notice External payable function to deposit ETH into the bank
    /// @dev Verifies that the deposit does not exceed the bank limit
    function deposit() external payable {
        // Checks
        require(msg.value > 0, "Zero deposit");
        
        uint256 currentTotalDeposited = totalDeposited;
        require(currentTotalDeposited + msg.value <= BANK_CAP, "Cap exceeded");

        // Effects - Single access to state variables
        uint256 currentUserBalance = balances[msg.sender];
        uint256 newUserBalance = currentUserBalance + msg.value;
        
        balances[msg.sender] = newUserBalance;
        totalDeposited = currentTotalDeposited + msg.value;
        totalDeposits++;

        // Interactions (event emission)
        emit Deposit(msg.sender, msg.value, newUserBalance);
    }

    /// @notice External function to withdraw ETH from the bank
    /// @param amount Amount to withdraw in wei
    /// @dev Verifies withdrawal limits and sufficient balance
    function withdraw(uint256 amount) external validAmount(amount) {
        // Checks
        require(amount <= WITHDRAWAL_LIMIT, "Limit exceeded");
        
        uint256 currentBalance = balances[msg.sender];
        require(amount <= currentBalance, "Low balance");

        // Effects - Single access to state variables
        uint256 newBalance = currentBalance - amount;
        
        balances[msg.sender] = newBalance;
        totalDeposited -= amount;
        totalWithdrawals++;

        // Interactions
        _safeTransfer(msg.sender, amount);
        
        emit Withdrawal(msg.sender, amount, newBalance);
    }

    /// @notice External view function to get a user's balance
    /// @param user User's address
    /// @return User's balance in wei
    function getBalance(address user) external view returns (uint256) {
        return balances[user];
    }

    /// @notice External view function to get general bank information
    /// @return totalDep Total deposited in the bank
    /// @return totalDeps Total number of deposits
    /// @return totalWith Total number of withdrawals
    /// @return bankCap Maximum bank limit
    /// @return withdrawLimit Withdrawal limit per transaction
    function getBankInfo() external view returns (
        uint256 totalDep,
        uint256 totalDeps,
        uint256 totalWith,
        uint256 bankCap,
        uint256 withdrawLimit
    ) {
        return (
            totalDeposited,
            totalDeposits,
            totalWithdrawals,
            BANK_CAP,
            WITHDRAWAL_LIMIT
        );
    }

    // ============ PRIVATE FUNCTIONS ============
    
    /// @notice Private function to perform safe ETH transfers
    /// @param to Destination address
    /// @param amount Amount to transfer in wei
    /// @dev Uses call method as taught in Module 2
    function _safeTransfer(address to, uint256 amount) private {
        (bool success, ) = payable(to).call{value: amount}("");
        require(success, "Transfer failed");
    }
}
```

### Apéndice B: Comandos de Interacción

#### Conversión ETH a Wei
```javascript
// 0.1 ETH = 100000000000000000 wei
// 0.01 ETH = 10000000000000000 wei
// 0.001 ETH = 1000000000000000 wei

// Función de conversión
function ethToWei(eth) {
    return eth * 10**18;
}

// Ejemplos
ethToWei(0.1)    // 100000000000000000
ethToWei(0.05)   // 50000000000000000
ethToWei(0.001)  // 1000000000000000
```

#### Ejemplos de Llamadas de Función

**Depósito de 0.05 ETH:**
```javascript
// Via Web3.js
await contract.deposit({ value: web3.utils.toWei("0.05", "ether") });

// Via Ethers.js
await contract.deposit({ value: ethers.utils.parseEther("0.05") });

// Via Remix IDE
// En el campo "VALUE": 0.05 ETH
// Llamar función deposit()
```

**Retiro de 0.03 ETH:**
```javascript
// Via Web3.js
await contract.withdraw(web3.utils.toWei("0.03", "ether"));

// Via Ethers.js
await contract.withdraw(ethers.utils.parseEther("0.03"));

// Via Remix IDE
// Parámetro amount: 30000000000000000
```

### Apéndice C: Enlaces Útiles

- **Contrato en Etherscan:** https://sepolia.etherscan.io/address/0x979CCD0EB9Bcfc4Bbad9D85914D4C20Edbee3a8B
- **Remix IDE:** https://remix.ethereum.org/
- **Sepolia Faucet:** https://sepoliafaucet.com/
- **MetaMask:** https://metamask.io/
- **Documentación Solidity:** https://docs.soliditylang.org/
- **Conversión ETH/Wei:** https://eth-converter.com/

---

**Fin del Análisis**  
*Documento generado por GitHub Copilot el 20 de Octubre, 2025*  
*Para uso educativo y de referencia técnica*