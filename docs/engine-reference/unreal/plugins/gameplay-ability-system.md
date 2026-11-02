# Unreal Engine 5.8 — Gameplay Ability System（GAS）

**Last verified:** 2026-10-17（技能资源标签，对照 5.8 头文件重新确认）；2026-02-13（文件其余部分，针对 5.7 编写）
**Status:** Production-Ready
**Plugin:** `GameplayAbilities`（内置，在 Plugins 中启用）

---

## 概述

**Gameplay Ability System（GAS）** 是一个用于构建技能、属性、
效果与玩法机制的模块化框架。它是 RPG、MOBA、带技能的射击游戏，
以及任何拥有复杂技能系统的游戏的标准方案。

**使用 GAS 的场景：**
- 角色技能（法术、技能、攻击）
- 属性（生命、法力、耐力、数值）
- 增益/减益（临时效果）
- 冷却与消耗
- 伤害计算
- 面向多玩家的技能复制

---

## 核心概念

### 1. **Ability System Component**（ASC）
- 拥有技能、属性与效果的主要组件
- 添加到 Character 或 PlayerState

### 2. **Gameplay Abilities**
- 单个技能/动作（火球、治疗、冲刺等）
- 被激活、提交（消耗/冷却），并可被取消

### 3. **Attributes & Attribute Sets**
- 可被修改的数值（Health、Mana、Stamina、Strength 等）
- 存储在 Attribute Set 中

### 4. **Gameplay Effects**
- 修改属性（伤害、治疗、增益、减益）
- 可以是即时、有时长或无限的

### 5. **Gameplay Tags**
- 用于技能逻辑的层级标签（例如 `Ability.Attack.Melee`、`Status.Stunned`）

---

## 设置

### 1. 启用插件

`Edit > Plugins > Gameplay Abilities > Enabled > Restart`

### 2. 添加 Ability System Component

```cpp
#include "AbilitySystemComponent.h"
#include "AttributeSet.h"

UCLASS()
class AMyCharacter : public ACharacter {
    GENERATED_BODY()

public:
    AMyCharacter() {
        // Create ASC
        AbilitySystemComponent = CreateDefaultSubobject<UAbilitySystemComponent>(TEXT("AbilitySystem"));
        AbilitySystemComponent->SetIsReplicated(true);
        AbilitySystemComponent->SetReplicationMode(EGameplayEffectReplicationMode::Mixed);

        // Create Attribute Set
        AttributeSet = CreateDefaultSubobject<UMyAttributeSet>(TEXT("AttributeSet"));
    }

protected:
    UPROPERTY(VisibleAnywhere, BlueprintReadOnly, Category = "Abilities")
    TObjectPtr<UAbilitySystemComponent> AbilitySystemComponent;

    UPROPERTY()
    TObjectPtr<const UAttributeSet> AttributeSet;
};
```

### 3. 初始化 ASC（多玩家场景中很重要）

```cpp
void AMyCharacter::PossessedBy(AController* NewController) {
    Super::PossessedBy(NewController);

    // Server: Initialize ASC
    if (AbilitySystemComponent) {
        AbilitySystemComponent->InitAbilityActorInfo(this, this);
        GiveDefaultAbilities();
    }
}

void AMyCharacter::OnRep_PlayerState() {
    Super::OnRep_PlayerState();

    // Client: Initialize ASC
    if (AbilitySystemComponent) {
        AbilitySystemComponent->InitAbilityActorInfo(this, this);
    }
}
```

---

## 属性与属性集（Attributes & Attribute Sets）

### 创建 Attribute Set

