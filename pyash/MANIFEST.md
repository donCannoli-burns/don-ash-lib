# Install manifest

Copy these paths into the corresponding KoLmafia directories:

```text
scripts/pyash.ash     -> <KoLmafia>/scripts/pyash.ash
data/pyash/hello.py   -> <KoLmafia>/data/pyash/hello.py
data/pyash/math.py    -> <KoLmafia>/data/pyash/math.py
data/pyash/smoke.py   -> <KoLmafia>/data/pyash/smoke.py
```

Then run:

```text
verify pyash.ash
call pyash.ash run pyash/smoke.py
```
