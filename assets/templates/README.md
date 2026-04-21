# Training cycle templates

Each file in this directory is a training cycle template — a multi-period plan the user can instantiate to jump-start a new cycle.

## Format versions

- **v5 (strength only)** — the historical format. `workouts[i].exercises` with muscle-group / equipment / set config. Still fully supported.
- **v6 (mixed sport, Phase 5.5+)** — adds a `sport` field per workout plus a `cardioTemplateId` reference for cardio days that points at a file in `assets/cardio_sessions/`.

v6 templates are valid v5 JSON — the `sport` field defaults to `"strength"` when absent, and the loader ignores `cardioTemplateId` until Phase 6 wires up the cardio loader.

## v6 schema sketch

```jsonc
{
  "id": "unique_id",
  "name": "Pretty name",
  "description": "One-paragraph summary",
  "primarySport": "strength | run | bike | swim",  // UI hint, optional
  "periodsTotal": 6,
  "daysPerPeriod": 5,
  "recoveryPeriod": 4,
  "workouts": [
    {
      "periodNumber": 1,
      "dayNumber": 1,
      "dayName": "Upper body",
      "sport": "strength",
      "exercises": [ /* same as v5 */ ]
    },
    {
      "periodNumber": 1,
      "dayNumber": 2,
      "dayName": "Easy run",
      "sport": "run",
      "cardioTemplateId": "run_easy_30min"  // references assets/cardio_sessions/
    }
  ]
}
```

## Cardio session references

`cardioTemplateId` is the basename (without `.json`) of a file in `assets/cardio_sessions/`. When the cardio loader lands in Phase 6, cycle creation will look up the referenced template, instantiate a `CardioSession` with its intervals, and attach it to the cycle's period/day.

Today (Phase 5.5), v6 templates containing `cardioTemplateId` will still load their strength days and simply skip the cardio days — the user can add cardio manually from the edit screen's cardio banner.

## Authoring guidelines

- Keep `description` under 200 characters.
- Use `primarySport` only as a defaults hint (days-per-period, initial sport picker); never rely on it to restrict content.
- Always provide a `dayName` — it shows up in the calendar.
- Strength exercises: reference names from `exercises.csv`. Custom names work but won't be recognized by the exercise library filters.
- Cardio sessions: use the cardio session library (`assets/cardio_sessions/`) rather than redefining intervals inline. Keeps templates short and reusable.
