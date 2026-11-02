# Unreal Engine 5.8 — CommonUI 插件

**Last verified:** 2026-10-17（UE 5.8 变更区块）；2026-02-13（文件其余部分，针对 5.7 编写）
**Status:** Production-Ready
**Plugin:** `CommonUI`（内置，在 Plugins 中启用）

> **UE 5.8 变更：** Common Input/UI 与 Enhanced Input 已统一，这
> "removes the need for duplicate data assets"，并带来更可靠的事件
> 处理、更好的控件绑定，以及面向 Enhanced Input
> UI 的 Input Debugger。CommonUI 标签现在可在蓝图中比较。5.8.1 安装中的
> `CommonUI.uplugin` 不带 Beta/Experimental 标记。来源：UE 5.8 发布
> 说明，https://dev.epicgames.com/documentation/en-us/unreal-engine/unreal-engine-5-8-release-notes?application_version=5.8

---

## 概述

**CommonUI** 是一个跨平台 UI 框架，可自动处理手柄、鼠标与触摸的
输入路由。它专为需要在 PC、主机与移动平台上无缝运行、且平台特定代码最少的
游戏设计。

**使用 CommonUI 的场景：**
- 多平台游戏（主机 + PC）
- 自动路由手柄/鼠标/触摸输入
- 与输入设备无关的 UI（同一套 UI 适用于任何输入方式）
- 控件焦点与导航
- 动作栏与输入提示

**不要使用 CommonUI 的场景：**
- 仅 PC、且只用鼠标的 UI（标准 UMG 更简单）
- 没有导航需求的简单 UI

---

## 与标准 UMG 的关键差异

| 特性 | 标准 UMG | CommonUI |
|---------|--------------|----------|
| **输入处理** | 每个控件手动处理 | 自动路由 |
| **焦点管理** | 基础 | 高级导航 |
| **平台切换** | 手动检测 | 自动 |
| **输入提示** | 硬编码图标 | 按平台动态显示 |
| **界面栈** | 手动 | 内置可激活控件 |

---

## 设置

### 1. 启用插件

`Edit > Plugins > CommonUI > Enabled > Restart`

### 2. 配置项目设置

`Project Settings > Plugins > CommonUI`：
- **Default Input Type**：Gamepad（或自动检测）
- **Platform-Specific Settings**：按平台配置输入图标

### 3. 创建 Common Input Settings 资源

1. Content Browser > Input > Common Input Settings
2. 按平台配置输入数据：
   - Default Gamepad Data
   - Default Mouse & Keyboard Data
   - Default Touch Data

---

## 核心控件

### CommonActivatableWidget（界面管理）

可被激活/停用的界面或菜单的基类。

```cpp
#include "CommonActivatableWidget.h"

UCLASS()
class UMyMenuWidget : public UCommonActivatableWidget {
    GENERATED_BODY()

protected:
    virtual void NativeOnActivated() override {
        Super::NativeOnActivated();
        // Menu is now visible and focused
        UE_LOG(LogTemp, Warning, TEXT("Menu activated"));
    }

    virtual void NativeOnDeactivated() override {
        Super::NativeOnDeactivated();
        // Menu is now hidden
        UE_LOG(LogTemp, Warning, TEXT("Menu deactivated"));
    }

    virtual UWidget* NativeGetDesiredFocusTarget() const override {
        // Return widget that should receive focus (e.g., first button)
        return PlayButton;
    }

private:
    UPROPERTY(meta = (BindWidget))
    TObjectPtr<UCommonButtonBase> PlayButton;
};
```

---

### CommonButtonBase（输入感知按钮）

替代标准 UMG Button。自动处理手柄/鼠标/键盘输入。