```cpp
#include "AttributeSet.h"
#include "AbilitySystemComponent.h"

UCLASS()
class UMyAttributeSet : public UAttributeSet {
    GENERATED_BODY()

public:
    UMyAttributeSet();

    // Health
    UPROPERTY(BlueprintReadOnly, Category = "Attributes", ReplicatedUsing = OnRep_Health)
    FGameplayAttributeData Health;
    ATTRIBUTE_ACCESSORS(UMyAttributeSet, Health)

    UPROPERTY(BlueprintReadOnly, Category = "Attributes", ReplicatedUsing = OnRep_MaxHealth)
    FGameplayAttributeData MaxHealth;
    ATTRIBUTE_ACCESSORS(UMyAttributeSet, MaxHealth)

    // Mana
    UPROPERTY(BlueprintReadOnly, Category = "Attributes", ReplicatedUsing = OnRep_Mana)
    FGameplayAttributeData Mana;
    ATTRIBUTE_ACCESSORS(UMyAttributeSet, Mana)

    virtual void GetLifetimeReplicatedProps(TArray<FLifetimeProperty>& OutLifetimeProps) const override;

protected:
    UFUNCTION()
    virtual void OnRep_Health(const FGameplayAttributeData& OldHealth);

    UFUNCTION()
    virtual void OnRep_MaxHealth(const FGameplayAttributeData& OldMaxHealth);

    UFUNCTION()
    virtual void OnRep_Mana(const FGameplayAttributeData& OldMana);
};
```

### 实现 Attribute Set

```cpp
#include "Net/UnrealNetwork.h"

UMyAttributeSet::UMyAttributeSet() {
    // Default values
    Health = 100.0f;
    MaxHealth = 100.0f;
    Mana = 50.0f;
}

void UMyAttributeSet::GetLifetimeReplicatedProps(TArray<FLifetimeProperty>& OutLifetimeProps) const {
    Super::GetLifetimeReplicatedProps(OutLifetimeProps);

    DOREPLIFETIME_CONDITION_NOTIFY(UMyAttributeSet, Health, COND_None, REPNOTIFY_Always);
    DOREPLIFETIME_CONDITION_NOTIFY(UMyAttributeSet, MaxHealth, COND_None, REPNOTIFY_Always);
    DOREPLIFETIME_CONDITION_NOTIFY(UMyAttributeSet, Mana, COND_None, REPNOTIFY_Always);
}

void UMyAttributeSet::OnRep_Health(const FGameplayAttributeData& OldHealth) {
    GAMEPLAYATTRIBUTE_REPNOTIFY(UMyAttributeSet, Health, OldHealth);
}

// Implement other OnRep functions similarly...
```

### 钳制属性（Clamping Attributes）

Attribute Set 没有内置的钳制机制：Data Table 的 `Min Value` 与
`Max Value` 列不会生效。请在 Attribute Set 中进行钳制：
- `PreAttributeChange()` 在对属性进行任何修改之前调用，
  是实现 `Health = Clamp(Health, 0, MaxHealth)` 这类规则的钩子 —
  它的 `NewValue` 可变。
- `PreAttributeBaseChange()` 在存在聚合器（aggregator）时、属性的
  **基值**发生变化之前调用；`PostGameplayEffectExecute()`
  在 Gameplay Effect 执行以修改基值之后立即调用 — 请在其中
  钳制由即时效果造成的基值变化。

堆叠规则（Stacking rules）管理同一 Gameplay Effect 的重复应用；它们并不
限制不同效果对同一属性的推送。

---

## Gameplay Abilities

### 创建 Gameplay Ability

```cpp
#include "Abilities/GameplayAbility.h"

UCLASS()
class UGA_Fireball : public UGameplayAbility {
    GENERATED_BODY()

public:
    UGA_Fireball() {
        // Ability config
        InstancingPolicy = EGameplayAbilityInstancingPolicy::InstancedPerActor;
        NetExecutionPolicy = EGameplayAbilityNetExecutionPolicy::ServerInitiated;

        // Tags: the ability's own tags (asset tags, formerly AbilityTags).
        // Set them with SetAssetTags(), constructor only; read with GetAssetTags().
        FGameplayTagContainer Tags;
        Tags.AddTag(FGameplayTag::RequestGameplayTag(FName("Ability.Attack.Fireball")));
        SetAssetTags(Tags);
    }

    virtual void ActivateAbility(const FGameplayAbilitySpecHandle Handle, const FGameplayAbilityActorInfo* ActorInfo,
        const FGameplayAbilityActivationInfo ActivationInfo, const FGameplayEventData* TriggerEventData) override {

        if (!CommitAbility(Handle, ActorInfo, ActivationInfo)) {
            // Failed to commit (not enough mana, on cooldown, etc.)
            EndAbility(Handle, ActorInfo, ActivationInfo, true, true);
            return;
        }

        // Spawn fireball projectile
        SpawnFireball();

        // End ability
        EndAbility(Handle, ActorInfo, ActivationInfo, true, false);
    }

    void SpawnFireball() {
        // Spawn fireball logic
    }
};
```

