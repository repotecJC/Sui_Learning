# Price Oracle — Test Matrix

> Scope: Unit tests for core behaviors (capability-gated auth, state transitions, abort/rollback, basic view functions). [web:397][web:361]

## Create Oracle

### Happy Path
- Feature: `create_oracle`
- Scenario: Create succeeds and initial fields are set
- Setup: Fresh address; no objects
- Input: `pair="BTC/USD"`, `initial_price=...`, `decimals=6`, `admin_limit=5`
- Expected:
  - Oracle is shared
  - `oracle.admin_minted == 1`
  - `oracle.admin_limit == 5`
  - Creator receives `SuperAdminCap` + `AdminCap` [web:397]

### Boundary Path
- Feature: `create_oracle`
- Scenario: Minimal admin limit that still allows creator admin
- Setup: Fresh address
- Input: `admin_limit=1`
- Expected:
  - Create succeeds
  - `oracle.admin_minted == 1`
  - `oracle.admin_limit == 1`
  - Next `add_admin` must fail due to limit (abort/tx failure) [web:361]


## Super Admin Authority

### Add Admin

#### Happy Path
- Feature: `add_admin`
- Scenario: Mint admin within limit
- Setup: `oracle.admin_minted=1`, `oracle.admin_limit=2`, caller has `SuperAdminCap`
- Input: `receiver=addr2`
- Expected:
  - `oracle.admin_minted == 2`
  - `addr2` receives `AdminCap` [web:397]

#### Failed Path 1 (Over Limit)
- Feature: `add_admin`
- Scenario: Mint admin over limit aborts
- Setup: `oracle.admin_minted=2`, `oracle.admin_limit=2`, caller has `SuperAdminCap`
- Input: `receiver=addr3`
- Expected:
  - Abort with `EAdminsOverLimit`
  - `oracle.admin_minted` remains `2` (rollback)
  - `addr3` does not receive `AdminCap` [web:361]

#### Failed Path 2 (No SuperAdminCap)
- Feature: `add_admin`
- Scenario: Attacker has no `SuperAdminCap` must fail
- Setup: Attacker address has no `SuperAdminCap`; `oracle.admin_minted=1`, `oracle.admin_limit=2`
- Input: `receiver=attacker_addr` (or any address)
- Expected:
  - Transaction/call fails
  - `oracle.admin_minted` unchanged
  - No `AdminCap` minted/transferred [web:397]

#### Boundary Path (Exactly Reach Limit)
- Feature: `add_admin`
- Scenario: Mint admin to exactly reach limit
- Setup: `oracle.admin_minted=oracle.admin_limit - 1`, caller has `SuperAdminCap`
- Input: `receiver=addrX`
- Expected:
  - Success
  - `oracle.admin_minted == oracle.admin_limit`
  - Next `add_admin` fails (abort/tx failure) [web:361]


### Increase Admin Limit

#### Happy Path
- Feature: `increase_admin_limit`
- Scenario: Increase admin limit
- Setup: `oracle.admin_limit=2`, caller has `SuperAdminCap`
- Input: `new_limit=5`
- Expected: `oracle.admin_limit == 5` [web:397]

#### Failed Path 1 (No SuperAdminCap)
- Feature: `increase_admin_limit`
- Scenario: Attacker has no `SuperAdminCap` must fail
- Setup: Attacker has no `SuperAdminCap`; `oracle.admin_limit=2`
- Input: `new_limit=5`
- Expected:
  - Transaction/call fails
  - `oracle.admin_limit` unchanged [web:397]

#### Failed/Spec Path 2 (Decrease Limit)
- Feature: `increase_admin_limit`
- Scenario: Attempt to set `new_limit` lower than current limit
- Setup: `oracle.admin_limit=2`, caller has `SuperAdminCap`
- Input: `new_limit=1`
- Expected: Record current observed behavior (either succeeds and sets to 1, or fails). Treat this as a spec clarification test. [web:361]


## Admin Authority

### Update Price

#### Happy Path
- Feature: `update_price`
- Scenario: Update by `AdminCap` succeeds (capability-gated)
- Setup: Caller has `AdminCap`; oracle exists
- Input: `new_price=...`
- Expected:
  - `oracle.price` updated
  - `oracle.last_updated` updated
  - Price update event emitted (if implemented) [web:397]

#### Failed Path (No AdminCap)
- Feature: `update_price`
- Scenario: Call without `AdminCap` must fail
- Setup: Attacker has no `AdminCap`; oracle exists
- Input: Attempt to call without providing `&AdminCap`
- Expected:
  - Transaction/call fails
  - `oracle.price` unchanged
  - `oracle.last_updated` unchanged [web:397]


## Public Functions

### Get Price
- Feature: `get_price`
- Scenario: Return stored price
- Setup: Oracle exists with known `price=P`
- Input: None
- Expected: Returns `P` [web:33]

### Is Fresh
- Feature: `is_fresh`
- Scenario: Freshness check works with a typical max_age
- Setup: Oracle exists; `last_updated` set such that age < max_age
- Input: `max_age=300`
- Expected: Returns `true` [web:33]

### Is Fresh (Boundary)
- Feature: `is_fresh`
- Scenario: age == max_age
- Setup: Oracle exists; `last_updated` set such that age == max_age
- Input: `max_age=300`
- Expected: Record current observed behavior (true/false) as the contract’s de-facto spec. [web:361]
