# ![](https://github.com/DmitrJuga/MapMarker/blob/master/MapMarker/Images.xcassets/AppIcon.appiconset/mapmarker-29@2x.png)  Map Marker

**"Map Marker"** - простое приложение для работы с отметками на карте. Учебный (тестовый) проект на **Objective-C** c использованием фреймворков **MapKit**, **CoreLocation** и **CoreData**.

![](https://github.com/DmitrJuga/MapMarker/blob/master/screenshots/screenshot1.png)
![](https://github.com/DmitrJuga/MapMarker/blob/master/screenshots/screenshot2.png)


## Функционал

- Добавление на карту именованых отметок, их просмотр и удаление.
- Отоброжение на карте текущей геопозиции пользователя (*если разрешено*).
- Добавление отметки производится длинным нажатием в необходимой точке на карте.
- При добавлении отметки пользователь может задать произвольное название места; также в отметке сохраняется адрес точки, получаемый автоматически.
- При нажатии на отметку на карте, отображается сохранённые в ней данные.
- В окне *Список* отображаются все добавленные отметки; при выборе произваольной отметки в списке происходит переключение на окно *Карта* и отображаение на карте соответствующей отметки.
- В окне *Список* возможно удаление как единичных, так и все сохранённых отметок.
- Все добавленные отметки сохраняются и отображаются при повторном запуске.
- *При первом запуске запрашивается разрешение приложению получать доступ к информации о текущем положении.*
- *При запуске в симуляторе необходимо включить симуляцию местоположения.*

## Technical Information

**Data Model:**
- CoreData framework for persistent storage of app data objects (*map markers*);
- My own `DDCoreDataHelper` class which encapsulats CoreData routines, provides shared (singleton) instance, extends `NSManagedObject` calss with custom category;
- CoreData model contain 1 entity (`Point`) with 4 attributes;
- `DDPoint` class represents CoreData entity in app data model;
- Extension of `DDPoint` class (category) adopting `MKAnnotation` protocol to be used as *annotation* on the MapView.
- `DDPointList` class which manages collection (array) of stored objects, implements data model-level-methods, provides shared (singleton) instance.

**App UI:**
- Uses 2 `UIViewController`s + `UITabBarController` + `UINavigationController` (with custom bar);
- `UITableView` with custom cells and row-deleting;
- `MKMapView` with customized `MKAnnotationView` and custom callout view (`DDCalloutView` class);
- Animated callout appearance and disappearance on annotation selecting and deselecting;
- Automatic map scale to show all annotations or to show selected annotation only;
- `UILongPressGestureRecognizer`;
- Auto Layout (Storyboard constraints).

**Extra:**
- CoreLocation framework (`CLLocationManager` with delegate) to display and update current user location on map;
- CoreLocation *WhenInUseAuthorization* permission request;
- AppIcon (image from free web source).


## More Screenshots

![](https://github.com/DmitrJuga/MapMarker/blob/master/screenshots/screenshot3.png)
![](https://github.com/DmitrJuga/MapMarker/blob/master/screenshots/screenshot4.png)
![](https://github.com/DmitrJuga/MapMarker/blob/master/screenshots/screenshot5.png)
![](https://github.com/DmitrJuga/MapMarker/blob/master/screenshots/screenshot6.png)

## Основа проекта

Проект создан на основе моей домашней работы к урокам 3 и 4 по курсу **"Objective C. Уровень 2"** в [НОЧУ ДО «Школа программирования» (http://geekbrains.ru)](http://geekbrains.ru/) и доработан после окончания курса. Домашнее задание и пояснения к выполненой работе - см. в [homework_readme.md](https://github.com/DmitrJuga/MapMarker/blob/master/homework_readme.md).

---

### Contacts

**Дмитрий Долотенко / Dmitry Dolotenko**

Krasnodar, Russia   
Phone: +7 (918) 464-02-63   
E-mail: <dmitrjuga@gmail.com>   
Skype: d2imas

:]