### 为角色授予技能

```cpp
void AMyCharacter::GiveDefaultAbilities() {
    if (!HasAuthority() || !AbilitySystemComponent) return;

    // Grant abilities
    AbilitySystemComponent->GiveAbility(FGameplayAbilitySpec(UGA_Fireball::StaticClass(), 1, INDEX_NONE, this));
    AbilitySystemComponent->GiveAbility(FGameplayAbilitySpec(UGA_Heal::StaticClass(), 1, INDEX_NONE, this));
}
```

### 激活技能

```cpp
// Activate by class
AbilitySystemComponent->TryActivateAbilityByClass(UGA_Fireball::StaticClass());

// Activate by tag
FGameplayTagContainer TagContainer;
TagContainer.AddTag(FGameplayTag::RequestGameplayTag(FName("Ability.Attack.Fireball")));
AbilitySystemComponent->TryActivateAbilitiesByTag(TagContainer);
```

---

## Gameplay Effects

### 创建 Gameplay Effect（伤害）

```cpp
// Create Blueprint: Content Browser > Gameplay > Gameplay Effect

// OR in C++:
UCLASS()
class UGE_Damage : public UGameplayEffect {
    GENERATED_BODY()

public:
    UGE_Damage() {
        // Instant damage
        DurationPolicy = EGameplayEffectDurationType::Instant;

        // Modifier: Reduce Health
        FGameplayModifierInfo ModifierInfo;
        ModifierInfo.Attribute = UMyAttributeSet::GetHealthAttribute();
        ModifierInfo.ModifierOp = EGameplayModOp::Additive;
        ModifierInfo.ModifierMagnitude = FScalableFloat(-25.0f); // -25 health

        Modifiers.Add(ModifierInfo);
    }
};
```

### 应用 Gameplay Effect

```cpp
// Apply damage to target
if (UAbilitySystemComponent* TargetASC = UAbilitySystemBlueprintLibrary::GetAbilitySystemComponent(Target)) {
    FGameplayEffectContextHandle EffectContext = AbilitySystemComponent->MakeEffectContext();
    EffectContext.AddSourceObject(this);

    FGameplayEffectSpecHandle SpecHandle = AbilitySystemComponent->MakeOutgoingSpec(
        UGE_Damage::StaticClass(), 1, EffectContext);

    if (SpecHandle.IsValid()) {
        AbilitySystemComponent->ApplyGameplayEffectSpecToTarget(*SpecHandle.Data.Get(), TargetASC);
    }
}
```

---

## Gameplay Tags

### 定义标签

`Project Settings > Project > Gameplay Tags > Gameplay Tag List`

示例层级：
```
Ability
  ├─ Ability.Attack
  │   ├─ Ability.Attack.Melee
  │   └─ Ability.Attack.Ranged
  ├─ Ability.Defend
  └─ Ability.Utility

Status
  ├─ Status.Stunned
  ├─ Status.Invulnerable
  └─ Status.Silenced
```

### 在技能中使用标签

```cpp
UCLASS()
class UGA_MeleeAttack : public UGameplayAbility {
    GENERATED_BODY()

public:
    UGA_MeleeAttack() {
        // This ability has these tags (asset tags; SetAssetTags() is constructor-only)
        FGameplayTagContainer Tags;
        Tags.AddTag(FGameplayTag::RequestGameplayTag(FName("Ability.Attack.Melee")));
        SetAssetTags(Tags);

        // Block these tags while active
        BlockAbilitiesWithTag.AddTag(FGameplayTag::RequestGameplayTag(FName("Ability.Attack")));

        // Cancel these abilities when activated
        CancelAbilitiesWithTag.AddTag(FGameplayTag::RequestGameplayTag(FName("Ability.Defend")));

        // Can't activate if target has these tags
        ActivationBlockedTags.AddTag(FGameplayTag::RequestGameplayTag(FName("Status.Stunned")));
    }
};
```

