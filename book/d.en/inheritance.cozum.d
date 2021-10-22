Ddoc

$(COZUM_BOLUMU Inheritance)

$(OL

$(LI The member functions that are declared as $(C abstract) by superclasses must be defined by the $(C override) keyword by subclasses.


$(P
Ignoring the $(C Train) class for this exercise, $(C Locomotive.makeSound) and $(C RailwayCar.makeSound) can be implemented as in the following program:
)

---
import std.stdio;
import std.exception;

class RailwayVehicle {
    void advance(size_t kilometers) {
        writefln("The vehicle is advancing %s kilometers",
                 kilometers);

        foreach (i; 0 .. kilometers / 100) {
            writefln("  %s", makeSound());
        }
    }

    abstract string makeSound();
}

class Locomotive : RailwayVehicle {
    $(HILITE override) string makeSound() {
        return "choo choo";
    }
}

class RailwayCar : RailwayVehicle {
    // ...

    $(HILITE override) string makeSound() {
        return "clack clack";
    }
}

class PassengerCar : RailwayCar {
    // ...
}

class FreightCar : RailwayCar {
    // ...
}

void main() {
    auto railwayCar1 = new PassengerCar;
    railwayCar1.advance(100);

    auto railwayCar2 = new FreightCar;
    railwayCar2.advance(200);

    auto locomotive = new Locomotive;
    locomotive.advance(300);
}
---

)

$(LI
The following program uses the sounds of the components of $(C Train) to make the sound of $(C Train) itself:

---
import std.stdio;
import std.exception;

class RailwayVehicle {
    void advance(size_t kilometers) {
        writefln("The vehicle is advancing %s kilometers",
                 kilometers);

        foreach (i; 0 .. kilometers / 100) {
            writefln("  %s", makeSound());
        }
    }

    abstract string makeSound();
}

class Locomotive : RailwayVehicle {
    override string makeSound() {
        return "choo choo";
    }
}

class RailwayCar : RailwayVehicle {
    abstract void load();
    abstract void unload();

    override string makeSound() {
        return "clack clack";
    }
}

class PassengerCar : RailwayCar {
    override void load() {
        writeln("The passengers are getting on");
    }

    override void unload() {
        writeln("The passengers are getting off");
    }
}

class FreightCar : RailwayCar {
    override void load() {
        writeln("The crates are being loaded");
    }

    override void unload() {
        writeln("The crates are being unloaded");
    }
}

class Train : RailwayVehicle {
    Locomotive locomotive;
    RailwayCar[] cars;

    this(Locomotive locomotive) {
        enforce(locomotive !is null,
                "Locomotive cannot be null");
        this.locomotive = locomotive;
    }

    void addCar(RailwayCar[] cars...) {
        this.cars ~= cars;
    }

    $(HILITE override) string makeSound() {
        string result = locomotive.makeSound();

        foreach (car; cars) {
            result ~= ", " ~ car.makeSound();
        }

        return result;
    }

    void departStation(string station) {
        foreach (car; cars) {
            car.load();
        }

        writefln("Departing from %s station", station);
    }

    void arriveStation(string station) {
        writefln("Arriving at %s station", station);

        foreach (car; cars) {
            car.unload();
        }
    }
}

void main() {
    auto locomotive = new Locomotive;
    auto train = new Train(locomotive);

    train.addCar(new PassengerCar, new FreightCar);

    train.departStation("Ankara");
    train.advance(500);
    train.arriveStation("Haydarpaşa");
}
---

$(P
The output:
)

$(SHELL
The passengers are getting on
The crates are being loaded
Departing from Ankara station
The vehicle is advancing 500 kilometers
  choo choo, clack clack, clack clack
  choo choo, clack clack, clack clack
  choo choo, clack clack, clack clack
  choo choo, clack clack, clack clack
  choo choo, clack clack, clack clack
Arriving at Haydarpaşa station
The passengers are getting off
The crates are being unloaded
)

)

)

Macros:
        TITLE=Inheritance

        DESCRIPTION=The exercise solutions for the Inheritance chapter, explaining how to specify behaviors of classes in the D programming language.

        KEYWORDS=programming in d tutorial class inheritance
