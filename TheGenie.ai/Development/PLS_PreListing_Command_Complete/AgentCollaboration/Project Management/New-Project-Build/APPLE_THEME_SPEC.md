# Task Manager - Apple Minimalist Theme Spec
## Frontend Design Guidelines

---

## Typography

**Primary Font:** SF Pro (with fallbacks)

```css
font-family: 'SF Pro Text', 'SF Pro Display', -apple-system, BlinkMacSystemFont, 'Inter', 'Helvetica Neue', sans-serif;
```

**Font Weights:**
- Regular: 400
- Medium: 500
- Semibold: 600

**Letter Spacing:**
- Headlines: -0.026em
- Body/Titles: -0.022em  
- Small text: -0.008em

**Line Heights:**
- Body text: 1.47059
- Headlines: 1.2

**Font Sizes:**
| Element | Size | Weight |
|---------|------|--------|
| Page title | 32px | 600 |
| Card title | 17px | 600 |
| Section title | 15px | 600 |
| Body text | 14px | 400 |
| Small/Meta | 13px | 400 |
| Tiny/Badge | 11-12px | 500 |

---

## Color Palette

### Core Colors
```css
:root {
  /* Backgrounds */
  --bg-primary: #ffffff;
  --bg-secondary: #f5f5f7;
  --bg-tertiary: #fbfbfd;
  
  /* Text */
  --text-primary: #1d1d1f;
  --text-secondary: #86868b;
  --text-tertiary: #aeaeb2;
  
  /* Accent */
  --accent: #0071e3;
  --accent-hover: #0077ed;
  
  /* Borders */
  --border: #d2d2d7;
  --border-light: #e8e8ed;
}
```

### Status Colors (Apple System Colors)
```css
:root {
  --status-gray: #8e8e93;
  --status-blue: #007aff;
  --status-orange: #ff9500;
  --status-purple: #af52de;
  --status-green: #34c759;
  --status-red: #ff3b30;
}
```

### Priority Badge Colors
| Priority | Background | Text |
|----------|------------|------|
| Low | none | --text-tertiary |
| Medium | none | --text-secondary |
| High | rgba(255,149,0,0.12) | #c77700 |
| Urgent | rgba(255,59,48,0.12) | #d70015 |

---

## Shadows

```css
/* Card resting state */
--card-shadow: 0 2px 8px rgba(0, 0, 0, 0.04);

/* Card hover state */
--card-shadow-hover: 0 4px 16px rgba(0, 0, 0, 0.08);

/* Modal/Dropdown */
--modal-shadow: 0 24px 80px rgba(0, 0, 0, 0.12);
```

---

## Border Radius

| Element | Radius |
|---------|--------|
| Cards | 14px |
| Columns | 12px |
| Task cards | 10px |
| Inputs | 10px |
| Buttons | 8-10px |
| Badges | 6px |
| Small elements | 7px |
| Avatar | 50% |

---

## Component Specifications

### Header
- Background: `rgba(255, 255, 255, 0.72)` with blur
- Backdrop filter: `saturate(180%) blur(20px)`
- Border bottom: 1px solid --border-light
- Height: ~52px
- Sticky positioning

```css
.header {
  background: rgba(255, 255, 255, 0.72);
  backdrop-filter: saturate(180%) blur(20px);
  -webkit-backdrop-filter: saturate(180%) blur(20px);
  border-bottom: 1px solid var(--border-light);
}
```

