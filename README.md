![](img/edw-fritzing-example.png)

# EdW Fritzing Parts

This project is a library of electronics schema parts adjusted for [Fritzing](https://fritzing.org/home/) application, based on template provided by polish magazine [Elektronika Dla Wszystkich](https://elportal.pl/).

The project's goal wasn not a full integration with Fritzing. The library containing only set of schematic elements as SVG files, without PCB and breadboard support. There are no plans so far to add them in future releases.

## License

This is an Open Source project released under the [GPL-3.0 License](LICENSE). But all rights to the drawings are held by the "Elektronika dla Wszystkich" magazine. All parts were originally designed and created by EdW's editor-in-chief [Piotr Górecki](https://www.facebook.com/Piotr-G%C3%B3recki-o-elektronice-105147944792967/).

Anyone can use this set of parts to prepare drawings for publication in magazine "Elektronika dla Wszystkich" and for other private (non-commercial) purposes, for example at school and university or on private websites. You are not allowed to use this set of parts for profit-making purposes without the explicitly consent of the Author and "Elektronika dla Wszystkich" magazine's editors.

## Install

Get [latest](https://github.com/di0x7c5/edw-fritzing-parts/releases/latest) version of tarball and extract it directly into `fritzing-parts` folder:

```
$ tar xzf edw-fritzing-parts_v*.tar.gz -C /opt/fritzing/fritzing-parts/
```

Then use built in application command to regenerate parts database from `Parts` -> `Regenerate parts database ...`, or use below command to do it the same from CLI:

```
$ Fritzing -db "/opt/fritzing/fritzing-parts/parts.db"
```

## Configuration

All elements are hand-made designed base on 0.5 inch mesh. There is necessary to set same value in Fritzing grid settings. Go to `Schematic` tab, then open menu `View` -> `Set Grid Size...` and set value `0.5` in.

![](img/edw-fritzing-set-grid-size.png)

After that operation all elements now should match each other perfectly.
