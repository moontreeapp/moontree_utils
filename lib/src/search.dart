enum Nearest { floor, ceil, closest }

int binaryClosest({
  required List<dynamic> list,
  required dynamic value,
  Nearest type = Nearest.closest,
  Comparator<dynamic>? comp,
}) {
  comp = comp ?? (dynamic a, dynamic b) => (a as int) - (b as int);

  // Quick returns
  if (list.isEmpty) {
    return -1;
  }
  // Our nearest value is less than the lowest value in the list
  if (comp(value, list[0]) <= 0) {
    if (type == Nearest.floor) {
      return -1;
    }
    return 0;
  }
  // Our nearest value is greater than the highest value in the list
  if (comp(value, list[list.length - 1]) >= 0) {
    if (type == Nearest.ceil) {
      return -1;
    }
    return list.length - 1;
  }

  // Modified binary search
  int binarySearchInternal(
    List<dynamic> list,
    Comparator<dynamic> comp,
    dynamic value,
    Nearest type,
    int start,
    int end,
  ) {
    int i = 0;
    int j = end;
    int mid = 0;
    while (i < j) {
      mid = ((i + j) / 2).floor();
      if (comp(value, list[mid]) == 0) {
        return mid;
      } else if (comp(value, list[mid]) < 0) {
        if (mid > 0 && comp(value, list[mid - 1]) > 0) {
          switch (type) {
            case Nearest.floor:
              return mid - 1;
            case Nearest.ceil:
              return mid;
            case Nearest.closest:
              return comp(value, list[mid - 1]).abs() <
                      comp(value, list[mid]).abs()
                  ? mid - 1
                  : mid;
          }
        }
        j = mid;
      } else {
        if (mid < list.length - 1 && comp(value, list[mid + 1]) < 0) {
          switch (type) {
            case Nearest.floor:
              return mid;
            case Nearest.ceil:
              return mid + 1;
            case Nearest.closest:
              return comp(value, list[mid + 1]).abs() <
                      comp(value, list[mid]).abs()
                  ? mid + 1
                  : mid;
          }
        }
        i = mid + 1;
      }
    }

    final int midComp = comp(value, mid);
    if (midComp < 0) {
      if (mid > 0) {
        switch (type) {
          case Nearest.floor:
            return mid - 1;
          case Nearest.ceil:
            return mid;
          case Nearest.closest:
            return comp(value, list[mid - 1]).abs() <
                    comp(value, list[mid]).abs()
                ? mid - 1
                : mid;
        }
      } else {
        if (type == Nearest.floor) {
          return -1;
        }
        return mid;
      }
    }
    if (midComp > 0) {
      if (mid < list.length - 1) {
        switch (type) {
          case Nearest.floor:
            return mid;
          case Nearest.ceil:
            return mid + 1;
          case Nearest.closest:
            return comp(value, list[mid + 1]).abs() <
                    comp(value, list[mid]).abs()
                ? mid + 1
                : mid;
        }
      } else {
        if (type == Nearest.ceil) {
          return -1;
        }
        return mid;
      }
    }

    return mid;
  }

  return binarySearchInternal(list, comp, value, type, 0, list.length - 1);
}

int binarySearch({
  required List<dynamic> list,
  required dynamic value,
  Comparator<dynamic>? comp,
}) {
  comp = comp ?? (dynamic a, dynamic b) => (a as int) - (b as int);
  // Quick returns
  if (list.isEmpty) {
    return -1;
  }
  if (comp(list[0], value) == 0) {
    return 0;
  }
  if (comp(list[list.length - 1], value) == 0) {
    return list.length - 1;
  }

  int binarySearchInternal(
    List<dynamic> list,
    Comparator<dynamic> comp,
    dynamic value,
    int start,
    int end,
  ) {
    if (end >= start) {
      final int mid = ((start + end) / 2).floor();
      if (comp(value, list[mid]) == 0) {
        return mid;
      } else if (comp(value, list[mid]) > 0) {
        return binarySearchInternal(list, comp, value, mid + 1, end);
      } else {
        return binarySearchInternal(list, comp, value, start, mid - 1);
      }
    }
    return -1;
  }

  return binarySearchInternal(list, comp, value, 0, list.length - 1);
}

bool binaryRemove({
  required List<dynamic> list,
  required dynamic value,
  Comparator<dynamic>? comp,
}) {
  final int found = binarySearch(
    list: list,
    value: value,
    comp: comp,
  );
  if (found != -1) {
    list.removeAt(found);
    return true;
  }
  return false;
}

bool binaryInsert({
  required List<dynamic> list,
  required dynamic value,
  Comparator<dynamic>? comp,
  bool doubleAdd = false,
}) {
  comp = comp ?? (dynamic a, dynamic b) => (a as int) - (b as int);
  final int index =
      binaryClosest(list: list, value: value, type: Nearest.ceil, comp: comp);
  if (index >= 0) {
    if (!doubleAdd && comp(value, list[index]) == 0) {
      return false;
    }
    list.insert(index, value);
  } else {
    list.add(value);
  }
  return true;
}