```cpp
#include "CommonButtonBase.h"

UCLASS()
class UMyMenuWidget : public UCommonActivatableWidget {
    GENERATED_BODY()

protected:
    UPROPERTY(meta = (BindWidget))
    TObjectPtr<UCommonButtonBase> PlayButton;

    virtual void NativeConstruct() override {
        Super::NativeConstruct();

        // Bind button click (works with any input method)
        PlayButton->OnClicked().AddUObject(this, &UMyMenuWidget::OnPlayClicked);

        // Set button text
        PlayButton->SetButtonText(FText::FromString(TEXT("Play")));
    }

    void OnPlayClicked() {
        UE_LOG(LogTemp, Warning, TEXT("Play clicked"));
    }
};
```

---

### CommonTextBlock（带样式的文本）

支持 CommonUI 样式的文本控件。

```cpp
UPROPERTY(meta = (BindWidget))
TObjectPtr<UCommonTextBlock> TitleText;

TitleText->SetText(FText::FromString(TEXT("Main Menu")));
```

---

### CommonActionWidget（输入提示）

显示输入提示（例如 "Press A to Continue"，并自动显示正确的按钮图标）。

```cpp
UPROPERTY(meta = (BindWidget))
TObjectPtr<UCommonActionWidget> ConfirmActionWidget;

// Bind to input action
ConfirmActionWidget->SetInputAction(ConfirmInputActionData);
// Automatically shows correct icon (A on Xbox, X on PlayStation, Enter on PC)
```

---

## 控件栈（界面管理）

### CommonActivatableWidgetStack

管理界面栈（例如 Main Menu → Settings → Controls）。

```cpp
#include "Widgets/CommonActivatableWidgetContainer.h"

UPROPERTY(meta = (BindWidget))
TObjectPtr<UCommonActivatableWidgetStack> WidgetStack;

// Push new screen onto stack
void ShowSettingsMenu() {
    WidgetStack->AddWidget(USettingsMenuWidget::StaticClass());
}

// Pop current screen (go back)
void GoBack() {
    WidgetStack->DeactivateWidget();
}
```

---

## 输入动作（CommonUI 风格）

### 定义输入动作

创建 **Common Input Action Data Table**：
1. Content Browser > Miscellaneous > Data Table
2. Row Structure：`CommonInputActionDataBase`
3. 为动作添加行（Confirm、Cancel、Navigate 等）

示例行：
- **Action Name**：Confirm
- **Default Input**：Gamepad Face Button Bottom (A/Cross)
- **Alternate Inputs**：Enter（键盘）、Left Mouse Button

---

### 在控件中绑定输入动作

```cpp
#include "Input/CommonUIActionRouterBase.h"

UCLASS()
class UMyWidget : public UCommonActivatableWidget {
    GENERATED_BODY()

protected:
    virtual void NativeOnActivated() override {
        Super::NativeOnActivated();

        // Bind input action
        FBindUIActionArgs BindArgs(ConfirmInputAction, FSimpleDelegate::CreateUObject(this, &UMyWidget::OnConfirm));
        BindArgs.bDisplayInActionBar = true; // Show in action bar
        RegisterUIActionBinding(BindArgs);
    }

    void OnConfirm() {
        UE_LOG(LogTemp, Warning, TEXT("Confirmed"));
    }

private:
    UPROPERTY(EditDefaultsOnly, Category = "Input")
    FDataTableRowHandle ConfirmInputAction;
};
```

---

## 焦点与导航

### 自动手柄导航

CommonUI 会自动处理手柄导航（用方向键/摇杆在按钮之间移动）。

```cpp
// In Widget Blueprint:
// - Widgets are automatically navigable if they inherit from CommonButton/CommonUserWidget
// - Focus order is determined by widget hierarchy and layout
```

### 自定义焦点导航

```cpp
// Override focus navigation
virtual UWidget* NativeGetDesiredFocusTarget() const override {
    return FirstButton; // Return widget that should receive focus
}
```

---

## 输入模式（游戏 vs UI）

### 切换输入模式

