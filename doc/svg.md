# SVG Cheetsheet 

## Common
* `class='XXX'`
* `id='XXX'`

## Classes
* `other`
* `pin`
* `terminal`
* `1`

## Attributes

### `stroke-linecap`

* `stroke-linecap="butt"` <br>
  \=
* `stroke-linecap="round"` <br>
  \(=)
* `stroke-linecap="square"` <br>
  \===

### `stroke-dasharray="5,5"`

* `stroke-dasharray="5,5"`
* `stroke-dasharray="20,10,5,5,5,10"`

## Line

```svg
<line class='other' x1='0.00' y1='0.00' x2='0.00' y2='0.00' stroke='#000000' stroke-width='1.00' />
```

## Rectangle

```svg
<rect class='other' x='0' y='0' width='1' height='1' fill='none' stroke='solid' stroke-width='1' />
```

## Circle

```svg
<circle class='other' cx="13.5" cy="9" r="3.6" fill="#000000" stroke="none" />
```

## Path
```svg
<path class='other' fill='#000000' stroke-width='0.143' stroke='#000000' d='M9 10.8 L16.2 24.3 L1.8 24.3 Z' />
```

**ARC:**
```svg
A rx ry x-axis-rotation large-arc-flag sweep-flag x y
```

Where:
 * rx ry - radius of arc
 * x-axis-rotation
 * large-arc-flag
 * sweep-flag
 * x y - the end point