### Kanban Column
- Width: 300px (fixed)
- Background: --bg-primary (#ffffff)
- Border: 1px solid --border-light
- Border-radius: 12px
- Box-shadow: --card-shadow
- Header border-bottom: 1px solid --border-light

### Task Card
- Background: --bg-tertiary (#fbfbfd)
- Border: 1px solid transparent (visible on hover)
- Border-radius: 10px
- Padding: 14px 16px
- Left accent bar: 3px wide, inset 12px from top/bottom

**Hover State:**
- Background: --bg-primary
- Border: 1px solid --border-light
- Box-shadow: --card-shadow-hover

### Buttons

**Primary Button:**
```css
.btn-primary {
  background: var(--accent);
  color: white;
  border: none;
  border-radius: 8px;
  padding: 10px 18px;
  font-size: 14px;
  font-weight: 500;
}

.btn-primary:hover {
  background: var(--accent-hover);
}
```

**Icon Button:**
```css
.btn-icon {
  background: transparent;
  border: none;
  border-radius: 7px;
  width: 28px;
  height: 28px;
  color: var(--text-tertiary);
}

.btn-icon:hover {
  background: var(--bg-secondary);
  color: var(--accent);
}
```

### Form Inputs
```css
.input {
  background: var(--bg-tertiary);
  border: 1px solid var(--border);
  border-radius: 10px;
  padding: 12px 16px;
  font-size: 15px;
}

.input:focus {
  border-color: var(--accent);
  box-shadow: 0 0 0 3px rgba(0, 113, 227, 0.15);
  outline: none;
}

.input::placeholder {
  color: var(--text-tertiary);
}
```

---

## Spacing Scale

Use 4px increments:
- 4px, 8px, 12px, 16px, 24px, 32px, 48px

Common patterns:
- Card padding: 24px
- Column padding: 16px header, 8px body
- Task card padding: 14px 16px
- Gap between columns: 12px
- Gap between task cards: 8px

---

## Transitions

Standard transition:
```css
transition: all 0.2s ease;
```

Use for:
- Background color changes
- Box shadow changes
- Border color changes
- Transform (translateY)

---

## Empty States

Centered, muted text:
```css
.empty-state {
  color: var(--text-tertiary);
  text-align: center;
  padding: 32px 16px;
  font-size: 13px;
}
```

---

## Icons

Use **Lucide React** icons at these sizes:
- Navigation: 18-20px
- Buttons: 16px
- Inline/meta: 12-14px

Or use SF Symbols style emoji:
- 📋 Clipboard
- 📅 Calendar
- ← Back arrow

---

## Responsive Notes

- Columns fixed at 300px width, horizontal scroll on mobile
- Dashboard grid: `repeat(auto-fill, minmax(320px, 1fr))`
- Login card: max-width 380px, centered
- Maintain padding on mobile: minimum 16px

---

## Tailwind Config

If using Tailwind, extend with Apple colors:

```js
// tailwind.config.js
module.exports = {
  theme: {
    extend: {
      colors: {
        apple: {
          bg: '#f5f5f7',
          card: '#fbfbfd',
          text: '#1d1d1f',
          secondary: '#86868b',
          tertiary: '#aeaeb2',
          accent: '#0071e3',
          border: '#d2d2d7',
          'border-light': '#e8e8ed',
        },
        status: {
          gray: '#8e8e93',
          blue: '#007aff',
          orange: '#ff9500',
          purple: '#af52de',
          green: '#34c759',
          red: '#ff3b30',
        }
      },
      fontFamily: {
        sf: ['SF Pro Text', 'SF Pro Display', '-apple-system', 'BlinkMacSystemFont', 'Inter', 'sans-serif'],
      },
      borderRadius: {
        'apple': '10px',
        'apple-lg': '14px',
      },
      boxShadow: {
        'apple': '0 2px 8px rgba(0, 0, 0, 0.04)',
        'apple-hover': '0 4px 16px rgba(0, 0, 0, 0.08)',
        'apple-modal': '0 24px 80px rgba(0, 0, 0, 0.12)',
      }
    }
  }
}
```

---

## Reference

Open `task-manager-apple-theme.html` in browser to see the exact visual target.

**Key Apple Design Principles:**
1. **Clarity** - Clean, uncluttered interface
2. **Deference** - UI recedes, content is king
3. **Depth** - Subtle shadows and layers create hierarchy

**Anti-patterns to avoid:**
- Heavy borders
- Saturated background colors
- Overly bold text
- Harsh shadows
- Cluttered UI elements