```cpp
#include "CommonUIExtensions.h"

// Switch to UI-only mode (pause game, show cursor)
UCommonUIExtensions::PushStreamedGameplayUIInputConfig(this, FrontendInputConfig);

// Return to game mode (hide cursor, resume gameplay)
UCommonUIExtensions::PopInputConfig(this);
```

---

## 平台特定输入图标

### 配置输入图标

1. 为每个平台创建 **Common Input Base Controller Data** 资源：
   - Gamepad（Xbox、PlayStation、Switch）
   - Mouse & Keyboard
   - Touch

2. 指定平台特定图标：
   - Gamepad Face Button Bottom：`A`（Xbox）、`Cross`（PlayStation）
   - Confirm Key：`Enter` 图标

3. 指定到 **Common Input Settings** 资源

### 自动显示正确图标

```cpp
// CommonActionWidget automatically shows correct icon for current platform
UPROPERTY(meta = (BindWidget))
TObjectPtr<UCommonActionWidget> JumpActionWidget;

JumpActionWidget->SetInputAction(JumpInputActionData);
// Shows "A" on Xbox, "Cross" on PlayStation, "Space" on PC
```

---

## 常见模式

### 带导航的主菜单

```cpp
UCLASS()
class UMainMenuWidget : public UCommonActivatableWidget {
    GENERATED_BODY()

protected:
    UPROPERTY(meta = (BindWidget))
    TObjectPtr<UCommonButtonBase> PlayButton;

    UPROPERTY(meta = (BindWidget))
    TObjectPtr<UCommonButtonBase> SettingsButton;

    UPROPERTY(meta = (BindWidget))
    TObjectPtr<UCommonButtonBase> QuitButton;

    virtual void NativeConstruct() override {
        Super::NativeConstruct();

        PlayButton->OnClicked().AddUObject(this, &UMainMenuWidget::OnPlayClicked);
        SettingsButton->OnClicked().AddUObject(this, &UMainMenuWidget::OnSettingsClicked);
        QuitButton->OnClicked().AddUObject(this, &UMainMenuWidget::OnQuitClicked);
    }

    virtual UWidget* NativeGetDesiredFocusTarget() const override {
        return PlayButton; // Focus "Play" button when menu opens
    }

    void OnPlayClicked() { /* Start game */ }
    void OnSettingsClicked() { /* Open settings */ }
    void OnQuitClicked() { /* Quit game */ }
};
```

---

### 带返回操作的暂停菜单

```cpp
UCLASS()
class UPauseMenuWidget : public UCommonActivatableWidget {
    GENERATED_BODY()

protected:
    UPROPERTY(EditDefaultsOnly, Category = "Input")
    FDataTableRowHandle BackInputAction; // Assign "Cancel" action in Blueprint

    virtual void NativeOnActivated() override {
        Super::NativeOnActivated();

        // Bind "Back" input (B/Circle/Escape)
        FBindUIActionArgs BindArgs(BackInputAction, FSimpleDelegate::CreateUObject(this, &UPauseMenuWidget::OnBack));
        RegisterUIActionBinding(BindArgs);
    }

    void OnBack() {
        DeactivateWidget(); // Close pause menu
    }
};
```

---

## 性能技巧

- 使用 **CommonActivatableWidgetStack** 进行界面管理（自动处理激活/停用）
- 避免每帧创建/销毁控件（复用控件）
- 对复杂菜单使用 **Lazy Widgets**（仅在需要时创建）

---

## 调试

### CommonUI 调试命令

```cpp
// Console commands:
// CommonUI.DumpActivatableTree - Show active widget hierarchy
// CommonUI.DumpActionBindings - Show registered input actions
```

---

## 来源
- https://docs.unrealengine.com/5.7/en-US/commonui-plugin-for-advanced-user-interfaces-in-unreal-engine/
- https://docs.unrealengine.com/5.7/en-US/commonui-quickstart-guide-for-unreal-engine/