---

## 冷却与消耗

### 添加冷却

```cpp
// In Ability Blueprint or C++:
// Create Gameplay Effect with Duration = Cooldown time
// Assign to Ability > Cooldown Gameplay Effect Class
```

### 添加消耗（法力）

```cpp
// Create Gameplay Effect that reduces Mana
// Assign to Ability > Cost Gameplay Effect Class
```

---

## 常见模式

### 获取当前属性值

```cpp
float CurrentHealth = AbilitySystemComponent->GetNumericAttribute(UMyAttributeSet::GetHealthAttribute());
```

### 监听属性变化

```cpp
AbilitySystemComponent->GetGameplayAttributeValueChangeDelegate(UMyAttributeSet::GetHealthAttribute())
    .AddUObject(this, &AMyCharacter::OnHealthChanged);

void AMyCharacter::OnHealthChanged(const FOnAttributeChangeData& Data) {
    UE_LOG(LogTemp, Warning, TEXT("Health: %f"), Data.NewValue);
}
```

---

## 来源
- https://docs.unrealengine.com/5.7/en-US/gameplay-ability-system-for-unreal-engine/
- Clamping：*Gameplay Attributes and Attribute Sets* https://dev.epicgames.com/documentation/en-us/unreal-engine/gameplay-attributes-and-attribute-sets-for-the-gameplay-ability-system-in-unreal-engine ；`UAttributeSet` API https://dev.epicgames.com/documentation/en-us/unreal-engine/API/Plugins/GameplayAbilities/UAttributeSet ；`PreAttributeChange` https://dev.epicgames.com/documentation/en-us/unreal-engine/API/Plugins/GameplayAbilities/UAttributeSet/PreAttributeChange
- 技能资源标签（`SetAssetTags()` / `GetAssetTags()`）— `UGameplayAbility` API，UE 5.7：https://dev.epicgames.com/documentation/en-us/unreal-engine/API/Plugins/GameplayAbilities/UGameplayAbility?application_version=5.7 ；`SetAssetTags`：https://dev.epicgames.com/documentation/en-us/unreal-engine/API/Plugins/GameplayAbilities/UGameplayAbility/SetAssetTags?application_version=5.7 。5.7 参考将 `SetAssetTags(const FGameplayTagContainer&)` 列为 protected，"formerly AbilityTags"，仅"only ... during construction"可调用；`GetAssetTags()` 为公开读取接口；`AbilityTags` 为公开变量，"exposed for backwards compatibility"（该页无弃用说明）。2026-10-17 对照 `Engine/Plugins/Runtime/GameplayAbilities/Source/GameplayAbilities/Public/Abilities/GameplayAbility.h`（5.8.1 安装）重新确认了 UE 5.8 的情形：`GetAssetTags()` 为 public，`SetAssetTags(const FGameplayTagContainer&)` 为 protected（"This can only be called during construction"），`AbilityTags` 仍是 public `UPROPERTY`，标记为 `UE_DEPRECATED_FORGAME(5.5, "Use GetAssetTags(). This is being made non-mutable, private and renamed to AssetTags in the future. Use SetAssetTags to set defaults (in constructor only).")` — 因此直接访问 `AbilityTags` 的游戏代码会收到弃用警告。5.8 API 页面：https://dev.epicgames.com/documentation/en-us/unreal-engine/API/Plugins/GameplayAbilities/UGameplayAbility/SetAssetTags?application_version=5.8 。5.8 中同样已弃用的还有：`FActiveGameplayEffectHandle(int32)` 构造函数（请使用 `GenerateNewHandle` 或 `GetInstantExecutedHandle()`；`.../Public/ActiveGameplayEffectHandle.h`）。
- https://github.com/tranek/GASDocumentation （社区指南）
