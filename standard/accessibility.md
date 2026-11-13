# Accessibility

Applies when a project has a user interface. Making it usable by people with
different abilities (vision, hearing, motor, cognitive) also makes it
better for everyone.

A project with a UI keeps `docs/accessibility.md`: which checklist below
applies (apps and websites, games, or both for a game with heavy menus),
and the results of each test pass. Record the target as an NFR in
`docs/requirements.md`, for example "meets WCAG 2.2 AA".

**The rule:** any UI change keeps the checklist items true. If you can't
verify an item yourself, say which ones the user should check by hand.

## Apps and websites: WCAG 2.2 level AA

The [Web Content Accessibility Guidelines 2.2](https://www.w3.org/TR/WCAG22/),
level AA. The items that matter most for a small project:

- [ ] **Keyboard:** everything works by keyboard alone, in a sensible
      order, with nowhere the focus gets stuck
- [ ] **Visible focus:** you can always see what has keyboard focus
- [ ] **Contrast:** text at least 4.5:1 against its background (3:1 for
      large text, icons and control borders)
- [ ] **Not colour alone:** add text, an icon or a pattern
- [ ] **Text alternatives:** meaningful images have alt text; decorative
      ones are marked decorative
- [ ] **Labels:** every input has a visible label; errors say what's wrong
      and how to fix it
- [ ] **Zoom:** usable at 200% without losing content
- [ ] **Motion:** respects "reduce motion"; nothing flashes more than 3
      times a second
- [ ] **Target size:** clickable targets at least 24×24 px
- [ ] **Structure:** headings, lists and buttons use the proper elements

## Games

The [Game Accessibility Guidelines](https://gameaccessibilityguidelines.com/),
basic level plus a few common intermediate items:

- [ ] **Controls** can all be remapped
- [ ] **No required speed or precision tricks** (rapid tapping, long holds,
      simultaneous presses), or an alternative exists
- [ ] **Colour-blind safe:** important information isn't colour alone
- [ ] **Subtitles** for all speech, readable size, can be turned on before
      any speech plays
- [ ] **Visual cues** for important sounds
- [ ] **Text size:** UI and subtitle text can be enlarged
- [ ] **Photosensitivity:** nothing flashes more than 3 times a second;
      screen shake and heavy effects can be reduced or turned off
- [ ] **Audio:** separate volume for music, effects and speech
- [ ] **Pause** anywhere
- [ ] **Difficulty** or game speed can be adjusted
- [ ] **Settings first:** accessibility settings reachable before gameplay,
      and remembered

## How to test

Automated tools catch only part of the problems; combine them with manual
checks, and record results in `docs/accessibility.md` or
`docs/manual-tests.md`.

| Check | How |
|---|---|
| Keyboard only | Ignore the mouse and complete the main tasks |
| Contrast | A contrast checker on text and controls |
| Colour blindness | A colour-blindness simulator on screenshots |
| Screen reader (apps, web) | A quick pass with Narrator or NVDA |
| Zoom (apps, web) | Browser or system zoom to 200% |
| Automated scan (web) | axe DevTools or Lighthouse's accessibility audit |
| Remapping, subtitles, flashing (games) | Play a session using the options |

## Checklists

**Every UI change:**
- [ ] The relevant items above still hold for the changed screens
- [ ] New colours meet contrast; new controls work by keyboard or can be
      remapped

**End of each phase:**
- [ ] A full test pass from the table above, recorded
